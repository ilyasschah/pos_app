import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:uuid/uuid.dart';

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
  static const _kDocuments = 'documents';
  static const _kLoyaltyCards = 'loyalty_cards';

  Future<void> sync(int companyId) async {
    await pushPendingProductGroupOps(companyId);
    await pushPendingProductOps(companyId);
    await pushPendingBarcodeOps(companyId);
    await pushPendingPromotionOps(companyId);
    await pushPendingOpenOrders(companyId);
    await pushPendingOrders(companyId);
    // Manual document editor: create/update/delete headers + their line items.
    // Runs before paid-status/payments so a locally-created document already
    // carries its server id when those are pushed.
    await pushPendingDocuments(companyId);
    await pushPendingDocumentItems(companyId);
    // Paid-status + standalone payment edits made in the document editor. Run
    // after pushPendingOrders so locally-created documents already carry their
    // server id before their payments are pushed.
    await pushPendingPaidStatus(companyId);
    await pushPendingPayments(companyId);
    await pushPendingVoids(companyId);
    await pushPendingCashMovements(companyId);
    await pushPendingZReports(companyId);
    await pushPendingUserOps(companyId);
    await pushPendingCustomerOps(companyId);
    await pushPendingCustomerDiscountOps(companyId);
    await pushPendingLoyaltyCardOps(companyId);
    await pushPendingShifts(companyId);
    await pushPendingTimeClockEntries(companyId);
    await pushPendingAppProperties(companyId);
    // Warehouse + stock ordering matters:
    //  1. create/update warehouses first (a stock "move" may target a brand-new
    //     warehouse that must exist on the server),
    //  2. then push the stock revoke/move ops (empties a warehouse),
    //  3. then delete warehouses (the backend FK rejects deleting one that
    //     still holds stock).
    await pushPendingWarehouseOps(companyId, deletePhase: false);
    await pushPendingStockOps(companyId);
    // Offline stock + stock-control edits made on the Stock screen.
    await pushPendingStocks(companyId);
    await pushPendingStockControls(companyId);
    await pushPendingProductTaxes(companyId);
    await pushPendingWarehouseOps(companyId, deletePhase: true);
    await pullMasterData(companyId);
    await pullDocuments(companyId);
  }

  // ==========================================================================
  // PUSH — app-property edits made offline. Two cases:
  //  • temp negative-id rows  → brand-new settings (e.g. App.DefaultScreen)
  //    that never reached the server → POST /ApplicationProperties/Add.
  //  • positive-id 'pending' rows → existing settings edited offline →
  //    PATCH /ApplicationProperties/Update.
  // Without this, offline setting changes would live only in local Drift.
  // ==========================================================================
  Future<void> pushPendingAppProperties(int companyId) async {
    // ── New settings created offline (temp negative ids) → /Add ────────────
    final newRows = await (db.select(db.appPropertiesTable)
          ..where((t) => t.companyId.equals(companyId))
          ..where((t) => t.id.isSmallerThanValue(0)))
        .get();

    for (final p in newRows) {
      try {
        final res = await dio.post<dynamic>(
          '/ApplicationProperties/Add',
          queryParameters: {'companyId': companyId},
          data: {'name': p.name, 'value': p.value ?? ''},
        );

        // If /Add echoes back the created row with its server id, swap the
        // temp row for the real one immediately (robust even if the following
        // pull fails). Otherwise leave the temp row for pullAppProperties to
        // reconcile (its dedup drops temp rows once the server row arrives).
        final data = res.data;
        final newId = data is Map<String, dynamic> ? data['id'] as int? : null;
        if (newId != null) {
          await db.into(db.appPropertiesTable).insertOnConflictUpdate(
                AppPropertiesTableCompanion(
                  id: Value(newId),
                  companyId: Value(companyId),
                  name: Value(p.name),
                  value: Value(p.value),
                  lastModified: Value(DateTime.now().toUtc()),
                  syncStatus: const Value('synced'),
                ),
              );
          await (db.delete(db.appPropertiesTable)
                ..where((t) => t.id.equals(p.id)))
              .go();
        }
      } catch (e) {
        debugPrint('pushPendingAppProperties (add): ${p.name} failed — $e');
        // Leave the temp row; next sync retries.
      }
    }

    // ── Existing settings edited offline (positive id, 'pending') → /Update ─
    final editedRows = await (db.select(db.appPropertiesTable)
          ..where((t) => t.companyId.equals(companyId))
          ..where((t) => t.id.isBiggerThanValue(0))
          ..where((t) => t.syncStatus.equals('pending')))
        .get();

    for (final p in editedRows) {
      try {
        await dio.patch<dynamic>(
          '/ApplicationProperties/Update',
          queryParameters: {'companyId': companyId},
          data: {'id': p.id, 'newValue': p.value ?? ''},
        );
        await (db.update(db.appPropertiesTable)
              ..where((t) => t.id.equals(p.id)))
            .write(const AppPropertiesTableCompanion(
          syncStatus: Value('synced'),
        ));
      } catch (e) {
        debugPrint('pushPendingAppProperties (update): ${p.name} failed — $e');
        // Leave it 'pending'; next sync retries.
      }
    }
  }

  Future<void> pullMasterData(int companyId) async {
    await pullProducts(companyId);
    await pullTaxes(companyId);
    await pullFloorPlans(companyId);
    await pullFloorPlanTables(companyId);
    await pullUsers(companyId);
    await pullAppProperties(companyId);
    await pullProductGroups(companyId);
    await pullPaymentTypes(companyId);
    await pullCustomers(companyId);
    await pullPromotions(companyId);
    await pullProductComments(companyId);
    await pullSecurityKeys(companyId);
    await pullCompany(companyId);
    await pullStocks(companyId);
    await pullWarehouses(companyId);
    await pullLoyaltyCards(companyId);
    await pullStartingCash(companyId);
    await pullBookings(companyId);
    await pullDocumentTypes(companyId);
    await pullDocumentCategories(companyId);
    await pullVoidReasons(companyId);
    await pullStockControls(companyId);
    await pullProductTaxes(companyId);
    await pullBarcodes(companyId);
  }

  // ==========================================================================
  // PRODUCT TAXES — offline-first bulk pull + per-assignment push.
  // ==========================================================================
  Future<void> pullProductTaxes(int companyId) async {
    final res = await dio.get<List<dynamic>>(
      '/ProductTaxes/GetAll',
      queryParameters: {'companyId': companyId},
    );
    final rows = res.data;
    if (rows == null) return;

    final serverPairs = <String>{};
    for (final j in rows.cast<Map<String, dynamic>>()) {
      final productId = (j['productId'] as num?)?.toInt() ?? 0;
      final taxId = (j['taxId'] as num?)?.toInt() ?? 0;
      serverPairs.add('$productId:$taxId');
      await db.upsertSyncedProductTax(ProductTaxesTableCompanion(
        productId: Value(productId),
        taxId: Value(taxId),
        companyId: Value(companyId),
        syncStatus: const Value('synced'),
      ));
    }

    // Drop synced assignments removed on the server; keep local pending edits.
    for (final r in await db.getProductTaxesBySyncStatus(companyId, 'synced')) {
      if (!serverPairs.contains('${r.productId}:${r.taxId}')) {
        await db.hardDeleteProductTax(r.productId, r.taxId);
      }
    }
  }

  Future<void> pushPendingProductTaxes(int companyId) async {
    for (final r
        in await db.getProductTaxesBySyncStatus(companyId, 'pending_create')) {
      try {
        await dio.post<dynamic>(
          '/ProductTaxes/Add',
          queryParameters: {'companyId': companyId},
          data: {'productId': r.productId, 'taxId': r.taxId},
        );
        await db.markProductTaxSynced(r.productId, r.taxId);
      } catch (e) {
        debugPrint('pushPendingProductTaxes (add) ${r.productId} failed — $e');
      }
    }
    for (final r
        in await db.getProductTaxesBySyncStatus(companyId, 'pending_delete')) {
      try {
        await dio.delete<dynamic>(
          '/ProductTaxes/Delete',
          queryParameters: {
            'productId': r.productId,
            'taxId': r.taxId,
            'companyId': companyId,
          },
        );
        await db.hardDeleteProductTax(r.productId, r.taxId);
      } catch (e) {
        debugPrint('pushPendingProductTaxes (delete) ${r.productId} failed — $e');
      }
    }
  }

  // ==========================================================================
  // BARCODES — bulk pull so the product editor reads them offline without a
  // per-open /Barcodes/GetByProductId fetch. Local pending edits are preserved;
  // pushes are handled by pushPendingBarcodeOps.
  // ==========================================================================
  Future<void> pullBarcodes(int companyId) async {
    final res = await dio.get<List<dynamic>>(
      '/Barcodes/GetAllBarCodeProductName',
      queryParameters: {'companyId': companyId},
    );
    final rows = res.data;
    if (rows == null) return;

    await db.transaction(() async {
      // Replace the synced cache; keep pending_create / pending_delete.
      await (db.delete(db.barcodesTable)
            ..where((t) => t.companyId.equals(companyId))
            ..where((t) => t.syncStatus.equals('synced')))
          .go();
      for (final b in rows.cast<Map<String, dynamic>>()) {
        await db.into(db.barcodesTable).insert(BarcodesTableCompanion(
              localId: Value(const Uuid().v4()),
              serverId: Value((b['id'] as num?)?.toInt() ?? 0),
              productId: Value((b['productId'] as num?)?.toInt() ?? 0),
              companyId: Value(companyId),
              value: Value(b['value'] as String? ?? ''),
              syncStatus: const Value('synced'),
            ));
      }
    });
  }

  Future<void> pullVoidReasons(int companyId) async {
    try {
      final res = await dio.get<dynamic>('/VoidReasons/GetAll',
          queryParameters: {'companyId': companyId});
      final list = ((res.data as List?) ?? const []).cast<Map<String, dynamic>>();
      final rows = list
          .map((j) => VoidReasonsTableCompanion(
                id: Value((j['id'] as num?)?.toInt() ?? 0),
                companyId: Value(companyId),
                name: Value((j['name'] as String?) ?? ''),
                rank: Value((j['rank'] as num?)?.toInt() ?? 0),
                lastModified: Value(DateTime.now().toUtc()),
              ))
          .toList();
      await db.replaceVoidReasons(companyId, rows);
    } catch (e) {
      debugPrint('pullVoidReasons failed: $e — local cache preserved.');
    }
  }

  // ==========================================================================
  // PULL — Document types + categories (full replace). Small, rarely-changing
  // master data that the document editor's type picker needs offline.
  // ==========================================================================
  Future<void> pullDocumentTypes(int companyId) async {
    try {
      final res = await dio.get<dynamic>('/DocumentType/GetAll');
      final list = ((res.data as List?) ?? const []).cast<Map<String, dynamic>>();
      final rows = list
          .map((j) => DocumentTypesTableCompanion(
                id: Value((j['id'] as num?)?.toInt() ?? 0),
                name: Value((j['name'] as String?) ?? ''),
                code: Value(j['code'] as String?),
                documentCategoryId:
                    Value((j['documentCategoryId'] as num?)?.toInt()),
                warehouseId: Value((j['warehouseId'] as num?)?.toInt()),
                lastModified: Value(DateTime.now().toUtc()),
              ))
          .toList();
      if (rows.isNotEmpty) await db.upsertDocumentTypes(rows);
    } catch (e) {
      debugPrint('pullDocumentTypes failed: $e — local cache preserved.');
    }
  }

  Future<void> pullDocumentCategories(int companyId) async {
    try {
      final res = await dio.get<dynamic>('/DocumentCategory/GetAll',
          queryParameters: {'companyId': companyId});
      final list = ((res.data as List?) ?? const []).cast<Map<String, dynamic>>();
      final rows = list
          .map((j) => DocumentCategoriesTableCompanion(
                id: Value((j['id'] as num?)?.toInt() ?? 0),
                companyId: Value(companyId),
                name: Value((j['name'] as String?) ?? ''),
                lastModified: Value(DateTime.now().toUtc()),
              ))
          .toList();
      if (rows.isNotEmpty) await db.upsertDocumentCategories(rows);
    } catch (e) {
      debugPrint('pullDocumentCategories failed: $e — local cache preserved.');
    }
  }

  // ==========================================================================
  // BOOKINGS — full-replace pull.
  //
  // Unlike the delta pulls above, bookings are wiped and re-inserted for the
  // company on every sync. Two reasons: the calendar must reflect server-side
  // deletes (a `modifiedAfter` delta never reports a removed row), and the
  // dataset is small (a day/week of reservations). The wipe + re-insert run in
  // a single transaction so the Drift watch stream emits exactly once, with no
  // empty-list flicker in between.
  // ==========================================================================
  Future<void> pullBookings(int companyId) async {
    final res = await dio.get<List<dynamic>>(
      '/Bookings/GetAll',
      queryParameters: {'companyId': companyId},
    );
    final rows = res.data ?? const [];

    await db.transaction(() async {
      await (db.delete(db.bookingsTable)
            ..where((t) => t.companyId.equals(companyId)))
          .go();
      await db.batch((batch) {
        for (final json in rows.cast<Map<String, dynamic>>()) {
          final tableIds = (json['tableIds'] as List<dynamic>?)
                  ?.map((e) => (e as num).toInt())
                  .toList() ??
              const <int>[];
          batch.insert(
            db.bookingsTable,
            BookingsTableCompanion(
              id: Value(json['id'] as int),
              companyId: Value(json['companyId'] as int? ?? companyId),
              customerId: Value(json['customerId'] as int?),
              userId: Value(json['userId'] as int?),
              reservationName: Value(json['reservationName'] as String? ?? ''),
              tableIdsJson: Value(jsonEncode(tableIds)),
              documentId: Value(json['documentId'] as int?),
              posOrderId: Value(json['posOrderId'] as int?),
              startTime: Value(DateTime.parse(json['startTime'] as String)),
              endTime: Value(DateTime.parse(json['endTime'] as String)),
              guestCount: Value(json['guestCount'] as int? ?? 1),
              status: Value(json['status'] as int? ?? 0),
              note: Value(json['note'] as String?),
              lastModified: Value(_parseLastModified(json['lastModified'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    });
  }

  Future<void> pushPendingOrders(int companyId) async {
    final pending = await db.getPendingOrders();
    if (pending.isEmpty) return;

    final payload = {'orders': pending.map(_orderToBatchJson).toList()};

    final List<dynamic> results;
    try {
      final res = await dio.post<Map<String, dynamic>>(
        '/PosOrder/BatchSync',
        queryParameters: {'companyId': companyId},
        data: payload,
      );
      results = (res.data?['results'] as List<dynamic>?) ?? const [];
    } catch (_) {
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
            await db.linkDocumentToServer(localId, serverId);
            await db.deleteCompletedOrder(localId);
          } else {
            await db.markOrderFailed(
              localId,
              'Server returned success without a serverId.',
            );
          }
        } else {
          final error = r['error'] as String? ?? 'Unknown server error.';
          await db.markOrderFailed(localId, error);
        }
      } catch (_) {}
    }
  }

  Map<String, dynamic> _orderToBatchJson(PosOrderWithItems o) {
    return {
      'localId': o.order.localId,
      'existingServerId': o.order.serverId,
      'paymentTypeId': o.order.paymentTypeId,
      'amountPaid': o.order.amountPaid,
      'orderTotal': o.order.total ?? 0,
      'order': {
        'userId': o.order.userId,
        'number': o.order.orderName,
        'discount': o.order.discount,
        'discountType': o.order.discountType,
        'total': o.order.total,
        'customerId': o.order.customerId,
        'serviceType': o.order.serviceType,
        'serviceStatus': o.order.serviceStatus,
        'floorPlanTableId': o.order.tableId,
        'warehouseId': o.order.warehouseId,
      },
      'items': o.items.map((item) {
        final List<Map<String, dynamic>> taxEntries = item.taxesJson != null
            ? (jsonDecode(item.taxesJson!) as List).cast<Map<String, dynamic>>()
            : const [];
        final appliedTaxIds = taxEntries.map((t) => t['id'] as int).toList();
        final taxes = taxEntries
            .map((t) => {'taxId': t['id'] as int, 'amount': t['amount']})
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

  Future<void> pushPendingOpenOrders(int companyId) async {
    final pending = await db.getPendingOpenOrders();
    if (pending.isEmpty) return;

    for (final o in pending) {
      try {
        int serverId;
        if (o.order.serverId == null) {
          final res = await dio.post<dynamic>(
            '/PosOrder/Create',
            queryParameters: {'companyId': companyId},
            data: {
              'userId': o.order.userId,
              'number': o.order.orderName ?? 'ORD',
              'discount': o.order.discount,
              'discountType': o.order.discountType,
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
              : (data['id'] ??
                        data['Id'] ??
                        data['posOrderId'] ??
                        data['PosOrderId'])
                    as int;

          await db.setServerId(o.order.localId, serverId);
        } else {
          serverId = o.order.serverId!;
          await dio.patch<dynamic>(
            '/PosOrder/Update',
            queryParameters: {'companyId': companyId},
            data: {
              "id": serverId,
              "userId": o.order.userId,
              "number": o.order.orderName,
              "discount": o.order.discount,
              "discountType": o.order.discountType,
              "total": o.order.total,
              "customerId": o.order.customerId,
              "serviceType": o.order.serviceType,
              "serviceStatus": o.order.serviceStatus,
              "floorPlanTableId": o.order.tableId,
              "warehouseId": o.order.warehouseId,
            },
          );
        }

        if (o.items.isNotEmpty) {
          final itemsJson = o.items.map((item) {
            final List<Map<String, dynamic>> taxEntries = item.taxesJson != null
                ? (jsonDecode(item.taxesJson!) as List)
                      .cast<Map<String, dynamic>>()
                : const [];
            final appliedTaxIds = taxEntries
                .map((t) => t['id'] as int)
                .toList();
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
          }).toList();

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

  Future<void> pushPendingVoids(int companyId) async {
    final pending = await db.getPendingVoids();
    if (pending.isEmpty) return;

    for (final v in pending) {
      try {
        final items = (jsonDecode(v.itemsJson) as List)
            .cast<Map<String, dynamic>>();

        // Step 1: post a PosVoid row for every voided item.
        for (final item in items) {
          await dio.post<dynamic>(
            '/PosVoids/Add',
            queryParameters: {
              'companyId': companyId,
              'orderNumber': v.orderNumber,
              'userId': v.userId,
              'userName': (item['userName'] ?? '') as String,
              'productId': item['productId'] as int,
              'productName': (item['productName'] ?? '') as String,
              'roundNumber': (item['roundNumber'] ?? 1) as int,
              'quantity': item['quantity'],
              'price': item['price'],
              'discount': (item['discount'] ?? 0),
              'discountType': (item['discountType'] ?? 0) as int,
              'total': item['total'],
              'voidedById': v.userId,
              'voidedByName': (item['userName'] ?? '') as String,
              if (v.reason != null) 'reason': v.reason,
            },
          );
        }

        // Step 2: delete the server PosOrder (void = remove the open order).
        await dio.delete<dynamic>(
          '/PosOrder/Delete',
          queryParameters: {
            'id': v.serverOrderId,
            'companyId': companyId,
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
          queryParameters: {'companyId': companyId, 'userId': report.userId},
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
    final pending =
        await (db.select(db.productsTable)
              ..where((t) => t.companyId.equals(companyId))
              ..where(
                (t) => t.syncStatus.isIn([
                  'pending_create',
                  'pending_update',
                  'pending_delete',
                ]),
              ))
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
            if (realId == null)
              throw Exception('Server returned no id for product create');

            // Replace the temp row: delete by temp id, insert with real id, and
            // cascade the id swap to product-keyed tables (taxes, stock rules,
            // barcodes, stocks) so their pending pushes use the real id.
            await db.transaction(() async {
              await (db.delete(
                db.productsTable,
              )..where((t) => t.id.equals(p.id))).go();
              await db
                  .into(db.productsTable)
                  .insert(
                    ProductsTableCompanion(
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
                    ),
                  );
              await db.remapProductId(p.id, realId);
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
            await (db.update(
              db.productsTable,
            )..where((t) => t.id.equals(p.id))).write(
              const ProductsTableCompanion(
                syncStatus: Value('synced'),
                syncError: Value(null),
              ),
            );

          // ── DELETE ──────────────────────────────────────────────────────
          case 'pending_delete':
            await dio.delete<dynamic>(
              '/Products/Delete',
              queryParameters: {'id': p.id, 'companyId': companyId},
            );
            await (db.delete(
              db.productsTable,
            )..where((t) => t.id.equals(p.id))).go();
        }
      } catch (e) {
        debugPrint(
          'pushPendingProductOps: product ${p.id} (${p.syncStatus}) failed — $e',
        );
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
    final pending =
        await (db.select(db.barcodesTable)
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
            final serverId = (res.data is Map ? res.data['id'] : null) as int?;
            await (db.update(
              db.barcodesTable,
            )..where((t) => t.localId.equals(b.localId))).write(
              BarcodesTableCompanion(
                serverId: Value(serverId),
                syncStatus: const Value('synced'),
              ),
            );

          case 'pending_delete':
            if (b.serverId != null) {
              await dio.delete<dynamic>(
                '/Barcodes/Delete',
                queryParameters: {'id': b.serverId, 'companyId': companyId},
              );
            }
            await (db.delete(
              db.barcodesTable,
            )..where((t) => t.localId.equals(b.localId))).go();
        }
      } catch (e) {
        debugPrint(
          'pushPendingBarcodeOps: barcode ${b.localId} (${b.syncStatus}) failed — $e',
        );
      }
    }
  }

  // ==========================================================================
  // SYNC META HELPERS
  // ==========================================================================

  Future<DateTime?> _getLastSync(String entity) async {
    final row = await (db.select(
      db.syncMetaTable,
    )..where((t) => t.entity.equals(entity))).getSingleOrNull();
    return row?.lastSyncedAt;
  }

  Future<void> _setLastSync(String entity, DateTime time) async {
    await db
        .into(db.syncMetaTable)
        .insertOnConflictUpdate(
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

      await db
          .into(db.productsTable)
          .insertOnConflictUpdate(
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
              lastPurchasePrice: Value(
                (json['lastPurchasePrice'] as num?)?.toDouble(),
              ),
              dateCreated: Value(_parseNullableDate(json['dateCreated'])),
              dateUpdated: Value(_parseNullableDate(json['dateUpdated'])),
              isPriceChangeAllowed: Value(
                json['isPriceChangeAllowed'] as bool? ?? false,
              ),
              isUsingDefaultQuantity: Value(
                json['isUsingDefaultQuantity'] as bool? ?? true,
              ),
              isTaxInclusivePrice: Value(
                json['isTaxInclusivePrice'] as bool? ?? true,
              ),
              isEnabled: Value(json['isEnabled'] as bool? ?? true),
              lastModified: Value(_parseLastModified(json['lastModified'])),
            ),
          );
    }

    await _setLastSync(_kProducts, startedAt);

    debugPrint(
      'pullProducts: saved $productCount products. '
      'Successfully cached $imageSuccessCount images.',
    );
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
      queryParameters: {..._query(companyId, watermark), 'deviceId': deviceId},
    );
    final rows = res.data ?? const [];

    await db.batch((batch) {
      for (final json in rows.cast<Map<String, dynamic>>()) {
        // Hash-only — never persist a raw `password` field even if the
        // server slips up and sends one. (Plan rule.)
        final hashedPin = json['hashedPin'] as String?;
        final firstName = _nullIfBlank(json['firstName'] as String?);
        final lastName = _nullIfBlank(json['lastName'] as String?);
        final username = _nullIfBlank(json['username'] as String?);
        final displayName = [
          firstName,
          lastName,
        ].whereType<String>().join(' ').trim();

        batch.insert(
          db.usersTable,
          UsersTableCompanion(
            id: Value(json['id'] as int),
            companyId: Value(json['companyId'] as int? ?? companyId),
            name: Value(displayName.isEmpty ? (username ?? '') : displayName),
            firstName: Value(firstName),
            lastName: Value(lastName),
            username: Value(username),
            email: Value(json['email'] as String?),
            pinHash: Value(hashedPin),
            role: Value(json['accessLevel'] as int? ?? 0),
            isEnabled: Value(json['isEnabled'] as bool? ?? true),
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
    final pending =
        await (db.select(db.productGroupsTable)
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
                  final renamed = newPath.replaceAll(
                    '${g.id}_image',
                    '${serverId}_image',
                  );
                  await File(newPath).rename(renamed);
                  newPath = renamed;
                } catch (_) {}
              }
              await db.transaction(() async {
                await (db.delete(
                  db.productGroupsTable,
                )..where((t) => t.id.equals(g.id))).go();
                await db
                    .into(db.productGroupsTable)
                    .insertOnConflictUpdate(
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
            await (db.update(
              db.productGroupsTable,
            )..where((t) => t.id.equals(g.id))).write(
              const ProductGroupsTableCompanion(syncStatus: Value('synced')),
            );

          case 'pending_delete':
            await dio.delete<dynamic>(
              '/ProductGroups/Delete',
              queryParameters: {'id': g.id, 'companyId': companyId},
            );
            await (db.delete(
              db.productGroupsTable,
            )..where((t) => t.id.equals(g.id))).go();
        }
      } catch (e) {
        debugPrint(
          'pushPendingProductGroupOps: group ${g.id} (${g.syncStatus}) failed — $e',
        );
        try {
          await (db.update(
            db.productGroupsTable,
          )..where((t) => t.id.equals(g.id))).write(
            ProductGroupsTableCompanion(syncError: Value(e.toString())),
          );
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
      final existing = await (db.select(
        db.productGroupsTable,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
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

      await db
          .into(db.productGroupsTable)
          .insertOnConflictUpdate(
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
      'Successfully cached $imageSuccessCount images.',
    );
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
            isCustomerRequired: Value(
              json['isCustomerRequired'] as bool? ?? false,
            ),
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

  // ==========================================================================
  // PUSH — pending customer creates / updates / deletes
  // ==========================================================================

  /// Pushes all locally-queued customer mutations to the server:
  ///   • pending_create → POST /Customer/AddCustomercommand (temp negative id → real id)
  ///   • pending_update → PATCH /Customer/UpdateCustomercommand
  ///   • pending_delete → DELETE /Customer/DeleteCustomercommand (then hard-delete locally)
  Future<void> pushPendingCustomerOps(int companyId) async {
    final pending =
        await (db.select(db.customersTable)
              ..where((t) => t.companyId.equals(companyId))
              ..where(
                (t) => t.syncStatus.isIn([
                  'pending_create',
                  'pending_update',
                  'pending_delete',
                ]),
              ))
            .get();

    if (pending.isEmpty) return;

    for (final c in pending) {
      try {
        switch (c.syncStatus) {
          case 'pending_create':
            final res = await dio.post<dynamic>(
              '/Customer/AddCustomercommand',
              queryParameters: {'companyId': companyId},
              data: {
                'name': c.name,
                'code': c.code,
                'taxNumber': c.taxNumber,
                'address': c.address,
                'postalCode': c.postalCode,
                'city': c.city,
                'countryId': c.countryId ?? 0,
                'email': c.email,
                'phoneNumber': c.phoneNumber,
                'isEnabled': c.isEnabled,
                'isCustomer': c.isCustomer,
                'isSupplier': c.isSupplier,
                'isTaxExempt': c.isTaxExempt,
                'dueDatePeriod': c.dueDatePeriod ?? 0,
                'streetName': c.streetName,
                'additionalStreetName': c.additionalStreetName,
                'buildingNumber': c.buildingNumber,
                'plotIdentification': c.plotIdentification,
                'citySubdivisionName': c.citySubdivisionName,
              },
            );
            final data = res.data;
            int realId = 0;
            if (data is int)
              realId = data;
            else if (data is Map)
              realId = ((data['id'] ?? data['Id']) as num?)?.toInt() ?? 0;
            if (realId <= 0)
              throw Exception('Server returned no id for customer create');

            // Replace temp row with real id; also update any pending discounts
            // that reference the old temp customer id.
            await db.transaction(() async {
              await (db.delete(
                db.customersTable,
              )..where((t) => t.id.equals(c.id))).go();
              await db
                  .into(db.customersTable)
                  .insert(
                    CustomersTableCompanion(
                      id: Value(realId),
                      companyId: Value(c.companyId),
                      name: Value(c.name),
                      code: Value(c.code),
                      taxNumber: Value(c.taxNumber),
                      address: Value(c.address),
                      postalCode: Value(c.postalCode),
                      city: Value(c.city),
                      countryId: Value(c.countryId),
                      email: Value(c.email),
                      phoneNumber: Value(c.phoneNumber),
                      isEnabled: Value(c.isEnabled),
                      isCustomer: Value(c.isCustomer),
                      isSupplier: Value(c.isSupplier),
                      dueDatePeriod: Value(c.dueDatePeriod),
                      streetName: Value(c.streetName),
                      additionalStreetName: Value(c.additionalStreetName),
                      buildingNumber: Value(c.buildingNumber),
                      plotIdentification: Value(c.plotIdentification),
                      citySubdivisionName: Value(c.citySubdivisionName),
                      isTaxExempt: Value(c.isTaxExempt),
                      lastModified: Value(DateTime.now().toUtc()),
                      syncStatus: const Value('synced'),
                    ),
                  );
              // Update any pending discounts that referenced the temp customer id.
              await (db.update(
                db.customerDiscountsTable,
              )..where((t) => t.customerId.equals(c.id))).write(
                CustomerDiscountsTableCompanion(customerId: Value(realId)),
              );
            });

          case 'pending_update':
            await dio.patch<dynamic>(
              '/Customer/UpdateCustomercommand',
              queryParameters: {'companyId': companyId},
              data: {
                'id': c.id,
                'name': c.name,
                'code': c.code,
                'taxNumber': c.taxNumber,
                'address': c.address,
                'postalCode': c.postalCode,
                'city': c.city,
                'countryId': c.countryId ?? 0,
                'email': c.email,
                'phoneNumber': c.phoneNumber,
                'isEnabled': c.isEnabled,
                'isCustomer': c.isCustomer,
                'isSupplier': c.isSupplier,
                'isTaxExempt': c.isTaxExempt,
                'dueDatePeriod': c.dueDatePeriod ?? 0,
                'streetName': c.streetName,
                'additionalStreetName': c.additionalStreetName,
                'buildingNumber': c.buildingNumber,
                'plotIdentification': c.plotIdentification,
                'citySubdivisionName': c.citySubdivisionName,
              },
            );
            await (db.update(
              db.customersTable,
            )..where((t) => t.id.equals(c.id))).write(
              const CustomersTableCompanion(
                syncStatus: Value('synced'),
                syncError: Value(null),
              ),
            );

          case 'pending_delete':
            await dio.delete<dynamic>(
              '/Customer/DeleteCustomercommand',
              queryParameters: {'id': c.id, 'companyId': companyId},
            );
            await (db.delete(
              db.customerDiscountsTable,
            )..where((t) => t.customerId.equals(c.id))).go();
            await (db.delete(
              db.customersTable,
            )..where((t) => t.id.equals(c.id))).go();
        }
      } catch (e) {
        debugPrint(
          'pushPendingCustomerOps: customer ${c.id} (${c.syncStatus}) failed — $e',
        );
        try {
          await (db.update(db.customersTable)..where((t) => t.id.equals(c.id)))
              .write(CustomersTableCompanion(syncError: Value(e.toString())));
        } catch (_) {}
      }
    }
  }

  /// Pushes all locally-queued customer-discount mutations to the server.
  /// Skips discounts with a negative (temp) customerId — those belong to
  /// customers that haven't been synced yet; [pushPendingCustomerOps] resolves
  /// the real customerId first, so the next sync cycle picks these up.
  Future<void> pushPendingCustomerDiscountOps(int companyId) async {
    final pending =
        await (db.select(db.customerDiscountsTable)
              ..where((t) => t.companyId.equals(companyId))
              ..where(
                (t) => t.syncStatus.isIn([
                  'pending_create',
                  'pending_update',
                  'pending_delete',
                ]),
              ))
            .get();

    if (pending.isEmpty) return;

    for (final d in pending) {
      // Skip if the parent customer hasn't been synced yet (temp negative id).
      if (d.customerId < 0) continue;

      try {
        switch (d.syncStatus) {
          case 'pending_create':
            final res = await dio.post<dynamic>(
              '/CustomerDiscounts/Create',
              queryParameters: {'companyId': companyId},
              data: {
                'customerId': d.customerId,
                'type': d.type,
                'uid': d.uid,
                'value': d.value,
              },
            );
            final data = res.data;
            int realId = 0;
            if (data is Map)
              realId = ((data['id'] ?? data['Id']) as num?)?.toInt() ?? 0;
            await db.transaction(() async {
              await (db.delete(
                db.customerDiscountsTable,
              )..where((t) => t.id.equals(d.id))).go();
              if (realId > 0) {
                await db
                    .into(db.customerDiscountsTable)
                    .insert(
                      CustomerDiscountsTableCompanion(
                        id: Value(realId),
                        companyId: Value(d.companyId),
                        customerId: Value(d.customerId),
                        type: Value(d.type),
                        uid: Value(d.uid),
                        value: Value(d.value),
                        lastModified: Value(DateTime.now().toUtc()),
                        syncStatus: const Value('synced'),
                      ),
                    );
              }
            });

          case 'pending_update':
            await dio.patch<dynamic>(
              '/CustomerDiscounts/Update',
              queryParameters: {'companyId': companyId},
              data: {'id': d.id, 'type': d.type, 'value': d.value},
            );
            await (db.update(
              db.customerDiscountsTable,
            )..where((t) => t.id.equals(d.id))).write(
              const CustomerDiscountsTableCompanion(
                syncStatus: Value('synced'),
                syncError: Value(null),
              ),
            );

          case 'pending_delete':
            if (d.id > 0) {
              await dio.delete<dynamic>(
                '/CustomerDiscounts/Delete',
                queryParameters: {'id': d.id, 'companyId': companyId},
              );
            }
            await (db.delete(
              db.customerDiscountsTable,
            )..where((t) => t.id.equals(d.id))).go();
        }
      } catch (e) {
        debugPrint(
          'pushPendingCustomerDiscountOps: discount ${d.id} (${d.syncStatus}) failed — $e',
        );
        try {
          await (db.update(
            db.customerDiscountsTable,
          )..where((t) => t.id.equals(d.id))).write(
            CustomerDiscountsTableCompanion(syncError: Value(e.toString())),
          );
        } catch (_) {}
      }
    }
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

    // Loop individually to protect rows with pending local edits from being
    // overwritten by stale server data. Same pattern as pullProductGroups.
    for (final json in rows.cast<Map<String, dynamic>>()) {
      final id = json['id'] as int;
      final existing = await (db.select(
        db.customersTable,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (existing != null && existing.syncStatus != 'synced') continue;

      await db
          .into(db.customersTable)
          .insertOnConflictUpdate(
            CustomersTableCompanion(
              id: Value(id),
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
              additionalStreetName: Value(
                json['additionalStreetName'] as String?,
              ),
              buildingNumber: Value(json['buildingNumber'] as String?),
              plotIdentification: Value(json['plotIdentification'] as String?),
              citySubdivisionName: Value(
                json['citySubdivisionName'] as String?,
              ),
              isTaxExempt: Value(json['isTaxExempt'] as bool? ?? false),
              lastModified: Value(_parseLastModified(json['lastModified'])),
              syncStatus: const Value('synced'),
            ),
          );
    }

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

    await db
        .into(db.companiesTable)
        .insertOnConflictUpdate(
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
    if (rows == null) return;

    final now = DateTime.now().toUtc();
    final serverIds = <int>{};

    for (final m in rows.cast<Map<String, dynamic>>()) {
      final id = m['id'] as int;
      serverIds.add(id);
      // Don't clobber a row that has unsynced local edits.
      final existing = await (db.select(db.stocksTable)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (existing != null && existing.syncStatus != 'synced') continue;
      await db.into(db.stocksTable).insertOnConflictUpdate(StocksTableCompanion(
        id: Value(id),
        productId: Value(m['productId'] as int),
        warehouseId: Value(m['warehouseId'] as int),
        companyId: Value(m['companyId'] as int? ?? companyId),
        quantity: Value(((m['quantity'] ?? 0) as num).toDouble()),
        lastModified: Value(now),
        syncStatus: const Value('synced'),
      ));
    }

    // Drop synced server rows deleted elsewhere; keep local pending/temp rows.
    final localSynced = await (db.select(db.stocksTable)
          ..where((t) => t.companyId.equals(companyId))
          ..where((t) => t.syncStatus.equals('synced'))
          ..where((t) => t.id.isBiggerThanValue(0)))
        .get();
    for (final s in localSynced) {
      if (!serverIds.contains(s.id)) {
        await (db.delete(db.stocksTable)..where((t) => t.id.equals(s.id))).go();
      }
    }
  }

  // ==========================================================================
  // PUSH — offline stock CRUD (add / update / delete quantities).
  // ==========================================================================
  Future<void> pushPendingStocks(int companyId) async {
    for (final s in await db.getStocksBySyncStatus(companyId, 'pending_create')) {
      try {
        final res = await dio.post<dynamic>(
          '/Stocks/Add',
          queryParameters: {'companyId': companyId},
          data: {
            'productId': s.productId,
            'warehouseId': s.warehouseId,
            'quantity': s.quantity,
          },
        );
        final newId = _parseDocServerId(res.data);
        if (newId != null) {
          await db.replaceStockTempId(s.id, newId);
        } else {
          // Server didn't echo an id — drop the temp row; pullStocks re-adds
          // the authoritative one.
          await db.hardDeleteStock(s.id);
        }
      } catch (e) {
        debugPrint('pushPendingStocks (add) ${s.id} failed — $e');
      }
    }

    for (final s in await db.getStocksBySyncStatus(companyId, 'pending_update')) {
      if (s.id < 0) continue;
      try {
        await dio.patch<dynamic>(
          '/Stocks/Update',
          queryParameters: {'companyId': companyId},
          data: {
            'id': s.id,
            'newProductId': s.productId,
            'newWarehouseId': s.warehouseId,
            'newQuantity': s.quantity,
          },
        );
        await db.markStockSynced(s.id);
      } catch (e) {
        debugPrint('pushPendingStocks (update) ${s.id} failed — $e');
      }
    }

    for (final s in await db.getStocksBySyncStatus(companyId, 'pending_delete')) {
      try {
        if (s.id > 0) {
          await dio.delete<dynamic>(
            '/Stocks/Delete',
            queryParameters: {'id': s.id, 'companyId': companyId},
          );
        }
        await db.hardDeleteStock(s.id);
      } catch (e) {
        debugPrint('pushPendingStocks (delete) ${s.id} failed — $e');
      }
    }
  }

  // ==========================================================================
  // STOCK CONTROLS — offline-first pull + CRUD push.
  // ==========================================================================
  Future<void> pullStockControls(int companyId) async {
    final res = await dio.get<List<dynamic>>(
      '/StockControls/GetAll',
      queryParameters: {'companyId': companyId},
    );
    final rows = res.data;
    if (rows == null) return;

    final now = DateTime.now().toUtc();
    final serverProductIds = <int>{};
    for (final j in rows.cast<Map<String, dynamic>>()) {
      final productId = (j['productId'] as num?)?.toInt() ?? 0;
      serverProductIds.add(productId);
      await db.upsertSyncedStockControl(StockControlsTableCompanion(
        productId: Value(productId),
        companyId: Value(companyId),
        serverId: Value((j['id'] as num?)?.toInt()),
        reorderPoint: Value((j['reorderPoint'] as num?)?.toDouble() ?? 0),
        preferredQuantity: Value((j['preferredQuantity'] as num?)?.toDouble() ?? 0),
        isLowStockWarningEnabled:
            Value(j['isLowStockWarningEnabled'] as bool? ?? true),
        lowStockWarningQuantity:
            Value((j['lowStockWarningQuantity'] as num?)?.toDouble() ?? 0),
        lastModified: Value(now),
        syncStatus: const Value('synced'),
      ));
    }

    // Drop synced rules deleted elsewhere; keep local pending edits.
    for (final sc in await db.getStockControlsBySyncStatus(companyId, 'synced')) {
      if (!serverProductIds.contains(sc.productId)) {
        await db.hardDeleteStockControl(sc.productId);
      }
    }
  }

  Future<void> pushPendingStockControls(int companyId) async {
    for (final sc
        in await db.getStockControlsBySyncStatus(companyId, 'pending_create')) {
      try {
        await dio.post<dynamic>(
          '/StockControls/Add',
          queryParameters: {'companyId': companyId},
          data: {
            'productId': sc.productId,
            'reorderPoint': sc.reorderPoint,
            'preferredQuantity': sc.preferredQuantity,
            'isLowStockWarningEnabled': sc.isLowStockWarningEnabled,
            'lowStockWarningQuantity': sc.lowStockWarningQuantity,
            if (sc.customerId != null) 'customerId': sc.customerId,
          },
        );
        // Add doesn't echo the id — fetch it so future edits/deletes can target
        // the server row.
        int? newId;
        try {
          final g = await dio.get<dynamic>(
            '/StockControls/GetByProductId',
            queryParameters: {'productId': sc.productId, 'companyId': companyId},
          );
          if (g.data is Map) newId = (g.data['id'] as num?)?.toInt();
        } catch (_) {}
        await db.markStockControlSynced(sc.productId, newId);
      } catch (e) {
        debugPrint('pushPendingStockControls (add) ${sc.productId} failed — $e');
      }
    }

    for (final sc
        in await db.getStockControlsBySyncStatus(companyId, 'pending_update')) {
      if (sc.serverId == null) continue;
      try {
        await dio.patch<dynamic>(
          '/StockControls/Update',
          queryParameters: {'companyId': companyId},
          data: {
            'id': sc.serverId,
            'reorderPoint': sc.reorderPoint,
            'preferredQuantity': sc.preferredQuantity,
            'isLowStockWarningEnabled': sc.isLowStockWarningEnabled,
            'lowStockWarningQuantity': sc.lowStockWarningQuantity,
            if (sc.customerId != null) 'customerId': sc.customerId,
          },
        );
        await db.markStockControlSynced(sc.productId, sc.serverId);
      } catch (e) {
        debugPrint(
            'pushPendingStockControls (update) ${sc.productId} failed — $e');
      }
    }

    for (final sc
        in await db.getStockControlsBySyncStatus(companyId, 'pending_delete')) {
      try {
        if (sc.serverId != null) {
          await dio.delete<dynamic>(
            '/StockControls/Delete',
            queryParameters: {'id': sc.serverId, 'companyId': companyId},
          );
        }
        await db.hardDeleteStockControl(sc.productId);
      } catch (e) {
        debugPrint(
            'pushPendingStockControls (delete) ${sc.productId} failed — $e');
      }
    }
  }

  // ==========================================================================
  // WAREHOUSES — offline-first pull + CRUD push.
  // ==========================================================================

  Future<void> pullWarehouses(int companyId) async {
    final res = await dio.get<List<dynamic>>(
      '/Warehouses/GetAll',
      queryParameters: {'companyId': companyId},
    );
    final rows = res.data ?? const [];
    final now = DateTime.now().toUtc();
    final serverIds = <int>{};

    for (final j in rows.cast<Map<String, dynamic>>()) {
      final id = j['id'] as int;
      serverIds.add(id);
      // Don't clobber a row that has unsynced local edits.
      final existing = await (db.select(db.warehousesTable)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (existing != null && existing.syncStatus != 'synced') continue;
      await db.into(db.warehousesTable).insertOnConflictUpdate(
            WarehousesTableCompanion(
              id: Value(id),
              companyId: Value(j['companyId'] as int? ?? companyId),
              name: Value(j['name'] as String? ?? ''),
              lastModified: Value(now),
              syncStatus: const Value('synced'),
            ),
          );
    }

    // Drop synced server rows that no longer exist on the server (deleted on
    // another device). Local pending rows (negative ids / non-'synced') are
    // preserved so an offline edit is never lost.
    final localSynced = await (db.select(db.warehousesTable)
          ..where((t) => t.companyId.equals(companyId))
          ..where((t) => t.syncStatus.equals('synced'))
          ..where((t) => t.id.isBiggerThanValue(0)))
        .get();
    for (final w in localSynced) {
      if (!serverIds.contains(w.id)) {
        await (db.delete(db.warehousesTable)..where((t) => t.id.equals(w.id)))
            .go();
      }
    }
  }

  /// Pushes locally-queued warehouse CRUD. Split into two phases by
  /// [deletePhase] so the caller can sequence creates/updates BEFORE the stock
  /// ops and deletes AFTER them (see `sync`).
  Future<void> pushPendingWarehouseOps(int companyId,
      {required bool deletePhase}) async {
    final statuses = deletePhase
        ? ['pending_delete']
        : ['pending_create', 'pending_update'];
    final pending = await (db.select(db.warehousesTable)
          ..where((t) => t.companyId.equals(companyId))
          ..where((t) => t.syncStatus.isIn(statuses)))
        .get();

    for (final w in pending) {
      try {
        switch (w.syncStatus) {
          case 'pending_create':
            final res = await dio.post<dynamic>(
              '/Warehouses/Add',
              queryParameters: {'companyId': companyId},
              data: {'name': w.name},
            );
            final data = res.data;
            final realId = data is Map
                ? ((data['id'] ?? data['Id']) as num?)?.toInt()
                : null;
            if (realId == null) {
              throw Exception('Server returned no id for warehouse create');
            }
            await db.transaction(() async {
              await (db.delete(db.warehousesTable)
                    ..where((t) => t.id.equals(w.id)))
                  .go();
              await db.into(db.warehousesTable).insertOnConflictUpdate(
                    WarehousesTableCompanion(
                      id: Value(realId),
                      companyId: Value(w.companyId),
                      name: Value(w.name),
                      lastModified: Value(DateTime.now().toUtc()),
                      syncStatus: const Value('synced'),
                    ),
                  );
              // Repoint any queued stock "move" that targeted the temp id.
              await (db.update(db.pendingStockOpsTable)
                    ..where((t) => t.targetWarehouseId.equals(w.id)))
                  .write(PendingStockOpsTableCompanion(
                      targetWarehouseId: Value(realId)));
            });

          case 'pending_update':
            await dio.patch<dynamic>(
              '/Warehouses/Update',
              queryParameters: {'companyId': companyId},
              data: {'id': w.id, 'name': w.name},
            );
            await (db.update(db.warehousesTable)
                  ..where((t) => t.id.equals(w.id)))
                .write(const WarehousesTableCompanion(
              syncStatus: Value('synced'),
              syncError: Value(null),
            ));

          case 'pending_delete':
            if (w.id > 0) {
              await dio.delete<dynamic>(
                '/Warehouses/Delete',
                queryParameters: {'id': w.id, 'companyId': companyId},
              );
            }
            await (db.delete(db.warehousesTable)
                  ..where((t) => t.id.equals(w.id)))
                .go();
        }
      } catch (e) {
        debugPrint(
            'pushPendingWarehouseOps: ${w.id} (${w.syncStatus}) failed — $e');
        try {
          await (db.update(db.warehousesTable)
                ..where((t) => t.id.equals(w.id)))
              .write(WarehousesTableCompanion(syncError: Value(e.toString())));
        } catch (_) {}
      }
    }
  }

  /// Drains the stock revoke/move queue created when a warehouse with stock is
  /// deleted offline. Runs AFTER warehouse creates (so a move target exists)
  /// and BEFORE warehouse deletes (so the warehouse is empty first).
  Future<void> pushPendingStockOps(int companyId) async {
    final ops = await (db.select(db.pendingStockOpsTable)
          ..where((t) => t.companyId.equals(companyId)))
        .get();

    for (final op in ops) {
      // A move whose target is still a temp (negative) id can't be pushed yet —
      // its warehouse create hasn't synced. Leave it for the next cycle.
      if (op.operation == 'move' &&
          (op.targetWarehouseId == null || op.targetWarehouseId! < 0)) {
        continue;
      }
      try {
        if (op.operation == 'delete') {
          await dio.delete<dynamic>(
            '/Stocks/Delete',
            queryParameters: {'id': op.stockId, 'companyId': companyId},
          );
        } else {
          await dio.patch<dynamic>(
            '/Stocks/Update',
            queryParameters: {'companyId': companyId},
            data: {
              'id': op.stockId,
              'newQuantity': op.quantity ?? 0,
              'newWarehouseId': op.targetWarehouseId,
              'newProductId': op.productId,
            },
          );
        }
        await (db.delete(db.pendingStockOpsTable)
              ..where((t) => t.id.equals(op.id)))
            .go();
      } on DioException catch (e) {
        // Already gone on the server — drop the op so it doesn't block deletes.
        if (e.response?.statusCode == 404) {
          await (db.delete(db.pendingStockOpsTable)
                ..where((t) => t.id.equals(op.id)))
              .go();
        } else {
          debugPrint('pushPendingStockOps: ${op.id} failed — $e');
        }
      } catch (e) {
        debugPrint('pushPendingStockOps: ${op.id} failed — $e');
      }
    }
  }

  // ==========================================================================
  // PULL — today's cash movements from /StartingCash/GetByDateRange
  // ==========================================================================

  /// Pulls today's StartingCash rows for [companyId] and inserts any that the
  /// local DB doesn't already know about (by server `id`), so the Cash In/Out
  /// list shows movements from every till even offline. Runs AFTER
  /// pushPendingCashMovements so locally-created rows already carry their
  /// serverId and are skipped here (no duplicates).
  Future<void> pullStartingCash(int companyId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);

    final List<dynamic>? rows;
    try {
      final res = await dio.get<List<dynamic>>(
        '/StartingCash/GetByDateRange',
        queryParameters: {
          'companyId': companyId,
          'startDate': start.toIso8601String(),
          'endDate': start.toIso8601String(),
        },
      );
      rows = res.data;
    } catch (e) {
      debugPrint('pullStartingCash failed: $e — local cash preserved.');
      return;
    }
    if (rows == null || rows.isEmpty) return;

    final known = await db.getStartingCashFinalizationByServerId();
    final toInsert = <StartingCashTableCompanion>[];
    final toFinalize = <int, int>{}; // serverId → zReportNumber
    for (final raw in rows) {
      final m = raw as Map<String, dynamic>;
      final serverId = m['id'] as int?;
      if (serverId == null) continue;
      final zReportNumber = m['zReportNumber'] as int?;

      if (known.containsKey(serverId)) {
        // Already local — the only meaningful change is finalization: the
        // server just stamped a Z-report number on a previously-open row.
        final alreadyFinalized = known[serverId]!;
        if (!alreadyFinalized && zReportNumber != null) {
          toFinalize[serverId] = zReportNumber;
        }
        continue;
      }

      // Map server fields → local schema: StartingCashType 0/1 → 'in'/'out',
      // Description → note, DateCreated → createdAt, ZReportNumber → zReportNumber.
      final type = (m['startingCashType'] as int? ?? 0) == 1 ? 'out' : 'in';
      toInsert.add(StartingCashTableCompanion.insert(
        localId: const Uuid().v4(),
        companyId: (m['companyId'] as int?) ?? companyId,
        userId: m['userId'] as int,
        amount: (m['amount'] as num).toDouble(),
        type: type,
        note: Value(m['description'] as String?),
        createdAt: DateTime.parse(m['dateCreated'] as String),
        zReportNumber: Value(zReportNumber),
        serverId: Value(serverId),
        syncStatus: const Value('synced'),
      ));
    }

    await db.insertSyncedStartingCash(toInsert);
    await db.applyStartingCashZReportNumbers(toFinalize);
  }

  // ==========================================================================
  // PUSH — Manual document editor headers (create / update / delete).
  // pending_create → POST /Document/Add (stamps the server id + links),
  // pending_update → PATCH /Document/Update, pending_delete → DELETE then
  // remove the local row. Line items are pushed separately so the document
  // always has a server id first.
  // ==========================================================================
  Future<void> pushPendingDocuments(int companyId) async {
    // ── Deletes ────────────────────────────────────────────────────────────
    for (final doc in await db.getDocumentsBySyncStatus(companyId, 'pending_delete')) {
      try {
        if (doc.serverId != null) {
          await dio.delete<dynamic>(
            '/Document/Delete',
            queryParameters: {'id': doc.serverId, 'companyId': companyId},
          );
        }
        await (db.delete(db.documentsTable)
              ..where((t) => t.localId.equals(doc.localId)))
            .go();
      } catch (e) {
        debugPrint('pushPendingDocuments (delete) ${doc.localId} failed — $e');
      }
    }

    // ── Creates ────────────────────────────────────────────────────────────
    for (final doc in await db.getDocumentsBySyncStatus(companyId, 'pending_create')) {
      try {
        final res = await dio.post<dynamic>(
          '/Document/Add',
          queryParameters: {'companyId': companyId},
          data: _documentAddJson(doc),
        );
        final serverId = _parseDocServerId(res.data);
        if (serverId == null) continue; // retry next sync
        await db.linkDocumentToServer(doc.localId, serverId);
      } catch (e) {
        debugPrint('pushPendingDocuments (create) ${doc.localId} failed — $e');
      }
    }

    // ── Header updates ─────────────────────────────────────────────────────
    for (final doc in await db.getDocumentsBySyncStatus(companyId, 'pending_update')) {
      if (doc.serverId == null) continue;
      try {
        await dio.patch<dynamic>(
          '/Document/Update',
          queryParameters: {'companyId': companyId},
          data: _documentUpdateJson(doc),
        );
        await (db.update(db.documentsTable)
              ..where((t) => t.localId.equals(doc.localId)))
            .write(const DocumentsTableCompanion(syncStatus: Value('synced')));
      } catch (e) {
        debugPrint('pushPendingDocuments (update) ${doc.localId} failed — $e');
      }
    }
  }

  Map<String, dynamic> _documentAddJson(DocumentsTableData d) => {
        'number': d.number,
        'userId': d.userId,
        'customerId': d.customerId,
        'orderNumber': d.orderNumber,
        'date': d.date.toIso8601String(),
        'stockDate': (d.stockDate ?? d.date).toIso8601String(),
        'dueDate': (d.dueDate ?? d.date).toIso8601String(),
        'total': d.total,
        'isClockedOut': true,
        'documentTypeId': d.documentTypeId,
        'warehouseId': d.warehouseId,
        'internalNote': d.internalNote ?? '',
        'note': d.note ?? '',
        'referenceDocumentNumber': d.referenceDocumentNumber ?? '',
        'discount': d.discount,
        'discountType': d.discountType,
        'paidStatus': d.paidStatus,
        'discountApplyRule': d.discountApplyRule,
        'serviceType': d.serviceType,
      };

  Map<String, dynamic> _documentUpdateJson(DocumentsTableData d) => {
        'id': d.serverId,
        'number': d.number,
        'customerId': d.customerId,
        'userId': d.userId,
        'date': d.date.toIso8601String(),
        'stockDate': (d.stockDate ?? d.date).toIso8601String(),
        'dueDate': (d.dueDate ?? d.date).toIso8601String(),
        'documentTypeId': d.documentTypeId,
        'warehouseId': d.warehouseId,
        'internalNote': d.internalNote ?? '',
        'note': d.note ?? '',
        'referenceDocumentNumber': d.referenceDocumentNumber ?? '',
        'discount': d.discount,
        'discountType': d.discountType,
        'discountApplyRule': d.discountApplyRule,
        'total': d.total,
        'paidStatus': d.paidStatus,
      };

  int? _parseDocServerId(dynamic body) {
    final data = body is Map && body.containsKey('data') ? body['data'] : body;
    if (data is Map) {
      return int.tryParse(
          data['id']?.toString() ?? data['Id']?.toString() ?? '');
    }
    if (data is num) return data.toInt();
    return null;
  }

  // ==========================================================================
  // PUSH — Manual document line items (create / update / delete). Items are
  // keyed to their parent by document localId; a create is skipped until its
  // document has a server id. Tax + expiration attachments ride along on create.
  // ==========================================================================
  Future<void> pushPendingDocumentItems(int companyId) async {
    // ── Creates ────────────────────────────────────────────────────────────
    for (final it in await db.getDocumentItemsBySyncStatus('pending_create')) {
      final doc = await db.getDocumentByLocalId(it.documentId);
      final docServerId = doc?.serverId;
      if (docServerId == null) continue;
      try {
        final res = await dio.post<dynamic>(
          '/DocumentItems/Add',
          queryParameters: {'companyId': companyId},
          data: {
            'documentId': docServerId,
            'productId': it.productId,
            'quantity': it.quantity,
            'expectedQuantity': it.quantity,
            'priceBeforeTax': it.priceBeforeTax,
            'price': it.unitPrice,
            'discount': it.discount,
            'discountType': it.discountType,
            'discountApplyRule': true,
          },
        );
        final itemServerId = _parseDocServerId(res.data);
        if (itemServerId != null && it.taxId != null) {
          await dio.post<dynamic>(
            '/DocumentItemTaxes/Add',
            queryParameters: {'companyId': companyId},
            data: {'documentItemId': itemServerId, 'taxId': it.taxId},
          );
        }
        if (itemServerId != null && it.expirationDate != null) {
          await dio.post<dynamic>(
            '/DocumentItemExpirationDates/Add',
            queryParameters: {'companyId': companyId},
            data: {
              'documentItemId': itemServerId,
              'expirationDate': it.expirationDate!.toIso8601String(),
            },
          );
        }
        await db.markDocumentItemSynced(it.localId, itemServerId);
      } catch (e) {
        debugPrint('pushPendingDocumentItems (create) ${it.localId} failed — $e');
      }
    }

    // ── Updates ────────────────────────────────────────────────────────────
    for (final it in await db.getDocumentItemsBySyncStatus('pending_update')) {
      if (it.serverId == null) continue;
      final doc = await db.getDocumentByLocalId(it.documentId);
      final docServerId = doc?.serverId;
      if (docServerId == null) continue;
      try {
        await dio.patch<dynamic>(
          '/DocumentItems/Update',
          queryParameters: {'companyId': companyId},
          data: {
            'id': it.serverId,
            'documentId': docServerId,
            'productId': it.productId,
            'quantity': it.quantity,
            'expectedQuantity': it.quantity,
            'priceBeforeTax': it.priceBeforeTax,
            'price': it.unitPrice,
            'discount': it.discount,
            'discountType': it.discountType,
            'productCost': 0,
            'discountApplyRule': true,
          },
        );
        if (it.expirationDate != null) {
          // Best-effort upsert of the expiration date.
          try {
            await dio.post<dynamic>(
              '/DocumentItemExpirationDates/Add',
              queryParameters: {'companyId': companyId},
              data: {
                'documentItemId': it.serverId,
                'expirationDate': it.expirationDate!.toIso8601String(),
              },
            );
          } catch (_) {}
        }
        await db.markDocumentItemSynced(it.localId, it.serverId);
      } catch (e) {
        debugPrint('pushPendingDocumentItems (update) ${it.localId} failed — $e');
      }
    }

    // ── Deletes ────────────────────────────────────────────────────────────
    for (final it in await db.getDocumentItemsBySyncStatus('pending_delete')) {
      try {
        if (it.serverId != null) {
          await dio.delete<dynamic>(
            '/DocumentItems/Delete',
            queryParameters: {'id': it.serverId, 'companyId': companyId},
          );
        }
        await db.hardDeleteDocumentItem(it.localId);
      } catch (e) {
        debugPrint('pushPendingDocumentItems (delete) ${it.localId} failed — $e');
      }
    }
  }

  // ==========================================================================
  // PUSH — Paid-status toggles made offline in the document editor.
  // documents.paid_status_dirty rows (with a server id) are PATCHed to
  // /Document/Update; the flag is cleared on success and retried otherwise.
  // ==========================================================================
  Future<void> pushPendingPaidStatus(int companyId) async {
    final dirty = await db.getPaidStatusDirtyDocuments(companyId);
    for (final doc in dirty) {
      try {
        await dio.patch<dynamic>(
          '/Document/Update',
          queryParameters: {'companyId': companyId},
          data: {'id': doc.serverId, 'paidStatus': doc.paidStatus},
        );
        await db.clearPaidStatusDirty(doc.localId);
      } catch (e) {
        debugPrint('pushPendingPaidStatus ${doc.localId} failed — $e');
      }
    }
  }

  // ==========================================================================
  // PUSH — Standalone payment CRUD made offline in the document editor.
  //   pending_create → POST /Payments/Add  (stamps the returned server id)
  //   pending_update → PATCH /Payments/Update
  //   pending_delete → DELETE /Payments/Delete then hard-delete the local row
  // A create whose parent document isn't on the server yet is skipped until it
  // is (its document syncs first via pushPendingOrders / linkDocumentToServer).
  // ==========================================================================
  Future<void> pushPendingPayments(int companyId) async {
    // ── Creates ────────────────────────────────────────────────────────────
    for (final p in await db.getPaymentsBySyncStatus('pending_create')) {
      final doc = await db.getDocumentByLocalId(p.documentId);
      final docServerId = doc?.serverId;
      if (docServerId == null) continue; // wait for the document to sync first
      try {
        final res = await dio.post<dynamic>(
          '/Payments/Add',
          queryParameters: {'companyId': companyId},
          data: {
            'documentId': docServerId,
            'paymentTypeId': p.paymentTypeId,
            'amount': p.amount,
            'userId': p.userId,
          },
        );
        await db.markPaymentSynced(p.localId, _parsePaymentServerId(res.data));
      } catch (e) {
        debugPrint('pushPendingPayments (create) ${p.localId} failed — $e');
      }
    }

    // ── Updates ────────────────────────────────────────────────────────────
    for (final p in await db.getPaymentsBySyncStatus('pending_update')) {
      if (p.serverId == null) continue;
      try {
        await dio.patch<dynamic>(
          '/Payments/Update',
          queryParameters: {'companyId': companyId},
          data: {
            'id': p.serverId,
            'amount': p.amount,
            'date': p.date.toIso8601String(),
          },
        );
        await db.markPaymentSynced(p.localId, p.serverId);
      } catch (e) {
        debugPrint('pushPendingPayments (update) ${p.localId} failed — $e');
      }
    }

    // ── Deletes ────────────────────────────────────────────────────────────
    for (final p in await db.getPaymentsBySyncStatus('pending_delete')) {
      try {
        if (p.serverId != null) {
          await dio.delete<dynamic>(
            '/Payments/Delete',
            queryParameters: {'id': p.serverId, 'companyId': companyId},
          );
        }
        await db.hardDeletePayment(p.localId);
      } catch (e) {
        debugPrint('pushPendingPayments (delete) ${p.localId} failed — $e');
      }
    }
  }

  int? _parsePaymentServerId(dynamic body) {
    final data = body is Map && body.containsKey('data') ? body['data'] : body;
    if (data is Map) {
      return int.tryParse(
          data['id']?.toString() ?? data['Id']?.toString() ?? '');
    }
    if (data is num) return data.toInt();
    return null;
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
    final now = DateTime.now().toUtc();
    final from = now.subtract(const Duration(days: 90));

    try {
      final res = await dio.get<dynamic>(
        '/Document/GetSalesHistory',
        queryParameters: {
          'companyId': companyId,
          'startDate': from.toIso8601String().substring(0, 10),
          'endDate': now.toIso8601String().substring(0, 10),
          // Pull line items + customerId so the local DB can compute the
          // dashboard / item-level reports fully offline.
          'includeItems': true,
        },
      );

      final list = ((res.data as List?) ?? []).cast<Map<String, dynamic>>();

      // Set of document localIds that already have line items locally — lets us
      // backfill items exactly once for documents pulled before includeItems
      // existed (or created on other devices), without rewriting items every
      // sync or touching local-origin docs that already carry their items.
      final withItemsRows = await (db.selectOnly(db.documentItemsTable,
              distinct: true)
            ..addColumns([db.documentItemsTable.documentId]))
          .get();
      final docsWithItems = withItemsRows
          .map((r) => r.read(db.documentItemsTable.documentId))
          .whereType<String>()
          .toSet();

      for (final d in list) {
        final serverId = (d['id'] as num?)?.toInt() ?? 0;
        if (serverId == 0) continue;

        final dateStr = (d['stockDate'] ?? d['date'] ?? '') as String;
        final date = DateTime.tryParse(dateStr) ?? now;
        final total = ((d['total'] as num?)?.toDouble()) ?? 0.0;
        final disc = ((d['discount'] as num?)?.toDouble()) ?? 0.0;
        final number = (d['number'] as String?) ?? '';
        final orderNo = d['orderNumber'] as String?;
        final paid = (d['paidStatus'] as num?)?.toInt() ?? 1;
        final customerId = (d['customerId'] as num?)?.toInt();
        final rawItems =
            ((d['items'] as List?) ?? const []).cast<Map<String, dynamic>>();

        // Build item rows for a given document localId. The server item id is
        // captured (when present) so the offline editor can later edit/delete
        // these server-originated items and have the change pushed.
        List<DocumentItemsTableCompanion> buildItems(String docLocalId) =>
            rawItems
                .map((m) => DocumentItemsTableCompanion.insert(
                      localId: const Uuid().v4(),
                      documentId: docLocalId,
                      productId: (m['productId'] as num?)?.toInt() ?? 0,
                      quantity: ((m['quantity'] as num?) ?? 0).toDouble(),
                      unitPrice: ((m['unitPrice'] as num?) ?? 0).toDouble(),
                      total: ((m['total'] as num?) ?? 0).toDouble(),
                      serverId: Value((m['id'] as num?)?.toInt()),
                      priceBeforeTax: Value(
                          ((m['priceBeforeTax'] as num?) ?? 0).toDouble()),
                      discount:
                          Value(((m['discount'] as num?) ?? 0).toDouble()),
                      discountType:
                          Value((m['discountType'] as num?)?.toInt() ?? 0),
                    ))
                .toList();

        // Case 1: already in local DB by serverId — stamp the number, and
        // backfill items if this row has none yet (older pull / other device).
        final existing =
            await (db.select(db.documentsTable)
                  ..where((t) => t.serverId.equals(serverId))
                  ..limit(1))
                .getSingleOrNull();

        if (existing != null) {
          // Never clobber a document with unsynced local edits — the pusher
          // owns it until it reaches the server. Reconciling it here would
          // drop a pending header/total/delete change.
          const manualPending = {
            'pending_create',
            'pending_update',
            'pending_delete',
          };
          if (manualPending.contains(existing.syncStatus)) {
            continue;
          }
          if (existing.number != number || existing.syncStatus != 'synced') {
            await (db.update(
              db.documentsTable,
            )..where((t) => t.localId.equals(existing.localId))).write(
              DocumentsTableCompanion(
                number: Value(number),
                syncStatus: const Value('synced'),
                lastModified: Value(date),
              ),
            );
          }
          if (rawItems.isNotEmpty &&
              !docsWithItems.contains(existing.localId)) {
            await db.batch((b) =>
                b.insertAll(db.documentItemsTable, buildItems(existing.localId)));
          }
          continue;
        }

        // Case 2: new document from another device — insert sentinel row
        // plus its line items + customerId so the local DB can compute the
        // dashboard / item reports offline.
        // userId / warehouseId are not returned by GetSalesHistory; use 0.
        final docLocalId = 'srv_$serverId';
        await db.upsertServerDocument(
          document: DocumentsTableCompanion(
            localId: Value(docLocalId),
            serverId: Value(serverId),
            companyId: Value(companyId),
            userId: const Value(0),
            warehouseId: const Value(0),
            number: Value(number),
            total: Value(total),
            discount: Value(disc),
            customerId: Value(customerId),
            orderNumber: Value(orderNo),
            paidStatus: Value(paid),
            date: Value(date),
            syncStatus: const Value('synced'),
            lastModified: Value(date),
          ),
          items: buildItems(docLocalId),
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
    final ops = await (db.select(
      db.pendingUserOpsTable,
    )..where((t) => t.companyId.equals(companyId))).get();
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
              data: {'name': payload['name'], 'level': payload['level']},
            );
          default:
            debugPrint('pushPendingUserOps: unknown op "${op.operation}"');
        }
        // Success — remove from queue.
        await (db.delete(
          db.pendingUserOpsTable,
        )..where((t) => t.id.equals(op.id))).go();
      } on DioException {
        // Still offline or transient error — leave the row for next retry.
        debugPrint(
          'pushPendingUserOps: op ${op.id} (${op.operation}) failed — will retry',
        );
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
        await (db.delete(
          db.securityKeysTable,
        )..where((t) => t.companyId.equals(companyId))).go();
        if (rows.isNotEmpty) {
          await db.batch((b) {
            b.insertAll(
              db.securityKeysTable,
              rows.map(
                (j) => SecurityKeysTableCompanion(
                  companyId: Value(companyId),
                  name: Value(j['name'] as String? ?? ''),
                  level: Value((j['level'] as num?)?.toInt() ?? 1),
                ),
              ),
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
      final existing = await (db.select(
        db.promotionsTable,
      )..where((t) => t.id.equals(promoId))).getSingleOrNull();
      if (existing != null && existing.syncStatus != 'synced') continue;

      await db.transaction(() async {
        await db
            .into(db.promotionsTable)
            .insertOnConflictUpdate(
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
                      : json['startTime'] as String?,
                ),
                endDate: Value(_parseNullableDate(json['endDate'])),
                endTime: Value(
                  (json['endTime'] as String?)?.isEmpty == true
                      ? null
                      : json['endTime'] as String?,
                ),
                lastModified: Value(_parseLastModified(json['lastModified'])),
                syncStatus: const Value('synced'),
              ),
            );
        // Replace items for this promotion with the server version.
        await (db.delete(
          db.promotionItemsTable,
        )..where((t) => t.promotionId.equals(promoId))).go();
        final items = ((json['items'] as List<dynamic>?) ?? [])
            .cast<Map<String, dynamic>>();
        for (final item in items) {
          await db
              .into(db.promotionItemsTable)
              .insertOnConflictUpdate(
                PromotionItemsTableCompanion(
                  id: Value((item['id'] as num?)?.toInt() ?? 0),
                  promotionId: Value(promoId),
                  productId: Value((item['productId'] as num?)?.toInt() ?? 0),
                  discountType: Value(
                    (item['discountType'] as num?)?.toInt() ?? 0,
                  ),
                  priceType: Value((item['priceType'] as num?)?.toInt() ?? 0),
                  value: Value((item['value'] as num?)?.toDouble() ?? 0),
                  isConditional: Value(item['isConditional'] as bool? ?? false),
                  quantity: Value((item['quantity'] as num?)?.toDouble() ?? 1),
                  conditionType: Value(
                    (item['conditionType'] as num?)?.toInt() ?? 0,
                  ),
                  quantityLimit: Value(
                    (item['quantityLimit'] as num?)?.toDouble() ?? 0,
                  ),
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
    final pending =
        await (db.select(db.promotionsTable)
              ..where((t) => t.companyId.equals(companyId))
              ..where((t) => t.syncStatus.isNotIn(['synced'])))
            .get();

    for (final p in pending) {
      try {
        final localItems = await (db.select(
          db.promotionItemsTable,
        )..where((t) => t.promotionId.equals(p.id))).get();

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
                  .map(
                    (i) => {
                      'productId': i.productId,
                      'discountType': i.discountType,
                      'priceType': i.priceType,
                      'value': i.value,
                      'isConditional': i.isConditional,
                      'quantity': i.quantity,
                      'conditionType': i.conditionType,
                      'quantityLimit': i.quantityLimit,
                    },
                  )
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
              await (db.delete(
                db.promotionsTable,
              )..where((t) => t.id.equals(p.id))).go();
              await (db.delete(
                db.promotionItemsTable,
              )..where((t) => t.promotionId.equals(p.id))).go();
              await db
                  .into(db.promotionsTable)
                  .insertOnConflictUpdate(
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
                await db
                    .into(db.promotionItemsTable)
                    .insertOnConflictUpdate(
                      PromotionItemsTableCompanion(
                        id: Value((item['id'] as num?)?.toInt() ?? 0),
                        promotionId: Value(serverId),
                        productId: Value(
                          (item['productId'] as num?)?.toInt() ?? 0,
                        ),
                        discountType: Value(
                          (item['discountType'] as num?)?.toInt() ?? 0,
                        ),
                        priceType: Value(
                          (item['priceType'] as num?)?.toInt() ?? 0,
                        ),
                        value: Value((item['value'] as num?)?.toDouble() ?? 0),
                        isConditional: Value(
                          item['isConditional'] as bool? ?? false,
                        ),
                        quantity: Value(
                          (item['quantity'] as num?)?.toDouble() ?? 1,
                        ),
                        conditionType: Value(
                          (item['conditionType'] as num?)?.toInt() ?? 0,
                        ),
                        quantityLimit: Value(
                          (item['quantityLimit'] as num?)?.toDouble() ?? 0,
                        ),
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
                  .map(
                    (i) => {
                      'id': i.id > 0 ? i.id : 0,
                      'productId': i.productId,
                      'discountType': i.discountType,
                      'priceType': i.priceType,
                      'value': i.value,
                      'isConditional': i.isConditional,
                      'quantity': i.quantity,
                      'conditionType': i.conditionType,
                      'quantityLimit': i.quantityLimit,
                    },
                  )
                  .toList(),
            };
            await dio.put<dynamic>(
              '/Promotions/Update',
              queryParameters: {'companyId': companyId},
              data: body,
            );
            await (db.update(
              db.promotionsTable,
            )..where((t) => t.id.equals(p.id))).write(
              const PromotionsTableCompanion(syncStatus: Value('synced')),
            );

          case 'pending_delete':
            await dio.delete<dynamic>(
              '/Promotions/Delete',
              queryParameters: {'id': p.id, 'companyId': companyId},
            );
            await (db.delete(
              db.promotionItemsTable,
            )..where((t) => t.promotionId.equals(p.id))).go();
            await (db.delete(
              db.promotionsTable,
            )..where((t) => t.id.equals(p.id))).go();
        }
      } catch (e) {
        debugPrint(
          'pushPendingPromotionOps: promo ${p.id} (${p.syncStatus}) failed — $e',
        );
        try {
          await (db.update(db.promotionsTable)..where((t) => t.id.equals(p.id)))
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

      final localRow = await (db.select(
        db.appPropertiesTable,
      )..where((t) => t.id.equals(id))).getSingleOrNull();

      if (localRow != null &&
          !serverLastModified.isAfter(localRow.lastModified)) {
        // Local copy is equal or newer — preserve it.
        continue;
      }

      final name = json['name'] as String? ?? '';
      await db
          .into(db.appPropertiesTable)
          .insertOnConflictUpdate(
            AppPropertiesTableCompanion(
              id: Value(id),
              companyId: Value(json['companyId'] as int? ?? companyId),
              name: Value(name),
              value: Value(json['value'] as String?),
              lastModified: Value(serverLastModified),
              // Authoritative server value — clears any local pending flag.
              syncStatus: const Value('synced'),
            ),
          );

      // Drop any offline-only temp row (negative id) for this key now that the
      // server has assigned a real id — prevents a duplicate name row.
      await (db.delete(db.appPropertiesTable)
            ..where((t) => t.name.equals(name))
            ..where((t) => t.id.isSmallerThanValue(0)))
          .go();
    }

    await _setLastSync(_kAppProperties, startedAt);
  }

  // ==========================================================================
  // LOYALTY CARDS — push pending writes, then pull all cards for company
  // ==========================================================================

  /// Pushes all locally-queued loyalty card mutations to the server using the
  /// batch sync endpoint. Pending deletes are handled individually via DELETE.
  ///
  /// After a successful batch push, temp rows (negative IDs from pending_create)
  /// are hard-deleted locally and pending_update rows are marked 'synced'. The
  /// subsequent [pullLoyaltyCards] then brings back the canonical server rows
  /// with real server-assigned IDs.
  Future<void> pushPendingLoyaltyCardOps(int companyId) async {
    final allPending =
        await (db.select(db.loyaltyCardsTable)
              ..where((t) => t.companyId.equals(companyId))
              ..where(
                (t) => t.syncStatus.isIn([
                  'pending_create',
                  'pending_update',
                  'pending_delete',
                ]),
              ))
            .get();

    if (allPending.isEmpty) return;

    // Split into upserts vs deletes.
    final toUpsert = allPending
        .where((r) => r.syncStatus != 'pending_delete')
        .toList();
    final toDelete = allPending
        .where((r) => r.syncStatus == 'pending_delete')
        .toList();

    // ── Batch upsert ──────────────────────────────────────────────────────────
    if (toUpsert.isNotEmpty) {
      try {
        final cards = toUpsert
            .map(
              (r) => {
                // Negative IDs are temp — omit so the server treats them as creates.
                if (r.id > 0) 'id': r.id,
                'customerId': r.customerId,
                'cardNumber': r.cardNumber,
                'points': r.points,
                'lastModified': r.lastModified.toUtc().toIso8601String(),
              },
            )
            .toList();

        await dio.post<dynamic>(
          '/LoyaltyCards/BatchSync',
          queryParameters: {'companyId': companyId},
          data: {'cards': cards},
        );

        // Remove temp rows and mark updates as synced.
        await db.transaction(() async {
          for (final r in toUpsert) {
            if (r.id < 0) {
              await (db.delete(
                db.loyaltyCardsTable,
              )..where((t) => t.id.equals(r.id))).go();
            } else {
              await (db.update(
                db.loyaltyCardsTable,
              )..where((t) => t.id.equals(r.id))).write(
                const LoyaltyCardsTableCompanion(
                  syncStatus: Value('synced'),
                  syncError: Value(null),
                ),
              );
            }
          }
        });
      } catch (e) {
        debugPrint('pushPendingLoyaltyCardOps: batch upsert failed — $e');
        // Leave rows pending for next retry.
      }
    }

    // ── Individual deletes ────────────────────────────────────────────────────
    for (final r in toDelete) {
      try {
        await dio.delete<dynamic>(
          '/LoyaltyCards/Delete',
          queryParameters: {'id': r.id, 'companyId': companyId},
        );
        await (db.delete(
          db.loyaltyCardsTable,
        )..where((t) => t.id.equals(r.id))).go();
      } catch (e) {
        debugPrint(
          'pushPendingLoyaltyCardOps: delete card ${r.id} failed — $e',
        );
      }
    }
  }

  // ==========================================================================
  // PUSH — pending shifts via /api/Shifts/BatchSync
  // ==========================================================================

  /// Pushes every `syncStatus='pending'` shift to /api/Shifts/BatchSync.
  /// The server returns a Results list mapping each localId → serverId so we
  /// can update the local row without a separate pull.
  Future<void> pushPendingShifts(int companyId) async {
    final pending = await db.getPendingShifts();
    if (pending.isEmpty) return;

    try {
      final shifts = pending
          .map((s) => {
                if (s.serverId != null) 'serverId': s.serverId,
                'localId': s.localId,
                'userId': s.userId,
                'openedAt': s.openedAt.toIso8601String(),
                if (s.closedAt != null)
                  'closedAt': s.closedAt!.toIso8601String(),
                'startingCash': s.startingCash,
                if (s.actualEndingCash != null)
                  'actualEndingCash': s.actualEndingCash,
                'status': s.status,
                'lastModified': s.lastModified.toIso8601String(),
              })
          .toList();

      final res = await dio.post<Map<String, dynamic>>(
        '/Shifts/BatchSync',
        queryParameters: {'companyId': companyId},
        data: {'shifts': shifts},
      );

      final data = res.data;
      final results =
          (data?['results'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>();

      for (final r in results) {
        final localId = r['localId'] as String?;
        final serverId = (r['serverId'] as num?)?.toInt();
        if (localId != null && serverId != null && serverId > 0) {
          await db.markShiftSynced(localId, serverId);
        }
      }
    } catch (e) {
      debugPrint('pushPendingShifts failed — $e');
      // Leave rows pending for next retry; don't mark failed on transport error.
    }
  }

  // ==========================================================================
  // PUSH — pending time clock entries via /api/TimeClock/BatchSync
  // ==========================================================================

  Future<void> pushPendingTimeClockEntries(int companyId) async {
    final pending = await db.getPendingTimeClockEntries();
    if (pending.isEmpty) return;

    try {
      final entries = pending
          .map((e) => {
                if (e.serverId != null) 'serverId': e.serverId,
                'localId': e.localId,
                'userId': e.userId,
                'clockInTime': e.clockInTime.toIso8601String(),
                if (e.clockOutTime != null)
                  'clockOutTime': e.clockOutTime!.toIso8601String(),
                'lastModified': DateTime.now().toUtc().toIso8601String(),
              })
          .toList();

      final res = await dio.post<Map<String, dynamic>>(
        '/TimeClock/BatchSync',
        queryParameters: {'companyId': companyId},
        data: {'entries': entries},
      );

      final data = res.data;
      final results =
          (data?['results'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>();

      for (final r in results) {
        final localId = r['localId'] as String?;
        final serverId = (r['serverId'] as num?)?.toInt();
        if (localId != null && serverId != null && serverId > 0) {
          await db.markTimeClockEntrySynced(localId, serverId);
        }
      }
    } catch (e) {
      debugPrint('pushPendingTimeClockEntries failed — $e');
    }
  }

  /// Pulls all loyalty cards for [companyId] and upserts them into the local
  /// Drift table. Skips rows that have pending local edits so offline writes
  /// are never overwritten by stale server data.
  Future<void> pullLoyaltyCards(int companyId) async {
    try {
      final res = await dio.get<List<dynamic>>(
        '/LoyaltyCards/GetAll',
        queryParameters: {'companyId': companyId},
      );
      final rows = (res.data ?? const []).cast<Map<String, dynamic>>();

      for (final json in rows) {
        final id = (json['id'] as num?)?.toInt() ?? 0;
        if (id <= 0) continue;

        final existing = await (db.select(
          db.loyaltyCardsTable,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (existing != null && existing.syncStatus != 'synced') continue;

        await db
            .into(db.loyaltyCardsTable)
            .insertOnConflictUpdate(
              LoyaltyCardsTableCompanion(
                id: Value(id),
                companyId: Value(json['companyId'] as int? ?? companyId),
                customerId: Value((json['customerId'] as num?)?.toInt() ?? 0),
                cardNumber: Value(json['cardNumber'] as String?),
                points: Value((json['points'] as num?)?.toDouble() ?? 0),
                lastModified: Value(_parseLastModified(json['lastModified'])),
                syncStatus: const Value('synced'),
                syncError: const Value(null),
              ),
            );
      }

      await _setLastSync(_kLoyaltyCards, DateTime.now().toUtc());
    } catch (e) {
      debugPrint('pullLoyaltyCards failed: $e — local data preserved.');
    }
  }
}

/// Converts an empty-or-whitespace string to null so Drift never stores "".
String? _nullIfBlank(String? s) {
  if (s == null) return null;
  final t = s.trim();
  return t.isEmpty ? null : t;
}
