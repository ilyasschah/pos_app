class Company {
  final int id;
  final String name;
  final int? countryId;
  final String? countryName;
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
  final String? logo;

  Company({
    required this.id,
    required this.name,
    this.countryId,
    this.countryName,
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
    this.logo,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      countryId: json['countryId'],
      countryName: json['countryName'],
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
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'countryId': countryId,
        'countryName': countryName,
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
        'logo': logo,
      };

  Company copyWith({
    String? logo,
    String? countryName,
  }) => Company(
        id: id,
        name: name,
        countryId: countryId,
        countryName: countryName ?? this.countryName,
        address: address,
        postalCode: postalCode,
        city: city,
        taxNumber: taxNumber,
        email: email,
        phoneNumber: phoneNumber,
        bankAccountNumber: bankAccountNumber,
        bankDetails: bankDetails,
        streetName: streetName,
        additionalStreetName: additionalStreetName,
        buildingNumber: buildingNumber,
        plotIdentification: plotIdentification,
        citySubdivisionName: citySubdivisionName,
        countrySubentity: countrySubentity,
        logo: logo ?? this.logo,
      );
}
