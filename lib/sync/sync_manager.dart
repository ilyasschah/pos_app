import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'package:pos_app/auth/auth_storage.dart';
import 'package:pos_app/database/app_database.dart';
import 'package:pos_app/sync/image_sync_helper.dart';

/// Pulls master data from the C# API into local Drift tables.
///
/// Each `_pull*` method follows the same delta pattern:
///   1. Read the per-entity watermark from `sync_meta`.
///   2. Call `GET /<Entity>/GetAll?companyId=X&modifiedAfter=<watermark>`.
///   3. Upsert rows by server `id`.
///   4. Stamp `sync_meta` with the time the request *started* (so any rows
///      written server-side mid-request are picked up by the next pull).
///
/// AppProperties is special — see [_pullAppProperties].
class SyncManager {
  SyncManager({
    required this.db,
    required this.dio,
    required this.authStorage,
    ImageSyncHelper? imageHelper,
  }) : imageHelper = imageHelper ?? ImageSyncHelper(dio);

  final AppDatabase db;
  final Dio dio;
  final AuthStorage authStorage;
  final ImageSyncHelper imageHelper;

  // Entity keys for sync_meta — keep as constants so a typo doesn't silently
  // create a duplicate row and break the watermark.
  static const _kProducts = 'products';
  static const _kTaxes = 'taxes';
  static const _kFloorPlans = 'floor_plans';
  static const _kFloorPlanTables = 'floor_plan_tables';
  static const _kUsers = 'users';
  static const _kAppProperties = 'app_properties';
  static const _kProductGroups = 'product_groups';
  static const _kPaymentTypes = 'payment_types';
  static const _kCustomers = 'customers';
  static const _kPromotions = 'promotions';
  static const _kProductComments = 'product_comments';
  static const _kDocuments       = 'documents';

  // ==========================================================================
  // PUBLIC ENTRYPOINT
  // ==========================================================================

  /// Full bidirectional sync: push every pending offline write (orders,
  /// cash movements, Z-reports) then pull fresh master data. Push runs
  /// first so server-side side effects (e.g. stock deltas, new generated
  /// Z-report rows) are reflected in the subsequent pull.
  ///
  /// Order matters: Z-reports push LAST so that all the day's orders and
  /// cash movements they need to aggregate over already exist server-side
  /// by the time `/ZReports/Generate` runs.
  Future<void> sync(int companyId) async {
    // Product groups first — products reference group IDs.
    await pushPendingProductGroupOps(companyId);
    // Product mutations after groups so group IDs are resolved.
    await pushPendingProductOps(companyId);
    // Barcode mutations after products so new product IDs are resolved first.
    await pushPendingBarcodeOps(companyId);
    // Promotion mutations after products so new product IDs referenced by
    // promotion items are already on the server.
    await pushPendingPromotionOps(companyId);
    // Open orders first — they must exist on the server before any completed
    // order that references the same items is processed by BatchSync.
    await pushPendingOpenOrders(companyId);
    await pushPendingOrders(companyId);
    await pushPendingVoids(companyId);
    await pushPendingCashMovements(companyId);
    await pushPendingZReports(companyId);
    await pushPendingUserOps(companyId);
    await pullMasterData(companyId);
    // Pull Documents last — after BatchSync has created them on the server —
    // so local Document rows pick up server-assigned numbers and IDs.
    await pullDocuments(companyId);
  }

  /// Pull-only path. Used by login (no orders to push yet) and by targeted
  /// post-mutation refreshes that already know nothing's pending.
  Future<void> pullMasterData(int companyId) async {
    await pullProducts(companyId);
    await pullTaxes(companyId);
    await pullFloorPlans(companyId);
    await pullFloorPlanTables(companyId);
    await pullUsers(companyId);
    await pullAppProperties(companyId);
    // Phase 3.6 additions — the four entities that previously hung the POS
    // screen offline. Pull last so they don't slow the first-paint critical
    // path (products/taxes/floor_plans are what the menu grid needs first).
    await pullProductGroups(companyId);
    await pullPaymentTypes(companyId);
    await pullCustomers(companyId);
    await pullPromotions(companyId);
    await pullProductComments(companyId);
    // Security key rules — full replace each sync (tiny table, no watermark).
    // Pulled here so SecurityGuard reflects any admin changes made since last sync.
    await pullSecurityKeys(companyId);
    // Company offline cache — single-row pull so receipts can render with
    // real branding (name/address/tax number/logo) when network drops.
    await pullCompany(companyId);
    // Stock levels — pulled last so any inventory changes from the preceding
    // pushes (BatchSync deductions, etc.) are reflected in the local cache.
    await pullStocks(companyId);
  }

  // ==========================================================================
  // PUSH — pending offline orders to /PosOrder/BatchSync
  // ==========================================================================

  /// Pushes every `syncStatus = 'pending'` order in the local DB to the
  /// server's `/PosOrder/BatchSync` endpoint. On success per item, the row's
  /// `syncStatus` flips to `'synced'` and `serverId` is populated. On per-
  /// item failure, the row flips to `'failed'` and stores the error — it
  /// can be retried later from the Failed Syncs screen.
  ///
  /// Whole-batch failure (network down, 500) leaves rows untouched so the
  /// next push retries them.
  Future<void> pushPendingOrders(int companyId) async {
    final pending = await db.getPendingOrders();
    if (pending.isEmpty) return;

    final payload = {
      'orders': pending.map(_orderToBatchJson).toList(),
    };

    final List<dynamic> results;
    try {
      final res = await dio.post<Map<String, dynamic>>(
        '/PosOrder/BatchSync',
        queryParameters: {'companyId': companyId},
        data: payload,
      );
      results = (res.data?['results'] as List<dynamic>?) ?? const [];
    } catch (_) {
      // Whole-batch failure — leave every row pending so the next push retries.
      // Do NOT mark them failed; that's for per-item server-side rejections.
      rethrow;
    }

    for (final raw in results) {
      final r = raw as Map<String, dynamic>;
      final localId = r['localId'] as String?;
      if (localId == null) continue;

      final success = r['success'] as bool? ?? false;
      try {
        if (success) {
          final serverId = r['serverId'] as int?;
          if (serverId != null) {
            // For paid orders the server returns the Document.Id (not PosOrder.Id
            // — the PosOrder is deleted by CheckoutPosOrderCommand on the server).
            // Stamp this onto the local Document row so it can be found/updated
            // when the pull syncs Documents back from the server.
            await db.linkDocumentToServer(localId, serverId);
            // Delete the completed PosOrder — items cascade via FK.
            await db.deleteCompletedOrder(localId);
          } else {
            await db.markOrderFailed(
                localId, 'Server returned success without a serverId.');
          }
        } else {
          final error = r['error'] as String? ?? 'Unknown server error.';
          await db.markOrderFailed(localId, error);
        }
      } catch (_) {
        // DB write failure is rare — swallow so one bad row doesn't abort
        // the rest of the batch. Next push will see the original row still
        // pending and retry from scratch.
      }
    }
  }

  Map<String, dynamic> _orderToBatchJson(PosOrderWithItems o) {
    return {
      'localId': o.order.localId,
      // Non-null for orders that were loaded from the server (e.g. 'svr_3280').
      // The backend uses this to call Checkout on the existing PosOrder rather
      // than creating a new one — preventing duplicate rows in SQL Server.
      'existingServerId': o.order.serverId,
      'paymentTypeId': o.order.paymentTypeId,
      'amountPaid': o.order.amountPaid,
      'orderTotal': o.order.total ?? 0,
      'order': {
        'userId': o.order.userId,
        'number': o.order.orderName,
        'discount': o.order.discount,
        'discountType': 0,
        'total': o.order.total,
        'customerId': o.order.customerId,
        'serviceType': o.order.serviceType,
        'serviceStatus': o.order.serviceStatus,
        'floorPlanTableId': o.order.tableId,
        'warehouseId': o.order.warehouseId,
      },
      'items': o.items.map((item) {
            // Decode per-item tax data stored at checkout time.
            // Shape stored: [{"id": 1, "amount": 2.50}]
            final List<Map<String, dynamic>> taxEntries = item.taxesJson != null
                ? (jsonDecode(item.taxesJson!) as List)
                    .cast<Map<String, dynamic>>()
                : const [];
            final appliedTaxIds =
                taxEntries.map((t) => t['id'] as int).toList();
            // CheckoutItemDto.Taxes expects {taxId, amount} pairs.
            final taxes = taxEntries
                .map((t) => {
                      'taxId': t['id'] as int,
                      'amount': t['amount'],
                    })
                .toList();
            return {
              'posOrderId': 0,
              'productId': item.productId,
              'roundNumber': 1,
              'quantity': item.quantity,
              'price': item.unitPrice,
              'discount': item.discount,
              'discountType': item.discountType,
              'discountAppliedType': 0,
              'comment': item.comment,
              'bundle': null,
              'appliedTaxIds': appliedTaxIds,
              'taxes': taxes,
            };
          }).toList(),
    };
  }

