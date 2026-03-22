import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'company_model.dart';
import 'country_model.dart';

// The currently selected company
class SelectedCompanyNotifier extends Notifier<Company?> {
  @override
  Company? build() => null;
}

final selectedCompanyProvider =
    NotifierProvider<SelectedCompanyNotifier, Company?>(
        () => SelectedCompanyNotifier());

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
