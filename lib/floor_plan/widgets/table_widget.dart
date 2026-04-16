import 'package:flutter/material.dart';
import 'package:pos_app/api_client.dart';
import 'package:pos_app/cart_provider.dart';
import 'package:pos_app/floor_plan_table.dart';

class TableWidget extends StatelessWidget {
  final FloorPlanTable table;
  final int companyId;
  final int userId;
  final int warehouseId;

  const TableWidget({
    Key? key,
    required this.table,
    required this.companyId,
    required this.userId,
    required this.warehouseId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✨ 1. Dynamic Colors based on Status!
    Color tableColor = Colors.green.shade400; // Free
    if (table.status == 1) tableColor = Colors.red.shade400; // Occupied
    if (table.status == 2) tableColor = Colors.orange.shade400; // Reserved

    return GestureDetector(
      onTap: () async {
        if (table.status == 1) {
          // Table is already occupied (Red).
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Table is already occupied!')),
          );
          return;
        }

        // ✨ 2. Table is Free (Green)! Let's create an order.
        try {
          // Optional: Show a quick loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                const Center(child: CircularProviderIndicator()),
          );

          final apiClient =
              ApiClient(); // Or however you access your Dio client

          // Call the C# Backend
          final int newOrderId = await apiClient.createPosOrder(
            companyId,
            userId,
            1, // 1 = Dine-in Service Type
            table.id,
          );

          // Close the loading dialog
          if (context.mounted) Navigator.pop(context);

          // ✨ 3. Tell the "Brain" that we have an active order!
          if (context.mounted) {
            Provider.of<CartProvider>(context, listen: false)
                .setOrderContext(newOrderId, warehouseId);

            // ✨ 4. Navigate to the Menu/Cart Screen
            // (Make sure '/menu' matches the route in your main.dart)
            Navigator.pushNamed(context, '/menu');
          }
        } catch (e) {
          if (context.mounted) Navigator.pop(context); // Close loader on error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening table: $e')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: tableColor,
          borderRadius: table.isRound
              ? BorderRadius.circular(100)
              : BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(2, 2),
            )
          ],
        ),
        child: Center(
          child: Text(
            table.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
