import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/floor_plan/floor_plan_provider.dart';
import 'package:pos_app/floor_plan/floor_plan_table_provider.dart';
import 'package:pos_app/auth/auth_provider.dart';
import 'package:pos_app/company/company_provider.dart';
import 'widgets/table_widget.dart';
import 'widgets/side_panel.dart';

class FloorPlanScreen extends ConsumerWidget {
  const FloorPlanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(allFloorPlansProvider);
    final tablesAsync = ref.watch(tablesByFloorPlanProvider);
    final fpState = ref.watch(floorPlanProvider);

    // ✨ Grab the required IDs from Riverpod
    final companyId = ref.watch(selectedCompanyProvider)?.id ?? 0;
    final userId = ref.watch(currentUserProvider)?.id ?? 0;
    final warehouseId = 5; // Assuming default warehouse 5

    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      endDrawer: const SidePanel(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        title: plansAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => const Text("Error loading rooms"),
          data: (plans) {
            if (plans.isEmpty) return const Text("No Floor Plans");
            if (fpState.activeFloorPlanId == null) {
              Future.microtask(() => ref
                  .read(floorPlanProvider.notifier)
                  .setActiveFloorPlan(plans.first.id));
            }
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
                              : Colors.transparent,
                          border: Border(
                              bottom: BorderSide(
                                  color: const Color(0xFFD81B60),
                                  width: isActive ? 0 : 2))),
                      child: Center(
                          child: Text(plan.name,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16))),
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
                  onPressed: () => Scaffold.of(context).openEndDrawer()))
        ],
      ),
      body: GestureDetector(
        onTap: () =>
            ref.read(floorPlanTableProvider.notifier).selectTable(null),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: tablesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Center(
                child: Text("Error loading tables",
                    style: TextStyle(color: Colors.white))),
            data: (tables) {
              return Stack(
                children: [
                  ...tables
                      .map((t) => TableWidget(
                            key: ValueKey(t.id),
                            table: t,
                            companyId: companyId, // ✨ Pass IDs to the widget
                            userId: userId,
                            warehouseId: warehouseId,
                          ))
                      .toList(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
