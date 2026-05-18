import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pos_app/auth/auth_provider.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/customer/customer_provider.dart';
import 'package:pos_app/product/product_provider.dart';
import 'package:pos_app/product/product_group_provider.dart';
import 'package:pos_app/stock/warehouse_provider.dart';
import 'package:pos_app/reports/report_models.dart';
import 'package:pos_app/reports/reports_provider.dart';

// ─── Data models ──────────────────────────────────────────────────────────────

class _ReportType {
  final String id;
  final String label;
  final IconData icon;
  const _ReportType(this.id, this.label, this.icon);
}

class _OpenTab {
  final String id;
  final _ReportType reportType;
  final ReportFilter filter;
  const _OpenTab({required this.id, required this.reportType, required this.filter});
}

// ─── Report catalogue ─────────────────────────────────────────────────────────

const _salesReports = [
  _ReportType('sales_by_product',         'Products',                      Icons.local_offer_outlined),
  _ReportType('sales_by_group',           'Product groups',                Icons.folder_outlined),
  _ReportType('sales_by_customer',        'Customers',                     Icons.people_outline),
  _ReportType('sales_tax',                'Tax rates',                     Icons.percent),
  _ReportType('sales_users',              'Users',                         Icons.person_outline),
  _ReportType('sales_item_list',          'Item list',                     Icons.list_alt_outlined),
  _ReportType('sales_payment_types',      'Payment types',                 Icons.credit_card_outlined),
  _ReportType('sales_payment_by_user',    'Payment types by users',        Icons.manage_accounts_outlined),
  _ReportType('sales_payment_by_customer','Payment types by customers',    Icons.person_pin_outlined),
  _ReportType('sales_refunds',            'Refunds',                       Icons.undo_outlined),
  _ReportType('sales_invoice_list',       'Invoice list',                  Icons.receipt_outlined),
  _ReportType('sales_daily',              'Daily sales',                   Icons.today_outlined),
  _ReportType('sales_hourly',             'Hourly sales',                  Icons.schedule_outlined),
  _ReportType('sales_hourly_group',       'Hourly sales by product groups',Icons.bar_chart_outlined),
  _ReportType('sales_by_table',           'Table or order number',         Icons.table_restaurant_outlined),
  _ReportType('sales_profit',             'Profit & margin',               Icons.trending_up_outlined),
  _ReportType('sales_unpaid',             'Unpaid sales',                  Icons.money_off_outlined),
  _ReportType('sales_starting_cash',      'Starting cash entries',         Icons.account_balance_wallet_outlined),
  _ReportType('sales_voided',             'Voided items',                  Icons.delete_outline),
  _ReportType('sales_discounts',          'Discounts granted',             Icons.discount_outlined),
  _ReportType('sales_item_discounts',     'Items discounts',               Icons.sell_outlined),
  _ReportType('sales_stock_movement',     'Stock movement',                Icons.swap_horiz_outlined),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  _ReportType? _selectedReportType;
  ReportFilter _filter = ReportFilter(
    startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
    endDate: DateTime.now(),
  );
  final List<_OpenTab> _tabs = [];
  String _activeTabId = 'home';
  int _tabCounter = 0;

  void _showReport() {
    if (_selectedReportType == null) return;
    final tab = _OpenTab(
      id: 'tab_${_tabCounter++}',
      reportType: _selectedReportType!,
      filter: _filter,
    );
    setState(() {
      _tabs.add(tab);
      _activeTabId = tab.id;
    });
  }

  void _closeTab(String id) {
    setState(() {
      _tabs.removeWhere((t) => t.id == id);
      if (_activeTabId == id) _activeTabId = 'home';
    });
  }

  Future<void> _exportCsv() async {
    if (_selectedReportType == null) return;
    final filter = _filter;
    final reportId = _selectedReportType!.id;
    final buf = StringBuffer();
    String filename;

    try {
      if (reportId == 'sales_by_product') {
        final rows = await ref.read(salesByProductProvider(filter).future);
        buf.writeln('Code,Product,Quantity,UOM,Total before tax,Total');
        for (final r in rows) {
          buf.writeln('"${r.code ?? ''}","${r.product}",${r.quantity},"${r.uom}",${r.totalBeforeTax},${r.total}');
        }
        buf.writeln('"","Total",${rows.fold(0.0, (s, r) => s + r.quantity)},"",${rows.fold(0.0, (s, r) => s + r.totalBeforeTax)},${rows.fold(0.0, (s, r) => s + r.total)}');
        filename = 'SalesByProduct';
      } else if (reportId == 'sales_by_group') {
        final rows = await ref.read(salesByProductGroupProvider(filter).future);
        buf.writeln('Product group,Quantity,Total before tax,Total');
        for (final r in rows) {
          buf.writeln('"${r.productGroup}",${r.quantity},${r.totalBeforeTax},${r.total}');
        }
        buf.writeln('"Total",${rows.fold(0.0, (s, r) => s + r.quantity)},${rows.fold(0.0, (s, r) => s + r.totalBeforeTax)},${rows.fold(0.0, (s, r) => s + r.total)}');
        filename = 'SalesByProductGroup';
      } else if (reportId == 'sales_by_customer') {
        final rows = await ref.read(salesByCustomerProvider(filter).future);
        buf.writeln('Customer,Total before tax,Total');
        for (final r in rows) {
          buf.writeln('"${r.customer}",${r.totalBeforeTax},${r.total}');
        }
        buf.writeln('"Total",${rows.fold(0.0, (s, r) => s + r.totalBeforeTax)},${rows.fold(0.0, (s, r) => s + r.total)}');
        filename = 'SalesByCustomer';
      } else if (reportId == 'sales_tax') {
        final rows = await ref.read(salesByTaxProvider(filter).future);
        buf.writeln('Tax name,Total before tax,Tax,Total');
        for (final r in rows) {
          buf.writeln('"${r.taxName}",${r.totalBeforeTax},${r.taxAmount},${r.total}');
        }
        buf.writeln('"Total",${rows.fold(0.0, (s, r) => s + r.totalBeforeTax)},${rows.fold(0.0, (s, r) => s + r.taxAmount)},${rows.fold(0.0, (s, r) => s + r.total)}');
        filename = 'SalesTax';
      } else if (reportId == 'sales_payment_by_customer') {
        final rows = await ref.read(paymentTypesByCustomerProvider(filter).future);
        final paymentTypes = rows.map((r) => r.paymentTypeName).toSet().toList()..sort();
        final customers = rows.map((r) => r.customerName).toSet().toList()..sort();
        final pivot = <String, Map<String, double>>{};
        for (final r in rows) {
          pivot.putIfAbsent(r.customerName, () => {});
          pivot[r.customerName]![r.paymentTypeName] =
              (pivot[r.customerName]![r.paymentTypeName] ?? 0) + r.amount;
        }
        buf.writeln(['Customer', ...paymentTypes, 'Total'].map((h) => '"$h"').join(','));
        for (final c in customers) {
          final amounts = paymentTypes.map((pt) => pivot[c]?[pt] ?? 0.0).toList();
          final total = amounts.fold(0.0, (s, a) => s + a);
          buf.writeln(['"$c"', ...amounts, total].join(','));
        }
        final grandAmounts = paymentTypes.map((pt) =>
            customers.fold(0.0, (s, c) => s + (pivot[c]?[pt] ?? 0.0))).toList();
        buf.writeln(['"Total"', ...grandAmounts, rows.fold(0.0, (s, r) => s + r.amount)].join(','));
        filename = 'PaymentTypesByCustomer';
      } else if (reportId == 'sales_payment_by_user') {
        final rows = await ref.read(paymentTypesByUserProvider(filter).future);
        final paymentTypes = rows.map((r) => r.paymentTypeName).toSet().toList()..sort();
        final users = rows.map((r) => r.userName).toSet().toList()..sort();
        final pivot = <String, Map<String, double>>{};
        for (final r in rows) {
          pivot.putIfAbsent(r.userName, () => {});
          pivot[r.userName]![r.paymentTypeName] =
              (pivot[r.userName]![r.paymentTypeName] ?? 0) + r.amount;
        }
        buf.writeln(['User', ...paymentTypes, 'Total'].map((h) => '"$h"').join(','));
        for (final u in users) {
          final amounts = paymentTypes.map((pt) => pivot[u]?[pt] ?? 0.0).toList();
          final total = amounts.fold(0.0, (s, a) => s + a);
          buf.writeln(['"$u"', ...amounts, total].join(','));
        }
        final grandAmounts = paymentTypes.map((pt) =>
            users.fold(0.0, (s, u) => s + (pivot[u]?[pt] ?? 0.0))).toList();
        buf.writeln(['"Total"', ...grandAmounts, rows.fold(0.0, (s, r) => s + r.amount)].join(','));
        filename = 'PaymentTypesByUser';
      } else if (reportId == 'sales_payment_types') {
        final rows = await ref.read(salesByPaymentTypeProvider(filter).future);
        final paymentTypes = rows.map((r) => r.paymentTypeName).toSet().toList()..sort();
        final dates = rows.map((r) => r.date).toSet().toList()..sort();
        final pivot = <DateTime, Map<String, double>>{};
        for (final r in rows) {
          pivot.putIfAbsent(r.date, () => {});
          pivot[r.date]![r.paymentTypeName] =
              (pivot[r.date]![r.paymentTypeName] ?? 0) + r.amount;
        }
        final dateFmt2 = DateFormat('dd/MM/yyyy');
        buf.writeln(['Date', ...paymentTypes, 'Total'].map((h) => '"$h"').join(','));
        for (final d in dates) {
          final amounts = paymentTypes.map((pt) => pivot[d]?[pt] ?? 0.0).toList();
          final total = amounts.fold(0.0, (s, a) => s + a);
          buf.writeln([dateFmt2.format(d), ...amounts, total].join(','));
        }
        // grand total row
        final grandAmounts = paymentTypes.map((pt) =>
            dates.fold(0.0, (s, d) => s + (pivot[d]?[pt] ?? 0.0))).toList();
        buf.writeln(['', ...grandAmounts, rows.fold(0.0, (s, r) => s + r.amount)].join(','));
        filename = 'SalesByPaymentType';
      } else if (reportId == 'sales_item_list') {
        final rows = await ref.read(salesItemListProvider(filter).future);
        buf.writeln('Document type,Date,Create date,Document number,Ref. number,Customer code,Customer,Order number,Code,Product,Quantity,UOM,Total before tax,Total tax,Total');
        final dateFmt = DateFormat('dd/MM/yyyy');
        final dtFmt = DateFormat('dd/MM/yyyy HH:mm:ss');
        for (final r in rows) {
          buf.writeln(
            '"${r.documentTypeName}","${dateFmt.format(r.date)}","${dtFmt.format(r.dateCreated)}",'
            '"${r.documentNumber}","${r.refNumber ?? ''}","${r.customerCode ?? ''}","${r.customerName}",'
            '"${r.orderNumber ?? ''}","${r.productCode ?? ''}","${r.productName}",'
            '${r.quantity},"${r.uom}",${r.totalBeforeTax},${r.totalTax},${r.total}',
          );
        }
        buf.writeln(
          '"","","","","","","","","","Total",'
          '${rows.fold(0.0, (s, r) => s + r.quantity)},"",'
          '${rows.fold(0.0, (s, r) => s + r.totalBeforeTax)},'
          '${rows.fold(0.0, (s, r) => s + r.totalTax)},'
          '${rows.fold(0.0, (s, r) => s + r.total)}',
        );
        filename = 'SalesItemList';
      } else if (reportId == 'sales_users') {
        final rows = await ref.read(salesByUserProvider(filter).future);
        buf.writeln('User,Total before tax,Total');
        for (final r in rows) {
          buf.writeln('"${r.user}",${r.totalBeforeTax},${r.total}');
        }
        buf.writeln('"Total",${rows.fold(0.0, (s, r) => s + r.totalBeforeTax)},${rows.fold(0.0, (s, r) => s + r.total)}');
        filename = 'SalesByUser';
      } else {
        return;
      }

      final file = File(
          '${Directory.systemTemp.path}\\${filename}_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(buf.toString());
      await Process.start('explorer.exe', [file.path]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final activeTab = _tabs.where((t) => t.id == _activeTabId).firstOrNull;

    return Column(
      children: [
        // ── Tab bar ─────────────────────────────────────────────────────────
        Material(
          color: cs.surfaceContainerHighest,
          elevation: 0,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _TabChip(
                  id: 'home',
                  label: 'Select report',
                  icon: Icons.search,
                  active: _activeTabId == 'home',
                  onTap: () => setState(() => _activeTabId = 'home'),
                ),
                ..._tabs.map((t) => _TabChip(
                      id: t.id,
                      label: t.reportType.label,
                      active: _activeTabId == t.id,
                      onTap: () => setState(() => _activeTabId = t.id),
                      onClose: () => _closeTab(t.id),
                    )),
              ],
            ),
          ),
        ),

        Divider(height: 1, color: cs.outlineVariant),

        // ── Body ─────────────────────────────────────────────────────────────
        Expanded(
          child: _activeTabId == 'home'
              ? _HomeView(
                  selected: _selectedReportType,
                  filter: _filter,
                  onSelectReport: (r) => setState(() => _selectedReportType = r),
                  onFilterChanged: (f) => setState(() => _filter = f),
                  onShowReport: _showReport,
                  onExportCsv: _exportCsv,
                )
              : activeTab != null
                  ? _TabPdfView(tab: activeTab)
                  : const Center(child: Text('Tab not found')),
        ),
      ],
    );
  }
}

