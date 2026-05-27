import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

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

  // ==========================================================================
  // PUBLIC ENTRYPOINT
  // ==========================================================================

  /// Runs every delta pull in sequence. Each pull commits independently —
  /// if `_pullTaxes` fails, the products it already wrote are kept.
  Future<void> pullMasterData(int companyId) async {
    await pullProducts(companyId);
    await pullTaxes(companyId);
    await pullFloorPlans(companyId);
    await pullFloorPlanTables(companyId);
    await pullUsers(companyId);
    await pullAppProperties(companyId);
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

    for (final json in rows.cast<Map<String, dynamic>>()) {
      final id = json['id'] as int;

      // Existing API serves base64 in `image`. ImageSyncHelper handles both
      // base64 and URL transparently — when the backend moves to a CDN, no
      // Flutter change required.
      final localImagePath = await imageHelper.downloadAndSaveImage(
        json['image'] as String?,
        id,
      );

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
              lastModified: Value(_parseLastModified(json['lastModified'])),
            ),
          );
    }

    await _setLastSync(_kProducts, startedAt);
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
        final firstName = json['firstName'] as String?;
        final lastName = json['lastName'] as String?;
        final username = json['username'] as String?;
        final displayName = [firstName, lastName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ')
            .trim();

        batch.insert(
          db.usersTable,
          UsersTableCompanion(
            id: Value(json['id'] as int),
            companyId: Value(json['companyId'] as int? ?? companyId),
            name: Value(displayName.isEmpty ? (username ?? '') : displayName),
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
