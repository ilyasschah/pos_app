import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/floor_plan/floor_plan_provider.dart';
import 'package:pos_app/floor_plan/floor_plan_table.dart';
import 'package:pos_app/floor_plan/floor_plan_table_provider.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/cart/cart_provider.dart';
import 'package:pos_app/utils/status_helper.dart';

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

    // ✨ Universal Status Mapping
    Color tableColor = ServiceStatusHelper.getColor(widget.table.status);
    if (isEditMode) {
      tableColor = isSelected ? Colors.green.shade400 : Colors.green.shade600;
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
            if (isCreatingOrder) return;
            setState(() => isCreatingOrder = true);

            try {
              final apiClient = ApiClient();

              if (widget.table.status > 0) {
                final success = await ref
                    .read(cartProvider.notifier)
                    .loadExistingOrder(
                      apiClient,
                      widget.companyId,
                      widget.table.id,
                      widget.warehouseId,
                    );

                if (success && mounted) {
                  Navigator.pushReplacementNamed(context, '/menu');
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Could not find active order for this table.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                final serviceType = await showDialog<int>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Select Service Type"),
                    content: const Text("How will the customer be served?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, 0),
                        child: const Text("Dine In"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, 1),
                        child: const Text("Takeaway"),
                      ),
                    ],
                  ),
                );

                if (serviceType == null) return;

                final int newOrderId = await apiClient.createPosOrder(
                  widget.companyId,
                  widget.userId,
                  serviceType,
                  widget.table.id,
                  widget.table.name,
                );

                if (mounted) {
                  ref
                      .read(cartProvider.notifier)
                      .setOrderContext(
                        newOrderId,
                        widget.warehouseId,
                        tableId: widget.table.id,
                        orderNumber: "ORD- ${widget.table.name}",
                      );
                  ref.read(cartProvider.notifier).state = ref
                      .read(cartProvider)
                      .copyWith(serviceType: serviceType);

                  Navigator.pushReplacementNamed(context, '/menu');
                }
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
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
                ref
                    .read(floorPlanTableProvider.notifier)
                    .updateTableGeometry(
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
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        ServiceStatusHelper.getIcon(widget.table.status),
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.table.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
