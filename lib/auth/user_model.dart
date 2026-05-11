class User {
  final int id;
  final int companyId;
  final String? firstName;
  final String? lastName;
  final String? username;
  final int accessLevel;
  final bool isEnabled;
  final String? email;
  final bool hasPinForThisDevice;
  final String? hashedPin;

  User({
    required this.id,
    required this.companyId,
    this.firstName,
    this.lastName,
    this.username,
    required this.accessLevel,
    required this.isEnabled,
    this.email,
    this.hasPinForThisDevice = false,
    this.hashedPin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['Id'] ?? 0,
      companyId: json['companyId'] ?? json['CompanyId'] ?? 0,
      firstName: json['firstName'] ?? json['FirstName'],
      lastName: json['lastName'] ?? json['LastName'],
      username: json['username'] ?? json['Username'],
      accessLevel: json['accessLevel'] ?? json['AccessLevel'] ?? 0,
      isEnabled: json['isEnabled'] ?? json['IsEnabled'] ?? false,
      email: json['email'] ?? json['Email'],
      hasPinForThisDevice:
          json['hasPinForThisDevice'] ?? json['HasPinForThisDevice'] ?? false,
      hashedPin: json['hashedPin'] ?? json['HashedPin'],
    );
  }

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username ?? 'Unknown User';
  }
}
