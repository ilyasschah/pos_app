import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/cart/payment_model.dart';
import 'package:pos_app/utils/api_error_parser.dart';

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
  } on DioException catch (e, st) {
    rethrowApiError(e, st);
    return [];
  }
});

final unreportedPaymentsProvider =
    FutureProvider.autoDispose<List<PaymentModel>>((ref) async {
  final companyId = ref.watch(selectedCompanyProvider)?.id;
  if (companyId == null) return [];

  try {
    final dio = createDio();
    final response = await dio.get(
      '/Payments/GetUnreported',
      queryParameters: {'companyId': companyId},
    );
    return (response.data as List)
        .map((j) => PaymentModel.fromJson(j))
        .toList();
  } on DioException catch (e, st) {
    rethrowApiError(e, st);
    return [];
  }
});
