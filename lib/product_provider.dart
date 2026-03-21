import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'product_model.dart';

// Fetch ALL products for the selected company
final allProductsListProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];
  final dio = createDio();
  final response = await dio.get(
    '/Products/GetAll',
    queryParameters: {'companyId': company.id},
  );
  return (response.data as List).map((j) => Product.fromJson(j)).toList();
});

// Fetch a single product by ID — keyed by productId
final productByIdProvider =
    FutureProvider.autoDispose.family<Product?, int>((ref, productId) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return null;
  final dio = createDio();
  final response = await dio.get(
    '/Products/GetById',
    queryParameters: {'id': productId, 'companyId': company.id},
  );
  return Product.fromJson(response.data as Map<String, dynamic>);
});

// Cache of all products as a map: productId -> Product
// Used by stock screen to enrich stock items without N+1 individual watchers
final productMapProvider =
    FutureProvider.autoDispose<Map<int, Product>>((ref) async {
  final products = await ref.watch(allProductsListProvider.future);
  return {for (final p in products) p.id: p};
});
