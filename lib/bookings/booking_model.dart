class Booking {
  final int id;
  final int? customerId;
  final int? userId;
  final String reservationName;
  final int? floorPlanTableId;
  final int? documentId;
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
    this.floorPlanTableId,
    this.documentId,
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
      floorPlanTableId: json['floorPlanTableId'],
      documentId: json['documentId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      guestCount: json['guestCount'] ?? 1,
      status: json['status'] ?? 0,
      note: json['note'],
    );
  }
}
