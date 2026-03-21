import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'warehouse_model.dart';
import 'api_client.dart';
import 'company_provider.dart';

// --- PROVIDER ---
final allWarehousesProvider =
    FutureProvider.autoDispose<List<Warehouse>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];
  final dio = createDio();
  final response = await dio.get(
    'https://localhost:7002/api/Warehouses/GetAll',
    queryParameters: {'companyId': company.id},
  );
  return (response.data as List).map((j) => Warehouse.fromJson(j)).toList();
});
