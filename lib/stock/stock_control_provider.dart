import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/stock/stock_control_model.dart';
import 'package:pos_app/utils/api_error_parser.dart';

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
    if (res.data == null || res.data == '') return null;
    return StockControl.fromJson(res.data);
  } on DioException catch (e, st) {
    // 404 = no stock control rule set yet for this product
    if (e.response?.statusCode == 404) return null;
    rethrowApiError(e, st);
    return null;
  }
});
