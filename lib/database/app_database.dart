import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:uuid/uuid.dart';

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

  // ---- Schema v2 additions (Phase 3.5) ----
  // Every new column is nullable OR has a default so the onUpgrade migration
  // (m.addColumn) succeeds on existing rows without backfill SQL.
  TextColumn get code => text().nullable()();
  IntColumn get plu => integer().nullable()();
  TextColumn get measurementUnit => text().nullable()();
  TextColumn get description => text().nullable()();
  RealColumn get markup => real().nullable()();
  IntColumn get rank => integer().withDefault(const Constant(0))();
  IntColumn get currencyId => integer().nullable()();
  IntColumn get ageRestriction => integer().nullable()();
  RealColumn get lastPurchasePrice => real().nullable()();
  DateTimeColumn get dateCreated => dateTime().nullable()();
  DateTimeColumn get dateUpdated => dateTime().nullable()();
  BoolColumn get isPriceChangeAllowed =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isUsingDefaultQuantity =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get isTaxInclusivePrice =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();

  DateTimeColumn get lastModified => dateTime()();

  // ---- Schema v12 additions ----
  // Offline CRUD queue: 'synced' | 'pending_create' | 'pending_update' | 'pending_delete'
  TextColumn get syncStatus =>
      text().withDefault(const Constant('synced'))();
  TextColumn get syncError => text().nullable()();

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

  // ---- Schema v2 additions (Phase 3.5) ----
  TextColumn get code => text().nullable()();
  BoolColumn get isFixed => boolean().withDefault(const Constant(false))();
  BoolColumn get isTaxOnTotal => boolean().withDefault(const Constant(true))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();

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
  // Combined display name kept for backward compat with old rows that
  // predate the firstName/lastName/username/email columns (added v18).
  TextColumn get name => text()();
  TextColumn get firstName => text().nullable()();
  TextColumn get lastName => text().nullable()();
  TextColumn get username => text().nullable()();
  TextColumn get email => text().nullable()();

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
// PHASE 3.6 — REMAINING MASTER ENTITIES (schema v4)
// These were originally deferred. Adding them so the offline POS screen
// doesn't hang on the four still-API-backed providers.
// ============================================================================

class SecurityKeysTable extends Table {
  @override
  String get tableName => 'security_keys';

  IntColumn get companyId => integer()();
  TextColumn get name => text()();
  // 0 = Cashier-accessible, 1 = Admin-only (matches server SecurityKey.Level)
  IntColumn get level => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {companyId, name};
}

class ProductGroupsTable extends Table {
  @override
  String get tableName => 'product_groups';

