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
import 'package:pos_app/navigation/main_layout.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(allFloorPlansProvider);
    final tablesAsync = ref.watch(tablesByFloorPlanProvider);
    final fpState = ref.watch(floorPlanProvider);

    final companyId = ref.watch(selectedCompanyProvider)?.id ?? 0;
    final userId = ref.watch(currentUserProvider)?.id ?? 0;
    final warehouseId = ref.watch(selectedWarehouseProvider)?.id ?? 1;
    final settings = ref.watch(appSettingsProvider);
    final isService = (settings[SettingKeys.industryMode] ?? 'FB') == 'Service';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.3,
      ),
      endDrawer: SidePanel(isService: isService),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
        title: plansAsync.when(
          loading: () => const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (err, stack) => Text(
            isService ? "Error loading resources" : "Error loading rooms",
          ),
          data: (plans) {
            if (plans.isEmpty)
              return Text(isService ? "No Resources" : "No Floor Plans");
            if (fpState.activeFloorPlanId == null) {
              Future.microtask(
                () => ref
                    .read(floorPlanProvider.notifier)
                    .setActiveFloorPlan(plans.first.id),
              );
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
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isActive
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          plan.name,
                          style: TextStyle(
                            color: isActive
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            fontSize: 15,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        actions: [
          if ((settings[SettingKeys.featureBookingEnabled] ?? 'true') == 'true')
            IconButton(
              icon: const Icon(Icons.calendar_month),
              color: theme.colorScheme.primary,
              tooltip: 'Bookings',
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const MainLayout(initialIndex: 2),
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () => _refreshData(),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.tune, color: theme.colorScheme.onSurfaceVariant),
              tooltip: "Floor Plan Settings",
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () =>
            ref.read(floorPlanTableProvider.notifier).selectTable(null),
        child: CustomPaint(
          painter: fpState.showGrid
              ? _GridPainter(theme.dividerColor.withValues(alpha: 0.5))
              : null,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: tablesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  const Center(child: Text("Error loading tables")),
              data: (tables) {
                return Stack(
                  children: [
                    ...tables
                        .map(
                          (t) => TableWidget(
                            key: ValueKey(t.id),
                            table: t,
                            companyId: companyId,
                            userId: userId,
                            warehouseId: warehouseId,
                          ),
                        )
                        .toList(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Draws a subtle grid background
class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const double step = 40;
    for (double i = 0; i < size.width; i += step)
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    for (double i = 0; i < size.height; i += step)
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
