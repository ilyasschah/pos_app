import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/floor_plan_provider.dart';
import 'package:pos_app/floor_plan_table.dart';
import 'package:pos_app/floor_plan_table_provider.dart';
import 'package:pos_app/menu_screen.dart';
// Adjust your imports based on your folder structure:

class TableWidget extends ConsumerStatefulWidget {
  final FloorPlanTable table;
  const TableWidget({Key? key, required this.table}) : super(key: key);
  @override
  ConsumerState<TableWidget> createState() => _TableWidgetState();
}

class _TableWidgetState extends ConsumerState<TableWidget> {
  late double localX;
  late double localY;

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
    final isEditMode =
        ref.watch(floorPlanProvider).isEditMode; // Watch the mode
    final isSelected = selectedTableId == widget.table.id && isEditMode;

    return Positioned(
      left: localX,
      top: localY,
      width: widget.table.width,
      height: widget.table.height,
      child: GestureDetector(
        onTap: () {
          if (isEditMode) {
            // EDIT MODE: Select table and open side panel
            ref
                .read(floorPlanTableProvider.notifier)
                .selectTable(widget.table.id);
            Scaffold.of(context).openEndDrawer();
          } else {
            // ORDER MODE: Go to POS!
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MenuScreen()),
            );
          }
        },
        // ONLY allow dragging if in Edit Mode
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
            color: isSelected ? Colors.green[400] : Colors.green[600],
            shape: widget.table.isRound ? BoxShape.circle : BoxShape.rectangle,
            border: Border.all(
              color: isSelected ? Colors.white : Colors.green[800]!,
              width: isSelected ? 3 : 2,
            ),
          ),
          child: Center(
            child: Text(
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
