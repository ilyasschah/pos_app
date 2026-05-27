import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/database/database_provider.dart';
import 'package:pos_app/product/product_model.dart';
import 'package:pos_app/utils/api_error_parser.dart';

final selectedProductGroupIdProvider = StateProvider<int?>((ref) => null);

/// Primary product list — sourced from the local Drift DB so the menu grid,
/// reports, promotions screen, and document editor all work offline.
///
/// IMPORTANT: Drift only stores the columns Phase 1 picked (id, name, price,
/// cost, barcode, productGroupId, isService, colorHex, localImagePath). Screens
/// that need fields like `code`, `description`, `markup`, etc. should keep
/// using [productsByGroupProvider] / [productByIdProvider] below — those still
/// hit the API. When the admin product editor is migrated, expand the Drift
/// ProductsTable schema first.
final allProductsListProvider =
    StreamProvider.autoDispose<List<Product>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final companyId = ref.watch(selectedCompanyProvider)?.id;
  if (companyId == null) return const Stream.empty();

  final query = db.select(db.productsTable)
    ..where((t) => t.companyId.equals(companyId));

  return query.watch().map((rows) => rows.map(Product.fromDrift).toList());
});

/// Admin product list — KEEPS hitting the API because the admin screen reads
/// fields not present in the Drift schema (code, description, markup, …).
/// Migrate to Drift once ProductsTable holds the full set.
final productsByGroupProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final companyId = ref.watch(selectedCompanyProvider)?.id;
  final groupId = ref.watch(selectedProductGroupIdProvider);

  if (companyId == null) return [];

  try {
    final dio = createDio();
    if (groupId == null) {
      final res = await dio.get(
        '/Products/GetAll',
        queryParameters: {'companyId': companyId},
      );
      return (res.data as List).map((x) => Product.fromJson(x)).toList();
    } else {
      final res = await dio.get(
        '/Products/GetByProductGroup',
        queryParameters: {
          'productGroupId': groupId,
          'companyId': companyId,
        },
      );
      return (res.data as List).map((x) => Product.fromJson(x)).toList();
    }
  } on DioException catch (e, st) {
    // 404 just means no products in this group — not a real error
    if (e.response?.statusCode == 404) return [];
    rethrowApiError(e, st);
    return [];
  }
});

/// Single product fetch — API-backed for the same field-coverage reason.
final productByIdProvider =
    FutureProvider.autoDispose.family<Product?, int>((ref, productId) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return null;

  try {
    final dio = createDio();
    final response = await dio.get(
      '/Products/GetById',
      queryParameters: {'id': productId, 'companyId': company.id},
    );
    return Product.fromJson(response.data as Map<String, dynamic>);
  } on DioException catch (e, st) {
    rethrowApiError(e, st);
    return null;
  }
});

/// Derived from the offline product list — provides O(1) lookup by id for
/// the menu / order screens. Updates automatically when Drift fires.
final productMapProvider = Provider.autoDispose<Map<int, Product>>((ref) {
  final products = ref.watch(allProductsListProvider).value ?? const [];
  return {for (final p in products) p.id: p};
});
