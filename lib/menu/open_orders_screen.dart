import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/auth/auth_provider.dart';
import 'package:pos_app/bookings/bookings_provider.dart';
import 'package:pos_app/database/app_database.dart';
import 'package:pos_app/database/database_provider.dart';
import 'package:pos_app/navigation/main_layout.dart';
import 'package:pos_app/cart/cart_provider.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/currency/currencies_provider.dart';
import 'package:pos_app/stock/warehouse_provider.dart';

/// Suspended/open orders streamed from the local Drift `pos_orders` table.
/// Includes both `synced` rows (have a real `serverId`) and `pending` rows
/// (saved offline, not yet pushed). Filters by `status=0` (open) — closed
/// orders from a completed checkout live with `status=1` and don't show.
///
/// Shape preserves the legacy API map contract so the screen body below
/// doesn't need touching. `id` falls back to `0` for pending rows; tapping
/// one will fail in `_reopen` (still calls `loadOrderById` on the server)
/// — acceptable V1: pending orders are visible in the list, reopen needs
/// a sync to land first.
final openOrdersProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final companyId = ref.watch(selectedCompanyProvider)?.id;
  if (companyId == null) return Stream.value(const []);

  final query = db.select(db.posOrdersTable)
    ..where((t) => t.companyId.equals(companyId))
    ..where((t) => t.status.equals(0));

  return query.watch().map((rows) => rows.map((r) => <String, dynamic>{
        'id': r.serverId ?? 0,
        'localId': r.localId,
        'number': r.orderName ?? 'ORD-${r.serverId ?? "PENDING"}',
        'total': r.total ?? 0.0,
        'userId': r.userId,
        'floorPlanTableId': r.tableId,
        'warehouseId': r.warehouseId,
        'syncStatus': r.syncStatus,
      }).toList());
});

class OpenOrdersScreen extends ConsumerStatefulWidget {
  final VoidCallback? onMenuPressed;

  const OpenOrdersScreen({super.key, this.onMenuPressed});

  @override
  ConsumerState<OpenOrdersScreen> createState() => _OpenOrdersScreenState();
}

