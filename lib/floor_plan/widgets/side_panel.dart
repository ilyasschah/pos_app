import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/floor_plan/floor_plan_provider.dart';
import 'package:pos_app/floor_plan/floor_plan_table.dart';
import 'package:pos_app/floor_plan/floor_plan_table_provider.dart';
import 'package:pos_app/floor_plan/active_orders_screen.dart';

class SidePanel extends ConsumerWidget {
  const SidePanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fpState = ref.watch(floorPlanProvider);
    final selectedTableId = ref.watch(floorPlanTableProvider);

    return Drawer(
      backgroundColor: const Color(0xFF1F2937),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(fpState.isEditMode ? "Edit Options" : "Options",
                      style:
                          const TextStyle(color: Colors.white, fontSize: 24)),
                  if (fpState.isEditMode)
                    IconButton(
                      icon:
                          const Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: () {
                        ref
                            .read(floorPlanProvider.notifier)
                            .toggleEditMode(false);
                        ref
                            .read(floorPlanTableProvider.notifier)
                            .selectTable(null);
                      },
                    )
                ],
              ),
            ),
            const Divider(color: Colors.grey),
            Expanded(
              child: !fpState.isEditMode
                  ? _buildMainMenu(context, ref)
                  : (selectedTableId == null
                      ? _buildRoomOptions(
                          context, ref, fpState.activeFloorPlanId ?? 0)
                      : _buildTableEditor(context, ref, selectedTableId)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMainMenu(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ListTile(
          leading: const Icon(Icons.list, color: Colors.white),
          title:
              const Text("Show orders", style: TextStyle(color: Colors.white)),
          onTap: () {
            // ✨ FIX: Close drawer and navigate to Active Orders
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ActiveOrdersScreen()));
          },
        ),
        const Divider(color: Colors.grey),
        ListTile(
          leading: const Icon(Icons.color_lens, color: Colors.white),
          title: const Text("Floor plan / table settings",
              style: TextStyle(color: Colors.white)),
          onTap: () {
            ref.read(floorPlanProvider.notifier).toggleEditMode(true);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Edit Mode ON: Tap any table to resize it!")));
          },
        ),
      ],
    );
  }

  Widget _buildRoomOptions(
      BuildContext context, WidgetRef ref, int activePlanId) {
    final fpState = ref.watch(floorPlanProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text("Show grid", style: TextStyle(color: Colors.white)),
          value: fpState.showGrid,
          activeThumbColor: Colors.greenAccent,
          onChanged: (val) =>
              ref.read(floorPlanProvider.notifier).toggleShowGrid(val),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF374151)),
              onPressed: () {
                if (activePlanId != 0) {
                  ref.read(floorPlanTableProvider.notifier).addTable(
                      FloorPlanTable(
                          id: 0,
                          floorPlanId: activePlanId,
                          name: "New Table",
                          positionX: 50,
                          positionY: 50,
                          width: 80,
                          height: 80,
                          isRound: false));
                }
              },
              child: const Text("Add table",
                  style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF374151)),
              onPressed: () {
                // 燥 FIX: Added real logic to create a new Floor Plan
                showDialog(
                    context: context,
                    builder: (ctx) {
                      String newName = "";
                      return AlertDialog(
                          title: const Text("New Floor Plan"),
                          content: TextField(
                            onChanged: (v) => newName = v,
                            decoration: const InputDecoration(
                                hintText: "E.g., Second Floor"),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("Cancel")),
                            TextButton(
                                onPressed: () {
                                  if (newName.isNotEmpty) {
                                    ref
                                        .read(floorPlanProvider.notifier)
                                        .addFloorPlan(newName, "Transparent");
                                  }
                                  Navigator.pop(ctx);
                                },
                                child: const Text("Save"))
                          ]);
                    });
              },
              child: const Text("Add new floor plan",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTableEditor(BuildContext context, WidgetRef ref, int tableId) {
    final tablesAsync = ref.watch(tablesByFloorPlanProvider);
    final tables = tablesAsync.value;
    if (tables == null) return const SizedBox();

    final tableIndex = tables.indexWhere((t) => t.id == tableId);
    if (tableIndex == -1) return const SizedBox();
    final table = tables[tableIndex];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF374151)),
          onPressed: () =>
              ref.read(floorPlanTableProvider.notifier).deleteTable(tableId),
          child: const Text("Remove selected table",
              style: TextStyle(color: Colors.redAccent)),
        ),
        const SizedBox(height: 20),
        Text("Table: ${table.name}",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        const Text("Height & Width",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Height", style: TextStyle(color: Colors.white70)),
          Row(children: [
            IconButton(
                icon: const Icon(Icons.remove, color: Colors.white),
                onPressed: () {
                  if (table.height > 20) {
                    ref
                        .read(floorPlanTableProvider.notifier)
                        .updateTableGeometry(table.id, table.positionX,
                            table.positionY, table.width, table.height - 10);
                  }
                }),
            Text("${table.height.toInt()}",
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  ref.read(floorPlanTableProvider.notifier).updateTableGeometry(
                      table.id,
                      table.positionX,
                      table.positionY,
                      table.width,
                      table.height + 10);
                }),
          ])
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Width", style: TextStyle(color: Colors.white70)),
          Row(children: [
            IconButton(
                icon: const Icon(Icons.remove, color: Colors.white),
                onPressed: () {
                  if (table.width > 20) {
                    ref
                        .read(floorPlanTableProvider.notifier)
                        .updateTableGeometry(table.id, table.positionX,
                            table.positionY, table.width - 10, table.height);
                  }
                }),
            Text("${table.width.toInt()}",
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  ref.read(floorPlanTableProvider.notifier).updateTableGeometry(
                      table.id,
                      table.positionX,
                      table.positionY,
                      table.width + 10,
                      table.height);
                }),
          ])
        ]),
      ],
    );
  }
}
