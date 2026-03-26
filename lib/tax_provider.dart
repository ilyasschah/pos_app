import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'tax_model.dart';

// Fetch ALL taxes for the selected company
final allTaxesProvider = FutureProvider.autoDispose<List<Tax>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];

  final dio = createDio();
  final response = await dio.get(
    '/Taxes/GetAllTaxes', // Exact endpoint from your Postman collection
    queryParameters: {'companyId': company.id},
  );

  return (response.data as List).map((j) => Tax.fromJson(j)).toList();
});
