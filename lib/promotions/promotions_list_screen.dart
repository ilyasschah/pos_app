import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/promotions/promotion_provider.dart';
import 'package:pos_app/promotions/promotion_edit_screen.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';

class PromotionsListScreen extends ConsumerWidget {
  const PromotionsListScreen({super.key});

  String _formatDaysOfWeek(int bitmask) {
    if (bitmask == 0) return "None";
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    List<String> activeDays = [];
    for (int i = 0; i < 7; i++) {
      if ((bitmask & (1 << i)) != 0) {
        activeDays.add(days[i]);
      }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Promotions')),
      body: promotionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (promotions) {
          return Column(
            children: [
              // Toolbar
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).cardColor,
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add Promotion"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PromotionEditScreen(),
                          ),
                        ).then((_) => ref.refresh(allPromotionsProvider));
                      },
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text("Refresh"),
                      onPressed: () => ref.refresh(allPromotionsProvider),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        isDark ? Colors.grey[800] : Colors.grey[200],
                      ),
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Name',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Status',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Days of week',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Start Date',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Start Time',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'End Date',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'End Time',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Actions',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: promotions.map((promotion) {
                        return DataRow(
                          cells: [
                            DataCell(Text(promotion.name)),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: promotion.isEnabled
                                      ? Colors.green.withAlpha(50)
                                      : Colors.red.withAlpha(50),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  promotion.isEnabled ? "Active" : "Disabled",
                                  style: TextStyle(
                                    color: promotion.isEnabled
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(_formatDaysOfWeek(promotion.daysOfWeek)),
                            ),
                            DataCell(Text(_formatDate(promotion.startDate))),
                            DataCell(Text(promotion.startTime ?? "-")),
                            DataCell(Text(_formatDate(promotion.endDate))),
                            DataCell(Text(promotion.endTime ?? "-")),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PromotionEditScreen(
                                            promotion: promotion,
                                          ),
                                        ),
                                      ).then(
                                        (_) =>
                                            ref.refresh(allPromotionsProvider),
                                      );
                                    },
                                    tooltip: "Edit",
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Confirm Delete'),
                                          content: Text(
                                            'Delete ${promotion.name}?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        final companyId = ref
                                            .read(selectedCompanyProvider)
                                            ?.id;
                                        if (companyId != null &&
                                            context.mounted) {
                                          try {
                                            await ApiClient().deletePromotion(
                                              companyId,
                                              promotion.id,
                                            );
                                            ref.invalidate(
                                              allPromotionsProvider,
                                            );
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text('Error: $e'),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      }
                                    },
                                    tooltip: "Delete",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
