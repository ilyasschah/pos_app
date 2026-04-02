import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/floor_plan_provider.dart';
import 'package:pos_app/floor_plan_table_provider.dart';
import 'widgets/table_widget.dart';
import 'widgets/side_panel.dart';

class FloorPlanScreen extends ConsumerWidget {
  const FloorPlanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Listen to API Providers
    final plansAsync = ref.watch(allFloorPlansProvider);
    final tablesAsync = ref.watch(tablesByFloorPlanProvider);

    // 2. Listen to Local State
    final fpState = ref.watch(floorPlanProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50), // Main dark background
      endDrawer: const SidePanel(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937), // Darker App Bar
        title: plansAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => const Text("Error loading rooms"),
          data: (plans) {
            if (plans.isEmpty) return const Text("No Floor Plans");

            // Auto-select first tab if none selected
            if (fpState.activeFloorPlanId == null) {
              Future.microtask(() => ref
                  .read(floorPlanProvider.notifier)
                  .setActiveFloorPlan(plans.first.id));
            }

            // Draw the tabs!
            return SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  final isActive = fpState.activeFloorPlanId == plan.id;

                  return InkWell(
                    onTap: () => ref
                        .read(floorPlanProvider.notifier)
                        .setActiveFloorPlan(plan.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFD81B60)
                              : Colors.transparent, // Pink active tab
                          border: Border(
                              bottom: BorderSide(
                            color: const Color(0xFFD81B60),
                            width: isActive ? 0 : 2,
                          ))),
                      child: Center(
                        child: Text(plan.name,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          )
        ],
      ),

      // THE CANVAS
      body: GestureDetector(
        // Deselect table when tapping the empty floor
        onTap: () =>
            ref.read(floorPlanTableProvider.notifier).selectTable(null),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent, // Allows gestures on empty space
          child: tablesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Center(
                child: Text("Error loading tables",
                    style: TextStyle(color: Colors.white))),
            data: (tables) {
              return Stack(
                children: [
                  // TODO: Draw Grid CustomPaint here if fpState.showGrid is true

                  // Render all tables
                  ...tables.map((t) => TableWidget(table: t)).toList(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
