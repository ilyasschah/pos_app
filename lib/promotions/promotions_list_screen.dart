import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/promotions/promotion_provider.dart';
import 'package:pos_app/promotions/promotion_edit_screen.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';

class PromotionsListScreen extends ConsumerWidget {
  const PromotionsListScreen({super.key});

  String _formatDaysOfWeek(int bitmask) {
    if (bitmask == 0 || bitmask == 127) return "Every day";
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final activeDays = <String>[];
    for (int i = 0; i < 7; i++) {
      if ((bitmask & (1 << i)) != 0) activeDays.add(days[i]);
    }
    return activeDays.join(", ");
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promotionsAsync = ref.watch(allPromotionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Promotions')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: promotionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (promotions) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header bar
              Row(
                children: [
                  Text(
                    '${promotions.length} Promotion${promotions.length == 1 ? '' : 's'}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text("Refresh"),
                    onPressed: () => ref.refresh(allPromotionsProvider),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add Promotion"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PromotionEditScreen()),
                    ).then((_) => ref.refresh(allPromotionsProvider)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Table card
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: theme.cardColor,
                  clipBehavior: Clip.antiAlias,
                  child: promotions.isEmpty
                      ? Center(
                          child: Text(
                            'No promotions yet. Tap "Add Promotion" to create one.',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            // Header row
                            Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(flex: 3, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface))),
                                  Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface))),
                                  Expanded(flex: 2, child: Text('Days', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface))),
                                  Expanded(flex: 2, child: Text('Start Date', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface))),
                                  Expanded(flex: 2, child: Text('Start Time', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface))),
                                  Expanded(flex: 2, child: Text('End Date', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface))),
                                  Expanded(flex: 2, child: Text('End Time', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface))),
                                  Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)))),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            // Data rows
                            Expanded(
                              child: ListView.separated(
                                itemCount: promotions.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final promotion = promotions[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            promotion.name,
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                            decoration: ShapeDecoration(
                                              color: promotion.isEnabled
                                                  ? Colors.green.withValues(alpha: 0.15)
                                                  : Colors.red.withValues(alpha: 0.15),
                                              shape: const StadiumBorder(),
                                            ),
                                            child: Text(
                                              promotion.isEnabled ? "Active" : "Disabled",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: promotion.isEnabled ? Colors.green : Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(flex: 2, child: Text(_formatDaysOfWeek(promotion.daysOfWeek))),
                                        Expanded(flex: 2, child: Text(_formatDate(promotion.startDate))),
                                        Expanded(flex: 2, child: Text(promotion.startTime ?? "-")),
                                        Expanded(flex: 2, child: Text(_formatDate(promotion.endDate))),
                                        Expanded(flex: 2, child: Text(promotion.endTime ?? "-")),
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: Colors.blue),
                                                tooltip: "Edit",
                                                padding: const EdgeInsets.all(10),
                                                onPressed: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => PromotionEditScreen(promotion: promotion),
                                                  ),
                                                ).then((_) => ref.refresh(allPromotionsProvider)),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                                tooltip: "Delete",
                                                padding: const EdgeInsets.all(10),
                                                onPressed: () async {
                                                  final confirm = await showDialog<bool>(
                                                    context: context,
                                                    builder: (ctx) => AlertDialog(
                                                      title: const Text('Confirm Delete'),
                                                      content: Text('Delete "${promotion.name}"?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(ctx, false),
                                                          child: const Text('Cancel'),
                                                        ),
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.red,
                                                            foregroundColor: Colors.white,
                                                          ),
                                                          onPressed: () => Navigator.pop(ctx, true),
                                                          child: const Text('Delete'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                  if (confirm == true) {
                                                    final companyId = ref.read(selectedCompanyProvider)?.id;
                                                    if (companyId != null && context.mounted) {
                                                      try {
                                                        await ApiClient().deletePromotion(companyId, promotion.id);
                                                        ref.invalidate(allPromotionsProvider);
                                                      } catch (e) {
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text('Error: $e')),
                                                          );
                                                        }
                                                      }
                                                    }
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
