import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/stock/stock_model.dart';
import 'package:pos_app/stock/warehouse_provider.dart';

/// Returns a map of productId → stock quantity for the currently selected
/// warehouse. Falls back to an empty map on any error so callers never crash.
final stockQuantitiesProvider = FutureProvider<Map<int, double>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return {};

  final selectedWarehouse = ref.watch(selectedWarehouseProvider);

  try {
    final dio = createDio();
    final response = await dio.get(
      '/Stocks/GetAllStocks',
      queryParameters: {'companyId': company.id},
    );
    final stocks = (response.data as List)
        .map((j) => StockItem.fromJson(j))
        .toList();

    final Map<int, double> map = {};
    for (final stock in stocks) {
      if (selectedWarehouse == null || stock.warehouseId == selectedWarehouse.id) {
        map[stock.productId] = (map[stock.productId] ?? 0) + stock.quantity;
      }
    }
    return map;
  } catch (_) {
    return {};
  }
});
