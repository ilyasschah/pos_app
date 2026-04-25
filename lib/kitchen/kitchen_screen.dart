import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';

// --- 1. MODELS ---
class KitchenItem {
  final int id;
  final String name;
  final double quantity;
  final String? comment;

  // isDone is NOT mutable here anymore.
  // It is managed in KitchenCardState instead.
  const KitchenItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.comment,
  });
}

class KitchenOrder {
  final int id;
  final String number;
  final int? tableId;
  final int serviceType;
  final DateTime? dateCreated;
  final List<KitchenItem> items;

  const KitchenOrder({
    required this.id,
    required this.number,
    this.tableId,
    required this.serviceType,
    this.dateCreated,
    required this.items,
  });

  String get typeString {
    switch (serviceType) {
      case 1:
        return "Dine in";
      case 2:
        return "Takeaway";
      case 3:
        return "Delivery";
      default:
        return "Order";
    }
  }

  Color get headerColor {
    if (dateCreated == null) return const Color(0xFFAED581);
    final minutesOld = DateTime.now().difference(dateCreated!).inMinutes;
    if (minutesOld > 15) return const Color(0xFFFF8A65);
    if (minutesOld > 5) return const Color(0xFFFFF176);
    return const Color(0xFFAED581);
  }
}

// --- 2. MAIN SCREEN ---
class KitchenScreen extends ConsumerStatefulWidget {
  const KitchenScreen({super.key});

  @override
  ConsumerState<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends ConsumerState<KitchenScreen> {
  Timer? _refreshTimer;
  int _refreshSeconds = 30;
  bool _isLoading = false;
  List<KitchenOrder> _orders = [];

  @override
  void initState() {
    super.initState();
    // Defer first fetch so the widget is fully mounted before any setState call
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchData();
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      Duration(seconds: _refreshSeconds),
      (_) {
        if (mounted) _fetchData();
      },
    );
  }

  Future<void> _fetchData() async {
    // Guard: don't stack concurrent fetches
    if (_isLoading || !mounted) return;

    setState(() => _isLoading = true);

    int? companyId = ref.read(selectedCompanyProvider)?.id;
    if (companyId == null &&
        Uri.base.queryParameters.containsKey('companyId')) {
      companyId = int.tryParse(Uri.base.queryParameters['companyId']!);
    }

    if (companyId == null || companyId == 0) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final apiClient = ApiClient();
      final rawData = await apiClient.getKitchenOrders(companyId);

      // Do all parsing BEFORE touching setState so we spend minimal time
      // between the mounted check and the setState call.
      final List<KitchenOrder> loadedOrders = [];

      for (final item in rawData) {
        final orderData = item['order'] ?? item['Order'];
        final itemsData = item['items'] ?? item['Items'];

        if (orderData == null || itemsData == null) continue;

        final List<KitchenItem> kitchenItems =
            (itemsData as List<dynamic>).map((i) {
          return KitchenItem(
            id: i['id'] ?? i['Id'] ?? 0,
            name: i['productName'] ?? i['ProductName'] ?? 'Unknown Item',
            quantity: (i['quantity'] ?? i['Quantity'] ?? 1).toDouble(),
            comment: i['comment'] ?? i['Comment'],
          );
        }).toList();

        DateTime? parsedDate;
        final dateStr = orderData['dateCreated'] ??
            orderData['DateCreated'] ??
            orderData['date'] ??
            orderData['Date'];
        if (dateStr != null) {
          parsedDate = DateTime.tryParse(dateStr.toString());
        }

        loadedOrders.add(KitchenOrder(
          id: orderData['id'] ?? orderData['Id'],
          number: orderData['number'] ?? orderData['Number'] ?? 'Unknown',
          tableId:
              orderData['floorPlanTableId'] ?? orderData['FloorPlanTableId'],
          serviceType:
              orderData['serviceType'] ?? orderData['ServiceType'] ?? 1,
          dateCreated: parsedDate,
          items: kitchenItems,
        ));
      }

      // Single mounted check immediately before setState
      if (!mounted) return;
      setState(() {
        _orders = loadedOrders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('KitchenScreen fetch error: $e');
    }
  }

  void _removeOrder(int orderId) {
    if (!mounted) return;
    setState(() => _orders.removeWhere((o) => o.id == orderId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF546E7A),
        foregroundColor: Colors.white,
        title: Text(
          "${_orders.length} order${_orders.length == 1 ? '' : 's'}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          const Icon(Icons.timer, size: 18, color: Colors.white70),
          const SizedBox(width: 4),
          DropdownButton<int>(
            value: _refreshSeconds,
            dropdownColor: const Color(0xFF546E7A),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            items: const [
              DropdownMenuItem(value: 10, child: Text("10s")),
              DropdownMenuItem(value: 30, child: Text("30s")),
              DropdownMenuItem(value: 60, child: Text("60s")),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _refreshSeconds = val);
                _startTimer();
              }
            },
          ),
          const SizedBox(width: 8),
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchData,
                ),
          const SizedBox(width: 8),
        ],
      ),
      body: _orders.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.kitchen, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    _isLoading ? "Loading orders..." : "Waiting for orders...",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _orders.map((order) {
                  return KitchenCard(
                    // Key is critical — it tells Flutter which card is which
                    // when items are added or removed from the list.
                    key: ValueKey(order.id),
                    order: order,
                    onRemove: () => _removeOrder(order.id),
                  );
                }).toList(),
              ),
            ),
    );
  }
}

// --- 3. KITCHEN CARD ---
// Converted from StatelessWidget to StatefulWidget so that
// item done-state is managed properly inside State, not on the model.
class KitchenCard extends StatefulWidget {
  final KitchenOrder order;
  final VoidCallback onRemove;

  const KitchenCard({
    super.key,
    required this.order,
    required this.onRemove,
  });

  @override
  State<KitchenCard> createState() => _KitchenCardState();
}

class _KitchenCardState extends State<KitchenCard> {
  // Local done-state keyed by item id — lives in State, not on the model
  late final Map<int, bool> _doneMap;

  @override
  void initState() {
    super.initState();
    _doneMap = {for (final item in widget.order.items) item.id: false};
  }

  void _toggleItem(int itemId) {
    if (!mounted) return;
    setState(() => _doneMap[itemId] = !(_doneMap[itemId] ?? false));
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final title =
        order.tableId != null ? "Table ${order.tableId}" : order.number;
    final timeStr = order.dateCreated != null
        ? "${order.dateCreated!.hour.toString().padLeft(2, '0')}:"
            "${order.dateCreated!.minute.toString().padLeft(2, '0')}"
        : "";

    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: order.headerColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (timeStr.isNotEmpty)
                  Text(
                    timeStr,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
          ),

          // Service type label
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              order.typeString,
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          // Items
          Column(
            children: order.items.map((item) {
              final isDone = _doneMap[item.id] ?? false;
              return InkWell(
                onTap: () => _toggleItem(item.id),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${item.quantity.toInt()} x ",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: isDone ? Colors.grey : Colors.black87,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 18,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: isDone ? Colors.grey : Colors.black87,
                              ),
                            ),
                          ),
                          // Visual tick indicator
                          if (isDone)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                        ],
                      ),
                      if (item.comment != null && item.comment!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 32),
                          child: Text(
                            item.comment!,
                            style: TextStyle(
                              fontSize: 15,
                              color: isDone
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          // Footer buttons
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                  label: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: widget.onRemove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    "Done",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
