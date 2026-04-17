class FloorPlanTable {
  final int id;
  final int floorPlanId;
  String name;
  double positionX;
  double positionY;
  double width;
  double height;
  bool isRound;
  int status;

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
      name: json['name'],
      positionX: (json['positionX'] as num).toDouble(),
      positionY: (json['positionY'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      isRound: json['isRound'],
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'floorPlanId': floorPlanId,
      'name': name,
      'positionX': positionX,
      'positionY': positionY,
      'width': width,
      'height': height,
      'isRound': isRound,
      'status': status,
    };
  }
}
