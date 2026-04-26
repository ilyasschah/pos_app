import 'package:flutter/material.dart';

class ServiceStatusHelper {
  static Color getColor(int status) {
    switch (status) {
      case 0:
        return Colors.green.withAlpha(50); // Free
      case 1:
        return Colors.blue; // Occupied
      case 2:
        return Colors.orange; // In Preparation
      case 3:
        return Colors.teal; // In Kitchen / Ready
      default:
        return Colors.grey;
    }
  }

  static IconData getIcon(int status) {
    switch (status) {
      case 0:
        return Icons.check_circle_outline;
      case 1:
        return Icons.people;
      case 2:
        return Icons.local_fire_department;
      case 3:
        return Icons.room_service;
      default:
        return Icons.help_outline;
    }
  }

  static String getLabel(int status) {
    switch (status) {
      case 0:
        return "Free";
      case 1:
        return "Occupied";
      case 2:
        return "In Preparation";
      case 3:
        return "In Kitchen";
      default:
        return "Unknown";
    }
  }
}
