import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/auth/auth_provider.dart';
import 'package:pos_app/bookings/bookings_provider.dart';
import 'package:pos_app/navigation/main_layout.dart';
import 'package:pos_app/cart/cart_provider.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/currency/currencies_provider.dart';
import 'package:pos_app/stock/warehouse_provider.dart';

final openOrdersProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];
  return ApiClient().getAllActiveOrders(company.id);
});

class OpenOrdersScreen extends ConsumerWidget {
  const OpenOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(openOrdersProvider);
    final allUsers = ref.watch(allUsersProvider).value ?? [];
    final allRooms = ref.watch(allRoomsProvider).value ?? [];
    final sym = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Orders'),
        actions: [
          IconButton(
            icon: const PhosphorIcon(PhosphorIconsRegular.arrowClockwise),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(openOrdersProvider),
          ),
        ],
      ),
      body: ordersAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 6,
          separatorBuilder: (_, __) => const Gap(10),
          itemBuilder: (_, __) => const _SkeletonOrderCard(),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhosphorIcon(
                PhosphorIconsRegular.warning,
                size: 52,
                color: Theme.of(context).colorScheme.error,
              ),
              const Gap(12),
              Text('Failed to load orders',
                  style: Theme.of(context).textTheme.titleMedium),
              const Gap(4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  '$e',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ),
              const Gap(16),
              FilledButton.icon(
                onPressed: () => ref.invalidate(openOrdersProvider),
                icon: const PhosphorIcon(PhosphorIconsRegular.arrowClockwise,
                    size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PhosphorIcon(
                    PhosphorIconsRegular.receipt,
                    size: 64,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.25),
                  ),
                  const Gap(16),
                  Text(
                    'No open orders',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.45),
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const Gap(10),
            itemBuilder: (context, i) {
              final o = orders[i];
              final orderId = (o['id'] ?? o['Id']) as int;
              final orderNumber =
                  (o['number'] ?? o['Number'] ?? 'ORD-$orderId') as String;
              final total =
                  (o['total'] ?? o['Total'] ?? 0.0 as num).toDouble();
              final staffId = o['userId'] ?? o['UserId'];
              final tableId = o['floorPlanTableId'] ?? o['FloorPlanTableId'];
              final warehouseId =
                  ((o['warehouseId'] ?? o['WarehouseId']) as num?)?.toInt() ??
                      ref.read(selectedWarehouseProvider)?.id ??
                      0;

              final staffName = staffId != null
                  ? allUsers
                      .where((u) => u.id == staffId)
                      .map((u) => u.displayName)
                      .firstOrNull
                  : null;
              final tableName = tableId != null
                  ? allRooms
                      .where((t) => t.id == tableId)
                      .map((t) => t.name)
                      .firstOrNull
                  : null;

              return _OpenOrderCard(
                orderId: orderId,
                orderNumber: orderNumber,
                total: total,
                staffName: staffName,
                tableName: tableName,
                warehouseId: warehouseId,
                sym: sym,
              )
                  .animate()
                  .fadeIn(duration: 220.ms, delay: (i * 45).ms)
                  .slideY(begin: 0.08, end: 0, duration: 220.ms, delay: (i * 45).ms);
            },
          );
        },
      ),
    );
  }
}

class _SkeletonOrderCard extends StatelessWidget {
  const _SkeletonOrderCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final shimmer = cs.onSurface.withValues(alpha: 0.08);

    Widget block(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: shimmer,
            borderRadius: BorderRadius.circular(6),
          ),
        );

    return Card(
      elevation: 0,
      color: cs.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: shimmer,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  block(120, 15),
                  const Gap(8),
                  block(80, 12),
                ],
              ),
            ),
            const Gap(12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                block(64, 15),
                const Gap(8),
                block(36, 11),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 1000.ms, color: cs.onSurface.withValues(alpha: 0.05));
  }
}

class _OpenOrderCard extends ConsumerStatefulWidget {
  final int orderId;
  final String orderNumber;
  final double total;
  final String? staffName;
  final String? tableName;
  final int warehouseId;
  final String sym;

  const _OpenOrderCard({
    required this.orderId,
    required this.orderNumber,
    required this.total,
    required this.staffName,
    required this.tableName,
    required this.warehouseId,
    required this.sym,
  });

  @override
  ConsumerState<_OpenOrderCard> createState() => _OpenOrderCardState();
}

class _OpenOrderCardState extends ConsumerState<_OpenOrderCard> {
  bool _loading = false;

  Future<void> _reopen() async {
    final company = ref.read(selectedCompanyProvider);
    if (company == null) return;
    setState(() => _loading = true);
    try {
      final ok = await ref.read(cartProvider.notifier).loadOrderById(
            ApiClient(),
            company.id,
            widget.orderId,
            widget.warehouseId,
          );
      if (!mounted) return;
      if (ok) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainLayout(initialIndex: 0)),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load order.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _loading ? null : _reopen,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Leading icon badge
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _loading
                    ? Padding(
                        padding: const EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: cs.onPrimaryContainer,
                        ),
                      )
                    : Center(
                        child: PhosphorIcon(
                          PhosphorIconsRegular.receipt,
                          color: cs.onPrimaryContainer,
                          size: 24,
                        ),
                      ),
              ),
              const Gap(16),
              // Order info — Expanded prevents right-side overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.orderNumber,
                      style: tt.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.tableName != null ||
                        widget.staffName != null) ...[
                      const Gap(6),
                      // Inner Row also guarded with Flexible on text nodes
                      Row(
                        children: [
                          if (widget.tableName != null) ...[
                            PhosphorIcon(
                              PhosphorIconsRegular.armchair,
                              size: 13,
                              color: cs.onSurface.withValues(alpha: 0.55),
                            ),
                            const Gap(4),
                            Flexible(
                              child: Text(
                                widget.tableName!,
                                style: tt.bodySmall?.copyWith(
                                  color:
                                      cs.onSurface.withValues(alpha: 0.55),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Gap(12),
                          ],
                          if (widget.staffName != null) ...[
                            PhosphorIcon(
                              PhosphorIconsRegular.userCircle,
                              size: 13,
                              color: cs.onSurface.withValues(alpha: 0.55),
                            ),
                            const Gap(4),
                            Flexible(
                              child: Text(
                                widget.staffName!,
                                style: tt.bodySmall?.copyWith(
                                  color:
                                      cs.onSurface.withValues(alpha: 0.55),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(12),
              // Trailing total + caret
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.total.toStringAsFixed(2)} ${widget.sym}',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const Gap(4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Open',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                      const Gap(2),
                      PhosphorIcon(
                        PhosphorIconsRegular.caretRight,
                        size: 12,
                        color: cs.onSurface.withValues(alpha: 0.45),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
