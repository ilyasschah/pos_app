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

@TableIndex(name: 'idx_products_group_id', columns: {#productGroupId})
@TableIndex(name: 'idx_products_barcode',  columns: {#barcode})
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

  /// 'synced' once the server has the current value; 'pending' after an offline
  /// edit so the sync engine knows to push it on reconnect.
  TextColumn get syncStatus =>
      text().withDefault(const Constant('synced'))();

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
  // Offline CRUD queue: 'synced' | 'pending_create' | 'pending_update' | 'pending_delete'
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  TextColumn get syncError => text().nullable()();

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

@TableIndex(name: 'idx_pos_orders_sync_status', columns: {#syncStatus})
@TableIndex(name: 'idx_pos_orders_status',      columns: {#status})
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
  // 0 = Percentage, 1 = Fixed — mirrors CartState.manualCartDiscountType.
  IntColumn get discountType => integer().withDefault(const Constant(0))();
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

@TableIndex(name: 'idx_pos_order_items_order_id', columns: {#orderId})
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

// Offline tax breakdown — one row per item × tax-rate per saved order.
// Populated inside saveOpenOrder so the receipt and sync paths have itemised
// tax amounts without re-computing them from CartItem state.
@TableIndex(name: 'idx_pos_order_item_taxes_order_id', columns: {#orderId})
class PosOrderItemTaxesTable extends Table {
  @override
  String get tableName => 'pos_order_item_taxes';

  TextColumn get localId => text()();
  TextColumn get orderId =>
      text().references(PosOrdersTable, #localId, onDelete: KeyAction.cascade)();
  IntColumn get productId => integer()();
  IntColumn get taxRateId => integer()();
  RealColumn get taxAmount => real()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {localId};
}

/// Local mirror of the server's `StartingCash` table (cash in / out).
/// Named to match the SQL Server entity; the physical SQLite table follows
/// the local snake_case convention (`starting_cash`).
class StartingCashTable extends Table {
  @override
  String get tableName => 'starting_cash';

  TextColumn get localId => text()();
  IntColumn get serverId => integer().nullable()();
  IntColumn get companyId => integer()();
  IntColumn get userId => integer()();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // 'in' | 'out'
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  /// Server Z-report number (mirrors `StartingCash.ZReportNumber`). NULL while
  /// the entry is active/unfinalized; once a Z-report is generated the server
  /// stamps this and the next pull hides the row from the active list.
  IntColumn get zReportNumber => integer().nullable()();

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
  // Offline-first CRUD: 'synced' | 'pending_create' | 'pending_update' |
  // 'pending_delete'. pending_create rows use a negative temp id until the
  // server assigns a real one.
  TextColumn get syncStatus =>
      text().withDefault(const Constant('synced'))();

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
  // True when paidStatus was changed locally (offline-first toggle in the
  // document editor) and still needs pushing to the server. Cleared by
  // SyncManager.pushPendingPaidStatus once the PATCH succeeds.
  BoolColumn get paidStatusDirty =>
      boolean().withDefault(const Constant(false))();
  // Editable header fields kept locally so the offline-first manual editor can
  // round-trip them (display on reopen + push to /Document on sync).
  DateTimeColumn get stockDate => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get internalNote => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get referenceDocumentNumber => text().nullable()();
  BoolColumn get discountApplyRule =>
      boolean().withDefault(const Constant(true))();
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
  // server DocumentItem.Id — null until the editor-added item is pushed.
  IntColumn get serverId => integer().nullable()();
  IntColumn get productId => integer()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();              // price incl. tax
  RealColumn get priceBeforeTax => real().withDefault(const Constant(0))();
  RealColumn get discount => real().withDefault(const Constant(0))();
  IntColumn get discountType => integer().withDefault(const Constant(0))();
  RealColumn get total => real()();
  RealColumn get taxAmount => real().withDefault(const Constant(0))();
  // Selected tax for offline-first editor items; pushed to /DocumentItemTaxes.
  IntColumn get taxId => integer().nullable()();
  RealColumn get taxRate => real().withDefault(const Constant(0))();
  DateTimeColumn get expirationDate => dateTime().nullable()();
  // Checkout items use 'synced' implicitly (pushed with their order). Editor
  // items use: 'synced' | 'pending_create' | 'pending_update' | 'pending_delete'.
  TextColumn get syncStatus =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {localId};
}

class PaymentsTable extends Table {
  @override
  String get tableName => 'payments';

  TextColumn get localId => text()();
  // server Payment.Id — null until the standalone payment is pushed, or for
  // checkout payments that travel inside the order BatchSync. Set when a
  // server payment is pulled or a local 'pending_create' is confirmed.
  IntColumn get serverId => integer().nullable()();
  // FK → documents.localId
  TextColumn get documentId =>
      text().references(DocumentsTable, #localId,
          onDelete: KeyAction.cascade)();
  IntColumn get paymentTypeId => integer()();
  RealColumn get amount => real()();
  IntColumn get userId => integer()();
  DateTimeColumn get date => dateTime()();
  // Non-null once the payment belongs to a closed Z-report — such payments are
  // locked (cannot be edited or deleted) in the document editor.
  IntColumn get zReportId => integer().nullable()();
  // Checkout payments inserted by insertOfflineDocument use 'pending' (pushed
  // with their order). Editor-added payments use the standalone CRUD states:
  // 'synced' | 'pending_create' | 'pending_update' | 'pending_delete'.
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
// CUSTOMER DISCOUNTS — per-customer discount rules.
// Cached locally so the edit form works offline. syncStatus drives the push
// pipeline for CRUD ops the same way as products/customers.
// ============================================================================

@TableIndex(name: 'idx_customer_discounts_customer_id', columns: {#customerId})
class CustomerDiscountsTable extends Table {
  @override
  String get tableName => 'customer_discounts';

  IntColumn get id => integer()();            // positive = server id; negative = temp local id
  IntColumn get companyId => integer()();
  IntColumn get customerId => integer()();
  IntColumn get type => integer().withDefault(const Constant(0))();   // 0=percentage, 1=fixed
  IntColumn get uid => integer().withDefault(const Constant(0))();
  RealColumn get value => real().withDefault(const Constant(0))();
  DateTimeColumn get lastModified => dateTime()();
  // 'synced' | 'pending_create' | 'pending_update' | 'pending_delete'
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================================
// LOYALTY CARDS — per-customer points cards, offline-first.
// `id` is positive (server-assigned) once synced; negative while pending_create.
// `syncStatus` drives pushPendingLoyaltyCardOps in SyncManager.
// ============================================================================

@TableIndex(name: 'idx_loyalty_cards_customer_id', columns: {#customerId})
@TableIndex(name: 'idx_loyalty_cards_sync_status', columns: {#syncStatus})
class LoyaltyCardsTable extends Table {
  @override
  String get tableName => 'loyalty_cards';

  IntColumn get id => integer()();
  IntColumn get companyId => integer()();
  IntColumn get customerId => integer()();
  TextColumn get cardNumber => text().nullable()();
  RealColumn get points => real().withDefault(const Constant(0))();
  DateTimeColumn get lastModified => dateTime()();
  // 'synced' | 'pending_create' | 'pending_update' | 'pending_delete'
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================================
// TIME CLOCK ENTRIES — offline-first employee attendance tracking.
// Completely separate from cash drawer / shift management.
// One row = one clock-in event. clockOutTime is null while the employee is
// still clocked in.  syncStatus drives pushPendingTimeClockEntries.
// ============================================================================

@TableIndex(name: 'idx_time_clock_user_id',    columns: {#userId})
@TableIndex(name: 'idx_time_clock_sync_status', columns: {#syncStatus})
class TimeClockEntriesTable extends Table {
  @override
  String get tableName => 'time_clock_entries';

  TextColumn get localId => text()();               // UUID — local PK
  IntColumn get serverId => integer().nullable()(); // null until synced
  IntColumn get companyId => integer()();
  IntColumn get userId => integer()();
  DateTimeColumn get clockInTime => dateTime()();
  DateTimeColumn get clockOutTime => dateTime().nullable()();

  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column> get primaryKey => {localId};
}

// ============================================================================
// SHIFTS — offline-first cashier shift tracking.
// One row per shift. status: 0=Open, 1=Closed.
// syncStatus drives pushPendingShifts in SyncManager.
// ============================================================================

@TableIndex(name: 'idx_shifts_company_status', columns: {#companyId, #status})
class ShiftsTable extends Table {
  @override
  String get tableName => 'shifts';

  TextColumn get localId => text()();           // UUID — local PK
  IntColumn get serverId => integer().nullable()(); // null until synced
  IntColumn get companyId => integer()();
  IntColumn get userId => integer()();
  RealColumn get startingCash => real().withDefault(const Constant(0))();
  RealColumn get actualEndingCash => real().nullable()();
  IntColumn get status => integer().withDefault(const Constant(0))(); // 0=Open, 1=Closed
  DateTimeColumn get openedAt => dateTime()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  DateTimeColumn get lastModified => dateTime()();

  /// Distinguishes the station's master cash-drawer shift (true) from bare
  /// per-employee attendance sessions (false). Lets many servers clock in for
  /// hours simultaneously on one station without colliding with the single
  /// drawer shift. Local-only differentiation flag.
  BoolColumn get isDrawerShift =>
      boolean().withDefault(const Constant(false))();

  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column> get primaryKey => {localId};
}

// ============================================================================
// BOOKINGS — reservations / appointments. Pulled from the server with a
// FULL-REPLACE strategy each sync (the calendar must reflect deletes and the
// dataset is small). Reads stream from here so the calendar renders offline;
// writes still go through the API then trigger a re-pull, mirroring the
// floor-plan provider pattern. `tableIdsJson` holds the assigned floor-plan
// table id list as a JSON array.
// ============================================================================

@TableIndex(name: 'idx_bookings_company_start', columns: {#companyId, #startTime})
class BookingsTable extends Table {
  @override
  String get tableName => 'bookings';

  IntColumn get id => integer()();              // server-assigned id
  IntColumn get companyId => integer()();
  IntColumn get customerId => integer().nullable()();
  IntColumn get userId => integer().nullable()();
  TextColumn get reservationName => text().withDefault(const Constant(''))();
  TextColumn get tableIdsJson => text().withDefault(const Constant('[]'))();
  IntColumn get documentId => integer().nullable()();
  IntColumn get posOrderId => integer().nullable()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  IntColumn get guestCount => integer().withDefault(const Constant(1))();
  IntColumn get status => integer().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================================
// WAREHOUSES — offline-first stock locations. Pulled from the server and also
// created/edited/deleted locally with a `syncStatus` queue (pending_create uses
// a temp NEGATIVE id until the server assigns a real one — same pattern as
// products/customers).
// ============================================================================

class WarehousesTable extends Table {
  @override
  String get tableName => 'warehouses';

  IntColumn get id => integer()();              // positive = server id; negative = temp local
  IntColumn get companyId => integer()();
  TextColumn get name => text()();
  DateTimeColumn get lastModified => dateTime()();
  // 'synced' | 'pending_create' | 'pending_update' | 'pending_delete'
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================================
// PENDING STOCK OPS — offline queue for the stock reassign/revoke that happens
// when a warehouse holding stock is deleted. `operation`: 'delete' | 'move'.
// `stockId` is always a server id (we only mutate already-synced stock rows
// here). SyncManager drains this via pushPendingStockOps BEFORE pullStocks.
// ============================================================================

class PendingStockOpsTable extends Table {
  @override
  String get tableName => 'pending_stock_ops';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get operation => text()();          // 'delete' | 'move'
  IntColumn get companyId => integer()();
  IntColumn get stockId => integer()();          // server Stock.Id
  IntColumn get targetWarehouseId => integer().nullable()(); // move: destination
  RealColumn get quantity => real().nullable()();            // move: newQuantity
  IntColumn get productId => integer().nullable()();         // move: newProductId
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
// DOCUMENT TYPES & CATEGORIES — pull-only master data that drives the document
// editor's "Select document type" picker. Cached locally so a document can be
// created entirely offline. DocumentType is global; DocumentCategory is
// company-scoped.
// ============================================================================

class DocumentTypesTable extends Table {
  @override
  String get tableName => 'document_types';

  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get code => text().nullable()();
  IntColumn get documentCategoryId => integer().nullable()();
  IntColumn get warehouseId => integer().nullable()();
  DateTimeColumn get lastModified => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DocumentCategoriesTable extends Table {
  @override
  String get tableName => 'document_categories';

  IntColumn get id => integer()();
  IntColumn get companyId => integer()();
  TextColumn get name => text()();
  DateTimeColumn get lastModified => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Per-product stock-control rule (reorder point, low-stock warning). The
// backend only exposes GetByProductId (no bulk pull), so this is cached lazily:
// the provider reads here and a background fetch upserts the row when online.
class StockControlsTable extends Table {
  @override
  String get tableName => 'stock_controls';

  IntColumn get productId => integer()();           // PK — one rule per product
  IntColumn get companyId => integer()();
  IntColumn get serverId => integer().nullable()();
  RealColumn get reorderPoint => real().withDefault(const Constant(0))();
  RealColumn get preferredQuantity => real().withDefault(const Constant(0))();
  BoolColumn get isLowStockWarningEnabled =>
      boolean().withDefault(const Constant(true))();
  RealColumn get lowStockWarningQuantity =>
      real().withDefault(const Constant(0))();
  // Optional preferred supplier for reordering (products-screen rules editor).
  IntColumn get customerId => integer().nullable()();
  DateTimeColumn get lastModified => dateTime().nullable()();
  // Offline-first CRUD state. 'synced' for pulled rows; pending_* for local
  // edits awaiting push. (serverId stays null for a pending_create until synced.)
  TextColumn get syncStatus =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {productId};
}

// Per-product tax assignment (productId ↔ taxId). Cached so the product editor
// shows/sets the assigned tax offline. Pull-seeded by pullProductTaxes; edits
// queue via syncStatus and push to /ProductTaxes/Add+Delete.
class ProductTaxesTable extends Table {
  @override
  String get tableName => 'product_taxes';

  IntColumn get productId => integer()();
  IntColumn get taxId => integer()();
  IntColumn get companyId => integer()();
  // 'synced' | 'pending_create' | 'pending_delete'
  TextColumn get syncStatus =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {productId, taxId};
}

// Void reasons — pull-only master data so the void dialog (during checkout)
// and the admin list work offline.
class VoidReasonsTable extends Table {
  @override
  String get tableName => 'void_reasons';

  IntColumn get id => integer()();
  IntColumn get companyId => integer()();
  TextColumn get name => text()();
  IntColumn get rank => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastModified => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
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
    PosOrderItemTaxesTable,
    StartingCashTable,
    ZReportsTable,
    SyncMetaTable,
    StocksTable,
    PendingVoidsTable,
    DocumentsTable,
    DocumentItemsTable,
    PaymentsTable,
    BarcodesTable,
    CustomerDiscountsTable,
    LoyaltyCardsTable,
    TimeClockEntriesTable,
    ShiftsTable,
    BookingsTable,
    WarehousesTable,
    PendingStockOpsTable,
    DocumentTypesTable,
    DocumentCategoriesTable,
    VoidReasonsTable,
    StockControlsTable,
    ProductTaxesTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 37;

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

          // v19: Performance indexes.
          // onCreate already applies them via m.createAll(); onUpgrade must
          // create them explicitly for existing installations.
          if (from < 19) {
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_products_group_id'
                ' ON products (product_group_id)');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_products_barcode'
                ' ON products (barcode)');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_pos_orders_sync_status'
                ' ON pos_orders (sync_status)');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_pos_orders_status'
                ' ON pos_orders (status)');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_pos_order_items_order_id'
                ' ON pos_order_items (order_id)');
          }

          // v20: Customers become offline-first; customer discounts are cached
          // locally so the edit form and POS discount lookup work offline.
          if (from < 20) {
            await customStatement(
                "ALTER TABLE customers ADD COLUMN sync_status TEXT NOT NULL DEFAULT 'synced'");
            await customStatement(
                'ALTER TABLE customers ADD COLUMN sync_error TEXT');
            await customStatement('''
              CREATE TABLE IF NOT EXISTS customer_discounts (
                id INTEGER NOT NULL PRIMARY KEY,
                company_id INTEGER NOT NULL,
                customer_id INTEGER NOT NULL,
                type INTEGER NOT NULL DEFAULT 0,
                uid INTEGER NOT NULL DEFAULT 0,
                value REAL NOT NULL DEFAULT 0.0,
                last_modified INTEGER NOT NULL DEFAULT 0,
                sync_status TEXT NOT NULL DEFAULT \'synced\',
                sync_error TEXT
              )
            ''');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_customer_discounts_customer_id'
                ' ON customer_discounts (customer_id)');
          }

          // v21: Loyalty cards — offline-first customer points cards.
          // Negative temp IDs are used for pending_create rows.
          if (from < 21) {
            await customStatement('''
              CREATE TABLE IF NOT EXISTS loyalty_cards (
                id INTEGER NOT NULL PRIMARY KEY,
                company_id INTEGER NOT NULL,
                customer_id INTEGER NOT NULL,
                card_number TEXT,
                points REAL NOT NULL DEFAULT 0,
                last_modified INTEGER NOT NULL,
                sync_status TEXT NOT NULL DEFAULT \'synced\',
                sync_error TEXT
              )
            ''');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_loyalty_cards_customer_id'
                ' ON loyalty_cards (customer_id)');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_loyalty_cards_sync_status'
                ' ON loyalty_cards (sync_status)');
          }

          // v22: Dual-discount persistence.
          //  • pos_orders gains a discount_type column so the cart-level
          //    discount type (0=%, 1=Fixed) survives save/reload.
          //  • pos_order_item_taxes stores offline per-item tax breakdowns
          //    so receipts and sync don't need to recompute them.
          if (from < 22) {
            await customStatement(
                'ALTER TABLE pos_orders'
                ' ADD COLUMN discount_type INTEGER NOT NULL DEFAULT 0');
            await customStatement('''
              CREATE TABLE IF NOT EXISTS pos_order_item_taxes (
                local_id TEXT NOT NULL PRIMARY KEY,
                order_id TEXT NOT NULL
                  REFERENCES pos_orders(local_id) ON DELETE CASCADE,
                product_id INTEGER NOT NULL,
                tax_rate_id INTEGER NOT NULL,
                tax_amount REAL NOT NULL,
                sync_status TEXT NOT NULL DEFAULT 'pending'
              )
            ''');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_pos_order_item_taxes_order_id'
                ' ON pos_order_item_taxes (order_id)');
          }

          // v25: Rename the local cash table `cash_movements` → `starting_cash`
          // so it mirrors the server's StartingCash table. Data is preserved by
          // a plain table rename. Guarded so the migration is safe whether or
          // not the old table exists (it was previously created only via
          // createAll on fresh installs).
          if (from < 25) {
            final existing = await customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' "
              "AND name IN ('cash_movements', 'starting_cash')",
            ).get();
            final names =
                existing.map((r) => r.read<String>('name')).toSet();
            if (names.contains('cash_movements') &&
                !names.contains('starting_cash')) {
              await customStatement(
                  'ALTER TABLE cash_movements RENAME TO starting_cash');
            } else if (!names.contains('starting_cash')) {
              await customStatement('''
                CREATE TABLE IF NOT EXISTS starting_cash (
                  local_id TEXT NOT NULL PRIMARY KEY,
                  server_id INTEGER,
                  company_id INTEGER NOT NULL,
                  user_id INTEGER NOT NULL,
                  amount REAL NOT NULL,
                  type TEXT NOT NULL,
                  note TEXT,
                  created_at INTEGER NOT NULL,
                  sync_status TEXT NOT NULL DEFAULT \'pending\',
                  sync_error TEXT
                )
              ''');
            }
          }

          // v26: Link cash entries to their Z-report. `z_report_number` is NULL
          // while the entry is active; once finalized the active Cash In/Out
          // list filters it out. Runs AFTER v25 so `starting_cash` exists.
          if (from < 26) {
            await customStatement(
                'ALTER TABLE starting_cash ADD COLUMN z_report_number INTEGER');
          }

          // v27: Differentiate per-employee attendance sessions (0) from the
          // station's master cash-drawer shift (1) so concurrent clock-ins on
          // one station never collide with the drawer shift.
          if (from < 27) {
            await customStatement(
                'ALTER TABLE shifts ADD COLUMN is_drawer_shift '
                'INTEGER NOT NULL DEFAULT 0');
          }

          // v28: Track per-setting sync state so an offline edit of an existing
          // app property is pushed to the server on reconnect. Existing rows
          // default to 'synced' (they came from the server).
          if (from < 28) {
            await customStatement(
                "ALTER TABLE app_properties ADD COLUMN sync_status "
                "TEXT NOT NULL DEFAULT 'synced'");
          }

          // v29: Offline bookings cache. Reservations are pulled (full replace)
          // each sync so the calendar renders offline. New table only — no
          // existing data to migrate.
          if (from < 29) {
            await m.createTable(bookingsTable);
          }

          // v30: Offline-first warehouses + the stock-op queue used when a
          // warehouse with stock is deleted. New tables only.
          if (from < 30) {
            await m.createTable(warehousesTable);
            await m.createTable(pendingStockOpsTable);
          }

          // v31: Offline-first paid-status + payments for the document editor.
          //  • documents.paid_status_dirty flags a locally-toggled paid status
          //    that SyncManager pushes to /Document/Update on reconnect.
          //  • payments gains server_id + z_report_id and reuses the standard
          //    sync_status states so editor add/edit/delete work offline and
          //    are reconciled with /Payments/* on sync.
          if (from < 31) {
            await customStatement(
                'ALTER TABLE documents ADD COLUMN paid_status_dirty '
                'INTEGER NOT NULL DEFAULT 0');
            await customStatement(
                'ALTER TABLE payments ADD COLUMN server_id INTEGER');
            await customStatement(
                'ALTER TABLE payments ADD COLUMN z_report_id INTEGER');
          }

          // v32: Offline-first manual document editor. document_items gains the
          // per-item sync fields (server id, tax selection, expiration, sync
          // state) so header + items can be created/edited/deleted offline and
          // pushed via /Document + /DocumentItems on reconnect. Documents reuse
          // their existing sync_status with the manual states pending_create /
          // pending_update / pending_delete (checkout keeps pending → synced).
          if (from < 32) {
            await customStatement(
                'ALTER TABLE document_items ADD COLUMN server_id INTEGER');
            await customStatement(
                'ALTER TABLE document_items ADD COLUMN price_before_tax '
                'REAL NOT NULL DEFAULT 0');
            await customStatement(
                'ALTER TABLE document_items ADD COLUMN tax_id INTEGER');
            await customStatement(
                'ALTER TABLE document_items ADD COLUMN tax_rate '
                'REAL NOT NULL DEFAULT 0');
            await customStatement(
                'ALTER TABLE document_items ADD COLUMN expiration_date INTEGER');
            await customStatement(
                "ALTER TABLE document_items ADD COLUMN sync_status "
                "TEXT NOT NULL DEFAULT 'synced'");
            // Editable header fields persisted for offline round-tripping.
            await customStatement(
                'ALTER TABLE documents ADD COLUMN stock_date INTEGER');
            await customStatement(
                'ALTER TABLE documents ADD COLUMN due_date INTEGER');
            await customStatement(
                'ALTER TABLE documents ADD COLUMN internal_note TEXT');
            await customStatement(
                'ALTER TABLE documents ADD COLUMN note TEXT');
            await customStatement(
                'ALTER TABLE documents ADD COLUMN reference_document_number TEXT');
            await customStatement(
                'ALTER TABLE documents ADD COLUMN discount_apply_rule '
                'INTEGER NOT NULL DEFAULT 1');
          }

          // v33: Cache document types + categories locally so the editor's
          // "Select document type" picker — and therefore offline document
          // creation — works without a network connection. Pull-only master
          // data seeded by SyncManager.pullDocumentTypes/Categories.
          if (from < 33) {
            await m.createTable(documentTypesTable);
            await m.createTable(documentCategoriesTable);
          }

          // v34: Cache void reasons locally so the checkout void dialog and the
          // admin list work offline. Pull-only, seeded by pullVoidReasons.
          if (from < 34) {
            await m.createTable(voidReasonsTable);
          }

          // v35: Lazy cache of per-product stock-control rules so the stock
          // screen reads them offline (refreshed from GetByProductId online).
          if (from < 35) {
            await m.createTable(stockControlsTable);
          }

          // v36: Offline-first CRUD for stocks + stock controls — sync_status
          // drives the local-write queue so adjustments/rules survive offline
          // and push on reconnect (mirrors warehouses).
          if (from < 36) {
            await customStatement(
                "ALTER TABLE stocks ADD COLUMN sync_status "
                "TEXT NOT NULL DEFAULT 'synced'");
            await customStatement(
                "ALTER TABLE stock_controls ADD COLUMN sync_status "
                "TEXT NOT NULL DEFAULT 'synced'");
          }

          // v37: ProductTaxes offline cache + stock_controls preferred supplier.
          if (from < 37) {
            await customStatement(
                'ALTER TABLE stock_controls ADD COLUMN customer_id INTEGER');
            await m.createTable(productTaxesTable);
          }

          // v24: Employee Time Clock — offline-first attendance tracking.
          // Completely isolated from cash drawer / shift management.
          // One row per clock-in event; clockOutTime null while clocked in.
          if (from < 24) {
            await customStatement('''
              CREATE TABLE IF NOT EXISTS time_clock_entries (
                local_id TEXT NOT NULL PRIMARY KEY,
                server_id INTEGER,
                company_id INTEGER NOT NULL,
                user_id INTEGER NOT NULL,
                clock_in_time INTEGER NOT NULL,
                clock_out_time INTEGER,
                sync_status TEXT NOT NULL DEFAULT \'pending\',
                sync_error TEXT
              )
            ''');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_time_clock_user_id'
                ' ON time_clock_entries (user_id)');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_time_clock_sync_status'
                ' ON time_clock_entries (sync_status)');
          }

          // v23: Offline-first shift management.
          // One row per cashier shift. status 0=Open, 1=Closed.
          // SyncManager pushes pending rows via /api/shifts/batchsync.
          if (from < 23) {
            await customStatement('''
              CREATE TABLE IF NOT EXISTS shifts (
                local_id TEXT NOT NULL PRIMARY KEY,
                server_id INTEGER,
                company_id INTEGER NOT NULL,
                user_id INTEGER NOT NULL,
                starting_cash REAL NOT NULL DEFAULT 0,
                actual_ending_cash REAL,
                status INTEGER NOT NULL DEFAULT 0,
                opened_at INTEGER NOT NULL,
                closed_at INTEGER,
                last_modified INTEGER NOT NULL,
                sync_status TEXT NOT NULL DEFAULT \'pending\',
                sync_error TEXT
              )
            ''');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_shifts_company_status'
                ' ON shifts (company_id, status)');
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
      ..where((t) => t.companyId.equals(companyId))
      ..where((t) => t.syncStatus.equals('pending_delete').not());
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

  /// Resolves a Document row by its server id. Used by the editor to map the
  /// server-id it holds back to the local UUID that Drift writes key on.
  Future<DocumentsTableData?> getDocumentByServerId(int serverId) =>
      (select(documentsTable)
            ..where((t) => t.serverId.equals(serverId))
            ..limit(1))
          .getSingleOrNull();

  Future<DocumentsTableData?> getDocumentByLocalId(String localId) =>
      (select(documentsTable)
            ..where((t) => t.localId.equals(localId))
            ..limit(1))
          .getSingleOrNull();

  /// Ensures a local Document row exists for a server-side document so the
  /// offline-first paid-status and payments writes have a row to attach to.
  /// Returns the existing localId when one is already present (keyed by
  /// serverId); otherwise inserts a 'srv_<serverId>' sentinel. Never touches
  /// line items.
  Future<String> ensureLocalDocumentForServer({
    required int serverId,
    required int companyId,
    required int userId,
    required int warehouseId,
    required int documentTypeId,
    required String? number,
    required double total,
    required int paidStatus,
    required DateTime date,
  }) async {
    final existing = await getDocumentByServerId(serverId);
    if (existing != null) return existing.localId;
    final localId = 'srv_$serverId';
    await into(documentsTable).insertOnConflictUpdate(
      DocumentsTableCompanion(
        localId: Value(localId),
        serverId: Value(serverId),
        companyId: Value(companyId),
        documentTypeId: Value(documentTypeId),
        userId: Value(userId),
        warehouseId: Value(warehouseId),
        number: Value(number),
        total: Value(total),
        paidStatus: Value(paidStatus),
        date: Value(date),
        syncStatus: const Value('synced'),
        lastModified: Value(DateTime.now().toUtc()),
      ),
    );
    return localId;
  }

  /// Offline-first paid-status write. Drift is the source of truth for the
  /// documents list, so this persists the toggle immediately and flags the row
  /// for a server push. Marking Unpaid mirrors the backend by clearing applied
  /// payments locally.
  Future<void> setLocalPaidStatus(String docLocalId, int newStatus) {
    return transaction(() async {
      await (update(documentsTable)
            ..where((t) => t.localId.equals(docLocalId)))
          .write(DocumentsTableCompanion(
        paidStatus: Value(newStatus),
        paidStatusDirty: const Value(true),
        lastModified: Value(DateTime.now().toUtc()),
      ));
      if (newStatus == 0) {
        await (delete(paymentsTable)
              ..where((t) => t.documentId.equals(docLocalId)))
            .go();
      }
    });
  }

  /// Live payments for a document, newest-last, hiding soft-deleted rows.
  Stream<List<PaymentsTableData>> watchPayments(String docLocalId) =>
      (select(paymentsTable)
            ..where((t) => t.documentId.equals(docLocalId))
            ..where((t) => t.syncStatus.equals('pending_delete').not())
            ..orderBy([(t) => OrderingTerm.asc(t.date)]))
          .watch();

  /// Inserts an editor-added payment locally with a 'pending_create' status.
  Future<void> insertLocalPayment(PaymentsTableCompanion payment) =>
      into(paymentsTable).insert(payment);

  /// Edits a payment's amount offline-first. A never-synced row stays
  /// 'pending_create'; an already-synced row is flagged 'pending_update'.
  Future<void> editLocalPayment({
    required String localId,
    required double amount,
    required String currentSyncStatus,
  }) {
    final next =
        currentSyncStatus == 'pending_create' ? 'pending_create' : 'pending_update';
    return (update(paymentsTable)..where((t) => t.localId.equals(localId)))
        .write(PaymentsTableCompanion(
      amount: Value(amount),
      syncStatus: Value(next),
    ));
  }

  /// Deletes a payment offline-first. A row that never reached the server is
  /// removed outright; one with a server id is soft-deleted ('pending_delete')
  /// so the pusher can issue /Payments/Delete on the next sync.
  Future<void> deleteLocalPayment({
    required String localId,
    required int? serverId,
  }) {
    if (serverId == null) {
      return (delete(paymentsTable)..where((t) => t.localId.equals(localId)))
          .go();
    }
    return (update(paymentsTable)..where((t) => t.localId.equals(localId)))
        .write(const PaymentsTableCompanion(syncStatus: Value('pending_delete')));
  }

  /// Replaces the server-synced payment rows for a document with a fresh server
  /// snapshot, preserving any local unsynced edits (pending_*). Called when the
  /// editor opens online so the cache reflects payments made on other devices.
  Future<void> reconcileServerPayments(
    String docLocalId,
    List<PaymentsTableCompanion> serverRows,
  ) {
    return transaction(() async {
      // Keep local pending edits keyed by their server id out of the wipe.
      final pendingRows = await (select(paymentsTable)
            ..where((t) => t.documentId.equals(docLocalId))
            ..where((t) => t.syncStatus.equals('pending_update') |
                t.syncStatus.equals('pending_delete')))
          .get();
      final lockedServerIds =
          pendingRows.map((r) => r.serverId).whereType<int>().toSet();

      // Wipe everything that is server-authoritative (synced) or a legacy
      // checkout 'pending' row — the snapshot supersedes them. pending_create /
      // pending_update / pending_delete rows survive.
      await (delete(paymentsTable)
            ..where((t) => t.documentId.equals(docLocalId))
            ..where((t) =>
                t.syncStatus.equals('synced') | t.syncStatus.equals('pending')))
          .go();

      for (final row in serverRows) {
        if (row.serverId.present &&
            lockedServerIds.contains(row.serverId.value)) {
          continue; // a local pending edit owns this server id
        }
        await into(paymentsTable).insert(row, mode: InsertMode.insertOrReplace);
      }
    });
  }

  // ── Sync getters / markers for offline-first paid status + payments ────────

  Future<List<DocumentsTableData>> getPaidStatusDirtyDocuments(int companyId) =>
      (select(documentsTable)
            ..where((t) => t.companyId.equals(companyId))
            ..where((t) => t.paidStatusDirty.equals(true))
            ..where((t) => t.serverId.isNotNull()))
          .get();

  Future<void> clearPaidStatusDirty(String docLocalId) =>
      (update(documentsTable)..where((t) => t.localId.equals(docLocalId)))
          .write(const DocumentsTableCompanion(paidStatusDirty: Value(false)));

  Future<List<PaymentsTableData>> getPaymentsBySyncStatus(String status) =>
      (select(paymentsTable)..where((t) => t.syncStatus.equals(status))).get();

  Future<void> markPaymentSynced(String localId, int? serverId) =>
      (update(paymentsTable)..where((t) => t.localId.equals(localId)))
          .write(PaymentsTableCompanion(
        serverId: serverId == null ? const Value.absent() : Value(serverId),
        syncStatus: const Value('synced'),
      ));

  Future<void> hardDeletePayment(String localId) =>
      (delete(paymentsTable)..where((t) => t.localId.equals(localId))).go();

  // ─── Offline-first MANUAL document editor (header + items) ─────────────────

  /// Inserts a brand-new editor document. The caller sets localId (UUID) and
  /// syncStatus 'pending_create'.
  Future<void> createManualDocument(DocumentsTableCompanion doc) =>
      into(documentsTable).insert(doc);

  /// Writes header fields for an editor document and queues a server push.
  /// A document that was never synced stays 'pending_create'; an already-synced
  /// one becomes 'pending_update'. `total` is optional (recomputed from items).
  Future<void> updateManualDocumentHeader(
    String localId,
    DocumentsTableCompanion fields,
  ) async {
    final current = await getDocumentByLocalId(localId);
    final next = current?.syncStatus == 'pending_create'
        ? 'pending_create'
        : 'pending_update';
    await (update(documentsTable)..where((t) => t.localId.equals(localId)))
        .write(fields.copyWith(
      syncStatus: Value(next),
      lastModified: Value(DateTime.now().toUtc()),
    ));
  }

  /// Persists the recomputed document total without changing its sync intent
  /// beyond flagging it for push.
  Future<void> setDocumentTotalLocal(String localId, double total) async {
    final current = await getDocumentByLocalId(localId);
    final next = current?.syncStatus == 'pending_create'
        ? 'pending_create'
        : current?.syncStatus == 'synced'
            ? 'pending_update'
            : (current?.syncStatus ?? 'pending_update');
    await (update(documentsTable)..where((t) => t.localId.equals(localId)))
        .write(DocumentsTableCompanion(
      total: Value(total),
      syncStatus: Value(next),
      lastModified: Value(DateTime.now().toUtc()),
    ));
  }

  /// Deletes an editor document offline-first. A never-synced document (and its
  /// items, via cascade) is removed outright; a synced one is soft-deleted
  /// ('pending_delete') so the pusher can DELETE it on the next sync.
  Future<void> deleteDocumentLocal(String localId) async {
    final current = await getDocumentByLocalId(localId);
    if (current == null) return;
    if (current.serverId == null && current.syncStatus != 'synced') {
      await (delete(documentsTable)..where((t) => t.localId.equals(localId)))
          .go();
      return;
    }
    await (update(documentsTable)..where((t) => t.localId.equals(localId)))
        .write(const DocumentsTableCompanion(syncStatus: Value('pending_delete')));
  }

  Future<List<DocumentsTableData>> getDocumentsBySyncStatus(
    int companyId,
    String status,
  ) =>
      (select(documentsTable)
            ..where((t) => t.companyId.equals(companyId))
            ..where((t) => t.syncStatus.equals(status)))
          .get();

  /// Live, active (non-deleted) items for a document — drives the editor list.
  Stream<List<DocumentItemsTableData>> watchDocumentItems(String docLocalId) =>
      (select(documentItemsTable)
            ..where((t) => t.documentId.equals(docLocalId))
            ..where((t) => t.syncStatus.equals('pending_delete').not()))
          .watch();

  /// Active items for a document (excludes soft-deleted) — used to recompute the
  /// document total.
  Future<List<DocumentItemsTableData>> getActiveDocumentItems(
          String docLocalId) =>
      (select(documentItemsTable)
            ..where((t) => t.documentId.equals(docLocalId))
            ..where((t) => t.syncStatus.equals('pending_delete').not()))
          .get();

  Future<void> insertDocumentItemLocal(DocumentItemsTableCompanion item) =>
      into(documentItemsTable).insert(item);

  /// Edits an item offline-first. A never-synced row stays 'pending_create';
  /// a synced row becomes 'pending_update'.
  Future<void> updateDocumentItemLocal(
    String localId,
    DocumentItemsTableCompanion fields,
  ) async {
    final current = await (select(documentItemsTable)
          ..where((t) => t.localId.equals(localId))
          ..limit(1))
        .getSingleOrNull();
    final next = current?.syncStatus == 'pending_create'
        ? 'pending_create'
        : 'pending_update';
    await (update(documentItemsTable)..where((t) => t.localId.equals(localId)))
        .write(fields.copyWith(syncStatus: Value(next)));
  }

  /// Deletes an item offline-first. A never-synced row is removed; a synced one
  /// is soft-deleted ('pending_delete').
  Future<void> deleteDocumentItemLocal(String localId) async {
    final current = await (select(documentItemsTable)
          ..where((t) => t.localId.equals(localId))
          ..limit(1))
        .getSingleOrNull();
    if (current == null) return;
    if (current.serverId == null && current.syncStatus != 'synced') {
      await (delete(documentItemsTable)
            ..where((t) => t.localId.equals(localId)))
          .go();
      return;
    }
    await (update(documentItemsTable)..where((t) => t.localId.equals(localId)))
        .write(const DocumentItemsTableCompanion(
            syncStatus: Value('pending_delete')));
  }

  Future<List<DocumentItemsTableData>> getDocumentItemsBySyncStatus(
          String status) =>
      (select(documentItemsTable)..where((t) => t.syncStatus.equals(status)))
          .get();

  Future<void> markDocumentItemSynced(String localId, int? serverId) =>
      (update(documentItemsTable)..where((t) => t.localId.equals(localId)))
          .write(DocumentItemsTableCompanion(
        serverId: serverId == null ? const Value.absent() : Value(serverId),
        syncStatus: const Value('synced'),
      ));

  Future<void> hardDeleteDocumentItem(String localId) =>
      (delete(documentItemsTable)..where((t) => t.localId.equals(localId)))
          .go();

  // ─── Document types / categories (pull-only master data) ───────────────────

  Stream<List<DocumentTypesTableData>> watchDocumentTypes() =>
      select(documentTypesTable).watch();

  Stream<List<DocumentCategoriesTableData>> watchDocumentCategories(
          int companyId) =>
      (select(documentCategoriesTable)
            ..where((t) => t.companyId.equals(companyId)))
          .watch();

  Future<void> upsertDocumentTypes(
          List<DocumentTypesTableCompanion> rows) async =>
      batch((b) => b.insertAllOnConflictUpdate(documentTypesTable, rows));

  Future<void> upsertDocumentCategories(
          List<DocumentCategoriesTableCompanion> rows) async =>
      batch((b) => b.insertAllOnConflictUpdate(documentCategoriesTable, rows));

  // ─── Void reasons (pull-only master data) ──────────────────────────────────

  Stream<List<VoidReasonsTableData>> watchVoidReasons(int companyId) =>
      (select(voidReasonsTable)
            ..where((t) => t.companyId.equals(companyId))
            ..orderBy([(t) => OrderingTerm.asc(t.rank)]))
          .watch();

  /// Full-replace the void reasons for a company (small dataset; mirrors server
  /// deletes that a delta pull would miss).
  Future<void> replaceVoidReasons(
          int companyId, List<VoidReasonsTableCompanion> rows) =>
      transaction(() async {
        await (delete(voidReasonsTable)
              ..where((t) => t.companyId.equals(companyId)))
            .go();
        if (rows.isNotEmpty) {
          await batch((b) => b.insertAll(voidReasonsTable, rows));
        }
      });

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
    List<PosOrderItemsTableCompanion> newItems, {
    List<PosOrderItemTaxesTableCompanion> itemTaxes = const [],
  }) {
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

      await (delete(posOrderItemTaxesTable)
            ..where((t) => t.orderId.equals(order.localId.value)))
          .go();
      if (itemTaxes.isNotEmpty) {
        await batch((b) {
          b.insertAll(posOrderItemTaxesTable, itemTaxes);
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

  /// Local Z-report history for a company, newest-first. Offline-first source
  /// for the End-of-Day "History" tab.
  Future<List<ZReportsTableData>> getZReportHistory(int companyId) =>
      (select(zReportsTable)
            ..where((t) => t.companyId.equals(companyId))
            ..orderBy([(t) => OrderingTerm.desc(t.closedAt)]))
          .get();

  /// All cached stocks for a company — offline-first source for the stock list.
  /// Soft-deleted rows (pending_delete) are hidden so they vanish immediately.
  Future<List<StocksTableData>> getStocksForCompany(int companyId) =>
      (select(stocksTable)
            ..where((t) => t.companyId.equals(companyId))
            ..where((t) => t.syncStatus.equals('pending_delete').not()))
          .get();

  // ─── Offline-first PRODUCT TAXES (per-product tax assignment) ──────────────

  /// Active (non-deleted) tax assignments for a product.
  Future<List<ProductTaxesTableData>> getProductTaxes(int productId) =>
      (select(productTaxesTable)
            ..where((t) => t.productId.equals(productId))
            ..where((t) => t.syncStatus.equals('pending_delete').not()))
          .get();

  /// Changes a product's single assigned tax offline-first: removes the old
  /// assignment and adds the new one (either may be null = none).
  Future<void> setProductTaxLocal({
    required int companyId,
    required int productId,
    required int? oldTaxId,
    required int? newTaxId,
  }) async {
    if (oldTaxId == newTaxId) return;
    await transaction(() async {
      if (oldTaxId != null) {
        final row = await (select(productTaxesTable)
              ..where((t) => t.productId.equals(productId))
              ..where((t) => t.taxId.equals(oldTaxId)))
            .getSingleOrNull();
        if (row != null) {
          if (row.syncStatus == 'pending_create') {
            // Never synced — just drop it.
            await (delete(productTaxesTable)
                  ..where((t) => t.productId.equals(productId))
                  ..where((t) => t.taxId.equals(oldTaxId)))
                .go();
          } else {
            await (update(productTaxesTable)
                  ..where((t) => t.productId.equals(productId))
                  ..where((t) => t.taxId.equals(oldTaxId)))
                .write(const ProductTaxesTableCompanion(
                    syncStatus: Value('pending_delete')));
          }
        }
      }
      if (newTaxId != null) {
        await into(productTaxesTable).insertOnConflictUpdate(
          ProductTaxesTableCompanion(
            productId: Value(productId),
            taxId: Value(newTaxId),
            companyId: Value(companyId),
            syncStatus: const Value('pending_create'),
          ),
        );
      }
    });
  }

  Future<List<ProductTaxesTableData>> getProductTaxesBySyncStatus(
          int companyId, String status) =>
      (select(productTaxesTable)
            ..where((t) => t.companyId.equals(companyId))
            ..where((t) => t.syncStatus.equals(status)))
          .get();

  Future<void> markProductTaxSynced(int productId, int taxId) =>
      (update(productTaxesTable)
            ..where((t) => t.productId.equals(productId))
            ..where((t) => t.taxId.equals(taxId)))
          .write(const ProductTaxesTableCompanion(syncStatus: Value('synced')));

  Future<void> hardDeleteProductTax(int productId, int taxId) =>
      (delete(productTaxesTable)
            ..where((t) => t.productId.equals(productId))
            ..where((t) => t.taxId.equals(taxId)))
          .go();

  /// Cascades a product's temp→real id swap to every product-keyed local table
  /// so offline-created taxes / stock rules / barcodes / stock rows push with
  /// the real product id. Called inside pushPendingProductOps' create swap.
  Future<void> remapProductId(int tempId, int realId) async {
    await (update(barcodesTable)..where((t) => t.productId.equals(tempId)))
        .write(BarcodesTableCompanion(productId: Value(realId)));
    await (update(productTaxesTable)..where((t) => t.productId.equals(tempId)))
        .write(ProductTaxesTableCompanion(productId: Value(realId)));
    await (update(stockControlsTable)..where((t) => t.productId.equals(tempId)))
        .write(StockControlsTableCompanion(productId: Value(realId)));
    await (update(stocksTable)..where((t) => t.productId.equals(tempId)))
        .write(StocksTableCompanion(productId: Value(realId)));
  }

  /// Upserts a server-pulled product-tax row without clobbering local edits.
  Future<void> upsertSyncedProductTax(ProductTaxesTableCompanion row) async {
    final existing = await (select(productTaxesTable)
          ..where((t) => t.productId.equals(row.productId.value))
          ..where((t) => t.taxId.equals(row.taxId.value)))
        .getSingleOrNull();
    if (existing != null && existing.syncStatus != 'synced') return;
    await into(productTaxesTable).insertOnConflictUpdate(row);
  }

  // ─── Offline-first STOCK CRUD (mirrors the warehouses pattern) ─────────────

  /// Next negative temp id for an offline-created stock row.
  Future<int> _nextStockTempId() async {
    final row = await (selectOnly(stocksTable)
          ..addColumns([stocksTable.id.min()]))
        .getSingleOrNull();
    final min = row?.read(stocksTable.id.min());
    return ((min != null && min < 0) ? min : 0) - 1;
  }

  /// Adds a stock row offline-first (negative temp id, pending_create).
  Future<void> addStockLocal({
    required int companyId,
    required int productId,
    required int warehouseId,
    required double quantity,
  }) async {
    final tempId = await _nextStockTempId();
    await into(stocksTable).insert(StocksTableCompanion(
      id: Value(tempId),
      productId: Value(productId),
      warehouseId: Value(warehouseId),
      companyId: Value(companyId),
      quantity: Value(quantity),
      lastModified: Value(DateTime.now().toUtc()),
      syncStatus: const Value('pending_create'),
    ));
  }

  /// Updates a stock row offline-first. A never-synced (temp) row keeps
  /// 'pending_create'; a synced row becomes 'pending_update'.
  Future<void> updateStockLocal({
    required int id,
    required int productId,
    required int warehouseId,
    required double quantity,
  }) async {
    final cur = await (select(stocksTable)..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    final next =
        cur?.syncStatus == 'pending_create' ? 'pending_create' : 'pending_update';
    await (update(stocksTable)..where((t) => t.id.equals(id))).write(
      StocksTableCompanion(
        productId: Value(productId),
        warehouseId: Value(warehouseId),
        quantity: Value(quantity),
        lastModified: Value(DateTime.now().toUtc()),
        syncStatus: Value(next),
      ),
    );
  }

  /// Deletes a stock row offline-first. A never-synced row is removed outright;
  /// a synced row is soft-deleted ('pending_delete') for the pusher.
  Future<void> deleteStockLocal(int id) async {
    final cur = await (select(stocksTable)..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    if (cur == null) return;
    if (id < 0 || cur.syncStatus == 'pending_create') {
      await (delete(stocksTable)..where((t) => t.id.equals(id))).go();
      return;
    }
    await (update(stocksTable)..where((t) => t.id.equals(id)))
        .write(const StocksTableCompanion(syncStatus: Value('pending_delete')));
  }

  Future<List<StocksTableData>> getStocksBySyncStatus(
          int companyId, String status) =>
      (select(stocksTable)
            ..where((t) => t.companyId.equals(companyId))
            ..where((t) => t.syncStatus.equals(status)))
          .get();

  /// Swaps a temp-id stock row for its real server id (and marks it synced).
  Future<void> replaceStockTempId(int tempId, int serverId) =>
      transaction(() async {
        final row = await (select(stocksTable)..where((t) => t.id.equals(tempId)))
            .getSingleOrNull();
        if (row == null) return;
        await (delete(stocksTable)..where((t) => t.id.equals(tempId))).go();
        await into(stocksTable).insertOnConflictUpdate(
          row.toCompanion(true).copyWith(
                id: Value(serverId),
                syncStatus: const Value('synced'),
              ),
        );
      });

  Future<void> markStockSynced(int id) =>
      (update(stocksTable)..where((t) => t.id.equals(id)))
          .write(const StocksTableCompanion(syncStatus: Value('synced')));

  Future<void> hardDeleteStock(int id) =>
      (delete(stocksTable)..where((t) => t.id.equals(id))).go();

  // ─── Offline-first STOCK CONTROL CRUD ──────────────────────────────────────

  /// Saves a per-product stock-control rule offline-first. New rules become
  /// 'pending_create'; edits to a synced rule become 'pending_update'.
  Future<void> saveStockControlLocal({
    required int companyId,
    required int productId,
    required double reorderPoint,
    required double preferredQuantity,
    required bool isLowStockWarningEnabled,
    required double lowStockWarningQuantity,
    int? customerId,
  }) async {
    final existing = await getStockControl(productId);
    final next = (existing?.serverId == null) ? 'pending_create' : 'pending_update';
    await into(stockControlsTable).insertOnConflictUpdate(StockControlsTableCompanion(
      productId: Value(productId),
      companyId: Value(companyId),
      serverId: Value(existing?.serverId),
      reorderPoint: Value(reorderPoint),
      preferredQuantity: Value(preferredQuantity),
      isLowStockWarningEnabled: Value(isLowStockWarningEnabled),
      lowStockWarningQuantity: Value(lowStockWarningQuantity),
      customerId: Value(customerId),
      lastModified: Value(DateTime.now().toUtc()),
      syncStatus: Value(next),
    ));
  }

  /// Deletes a stock-control rule offline-first.
  Future<void> deleteStockControlLocal(int productId) async {
    final existing = await getStockControl(productId);
    if (existing == null) return;
    if (existing.serverId == null) {
      await (delete(stockControlsTable)..where((t) => t.productId.equals(productId)))
          .go();
      return;
    }
    await (update(stockControlsTable)..where((t) => t.productId.equals(productId)))
        .write(const StockControlsTableCompanion(
            syncStatus: Value('pending_delete')));
  }

  Future<List<StockControlsTableData>> getStockControlsBySyncStatus(
          int companyId, String status) =>
      (select(stockControlsTable)
            ..where((t) => t.companyId.equals(companyId))
            ..where((t) => t.syncStatus.equals(status)))
          .get();

  Future<void> markStockControlSynced(int productId, int? serverId) =>
      (update(stockControlsTable)..where((t) => t.productId.equals(productId)))
          .write(StockControlsTableCompanion(
        serverId: serverId == null ? const Value.absent() : Value(serverId),
        syncStatus: const Value('synced'),
      ));

  Future<void> hardDeleteStockControl(int productId) =>
      (delete(stockControlsTable)..where((t) => t.productId.equals(productId)))
          .go();

  /// Upserts a server-pulled stock-control row without clobbering local edits.
  Future<void> upsertSyncedStockControl(StockControlsTableCompanion row) async {
    final pid = row.productId.value;
    final existing = await getStockControl(pid);
    if (existing != null && existing.syncStatus != 'synced') return; // keep local edit
    await into(stockControlsTable).insertOnConflictUpdate(row);
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
      StartingCashTableCompanion movement) async {
    final localId = movement.localId.present && movement.localId.value.isNotEmpty
        ? movement.localId.value
        : const Uuid().v4();

    await into(startingCashTable).insert(
      movement.copyWith(
        localId: Value(localId),
        serverId: const Value(null),
        syncStatus: const Value('pending'),
        syncError: const Value(null),
      ),
    );
  }

  Future<List<StartingCashTableData>> getPendingCashMovements() {
    return (select(startingCashTable)
          ..where((t) => t.syncStatus.equals('pending')))
        .get();
  }

  Future<void> markCashMovementSynced(String localId, int serverId) {
    return (update(startingCashTable)
          ..where((t) => t.localId.equals(localId)))
        .write(StartingCashTableCompanion(
      serverId: Value(serverId),
      syncStatus: const Value('synced'),
      syncError: const Value(null),
    ));
  }

  Future<void> markCashMovementFailed(String localId, String errorMessage) {
    return (update(startingCashTable)
          ..where((t) => t.localId.equals(localId)))
        .write(StartingCashTableCompanion(
      syncStatus: const Value('failed'),
      syncError: Value(errorMessage),
    ));
  }

  /// Map of every locally-known server `id` → whether it's *really* finalized
  /// (has a real, server-assigned Z-report number). The optimistic placeholder
  /// (-1) counts as NOT finalized so the pull-sync overwrites it with the
  /// authoritative server number. The pull also uses this to skip re-inserting
  /// rows it already has.
  Future<Map<int, bool>> getStartingCashFinalizationByServerId() async {
    final query = selectOnly(startingCashTable)
      ..addColumns([startingCashTable.serverId, startingCashTable.zReportNumber])
      ..where(startingCashTable.serverId.isNotNull());
    final rows = await query.get();
    return {
      for (final r in rows)
        r.read(startingCashTable.serverId)!: () {
          final z = r.read(startingCashTable.zReportNumber);
          return z != null && z != optimisticZReportPlaceholder;
        }(),
    };
  }

  /// Inserts server-originated cash rows pulled from /StartingCash. Each row
  /// is already `synced` (it lives on the server). New UUID local ids never
  /// collide, so insertOrIgnore is just a belt-and-braces guard.
  Future<void> insertSyncedStartingCash(
      List<StartingCashTableCompanion> rows) async {
    if (rows.isEmpty) return;
    await batch((b) => b.insertAll(startingCashTable, rows,
        mode: InsertMode.insertOrIgnore));
  }

  /// Stamps Z-report numbers onto already-local rows (keyed by server id) once
  /// the server has finalized them — this is what makes finalized entries drop
  /// off the active list on the next sync.
  Future<void> applyStartingCashZReportNumbers(
      Map<int, int> zReportByServerId) async {
    if (zReportByServerId.isEmpty) return;
    await batch((b) {
      zReportByServerId.forEach((serverId, zNumber) {
        b.update(
          startingCashTable,
          StartingCashTableCompanion(zReportNumber: Value(zNumber)),
          where: (t) => t.serverId.equals(serverId),
        );
      });
    });
  }

  /// Placeholder used to mark a cash row as locally finalized *before* the
  /// server has assigned a real sequential Z-report number. Treated as
  /// "not yet finalized" by the pull-sync so the server value overwrites it.
  static const int optimisticZReportPlaceholder = -1;

  /// Optimistic local finalization: stamps the placeholder Z-report number on
  /// every still-active cash row for [companyId] in one atomic transaction, so
  /// they drop out of `watchTodayStartingCash` instantly — no network wait.
  /// The next pull reconciles each row with the server's real Z-report number.
  Future<void> optimisticallyFinalizeActiveStartingCash(int companyId) async {
    await transaction(() async {
      await (update(startingCashTable)
            ..where((t) => t.companyId.equals(companyId))
            ..where((t) => t.zReportNumber.isNull()))
          .write(const StartingCashTableCompanion(
        zReportNumber: Value(optimisticZReportPlaceholder),
      ));
    });
  }

  /// Watches today's *active* cash movements for [companyId], newest first —
  /// the offline-first source for the Cash In/Out entries list. Rows already
  /// linked to a Z-report (`zReportNumber` not null) are filtered out at the
  /// engine level so finalized entries vanish without any in-memory scanning.
  Stream<List<StartingCashTableData>> watchTodayStartingCash(int companyId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return (select(startingCashTable)
          ..where((t) => t.companyId.equals(companyId))
          ..where((t) => t.zReportNumber.isNull())
          ..where((t) => t.createdAt.isBiggerOrEqualValue(startOfDay))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
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

  // ─── Unreported payments (offline Z-report aggregation) ────────────────────

  /// Payments not yet assigned to a Z-report, scoped to a company via their
  /// parent document. Drives the offline `unreportedPaymentsProvider` and the
  /// Close-Register aggregation.
  Future<List<PaymentsTableData>> getUnreportedPayments(int companyId) async {
    final q = select(paymentsTable).join([
      innerJoin(documentsTable,
          documentsTable.localId.equalsExp(paymentsTable.documentId)),
    ])
      ..where(documentsTable.companyId.equals(companyId))
      ..where(paymentsTable.zReportId.isNull())
      ..where(paymentsTable.syncStatus.equals('pending_delete').not());
    final rows = await q.get();
    return rows.map((r) => r.readTable(paymentsTable)).toList();
  }

  /// Stamps the optimistic placeholder Z-report id on every still-unreported
  /// payment for a company so they drop out of the unreported list immediately
  /// when the register is closed offline.
  Future<void> assignUnreportedPaymentsToZReport(int companyId) async {
    final docRows = await (selectOnly(documentsTable)
          ..addColumns([documentsTable.localId])
          ..where(documentsTable.companyId.equals(companyId)))
        .get();
    final docIds =
        docRows.map((r) => r.read(documentsTable.localId)!).toList();
    if (docIds.isEmpty) return;
    await (update(paymentsTable)
          ..where((t) => t.documentId.isIn(docIds))
          ..where((t) => t.zReportId.isNull()))
        .write(const PaymentsTableCompanion(
            zReportId: Value(optimisticZReportPlaceholder)));
  }

  /// Active (unfinalized) cash movements for a company — used to total cash
  /// in/out into the offline Z-report.
  Future<List<StartingCashTableData>> getActiveStartingCash(int companyId) =>
      (select(startingCashTable)
            ..where((t) => t.companyId.equals(companyId))
            ..where((t) => t.zReportNumber.isNull()))
          .get();

  // ─── Stock-control rules (lazy offline cache) ──────────────────────────────

  Future<StockControlsTableData?> getStockControl(int productId) =>
      (select(stockControlsTable)
            ..where((t) => t.productId.equals(productId))
            ..limit(1))
          .getSingleOrNull();

  Future<void> upsertStockControl(StockControlsTableCompanion row) =>
      into(stockControlsTable).insertOnConflictUpdate(row);

  /// All active (non-deleted) stock-control rules for a company — offline-first
  /// source for evaluating low-stock / reorder status across the stock list.
  Future<List<StockControlsTableData>> getStockControlsForCompany(
          int companyId) =>
      (select(stockControlsTable)
            ..where((t) => t.companyId.equals(companyId))
            ..where((t) => t.syncStatus.equals('pending_delete').not()))
          .get();

  // ---------------- SHIFTS ----------------

  Future<void> insertOfflineShift(ShiftsTableCompanion shift) async {
    final localId = shift.localId.present && shift.localId.value.isNotEmpty
        ? shift.localId.value
        : const Uuid().v4();
    await into(shiftsTable).insert(
      shift.copyWith(localId: Value(localId)),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<ShiftsTableData>> getPendingShifts() {
    return (select(shiftsTable)
          ..where((t) => t.syncStatus.equals('pending')))
        .get();
  }

  Future<ShiftsTableData?> getActiveShift(int companyId) {
    return (select(shiftsTable)
          ..where((t) => t.companyId.equals(companyId))
          ..where((t) => t.status.equals(0))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<ShiftsTableData>> getShiftHistory(int companyId) {
    return (select(shiftsTable)
          ..where((t) => t.companyId.equals(companyId))
          ..orderBy([(t) => OrderingTerm.desc(t.openedAt)]))
        .get();
  }

  Future<void> markShiftSynced(String localId, int serverId) {
    return (update(shiftsTable)..where((t) => t.localId.equals(localId)))
        .write(ShiftsTableCompanion(
      serverId: Value(serverId),
      syncStatus: const Value('synced'),
      syncError: const Value(null),
    ));
  }

  Future<void> markShiftFailed(String localId, String errorMessage) {
    return (update(shiftsTable)..where((t) => t.localId.equals(localId)))
        .write(ShiftsTableCompanion(
      syncStatus: const Value('failed'),
      syncError: Value(errorMessage),
    ));
  }

  // ---------------- TIME CLOCK ----------------

  Future<void> insertClockIn(TimeClockEntriesTableCompanion entry) async {
    final localId = entry.localId.present && entry.localId.value.isNotEmpty
        ? entry.localId.value
        : const Uuid().v4();
    await into(timeClockEntriesTable).insert(
      entry.copyWith(localId: Value(localId)),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Finds the most recent open entry (clockOutTime == null) for [userId].
  Future<TimeClockEntriesTableData?> getActiveClockEntry(int userId) {
    return (select(timeClockEntriesTable)
          ..where((t) => t.userId.equals(userId))
          ..where((t) => t.clockOutTime.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.clockInTime)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> clockOut(String localId, DateTime clockOutTime) {
    return (update(timeClockEntriesTable)
          ..where((t) => t.localId.equals(localId)))
        .write(TimeClockEntriesTableCompanion(
      clockOutTime: Value(clockOutTime),
      syncStatus: const Value('pending'),
      syncError: const Value(null),
    ));
  }

  Future<List<TimeClockEntriesTableData>> getPendingTimeClockEntries() {
    return (select(timeClockEntriesTable)
          ..where((t) => t.syncStatus.equals('pending')))
        .get();
  }

  Future<void> markTimeClockEntrySynced(String localId, int serverId) {
    return (update(timeClockEntriesTable)
          ..where((t) => t.localId.equals(localId)))
        .write(TimeClockEntriesTableCompanion(
      serverId: Value(serverId),
      syncStatus: const Value('synced'),
      syncError: const Value(null),
    ));
  }

  Future<void> markTimeClockEntryFailed(String localId, String errorMessage) {
    return (update(timeClockEntriesTable)
          ..where((t) => t.localId.equals(localId)))
        .write(TimeClockEntriesTableCompanion(
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
