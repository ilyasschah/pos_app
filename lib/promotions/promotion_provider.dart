import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/api/promotion_models.dart';
import 'package:pos_app/company/company_provider.dart';

final allPromotionsProvider = FutureProvider<List<PromotionDto>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];
  final api = ApiClient();
  return await api.getAllPromotions(company.id);
});
