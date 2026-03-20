import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'customer_model.dart';
import 'api_client.dart';
import 'company_provider.dart';

// 1. FETCH: Get All Customers — filtered by selected company
final allCustomersProvider = FutureProvider<List<Customer>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];

  final dio = createDio();
  final response = await dio.get(
    'https://localhost:7002/api/Customer/GetAllCustomers',
    queryParameters: {'companyId': company.id},
  );
  final data = response.data as List;
  return data.map((json) => Customer.fromJson(json)).toList();
});

// 2. STATE: The Currently Selected Customer
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
