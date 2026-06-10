import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/stock/stock_model.dart';
import 'package:pos_app/stock/warehouse_provider.dart';

/// Returns productId → { warehouseId → quantity } for every warehouse in the
/// company. Used both for the per-warehouse out-of-stock guard and to suggest
/// fallback warehouses where a product is still available. Falls back to an
/// empty map on any error so callers never crash.
final stockByWarehouseProvider =
    FutureProvider<Map<int, Map<int, double>>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return {};

  try {
    final dio = createDio();
    final response = await dio.get(
      '/Stocks/GetAllStocks',
      queryParameters: {'companyId': company.id},
    );
    final stocks = (response.data as List)
        .map((j) => StockItem.fromJson(j))
        .toList();

    final Map<int, Map<int, double>> map = {};
    for (final stock in stocks) {
      final byWh = map.putIfAbsent(stock.productId, () => {});
      byWh[stock.warehouseId] = (byWh[stock.warehouseId] ?? 0) + stock.quantity;
    }
    return map;
  } catch (_) {
    return {};
  }
});

/// Returns a map of productId → stock quantity for the currently selected
/// warehouse. Derived from [stockByWarehouseProvider] so both share one fetch.
final stockQuantitiesProvider = FutureProvider<Map<int, double>>((ref) async {
  final byWarehouse = await ref.watch(stockByWarehouseProvider.future);
  final selectedWarehouse = ref.watch(selectedWarehouseProvider);

  final Map<int, double> map = {};
  byWarehouse.forEach((productId, byWh) {
    byWh.forEach((warehouseId, quantity) {
      if (selectedWarehouse == null || warehouseId == selectedWarehouse.id) {
        map[productId] = (map[productId] ?? 0) + quantity;
      }
    });
  });
  return map;
});
