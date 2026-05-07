import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/floor_plan/floor_plan_provider.dart';
import 'package:pos_app/floor_plan/floor_plan_table.dart';
import 'package:pos_app/floor_plan/floor_plan_table_provider.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/cart/cart_provider.dart';
import 'package:pos_app/utils/status_helper.dart';
import 'package:pos_app/app_settings/app_settings_provider.dart';

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
                final types = ref
                    .read(appSettingsProvider.notifier)
                    .customServiceTypes;
                final serviceType = await showDialog<int>(
                  context: context,
                  builder: (dialogCtx) => Dialog(
                    backgroundColor: const Color(0xFF2C3E50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 40.0,
                        horizontal: 20.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Service type",
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Select service type for this order",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: types.asMap().entries.map((e) {
                              final idx = e.key;
                              final t = e.value;
                              final color = _kServiceTypePalette[
                                  idx % _kServiceTypePalette.length];
                              final icon = _kServiceTypeIcons[
                                  idx.clamp(0, _kServiceTypeIcons.length - 1)];
                              return InkWell(
                                onTap: () =>
                                    Navigator.pop(dialogCtx, t.id),
                                borderRadius: BorderRadius.circular(12),
                                hoverColor: Colors.white.withAlpha(25),
                                splashColor: Colors.white.withAlpha(50),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.25),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          icon,
                                          size: 64,
                                          color: color,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        t.name,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                if (serviceType == null) return;

                if (serviceType != 0) {
                  // Takeaway / Delivery: tableless order — do NOT attach table
                  await ref
                      .read(cartProvider.notifier)
                      .startTablelessOrder(
                        apiClient,
                        widget.companyId,
                        widget.userId,
                        serviceType,
                      );
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/menu');
                  }
                } else {
                  // Dine-In: reserve this specific table
                  final int newOrderId = await apiClient.createPosOrder(
                    widget.companyId,
                    widget.userId,
                    serviceType,
                    widget.table.id,
                    widget.table.name,
                    widget.warehouseId,
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
                        .copyWith(serviceType: 0);
                    Navigator.pushReplacementNamed(context, '/menu');
                  }
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
            gradient: ServiceStatusHelper.getGradient(widget.table.status),
            shape: widget.table.isRound ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.table.isRound ? null : BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
              width: isSelected ? 3 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
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

const _kServiceTypePalette = [
  Color(0xFF4F89F0), // Blue   – Dine-In
  Color(0xFFFF7043), // Orange – Takeaway
  Color(0xFF66BB6A), // Green  – Delivery
  Color(0xFFAB47BC), // Purple
  Color(0xFF26C6DA), // Cyan
  Color(0xFFFFCA28), // Amber
];

const _kServiceTypeIcons = [
  Icons.restaurant,
  Icons.shopping_bag_outlined,
  Icons.delivery_dining,
  Icons.room_service,
  Icons.local_cafe,
  Icons.local_bar,
];
