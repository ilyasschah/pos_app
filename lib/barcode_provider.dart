import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'barcode_model.dart';

final barcodesByProductIdProvider = FutureProvider.autoDispose
    .family<List<BarcodeModel>, int>((ref, productId) async {
  final companyId = ref.watch(selectedCompanyProvider)?.id;
  if (companyId == null) return [];

  try {
    final dio = createDio();
    final res = await dio.get(
      '/Barcodes/GetByProductId',
      queryParameters: {'productId': productId, 'companyId': companyId},
    );
    return (res.data as List).map((x) => BarcodeModel.fromJson(x)).toList();
  } catch (e) {
    return [];
  }
});
