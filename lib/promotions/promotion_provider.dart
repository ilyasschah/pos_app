import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/api/promotion_models.dart';
import 'package:pos_app/company/company_provider.dart';

final allPromotionsProvider = FutureProvider<List<PromotionDto>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];
  final api = ApiClient();
  try {
    return await api.getAllPromotions(company.id);
  } catch (e, stackTrace) {
    print("Error fetching all promotions: $e\n$stackTrace");
    return [];
  }
});

final activePromotionsProvider = Provider<List<PromotionDto>>((ref) {
  final asyncPromotions = ref.watch(allPromotionsProvider);
  final promotions = asyncPromotions.value ?? [];

  final now = DateTime.now();
  final currentWeekday = now.weekday;
  final dayBitmask = 1 << (currentWeekday - 1);
  final currentTimeString =
      "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
  final activePromotions = promotions.where((p) {
    if (!p.isEnabled) return false;

    if (p.startDate != null) {
      final localStart = p.startDate!.toLocal();
      final start = DateTime(localStart.year, localStart.month, localStart.day);
      if (now.isBefore(start)) return false;
    }
    if (p.endDate != null) {
      final localEnd = p.endDate!.toLocal();
      final end = DateTime(
        localEnd.year,
        localEnd.month,
        localEnd.day,
        23,
        59,
        59,
      );
      if (now.isAfter(end)) return false;
    }

    if (p.startTime != null && p.startTime!.isNotEmpty) {
      final safeStart = p.startTime!.length == 5
          ? "${p.startTime}:00"
          : p.startTime!;
      if (currentTimeString.compareTo(safeStart) < 0) return false;
    }
    if (p.endTime != null && p.endTime!.isNotEmpty) {
      final safeEnd = p.endTime!.length == 5 ? "${p.endTime}:00" : p.endTime!;
      if (currentTimeString.compareTo(safeEnd) > 0) return false;
    }
    if (p.daysOfWeek > 0 && (p.daysOfWeek & dayBitmask) == 0) {
      return false;
    }
    return true;
  }).toList();

  print(
    "Total Active Promotions evaluated by frontend: ${activePromotions.length}",
  );
  return activePromotions;
});

int getActivePromotionCountForProduct(WidgetRef ref, int productId) {
  final activePromotions = ref.watch(activePromotionsProvider);
  int count = 0;
  for (var promo in activePromotions) {
    if (promo.items.any((item) => item.productId == productId)) {
      count++;
    }
  }
  return count;
}
