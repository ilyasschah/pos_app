import 'package:flutter/material.dart';
import 'floor_plan.dart';

class FloorPlanProvider extends ChangeNotifier {
  List<FloorPlan> _floorPlans = [];
  int? _activeFloorPlanId;

  // Canvas Options
  bool _showGrid = true;
  bool _snapToGrid = false;
  double _gridSize = 20.0;

  List<FloorPlan> get floorPlans => _floorPlans;
  int? get activeFloorPlanId => _activeFloorPlanId;
  bool get showGrid => _showGrid;
  bool get snapToGrid => _snapToGrid;
  double get gridSize => _gridSize;

  // We will call the API Service here later to populate this
  void setFloorPlans(List<FloorPlan> plans) {
    _floorPlans = plans;
    if (_floorPlans.isNotEmpty && _activeFloorPlanId == null) {
      _activeFloorPlanId = _floorPlans.first.id;
    }
    notifyListeners();
  }

  void setActiveFloorPlan(int id) {
    _activeFloorPlanId = id;
    notifyListeners();
  }

  void toggleShowGrid(bool value) {
    _showGrid = value;
    notifyListeners();
  }

  void toggleSnapToGrid(bool value) {
    _snapToGrid = value;
    notifyListeners();
  }

  void setGridSize(double size) {
    _gridSize = size;
    notifyListeners();
  }
}