  // ==========================================================================
  // PUSH — pending open orders to /PosOrder/Create + /PosOrderItem/BulkAdd
  // ==========================================================================

  /// Pushes every `status=0, syncStatus='pending'` (saved-but-unpaid) order
  /// to the server so other devices can see it in open-orders lists.
  ///
  /// Two-phase per order:
  ///   1. If no serverId → POST /PosOrder/Create → store serverId locally.
  ///   2. POST /PosOrderItem/BulkAdd — server's delta logic handles re-saves.
  ///   3. Mark synced.
  ///
  /// A failure at phase 2 leaves the row with a serverId but still 'pending',
  /// so the next sync retries only the item-add step (no duplicate header).
  Future<void> pushPendingOpenOrders(int companyId) async {
    final pending = await db.getPendingOpenOrders();
    if (pending.isEmpty) return;

    for (final o in pending) {
      try {
        int serverId;

        if (o.order.serverId == null) {
          // Phase 1: create the order header on the server.
          final res = await dio.post<dynamic>(
            '/PosOrder/Create',
            queryParameters: {'companyId': companyId},
            data: {
              'userId': o.order.userId,
              'number': o.order.orderName ?? 'ORD',
              'discount': o.order.discount,
              'discountType': 0,
              'total': o.order.total ?? 0,
              'customerId': o.order.customerId,
              'serviceType': o.order.serviceType,
              'serviceStatus': o.order.serviceStatus,
              'floorPlanTableId': o.order.tableId,
              'warehouseId': o.order.warehouseId,
            },
          );
          final data = res.data;
          serverId = data is int
              ? data
              : (data['id'] ?? data['Id'] ?? data['posOrderId'] ??
                    data['PosOrderId']) as int;

          // Persist serverId so a crash before phase 2 doesn't re-create the header.
          await db.setServerId(o.order.localId, serverId);
        } else {
          serverId = o.order.serverId!;
        }

        // Phase 2: add / update items (server delta logic handles re-saves).
        if (o.items.isNotEmpty) {
          final itemsJson = o.items
              .map((item) {
                final List<Map<String, dynamic>> taxEntries =
                    item.taxesJson != null
                        ? (jsonDecode(item.taxesJson!) as List)
                            .cast<Map<String, dynamic>>()
                        : const [];
                final appliedTaxIds =
                    taxEntries.map((t) => t['id'] as int).toList();
                return {
                  'posOrderId': serverId,
                  'PosOrderId': serverId,
                  'productId': item.productId,
                  'ProductId': item.productId,
                  'quantity': item.quantity,
                  'Quantity': item.quantity,
                  'price': item.unitPrice,
                  'Price': item.unitPrice,
                  'discount': item.discount,
                  'Discount': item.discount,
                  'discountType': item.discountType,
                  'DiscountType': item.discountType,
                  'discountAppliedType': 0,
                  'DiscountAppliedType': 0,
                  'comment': item.comment,
                  'Comment': item.comment,
                  'roundNumber': 1,
                  'RoundNumber': 1,
                  'bundle': null,
                  'Bundle': null,
                  'appliedTaxIds': appliedTaxIds,
                  'AppliedTaxIds': appliedTaxIds,
                };
              })
              .toList();

          await dio.post<dynamic>(
            '/PosOrderItem/BulkAdd',
            queryParameters: {
              'companyId': companyId,
              'warehouseId': o.order.warehouseId,
              'orderTotal': o.order.total ?? 0,
            },
            data: itemsJson,
          );
        }

        // Phase 3: mark fully synced.
        await db.markOrderSynced(o.order.localId, serverId);
      } catch (e) {
        debugPrint('pushPendingOpenOrders: ${o.order.localId} failed — $e');
        // Leave as pending; next sync will retry.
      }
    }
  }

  // ==========================================================================
  // PUSH — pending voids to /PosVoids/Add + /PosOrder/Delete
  // ==========================================================================

  /// Pushes every `syncStatus='pending'` void record to the server.
  /// Each void: (1) POSTs one PosVoid record per item, (2) DELETEs the server
  /// PosOrder. Both steps are required to match what the online void flow does.
  Future<void> pushPendingVoids(int companyId) async {
    final pending = await db.getPendingVoids();
    if (pending.isEmpty) return;

    for (final v in pending) {
      try {
        final items =
            (jsonDecode(v.itemsJson) as List).cast<Map<String, dynamic>>();

        // Step 1: post a PosVoid row for every voided item.
        for (final item in items) {
          await dio.post<dynamic>(
            '/PosVoids/Add',
            queryParameters: {
              'companyId':    companyId,
              'orderNumber':  v.orderNumber,
              'userId':       v.userId,
              'userName':     (item['userName'] ?? '') as String,
              'productId':    item['productId'] as int,
              'productName':  (item['productName'] ?? '') as String,
              'roundNumber':  (item['roundNumber'] ?? 1) as int,
              'quantity':     item['quantity'],
              'price':        item['price'],
              'discount':     (item['discount'] ?? 0),
              'discountType': (item['discountType'] ?? 0) as int,
              'total':        item['total'],
              'voidedById':   v.userId,
              'voidedByName': (item['userName'] ?? '') as String,
              if (v.reason != null) 'reason': v.reason,
            },
          );
        }

        // Step 2: delete the server PosOrder (void = remove the open order).
        await dio.delete<dynamic>(
          '/PosOrder/Delete',
          queryParameters: {
            'id':          v.serverOrderId,
            'companyId':   companyId,
            'warehouseId': v.warehouseId,
          },
        );

        await db.markVoidSynced(v.localId);
      } catch (e) {
        debugPrint('pushPendingVoids: ${v.localId} failed — $e');
        // Leave as pending; next sync retries.
      }
    }
  }

  // ==========================================================================
  // PUSH — pending cash movements to /StartingCash/Add (individual POSTs)
  // ==========================================================================

  /// Pushes every `syncStatus='pending'` cash_movement to /StartingCash/Add.
  /// No batch endpoint exists server-side, so we loop individually — fine
  /// for the typical end-of-shift queue size (single digits).
  ///
  /// Per-item failure marks just that row failed; the loop continues. Whole-
  /// transport failures (e.g. server unreachable mid-loop) leave remaining
  /// rows pending for the next retry.
  Future<void> pushPendingCashMovements(int companyId) async {
    final pending = await db.getPendingCashMovements();
    if (pending.isEmpty) return;

    for (final m in pending) {
      try {
        final res = await dio.post<dynamic>(
          '/StartingCash/Add',
          queryParameters: {
            'companyId': companyId,
            'userId': m.userId,
            'amount': m.amount,
            // Drift stores 'in'/'out' as text for readability; the C# API
            // expects 0 (cash in) / 1 (cash out). Convert at the boundary.
            'startingCashType': m.type == 'in' ? 0 : 1,
            if (m.note != null && m.note!.isNotEmpty) 'description': m.note,
          },
        );

        // /StartingCash/Add returns the created StartingCashDto with an `id`.
        final data = res.data;
        final serverId = data is Map<String, dynamic>
            ? (data['id'] as int?)
            : null;

        if (serverId != null) {
          await db.markCashMovementSynced(m.localId, serverId);
        } else {
          // Server accepted the POST but we couldn't parse an id — mark
          // synced without server linkage rather than retry forever.
          await db.markCashMovementSynced(m.localId, 0);
        }
      } catch (e) {
        await db.markCashMovementFailed(m.localId, e.toString());
        // Continue the loop — one bad movement shouldn't block the rest.
      }
    }
  }