// ─── Tab chip ─────────────────────────────────────────────────────────────────

class _TabChip extends StatelessWidget {
  final String id;
  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClose;

  const _TabChip({
    required this.id,
    required this.label,
    this.icon,
    required this.active,
    required this.onTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      splashColor: cs.primary.withValues(alpha: 0.1),
      highlightColor: cs.primary.withValues(alpha: 0.05),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? cs.surface : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: active ? cs.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14,
                  color: active ? cs.primary : cs.onSurfaceVariant),
              const Gap(6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: active ? cs.primary : cs.onSurfaceVariant,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (onClose != null) ...[
              const Gap(8),
              InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(Icons.close, size: 13,
                      color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Home view ────────────────────────────────────────────────────────────────

class _HomeView extends StatelessWidget {
  final _ReportType? selected;
  final ReportFilter filter;
  final ValueChanged<_ReportType> onSelectReport;
  final ValueChanged<ReportFilter> onFilterChanged;
  final VoidCallback onShowReport;
  final Future<void> Function() onExportCsv;

  const _HomeView({
    required this.selected,
    required this.filter,
    required this.onSelectReport,
    required this.onFilterChanged,
    required this.onShowReport,
    required this.onExportCsv,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Report list
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
                child: Text(
                  'Select report to view or print',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 6),
                child: Text(
                  'Sales',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: _salesReports.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: cs.outlineVariant),
                  itemBuilder: (_, i) {
                    final r = _salesReports[i];
                    final active = selected?.id == r.id;
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        r.icon,
                        size: 18,
                        color: active ? cs.primary : cs.onSurfaceVariant,
                      ),
                      title: Text(
                        r.label,
                        style: TextStyle(
                          fontSize: 14,
                          color: active ? cs.primary : cs.onSurface,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      selected: active,
                      selectedTileColor:
                          cs.primaryContainer.withValues(alpha: 0.35),
                      onTap: () => onSelectReport(r),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Filter panel
        if (selected != null) ...[
          VerticalDivider(width: 1, color: cs.outlineVariant),
          _FilterPanel(
            reportId: selected!.id,
            filter: filter,
            onFilterChanged: onFilterChanged,
            onShowReport: onShowReport,
            onExportCsv: onExportCsv,
          ),
        ],
      ],
    );
  }
}

// ─── PDF preview tab ──────────────────────────────────────────────────────────

class _TabPdfView extends ConsumerWidget {
  final _OpenTab tab;
  const _TabPdfView({required this.tab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final company = ref.watch(selectedCompanyProvider);
    final customers = ref.watch(allCustomersProvider).value ?? [];
    final users = ref.watch(allUsersProvider).value ?? [];
    final products = ref.watch(allProductsListProvider).value ?? [];

    String customerLabel() {
      if (tab.filter.customerId == null) return 'All';
      return customers
              .where((c) => c.id == tab.filter.customerId)
              .map((c) => c.name)
              .firstOrNull ??
          'All';
    }

    String userLabel() {
      if (tab.filter.userId == null) return 'All';
      return users
              .where((u) => u.id == tab.filter.userId)
              .map((u) =>
                  '${u.firstName ?? ''} ${u.lastName ?? ''}'.trim())
              .firstOrNull ??
          'All';
    }

    String productLabel() {
      if (tab.filter.productId == null) return 'All';
      return products
              .where((p) => p.id == tab.filter.productId)
              .map((p) => p.name)
              .firstOrNull ??
          'All';
    }

    if (tab.reportType.id == 'sales_by_product') {
      final async = ref.watch(salesByProductProvider(tab.filter));
      return async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Error: $e', style: TextStyle(color: cs.error))),
        data: (rows) => PdfPreview(
          pdfFileName: 'SalesByProduct.pdf',
          initialPageFormat: PdfPageFormat.a4.landscape,
          canChangePageFormat: false,
          canDebug: false,
          allowSharing: false,
          build: (_) => _buildProductsPdf(
            rows: rows,
            filter: tab.filter,
            companyName: company?.name,
            companyAddress: company?.address,
            customerLabel: customerLabel(),
            userLabel: userLabel(),
            productLabel: productLabel(),
          ),
        ),
      );
    }

    if (tab.reportType.id == 'sales_by_group') {
      final async = ref.watch(salesByProductGroupProvider(tab.filter));
      return async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Error: $e', style: TextStyle(color: cs.error))),
        data: (rows) => PdfPreview(
          pdfFileName: 'SalesByProductGroup.pdf',
          initialPageFormat: PdfPageFormat.a4.landscape,
          canChangePageFormat: false,
          canDebug: false,
          allowSharing: false,
          build: (_) => _buildProductGroupsPdf(
            rows: rows,
            filter: tab.filter,
            companyName: company?.name,
            companyAddress: company?.address,
            customerLabel: customerLabel(),
            userLabel: userLabel(),
            productLabel: productLabel(),
          ),
        ),
      );
    }

    if (tab.reportType.id == 'sales_by_customer') {
      final async = ref.watch(salesByCustomerProvider(tab.filter));
      return async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Error: $e', style: TextStyle(color: cs.error))),
        data: (rows) => PdfPreview(
          pdfFileName: 'SalesByCustomer.pdf',
          initialPageFormat: PdfPageFormat.a4.landscape,
          canChangePageFormat: false,
          canDebug: false,
          allowSharing: false,
          build: (_) => _buildCustomersPdf(
            rows: rows,
            filter: tab.filter,
            companyName: company?.name,
            companyAddress: company?.address,
            customerLabel: customerLabel(),
            userLabel: userLabel(),
            productLabel: productLabel(),
          ),
        ),
      );
    }

    if (tab.reportType.id == 'sales_tax') {
      final async = ref.watch(salesByTaxProvider(tab.filter));
      return async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Error: $e', style: TextStyle(color: cs.error))),
        data: (rows) => PdfPreview(
          pdfFileName: 'SalesTax.pdf',
          initialPageFormat: PdfPageFormat.a4.landscape,
          canChangePageFormat: false,
          canDebug: false,
          allowSharing: false,
          build: (_) => _buildTaxPdf(
            rows: rows,
            filter: tab.filter,
            companyName: company?.name,
            companyAddress: company?.address,
            customerLabel: customerLabel(),
            userLabel: userLabel(),
            productLabel: productLabel(),
          ),
        ),
      );
    }

    if (tab.reportType.id == 'sales_payment_by_customer') {
      final async = ref.watch(paymentTypesByCustomerProvider(tab.filter));
      return async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Error: $e', style: TextStyle(color: cs.error))),
        data: (rows) => PdfPreview(
          pdfFileName: 'PaymentTypesByCustomer.pdf',
          initialPageFormat: PdfPageFormat.a4.landscape,
          canChangePageFormat: false,
          canDebug: false,
          allowSharing: false,
          build: (_) => _buildPaymentTypesByCustomerPdf(
            rows: rows,
            filter: tab.filter,
            companyName: company?.name,
            companyAddress: company?.address,
            customerLabel: customerLabel(),
            userLabel: userLabel(),
            productLabel: productLabel(),
          ),
        ),
      );
    }

    if (tab.reportType.id == 'sales_payment_by_user') {
      final async = ref.watch(paymentTypesByUserProvider(tab.filter));
      return async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Error: $e', style: TextStyle(color: cs.error))),
        data: (rows) => PdfPreview(
          pdfFileName: 'PaymentTypesByUser.pdf',
          initialPageFormat: PdfPageFormat.a4.landscape,
          canChangePageFormat: false,
          canDebug: false,
          allowSharing: false,
          build: (_) => _buildPaymentTypesByUserPdf(
            rows: rows,
            filter: tab.filter,
            companyName: company?.name,
            companyAddress: company?.address,
            customerLabel: customerLabel(),
            userLabel: userLabel(),
            productLabel: productLabel(),
          ),
        ),
      );
    }

    if (tab.reportType.id == 'sales_payment_types') {
      final async = ref.watch(salesByPaymentTypeProvider(tab.filter));
      return async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Error: $e', style: TextStyle(color: cs.error))),
        data: (rows) => PdfPreview(
          pdfFileName: 'SalesByPaymentType.pdf',
          initialPageFormat: PdfPageFormat.a4.landscape,
          canChangePageFormat: false,
          canDebug: false,
          allowSharing: false,
          build: (_) => _buildPaymentTypesPdf(
            rows: rows,
            filter: tab.filter,
            companyName: company?.name,
            companyAddress: company?.address,
            customerLabel: customerLabel(),
            userLabel: userLabel(),
            productLabel: productLabel(),
          ),
        ),
      );
    }

    if (tab.reportType.id == 'sales_item_list') {
      final async = ref.watch(salesItemListProvider(tab.filter));
      return async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Error: $e', style: TextStyle(color: cs.error))),
        data: (rows) => PdfPreview(
          pdfFileName: 'SalesItemList.pdf',
          initialPageFormat: PdfPageFormat.a4.landscape,
          canChangePageFormat: false,
          canDebug: false,
          allowSharing: false,
          build: (_) => _buildItemListPdf(
            rows: rows,
            filter: tab.filter,
            companyName: company?.name,
            companyAddress: company?.address,
            customerLabel: customerLabel(),
            userLabel: userLabel(),
            productLabel: productLabel(),
          ),
        ),
      );
    }

