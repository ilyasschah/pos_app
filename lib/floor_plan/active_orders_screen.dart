import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/cart/cart_provider.dart';
import 'package:pos_app/menu/menu_screen.dart';
import 'package:pos_app/stock/warehouse_provider.dart';
import 'package:pos_app/utils/status_helper.dart';

// Riverpod Provider to fetch the orders automatically
final activeOrdersListProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final companyId = ref.watch(selectedCompanyProvider)?.id;
  if (companyId == null) return [];
  final apiClient = ApiClient();
  return await apiClient.getAllActiveOrders(companyId);
});

class ActiveOrdersScreen extends ConsumerStatefulWidget {
  const ActiveOrdersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ActiveOrdersScreen> createState() => _ActiveOrdersScreenState();
}

class _ActiveOrdersScreenState extends ConsumerState<ActiveOrdersScreen> {
  bool isOpeningOrder = false;

  void _openOrder(int posOrderId) async {
    if (isOpeningOrder) return;
    setState(() => isOpeningOrder = true);

    final companyId = ref.read(selectedCompanyProvider)?.id ?? 0;
    final warehousesAsync = ref.read(allWarehousesProvider);
    final warehouseId = warehousesAsync.maybeWhen(
      data: (list) => list.isNotEmpty ? list.first.id : 1,
      orElse: () => 1,
    );
    final apiClient = ApiClient();

    try {
      final success = await ref
          .read(cartProvider.notifier)
          .loadOrderById(apiClient, companyId, posOrderId, warehouseId);

      if (success && mounted) {
        // Navigate to the Menu screen with the order loaded!
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MenuScreen()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => isOpeningOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(activeOrdersListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        title:
            const Text("Active Orders", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isOpeningOrder
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                  child: Text("Error: $err",
                      style: const TextStyle(color: Colors.red))),
              data: (allOrders) {
                final orders = allOrders.where((o) {
                  final status = (o['serviceStatus'] ?? o['ServiceStatus'] ?? 0).toInt();
                  return status > 0;
                }).toList();

                if (orders.isEmpty) {
                  return const Center(
                      child: Text("No active orders found.",
                          style: TextStyle(color: Colors.white, fontSize: 18)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final orderId = order['id'] ?? order['Id'];
                    final orderNumber =
                        order['number'] ?? order['Number'] ?? "Unknown";
                    final status = (order['serviceStatus'] ??
                            order['ServiceStatus'] ??
                            1)
                        .toInt();

                    return Card(
                      color: const Color(0xFF374151),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: ServiceStatusHelper.getColor(status),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        leading: CircleAvatar(
                          backgroundColor: ServiceStatusHelper.getColor(status),
                          child: Icon(
                            ServiceStatusHelper.getIcon(status),
                            color: Colors.white,
                          ),
                        ),
                        title: Text("Order: $orderNumber",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                        subtitle: Text(
                          "Status: ${ServiceStatusHelper.getLabel(status)}",
                          style: TextStyle(
                            color: ServiceStatusHelper.getColor(status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.white),
                        onTap: () => _openOrder(orderId),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
