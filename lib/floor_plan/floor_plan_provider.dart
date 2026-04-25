import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/floor_plan/floor_plan.dart';
import '../utils/api_error_parser.dart';

final allFloorPlansProvider =
    FutureProvider.autoDispose<List<FloorPlan>>((ref) async {
  final companyId = ref.watch(selectedCompanyProvider)?.id;
  if (companyId == null) return [];

  try {
    final dio = createDio();
    final response = await dio.get(
      '/FloorPlans/GetAll',
      queryParameters: {'companyId': companyId},
    );
    return (response.data as List).map((j) => FloorPlan.fromJson(j)).toList();
  } on DioException catch (e, st) {
    rethrowApiError(e, st);
    return [];
  }
});

class FloorPlanState {
  final int? activeFloorPlanId;
  final bool showGrid;
  final bool snapToGrid;
  final double gridSize;
  final bool isEditMode;

  FloorPlanState({
    this.activeFloorPlanId,
    this.showGrid = true,
    this.snapToGrid = false,
    this.gridSize = 20.0,
    this.isEditMode = false,
  });

  FloorPlanState copyWith({
    int? activeFloorPlanId,
    bool? showGrid,
    bool? snapToGrid,
    double? gridSize,
    bool? isEditMode,
  }) {
    return FloorPlanState(
      activeFloorPlanId: activeFloorPlanId ?? this.activeFloorPlanId,
      showGrid: showGrid ?? this.showGrid,
      snapToGrid: snapToGrid ?? this.snapToGrid,
      gridSize: gridSize ?? this.gridSize,
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }
}

class FloorPlanNotifier extends Notifier<FloorPlanState> {
  @override
  FloorPlanState build() => FloorPlanState();

  void setActiveFloorPlan(int id) =>
      state = state.copyWith(activeFloorPlanId: id);

  void toggleShowGrid(bool value) => state = state.copyWith(showGrid: value);
  void toggleSnapToGrid(bool value) =>
      state = state.copyWith(snapToGrid: value);
  void setGridSize(double size) => state = state.copyWith(gridSize: size);
  void toggleEditMode(bool value) => state = state.copyWith(isEditMode: value);

  Future<void> addFloorPlan(String name, String color) async {
    final companyId = ref.read(selectedCompanyProvider)?.id;
    if (companyId == null) return;
    final dio = createDio();
    await dio.post('/FloorPlans/Add',
        queryParameters: {'companyId': companyId},
        data: {'name': name, 'color': color});
    ref.invalidate(allFloorPlansProvider);
  }

  Future<void> updateFloorPlan(int id, String name, String color) async {
    final companyId = ref.read(selectedCompanyProvider)?.id;
    if (companyId == null) return;
    final dio = createDio();
    await dio.patch('/FloorPlans/Update',
        queryParameters: {'companyId': companyId},
        data: {'id': id, 'name': name, 'color': color});
    ref.invalidate(allFloorPlansProvider);
  }

  Future<void> deleteFloorPlan(int id) async {
    final companyId = ref.read(selectedCompanyProvider)?.id;
    if (companyId == null) return;
    final dio = createDio();
    await dio.delete('/FloorPlans/Delete',
        queryParameters: {'id': id, 'companyId': companyId});
    if (state.activeFloorPlanId == id) {
      state = FloorPlanState(activeFloorPlanId: null);
    }
    ref.invalidate(allFloorPlansProvider);
  }
}

final floorPlanProvider = NotifierProvider<FloorPlanNotifier, FloorPlanState>(
    () => FloorPlanNotifier());
