import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'payment_model.dart';

final paymentsByDocumentIdProvider = FutureProvider.autoDispose
    .family<List<PaymentModel>, int>((ref, documentId) async {
  final companyId = ref.watch(selectedCompanyProvider)?.id;
  if (companyId == null) return [];

  try {
    final dio = createDio();
    final response = await dio.get(
      '/Payments/GetByDocumentId',
      queryParameters: {'documentId': documentId, 'companyId': companyId},
    );
    return (response.data as List)
        .map((j) => PaymentModel.fromJson(j))
        .toList();
  } catch (e) {
    return [];
  }
});
