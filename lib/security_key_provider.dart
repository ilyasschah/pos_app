import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'security_key_model.dart';
import 'utils/api_error_parser.dart';

final allSecurityKeysProvider =
    FutureProvider<List<SecurityKeyModel>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];

  try {
    final dio = createDio();
    final response = await dio.get(
      '/SecurityKeys/GetAll',
      queryParameters: {'companyId': company.id},
    );
    return (response.data as List)
        .map((json) => SecurityKeyModel.fromJson(json))
        .toList();
  } on DioException catch (e, st) {
    rethrowApiError(e, st);
    return [];
  }
});
