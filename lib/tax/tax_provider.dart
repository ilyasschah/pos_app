import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/tax/tax_model.dart';
import 'package:pos_app/utils/api_error_parser.dart';

final allTaxesProvider = FutureProvider.autoDispose<List<Tax>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];

  try {
    final dio = createDio();
    final response = await dio.get(
      '/Taxes/GetAllTaxes',
      queryParameters: {'companyId': company.id},
    );
    return (response.data as List).map((j) => Tax.fromJson(j)).toList();
  } on DioException catch (e, st) {
    rethrowApiError(e, st);
    return [];
  }
});
