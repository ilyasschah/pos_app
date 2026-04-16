class FloorPlanTable {
  final int id;
  final int floorPlanId;
  final String name;
  final double positionX;
  final double positionY;
  final double width;
  final double height;
  final bool isRound;
  final int status;

  FloorPlanTable({
    required this.id,
    required this.floorPlanId,
    required this.name,
    required this.positionX,
    required this.positionY,
    required this.width,
    required this.height,
    required this.isRound,
    this.status = 0,
  });

  factory FloorPlanTable.fromJson(Map<String, dynamic> json) {
    return FloorPlanTable(
      id: json['id'],
      floorPlanId: json['floorPlanId'],
      name: json['name'] ?? '',
      positionX: (json['positionX'] ?? 0).toDouble(),
      positionY: (json['positionY'] ?? 0).toDouble(),
      width: (json['width'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      isRound: json['isRound'] ?? false,
      status: json['status'] ?? 0,
    );
  }
}