    if (tab.reportType.id == 'sales_users') {
      final async = ref.watch(salesByUserProvider(tab.filter));
      return async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Error: $e', style: TextStyle(color: cs.error))),
        data: (rows) => PdfPreview(
          pdfFileName: 'SalesByUser.pdf',
          initialPageFormat: PdfPageFormat.a4.landscape,
          canChangePageFormat: false,
          canDebug: false,
          allowSharing: false,
          build: (_) => _buildUsersPdf(
            rows: rows,
            filter: tab.filter,
            companyName: company?.name,
            companyAddress: company?.address,
            customerLabel: customerLabel(),
            userLabel: userLabel(),
            productLabel: productLabel(),
          ),
        ),
      );
    }

    return Center(
      child: Text('This report is coming soon.',
          style: TextStyle(color: cs.onSurfaceVariant)),
    );
  }
}

// ─── PDF builder functions ────────────────────────────────────────────────────

Future<Uint8List> _buildProductsPdf({
  required List<SalesByProductRow> rows,
  required ReportFilter filter,
  String? companyName,
  String? companyAddress,
  required String customerLabel,
  required String userLabel,
  required String productLabel,
}) async {
  final doc = pw.Document();
  final fmt = NumberFormat('#,##0.00');
  final dateFmt = DateFormat('dd/MM/yyyy');

  final regular = await PdfGoogleFonts.notoSansRegular();
  final bold = await PdfGoogleFonts.notoSansBold();
  final theme = pw.ThemeData.withFont(base: regular, bold: bold);

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4.landscape,
    theme: theme,
    build: (ctx) => [
      pw.Text('SALES BY PRODUCT',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8),
      _pdfHeader(dateFmt, filter, companyName, companyAddress,
          customerLabel, userLabel, productLabel),
      pw.SizedBox(height: 12),
      pw.TableHelper.fromTextArray(
        headers: ['Code', 'Product', 'Quantity', 'UOM', 'Total before tax', 'Total'],
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        cellAlignments: {
          2: pw.Alignment.centerRight,
          4: pw.Alignment.centerRight,
          5: pw.Alignment.centerRight,
        },
        data: [
          ...rows.map((r) => [
                r.code ?? '',
                r.product,
                fmt.format(r.quantity),
                r.uom,
                fmt.format(r.totalBeforeTax),
                fmt.format(r.total),
              ]),
          [
            '', 'Total',
            fmt.format(rows.fold(0.0, (s, r) => s + r.quantity)),
            '',
            fmt.format(rows.fold(0.0, (s, r) => s + r.totalBeforeTax)),
            fmt.format(rows.fold(0.0, (s, r) => s + r.total)),
          ],
        ],
        columnWidths: const {
          0: pw.FixedColumnWidth(60),
          1: pw.FlexColumnWidth(3),
          2: pw.FixedColumnWidth(70),
          3: pw.FixedColumnWidth(50),
          4: pw.FixedColumnWidth(90),
          5: pw.FixedColumnWidth(90),
        },
      ),
    ],
  ));

  return doc.save();
}

