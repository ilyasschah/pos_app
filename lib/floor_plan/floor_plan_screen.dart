import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/floor_plan/floor_plan_provider.dart';
import 'package:pos_app/floor_plan/floor_plan_table_provider.dart';
import 'package:pos_app/auth/auth_provider.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/app_settings/app_settings_model.dart';
import 'package:pos_app/app_settings/app_settings_provider.dart';
import 'widgets/table_widget.dart';
import 'widgets/side_panel.dart';
import 'package:pos_app/stock/warehouse_provider.dart';
import 'package:pos_app/widgets/shared_drawer.dart';

class FloorPlanScreen extends ConsumerStatefulWidget {
  const FloorPlanScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FloorPlanScreen> createState() => _FloorPlanScreenState();
}

class _FloorPlanScreenState extends ConsumerState<FloorPlanScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // ✨ Task 3: Auto-refresh Polling (15s)
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _refreshData(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _refreshData({bool silent = false}) {
    ref.invalidate(allFloorPlansProvider);
    ref.invalidate(tablesByFloorPlanProvider);
    // Note: Riverpod automatically keeps the old data on the screen (isRefreshing)
    // until the new data arrives, naturally creating a "silent" refresh!
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(allFloorPlansProvider);
    final tablesAsync = ref.watch(tablesByFloorPlanProvider);
    final fpState = ref.watch(floorPlanProvider);

    final companyId = ref.watch(selectedCompanyProvider)?.id ?? 0;
    final userId = ref.watch(currentUserProvider)?.id ?? 0;
    final selectedWarehouse = ref.watch(selectedWarehouseProvider);
    final warehouseId = selectedWarehouse?.id ?? 1;
    final settings = ref.watch(appSettingsProvider);
    final industryMode = settings[SettingKeys.industryMode] ?? 'FB';
    final isService = industryMode == 'Service';

    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      drawer: const SharedDrawer(),
      endDrawer: SidePanel(isService: isService),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        title: plansAsync.when(
          loading: () => const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (err, stack) => Text(isService ? "Error loading resources" : "Error loading rooms"),
          data: (plans) {
            if (plans.isEmpty) return Text(isService ? "No Resources" : "No Floor Plans");
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
          // ✨ Task 2: Manual Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _refreshData(),
          ),
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
                            companyId: companyId,
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
