import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'product_comment_model.dart';

final productCommentsProvider = FutureProvider.autoDispose
    .family<List<ProductComment>, int>((ref, productId) async {
  final companyId = ref.watch(selectedCompanyProvider)?.id;
  if (companyId == null) return [];

  try {
    final dio = createDio();
    final res = await dio.get(
      '/ProductComments/GetByProductId',
      queryParameters: {'productId': productId, 'companyId': companyId},
    );
    return (res.data as List).map((x) => ProductComment.fromJson(x)).toList();
  } catch (e) {
    return [];
  }
});
