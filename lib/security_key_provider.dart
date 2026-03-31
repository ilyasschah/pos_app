import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'security_key_model.dart';

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

    final data = response.data as List;
    return data.map((json) => SecurityKeyModel.fromJson(json)).toList();
  } on DioException catch (e) {
    print("Failed to fetch security keys: ${e.message}");
    return [];
  } catch (e) {
    print("Unexpected error fetching security keys: $e");
    return [];
  }
});
