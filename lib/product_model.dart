// product_model.dart
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

  Product({
    required this.id,
    required this.name,
    this.code,
    required this.price,
    this.color,
    this.productGroupId,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
