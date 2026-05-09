import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_model.dart';
import 'package:pos_app/currency/country_model.dart';

// The currently selected company
class SelectedCompanyNotifier extends Notifier<Company?> {
  @override
  Company? build() => null;

  void update(Company company) {
    state = company;
  }

  void updateLogo(String base64Logo) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(logo: base64Logo);
  }
}

final selectedCompanyProvider =
    NotifierProvider<SelectedCompanyNotifier, Company?>(
        () => SelectedCompanyNotifier());

// Fetches full company detail from GetById — always authoritative.
final companyDetailProvider = FutureProvider.autoDispose<Company>((ref) async {
  final selected = ref.watch(selectedCompanyProvider);
  if (selected == null) throw Exception('No company selected');

  final dio = createDio();
  final response = await dio.get(
    '/Company/GetById',
    queryParameters: {'id': selected.id},
  );
  final company = Company.fromJson(response.data as Map<String, dynamic>);

  // Keep selectedCompanyProvider in sync with fresh detail data.
  ref.read(selectedCompanyProvider.notifier).update(company);
  return company;
});

// Fetch all companies for the selection screen
final allCompaniesProvider = FutureProvider<List<Company>>((ref) async {
  final dio = createDio();
  final response = await dio.get('/Company/GetAll');
  return (response.data as List).map((j) => Company.fromJson(j)).toList();
});

// Fetch countries based on selected company
final countriesProvider = FutureProvider<List<Country>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];

  final dio = createDio();
  final response = await dio.get(
    '/Country/GetAllCountries',
    queryParameters: {'companyId': company.id},
  );
  return (response.data as List).map((j) => Country.fromJson(j)).toList();
});
