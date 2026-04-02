import 'package:flutter/material.dart';
import 'floor_plan_table.dart';

class FloorPlanTableProvider extends ChangeNotifier {
  List<FloorPlanTable> _tables = [];
  int? _selectedTableId;

  List<FloorPlanTable> get tables => _tables;
  int? get selectedTableId => _selectedTableId;

  FloorPlanTable? get selectedTable {
    if (_selectedTableId == null) return null;
    try {
      return _tables.firstWhere((t) => t.id == _selectedTableId);
    } catch (e) {
      return null;
    }
  }

  // We will call the API Service here later
  void setTables(List<FloorPlanTable> newTables) {
    _tables = newTables;
    // Clear selection if the active floor plan changes
    _selectedTableId = null;
    notifyListeners();
  }

  void selectTable(int? id) {
    _selectedTableId = id;
    notifyListeners();
  }

  void updateTableGeometryLocally(int id, double x, double y) {
    final index = _tables.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tables[index].positionX = x;
      _tables[index].positionY = y;
      notifyListeners();
    }
  }

  void updateTableSizeLocally(int id, double width, double height) {
    final index = _tables.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tables[index].width = width;
      _tables[index].height = height;
      notifyListeners();
    }
  }
}
