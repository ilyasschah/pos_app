import 'package:drift/drift.dart' show Value, OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:pos_app/auth/auth_provider.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/database/app_database.dart';
import 'package:pos_app/database/database_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

/// Stream of the currently active (status=0) shift for the selected company.
/// Emits null when no shift is open.
final activeShiftProvider = StreamProvider<ShiftsTableData?>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final companyId = ref.watch(selectedCompanyProvider)?.id;
  if (companyId == null) return Stream.value(null);

  return (db.select(db.shiftsTable)
        ..where((t) => t.companyId.equals(companyId))
        ..where((t) => t.status.equals(0))
        ..limit(1))
      .watchSingleOrNull();
});

/// Ordered history of all shifts for the selected company (newest first).
final shiftHistoryProvider = StreamProvider<List<ShiftsTableData>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final companyId = ref.watch(selectedCompanyProvider)?.id;
  if (companyId == null) return Stream.value(const []);

  return (db.select(db.shiftsTable)
        ..where((t) => t.companyId.equals(companyId))
        ..orderBy([(t) => OrderingTerm.desc(t.openedAt)]))
      .watch();
});

final shiftNotifierProvider =
    NotifierProvider<ShiftNotifier, void>(() => ShiftNotifier());

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class ShiftNotifier extends Notifier<void> {
  @override
  void build() {}

  AppDatabase get _db => ref.read(appDatabaseProvider);

  /// Opens a new shift with the given starting cash drawer amount.
  /// Also records a 'cash in' movement for the starting cash.
  Future<void> startShift(double startingCash) async {
    final companyId = ref.read(selectedCompanyProvider)?.id;
    final user = ref.read(currentUserProvider);
    if (companyId == null || user == null) return;

    final now = DateTime.now().toUtc();
    final localId = const Uuid().v4();

    await _db.insertOfflineShift(
      ShiftsTableCompanion(
        localId: Value(localId),
        companyId: Value(companyId),
        userId: Value(user.id),
        startingCash: Value(startingCash),
        status: const Value(0),
        openedAt: Value(now),
        lastModified: Value(now),
        syncStatus: const Value('pending'),
      ),
    );

    // Record the starting cash as a cash-in movement so it appears in the
    // cash movement history and counts toward the drawer balance.
    if (startingCash > 0) {
      await _db.insertOfflineCashMovement(
        CashMovementsTableCompanion(
          localId: Value(const Uuid().v4()),
          companyId: Value(companyId),
          userId: Value(user.id),
          amount: Value(startingCash),
          type: const Value('in'),
          note: const Value('Shift opening float'),
          createdAt: Value(now),
          syncStatus: const Value('pending'),
        ),
      );
    }
  }

  /// Closes the current open shift and generates an offline Z-report snapshot.
  /// [actualCountedCash] is the physical count the cashier enters.
  Future<void> closeShift(
    ShiftsTableData activeShift, {
    required double actualCountedCash,
  }) async {
    final companyId = ref.read(selectedCompanyProvider)?.id;
    final user = ref.read(currentUserProvider);
    if (companyId == null || user == null) return;

    final now = DateTime.now().toUtc();

    // ── Aggregate cash movements since shift opened ────────────────────────
    final allMovements = await (_db.select(_db.cashMovementsTable)
          ..where((t) => t.companyId.equals(companyId)))
        .get();
    final shiftMovements = allMovements
        .where((m) => !m.createdAt.isBefore(activeShift.openedAt))
        .toList();

    double totalCashIn = 0;
    double totalCashOut = 0;
    for (final m in shiftMovements) {
      if (m.type == 'in') {
        totalCashIn += m.amount;
      } else {
        totalCashOut += m.amount;
      }
    }

    // ── Aggregate cash sales from documents since shift opened ─────────────
    // Cash payment type ID 1 is the standard cash type. We aggregate from
    // the payments table so we only count completed sales in this shift window.
    final allPayments = await (_db.select(_db.paymentsTable)).get();
    final shiftPayments = allPayments
        .where((p) => !p.date.isBefore(activeShift.openedAt))
        .toList();

    double cashSales = 0;
    for (final p in shiftPayments) {
      // paymentTypeId 1 = Cash (standard assumption; adapt if needed)
      if (p.paymentTypeId == 1) {
        cashSales += p.amount;
      }
    }

    final totalSales = cashSales;

    // ── Mark shift closed ──────────────────────────────────────────────────
    await (_db.update(_db.shiftsTable)
          ..where((t) => t.localId.equals(activeShift.localId)))
        .write(ShiftsTableCompanion(
      status: const Value(1),
      closedAt: Value(now),
      actualEndingCash: Value(actualCountedCash),
      lastModified: Value(now),
      syncStatus: const Value('pending'),
    ));

    // ── Insert Z-report snapshot ───────────────────────────────────────────
    await _db.insertOfflineZReport(
      ZReportsTableCompanion(
        localId: Value(const Uuid().v4()),
        companyId: Value(companyId),
        userId: Value(user.id),
        totalSales: Value(totalSales),
        totalCashIn: Value(totalCashIn),
        totalCashOut: Value(totalCashOut),
        paymentBreakdownJson: const Value('{}'),
        closedAt: Value(now),
        syncStatus: const Value('pending'),
      ),
    );
  }

  /// Records a cash-in or cash-out movement during an open shift.
  Future<void> addCashMovement({
    required double amount,
    required String type, // 'in' | 'out'
    String? note,
  }) async {
    final companyId = ref.read(selectedCompanyProvider)?.id;
    final user = ref.read(currentUserProvider);
    if (companyId == null || user == null) return;

    await _db.insertOfflineCashMovement(
      CashMovementsTableCompanion(
        localId: Value(const Uuid().v4()),
        companyId: Value(companyId),
        userId: Value(user.id),
        amount: Value(amount),
        type: Value(type),
        note: Value(note),
        createdAt: Value(DateTime.now().toUtc()),
        syncStatus: const Value('pending'),
      ),
    );
  }
}
