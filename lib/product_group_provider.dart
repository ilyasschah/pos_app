import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_group_model.dart';
import 'api_client.dart';
import 'company_provider.dart';

final allProductGroupsProvider =
    FutureProvider.autoDispose<List<ProductGroup>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];

  final dio = createDio();
  final response = await dio
      .get('/ProductGroups/GetAll', queryParameters: {'companyId': company.id});

  return (response.data as List).map((j) => ProductGroup.fromJson(j)).toList();
});
