import 'dart:convert';

import 'package:crypto/crypto.dart';
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

/// The currently logged-in user's active (open) clock entry.
/// Emits null when they are not clocked in.
final activeClockEntryProvider = StreamProvider<TimeClockEntriesTableData?>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return Stream.value(null);

  return (db.select(db.timeClockEntriesTable)
        ..where((t) => t.userId.equals(userId))
        ..where((t) => t.clockOutTime.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.clockInTime)])
        ..limit(1))
      .watchSingleOrNull();
});

/// An open clock entry for any user — used by the kiosk Time Clock screen
/// to check if a specific userId (identified by PIN) is currently clocked in.
final activeClockEntryForUserProvider =
    StreamProvider.autoDispose.family<TimeClockEntriesTableData?, int>(
  (ref, userId) {
    final db = ref.watch(appDatabaseProvider);
    return (db.select(db.timeClockEntriesTable)
          ..where((t) => t.userId.equals(userId))
          ..where((t) => t.clockOutTime.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.clockInTime)])
          ..limit(1))
        .watchSingleOrNull();
  },
);

final timeClockNotifierProvider =
    NotifierProvider<TimeClockNotifier, void>(() => TimeClockNotifier());

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class TimeClockNotifier extends Notifier<void> {
  @override
  void build() {}

  AppDatabase get _db => ref.read(appDatabaseProvider);

  int? get _companyId => ref.read(selectedCompanyProvider)?.id;

  /// Clocks in the user identified by [userId].
  /// Returns an error string if the user is already clocked in, null on success.
  Future<String?> clockIn(int userId) async {
    final companyId = _companyId;
    if (companyId == null) return 'No company selected.';

    final existing = await _db.getActiveClockEntry(userId);
    if (existing != null) return 'Already clocked in.';

    await _db.insertClockIn(
      TimeClockEntriesTableCompanion(
        localId: Value(const Uuid().v4()),
        companyId: Value(companyId),
        userId: Value(userId),
        clockInTime: Value(DateTime.now().toUtc()),
        syncStatus: const Value('pending'),
      ),
    );
    return null;
  }

  /// Clocks out the user identified by [userId].
  /// Returns an error string if they are not clocked in, null on success.
  Future<String?> clockOut(int userId) async {
    if (_companyId == null) return 'No company selected.';

    final entry = await _db.getActiveClockEntry(userId);
    if (entry == null) return 'Not currently clocked in.';

    await _db.clockOut(entry.localId, DateTime.now().toUtc());
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PIN → USER LOOKUP  (used by the kiosk screen — no POS login required)
// ─────────────────────────────────────────────────────────────────────────────

/// Hashes a raw 4-digit PIN string to sha256/base64, matching the server's
/// format, then searches the local users table for a matching pinHash row.
/// Returns null if no user has that PIN registered on this device.
Future<UsersTableData?> findUserByPin(AppDatabase db, int companyId, String pin) async {
  final bytes = utf8.encode(pin);
  final digest = sha256.convert(bytes);
  final hashed = base64Encode(digest.bytes);

  final rows = await (db.select(db.usersTable)
        ..where((t) => t.companyId.equals(companyId))
        ..where((t) => t.isEnabled.equals(true)))
      .get();

  try {
    return rows.firstWhere((u) => u.pinHash == hashed);
  } catch (_) {
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOURS CALCULATION UTILITY
// ─────────────────────────────────────────────────────────────────────────────

/// Returns a human-readable duration string: "3h 25m" or "45m".
/// If [clockOutTime] is null, calculates from [clockInTime] to now.
String formatWorkedDuration(DateTime clockInTime, [DateTime? clockOutTime]) {
  final end = (clockOutTime ?? DateTime.now().toUtc()).toUtc();
  final duration = end.difference(clockInTime.toUtc());
  final h = duration.inHours;
  final m = duration.inMinutes.remainder(60);
  if (h > 0) return '${h}h ${m}m';
  return '${m}m';
}

/// Returns the total minutes worked between two times.
int workedMinutes(DateTime clockInTime, [DateTime? clockOutTime]) {
  final end = (clockOutTime ?? DateTime.now().toUtc()).toUtc();
  return end.difference(clockInTime.toUtc()).inMinutes;
}

// ─────────────────────────────────────────────────────────────────────────────
// HOURS REPORT DATA
// ─────────────────────────────────────────────────────────────────────────────

/// One row in the hours report table.
class HoursReportRow {
  final String employeeName;
  final int totalMinutes;
  const HoursReportRow({required this.employeeName, required this.totalMinutes});
}

/// Family key for [hoursReportProvider]. Uses plain DateTimes so the provider
/// file doesn't import the Flutter material library.
typedef HoursQueryParams = ({
  DateTime rangeStart,
  DateTime rangeEnd,
  int? userId,
  int companyId,
});

/// Aggregates total worked minutes per employee within the given date range.
/// If [userId] is null, all employees are returned (with > 0 minutes).
final hoursReportProvider =
    FutureProvider.autoDispose.family<List<HoursReportRow>, HoursQueryParams>(
  (ref, params) async {
    if (params.companyId == 0) return const [];
    final db = ref.watch(appDatabaseProvider);

    final usersQuery = db.select(db.usersTable)
      ..where((t) => t.companyId.equals(params.companyId));
    if (params.userId != null) {
      usersQuery.where((t) => t.id.equals(params.userId!));
    }
    final users = await usersQuery.get();

    final entries = await (db.select(db.timeClockEntriesTable)
          ..where((t) => t.companyId.equals(params.companyId)))
        .get();

    // Build per-user minute totals, clamped to the selected date range.
    final Map<int, int> minutesByUser = {};
    for (final e in entries) {
      if (params.userId != null && e.userId != params.userId) continue;
      final clockIn = e.clockInTime.toUtc();
      if (clockIn.isAfter(params.rangeEnd) ||
          clockIn.isBefore(params.rangeStart)) continue;
      final clockOut = (e.clockOutTime ?? DateTime.now()).toUtc();
      final mins = clockOut.difference(clockIn).inMinutes.clamp(0, 24 * 60);
      minutesByUser[e.userId] = (minutesByUser[e.userId] ?? 0) + mins;
    }

    final results = <HoursReportRow>[];
    for (final u in users) {
      final mins = minutesByUser[u.id] ?? 0;
      if (mins == 0) continue;
      final name = [u.firstName, u.lastName]
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .join(' ')
          .trim();
      results.add(HoursReportRow(
        employeeName: name.isEmpty ? (u.username ?? 'User #${u.id}') : name,
        totalMinutes: mins,
      ));
    }
    results.sort((a, b) => a.employeeName.compareTo(b.employeeName));
    return results;
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// SIDEBAR BADGE SUPPORT
// ─────────────────────────────────────────────────────────────────────────────

/// Streams the current user's total minutes worked today (UTC day boundary).
/// Emits 0 when no entries exist or the user is logged out.
final todayTotalMinutesProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return Stream.value(0);

  final today = DateTime.now();
  final todayStartUtc =
      DateTime(today.year, today.month, today.day).toUtc();

  return (db.select(db.timeClockEntriesTable)
        ..where((t) => t.userId.equals(userId)))
      .watch()
      .map((entries) {
    int total = 0;
    for (final e in entries) {
      if (e.clockInTime.toUtc().isBefore(todayStartUtc)) continue;
      final out = (e.clockOutTime ?? DateTime.now()).toUtc();
      total +=
          out.difference(e.clockInTime.toUtc()).inMinutes.clamp(0, 24 * 60);
    }
    return total;
  });
});

/// Formats a minute duration for the sidebar badge:
/// - Under 60 min  → "-45m"
/// - 60 min or more → "HH:MM"
String formatSidebarDuration(int totalMinutes) {
  if (totalMinutes < 60) return '-${totalMinutes}m';
  final h = totalMinutes ~/ 60;
  final m = totalMinutes % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}
