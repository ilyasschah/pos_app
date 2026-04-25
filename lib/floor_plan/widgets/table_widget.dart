import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/floor_plan/floor_plan_provider.dart';
import 'package:pos_app/floor_plan/floor_plan_table.dart';
import 'package:pos_app/floor_plan/floor_plan_table_provider.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/cart/cart_provider.dart';

class TableWidget extends ConsumerStatefulWidget {
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
  ConsumerState<TableWidget> createState() => _TableWidgetState();
}

class _TableWidgetState extends ConsumerState<TableWidget> {
  late double localX;
  late double localY;
  bool isCreatingOrder = false;

  @override
  void initState() {
    super.initState();
    localX = widget.table.positionX;
    localY = widget.table.positionY;
  }

  @override
  void didUpdateWidget(covariant TableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.table.positionX != widget.table.positionX ||
        oldWidget.table.positionY != widget.table.positionY) {
      localX = widget.table.positionX;
      localY = widget.table.positionY;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTableId = ref.watch(floorPlanTableProvider);
    final isEditMode = ref.watch(floorPlanProvider).isEditMode;
    final isSelected = selectedTableId == widget.table.id && isEditMode;

    // ✨ Dynamic Colors based on Backend Status!
    Color tableColor = Colors.green.shade600;

    if (isEditMode) {
      tableColor = isSelected ? Colors.green.shade400 : Colors.green.shade600;
    } else {
      if (widget.table.status == 0) tableColor = Colors.green.shade600; // Free
      if (widget.table.status == 1)
        tableColor = Colors.red.shade600; // Occupied
      if (widget.table.status == 2)
        tableColor = Colors.orange.shade600; // Reserved
    }

    return Positioned(
      left: localX,
      top: localY,
      width: widget.table.width,
      height: widget.table.height,
      child: GestureDetector(
        onTap: () async {
          if (isEditMode) {
            ref
                .read(floorPlanTableProvider.notifier)
                .selectTable(widget.table.id);
            Scaffold.of(context).openEndDrawer();
          } else {
            // ✨ ORDER MODE
            if (isCreatingOrder) return;
            setState(() => isCreatingOrder = true);

            try {
              final apiClient = ApiClient();

              // --- 1. IF TABLE IS OCCUPIED (RED) -> LOAD ORDER ---
              if (widget.table.status == 1) {
                final success = await ref
                    .read(cartProvider.notifier)
                    .loadExistingOrder(apiClient, widget.companyId,
                        widget.table.id, widget.warehouseId);

                if (success && mounted) {
                  Navigator.pushReplacementNamed(context, '/menu');
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text('Could not find active order for this table.'),
                      backgroundColor: Colors.red));
                }
              }
              // --- 2. IF TABLE IS FREE (GREEN) -> CREATE NEW ORDER ---
              else {
                final int newOrderId = await apiClient.createPosOrder(
                  widget.companyId,
                  widget.userId,
                  1,
                  widget.table.id,
                );

                if (mounted) {
                  ref
                      .read(cartProvider.notifier)
                      .setOrderContext(newOrderId, widget.warehouseId);
                  Navigator.pushReplacementNamed(context, '/menu');
                }
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error: $e'), backgroundColor: Colors.red));
              }
            } finally {
              if (mounted) setState(() => isCreatingOrder = false);
            }
          }
        },
        onPanUpdate: isEditMode
            ? (details) {
                setState(() {
                  localX += details.delta.dx;
                  localY += details.delta.dy;
                });
              }
            : null,
        onPanEnd: isEditMode
            ? (details) {
                ref.read(floorPlanTableProvider.notifier).updateTableGeometry(
                      widget.table.id,
                      localX,
                      localY,
                      widget.table.width,
                      widget.table.height,
                    );
              }
            : null,
        child: Container(
          decoration: BoxDecoration(
            color: tableColor,
            shape: widget.table.isRound ? BoxShape.circle : BoxShape.rectangle,
            border: Border.all(
              color: isSelected ? Colors.white : Colors.green[800]!,
              width: isSelected ? 3 : 2,
            ),
          ),
          child: Center(
            child: isCreatingOrder
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    widget.table.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
          ),
        ),
      ),
    );
  }
}
