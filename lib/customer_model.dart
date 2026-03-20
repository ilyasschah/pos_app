class Customer {
  final int id;
  final String name;
  final String? code;
  final String? email;
  final String? phoneNumber;

  Customer({
    required this.id,
    required this.name,
    this.code,
    this.email,
    this.phoneNumber,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      code: json['code'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }
}
