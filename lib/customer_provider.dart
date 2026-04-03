import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'customer_model.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'utils/api_error_parser.dart';

final allCustomersProvider = FutureProvider<List<Customer>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];

  try {
    final dio = createDio();
    final response = await dio.get(
      '/Customer/GetAllCustomers',
      queryParameters: {'companyId': company.id},
    );
    final data = response.data as List;
    return data.map((json) => Customer.fromJson(json)).toList();
  } on DioException catch (e, st) {
    rethrowApiError(e, st);
    return [];
  }
});

class CurrentCustomerNotifier extends Notifier<Customer?> {
  @override
  Customer? build() => null;

  void setCustomer(Customer c) => state = c;

  void setDefault(List<Customer> customers) {
    state = customers.firstWhere(
      (c) => c.id == 4,
      orElse: () => customers.first,
    );
  }
}

final currentCustomerProvider =
    NotifierProvider<CurrentCustomerNotifier, Customer?>(
        () => CurrentCustomerNotifier());
