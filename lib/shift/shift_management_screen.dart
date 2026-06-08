import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:pos_app/auth/auth_provider.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/database/app_database.dart';
import 'package:pos_app/database/database_provider.dart';
import 'package:pos_app/shift/shift_provider.dart';
import 'package:pos_app/time_clock/time_clock_provider.dart';
import 'package:pos_app/utils/snackbar_helper.dart';

class ShiftManagementScreen extends ConsumerWidget {
  const ShiftManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shift Management'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.timer_outlined), text: 'My Shift'),
              Tab(icon: Icon(Icons.bar_chart_outlined), text: 'Hours Report'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ShiftTab(),
            _HoursTab(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB A — Existing shift management logic
// ─────────────────────────────────────────────────────────────────────────────

class _ShiftTab extends ConsumerWidget {
  const _ShiftTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(activeShiftProvider).when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (shift) =>
          shift == null ? _NoShiftView() : _ActiveShiftView(shift: shift),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BRANCH A — No active shift
// ─────────────────────────────────────────────────────────────────────────────

class _NoShiftView extends ConsumerStatefulWidget {
  @override
  ConsumerState<_NoShiftView> createState() => _NoShiftViewState();
}

class _NoShiftViewState extends ConsumerState<_NoShiftView> {
  final _ctrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _startShift() async {
    final amount = double.tryParse(_ctrl.text) ?? 0;
    setState(() => _saving = true);
    try {
      await ref.read(shiftNotifierProvider.notifier).startShift(amount);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final user = ref.watch(currentUserProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Card(
          color: theme.cardColor,
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.lock_clock,
                    size: 56, color: cs.primary.withValues(alpha: 0.7)),
                const SizedBox(height: 16),
                Text(
                  'No Active Shift',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  [user?.firstName, user?.lastName]
                      .whereType<String>()
                      .join(' ')
                      .trim(),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Text('Opening float amount',
                    style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  controller: _ctrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saving ? null : _startShift,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lock_open),
                  label: const Text('Open Drawer / Start Shift'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BRANCH B — Active shift dashboard
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveShiftView extends ConsumerStatefulWidget {
  final ShiftsTableData shift;
  const _ActiveShiftView({required this.shift});

  @override
  ConsumerState<_ActiveShiftView> createState() => _ActiveShiftViewState();
}

class _ActiveShiftViewState extends ConsumerState<_ActiveShiftView> {
  bool _closing = false;

  Future<void> _addMovement(String type) async {
    final amtCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).cardColor,
        title: Text(type == 'in' ? 'Cash In' : 'Cash Out'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amtCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final amount = double.tryParse(amtCtrl.text) ?? 0;
    if (amount <= 0) return;
    await ref.read(shiftNotifierProvider.notifier).addCashMovement(
          amount: amount,
          type: type,
          note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
        );
  }

  Future<void> _endShift() async {
    final amtCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).cardColor,
        title: const Text('End Shift'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Count the cash in the drawer and enter the total below. '
              'A Z-Report will be generated automatically.',
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(ctx)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amtCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Actual drawer count',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Close Shift & Generate Z-Report'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _closing = true);
    try {
      await ref
          .read(shiftNotifierProvider.notifier)
          .closeShift(widget.shift,
              actualCountedCash: double.tryParse(amtCtrl.text) ?? 0);
    } finally {
      if (mounted) setState(() => _closing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final shift = widget.shift;
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final currFmt = NumberFormat('#,##0.00');

    final duration = DateTime.now().difference(shift.openedAt);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Shift summary card ─────────────────────────────────────────
          Card(
            color: cs.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_open,
                          color: cs.onPrimaryContainer, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Shift Open',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_closing)
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.onPrimaryContainer),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${hours}h ${minutes}m',
                            style: TextStyle(
                                color: cs.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    label: 'Opened at',
                    value: fmt.format(shift.openedAt.toLocal()),
                    color: cs.onPrimaryContainer,
                  ),
                  _InfoRow(
                    label: 'Opening float',
                    value: currFmt.format(shift.startingCash),
                    color: cs.onPrimaryContainer,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Action buttons ─────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _closing ? null : () => _addMovement('in'),
                  icon: const Icon(Icons.add),
                  label: const Text('Cash In'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _closing ? null : () => _addMovement('out'),
                  icon: const Icon(Icons.remove),
                  label: const Text('Cash Out'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: cs.error,
                    side: BorderSide(color: cs.error),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Recent movements ───────────────────────────────────────────
          _ShiftMovementsCard(shiftOpenedAt: shift.openedAt),

          const SizedBox(height: 24),

          // ── End shift ──────────────────────────────────────────────────
          FilledButton.icon(
            onPressed: _closing ? null : _endShift,
            icon: const Icon(Icons.lock),
            label: const Text('End Shift & Generate Z-Report'),
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RECENT MOVEMENTS CARD
// ─────────────────────────────────────────────────────────────────────────────

class _ShiftMovementsCard extends ConsumerWidget {
  final DateTime shiftOpenedAt;
  const _ShiftMovementsCard({required this.shiftOpenedAt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cash Movements This Shift',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ref.watch(_shiftMovementsProvider(shiftOpenedAt)).when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
              data: (movements) {
                if (movements.isEmpty) {
                  return Text(
                    'No movements yet.',
                    style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.5)),
                  );
                }
                final fmt = DateFormat('HH:mm');
                final currFmt = NumberFormat('#,##0.00');
                return Column(
                  children: movements.map((m) {
                    final isIn = m.type == 'in';
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isIn
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: isIn ? Colors.green : cs.error,
                        size: 20,
                      ),
                      title: Text(
                        '${isIn ? '+' : '-'}${currFmt.format(m.amount)}',
                        style: TextStyle(
                          color: isIn ? Colors.green : cs.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: m.note != null ? Text(m.note!) : null,
                      trailing: Text(
                        fmt.format(m.createdAt.toLocal()),
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.5)),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB B — Hours report
// ─────────────────────────────────────────────────────────────────────────────

class _HoursTab extends ConsumerStatefulWidget {
  const _HoursTab();

  @override
  ConsumerState<_HoursTab> createState() => _HoursTabState();
}

class _HoursTabState extends ConsumerState<_HoursTab> {
  late DateTimeRange _range;
  int? _selectedUserId;
  int _page = 0;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _range = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
  }

  Future<void> _pickRange() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _range,
    );
    if (result != null && mounted) {
      setState(() {
        _range = result;
        _page = 0;
      });
    }
  }

  HoursQueryParams get _params {
    final companyId = ref.read(selectedCompanyProvider)?.id ?? 0;
    final start = _range.start;
    final end = _range.end;
    return (
      rangeStart: DateTime(start.year, start.month, start.day).toUtc(),
      rangeEnd:
          DateTime(end.year, end.month, end.day, 23, 59, 59).toUtc(),
      userId: _selectedUserId,
      companyId: companyId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final company = ref.watch(selectedCompanyProvider);
    final storeName = company?.name ?? '';
    final hoursAsync = ref.watch(hoursReportProvider(_params));
    final allUsersAsync = ref.watch(allUsersProvider);

    final dateFmt = DateFormat('MMM d, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Filter bar ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Date range picker chip
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _pickRange,
                child: Container(
                  height: 44,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: cs.outline.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: cs.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        '${dateFmt.format(_range.start)}  –  ${dateFmt.format(_range.end)}',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: cs.onSurface),
                      ),
                    ],
                  ),
                ),
              ),

              // Employee dropdown
              allUsersAsync.when(
                loading: () => const SizedBox(
                    height: 44, width: 160, child: LinearProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
                data: (users) => ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 180),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: cs.outline.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: _selectedUserId,
                        isExpanded: true,
                        dropdownColor: theme.cardColor,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: cs.onSurface),
                        items: [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text('All employees ...',
                                style: TextStyle(color: cs.onSurface)),
                          ),
                          ...users.map((u) {
                            final name = [u.firstName, u.lastName]
                                .whereType<String>()
                                .where((s) => s.isNotEmpty)
                                .join(' ')
                                .trim();
                            return DropdownMenuItem<int?>(
                              value: u.id,
                              child: Text(
                                name.isEmpty
                                    ? (u.username ?? 'User #${u.id}')
                                    : name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: cs.onSurface),
                              ),
                            );
                          }),
                        ],
                        onChanged: (id) => setState(() {
                          _selectedUserId = id;
                          _page = 0;
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Report card ────────────────────────────────────────────────
        Expanded(
          child: hoursAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (rows) => _HoursReportCard(
              rows: rows,
              storeName: storeName,
              page: _page,
              rowsPerPage: _rowsPerPage,
              onPageChanged: (p) => setState(() => _page = p),
              onRowsPerPageChanged: (r) =>
                  setState(() { _rowsPerPage = r; _page = 0; }),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOURS REPORT CARD (table + export + pagination)
// ─────────────────────────────────────────────────────────────────────────────

class _HoursReportCard extends StatelessWidget {
  final List<HoursReportRow> rows;
  final String storeName;
  final int page;
  final int rowsPerPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onRowsPerPageChanged;

  const _HoursReportCard({
    required this.rows,
    required this.storeName,
    required this.page,
    required this.rowsPerPage,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
  });

  int get _totalPages =>
      rows.isEmpty ? 1 : (rows.length / rowsPerPage).ceil();

  int get _safePage => page.clamp(0, _totalPages - 1);

  String _fmtHours(int minutes) =>
      NumberFormat.decimalPatternDigits(decimalDigits: 2)
          .format(minutes / 60.0);

  void _doExport(BuildContext context) {
    final sb = StringBuffer('Employee,Store,Total Hours\n');
    for (final r in rows) {
      final emp = r.employeeName.contains(',')
          ? '"${r.employeeName}"'
          : r.employeeName;
      final store =
          storeName.contains(',') ? '"$storeName"' : storeName;
      sb.writeln('$emp,$store,${_fmtHours(r.totalMinutes)}');
    }
    Clipboard.setData(ClipboardData(text: sb.toString()));
    showAppSnackbarRaw(context, 'Report copied to clipboard as CSV');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final labelStyle = theme.textTheme.bodySmall
        ?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w500);
    final dividerColor = cs.outline.withValues(alpha: 0.22);

    final pageRows =
        rows.skip(_safePage * rowsPerPage).take(rowsPerPage).toList();
    final totalMinutes =
        rows.fold(0, (sum, r) => sum + r.totalMinutes);

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // EXPORT button row
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => _doExport(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'EXPORT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: dividerColor),

          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text('Employee', style: labelStyle),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Store', style: labelStyle),
                ),
                Text(
                  'Total hours',
                  style: labelStyle?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: dividerColor),

          // Data rows
          Expanded(
            child: rows.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_off_outlined,
                            size: 40,
                            color: cs.onSurfaceVariant
                                .withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text(
                          'No time entries in the selected range.',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: pageRows.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: dividerColor),
                    itemBuilder: (_, i) {
                      final row = pageRows[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                row.employeeName,
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                storeName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: cs.onSurface
                                      .withValues(alpha: 0.55),
                                ),
                              ),
                            ),
                            Text(
                              _fmtHours(row.totalMinutes),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Total row (only when there is data)
          if (rows.isNotEmpty) ...[
            Divider(height: 1, color: dividerColor),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      'Total',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Expanded(flex: 3, child: SizedBox()),
                  Text(
                    _fmtHours(totalMinutes),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],

          // Pagination footer
          Divider(height: 1, color: dividerColor),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                // Prev arrow
                IconButton(
                  icon: Icon(Icons.chevron_left,
                      color: _safePage > 0
                          ? cs.onSurface
                          : cs.onSurface.withValues(alpha: 0.25)),
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: _safePage > 0
                      ? () => onPageChanged(_safePage - 1)
                      : null,
                ),
                // Next arrow
                IconButton(
                  icon: Icon(Icons.chevron_right,
                      color: _safePage < _totalPages - 1
                          ? cs.onSurface
                          : cs.onSurface.withValues(alpha: 0.25)),
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: _safePage < _totalPages - 1
                      ? () => onPageChanged(_safePage + 1)
                      : null,
                ),
                const SizedBox(width: 4),
                Text('Page:',
                    style: labelStyle),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: cs.outline.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${_safePage + 1}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 6),
                Text('of $_totalPages', style: labelStyle),
                const Spacer(),
                Text('Rows per page:', style: labelStyle),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: rowsPerPage,
                    isDense: true,
                    dropdownColor: theme.cardColor,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cs.onSurface),
                    items: [10, 25, 50]
                        .map((n) => DropdownMenuItem<int>(
                              value: n,
                              child: Text('$n'),
                            ))
                        .toList(),
                    onChanged: (n) {
                      if (n != null) onRowsPerPageChanged(n);
                    },
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _InfoRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
        color: color ?? Theme.of(context).colorScheme.onSurface);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: style.copyWith(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, style: style)),
        ],
      ),
    );
  }
}

final _shiftMovementsProvider =
    StreamProvider.autoDispose.family<List<CashMovementsTableData>, DateTime>(
  (ref, shiftOpenedAt) {
    final db = ref.watch(appDatabaseProvider);
    return (db.select(db.cashMovementsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((all) => all
            .where((m) => !m.createdAt.isBefore(shiftOpenedAt))
            .toList());
  },
);
