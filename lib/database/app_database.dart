import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'app_database.g.dart';

// ============================================================================
// MASTER DATA — server-assigned `id` is the PK. `lastModified` is the per-row
// watermark we compare against `modifiedAfter` on delta pulls.
// ============================================================================

class ProductsTable extends Table {
  @override
  String get tableName => 'products';

  IntColumn get id => integer()();
  IntColumn get companyId => integer()();
  TextColumn get name => text()();
  RealColumn get price => real().withDefault(const Constant(0))();
  RealColumn get cost => real().withDefault(const Constant(0))();
  TextColumn get barcode => text().nullable()();
  IntColumn get productGroupId => integer().nullable()();
  BoolColumn get isService => boolean().withDefault(const Constant(false))();
  TextColumn get colorHex => text().nullable()();

  // Plan constraint: images live on disk, NEVER as BlobColumn.
  // Holds the absolute file path returned by ImageCacheService.
  TextColumn get localImagePath => text().nullable()();

  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class TaxesTable extends Table {
  @override
  String get tableName => 'taxes';

  IntColumn get id => integer()();
  IntColumn get companyId => integer()();
  TextColumn get name => text()();
  RealColumn get rate => real()();
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class FloorPlansTable extends Table {
  @override
  String get tableName => 'floor_plans';

  IntColumn get id => integer()();
  IntColumn get companyId => integer()();
  TextColumn get name => text()();
  TextColumn get color => text().withDefault(const Constant('Transparent'))();
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class FloorPlanTablesTable extends Table {
  @override
  String get tableName => 'floor_plan_tables';

  IntColumn get id => integer()();
  IntColumn get companyId => integer()();
  IntColumn get floorPlanId => integer()();
  TextColumn get name => text()();
  RealColumn get positionX => real()();
  RealColumn get positionY => real()();
  RealColumn get width => real()();
  RealColumn get height => real()();
  BoolColumn get isRound => boolean().withDefault(const Constant(false))();
  IntColumn get status => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class UsersTable extends Table {
  @override
  String get tableName => 'users';

  IntColumn get id => integer()();
  IntColumn get companyId => integer()();
  TextColumn get name => text()();

  // Plan rule: only ever store the hash. The C# /Users/GetAll endpoint
  // must serve `pinHash`, NEVER the raw password.
  TextColumn get pinHash => text().nullable()();

  IntColumn get role => integer().withDefault(const Constant(0))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppPropertiesTable extends Table {
  @override
  String get tableName => 'app_properties';

  IntColumn get id => integer()();
  IntColumn get companyId => integer()();
  TextColumn get name => text()();
  TextColumn get value => text().nullable()();
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================================
// TRANSACTION DATA — created offline-first. `localId` (UUID v4) is the PK so
// the row is referenceable BEFORE the server assigns `serverId`. `syncStatus`
// drives the push pipeline: pending → synced | failed.
// ============================================================================

class PosOrdersTable extends Table {
  @override
  String get tableName => 'pos_orders';

  TextColumn get localId => text()();
  IntColumn get serverId => integer().nullable()();
  IntColumn get companyId => integer()();
  IntColumn get userId => integer()();
  IntColumn get tableId => integer().nullable()();
  IntColumn get serviceType => integer()();
  IntColumn get serviceStatus => integer().withDefault(const Constant(0))();
  TextColumn get orderName => text().nullable()();
  DateTimeColumn get openedAt => dateTime()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  IntColumn get status => integer().withDefault(const Constant(0))();
  RealColumn get total => real().nullable()();
  RealColumn get discount => real().withDefault(const Constant(0))();
  IntColumn get warehouseId => integer()();

  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
  TextColumn get syncError => text().nullable()();
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {localId};
}

class PosOrderItemsTable extends Table {
  @override
  String get tableName => 'pos_order_items';

  TextColumn get localId => text()();
  TextColumn get orderId =>
      text().references(PosOrdersTable, #localId, onDelete: KeyAction.cascade)();
  IntColumn get productId => integer()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get taxRate => real().withDefault(const Constant(0))();
  TextColumn get comment => text().nullable()();
  IntColumn get warehouseId => integer()();

  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {localId};
}

class CashMovementsTable extends Table {
  @override
  String get tableName => 'cash_movements';

  TextColumn get localId => text()();
  IntColumn get serverId => integer().nullable()();
  IntColumn get companyId => integer()();
  IntColumn get userId => integer()();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // 'in' | 'out'
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column> get primaryKey => {localId};
}

class ZReportsTable extends Table {
  @override
  String get tableName => 'z_reports';

  TextColumn get localId => text()();
  IntColumn get serverId => integer().nullable()();
  IntColumn get companyId => integer()();
  IntColumn get userId => integer()();
  RealColumn get totalSales => real()();
  RealColumn get totalCashIn => real()();
  RealColumn get totalCashOut => real()();
  TextColumn get paymentBreakdownJson => text()(); // serialized JSON map
  DateTimeColumn get closedAt => dateTime()();

  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column> get primaryKey => {localId};
}

// ============================================================================
// SYNC METADATA — one row per entity; holds the watermark we send as
// `modifiedAfter` on the next delta pull.
// ============================================================================

class SyncMetaTable extends Table {
  @override
  String get tableName => 'sync_meta';

  // Renamed from `entityName` — Drift's TableInfo base class already exposes
  // `entityName` (the SQL table name), and a column getter with the same name
  // is a hard override conflict.
  TextColumn get entity => text()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {entity};
}

// ============================================================================
// DATABASE
// ============================================================================

@DriftDatabase(
  tables: [
    ProductsTable,
    TaxesTable,
    FloorPlansTable,
    FloorPlanTablesTable,
    UsersTable,
    AppPropertiesTable,
    PosOrdersTable,
    PosOrderItemsTable,
    CashMovementsTable,
    ZReportsTable,
    SyncMetaTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        beforeOpen: (details) async {
          // Enforce FK constraints (off by default in SQLite).
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // sqlite3_flutter_libs ships a tested SQLite build; this avoids
    // version skew on Android devices that ship older sqlite.
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'pos_app.sqlite'));

    // createInBackground spawns an isolate for DB I/O — keeps UI smooth
    // during the Phase 2 seed of all products + images.
    return NativeDatabase.createInBackground(
      file,
      logStatements: false, // flip to true while debugging
    );
  });
}