Future<Uint8List> _buildProductGroupsPdf({
  required List<SalesByProductGroupRow> rows,
  required ReportFilter filter,
  String? companyName,
  String? companyAddress,
  required String customerLabel,
  required String userLabel,
  required String productLabel,
}) async {
  final doc = pw.Document();
  final fmt = NumberFormat('#,##0.00');
  final dateFmt = DateFormat('dd/MM/yyyy');

  final regular = await PdfGoogleFonts.notoSansRegular();
  final bold = await PdfGoogleFonts.notoSansBold();
  final theme = pw.ThemeData.withFont(base: regular, bold: bold);

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4.landscape,
    theme: theme,
    build: (ctx) => [
      pw.Text('SALES BY PRODUCT GROUPS',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8),
      _pdfHeader(dateFmt, filter, companyName, companyAddress,
          customerLabel, userLabel, productLabel),
      pw.SizedBox(height: 12),
      pw.TableHelper.fromTextArray(
        headers: ['Product group', 'Quantity', 'Total before tax', 'Total'],
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        cellAlignments: {
          1: pw.Alignment.centerRight,
          2: pw.Alignment.centerRight,
          3: pw.Alignment.centerRight,
        },
        data: [
          ...rows.map((r) => [
                r.productGroup,
                fmt.format(r.quantity),
                fmt.format(r.totalBeforeTax),
                fmt.format(r.total),
              ]),
          [
            'Total',
            fmt.format(rows.fold(0.0, (s, r) => s + r.quantity)),
            fmt.format(rows.fold(0.0, (s, r) => s + r.totalBeforeTax)),
            fmt.format(rows.fold(0.0, (s, r) => s + r.total)),
          ],
        ],
        columnWidths: const {
          0: pw.FlexColumnWidth(3),
          1: pw.FixedColumnWidth(80),
          2: pw.FixedColumnWidth(100),
          3: pw.FixedColumnWidth(100),
        },
      ),
    ],
  ));

  return doc.save();
}

