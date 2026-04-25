import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/product/product_model.dart';
import 'package:pos_app/utils/api_error_parser.dart';

final selectedProductGroupIdProvider = StateProvider<int?>((ref) => null);

final allProductsListProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];

  try {
    final dio = createDio();
    final response = await dio.get(
      '/Products/GetAll',
      queryParameters: {'companyId': company.id},
    );
    return (response.data as List).map((j) => Product.fromJson(j)).toList();
  } on DioException catch (e, st) {
    rethrowApiError(e, st);
    return [];
  }
});

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

final productMapProvider =
    FutureProvider.autoDispose<Map<int, Product>>((ref) async {
  final products = await ref.watch(allProductsListProvider.future);
  return {for (final p in products) p.id: p};
});
