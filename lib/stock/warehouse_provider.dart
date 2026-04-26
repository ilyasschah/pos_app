import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:dio/dio.dart';
import 'package:pos_app/stock/warehouse_model.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/utils/api_error_parser.dart';

final selectedWarehouseProvider = StateProvider<Warehouse?>((ref) => null);

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
    final list = (response.data as List).map((j) => Warehouse.fromJson(j)).toList();
    
    if (list.isNotEmpty && ref.read(selectedWarehouseProvider) == null) {
      ref.read(selectedWarehouseProvider.notifier).state = list.first;
    }
    
    return list;
  } on DioException catch (e, st) {
    rethrowApiError(e, st);
    return [];
  }
});