class _OpenOrdersScreenState extends ConsumerState<OpenOrdersScreen> {
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _pullFromServer());
  }

  /// Fetches open orders from the API and upserts them into Drift so orders
  /// created on other devices (or via the backend directly) appear in the list.
  Future<void> _pullFromServer() async {
    final company = ref.read(selectedCompanyProvider);
    if (company == null) return;
    if (mounted) setState(() => _syncing = true);

    try {
      final orders = await ApiClient().getAllPosOrders(company.id);
      final db = ref.read(appDatabaseProvider);
      final now = DateTime.now().toUtc();

      // Collect the server IDs that are still open so we can clean up stale rows.
      final openServerIds = <int>{};

      for (final o in orders) {
        final id = (o['id'] ?? o['Id']) as int? ?? 0;
        if (id == 0) continue;
        final status = (o['status'] ?? o['Status']) as int? ?? 0;
        if (status != 0) continue; // only open orders
        openServerIds.add(id);

        // Case 1: Already in Drift matched by serverId — skip.
        final existingByServerId = await (db.select(db.posOrdersTable)
              ..where((t) => t.serverId.equals(id)))
            .getSingleOrNull();
        if (existingByServerId != null) continue;

        // Case 2: A local UUID row with no serverId exists for the same order
        // name (created offline, just pushed by BatchSync). Stamp the serverId
        // on it so it won't appear as a duplicate after the next pull.
        final serverName =
            (o['number'] ?? o['Number'] ?? o['orderNumber']) as String?;
        if (serverName != null && serverName.isNotEmpty) {
          final existingByName = await (db.select(db.posOrdersTable)
                ..where((t) => t.orderName.equals(serverName))
                ..where((t) => t.status.equals(0))
                ..where((t) => t.syncStatus.equals('synced'))
                ..limit(1))
              .getSingleOrNull();
          if (existingByName != null && existingByName.serverId == null) {
            await (db.update(db.posOrdersTable)
                  ..where((t) => t.localId.equals(existingByName.localId)))
                .write(PosOrdersTableCompanion(serverId: Value(id)));
            continue;
          }
        }

        // Case 3: Genuine server-originated order not yet in local Drift —
        // insert with a deterministic sentinel localId.
        await db.into(db.posOrdersTable).insertOnConflictUpdate(
          PosOrdersTableCompanion(
            localId: Value('svr_$id'),
            serverId: Value(id),
            companyId: Value(company.id),
            userId: Value((o['userId'] ?? o['UserId']) as int? ?? 0),
            tableId: Value((o['floorPlanTableId'] ?? o['FloorPlanTableId']) as int?),
            serviceType: Value((o['serviceType'] ?? o['ServiceType']) as int? ?? 0),
            serviceStatus: Value((o['serviceStatus'] ?? o['ServiceStatus']) as int? ?? 0),
            orderName: Value(serverName),
            openedAt: Value(now),
            status: const Value(0),
            total: Value(((o['total'] ?? o['Total']) as num?)?.toDouble()),
            discount: const Value(0),
            warehouseId: Value((o['warehouseId'] ?? o['WarehouseId']) as int? ?? 1),
            syncStatus: const Value('synced'),
            lastModified: Value(now),
          ),
        );
      }

      // Remove sentinel rows for orders that are no longer open on the server.
      final svrRows = await (db.select(db.posOrdersTable)
            ..where((t) => t.companyId.equals(company.id))
            ..where((t) => t.status.equals(0)))
          .get();
      for (final row in svrRows) {
        if (row.localId.startsWith('svr_') &&
            row.serverId != null &&
            !openServerIds.contains(row.serverId!)) {
          await (db.delete(db.posOrdersTable)
                ..where((t) => t.localId.equals(row.localId)))
              .go();
        }
      }
    } catch (_) {
      // Offline or API error — Drift stream already shows local orders.
    } finally {
      if (mounted) {
        setState(() => _syncing = false);
        ref.invalidate(openOrdersProvider);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(openOrdersProvider);
    final allUsers = ref.watch(allUsersProvider).value ?? [];
    final allRooms = ref.watch(allRoomsProvider).value ?? [];
    final sym = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(
        leading: widget.onMenuPressed != null
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: widget.onMenuPressed,
              )
            : null,
        title: const Text('Open Orders'),
        actions: [
          if (_syncing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const PhosphorIcon(PhosphorIconsRegular.arrowClockwise),
              tooltip: 'Refresh',
              onPressed: _pullFromServer,
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
                localId: (o['localId'] ?? '') as String,
                orderNumber: orderNumber,
                total: total,
                staffName: staffName,
                tableName: tableName,
                warehouseId: warehouseId,
                sym: sym,
              );
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
    );
  }
}

class _OpenOrderCard extends ConsumerStatefulWidget {
  final int orderId;
  final String localId;   // Drift localId — used when orderId == 0 (not yet synced)
  final String orderNumber;
  final double total;
  final String? staffName;
  final String? tableName;
  final int warehouseId;
  final String sym;

  const _OpenOrderCard({
    required this.orderId,
    required this.localId,
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
      bool ok;

      if (widget.orderId == 0) {
        // Local-only order (not yet synced) — load directly from Drift
        // so we never hit the API with id=0 and get a 404.
        ok = await ref
            .read(cartProvider.notifier)
            .loadOrderFromLocal(widget.localId);
      } else {
        // Server-synced order — load via API.
        ok = await ref.read(cartProvider.notifier).loadOrderById(
              ApiClient(),
              company.id,
              widget.orderId,
              widget.warehouseId,
            );
      }

      if (!mounted) return;
      if (ok) {
        // OpenOrdersScreen is a tab inside MainLayout — switch tabs reactively
        // instead of rebuilding MainLayout (which would re-fire its startup
        // cash-in hook). Just point the shared nav index at the POS Menu.
        ref.read(mainNavigationIndexProvider.notifier).state = 0;
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
