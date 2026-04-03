import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'warehouse_model.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'utils/api_error_parser.dart';

final allWarehousesProvider =
    FutureProvider.autoDispose<List<Warehouse>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];

  try {
    final dio = createDio();
    final response = await dio.get(
      '/Warehouses/GetAll',
      queryParameters: {'companyId': company.id},
    );
    return (response.data as List).map((j) => Warehouse.fromJson(j)).toList();
  } on DioException catch (e, st) {
    rethrowApiError(e, st);
    return [];
  }
});
