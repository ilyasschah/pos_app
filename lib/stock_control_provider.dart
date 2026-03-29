import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'stock_control_model.dart';

final stockControlByProductIdProvider = FutureProvider.autoDispose
    .family<StockControl?, int>((ref, productId) async {
  final companyId = ref.watch(selectedCompanyProvider)?.id;
  if (companyId == null) return null;

  try {
    final dio = createDio();
    final res = await dio.get(
      '/StockControls/GetByProductId',
      queryParameters: {'productId': productId, 'companyId': companyId},
    );
    if (res.data == null || res.data == '')
      return null; // In case the product doesn't have a rule yet
    return StockControl.fromJson(res.data);
  } catch (e) {
    return null;
  }
});
