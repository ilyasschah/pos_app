import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../api_client.dart';
import '../company_provider.dart';
import 'floor_plan_provider.dart';
import 'floor_plan_table.dart';
import '../utils/api_error_parser.dart';

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
        'companyId': companyId,
      },
    );
    return (response.data as List)
        .map((j) => FloorPlanTable.fromJson(j))
        .toList();
  } on DioException catch (e, st) {
    rethrowApiError(e, st);
    return [];
  }
});

class FloorPlanTableNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void selectTable(int? id) => state = id;

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
    if (state == id) state = null;
    ref.invalidate(tablesByFloorPlanProvider);
  }

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