Future<Uint8List> _buildTaxPdf({
  required List<SalesByTaxRow> rows,
  required ReportFilter filter,
  String? companyName,
  String? companyAddress,
  required String customerLabel,
  required String userLabel,
  required String productLabel,
}) async {
  final doc = pw.Document();
  final fmt = NumberFormat('#,##0.00');
  final dateFmt = DateFormat('dd/MM/yyyy');

  final regular = await PdfGoogleFonts.notoSansRegular();
  final bold = await PdfGoogleFonts.notoSansBold();
  final theme = pw.ThemeData.withFont(base: regular, bold: bold);

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4.landscape,
    theme: theme,
    build: (ctx) => [
      pw.Text('SALES TAX',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8),
      _pdfHeader(dateFmt, filter, companyName, companyAddress,
          customerLabel, userLabel, productLabel),
      pw.SizedBox(height: 12),
      pw.TableHelper.fromTextArray(
        headers: ['Tax name', 'Total before tax', 'Tax', 'Total'],
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        cellAlignments: {
          1: pw.Alignment.centerRight,
          2: pw.Alignment.centerRight,
          3: pw.Alignment.centerRight,
        },
        data: [
          ...rows.map((r) => [
                r.taxName,
                fmt.format(r.totalBeforeTax),
                fmt.format(r.taxAmount),
                fmt.format(r.total),
              ]),
          [
            'Total',
            fmt.format(rows.fold(0.0, (s, r) => s + r.totalBeforeTax)),
            fmt.format(rows.fold(0.0, (s, r) => s + r.taxAmount)),
            fmt.format(rows.fold(0.0, (s, r) => s + r.total)),
          ],
        ],
        columnWidths: const {
          0: pw.FlexColumnWidth(3),
          1: pw.FixedColumnWidth(100),
          2: pw.FixedColumnWidth(80),
          3: pw.FixedColumnWidth(100),
        },
      ),
    ],
  ));

  return doc.save();
}

Future<Uint8List> _buildCustomersPdf({
  required List<SalesByCustomerRow> rows,
  required ReportFilter filter,
  String? companyName,
  String? companyAddress,
  required String customerLabel,
  required String userLabel,
  required String productLabel,
}) async {
  final doc = pw.Document();
  final fmt = NumberFormat('#,##0.00');
  final dateFmt = DateFormat('dd/MM/yyyy');

  final regular = await PdfGoogleFonts.notoSansRegular();
  final bold = await PdfGoogleFonts.notoSansBold();
  final theme = pw.ThemeData.withFont(base: regular, bold: bold);

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4.landscape,
    theme: theme,
    build: (ctx) => [
      pw.Text('SALES BY CUSTOMER',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8),
      _pdfHeader(dateFmt, filter, companyName, companyAddress,
          customerLabel, userLabel, productLabel),
      pw.SizedBox(height: 12),
      pw.TableHelper.fromTextArray(
        headers: ['Customer', 'Total before tax', 'Total'],
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        cellAlignments: {
          1: pw.Alignment.centerRight,
          2: pw.Alignment.centerRight,
        },
        data: [
          ...rows.map((r) => [
                r.customer,
                fmt.format(r.totalBeforeTax),
                fmt.format(r.total),
              ]),
          [
            'Total',
            fmt.format(rows.fold(0.0, (s, r) => s + r.totalBeforeTax)),
            fmt.format(rows.fold(0.0, (s, r) => s + r.total)),
          ],
        ],
        columnWidths: const {
          0: pw.FlexColumnWidth(3),
          1: pw.FixedColumnWidth(100),
          2: pw.FixedColumnWidth(100),
        },
      ),
    ],
  ));

  return doc.save();
}

