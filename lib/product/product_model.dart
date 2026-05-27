import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pos_app/database/app_database.dart';

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
  final String? image; // base64 (legacy / edit-flow source)
  final String? localImagePath; // absolute path on disk (Drift source)
  final String color;
  final int? ageRestriction;
  final double? lastPurchasePrice;
  final int? rank;
  final List<String> barcodes;

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
    this.localImagePath,
    required this.color,
    this.ageRestriction,
    this.lastPurchasePrice,
    this.rank,
    this.barcodes = const [],
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
      barcodes: (json['barcodes'] as List<dynamic>?)
              ?.map((b) => b.toString())
              .toList() ??
          const [],
    );
  }

  /// Reconstruct from a Drift row. The Drift schema stores a minimal subset
  /// (Phase 1 decision). Fields not on the table fall back to safe defaults:
  /// nulls for optionals, sensible booleans for required flags. Screens that
  /// need the full set (admin product editor) should keep using
  /// `productsByGroupProvider` / `productByIdProvider` which still fetch
  /// from the API.
  factory Product.fromDrift(ProductsTableData row) {
    return Product(
      id: row.id,
      companyId: row.companyId,
      productGroupId: row.productGroupId,
      name: row.name,
      price: row.price,
      isTaxInclusivePrice: true,
      isPriceChangeAllowed: false,
      isService: row.isService,
      isUsingDefaultQuantity: true,
      isEnabled: true,
      cost: row.cost,
      localImagePath: row.localImagePath,
      color: row.colorHex ?? 'Transparent',
      barcodes: row.barcode != null ? [row.barcode!] : const [],
    );
  }

  /// Returns image bytes for rendering with `Image.memory` /  `MemoryImage`.
  /// Source priority:
  ///   1. `image` (base64) — present on JSON-sourced Products (admin/edit flow)
  ///   2. `localImagePath` — present on Drift-sourced Products (menu, etc.)
  ///
  /// The file fallback uses sync I/O. For hot UI paths (long product grids),
  /// prefer the [imageFile] getter with `Image.file` — it streams from disk
  /// and lets Flutter's image cache hold a single decoded copy in memory.
  Uint8List? get imageBytes {
    if (image != null && image!.isNotEmpty) {
      try {
        return base64Decode(image!);
      } catch (_) {
        // fall through to file path
      }
    }
    if (localImagePath != null && localImagePath!.isNotEmpty) {
      try {
        final f = File(localImagePath!);
        if (f.existsSync()) return f.readAsBytesSync();
      } catch (_) {/* ignore */}
    }
    return null;
  }

  /// Returns a `File` handle when the image lives on disk (Drift-sourced
  /// products). Use with `Image.file(p.imageFile!)` for efficient rendering
  /// in lists — Flutter caches decoded `FileImage`s by path so the same
  /// product image only decodes once.
  File? get imageFile {
    if (localImagePath == null || localImagePath!.isEmpty) return null;
    final f = File(localImagePath!);
    return f.existsSync() ? f : null;
  }
}
