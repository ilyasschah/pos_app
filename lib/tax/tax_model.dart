class Tax {
  final int id;
  final String name;
  final double rate;
  final String? code;
  final bool isFixed;
  final bool isTaxOnTotal;
  final bool isEnabled;

  Tax({
    required this.id,
    required this.name,
    required this.rate,
    this.code,
    this.isFixed = false,
    this.isTaxOnTotal = true,
    this.isEnabled = true,
  });

  factory Tax.fromJson(Map<String, dynamic> json) {
    return Tax(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      code: json['code'],
      isFixed: json['isFixed'] ?? false,
      isTaxOnTotal: json['isTaxOnTotal'] ?? true,
      isEnabled: json['isEnabled'] ?? true,
    );
  }
}