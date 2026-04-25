import 'dart:convert';
import 'dart:typed_data';

class Product {
  final int id;
  final int companyId;
  final int? productGroupId;
  final String name;
  final String? code;
  final int? plu;
  final String? measurementUnit;
  final double price;
  final bool isTaxInclusivePrice;
  final int? currencyId;
  final bool isPriceChangeAllowed;
  final bool isService;
  final bool isUsingDefaultQuantity;
  final bool isEnabled;
  final String? description;
  final String? dateCreated;
  final String? dateUpdated;
  final double cost;
  final double? markup;
  final String? image;
  final String color;
  final int? ageRestriction;
  final double? lastPurchasePrice;
  final int? rank;

  Product({
    required this.id,
    required this.companyId,
    this.productGroupId,
    required this.name,
    this.code,
    this.plu,
    this.measurementUnit,
    required this.price,
    required this.isTaxInclusivePrice,
    this.currencyId,
    required this.isPriceChangeAllowed,
    required this.isService,
    required this.isUsingDefaultQuantity,
    required this.isEnabled,
    this.description,
    this.dateCreated,
    this.dateUpdated,
    required this.cost,
    this.markup,
    this.image,
    required this.color,
    this.ageRestriction,
    this.lastPurchasePrice,
    this.rank,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      companyId: json['companyId'] ?? 0,
      productGroupId: json['productGroupId'],
      name: json['name'] ?? '',
      code: json['code'],
      plu: json['plu'],
      measurementUnit: json['measurementUnit'],
      price: (json['price'] ?? 0).toDouble(),
      isTaxInclusivePrice: json['isTaxInclusivePrice'] ?? true,
      currencyId: json['currencyId'],
      isPriceChangeAllowed: json['isPriceChangeAllowed'] ?? false,
      isService: json['isService'] ?? false,
      isUsingDefaultQuantity: json['isUsingDefaultQuantity'] ?? true,
      isEnabled: json['isEnabled'] ?? true,
      description: json['description'],
      dateCreated: json['dateCreated'],
      dateUpdated: json['dateUpdated'],
      cost: (json['cost'] ?? 0).toDouble(),
      markup: json['markup'] != null ? (json['markup']).toDouble() : null,
      image: json['image'],
      color: json['color'] ?? 'Transparent',
      ageRestriction: json['ageRestriction'],
      lastPurchasePrice: json['lastPurchasePrice'] != null
          ? (json['lastPurchasePrice']).toDouble()
          : null,
      rank: json['rank'] ?? 0,
    );
  }

  Uint8List? get imageBytes {
    if (image == null || image!.isEmpty) return null;
    try {
      return base64Decode(image!);
    } catch (_) {
      return null;
    }
  }
}
