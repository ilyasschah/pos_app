import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/auth/auth_provider.dart';
import 'package:pos_app/bookings/bookings_provider.dart';
import 'package:pos_app/cart/cart_provider.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/currency/currencies_provider.dart';

// TODO (backend): ensure /PosOrder/GetAll returns all unpaid orders for the company.
// getAllActiveOrders already filters serviceStatus > 0, which covers open/parked orders.
final openOrdersProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];
  return ApiClient().getAllActiveOrders(company.id);
});

class OpenOrdersScreen extends ConsumerWidget {
  const OpenOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(openOrdersProvider);
    final allUsers = ref.watch(allUsersProvider).value ?? [];
    final allRooms = ref.watch(allRoomsProvider).value ?? [];
    final sym = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(openOrdersProvider),
          ),
        ],
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error loading orders: $e',
              style: const TextStyle(color: Colors.red)),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No open orders',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth > 900
                  ? 3
                  : constraints.maxWidth > 600
                      ? 2
                      : 1;
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.8,
                ),
                itemCount: orders.length,
                itemBuilder: (context, i) {
                  final o = orders[i];
                  final orderId = (o['id'] ?? o['Id']) as int;
                  final orderNumber =
                      (o['number'] ?? o['Number'] ?? 'ORD-$orderId') as String;
                  final total =
                      (o['total'] ?? o['Total'] ?? 0.0 as num).toDouble();
                  final staffId = o['userId'] ?? o['UserId'];
                  final tableId = o['floorPlanTableId'] ?? o['FloorPlanTableId'];
                  final warehouseId =
                      ((o['warehouseId'] ?? o['WarehouseId'] ?? 0) as num)
                          .toInt();

                  final staffName = staffId != null
                      ? allUsers
                          .where((u) => u.id == staffId)
                          .map((u) => u.displayName)
                          .firstOrNull
                      : null;
                  final tableName = tableId != null
                      ? allRooms
                          .where((t) => t.id == tableId)
                          .map((t) => t.name)
                          .firstOrNull
                      : null;

                  return _OpenOrderCard(
                    orderId: orderId,
                    orderNumber: orderNumber,
                    total: total,
                    staffName: staffName,
                    tableName: tableName,
                    warehouseId: warehouseId,
                    sym: sym,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _OpenOrderCard extends ConsumerStatefulWidget {
  final int orderId;
  final String orderNumber;
  final double total;
  final String? staffName;
  final String? tableName;
  final int warehouseId;
  final String sym;

  const _OpenOrderCard({
    required this.orderId,
    required this.orderNumber,
    required this.total,
    required this.staffName,
    required this.tableName,
    required this.warehouseId,
    required this.sym,
  });

  @override
  ConsumerState<_OpenOrderCard> createState() => _OpenOrderCardState();
}

class _OpenOrderCardState extends ConsumerState<_OpenOrderCard> {
  bool _loading = false;

  Future<void> _reopen() async {
    final company = ref.read(selectedCompanyProvider);
    if (company == null) return;
    setState(() => _loading = true);
    try {
      final ok = await ref.read(cartProvider.notifier).loadOrderById(
            ApiClient(),
            company.id,
            widget.orderId,
            widget.warehouseId,
          );
      if (!mounted) return;
      if (ok) {
        // OpenOrdersScreen was pushed on top of MenuScreen from the Drawer,
        // so popping returns directly to MenuScreen with the loaded cart.
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to load order.'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _loading ? null : _reopen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _loading
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary),
                      )
                    : Icon(Icons.receipt_long,
                        color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.orderNumber,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (widget.tableName != null) ...[
                          Icon(Icons.meeting_room,
                              size: 13,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.55)),
                          const SizedBox(width: 4),
                          Text(
                            widget.tableName!,
                            style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.55)),
                          ),
                          const SizedBox(width: 10),
                        ],
                        if (widget.staffName != null) ...[
                          Icon(Icons.badge,
                              size: 13,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.55)),
                          const SizedBox(width: 4),
                          Text(
                            widget.staffName!,
                            style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.55)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.total.toStringAsFixed(2)} ${widget.sym}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to reopen',
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.45)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
