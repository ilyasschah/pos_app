import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'payment_type_model.dart';

final allPaymentTypesProvider = FutureProvider<List<PaymentType>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];
  final dio = createDio();
  final response = await dio.get(
    '/PaymentTypes/GetAll',
    queryParameters: {'companyId': company.id},
  );
  return (response.data as List).map((j) => PaymentType.fromJson(j)).toList();
});
