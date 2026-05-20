import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/auth/auth_provider.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/reports/report_models.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final _cashEntriesProvider =
    FutureProvider.autoDispose<List<StartingCashRow>>((ref) async {
  final companyId = ref.watch(selectedCompanyProvider)?.id;
  if (companyId == null) return [];

  final today = DateTime.now();
  final start = DateTime(today.year, today.month, today.day);

  final dio = createDio();
  final response = await dio.get(
    '/StartingCash/GetByDateRange',
    queryParameters: {
      'companyId': companyId,
      'startDate': start.toIso8601String(),
      'endDate':   start.toIso8601String(),
    },
  );

  final list = (response.data as List)
      .map((j) => StartingCashRow.fromJson(j as Map<String, dynamic>))
      .toList();
  return list.reversed.toList();
});

// ── Screen ────────────────────────────────────────────────────────────────────

class CashMovementScreen extends ConsumerStatefulWidget {
  const CashMovementScreen({super.key});

  @override
  ConsumerState<CashMovementScreen> createState() => _CashMovementScreenState();
}

class _CashMovementScreenState extends ConsumerState<CashMovementScreen> {
  int _type = 0; // 0 = Cash In (Add), 1 = Cash Out (Remove)
  final _amountCtrl = TextEditingController(text: '0');
  final _descCtrl   = TextEditingController();
  bool   _saving    = false;
  String? _error;

  static final _dtFmt = DateFormat('dd/MM/yyyy HH:mm:ss');
  static final _numFmt = NumberFormat('#,##0.00');

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text.trim().replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount greater than zero.');
      return;
    }

    final company = ref.read(selectedCompanyProvider);
    final user    = ref.read(currentUserProvider);
    if (company == null || user == null) {
      setState(() => _error = 'Missing company or user context.');
      return;
    }

    setState(() {
      _saving = true;
      _error  = null;
    });

    try {
      final dio = createDio();
      await dio.post(
        '/StartingCash/Add',
        queryParameters: {
          'companyId':        company.id,
          'userId':           user.id,
          'amount':           amount,
          'startingCashType': _type,
          if (_descCtrl.text.trim().isNotEmpty)
            'description': _descCtrl.text.trim(),
        },
      );
      _amountCtrl.text = '0';
      _descCtrl.clear();
      setState(() => _saving = false);
      ref.invalidate(_cashEntriesProvider);
    } on DioException catch (e) {
      setState(() {
        _error  = e.response?.data?.toString() ?? 'Failed to save cash movement.';
        _saving = false;
      });
    } catch (e) {
      setState(() {
        _error  = e.toString();
        _saving = false;
      });
    }
  }

  void _cancel() {
    _amountCtrl.text = '0';
    _descCtrl.clear();
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final cs      = theme.colorScheme;
    final isDark  = theme.brightness == Brightness.dark;
    final entries = ref.watch(_cashEntriesProvider);

    final isCashIn = _type == 0;
    const activeBlue = Color(0xFF2196F3);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cash In / Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Type selector ─────────────────────────────────────
                      Row(
                        children: [
                          _TypeButton(
                            label: 'Add cash',
                            icon: Icons.arrow_downward_rounded,
                            selected: isCashIn,
                            activeColor: activeBlue,
                            onTap: () => setState(() => _type = 0),
                          ),
                          const SizedBox(width: 4),
                          _TypeButton(
                            label: 'Remove cash',
                            icon: Icons.arrow_upward_rounded,
                            selected: !isCashIn,
                            activeColor: cs.error,
                            onTap: () => setState(() => _type = 1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Amount ────────────────────────────────────────────
                      Text(
                        'Amount',
                        style: TextStyle(
                          color: isCashIn ? activeBlue : cs.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.right,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        onTap: () {
                          if (_amountCtrl.text == '0') _amountCtrl.clear();
                        },
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white24
                                  : Colors.black26,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: isCashIn ? activeBlue : cs.error,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Description ───────────────────────────────────────
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _descCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Enter the reason for adding or removing cash...',
                          hintStyle: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.35),
                            fontSize: 13,
                          ),
                          contentPadding: const EdgeInsets.all(12),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: isDark ? Colors.white24 : Colors.black26,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: isCashIn ? activeBlue : cs.error,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style: TextStyle(color: cs.error, fontSize: 13),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // ── Cash entries list ─────────────────────────────────
                      entries.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (e, _) => Text(
                          'Could not load entries: $e',
                          style: TextStyle(color: cs.error, fontSize: 12),
                        ),
                        data: (rows) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cash entries (${rows.length})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (rows.isEmpty)
                                Text(
                                  'No cash movements today.',
                                  style: TextStyle(
                                    color: cs.onSurface.withValues(alpha: 0.5),
                                    fontSize: 13,
                                  ),
                                )
                              else
                                ...rows.map((r) => _EntryTile(
                                      row: r,
                                      dtFmt: _dtFmt,
                                      numFmt: _numFmt,
                                    )),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // ── Action buttons (pinned to bottom) ─────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : _cancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: isCashIn ? activeBlue : cs.error,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                isCashIn ? 'Save Cash In' : 'Save Cash Out',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Type selector button ──────────────────────────────────────────────────────

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = selected
        ? activeColor
        : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0));
    final fg = selected
        ? Colors.white
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: fg, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Single entry row ──────────────────────────────────────────────────────────

class _EntryTile extends StatelessWidget {
  final StartingCashRow row;
  final DateFormat dtFmt;
  final NumberFormat numFmt;

  const _EntryTile({
    required this.row,
    required this.dtFmt,
    required this.numFmt,
  });

  @override
  Widget build(BuildContext context) {
    final isCashOut = row.isCashOut;
    final color     = isCashOut ? Colors.red : Colors.green;
    final sign      = isCashOut ? '-' : '+';
    final userName  = row.userName ?? 'Unknown';
    final desc      = row.description?.isNotEmpty == true
        ? row.description!
        : (isCashOut ? 'Cash out' : 'Cash in');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCashOut ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$sign${numFmt.format(row.amount)} / $desc',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$userName @ ${dtFmt.format(row.dateCreated)}',
                  style: TextStyle(
                    color: color.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