Future<Uint8List> _buildPaymentTypesByCustomerPdf({
  required List<PaymentTypesByCustomerRow> rows,
  required ReportFilter filter,
  String? companyName,
  String? companyAddress,
  required String customerLabel,
  required String userLabel,
  required String productLabel,
}) async {
  final doc = pw.Document();
  final fmt = NumberFormat('#,##0.00');
  final dateFmt = DateFormat('dd/MM/yyyy');

  final regular = await PdfGoogleFonts.notoSansRegular();
  final bold = await PdfGoogleFonts.notoSansBold();
  final theme = pw.ThemeData.withFont(base: regular, bold: bold);

  final paymentTypes = rows.map((r) => r.paymentTypeName).toSet().toList()..sort();
  final customers = rows.map((r) => r.customerName).toSet().toList()..sort();
  final pivot = <String, Map<String, double>>{};
  for (final r in rows) {
    pivot.putIfAbsent(r.customerName, () => {});
    pivot[r.customerName]![r.paymentTypeName] =
        (pivot[r.customerName]![r.paymentTypeName] ?? 0) + r.amount;
  }

  final colWidths = <int, pw.FixedColumnWidth>{
    0: const pw.FixedColumnWidth(80),
  };
  for (var i = 1; i <= paymentTypes.length; i++) {
    colWidths[i] = const pw.FixedColumnWidth(80);
  }
  colWidths[paymentTypes.length + 1] = const pw.FixedColumnWidth(80);

  final grandAmounts = paymentTypes
      .map((pt) => customers.fold(0.0, (s, c) => s + (pivot[c]?[pt] ?? 0.0)))
      .toList();
  final grandTotal = rows.fold(0.0, (s, r) => s + r.amount);

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4.landscape,
    theme: theme,
    build: (ctx) => [
      pw.Text('PAYMENT TYPES BY CUSTOMERS',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8),
      _pdfHeader(dateFmt, filter, companyName, companyAddress,
          customerLabel, userLabel, productLabel),
      pw.SizedBox(height: 12),
      pw.TableHelper.fromTextArray(
        headers: ['Customer', ...paymentTypes, 'Total'],
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        cellAlignments: {
          for (var i = 1; i <= paymentTypes.length + 1; i++)
            i: pw.Alignment.centerRight,
        },
        columnWidths: colWidths,
        data: [
          ...customers.map((c) {
            final amounts =
                paymentTypes.map((pt) => pivot[c]?[pt] ?? 0.0).toList();
            final rowTotal = amounts.fold(0.0, (s, a) => s + a);
            return [c, ...amounts.map(fmt.format), fmt.format(rowTotal)];
          }),
          ['Total', ...grandAmounts.map(fmt.format), fmt.format(grandTotal)],
        ],
      ),
    ],
  ));

  return doc.save();
}

Future<Uint8List> _buildPaymentTypesByUserPdf({
  required List<PaymentTypesByUserRow> rows,
  required ReportFilter filter,
  String? companyName,
  String? companyAddress,
  required String customerLabel,
  required String userLabel,
  required String productLabel,
}) async {
  final doc = pw.Document();
  final fmt = NumberFormat('#,##0.00');
  final dateFmt = DateFormat('dd/MM/yyyy');

  final regular = await PdfGoogleFonts.notoSansRegular();
  final bold = await PdfGoogleFonts.notoSansBold();
  final theme = pw.ThemeData.withFont(base: regular, bold: bold);

  final paymentTypes = rows.map((r) => r.paymentTypeName).toSet().toList()..sort();
  final users = rows.map((r) => r.userName).toSet().toList()..sort();
  final pivot = <String, Map<String, double>>{};
  for (final r in rows) {
    pivot.putIfAbsent(r.userName, () => {});
    pivot[r.userName]![r.paymentTypeName] =
        (pivot[r.userName]![r.paymentTypeName] ?? 0) + r.amount;
  }

  final colWidths = <int, pw.FixedColumnWidth>{
    0: const pw.FixedColumnWidth(80),
  };
  for (var i = 1; i <= paymentTypes.length; i++) {
    colWidths[i] = const pw.FixedColumnWidth(80);
  }
  colWidths[paymentTypes.length + 1] = const pw.FixedColumnWidth(80);

  final grandAmounts = paymentTypes
      .map((pt) => users.fold(0.0, (s, u) => s + (pivot[u]?[pt] ?? 0.0)))
      .toList();
  final grandTotal = rows.fold(0.0, (s, r) => s + r.amount);

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4.landscape,
    theme: theme,
    build: (ctx) => [
      pw.Text('PAYMENT TYPES BY USERS',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8),
      _pdfHeader(dateFmt, filter, companyName, companyAddress,
          customerLabel, userLabel, productLabel),
      pw.SizedBox(height: 12),
      pw.TableHelper.fromTextArray(
        headers: ['', ...paymentTypes, 'Total'],
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        cellAlignments: {
          for (var i = 1; i <= paymentTypes.length + 1; i++)
            i: pw.Alignment.centerRight,
        },
        columnWidths: colWidths,
        data: [
          ...users.map((u) {
            final amounts =
                paymentTypes.map((pt) => pivot[u]?[pt] ?? 0.0).toList();
            final rowTotal = amounts.fold(0.0, (s, a) => s + a);
            return [u, ...amounts.map(fmt.format), fmt.format(rowTotal)];
          }),
          ['Total', ...grandAmounts.map(fmt.format), fmt.format(grandTotal)],
        ],
      ),
    ],
  ));

  return doc.save();
}