  // ==========================================================================
  // PUSH — pending Z-reports via /ZReports/Generate (individual POSTs)
  // ==========================================================================

  /// Pushes every `syncStatus='pending'` z_report. /ZReports/Generate is a
  /// server-side aggregation, so we don't send our local totals — we just
  /// ask the server to generate its own Z-report for the user/company and
  /// use the returned id to mark the local snapshot as synced.
  ///
  /// CRITICAL ORDERING: This must run AFTER pushPendingOrders and
  /// pushPendingCashMovements so that all source data the server aggregates
  /// over is already present. `sync()` enforces this order.
  Future<void> pushPendingZReports(int companyId) async {
    final pending = await db.getPendingZReports();
    if (pending.isEmpty) return;

    for (final report in pending) {
      try {
        final res = await dio.post<dynamic>(
          '/ZReports/Generate',
          queryParameters: {
            'companyId': companyId,
            'userId': report.userId,
          },
        );

        final data = res.data;
        final serverId = data is Map<String, dynamic>
            ? (data['id'] as int?)
            : null;

        if (serverId != null) {
          await db.markZReportSynced(report.localId, serverId);
        } else {
          await db.markZReportSynced(report.localId, 0);
        }
      } catch (e) {
        await db.markZReportFailed(report.localId, e.toString());
      }
    }
  }

  // ==========================================================================
  // PUSH — pending product creates / updates / deletes
  // ==========================================================================

  /// Pushes all locally-queued product mutations to the server:
  ///   • pending_create → POST /Products/Add  (temp negative id → real id)
  ///   • pending_update → PATCH /Products/Update
  ///   • pending_delete → DELETE /Products/Delete  (then hard-delete locally)
  ///
  /// Must run BEFORE pushPendingOrders so newly created products exist on the
  /// server before any order that references them is synced.
  Future<void> pushPendingProductOps(int companyId) async {
    final pending = await (db.select(db.productsTable)
          ..where((t) => t.companyId.equals(companyId))
          ..where((t) => t.syncStatus.isIn([
                'pending_create',
                'pending_update',
                'pending_delete',
              ])))
        .get();

    if (pending.isEmpty) return;

    for (final p in pending) {
      try {
        switch (p.syncStatus) {
          // ── CREATE ──────────────────────────────────────────────────────
          case 'pending_create':
            // Re-encode image from disk so we can include it in the POST.
            String imageBase64 = '';
            if (p.localImagePath != null) {
              try {
                final bytes = await File(p.localImagePath!).readAsBytes();
                imageBase64 = base64Encode(bytes);
              } catch (_) {}
            }

            final res = await dio.post<Map<String, dynamic>>(
              '/Products/Add',
              queryParameters: {'companyId': companyId},
              data: {
                'name': p.name,
                'productGroupId': p.productGroupId,
                'code': p.code,
                'plu': p.plu,
                'measurementUnit': p.measurementUnit,
                'price': p.price,
                'cost': p.cost,
                'markup': p.markup,
                'rank': p.rank,
                'ageRestriction': p.ageRestriction,
                'description': p.description,
                'isTaxInclusivePrice': p.isTaxInclusivePrice,
                'isService': p.isService,
                'isPriceChangeAllowed': p.isPriceChangeAllowed,
                'isUsingDefaultQuantity': p.isUsingDefaultQuantity,
                'isEnabled': p.isEnabled,
                'color': p.colorHex ?? '#000000',
                'imageBase64': imageBase64,
              },
            );
            final body = res.data?['data'] ?? res.data;
            final realId = (body['id'] as num?)?.toInt();
            if (realId == null) throw Exception('Server returned no id for product create');

            // Replace the temp row: delete by temp id, insert with real id.
            await db.transaction(() async {
              await (db.delete(db.productsTable)
                    ..where((t) => t.id.equals(p.id)))
                  .go();
              await db.into(db.productsTable).insert(ProductsTableCompanion(
                id: Value(realId),
                companyId: Value(p.companyId),
                name: Value(p.name),
                price: Value(p.price),
                cost: Value(p.cost),
                productGroupId: Value(p.productGroupId),
                isService: Value(p.isService),
                colorHex: Value(p.colorHex),
                localImagePath: Value(p.localImagePath),
                code: Value(p.code),
                plu: Value(p.plu),
                measurementUnit: Value(p.measurementUnit),
                description: Value(p.description),
                markup: Value(p.markup),
                rank: Value(p.rank),
                ageRestriction: Value(p.ageRestriction),
                isPriceChangeAllowed: Value(p.isPriceChangeAllowed),
                isUsingDefaultQuantity: Value(p.isUsingDefaultQuantity),
                isTaxInclusivePrice: Value(p.isTaxInclusivePrice),
                isEnabled: Value(p.isEnabled),
                syncStatus: const Value('synced'),
                lastModified: Value(DateTime.now().toUtc()),
              ));
            });

          // ── UPDATE ──────────────────────────────────────────────────────
          case 'pending_update':
            String imageBase64 = '';
            if (p.localImagePath != null) {
              try {
                final bytes = await File(p.localImagePath!).readAsBytes();
                imageBase64 = base64Encode(bytes);
              } catch (_) {}
            }

            await dio.patch<dynamic>(
              '/Products/Update',
              queryParameters: {'id': p.id, 'companyId': companyId},
              data: {
                'id': p.id,
                'name': p.name,
                'productGroupId': p.productGroupId,
                'code': p.code,
                'plu': p.plu,
                'measurementUnit': p.measurementUnit,
                'price': p.price,
                'cost': p.cost,
                'markup': p.markup,
                'rank': p.rank,
                'ageRestriction': p.ageRestriction,
                'description': p.description,
                'isTaxInclusivePrice': p.isTaxInclusivePrice,
                'isService': p.isService,
                'isPriceChangeAllowed': p.isPriceChangeAllowed,
                'isUsingDefaultQuantity': p.isUsingDefaultQuantity,
                'isEnabled': p.isEnabled,
                'color': p.colorHex ?? '#000000',
                'imageBase64': imageBase64,
              },
            );
            await (db.update(db.productsTable)
                  ..where((t) => t.id.equals(p.id)))
                .write(const ProductsTableCompanion(
              syncStatus: Value('synced'),
              syncError: Value(null),
            ));

          // ── DELETE ──────────────────────────────────────────────────────
          case 'pending_delete':
            await dio.delete<dynamic>(
              '/Products/Delete',
              queryParameters: {'id': p.id, 'companyId': companyId},
            );
            await (db.delete(db.productsTable)
                  ..where((t) => t.id.equals(p.id)))
                .go();
        }
      } catch (e) {
        debugPrint('pushPendingProductOps: product ${p.id} (${p.syncStatus}) failed — $e');
        // Record the error; leave syncStatus unchanged so next sync retries.
        try {
          await (db.update(db.productsTable)..where((t) => t.id.equals(p.id)))
              .write(ProductsTableCompanion(syncError: Value(e.toString())));
        } catch (_) {}
      }
    }
  }

  /// Pushes every pending barcode write (pending_create / pending_delete) to
  /// the server. Runs after [pushPendingProductOps] so new product IDs are
  /// already resolved before we try to associate barcodes with them.
  Future<void> pushPendingBarcodeOps(int companyId) async {
    final pending = await (db.select(db.barcodesTable)
          ..where((t) => t.companyId.equals(companyId))
          ..where((t) => t.syncStatus.isNotIn(['synced'])))
        .get();

    for (final b in pending) {
      try {
        switch (b.syncStatus) {
          case 'pending_create':
            final res = await dio.post<dynamic>(
              '/Barcodes/Add',
              queryParameters: {'companyId': companyId},
              data: {'productId': b.productId, 'value': b.value},
            );
            final serverId =
                (res.data is Map ? res.data['id'] : null) as int?;
            await (db.update(db.barcodesTable)
                  ..where((t) => t.localId.equals(b.localId)))
                .write(BarcodesTableCompanion(
              serverId: Value(serverId),
              syncStatus: const Value('synced'),
            ));

          case 'pending_delete':
            if (b.serverId != null) {
              await dio.delete<dynamic>(
                '/Barcodes/Delete',
                queryParameters: {
                  'id': b.serverId,
                  'companyId': companyId,
                },
              );
            }
            await (db.delete(db.barcodesTable)
                  ..where((t) => t.localId.equals(b.localId)))
                .go();
        }
      } catch (e) {
        debugPrint(
            'pushPendingBarcodeOps: barcode ${b.localId} (${b.syncStatus}) failed — $e');
      }
    }
  }

