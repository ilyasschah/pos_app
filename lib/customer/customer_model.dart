class Customer {
  final int id;
  final String name;
  final String? code;
  final String? taxNumber;
  final String? address;
  final String? postalCode;
  final String? city;
  final int? countryId;
  final String? email;
  final String? phoneNumber;
  final bool isEnabled;
  final bool isCustomer;
  final bool isSupplier;
  final int? dueDatePeriod;
  final String? streetName;
  final String? additionalStreetName;
  final String? buildingNumber;
  final String? plotIdentification;
  final String? citySubdivisionName;
  final bool isTaxExempt;

  Customer({
    required this.id,
    required this.name,
    this.code,
    this.taxNumber,
    this.address,
    this.postalCode,
    this.city,
    this.countryId,
    this.email,
    this.phoneNumber,
    this.isEnabled = true,
    this.isCustomer = true,
    this.isSupplier = false,
    this.dueDatePeriod,
    this.streetName,
    this.additionalStreetName,
    this.buildingNumber,
    this.plotIdentification,
    this.citySubdivisionName,
    this.isTaxExempt = false,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      code: json['code'],
      taxNumber: json['taxNumber'],
      address: json['address'],
      postalCode: json['postalCode'],
      city: json['city'],
      countryId: json['countryId'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      isEnabled: json['isEnabled'] ?? true,
      isCustomer: json['isCustomer'] ?? true,
      isSupplier: json['isSupplier'] ?? false,
      dueDatePeriod: json['dueDatePeriod'],
      streetName: json['streetName'],
      additionalStreetName: json['additionalStreetName'],
      buildingNumber: json['buildingNumber'],
      plotIdentification: json['plotIdentification'],
      citySubdivisionName: json['citySubdivisionName'],
      isTaxExempt: json['isTaxExempt'] ?? false,
    );
  }
}