Future<Uint8List> _buildPaymentTypesPdf({
  required List<SalesByPaymentTypeRow> rows,
  required ReportFilter filter,
  String? companyName,
  String? companyAddress,
  required String customerLabel,
  required String userLabel,
  required String productLabel,
}) async {
  final doc = pw.Document();
  final fmt = NumberFormat('#,##0.00');
  final dateFmt = DateFormat('dd/MM/yyyy');

  final regular = await PdfGoogleFonts.notoSansRegular();
  final bold = await PdfGoogleFonts.notoSansBold();
  final theme = pw.ThemeData.withFont(base: regular, bold: bold);

  // Pivot data
  final paymentTypes = rows.map((r) => r.paymentTypeName).toSet().toList()..sort();
  final dates = rows.map((r) => r.date).toSet().toList()..sort();
  final pivot = <DateTime, Map<String, double>>{};
  for (final r in rows) {
    pivot.putIfAbsent(r.date, () => {});
    pivot[r.date]![r.paymentTypeName] =
        (pivot[r.date]![r.paymentTypeName] ?? 0) + r.amount;
  }

  // Build dynamic column widths: Date + one per payment type + Total
  final colWidths = <int, pw.FixedColumnWidth>{
    0: const pw.FixedColumnWidth(60),
  };
  for (var i = 1; i <= paymentTypes.length; i++) {
    colWidths[i] = const pw.FixedColumnWidth(80);
  }
  colWidths[paymentTypes.length + 1] = const pw.FixedColumnWidth(80);

  // Grand totals per payment type
  final grandAmounts = paymentTypes
      .map((pt) => dates.fold(0.0, (s, d) => s + (pivot[d]?[pt] ?? 0.0)))
      .toList();
  final grandTotal = rows.fold(0.0, (s, r) => s + r.amount);

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4.landscape,
    theme: theme,
    build: (ctx) => [
      pw.Text('SALES BY PAYMENT TYPES',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8),
      _pdfHeader(dateFmt, filter, companyName, companyAddress,
          customerLabel, userLabel, productLabel),
      pw.SizedBox(height: 12),
      pw.TableHelper.fromTextArray(
        headers: ['Date', ...paymentTypes, 'Total'],
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        cellAlignments: {
          for (var i = 1; i <= paymentTypes.length + 1; i++)
            i: pw.Alignment.centerRight,
        },
        columnWidths: colWidths,
        data: [
          ...dates.map((d) {
            final amounts =
                paymentTypes.map((pt) => pivot[d]?[pt] ?? 0.0).toList();
            final rowTotal = amounts.fold(0.0, (s, a) => s + a);
            return [
              dateFmt.format(d),
              ...amounts.map(fmt.format),
              fmt.format(rowTotal),
            ];
          }),
          // Grand total row
          [
            '',
            ...grandAmounts.map(fmt.format),
            fmt.format(grandTotal),
          ],
        ],
      ),
    ],
  ));

  return doc.save();
}

Future<Uint8List> _buildItemListPdf({
  required List<SalesItemListRow> rows,
  required ReportFilter filter,
  String? companyName,
  String? companyAddress,
  required String customerLabel,
  required String userLabel,
  required String productLabel,
}) async {
  final doc = pw.Document();
  final fmt = NumberFormat('#,##0.00');
  final dateFmt = DateFormat('dd/MM/yyyy');
  final dtFmt = DateFormat('dd/MM/yyyy HH:mm:ss');

  final regular = await PdfGoogleFonts.notoSansRegular();
  final bold = await PdfGoogleFonts.notoSansBold();
  final theme = pw.ThemeData.withFont(base: regular, bold: bold);

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4.landscape,
    theme: theme,
    margin: const pw.EdgeInsets.all(20),
    build: (ctx) => [
      pw.Text('SALES ITEM LIST',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8),
      _pdfHeader(dateFmt, filter, companyName, companyAddress,
          customerLabel, userLabel, productLabel),
      pw.SizedBox(height: 12),
      pw.TableHelper.fromTextArray(
        headers: [
          'Document type', 'Date', 'Create date', 'Document number',
          'Ref. number', 'Customer code', 'Customer', 'Order number',
          'Code', 'Product', 'Quantity', 'UOM',
          'Total before tax', 'Total tax', 'Total',
        ],
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7),
        cellStyle: const pw.TextStyle(fontSize: 7),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        cellAlignments: {
          10: pw.Alignment.centerRight,
          12: pw.Alignment.centerRight,
          13: pw.Alignment.centerRight,
          14: pw.Alignment.centerRight,
        },
        data: [
          ...rows.map((r) => [
                r.documentTypeName,
                dateFmt.format(r.date),
                dtFmt.format(r.dateCreated),
                r.documentNumber,
                r.refNumber ?? '',
                r.customerCode ?? '',
                r.customerName,
                r.orderNumber ?? '',
                r.productCode ?? '',
                r.productName,
                fmt.format(r.quantity),
                r.uom,
                fmt.format(r.totalBeforeTax),
                fmt.format(r.totalTax),
                fmt.format(r.total),
              ]),
          [
            '', '', '', '', '', '', '', '', '', 'Total',
            fmt.format(rows.fold(0.0, (s, r) => s + r.quantity)),
            '',
            fmt.format(rows.fold(0.0, (s, r) => s + r.totalBeforeTax)),
            fmt.format(rows.fold(0.0, (s, r) => s + r.totalTax)),
            fmt.format(rows.fold(0.0, (s, r) => s + r.total)),
          ],
        ],
        columnWidths: const {
          0:  pw.FixedColumnWidth(40),
          1:  pw.FixedColumnWidth(42),
          2:  pw.FixedColumnWidth(68),
          3:  pw.FixedColumnWidth(68),
          4:  pw.FixedColumnWidth(38),
          5:  pw.FixedColumnWidth(45),
          6:  pw.FlexColumnWidth(1.5),
          7:  pw.FixedColumnWidth(36),
          8:  pw.FixedColumnWidth(32),
          9:  pw.FlexColumnWidth(2),
          10: pw.FixedColumnWidth(42),
          11: pw.FixedColumnWidth(26),
          12: pw.FixedColumnWidth(52),
          13: pw.FixedColumnWidth(46),
          14: pw.FixedColumnWidth(52),
        },
      ),
    ],
  ));

  return doc.save();
}

Future<Uint8List> _buildUsersPdf({
  required List<SalesByUserRow> rows,
  required ReportFilter filter,
  String? companyName,
  String? companyAddress,
  required String customerLabel,
  required String userLabel,
  required String productLabel,
}) async {
  final doc = pw.Document();
  final fmt = NumberFormat('#,##0.00');
  final dateFmt = DateFormat('dd/MM/yyyy');

  final regular = await PdfGoogleFonts.notoSansRegular();
  final bold = await PdfGoogleFonts.notoSansBold();
  final theme = pw.ThemeData.withFont(base: regular, bold: bold);

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4.landscape,
    theme: theme,
    build: (ctx) => [
      pw.Text('SALES BY USERS',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8),
      _pdfHeader(dateFmt, filter, companyName, companyAddress,
          customerLabel, userLabel, productLabel),
      pw.SizedBox(height: 12),
      pw.TableHelper.fromTextArray(
        headers: ['User', 'Total before tax', 'Total'],
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        cellAlignments: {
          1: pw.Alignment.centerRight,
          2: pw.Alignment.centerRight,
        },
        data: [
          ...rows.map((r) => [
                r.user,
                fmt.format(r.totalBeforeTax),
                fmt.format(r.total),
              ]),
          [
            'Total',
            fmt.format(rows.fold(0.0, (s, r) => s + r.totalBeforeTax)),
            fmt.format(rows.fold(0.0, (s, r) => s + r.total)),
          ],
        ],
        columnWidths: const {
          0: pw.FlexColumnWidth(3),
          1: pw.FixedColumnWidth(100),
          2: pw.FixedColumnWidth(100),
        },
      ),
    ],
  ));

  return doc.save();
}

