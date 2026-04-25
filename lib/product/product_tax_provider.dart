import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/product/product_tax_model.dart';
import 'package:pos_app/utils/api_error_parser.dart';

final productTaxesByProductIdProvider = FutureProvider.autoDispose
    .family<List<ProductTax>, int>((ref, productId) async {
  final companyId = ref.watch(selectedCompanyProvider)?.id;
  if (companyId == null) return [];

  try {
    final dio = createDio();
    final res = await dio.get(
      '/ProductTaxes/GetByProductId',
      queryParameters: {'productId': productId, 'companyId': companyId},
    );
    return (res.data as List).map((x) => ProductTax.fromJson(x)).toList();
  } on DioException catch (e, st) {
    // 404 = no taxes linked yet, not an error worth surfacing
    if (e.response?.statusCode == 404) return [];
    rethrowApiError(e, st);
    return [];
  }
});
