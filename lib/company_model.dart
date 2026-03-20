class Company {
  final int id;
  final String name;
  final int? countryId;
  final String? address;
  final String? postalCode;
  final String? city;
  final String? taxNumber;
  final String? email;
  final String? phoneNumber;
  final String? bankAccountNumber;
  final String? bankDetails;
  final String? streetName;
  final String? additionalStreetName;
  final String? buildingNumber;
  final String? plotIdentification;
  final String? citySubdivisionName;
  final String? countrySubentity;

  Company({
    required this.id,
    required this.name,
    this.countryId,
    this.address,
    this.postalCode,
    this.city,
    this.taxNumber,
    this.email,
    this.phoneNumber,
    this.bankAccountNumber,
    this.bankDetails,
    this.streetName,
    this.additionalStreetName,
    this.buildingNumber,
    this.plotIdentification,
    this.citySubdivisionName,
    this.countrySubentity,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      countryId: json['countryId'],
      address: json['address'],
      postalCode: json['postalCode'],
      city: json['city'],
      taxNumber: json['taxNumber'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      bankAccountNumber: json['bankAccountNumber'],
      bankDetails: json['bankDetails'],
      streetName: json['streetName'],
      additionalStreetName: json['additionalStreetName'],
      buildingNumber: json['buildingNumber'],
      plotIdentification: json['plotIdentification'],
      citySubdivisionName: json['citySubdivisionName'],
      countrySubentity: json['countrySubentity'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'countryId': countryId,
        'address': address,
        'postalCode': postalCode,
        'city': city,
        'taxNumber': taxNumber,
        'email': email,
        'phoneNumber': phoneNumber,
        'bankAccountNumber': bankAccountNumber,
        'bankDetails': bankDetails,
        'streetName': streetName,
        'additionalStreetName': additionalStreetName,
        'buildingNumber': buildingNumber,
        'plotIdentification': plotIdentification,
        'citySubdivisionName': citySubdivisionName,
        'countrySubentity': countrySubentity,
      };
}