pw.Widget _pdfHeader(
  DateFormat dateFmt,
  ReportFilter filter,
  String? companyName,
  String? companyAddress,
  String customerLabel,
  String userLabel,
  String productLabel,
) {
  final ts = const pw.TextStyle(fontSize: 9);
  final tb = pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold);

  row(String lbl, String val) => pw.Row(children: [
        pw.Text('$lbl: ', style: tb),
        pw.Text(val, style: ts),
      ]);

  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        row('Period',
            '${dateFmt.format(filter.startDate)} – ${dateFmt.format(filter.endDate)}'),
        pw.SizedBox(height: 3),
        row('Customer', customerLabel),
        pw.SizedBox(height: 3),
        row('User', userLabel),
        pw.SizedBox(height: 3),
        row('Product', productLabel),
      ]),
      pw.SizedBox(width: 48),
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        row('Company', companyName ?? ''),
        pw.SizedBox(height: 3),
        row('Address', companyAddress ?? ''),
      ]),
    ],
  );
}

// ─── Filter panel ─────────────────────────────────────────────────────────────

class _FilterPanel extends ConsumerWidget {
  final String reportId;
  final ReportFilter filter;
  final ValueChanged<ReportFilter> onFilterChanged;
  final VoidCallback onShowReport;
  final Future<void> Function() onExportCsv;

  const _FilterPanel({
    required this.reportId,
    required this.filter,
    required this.onFilterChanged,
    required this.onShowReport,
    required this.onExportCsv,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final dateFmt = DateFormat('dd/MM/yyyy');

    final customers = ref.watch(allCustomersProvider).value ?? [];
    final users = ref.watch(allUsersProvider).value ?? [];
    final warehouses = ref.watch(allWarehousesProvider).value ?? [];
    final products = ref.watch(allProductsListProvider).value ?? [];
    final groups = ref.watch(allProductGroupsProvider).value ?? [];

    return Container(
      width: 240,
      color: cs.surfaceContainerLow,
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Filter',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface)),
            const Gap(16),

            _FilterLabel('Customers & suppliers'),
            const Gap(4),
            _FilterDropdown<int?>(
              value: filter.customerId,
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...customers.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name, overflow: TextOverflow.ellipsis))),
              ],
              onChanged: (v) => onFilterChanged(filter.copyWith(customerId: v)),
            ),
            const Gap(12),

            _FilterLabel('User'),
            const Gap(4),
            _FilterDropdown<int?>(
              value: filter.userId,
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...users.map((u) {
                  final name =
                      '${u.firstName ?? ''} ${u.lastName ?? ''}'.trim();
                  return DropdownMenuItem(
                      value: u.id,
                      child: Text(
                          name.isEmpty ? u.username ?? 'User ${u.id}' : name,
                          overflow: TextOverflow.ellipsis));
                }),
              ],
              onChanged: (v) => onFilterChanged(filter.copyWith(userId: v)),
            ),
            const Gap(12),

            _FilterLabel('Cash register'),
            const Gap(4),
            _FilterDropdown<int?>(
              value: filter.warehouseId,
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...warehouses.map((w) => DropdownMenuItem(
                    value: w.id,
                    child: Text(w.name, overflow: TextOverflow.ellipsis))),
              ],
              onChanged: (v) =>
                  onFilterChanged(filter.copyWith(warehouseId: v)),
            ),
            const Gap(12),

            _FilterLabel('Product'),
            const Gap(4),
            _FilterDropdown<int?>(
              value: filter.productId,
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...products.map((p) => DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name, overflow: TextOverflow.ellipsis))),
              ],
              onChanged: (v) => onFilterChanged(filter.copyWith(productId: v)),
            ),
            const Gap(12),

            _FilterLabel('Product group'),
            const Gap(4),
            _FilterDropdown<int?>(
              value: filter.productGroupId,
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...groups.map((g) => DropdownMenuItem(
                    value: g.id,
                    child: Text(g.name, overflow: TextOverflow.ellipsis))),
              ],
              onChanged: (v) =>
                  onFilterChanged(filter.copyWith(productGroupId: v)),
            ),
            const Gap(6),

            if (reportId == 'sales_by_group')
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('Include subgroups',
                    style:
                        TextStyle(fontSize: 13, color: cs.onSurface)),
                value: filter.includeSubgroups,
                onChanged: (v) => onFilterChanged(
                    filter.copyWith(includeSubgroups: v ?? false)),
              ),

            const Gap(12),
            const Divider(),
            const Gap(8),

            _FilterLabel('Period'),
            const Gap(6),
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: dateFmt.format(filter.startDate),
                    onTap: () => _pickDate(context, true),
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('–')),
                Expanded(
                  child: _DateButton(
                    label: dateFmt.format(filter.endDate),
                    onTap: () => _pickDate(context, false),
                  ),
                ),
              ],
            ),

            const Gap(16),
            const Divider(),
            const Gap(12),

            FilledButton.icon(
              icon: const Icon(Icons.search, size: 16),
              label: const Text('Show report'),
              onPressed: onShowReport,
            ),
            const Gap(8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.grid_on_outlined, size: 14),
                    label: const Text('Excel'),
                    onPressed: onExportCsv,
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final initial = isStart ? filter.startDate : filter.endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    onFilterChanged(isStart
        ? filter.copyWith(startDate: picked)
        : filter.copyWith(endDate: picked));
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _FilterLabel extends StatelessWidget {
  final String text;
  const _FilterLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(text,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant));
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(8),
        color: cs.surface,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          isDense: true,
          items: items,
          onChanged: onChanged,
          style: TextStyle(fontSize: 13, color: cs.onSurface),
          dropdownColor: cs.surface,
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DateButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(8),
          color: cs.surface,
        ),
        child: Text(label,
            style: TextStyle(color: cs.onSurface, fontSize: 12),
            textAlign: TextAlign.center),
      ),
    );
  }
}
