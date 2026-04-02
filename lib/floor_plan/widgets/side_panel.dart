import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/floor_plan_provider.dart';
import 'package:pos_app/floor_plan_table.dart';
import 'package:pos_app/floor_plan_table_provider.dart';

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
                  // Show an exit arrow if they are in Edit Mode
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

            // Dynamic content based on mode
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

  // THE NEW MENU (Orders and Settings)
  Widget _buildMainMenu(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ListTile(
          leading: const Icon(Icons.list, color: Colors.white),
          title:
              const Text("Show orders", style: TextStyle(color: Colors.white)),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Show Orders coming soon")));
          },
        ),
        const Divider(color: Colors.grey),
        ListTile(
          leading: const Icon(Icons.color_lens, color: Colors.white),
          title: const Text("Floor plan / table settings",
              style: TextStyle(color: Colors.white)),
          onTap: () {
            // Turn on edit mode!
            ref.read(floorPlanProvider.notifier).toggleEditMode(true);
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
        // Toggles
        SwitchListTile(
          title: const Text("Show grid", style: TextStyle(color: Colors.white)),
          value: fpState.showGrid,
          activeColor: Colors.greenAccent,
          onChanged: (val) =>
              ref.read(floorPlanProvider.notifier).toggleShowGrid(val),
        ),

        // Buttons
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF374151)),
              onPressed: () {
                // Add table logic
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
              onPressed: () {/* Add Floor Plan Logic */},
              child: const Text("Add new floor plan",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        )
      ],
    );
  }

  // --- UI FROM IMAGE 3 (TABLE EDITOR) ---
  Widget _buildTableEditor(BuildContext context, WidgetRef ref, int tableId) {
    // Note: To show real-time changes without rebuilding the whole drawer heavily,
    // we would pull the specific table from the tables list.
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF374151)),
          onPressed: () {
            ref.read(floorPlanTableProvider.notifier).deleteTable(tableId);
          },
          child: const Text("Remove selected table",
              style: TextStyle(color: Colors.redAccent)),
        ),
        const SizedBox(height: 20),

        // Size Controls
        const Text("Height & Width", style: TextStyle(color: Colors.white)),
        // We will add the + / - steppers from your UI here later
        const Center(
          child: Text("Use drag edges on table to resize (Coming soon)",
              style: TextStyle(color: Colors.grey)),
        )
      ],
    );
  }
}
