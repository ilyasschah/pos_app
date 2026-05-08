import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/cart/payment_type_model.dart';
import 'package:pos_app/utils/api_error_parser.dart';

final allPaymentTypesProvider = FutureProvider<List<PaymentType>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];

  try {
    final dio = createDio();
    final response = await dio.get(
      '/PaymentTypes/GetAll',
      queryParameters: {'companyId': company.id},
    );
    return (response.data as List).map((j) => PaymentType.fromJson(j)).toList();
  } on DioException catch (e, st) {
    rethrowApiError(e, st);
    return [];
  }
});
final paymentTypeVisibleColumnsProvider = StateProvider<Map<String, bool>>((
  ref,
) {
  return {
    'Name': true,
    'Code': true,
    'Position': true,
    'Enabled': true,
    'Quick Pay': true,
    'Actions': true,
    'Customer Req.': false,
    'Change': false,
    'Mark Paid': false,
    'Cash Drawer': false,
    'Fiscal': false,
    'Slip': false,
    'Shortcut': false,
  };
});
