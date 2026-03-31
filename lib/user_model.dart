class User {
  final int id;
  final int companyId;
  final String? firstName;
  final String? lastName;
  final String? username;
  final int accessLevel;
  final bool isEnabled;
  final String? email;

  User({
    required this.id,
    required this.companyId,
    this.firstName,
    this.lastName,
    this.username,
    required this.accessLevel,
    required this.isEnabled,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      companyId: json['companyId'] ?? 0,
      firstName: json['firstName'],
      lastName: json['lastName'],
      username: json['username'],
      accessLevel: json['accessLevel'] ?? 0,
      isEnabled: json['isEnabled'] ?? false,
      email: json['email'],
    );
  }

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username ?? 'Unknown User';
  }
}
