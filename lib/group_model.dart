class Group {
  final int id;
  final String name;
  final int? parentGroupId;
  final String? color;
  final int rank;

  Group({
    required this.id,
    required this.name,
    this.parentGroupId,
    this.color,
    required this.rank,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      parentGroupId: json['parentGroupId'],
      color: json['color'],
      rank: json['rank'] ?? 0,
    );
  }
}
