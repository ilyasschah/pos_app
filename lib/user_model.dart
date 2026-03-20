class User {
  final int id;
  final String? firstName;
  final String? lastName;
  final String username;
  final int accessLevel;
  final bool isEnabled;
  final String? email;

  User({
    required this.id,
    this.firstName,
    this.lastName,
    required this.username,
    required this.accessLevel,
    required this.isEnabled,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      username: json['username'] ?? 'Unknown',
      accessLevel: json['accessLevel'] ?? 0,
      isEnabled: json['isEnabled'] ?? false,
      email: json['email'],
    );
  }

  // Helper to show a nice name in the UI
  String get displayName {
    if (firstName != null && lastName != null) {
      return "$firstName $lastName";
    }
    return username;
  }
}