  IntColumn get id => integer()();
  IntColumn get companyId => integer()();
  TextColumn get name => text()();
  IntColumn get parentGroupId => integer().nullable()();
  TextColumn get colorHex => text().withDefault(const Constant('Transparent'))();
  IntColumn get rank => integer().withDefault(const Constant(0))();
  // Disk-cached icon path. ImageSyncHelper writes the file under
  // <docs>/group_images/<id>.jpg during pullProductGroups; nothing else
  // touches binary data.
  TextColumn get localImagePath => text().nullable()();
  DateTimeColumn get lastModified => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class PaymentTypesTable extends Table {
  @override
  String get tableName => 'payment_types';

  IntColumn get id => integer()();
  IntColumn get companyId => integer()();
  TextColumn get name => text()();
  TextColumn get code => text().nullable()();
  BoolColumn get isCustomerRequired =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isFiscal => boolean().withDefault(const Constant(false))();
  BoolColumn get isSlipRequired =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isChangeAllowed =>
      boolean().withDefault(const Constant(false))();
  IntColumn get ordinal => integer().withDefault(const Constant(0))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get isQuickPayment =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get openCashDrawer =>
      boolean().withDefault(const Constant(false))();
  TextColumn get shortcutKey => text().nullable()();
  BoolColumn get markAsPaid => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CustomersTable extends Table {
  @override
  String get tableName => 'customers';

  IntColumn get id => integer()();
  IntColumn get companyId => integer()();
  TextColumn get code => text().nullable()();
  TextColumn get name => text()();
  TextColumn get taxNumber => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get postalCode => text().nullable()();
  TextColumn get city => text().nullable()();
  IntColumn get countryId => integer().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get isCustomer => boolean().withDefault(const Constant(true))();
  BoolColumn get isSupplier => boolean().withDefault(const Constant(false))();
  IntColumn get dueDatePeriod => integer().nullable()();
  TextColumn get streetName => text().nullable()();
  TextColumn get additionalStreetName => text().nullable()();
  TextColumn get buildingNumber => text().nullable()();
  TextColumn get plotIdentification => text().nullable()();
  TextColumn get citySubdivisionName => text().nullable()();
  BoolColumn get isTaxExempt => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Single-row-per-id cache so receipts render with the real company name,
/// address, tax number, phone, and logo when offline. Lean schema — only
/// the fields the receipt printer / receipt header actually use. Logo lives
/// on disk via ImageSyncHelper (Phase 1 "images on disk, never in SQLite"
/// rule) — `localLogoPath` is the absolute file path.
class CompaniesTable extends Table {
  @override
  String get tableName => 'companies';

  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get taxNumber => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get localLogoPath => text().nullable()();
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Per-product comment suggestions (e.g. "no onions", "extra cheese") used
/// by the menu grid's tap dialog. Pulled in bulk via /ProductComments/GetAll.
class ProductCommentsTable extends Table {
  @override
  String get tableName => 'product_comments';

  IntColumn get id => integer()();
  IntColumn get companyId => integer()();
  IntColumn get productId => integer()();
  TextColumn get comment => text()();
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PromotionsTable extends Table {
  @override
  String get tableName => 'promotions';

  IntColumn get id => integer()();
  IntColumn get companyId => integer()();
  TextColumn get name => text()();
  IntColumn get daysOfWeek => integer().withDefault(const Constant(127))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get startDate => dateTime().nullable()();
  TextColumn get startTime => text().nullable()(); // "HH:mm:ss"
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get endTime => text().nullable()();
  DateTimeColumn get lastModified => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class PromotionItemsTable extends Table {
  @override
  String get tableName => 'promotion_items';

  IntColumn get id => integer()();          // positive = server id; negative = temp local id
  IntColumn get promotionId => integer()();
  IntColumn get productId => integer()();
  IntColumn get discountType => integer().withDefault(const Constant(0))();
  IntColumn get priceType => integer().withDefault(const Constant(0))();
  RealColumn get value => real().withDefault(const Constant(0))();
  BoolColumn get isConditional => boolean().withDefault(const Constant(false))();
  RealColumn get quantity => real().withDefault(const Constant(1))();
  IntColumn get conditionType => integer().withDefault(const Constant(0))();
  RealColumn get quantityLimit => real().withDefault(const Constant(0))();

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

  // ---- Schema v3 (Phase 4) — checkout finalisation fields ----
  // Required by Phase 5 to POST the completed order to /PosOrder/Checkout.
  // Nullable so the migration succeeds on existing v2 rows (none exist yet
  // in practice — pos_orders is brand-new — but the constraint keeps the
  // upgrade path correct for any draft rows that slipped in).
  IntColumn get paymentTypeId => integer().nullable()();
  RealColumn get amountPaid => real().nullable()();
  IntColumn get customerId => integer().nullable()();

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
  IntColumn get discountType => integer().withDefault(const Constant(0))();
  RealColumn get taxRate => real().withDefault(const Constant(0))();
  // JSON-encoded per-item applied taxes: [{"id":1,"amount":2.50}]
  // Null when the item has no taxes. Used by SyncManager to populate
  // CheckoutItemDto.Taxes so DocumentItemTax rows are created server-side.
  TextColumn get taxesJson => text().nullable()();
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
// STOCKS — local mirror of server Stock rows.
// Pulled during every master-data sync and deducted locally at checkout so
// the UI shows accurate quantities even while offline.
// ============================================================================

class StocksTable extends Table {
  @override
  String get tableName => 'stocks';

  IntColumn get id => integer()();              // server-assigned id
  IntColumn get productId => integer()();
  IntColumn get warehouseId => integer()();
  IntColumn get companyId => integer()();
  RealColumn get quantity =>
      real().withDefault(const Constant(0))();
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================================
// PENDING VOIDS — offline queue for voided orders.
// When a cashier voids an order offline the PosOrder row is deleted locally
// and the void details are queued here. SyncManager pushes the queue to
// POST /PosVoids/Add and DELETE /PosOrder/Delete when connectivity returns.
// ============================================================================

class PendingVoidsTable extends Table {
  @override
  String get tableName => 'pending_voids';

  TextColumn get localId => text()();            // UUID — local PK
  IntColumn get serverOrderId => integer()();    // server PosOrder.Id
  IntColumn get companyId => integer()();
  IntColumn get userId => integer()();
  TextColumn get orderNumber => text()();
  IntColumn get warehouseId => integer()();
  // JSON-encoded list of void items (same shape as the /PosVoids/Add params).
  TextColumn get itemsJson => text()();
  TextColumn get reason => text().nullable()();
  DateTimeColumn get voidedAt => dateTime()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {localId};
}

// ============================================================================
// DOCUMENTS — offline sales receipts.
// Created locally at checkout; serverId + number filled in after BatchSync
// confirms the server Document was created.  Pulled from server on every
// sync so documents from other devices appear in local history.
// ============================================================================

class DocumentsTable extends Table {
  @override
  String get tableName => 'documents';

  TextColumn get localId => text()();              // UUID — local PK (= PosOrder localId)
  IntColumn get serverId => integer().nullable()(); // server Document.Id — null until synced
  IntColumn get companyId => integer()();
  IntColumn get documentTypeId => integer().withDefault(const Constant(2))(); // 2 = Sales
  TextColumn get number => text().nullable()();    // server-assigned document number
  IntColumn get userId => integer()();
  IntColumn get warehouseId => integer()();
  RealColumn get total => real().withDefault(const Constant(0))();
  RealColumn get discount => real().withDefault(const Constant(0))();
  IntColumn get discountType => integer().withDefault(const Constant(0))();
  IntColumn get customerId => integer().nullable()();
  TextColumn get orderNumber => text().nullable()();
  IntColumn get serviceType => integer().withDefault(const Constant(0))();
  IntColumn get paidStatus => integer().withDefault(const Constant(1))(); // 1=paid, 0=unpaid
  DateTimeColumn get date => dateTime()();
  // 'pending' until BatchSync confirms Document on server; 'synced' after.
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {localId};
}

class DocumentItemsTable extends Table {
  @override
  String get tableName => 'document_items';

  TextColumn get localId => text()();
  // FK → documents.localId; cascade so deleting a Document removes its items.
  TextColumn get documentId =>
      text().references(DocumentsTable, #localId,
          onDelete: KeyAction.cascade)();
  IntColumn get productId => integer()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get discount => real().withDefault(const Constant(0))();
  IntColumn get discountType => integer().withDefault(const Constant(0))();
  RealColumn get total => real()();
  RealColumn get taxAmount => real().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {localId};
}

class PaymentsTable extends Table {
  @override
  String get tableName => 'payments';

  TextColumn get localId => text()();
  // FK → documents.localId
  TextColumn get documentId =>
      text().references(DocumentsTable, #localId,
          onDelete: KeyAction.cascade)();
  IntColumn get paymentTypeId => integer()();
  RealColumn get amount => real()();
  IntColumn get userId => integer()();
  DateTimeColumn get date => dateTime()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {localId};
}

// ============================================================================
// BARCODES — per-product barcode list.
// Seeded from /Barcodes/GetByProductId when the product editor opens.
// Adds and deletes are written locally first with a pending syncStatus so
// they appear immediately in the UI and SyncManager pushes them on next sync.
// ============================================================================

class BarcodesTable extends Table {
  @override
  String get tableName => 'barcodes';

  TextColumn get localId => text()();           // UUID — local PK
  IntColumn get serverId => integer().nullable()(); // null until synced
  IntColumn get productId => integer()();
  IntColumn get companyId => integer()();
  TextColumn get value => text()();
  // 'synced' | 'pending_create' | 'pending_delete'
  TextColumn get syncStatus =>
      text().withDefault(const Constant('synced'))();

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
// PENDING USER & SECURITY-KEY OPS — offline write queue.
// Rows are written when toggle / edit / security-key changes hit a network
// error. SyncManager drains this table via pushPendingUserOps() on every sync.
// 'operation' values: 'toggle_user' | 'update_user' | 'update_security_key'
// ============================================================================

class PendingUserOpsTable extends Table {
  @override
  String get tableName => 'pending_user_ops';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get operation => text()();
  IntColumn get companyId => integer()();
  TextColumn get payload => text()(); // JSON-encoded op params
}

// ============================================================================
// DATABASE
// ============================================================================

@DriftDatabase(
  tables: [
    SecurityKeysTable,
    PendingUserOpsTable,
    ProductsTable,
    TaxesTable,
    FloorPlansTable,
    FloorPlanTablesTable,
    UsersTable,
    AppPropertiesTable,
    ProductGroupsTable,
    PaymentTypesTable,
    CustomersTable,
    PromotionsTable,
    PromotionItemsTable,
    ProductCommentsTable,
    CompaniesTable,
    PosOrdersTable,
    PosOrderItemsTable,
    CashMovementsTable,
    ZReportsTable,
    SyncMetaTable,
    StocksTable,
    PendingVoidsTable,
    DocumentsTable,
    DocumentItemsTable,
    PaymentsTable,
    BarcodesTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 18;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v1 -> v2: Phase 3.5 schema bump — full admin field coverage for
          // Products and Taxes so the admin screens can stream from Drift.
          // Each addColumn targets either a nullable column or one with a
          // default, so existing rows remain valid without backfill.
          if (from < 2) {
            await m.addColumn(productsTable, productsTable.code);
            await m.addColumn(productsTable, productsTable.plu);
            await m.addColumn(productsTable, productsTable.measurementUnit);
            await m.addColumn(productsTable, productsTable.description);
            await m.addColumn(productsTable, productsTable.markup);
            await m.addColumn(productsTable, productsTable.rank);
            await m.addColumn(productsTable, productsTable.currencyId);
            await m.addColumn(productsTable, productsTable.ageRestriction);
            await m.addColumn(productsTable, productsTable.lastPurchasePrice);
            await m.addColumn(productsTable, productsTable.dateCreated);
            await m.addColumn(productsTable, productsTable.dateUpdated);
            await m.addColumn(
                productsTable, productsTable.isPriceChangeAllowed);
            await m.addColumn(
                productsTable, productsTable.isUsingDefaultQuantity);
            await m.addColumn(
                productsTable, productsTable.isTaxInclusivePrice);
            await m.addColumn(productsTable, productsTable.isEnabled);

            await m.addColumn(taxesTable, taxesTable.code);
            await m.addColumn(taxesTable, taxesTable.isFixed);
            await m.addColumn(taxesTable, taxesTable.isTaxOnTotal);
            await m.addColumn(taxesTable, taxesTable.isEnabled);

            // After adding columns, the next master-data pull repopulates
            // them with real values. Until then admin screens see defaults.
          }

          // v2 -> v3: Phase 4 — offline checkout finalisation fields on
          // pos_orders. These travel with the order on the next BatchSync push.
          if (from < 3) {
            await m.addColumn(posOrdersTable, posOrdersTable.paymentTypeId);
            await m.addColumn(posOrdersTable, posOrdersTable.amountPaid);
            await m.addColumn(posOrdersTable, posOrdersTable.customerId);
          }

          // v3 -> v4: Emergency Phase 3.6 — the four master entities that
          // were left API-backed (ProductGroups, PaymentTypes, Customers,
          // Promotions). createTable is safe even when the table already
          // exists thanks to Drift's IF NOT EXISTS, but onUpgrade only runs
          // from < new, so first-launch installs hit onCreate instead and
          // skip this branch.
          if (from < 4) {
            await m.createTable(productGroupsTable);
            await m.createTable(paymentTypesTable);
            await m.createTable(customersTable);
            await m.createTable(promotionsTable);
          }

          // v4 -> v5: Company offline cache. Single-row-per-company lean
          // schema so receipts render with real branding (name/address/tax
          // number/phone/logo) when offline.
          //
          // DROP IF EXISTS handles a quirk of this migration's history:
          // an earlier draft of v5 shipped a different (20-field) schema.
          // If a dev machine already ran that draft, we recreate the table
          // with the lean shape. Cache loss is fine — pullCompany refills
          // it on the next sync.
          if (from < 5) {
            await customStatement('DROP TABLE IF EXISTS companies');
            await m.createTable(companiesTable);
          }

          // v5 -> v6: Phase 3.9 — disk cache for product group icons. Same
          // pattern as Product.localImagePath; ImageSyncHelper writes under
          // `group_images/<id>.jpg` during pullProductGroups.
          if (from < 6) {
            await m.addColumn(
                productGroupsTable, productGroupsTable.localImagePath);
          }

          // v6 -> v7: ProductComments offline cache — the per-product
          // "extra cheese / no onions" suggestion list, used by the tap
          // dialog. New table only, no existing data to migrate.
          if (from < 7) {
            await m.createTable(productCommentsTable);
          }

          // v7 -> v8: Stocks offline cache so local inventory is checked and
          // deducted at checkout even without a network connection.
          // pullStocks() re-seeds this on the next successful sync.
          if (from < 8) {
            await m.createTable(stocksTable);
          }

          // v8 -> v9: Pending voids queue — offline void support.
          if (from < 9) {
            await m.createTable(pendingVoidsTable);
          }

          // v9 -> v10: Offline documents, items, and payments.
          // Documents are created locally at checkout and pulled from the
          // server on every sync so history is always available offline.
          if (from < 10) {
            await m.createTable(documentsTable);
            await m.createTable(documentItemsTable);
            await m.createTable(paymentsTable);
          }

          // v10 -> v11: Per-item offline tax and discount-type storage.
          // taxesJson holds [{"id":1,"amount":2.50}] so SyncManager can
          // populate CheckoutItemDto.Taxes on BatchSync, creating
          // DocumentItemTax rows server-side.
          // discountType was hardcoded to 0 in BatchSync — now persisted.
          if (from < 11) {
            await customStatement(
                'ALTER TABLE pos_order_items ADD COLUMN discount_type INTEGER NOT NULL DEFAULT 0');
            await customStatement(
                'ALTER TABLE pos_order_items ADD COLUMN taxes_json TEXT');
          }

          // v11 -> v12: Offline product CRUD queue.
          // syncStatus tracks pending creates/updates/deletes so SyncManager
          // can push them to the server when connectivity returns.
          // pending_create rows use a negative temp id until server confirms.
          if (from < 12) {
            await customStatement(
                "ALTER TABLE products ADD COLUMN sync_status TEXT NOT NULL DEFAULT 'synced'");
            await customStatement(
                'ALTER TABLE products ADD COLUMN sync_error TEXT');
          }

          // v12 -> v13: Offline barcode CRUD.
          // Barcodes are written locally first (pending_create / pending_delete)
          // and pushed to /Barcodes/Add+Delete on the next sync.
          if (from < 13) {
            await customStatement('''
              CREATE TABLE IF NOT EXISTS barcodes (
                local_id TEXT NOT NULL PRIMARY KEY,
                server_id INTEGER,
                product_id INTEGER NOT NULL,
                company_id INTEGER NOT NULL,
                value TEXT NOT NULL,
                sync_status TEXT NOT NULL DEFAULT \'synced\'
              )
            ''');
          }

          // v14: Promotions become offline-first.
          // sync_status/sync_error drive the push pipeline for CRUD ops.
          // promotion_items stores per-product discount config so
          // activePromotionsProvider can apply discounts offline.
          // v15: Product groups become offline-first (create/update/delete).
          if (from < 15) {
            await customStatement(
                "ALTER TABLE product_groups ADD COLUMN sync_status TEXT NOT NULL DEFAULT 'synced'");
            await customStatement(
                'ALTER TABLE product_groups ADD COLUMN sync_error TEXT');
          }

          if (from < 14) {
            await customStatement(
                "ALTER TABLE promotions ADD COLUMN sync_status TEXT NOT NULL DEFAULT 'synced'");
            await customStatement(
                'ALTER TABLE promotions ADD COLUMN sync_error TEXT');
            await customStatement('''
              CREATE TABLE IF NOT EXISTS promotion_items (
                id INTEGER NOT NULL PRIMARY KEY,
                promotion_id INTEGER NOT NULL,
                product_id INTEGER NOT NULL,
                discount_type INTEGER NOT NULL DEFAULT 0,
                price_type INTEGER NOT NULL DEFAULT 0,
                value REAL NOT NULL DEFAULT 0,
                is_conditional INTEGER NOT NULL DEFAULT 0,
                quantity REAL NOT NULL DEFAULT 1,
                condition_type INTEGER NOT NULL DEFAULT 0,
                quantity_limit REAL NOT NULL DEFAULT 0
              )
            ''');
          }

          // v16: Security keys offline cache.
          // Pulled from /SecurityKeys/GetAll on every master-data sync so
          // SecurityGuard can enforce RBAC without a network round-trip.
          if (from < 16) {
            await customStatement('''
              CREATE TABLE IF NOT EXISTS security_keys (
                company_id INTEGER NOT NULL,
                name TEXT NOT NULL,
                level INTEGER NOT NULL DEFAULT 0,
                PRIMARY KEY (company_id, name)
              )
            ''');
          }

          // v17: Pending user / security-key ops queue.
          // Written when toggle-user, edit-user, or update-security-key fails
          // due to no connectivity. SyncManager drains it on next online sync.
          if (from < 17) {
            await customStatement('''
              CREATE TABLE IF NOT EXISTS pending_user_ops (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                operation TEXT NOT NULL,
                company_id INTEGER NOT NULL,
                payload TEXT NOT NULL
              )
            ''');
          }

          // v18: Full user fields — email, username, firstName, lastName.
          // These were missing from the original schema; all are nullable so
          // existing rows stay valid. pullUsers + seedUsersFromApiProvider
          // populate them on the next sync.
          if (from < 18) {
            await customStatement(
                'ALTER TABLE users ADD COLUMN first_name TEXT');
            await customStatement(
                'ALTER TABLE users ADD COLUMN last_name TEXT');
            await customStatement(
                'ALTER TABLE users ADD COLUMN username TEXT');
            await customStatement('ALTER TABLE users ADD COLUMN email TEXT');
          }
        },
        beforeOpen: (details) async {
          // Enforce FK constraints (off by default in SQLite).
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Persists a completed offline order and its line items in a single
  /// transaction. Either both inserts succeed or neither does — so a partial
  /// failure can never leave a header row with no items (or vice versa).
  ///
  /// Caller is responsible for setting `localId` on the order and `orderId`
  /// on each item to the matching UUID, plus `syncStatus = 'pending'` so
  /// Phase 5's push picks the row up.
  Future<void> insertOfflineOrder(
    PosOrdersTableCompanion order,
    List<PosOrderItemsTableCompanion> items,
  ) {
    return transaction(() async {
      await into(posOrdersTable).insert(order);
      if (items.isNotEmpty) {
        await batch((b) {
          b.insertAll(posOrderItemsTable, items);
        });
      }
    });
  }

  /// Completes an existing open order that was loaded from the server and paid
  /// offline. Updates the header row in place and replaces its items so the row
  /// reflects the final paid state. The caller sets syncStatus = 'pending' so
  /// BatchSync pushes the completion to the server on the next sync.
  Future<void> completeExistingOrder(
    String localId,
    PosOrdersTableCompanion orderUpdate,
    List<PosOrderItemsTableCompanion> newItems,
  ) {
    return transaction(() async {
      await (update(posOrdersTable)..where((t) => t.localId.equals(localId)))
          .write(orderUpdate);
      await (delete(posOrderItemsTable)
            ..where((t) => t.orderId.equals(localId)))
          .go();
      if (newItems.isNotEmpty) {
        await batch((b) {
          b.insertAll(posOrderItemsTable, newItems);
        });
      }
    });
  }

  // ==========================================================================
  // PHASE 5 — PUSH SYNC HELPERS
  // ==========================================================================

  /// Checks local stock and deducts quantities for a completed checkout.
  ///
  /// Returns `(success: true)` when every item was deducted.
  /// Returns `(success: false, message: '...')` when a product is out of stock
  /// and [allowNegative] is false — the caller should show a blocking dialog.
  ///
  /// Service products (isService = true) are always skipped.
  /// Products with no local stock record are skipped (treated as untracked).
  Future<({bool success, String? message})> deductStockForCheckout({
    required List<({
      int productId,
      double quantity,
      int warehouseId,
      bool isService,
      String productName,
    })> items,
    required bool allowNegative,
  }) async {
    // Pre-flight: check all items before touching any stock row.
    if (!allowNegative) {
      for (final item in items) {
        if (item.isService) continue;
        final stock = await (select(stocksTable)
              ..where((t) => t.productId.equals(item.productId))
              ..where((t) => t.warehouseId.equals(item.warehouseId))
              ..limit(1))
            .getSingleOrNull();
        if (stock == null) continue; // untracked product — allow
        if (stock.quantity < item.quantity) {
          return (
            success: false,
            message:
                '${item.productName} is out of stock '
                '(available: ${stock.quantity.toStringAsFixed(2)}, '
                'needed: ${item.quantity.toStringAsFixed(2)}).',
          );
        }
      }
    }

    // Deduct pass — runs only when the pre-flight passed (or allowNegative).
    await transaction(() async {
      for (final item in items) {
        if (item.isService) continue;
        final stock = await (select(stocksTable)
              ..where((t) => t.productId.equals(item.productId))
              ..where((t) => t.warehouseId.equals(item.warehouseId))
              ..limit(1))
            .getSingleOrNull();
        if (stock == null) continue;
        await (update(stocksTable)..where((t) => t.id.equals(stock.id))).write(
          StocksTableCompanion(
            quantity: Value(stock.quantity - item.quantity),
            lastModified: Value(DateTime.now().toUtc()),
          ),
        );
      }
    });

    return (success: true, message: null);
  }

  // ─── Documents / Payments ─────────────────────────────────────────────────

  /// Saves a completed sale to local SQLite in a single atomic transaction:
  /// Document header + line items + payment record.
  /// The Document localId MUST equal the PosOrder localId so sync_manager
  /// can call [linkDocumentToServer] by the same key after BatchSync.
  Future<void> insertOfflineDocument({
    required DocumentsTableCompanion document,
    required List<DocumentItemsTableCompanion> items,
    required PaymentsTableCompanion payment,
  }) {
    return transaction(() async {
      await into(documentsTable).insert(document);
      if (items.isNotEmpty) {
        await batch((b) { b.insertAll(documentItemsTable, items); });
      }
      await into(paymentsTable).insert(payment);
    });
  }

  /// Called after BatchSync succeeds: stamps the server Document.Id onto the
  /// locally-created Document and flips syncStatus to 'synced'.
  Future<void> linkDocumentToServer(String localId, int documentServerId) {
    return transaction(() async {
      await (update(documentsTable)
            ..where((t) => t.localId.equals(localId)))
          .write(DocumentsTableCompanion(
        serverId:    Value(documentServerId),
        syncStatus:  const Value('synced'),
        lastModified: Value(DateTime.now().toUtc()),
      ));
    });
  }

  /// Returns all Documents for a company ordered newest-first.
  /// Used by the Sales History screen — reads local SQLite, no network needed.
  Future<List<DocumentsTableData>> getDocuments({
    required int companyId,
    DateTime? from,
    DateTime? to,
    int? userId,
    int? customerId,
  }) {
    final query = select(documentsTable)
      ..where((t) => t.companyId.equals(companyId));
    if (from != null) query.where((t) => t.date.isBiggerOrEqualValue(from));
    if (to   != null) query.where((t) => t.date.isSmallerOrEqualValue(to));
    if (userId   != null) query.where((t) => t.userId.equals(userId));
    if (customerId != null) query.where((t) => t.customerId.equals(customerId));
    query.orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.get();
  }

  /// Returns all line items for a given Document localId.
  Future<List<DocumentItemsTableData>> getDocumentItems(String documentLocalId) =>
      (select(documentItemsTable)
            ..where((t) => t.documentId.equals(documentLocalId)))
          .get();

  /// Returns all Payments for a given Document localId.
  Future<List<PaymentsTableData>> getPayments(String documentLocalId) =>
      (select(paymentsTable)
            ..where((t) => t.documentId.equals(documentLocalId)))
          .get();

  /// Upserts a Document + items + payment pulled from the server.
  /// localId is fabricated as 'srv_<serverId>' for server-originated rows.
  Future<void> upsertServerDocument({
    required DocumentsTableCompanion document,
    required List<DocumentItemsTableCompanion> items,
  }) {
    return transaction(() async {
      await into(documentsTable).insertOnConflictUpdate(document);
      // Replace items — simpler than diffing for server-pulled data.
      await (delete(documentItemsTable)
            ..where((t) => t.documentId.equals(document.localId.value)))
          .go();
      if (items.isNotEmpty) {
        await batch((b) { b.insertAll(documentItemsTable, items); });
      }
    });
  }

  /// Queues a voided order for server sync and deletes the local open-order row.
  /// Items cascade-delete via the FK. The caller should also restore local
  /// stock quantities (via deductStockForCheckout with negative quantities or
  /// a dedicated helper) so the UI reflects the freed inventory immediately.
  Future<void> queueVoidAndDeleteOrder({
    required String localId,
    required int serverOrderId,
    required int companyId,
    required int userId,
    required String orderNumber,
    required int warehouseId,
    required String itemsJson,
    String? reason,
  }) {
    return transaction(() async {
      await into(pendingVoidsTable).insert(
        PendingVoidsTableCompanion(
          localId:       Value(const Uuid().v4()),
          serverOrderId: Value(serverOrderId),
          companyId:     Value(companyId),
          userId:        Value(userId),
          orderNumber:   Value(orderNumber),
          warehouseId:   Value(warehouseId),
          itemsJson:     Value(itemsJson),
          reason:        Value(reason),
          voidedAt:      Value(DateTime.now().toUtc()),
        ),
      );
      // Delete the open-order row (cascade removes its items too).
      await (delete(posOrdersTable)
            ..where((t) => t.localId.equals(localId)))
          .go();
    });
  }

  /// Returns all pending voids that haven't been synced to the server yet.
  Future<List<PendingVoidsTableData>> getPendingVoids() =>
      (select(pendingVoidsTable)
            ..where((t) => t.syncStatus.equals('pending')))
          .get();

  /// Marks a void as synced after the server confirms both the PosVoid records
  /// and the PosOrder deletion were processed successfully.
  Future<void> markVoidSynced(String localId) =>
      (update(pendingVoidsTable)..where((t) => t.localId.equals(localId)))
          .write(const PendingVoidsTableCompanion(
        syncStatus: Value('synced'),
      ));

  /// Deletes a completed order and its items from local SQLite after the
  /// server confirms the Document + Payment were created. Items are removed
  /// automatically by the CASCADE FK on `pos_order_items.order_id`.
  Future<void> deleteCompletedOrder(String localId) {
    return (delete(posOrdersTable)
          ..where((t) => t.localId.equals(localId)))
        .go();
  }

  /// Upserts an open (status=0) order and replaces its items atomically.
  /// Used by the offline-first SAVE button — creates a new local row the
  /// first time and updates it on every subsequent re-save.
  Future<void> saveOpenOrder(
    PosOrdersTableCompanion order,
    List<PosOrderItemsTableCompanion> newItems,
  ) {
    return transaction(() async {
      await into(posOrdersTable).insertOnConflictUpdate(order);
      await (delete(posOrderItemsTable)
            ..where((t) => t.orderId.equals(order.localId.value)))
          .go();
      if (newItems.isNotEmpty) {
        await batch((b) {
          b.insertAll(posOrderItemsTable, newItems);
        });
      }
    });
  }

  /// Stamps the server-assigned id on a row mid-sync without flipping
  /// syncStatus to 'synced' yet. Lets pushPendingOpenOrders record the
  /// server id after `POST /PosOrder/Create` succeeds but before
  /// `POST /PosOrderItem/BulkAdd` completes, so a crash between the two
  /// steps restarts at the item-add phase rather than re-creating the header.
  Future<void> setServerId(String localId, int serverId) {
    return (update(posOrdersTable)..where((t) => t.localId.equals(localId)))
        .write(PosOrdersTableCompanion(serverId: Value(serverId)));
  }

  /// Returns every COMPLETED (status=1) pending order together with its items.
  /// Used by SyncManager.pushPendingOrders → BatchSync.
  Future<List<PosOrderWithItems>> getPendingOrders() async {
    final orders = await (select(posOrdersTable)
          ..where((t) => t.syncStatus.equals('pending'))
          ..where((t) => t.status.equals(1)))
        .get();

    if (orders.isEmpty) return const [];

    final result = <PosOrderWithItems>[];
    for (final order in orders) {
      final items = await (select(posOrderItemsTable)
            ..where((t) => t.orderId.equals(order.localId)))
          .get();
      result.add(PosOrderWithItems(order: order, items: items));
    }
    return result;
  }

  /// Returns every OPEN (status=0) pending order together with its items.
  /// Used by SyncManager.pushPendingOpenOrders to create/update orders on the
  /// server without going through BatchSync (which is for completed orders).
  Future<List<PosOrderWithItems>> getPendingOpenOrders() async {
    final orders = await (select(posOrdersTable)
          ..where((t) => t.syncStatus.equals('pending'))
          ..where((t) => t.status.equals(0)))
        .get();

    if (orders.isEmpty) return const [];

    final result = <PosOrderWithItems>[];
    for (final order in orders) {
      final items = await (select(posOrderItemsTable)
            ..where((t) => t.orderId.equals(order.localId)))
          .get();
      result.add(PosOrderWithItems(order: order, items: items));
    }
    return result;
  }

  /// Stamp the row with the server-assigned id and flip the status. Called
  /// after a successful BatchSync result. Items are flipped too so failed-
  /// retry queries don't surface them again.
  Future<void> markOrderSynced(String localId, int serverId) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      await (update(posOrdersTable)
            ..where((t) => t.localId.equals(localId)))
          .write(PosOrdersTableCompanion(
        serverId: Value(serverId),
        syncStatus: const Value('synced'),
        syncError: const Value(null),
        lastModified: Value(now),
      ));
      await (update(posOrderItemsTable)
            ..where((t) => t.orderId.equals(localId)))
          .write(const PosOrderItemsTableCompanion(
        syncStatus: Value('synced'),
      ));
    });
  }

  /// Record a failure on the order header. The row stays in the DB and the
  /// user can retry it from the Failed Syncs screen (planned).
  Future<void> markOrderFailed(String localId, String errorMessage) {
    return (update(posOrdersTable)
          ..where((t) => t.localId.equals(localId)))
        .write(PosOrdersTableCompanion(
      syncStatus: const Value('failed'),
      syncError: Value(errorMessage),
      lastModified: Value(DateTime.now().toUtc()),
    ));
  }
}

/// Pairs a pos_orders row with its line items. Plain Dart so callers
/// (SyncManager, future Failed Syncs screen) don't need Drift internals.
class PosOrderWithItems {
  final PosOrdersTableData order;
  final List<PosOrderItemsTableData> items;

  const PosOrderWithItems({required this.order, required this.items});
}

// ============================================================================
// PHASE 7 — CASH MOVEMENT + Z-REPORT OFFLINE QUEUE HELPERS
// Mounted as a Dart extension so the AppDatabase class stays readable. All
// of these helpers follow the same contract as the order queue:
//   - insertOffline* generates the UUID if the caller didn't supply one and
//     forces syncStatus='pending' / serverId=null so the row is picked up by
//     the next sync push.
//   - getPending* returns rows where syncStatus='pending'.
//   - mark*Synced flips the row to 'synced' and stamps the serverId.
//   - mark*Failed records the error and flips to 'failed' for retry.
// ============================================================================
extension OfflineQueueHelpers on AppDatabase {
  // ---------------- CASH MOVEMENTS ----------------

  Future<void> insertOfflineCashMovement(
      CashMovementsTableCompanion movement) async {
    final localId = movement.localId.present && movement.localId.value.isNotEmpty
        ? movement.localId.value
        : const Uuid().v4();

    await into(cashMovementsTable).insert(
      movement.copyWith(
        localId: Value(localId),
        serverId: const Value(null),
        syncStatus: const Value('pending'),
        syncError: const Value(null),
      ),
    );
  }

  Future<List<CashMovementsTableData>> getPendingCashMovements() {
    return (select(cashMovementsTable)
          ..where((t) => t.syncStatus.equals('pending')))
        .get();
  }

  Future<void> markCashMovementSynced(String localId, int serverId) {
    return (update(cashMovementsTable)
          ..where((t) => t.localId.equals(localId)))
        .write(CashMovementsTableCompanion(
      serverId: Value(serverId),
      syncStatus: const Value('synced'),
      syncError: const Value(null),
    ));
  }

  Future<void> markCashMovementFailed(String localId, String errorMessage) {
    return (update(cashMovementsTable)
          ..where((t) => t.localId.equals(localId)))
        .write(CashMovementsTableCompanion(
      syncStatus: const Value('failed'),
      syncError: Value(errorMessage),
    ));
  }

  // ---------------- Z-REPORTS ----------------

  Future<void> insertOfflineZReport(ZReportsTableCompanion report) async {
    final localId = report.localId.present && report.localId.value.isNotEmpty
        ? report.localId.value
        : const Uuid().v4();

    await into(zReportsTable).insert(
      report.copyWith(
        localId: Value(localId),
        serverId: const Value(null),
        syncStatus: const Value('pending'),
        syncError: const Value(null),
      ),
    );
  }

  Future<List<ZReportsTableData>> getPendingZReports() {
    return (select(zReportsTable)
          ..where((t) => t.syncStatus.equals('pending')))
        .get();
  }

  Future<void> markZReportSynced(String localId, int serverId) {
    return (update(zReportsTable)
          ..where((t) => t.localId.equals(localId)))
        .write(ZReportsTableCompanion(
      serverId: Value(serverId),
      syncStatus: const Value('synced'),
      syncError: const Value(null),
    ));
  }

  Future<void> markZReportFailed(String localId, String errorMessage) {
    return (update(zReportsTable)
          ..where((t) => t.localId.equals(localId)))
        .write(ZReportsTableCompanion(
      syncStatus: const Value('failed'),
      syncError: Value(errorMessage),
    ));
  }
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
