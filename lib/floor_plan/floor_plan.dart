class FloorPlan {
  final int id;
  final String name;
  final String color;

  FloorPlan({
    required this.id,
    required this.name,
    this.color = "Transparent",
  });

  factory FloorPlan.fromJson(Map<String, dynamic> json) {
    return FloorPlan(
      id: json['id'],
      name: json['name'],
      color: json['color'] ?? "Transparent",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }
}
