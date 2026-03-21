import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class Product {
  final int id;
  final String name;
  final String? code;
  final double price;
  final String? color;
  final int? productGroupId;
  final double? cost;
  final int? plu;
  final String? measurementUnit;
  final bool? isTaxInclusivePrice;
  final int? currencyId;
  final bool? isPriceChangeAllowed;
  final bool? isService;
  final bool? isUsingDefaultQuantity;
  final bool? isEnabled;
  final String? description;
  final String? dateCreated;
  final String? dateUpdated;
  final double? markup;
  final String? image;
  final int? ageRestriction;
  final double? lastPurchasePrice;
  final int? rank;

  Product({
    required this.id,
    required this.name,
    this.code,
    required this.price,
    this.color,
    this.productGroupId,
    this.cost,
    this.plu,
    this.measurementUnit,
    this.isTaxInclusivePrice,
    this.currencyId,
    this.isPriceChangeAllowed,
    this.isService,
    this.isUsingDefaultQuantity,
    this.isEnabled,
    this.description,
    this.dateCreated,
    this.dateUpdated,
    this.markup,
    this.image,
    this.ageRestriction,
    this.lastPurchasePrice,
    this.rank,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
