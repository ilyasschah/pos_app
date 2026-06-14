import 'dart:convert';

import 'package:pos_app/database/app_database.dart';

class Booking {
  final int id;
  final int? customerId;
  final int? userId;
  final String reservationName;
  final List<int> tableIds;
  final int? documentId;
  final int? posOrderId;
  final DateTime startTime;
  final DateTime endTime;
  final int guestCount;
  final int status;
  final String? note;

  const Booking({
    required this.id,
    this.customerId,
    this.userId,
    required this.reservationName,
    this.tableIds = const [],
    this.documentId,
    this.posOrderId,
    required this.startTime,
    required this.endTime,
    this.guestCount = 1,
    this.status = 0,
    this.note,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      customerId: json['customerId'],
      userId: json['userId'],
      reservationName: json['reservationName'] ?? '',
      tableIds: (json['tableIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      documentId: json['documentId'],
      posOrderId: json['posOrderId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      guestCount: json['guestCount'] ?? 1,
      status: json['status'] ?? 0,
      note: json['note'],
    );
  }

  factory Booking.fromDrift(BookingsTableData row) {
    final ids = (jsonDecode(row.tableIdsJson) as List<dynamic>)
        .map((e) => (e as num).toInt())
        .toList();
    return Booking(
      id: row.id,
      customerId: row.customerId,
      userId: row.userId,
      reservationName: row.reservationName,
      tableIds: ids,
      documentId: row.documentId,
      posOrderId: row.posOrderId,
      startTime: row.startTime,
      endTime: row.endTime,
      guestCount: row.guestCount,
      status: row.status,
      note: row.note,
    );
  }
}
