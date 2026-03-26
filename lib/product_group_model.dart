import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ProductGroup {
  final int id;
  final int companyId;
  final String name;
  final int? parentGroupId;
  final String? parentGroupName;
  final String color;
  final String? image; // The raw base64 string from DB
  final int rank;

  ProductGroup({
    required this.id,
    required this.companyId,
    required this.name,
    this.parentGroupId,
    this.parentGroupName,
    required this.color,
    this.image,
    required this.rank,
  });

  factory ProductGroup.fromJson(Map<String, dynamic> json) {
    return ProductGroup(
      id: json['id'] ?? 0,
      companyId: json['companyId'] ?? 0,
      name: json['name'] ?? '',
      parentGroupId: json['parentGroupId'],
      parentGroupName: json['parentGroupName'],
      color: json['color'] ?? 'Transparent',
      image: json['image'], // Map the image from JSON
      rank: json['rank'] ?? 0,
    );
  }

  // Parses the hex string into a Flutter Color
  Color get flutterColor {
    if (color.startsWith('#') && color.length == 7) {
      try {
        return Color(int.parse(color.substring(1, 7), radix: 16) + 0xFF000000);
      } catch (_) {}
    }
    return Colors.blueGrey;
  }

  // Decodes the base64 string into readable Image Bytes
  Uint8List? get imageBytes {
    if (image == null || image!.isEmpty) return null;
    try {
      return base64Decode(image!);
    } catch (_) {
      return null;
    }
  }
}
