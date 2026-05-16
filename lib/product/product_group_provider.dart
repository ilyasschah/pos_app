import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/product/product_group_model.dart';
import 'package:pos_app/product/product_group_service.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/utils/api_error_parser.dart';

final allProductGroupsProvider =
    FutureProvider.autoDispose<List<ProductGroup>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];

  try {
    final service = ref.watch(productGroupServiceProvider);
    return await service.getAll(company.id);
  } catch (e, st) {
    rethrowApiError(e, st);
    return [];
  }
});