  // ==========================================================================
  // SYNC META HELPERS
  // ==========================================================================

  Future<DateTime?> _getLastSync(String entity) async {
    final row = await (db.select(db.syncMetaTable)
          ..where((t) => t.entity.equals(entity)))
        .getSingleOrNull();
    return row?.lastSyncedAt;
  }

  Future<void> _setLastSync(String entity, DateTime time) async {
    await db.into(db.syncMetaTable).insertOnConflictUpdate(
          SyncMetaTableCompanion(
            entity: Value(entity),
            lastSyncedAt: Value(time.toUtc()),
          ),
        );
  }

  /// Encodes the watermark in the form the C# `modifiedAfter` query param
  /// expects: ISO-8601 with the trailing `Z` so it parses as `DateTimeKind.Utc`.
  Map<String, dynamic> _query(int companyId, DateTime? watermark) => {
        'companyId': companyId,
        if (watermark != null) 'modifiedAfter': watermark.toUtc().toIso8601String(),
      };

  /// Parses a server timestamp into UTC. Falls back to `now` so a missing
  /// `lastModified` (server not yet backfilled) doesn't write `default(DateTime)`
  /// into the DB.
  DateTime _parseLastModified(dynamic raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.parse(raw).toUtc();
    }
    return DateTime.now().toUtc();
  }

  /// Like [_parseLastModified] but returns null when the field is missing —
  /// used for optional timestamps (dateCreated / dateUpdated) where "missing"
  /// is meaningful and shouldn't be silently replaced with `now`.
  DateTime? _parseNullableDate(dynamic raw) {
    if (raw is String && raw.isNotEmpty) {
      try {
        return DateTime.parse(raw).toUtc();
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // ==========================================================================
  // DELTA PULLS
  // ==========================================================================

  Future<void> pullProducts(int companyId) async {
    final startedAt = DateTime.now().toUtc();
    final watermark = await _getLastSync(_kProducts);

    final res = await dio.get<List<dynamic>>(
      '/Products/GetAll',
      queryParameters: _query(companyId, watermark),
    );

    final rows = res.data ?? const [];

    // Sequential image processing — one file handle at a time. ImageSyncHelper
    // never throws (it logs + returns null on failure), so a single bad image
    // can never abort the loop or leave a half-written product row.
    var productCount = 0;
    var imageSuccessCount = 0;

    for (final json in rows.cast<Map<String, dynamic>>()) {
      final id = json['id'] as int;

      // Existing API serves base64 in `image`. ImageSyncHelper handles both
      // base64 and URL transparently — when the backend moves to a CDN, no
      // Flutter change required. Failures return null; the product still
      // inserts with localImagePath: null and the UI falls back to its
      // placeholder icon.
      final localImagePath = await imageHelper.downloadAndSaveImage(
        json['image'] as String?,
        id,
      );
      if (localImagePath != null) imageSuccessCount++;
      productCount++;

      await db.into(db.productsTable).insertOnConflictUpdate(
            ProductsTableCompanion(
              id: Value(id),
              companyId: Value(json['companyId'] as int? ?? companyId),
              name: Value(json['name'] as String? ?? ''),
              price: Value((json['price'] as num?)?.toDouble() ?? 0),
              cost: Value((json['cost'] as num?)?.toDouble() ?? 0),
              barcode: Value(_firstBarcode(json)),
              productGroupId: Value(json['productGroupId'] as int?),
              isService: Value(json['isService'] as bool? ?? false),
              colorHex: Value(json['color'] as String?),
              localImagePath: Value(localImagePath),
              // Schema v2 columns — needed for the admin product editor to
              // render without round-tripping to the API.
              code: Value(json['code'] as String?),
              plu: Value(json['plu'] as int?),
              measurementUnit: Value(json['measurementUnit'] as String?),
              description: Value(json['description'] as String?),
              markup: Value((json['markup'] as num?)?.toDouble()),
              rank: Value(json['rank'] as int? ?? 0),
              currencyId: Value(json['currencyId'] as int?),
              ageRestriction: Value(json['ageRestriction'] as int?),
              lastPurchasePrice:
                  Value((json['lastPurchasePrice'] as num?)?.toDouble()),
              dateCreated: Value(_parseNullableDate(json['dateCreated'])),
              dateUpdated: Value(_parseNullableDate(json['dateUpdated'])),
              isPriceChangeAllowed:
                  Value(json['isPriceChangeAllowed'] as bool? ?? false),
              isUsingDefaultQuantity:
                  Value(json['isUsingDefaultQuantity'] as bool? ?? true),
              isTaxInclusivePrice:
                  Value(json['isTaxInclusivePrice'] as bool? ?? true),
              isEnabled: Value(json['isEnabled'] as bool? ?? true),
              lastModified: Value(_parseLastModified(json['lastModified'])),
            ),
          );
    }

    await _setLastSync(_kProducts, startedAt);

    debugPrint(
        'pullProducts: saved $productCount products. '
        'Successfully cached $imageSuccessCount images.');
  }

  String? _firstBarcode(Map<String, dynamic> json) {
    final list = json['barcodes'];
    if (list is List && list.isNotEmpty) {
      final first = list.first;
      return first?.toString();
    }
    return null;
  }

  Future<void> pullTaxes(int companyId) async {
    final startedAt = DateTime.now().toUtc();
    final watermark = await _getLastSync(_kTaxes);

    final res = await dio.get<List<dynamic>>(
      '/Taxes/GetAllTaxes',
      queryParameters: _query(companyId, watermark),
    );
    final rows = res.data ?? const [];

    await db.batch((batch) {
      for (final json in rows.cast<Map<String, dynamic>>()) {
        batch.insert(
          db.taxesTable,
          TaxesTableCompanion(
            id: Value(json['id'] as int),
            companyId: Value(json['companyId'] as int? ?? companyId),
            name: Value(json['name'] as String? ?? ''),
            rate: Value((json['rate'] as num?)?.toDouble() ?? 0),
            // Schema v2 columns.
            code: Value(json['code'] as String?),
            isFixed: Value(json['isFixed'] as bool? ?? false),
            isTaxOnTotal: Value(json['isTaxOnTotal'] as bool? ?? true),
            isEnabled: Value(json['isEnabled'] as bool? ?? true),
            lastModified: Value(_parseLastModified(json['lastModified'])),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    await _setLastSync(_kTaxes, startedAt);
  }

  Future<void> pullFloorPlans(int companyId) async {
    final startedAt = DateTime.now().toUtc();
    final watermark = await _getLastSync(_kFloorPlans);

    final res = await dio.get<List<dynamic>>(
      '/FloorPlans/GetAll',
      queryParameters: _query(companyId, watermark),
    );
    final rows = res.data ?? const [];

    await db.batch((batch) {
      for (final json in rows.cast<Map<String, dynamic>>()) {
        batch.insert(
          db.floorPlansTable,
          FloorPlansTableCompanion(
            id: Value(json['id'] as int),
            companyId: Value(json['companyId'] as int? ?? companyId),
            name: Value(json['name'] as String? ?? ''),
            color: Value(json['color'] as String? ?? 'Transparent'),
            lastModified: Value(_parseLastModified(json['lastModified'])),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    await _setLastSync(_kFloorPlans, startedAt);
  }

  Future<void> pullFloorPlanTables(int companyId) async {
    final startedAt = DateTime.now().toUtc();
    final watermark = await _getLastSync(_kFloorPlanTables);

    final res = await dio.get<List<dynamic>>(
      '/FloorPlanTables/GetAll',
      queryParameters: _query(companyId, watermark),
    );
    final rows = res.data ?? const [];

    await db.batch((batch) {
      for (final json in rows.cast<Map<String, dynamic>>()) {
        batch.insert(
          db.floorPlanTablesTable,
          FloorPlanTablesTableCompanion(
            id: Value(json['id'] as int),
            companyId: Value(json['companyId'] as int? ?? companyId),
            floorPlanId: Value(json['floorPlanId'] as int),
            name: Value(json['name'] as String? ?? ''),
            positionX: Value((json['positionX'] as num?)?.toDouble() ?? 0),
            positionY: Value((json['positionY'] as num?)?.toDouble() ?? 0),
            width: Value((json['width'] as num?)?.toDouble() ?? 0),
            height: Value((json['height'] as num?)?.toDouble() ?? 0),
            isRound: Value(json['isRound'] as bool? ?? false),
            status: Value(json['status'] as int? ?? 0),
            lastModified: Value(_parseLastModified(json['lastModified'])),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    await _setLastSync(_kFloorPlanTables, startedAt);
  }

  Future<void> pullUsers(int companyId) async {
    final startedAt = DateTime.now().toUtc();
    final watermark = await _getLastSync(_kUsers);

    // deviceId is required server-side for HashedPin to resolve correctly —
    // each device has its own PIN per user. Without it, every user comes
    // back with `hashedPin: null` and offline login silently breaks.
    final deviceId = await authStorage.getOrCreateDeviceId();

    final res = await dio.get<List<dynamic>>(
      '/Users/GetAllUsers',
      queryParameters: {
        ..._query(companyId, watermark),
        'deviceId': deviceId,
      },
    );
    final rows = res.data ?? const [];

    await db.batch((batch) {
      for (final json in rows.cast<Map<String, dynamic>>()) {
        // Hash-only — never persist a raw `password` field even if the
        // server slips up and sends one. (Plan rule.)
        final hashedPin = json['hashedPin'] as String?;
        final firstName = _nullIfBlank(json['firstName'] as String?);
        final lastName  = _nullIfBlank(json['lastName']  as String?);
        final username  = _nullIfBlank(json['username']  as String?);
        final displayName = [firstName, lastName]
            .whereType<String>()
            .join(' ')
            .trim();

        batch.insert(
          db.usersTable,
          UsersTableCompanion(
            id:           Value(json['id'] as int),
            companyId:    Value(json['companyId'] as int? ?? companyId),
            name:         Value(displayName.isEmpty ? (username ?? '') : displayName),
            firstName:    Value(firstName),
            lastName:     Value(lastName),
            username:     Value(username),
            email:        Value(json['email'] as String?),
            pinHash:      Value(hashedPin),
            role:         Value(json['accessLevel'] as int? ?? 0),
            isEnabled:    Value(json['isEnabled'] as bool? ?? true),
            lastModified: Value(_parseLastModified(json['lastModified'])),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    await _setLastSync(_kUsers, startedAt);
  }

  // ==========================================================================
  // PHASE 3.6 PULLS — ProductGroups, PaymentTypes, Customers, Promotions
  //
  // The 4 endpoints below DON'T currently accept `modifiedAfter` server-side
  // (their entities have LastModified, but the DTOs + controllers haven't
  // been extended like the 6 entities in Phase 0/3.5). Sending the param
  // anyway — ASP.NET silently ignores unknown query params, and the moment
  // the backend adds the filter no Flutter change is required.
  //
  // Until then these are effectively full-table pulls each cycle. Fine for
  // typical sizes (single-digit groups, ~10 payment types, hundreds of
  // customers/promotions); revisit if customer counts blow up.
  // ==========================================================================

  /// Pushes every pending product-group write (create / update / delete) to
  /// the server, then lets the subsequent [pullProductGroups] bring back the
  /// canonical server data (including server-assigned IDs and image URLs).
  Future<void> pushPendingProductGroupOps(int companyId) async {
    final pending = await (db.select(db.productGroupsTable)
          ..where((t) => t.companyId.equals(companyId))
          ..where((t) => t.syncStatus.isNotIn(['synced'])))
        .get();

    for (final g in pending) {
      try {
        // Re-encode the locally-saved icon so the server can store it.
        String imageBase64 = '';
        if (g.localImagePath != null) {
          try {
            final file = File(g.localImagePath!);
            if (file.existsSync()) {
              imageBase64 = base64Encode(await file.readAsBytes());
            }
          } catch (_) {}
        }

        switch (g.syncStatus) {
          case 'pending_create':
            final res = await dio.post<dynamic>(
              '/ProductGroups/Add',
              queryParameters: {'companyId': companyId},
              data: {
                'name': g.name,
                'parentGroupId': g.parentGroupId,
                'color': g.colorHex,
                'image': imageBase64,
                'rank': g.rank,
              },
            );
            final serverId =
                (res.data is Map ? (res.data as Map)['id'] : null) as int?;
            if (serverId != null) {
              // Rename temp image file to the real server ID.
              String? newPath = g.localImagePath;
              if (newPath != null) {
                try {
                  final renamed =
                      newPath.replaceAll('${g.id}_image', '${serverId}_image');
                  await File(newPath).rename(renamed);
                  newPath = renamed;
                } catch (_) {}
              }
              await db.transaction(() async {
                await (db.delete(db.productGroupsTable)
                      ..where((t) => t.id.equals(g.id)))
                    .go();
                await db.into(db.productGroupsTable).insertOnConflictUpdate(
                      ProductGroupsTableCompanion(
                        id: Value(serverId),
                        companyId: Value(g.companyId),
                        name: Value(g.name),
                        parentGroupId: Value(g.parentGroupId),
                        colorHex: Value(g.colorHex),
                        rank: Value(g.rank),
                        localImagePath: Value(newPath),
                        lastModified: Value(DateTime.now().toUtc()),
                        syncStatus: const Value('synced'),
                      ),
                    );
              });
            }

          case 'pending_update':
            await dio.patch<dynamic>(
              '/ProductGroups/Update',
              queryParameters: {'companyId': companyId},
              data: {
                'id': g.id,
                'name': g.name,
                'parentGroupId': g.parentGroupId,
                'color': g.colorHex,
                'image': imageBase64,
                'rank': g.rank,
              },
            );
            await (db.update(db.productGroupsTable)
                  ..where((t) => t.id.equals(g.id)))
                .write(const ProductGroupsTableCompanion(
              syncStatus: Value('synced'),
            ));

          case 'pending_delete':
            await dio.delete<dynamic>(
              '/ProductGroups/Delete',
              queryParameters: {'id': g.id, 'companyId': companyId},
            );
            await (db.delete(db.productGroupsTable)
                  ..where((t) => t.id.equals(g.id)))
                .go();
        }
      } catch (e) {
        debugPrint(
            'pushPendingProductGroupOps: group ${g.id} (${g.syncStatus}) failed — $e');
        try {
          await (db.update(db.productGroupsTable)
                ..where((t) => t.id.equals(g.id)))
              .write(
                  ProductGroupsTableCompanion(syncError: Value(e.toString())));
        } catch (_) {}
      }
    }
  }

  Future<void> pullProductGroups(int companyId) async {
    final startedAt = DateTime.now().toUtc();
    final watermark = await _getLastSync(_kProductGroups);

    final res = await dio.get<List<dynamic>>(
      '/ProductGroups/GetAll',
      queryParameters: _query(companyId, watermark),
    );
    final rows = res.data ?? const [];

    // Sequential image saves + upserts. Can't use db.batch here because the
    // ImageSyncHelper awaits don't compose with batch's sync callback.
    var groupCount = 0;
    var imageSuccessCount = 0;

    for (final json in rows.cast<Map<String, dynamic>>()) {
      final id = json['id'] as int;

      // Don't overwrite rows that have unsync-ed local edits.
      final existing = await (db.select(db.productGroupsTable)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (existing != null && existing.syncStatus != 'synced') continue;

      // Download/decode the group icon. Returns null on null/empty source
      // or any decode/write failure (logged via debugPrint inside the helper).
      final localImagePath = await imageHelper.downloadAndSaveImage(
        json['image'] as String?,
        id,
        folder: 'group_images',
      );
      if (localImagePath != null) imageSuccessCount++;
      groupCount++;

      await db.into(db.productGroupsTable).insertOnConflictUpdate(
            ProductGroupsTableCompanion(
              id: Value(id),
              companyId: Value(json['companyId'] as int? ?? companyId),
              name: Value(json['name'] as String? ?? ''),
              parentGroupId: Value(json['parentGroupId'] as int?),
              colorHex: Value(json['color'] as String? ?? 'Transparent'),
              rank: Value(json['rank'] as int? ?? 0),
              localImagePath: Value(localImagePath),
              lastModified: Value(_parseLastModified(json['lastModified'])),
              syncStatus: const Value('synced'),
            ),
          );
    }

    await _setLastSync(_kProductGroups, startedAt);

    debugPrint(
        'pullProductGroups: saved $groupCount groups. '
        'Successfully cached $imageSuccessCount images.');
  }

  Future<void> pullPaymentTypes(int companyId) async {
    final startedAt = DateTime.now().toUtc();
    final watermark = await _getLastSync(_kPaymentTypes);

    final res = await dio.get<List<dynamic>>(
      '/PaymentTypes/GetAll',
      queryParameters: _query(companyId, watermark),
    );
    final rows = res.data ?? const [];

    await db.batch((batch) {
      for (final json in rows.cast<Map<String, dynamic>>()) {
        batch.insert(
          db.paymentTypesTable,
          PaymentTypesTableCompanion(
            id: Value(json['id'] as int),
            companyId: Value(json['companyId'] as int? ?? companyId),
            name: Value(json['name'] as String? ?? ''),
            code: Value(json['code'] as String?),
            isCustomerRequired:
                Value(json['isCustomerRequired'] as bool? ?? false),
            isFiscal: Value(json['isFiscal'] as bool? ?? false),
            isSlipRequired: Value(json['isSlipRequired'] as bool? ?? false),
            isChangeAllowed: Value(json['isChangeAllowed'] as bool? ?? false),
            ordinal: Value(json['ordinal'] as int? ?? 0),
            isEnabled: Value(json['isEnabled'] as bool? ?? true),
            isQuickPayment: Value(json['isQuickPayment'] as bool? ?? false),
            openCashDrawer: Value(json['openCashDrawer'] as bool? ?? false),
            shortcutKey: Value(json['shortcutKey'] as String?),
            markAsPaid: Value(json['markAsPaid'] as bool? ?? false),
            lastModified: Value(_parseLastModified(json['lastModified'])),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    await _setLastSync(_kPaymentTypes, startedAt);
  }

  Future<void> pullCustomers(int companyId) async {
    final startedAt = DateTime.now().toUtc();
    final watermark = await _getLastSync(_kCustomers);

    // Existing route is /Customer/GetAllCustomers (singular controller).
    final res = await dio.get<List<dynamic>>(
      '/Customer/GetAllCustomers',
      queryParameters: _query(companyId, watermark),
    );
    final rows = res.data ?? const [];

    await db.batch((batch) {
      for (final json in rows.cast<Map<String, dynamic>>()) {
        batch.insert(
          db.customersTable,
          CustomersTableCompanion(
            id: Value(json['id'] as int),
            companyId: Value(json['companyId'] as int? ?? companyId),
            code: Value(json['code'] as String?),
            name: Value(json['name'] as String? ?? 'Unknown'),
            taxNumber: Value(json['taxNumber'] as String?),
            address: Value(json['address'] as String?),
            postalCode: Value(json['postalCode'] as String?),
            city: Value(json['city'] as String?),
            countryId: Value(json['countryId'] as int?),
            email: Value(json['email'] as String?),
            phoneNumber: Value(json['phoneNumber'] as String?),
            isEnabled: Value(json['isEnabled'] as bool? ?? true),
            isCustomer: Value(json['isCustomer'] as bool? ?? true),
            isSupplier: Value(json['isSupplier'] as bool? ?? false),
            dueDatePeriod: Value(json['dueDatePeriod'] as int?),
            streetName: Value(json['streetName'] as String?),
            additionalStreetName: Value(json['additionalStreetName'] as String?),
            buildingNumber: Value(json['buildingNumber'] as String?),
            plotIdentification: Value(json['plotIdentification'] as String?),
            citySubdivisionName: Value(json['citySubdivisionName'] as String?),
            isTaxExempt: Value(json['isTaxExempt'] as bool? ?? false),
            lastModified: Value(_parseLastModified(json['lastModified'])),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    await _setLastSync(_kCustomers, startedAt);
  }

  /// Single-row pull: fetches the active company via `/Company/GetById`,
  /// writes the logo to disk via ImageSyncHelper, and upserts the lean
  /// row into `companies`. No `modifiedAfter` watermark — single tiny
  /// record, cheaper to re-fetch each sync than to track timestamps.
  Future<void> pullCompany(int companyId) async {
    final res = await dio.get<Map<String, dynamic>>(
      '/Company/GetById',
      queryParameters: {'id': companyId},
    );
    final json = res.data;
    if (json == null) return;

    // The C# API serves the logo as a base64 string under `logo`. Write
    // it to disk under company_logos/ and store only the path in Drift.
    // Disk write is best-effort — a missing logo never blocks the upsert.
    final localLogoPath = await imageHelper.downloadAndSaveImage(
      json['logo'] as String?,
      json['id'] as int? ?? companyId,
      folder: 'company_logos',
    );

    await db.into(db.companiesTable).insertOnConflictUpdate(
          CompaniesTableCompanion(
            id: Value(json['id'] as int? ?? companyId),
            name: Value(json['name'] as String? ?? ''),
            taxNumber: Value(json['taxNumber'] as String?),
            address: Value(json['address'] as String?),
            phone: Value(json['phoneNumber'] as String?),
            localLogoPath: Value(localLogoPath),
            lastModified: Value(_parseLastModified(json['lastModified'])),
          ),
        );
  }

  /// Pulls all stock records for [companyId] and upserts them into the local
  /// `stocks` table. No delta watermark — the full list is small enough
  /// (~products × warehouses rows) that a full replace is cheapest.
  /// Must run AFTER pushes so local quantities reflect server-side deductions.
  Future<void> pullStocks(int companyId) async {
    final res = await dio.get<List<dynamic>>(
      '/Stocks/GetAllStocks',
      queryParameters: {'companyId': companyId},
    );
    final rows = res.data;
    if (rows == null || rows.isEmpty) return;

    final now = DateTime.now().toUtc();
    final companions = rows.map((r) {
      final m = r as Map<String, dynamic>;
      return StocksTableCompanion(
        id:          Value(m['id'] as int),
        productId:   Value(m['productId'] as int),
        warehouseId: Value(m['warehouseId'] as int),
        companyId:   Value(m['companyId'] as int),
        quantity:    Value(((m['quantity'] ?? 0) as num).toDouble()),
        lastModified: Value(now),
      );
    }).toList();

    await db.batch((b) {
      b.insertAllOnConflictUpdate(db.stocksTable, companions);
    });
  }

  // ==========================================================================
  // PULL — Documents from /Document/GetSalesHistory
  // ==========================================================================

  /// Pulls the last 90 days of sales documents from the server and upserts
  /// them into the local Drift DocumentsTable.
  ///
  /// Two cases per server document:
  ///   1. A local row with the same serverId already exists (created at checkout
  ///      on this device) → update the server-assigned document number.
  ///   2. No local row (created on another device) → insert a new 'srv_X'
  ///      sentinel row so the local history is complete across all devices.
  Future<void> pullDocuments(int companyId) async {
    final now  = DateTime.now().toUtc();
    final from = now.subtract(const Duration(days: 90));

    try {
      final res = await dio.get<dynamic>(
        '/Document/GetSalesHistory',
        queryParameters: {
          'companyId': companyId,
          'startDate': from.toIso8601String().substring(0, 10),
          'endDate':   now.toIso8601String().substring(0, 10),
        },
      );

      final list = ((res.data as List?) ?? []).cast<Map<String, dynamic>>();

      for (final d in list) {
        final serverId = (d['id'] as num?)?.toInt() ?? 0;
        if (serverId == 0) continue;

        final dateStr = (d['stockDate'] ?? d['date'] ?? '') as String;
        final date    = DateTime.tryParse(dateStr) ?? now;
        final total   = ((d['total']    as num?)?.toDouble()) ?? 0.0;
        final disc    = ((d['discount'] as num?)?.toDouble()) ?? 0.0;
        final number  = (d['number']      as String?) ?? '';
        final orderNo = d['orderNumber']  as String?;
        final paid    = (d['paidStatus']  as num?)?.toInt() ?? 1;

        // Case 1: already in local DB by serverId — just stamp the number.
        final existing = await (db.select(db.documentsTable)
              ..where((t) => t.serverId.equals(serverId))
              ..limit(1))
            .getSingleOrNull();

        if (existing != null) {
          if (existing.number != number || existing.syncStatus != 'synced') {
            await (db.update(db.documentsTable)
                  ..where((t) => t.localId.equals(existing.localId)))
                .write(DocumentsTableCompanion(
              number:       Value(number),
              syncStatus:   const Value('synced'),
              lastModified: Value(date),
            ));
          }
          continue;
        }

        // Case 2: new document from another device — insert sentinel row.
        // userId / warehouseId are not returned by GetSalesHistory; use 0.
        await db.upsertServerDocument(
          document: DocumentsTableCompanion(
            localId:      Value('srv_$serverId'),
            serverId:     Value(serverId),
            companyId:    Value(companyId),
            userId:       const Value(0),
            warehouseId:  const Value(0),
            number:       Value(number),
            total:        Value(total),
            discount:     Value(disc),
            orderNumber:  Value(orderNo),
            paidStatus:   Value(paid),
            date:         Value(date),
            syncStatus:   const Value('synced'),
            lastModified: Value(date),
          ),
          items: const [],
        );
      }

      await _setLastSync(_kDocuments, now);
    } catch (e) {
      debugPrint('pullDocuments failed: $e — local history preserved.');
    }
  }

  Future<void> pullProductComments(int companyId) async {
    final startedAt = DateTime.now().toUtc();
    final watermark = await _getLastSync(_kProductComments);

    final res = await dio.get<List<dynamic>>(
      '/ProductComments/GetAll',
      queryParameters: _query(companyId, watermark),
    );
    final rows = res.data ?? const [];

    await db.batch((batch) {
      for (final json in rows.cast<Map<String, dynamic>>()) {
        batch.insert(
          db.productCommentsTable,
          ProductCommentsTableCompanion(
            id: Value(json['id'] as int),
            companyId: Value(json['companyId'] as int? ?? companyId),
            productId: Value(json['productId'] as int? ?? 0),
            comment: Value(json['comment'] as String? ?? ''),
            lastModified: Value(_parseLastModified(json['lastModified'])),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    await _setLastSync(_kProductComments, startedAt);
  }

  /// Drains the [PendingUserOpsTable] by replaying each queued write against
  /// the server. Called during [sync] after all order/cash pushes so user-state
  /// changes (toggle, edit, security-key level) land before master-data pull
  /// overwrites the Drift rows with authoritative server values.
  ///
  /// Each op is attempted independently; a failure leaves the row for the next
  /// sync retry. On success the row is deleted.
  Future<void> pushPendingUserOps(int companyId) async {
    final ops = await (db.select(db.pendingUserOpsTable)
          ..where((t) => t.companyId.equals(companyId)))
        .get();
    if (ops.isEmpty) return;

    for (final op in ops) {
      try {
        final payload = jsonDecode(op.payload) as Map<String, dynamic>;
        switch (op.operation) {
          case 'toggle_user':
            await dio.patch(
              '/Users/UpdateUser',
              queryParameters: {'companyId': companyId},
              data: {
                'id': payload['userId'],
                'isEnabled': payload['isEnabled'],
              },
            );
          case 'update_user':
            await dio.patch(
              '/Users/UpdateUser',
              queryParameters: {'companyId': companyId},
              data: payload,
            );
          case 'update_security_key':
            await dio.patch(
              '/SecurityKeys/Update',
              queryParameters: {'companyId': companyId},
              data: {
                'name': payload['name'],
                'level': payload['level'],
              },
            );
          default:
            debugPrint('pushPendingUserOps: unknown op "${op.operation}"');
        }
        // Success — remove from queue.
        await (db.delete(db.pendingUserOpsTable)
              ..where((t) => t.id.equals(op.id)))
            .go();
      } on DioException {
        // Still offline or transient error — leave the row for next retry.
        debugPrint(
            'pushPendingUserOps: op ${op.id} (${op.operation}) failed — will retry');
      }
    }
  }

  /// Fetches all security key rules from the server and does a full replace in
  /// Drift (delete-old + bulk-insert-new inside a transaction). No watermark
  /// is used because the table is tiny (< 20 rows) and the endpoint does not
  /// support `modifiedAfter`. Failures are silently swallowed so a network
  /// drop never breaks the sync pipeline — cached rules stay in place.
  Future<void> pullSecurityKeys(int companyId) async {
    try {
      final res = await dio.get<List<dynamic>>(
        '/SecurityKeys/GetAll',
        queryParameters: {'companyId': companyId},
      );
      final rows = (res.data ?? const []).cast<Map<String, dynamic>>();

      await db.transaction(() async {
        await (db.delete(db.securityKeysTable)
              ..where((t) => t.companyId.equals(companyId)))
            .go();
        if (rows.isNotEmpty) {
          await db.batch((b) {
            b.insertAll(
              db.securityKeysTable,
              rows.map((j) => SecurityKeysTableCompanion(
                    companyId: Value(companyId),
                    name: Value(j['name'] as String? ?? ''),
                    level: Value((j['level'] as num?)?.toInt() ?? 1),
                  )),
            );
          });
        }
      });
    } on DioException {
      // Offline or server error — leave existing cached rules intact.
    }
  }

  Future<void> pullPromotions(int companyId) async {
    final startedAt = DateTime.now().toUtc();
    final watermark = await _getLastSync(_kPromotions);

    final res = await dio.get<List<dynamic>>(
      '/Promotions/GetAll',
      queryParameters: _query(companyId, watermark),
    );
    final rows = (res.data ?? const []).cast<Map<String, dynamic>>();

    for (final json in rows) {
      final promoId = (json['id'] as num?)?.toInt() ?? 0;

      // Don't overwrite rows that have unsync-ed local edits.
      final existing = await (db.select(db.promotionsTable)
            ..where((t) => t.id.equals(promoId)))
          .getSingleOrNull();
      if (existing != null && existing.syncStatus != 'synced') continue;

      await db.transaction(() async {
        await db.into(db.promotionsTable).insertOnConflictUpdate(
              PromotionsTableCompanion(
                id: Value(promoId),
                companyId: Value(json['companyId'] as int? ?? companyId),
                name: Value(json['name'] as String? ?? 'Unnamed'),
                daysOfWeek: Value(json['daysOfWeek'] as int? ?? 127),
                isEnabled: Value(json['isEnabled'] as bool? ?? true),
                startDate: Value(_parseNullableDate(json['startDate'])),
                startTime: Value(
                    (json['startTime'] as String?)?.isEmpty == true
                        ? null
                        : json['startTime'] as String?),
                endDate: Value(_parseNullableDate(json['endDate'])),
                endTime: Value(
                    (json['endTime'] as String?)?.isEmpty == true
                        ? null
                        : json['endTime'] as String?),
                lastModified: Value(_parseLastModified(json['lastModified'])),
                syncStatus: const Value('synced'),
              ),
            );
        // Replace items for this promotion with the server version.
        await (db.delete(db.promotionItemsTable)
              ..where((t) => t.promotionId.equals(promoId)))
            .go();
        final items =
            ((json['items'] as List<dynamic>?) ?? []).cast<Map<String, dynamic>>();
        for (final item in items) {
          await db.into(db.promotionItemsTable).insertOnConflictUpdate(
                PromotionItemsTableCompanion(
                  id: Value((item['id'] as num?)?.toInt() ?? 0),
                  promotionId: Value(promoId),
                  productId: Value((item['productId'] as num?)?.toInt() ?? 0),
                  discountType:
                      Value((item['discountType'] as num?)?.toInt() ?? 0),
                  priceType: Value((item['priceType'] as num?)?.toInt() ?? 0),
                  value: Value((item['value'] as num?)?.toDouble() ?? 0),
                  isConditional:
                      Value(item['isConditional'] as bool? ?? false),
                  quantity:
                      Value((item['quantity'] as num?)?.toDouble() ?? 1),
                  conditionType:
                      Value((item['conditionType'] as num?)?.toInt() ?? 0),
                  quantityLimit:
                      Value((item['quantityLimit'] as num?)?.toDouble() ?? 0),
                ),
              );
        }
      });
    }

    await _setLastSync(_kPromotions, startedAt);
  }

  /// Pushes every pending promotion write (create / update / delete) to the
  /// server. Runs in [sync] after product ops so any newly-created products
  /// referenced by promotion items already exist server-side.
  Future<void> pushPendingPromotionOps(int companyId) async {
    final pending = await (db.select(db.promotionsTable)
          ..where((t) => t.companyId.equals(companyId))
          ..where((t) => t.syncStatus.isNotIn(['synced'])))
        .get();

    for (final p in pending) {
      try {
        final localItems = await (db.select(db.promotionItemsTable)
              ..where((t) => t.promotionId.equals(p.id)))
            .get();

        switch (p.syncStatus) {
          case 'pending_create':
            final body = {
              'name': p.name,
              'daysOfWeek': p.daysOfWeek,
              'startDate': p.startDate?.toUtc().toIso8601String(),
              'startTime': p.startTime,
              'endDate': p.endDate?.toUtc().toIso8601String(),
              'endTime': p.endTime,
              'items': localItems
                  .map((i) => {
                        'productId': i.productId,
                        'discountType': i.discountType,
                        'priceType': i.priceType,
                        'value': i.value,
                        'isConditional': i.isConditional,
                        'quantity': i.quantity,
                        'conditionType': i.conditionType,
                        'quantityLimit': i.quantityLimit,
                      })
                  .toList(),
            };
            final res = await dio.post<dynamic>(
              '/Promotions/Add',
              queryParameters: {'companyId': companyId},
              data: body,
            );
            final serverJson = res.data as Map<String, dynamic>;
            final serverId = (serverJson['id'] as num?)?.toInt() ?? 0;
            final serverItems = ((serverJson['items'] as List<dynamic>?) ?? [])
                .cast<Map<String, dynamic>>();
            await db.transaction(() async {
              await (db.delete(db.promotionsTable)
                    ..where((t) => t.id.equals(p.id)))
                  .go();
              await (db.delete(db.promotionItemsTable)
                    ..where((t) => t.promotionId.equals(p.id)))
                  .go();
              await db.into(db.promotionsTable).insertOnConflictUpdate(
                    PromotionsTableCompanion(
                      id: Value(serverId),
                      companyId: Value(p.companyId),
                      name: Value(p.name),
                      daysOfWeek: Value(p.daysOfWeek),
                      isEnabled: Value(p.isEnabled),
                      startDate: Value(p.startDate),
                      startTime: Value(p.startTime),
                      endDate: Value(p.endDate),
                      endTime: Value(p.endTime),
                      lastModified: Value(DateTime.now().toUtc()),
                      syncStatus: const Value('synced'),
                    ),
                  );
              for (final item in serverItems) {
                await db.into(db.promotionItemsTable).insertOnConflictUpdate(
                      PromotionItemsTableCompanion(
                        id: Value((item['id'] as num?)?.toInt() ?? 0),
                        promotionId: Value(serverId),
                        productId:
                            Value((item['productId'] as num?)?.toInt() ?? 0),
                        discountType:
                            Value((item['discountType'] as num?)?.toInt() ?? 0),
                        priceType:
                            Value((item['priceType'] as num?)?.toInt() ?? 0),
                        value:
                            Value((item['value'] as num?)?.toDouble() ?? 0),
                        isConditional:
                            Value(item['isConditional'] as bool? ?? false),
                        quantity:
                            Value((item['quantity'] as num?)?.toDouble() ?? 1),
                        conditionType:
                            Value((item['conditionType'] as num?)?.toInt() ?? 0),
                        quantityLimit:
                            Value((item['quantityLimit'] as num?)?.toDouble() ?? 0),
                      ),
                    );
              }
            });

          case 'pending_update':
            final body = {
              'id': p.id,
              'name': p.name,
              'daysOfWeek': p.daysOfWeek,
              'isEnabled': p.isEnabled,
              'startDate': p.startDate?.toUtc().toIso8601String(),
              'startTime': p.startTime,
              'endDate': p.endDate?.toUtc().toIso8601String(),
              'endTime': p.endTime,
              'items': localItems
                  .map((i) => {
                        'id': i.id > 0 ? i.id : 0,
                        'productId': i.productId,
                        'discountType': i.discountType,
                        'priceType': i.priceType,
                        'value': i.value,
                        'isConditional': i.isConditional,
                        'quantity': i.quantity,
                        'conditionType': i.conditionType,
                        'quantityLimit': i.quantityLimit,
                      })
                  .toList(),
            };
            await dio.put<dynamic>(
              '/Promotions/Update',
              queryParameters: {'companyId': companyId},
              data: body,
            );
            await (db.update(db.promotionsTable)
                  ..where((t) => t.id.equals(p.id)))
                .write(const PromotionsTableCompanion(
              syncStatus: Value('synced'),
            ));

          case 'pending_delete':
            await dio.delete<dynamic>(
              '/Promotions/Delete',
              queryParameters: {'id': p.id, 'companyId': companyId},
            );
            await (db.delete(db.promotionItemsTable)
                  ..where((t) => t.promotionId.equals(p.id)))
                .go();
            await (db.delete(db.promotionsTable)
                  ..where((t) => t.id.equals(p.id)))
                .go();
        }
      } catch (e) {
        debugPrint(
            'pushPendingPromotionOps: promo ${p.id} (${p.syncStatus}) failed — $e');
        try {
          await (db.update(db.promotionsTable)
                ..where((t) => t.id.equals(p.id)))
              .write(PromotionsTableCompanion(syncError: Value(e.toString())));
        } catch (_) {}
      }
    }
  }

  // ==========================================================================
  // APP PROPERTIES — bidirectional, per-key timestamp guard.
  //
  // Plan rule: never blindly overwrite. The user can change a setting locally
  // (offline) and the push hasn't happened yet — a stale server row arriving
  // via pull must NOT clobber it.
  //
  // We compare `serverLastModified` against `localLastModified` per row and
  // upsert only when the server is strictly newer.
  // ==========================================================================
  Future<void> pullAppProperties(int companyId) async {
    final startedAt = DateTime.now().toUtc();
    final watermark = await _getLastSync(_kAppProperties);

    final res = await dio.get<List<dynamic>>(
      '/ApplicationProperties/GetAll',
      queryParameters: _query(companyId, watermark),
    );
    final rows = res.data ?? const [];

    for (final json in rows.cast<Map<String, dynamic>>()) {
      final id = json['id'] as int;
      final serverLastModified = _parseLastModified(json['lastModified']);

      final localRow = await (db.select(db.appPropertiesTable)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      if (localRow != null &&
          !serverLastModified.isAfter(localRow.lastModified)) {
        // Local copy is equal or newer — preserve it.
        continue;
      }

      await db.into(db.appPropertiesTable).insertOnConflictUpdate(
            AppPropertiesTableCompanion(
              id: Value(id),
              companyId: Value(json['companyId'] as int? ?? companyId),
              name: Value(json['name'] as String? ?? ''),
              value: Value(json['value'] as String?),
              lastModified: Value(serverLastModified),
            ),
          );
    }

    await _setLastSync(_kAppProperties, startedAt);
  }
}

/// Converts an empty-or-whitespace string to null so Drift never stores "".
String? _nullIfBlank(String? s) {
  if (s == null) return null;
  final t = s.trim();
  return t.isEmpty ? null : t;
}
