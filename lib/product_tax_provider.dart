import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'product_tax_model.dart';

// Fetch taxes specifically linked to a single product
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
  } catch (e) {
    return [];
  }
});
