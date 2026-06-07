import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pos_app/api/promotion_models.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/database/app_database.dart';
import 'package:pos_app/database/database_provider.dart';

/// Live list of promotions for the current company, streamed from Drift.
///
/// Each emission fetches the matching promotion_items rows so that
/// `activePromotionsProvider` can apply per-product discounts offline and
/// `getActivePromotionCountForProduct` returns accurate counts.
///
/// Items are re-fetched synchronously on every header-table change (asyncMap).
/// Standalone item mutations don't auto-trigger the stream; they always happen
/// together with a header write (save / pull) so this is acceptable.
final allPromotionsProvider =
    StreamProvider.autoDispose<List<PromotionDto>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final companyId = ref.watch(selectedCompanyProvider)?.id;
  if (companyId == null) return const Stream.empty();

  return (db.select(db.promotionsTable)
        ..where((t) => t.companyId.equals(companyId))
        ..where((t) => t.syncStatus.isNotIn(['pending_delete'])))
      .watch()
      .asyncMap((promos) async {
        if (promos.isEmpty) return <PromotionDto>[];
        final ids = promos.map((p) => p.id).toList();
        final items = await (db.select(db.promotionItemsTable)
              ..where((t) => t.promotionId.isIn(ids)))
            .get();
        final byId = <int, List<PromotionItemsTableData>>{};
        for (final item in items) {
          byId.putIfAbsent(item.promotionId, () => []).add(item);
        }
        return promos
            .map((p) => PromotionDto.fromDrift(p, byId[p.id] ?? []))
            .toList();
      });
});

final activePromotionsProvider =
    StreamProvider.autoDispose<List<PromotionDto>>((ref) {
  // Derive from the local stream — same filtering logic as before, just
  // sourced from Drift instead of an awaited Future.
  final promotionsAsync = ref.watch(allPromotionsProvider);
  final promotions = promotionsAsync.value ?? const [];

  final now = DateTime.now();
  final currentWeekday = now.weekday;
  final dayBitmask = 1 << (currentWeekday - 1);
  final currentTimeString =
      "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

  final active = promotions.where((p) {
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
      final safeStart =
          p.startTime!.length == 5 ? "${p.startTime}:00" : p.startTime!;
      if (currentTimeString.compareTo(safeStart) < 0) return false;
    }
    if (p.endTime != null && p.endTime!.isNotEmpty) {
      final safeEnd =
          p.endTime!.length == 5 ? "${p.endTime}:00" : p.endTime!;
      if (currentTimeString.compareTo(safeEnd) > 0) return false;
    }
    if (p.daysOfWeek > 0 && (p.daysOfWeek & dayBitmask) == 0) {
      return false;
    }
    return true;
  }).toList();

  return Stream.value(active);
});

int getActivePromotionCountForProduct(
    List<PromotionDto> activePromotions, int productId) {
  int count = 0;
  for (var promo in activePromotions) {
    if (promo.items.any((item) => item.productId == productId)) {
      count++;
    }
  }
  return count;
}
