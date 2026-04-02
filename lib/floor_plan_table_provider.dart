import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api_client.dart';
import '../company_provider.dart';
import 'floor_plan_provider.dart';
import 'floor_plan_table.dart';

// --- 1. API FETCH PROVIDER ---
// Automatically fetches tables whenever the active Floor Plan (Tab) changes
final tablesByFloorPlanProvider =
    FutureProvider.autoDispose<List<FloorPlanTable>>((ref) async {
  final companyId = ref.watch(selectedCompanyProvider)?.id;
  final activeFloorPlanId = ref.watch(floorPlanProvider).activeFloorPlanId;

  if (companyId == null || activeFloorPlanId == null) return [];

  try {
    final dio = createDio();
    final response = await dio.get(
      '/FloorPlanTables/GetByFloorPlanId',
      queryParameters: {
        'floorPlanId': activeFloorPlanId,
        'companyId': companyId
      },
    );
    return (response.data as List)
        .map((j) => FloorPlanTable.fromJson(j))
        .toList();
  } catch (e) {
    return [];
  }
});

// --- 2. STATE MANAGEMENT (Selection & Math) ---
class FloorPlanTableNotifier extends Notifier<int?> {
  @override
  int? build() {
    return null;
  }

  void selectTable(int? id) {
    state = id;
  }

  // --- API MUTATION METHODS ---
  Future<void> addTable(FloorPlanTable table) async {
    final companyId = ref.read(selectedCompanyProvider)?.id;
    if (companyId == null) return;

    final dio = createDio();
    await dio.post('/FloorPlanTables/Add',
        queryParameters: {'companyId': companyId}, data: table.toJson());

    ref.invalidate(tablesByFloorPlanProvider);
  }

  Future<void> deleteTable(int id) async {
    final companyId = ref.read(selectedCompanyProvider)?.id;
    if (companyId == null) return;

    final dio = createDio();
    await dio.delete('/FloorPlanTables/Delete',
        queryParameters: {'id': id, 'companyId': companyId});

    if (state == id) state = null; // Deselect if deleted
    ref.invalidate(tablesByFloorPlanProvider);
  }

  // Called when a user stops dragging a table in the UI
  Future<void> updateTableGeometry(
      int id, double x, double y, double width, double height) async {
    final companyId = ref.read(selectedCompanyProvider)?.id;
    if (companyId == null) return;

    final dio = createDio();
    await dio.patch('/FloorPlanTables/UpdateGeometry', queryParameters: {
      'companyId': companyId
    }, data: {
      'id': id,
      'positionX': x,
      'positionY': y,
      'width': width,
      'height': height,
    });

    ref.invalidate(tablesByFloorPlanProvider);
  }
}

final floorPlanTableProvider = NotifierProvider<FloorPlanTableNotifier, int?>(
    () => FloorPlanTableNotifier());
