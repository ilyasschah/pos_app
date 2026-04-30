import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/document/document_model.dart';
import 'package:pos_app/document/document_editor_screen.dart';
import 'package:pos_app/currency/currencies_provider.dart';

// --- PROVIDERS ---
final allDocumentsProvider = FutureProvider.autoDispose<List<Document>>((
  ref,
) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];
  final dio = createDio();
  final response = await dio.get(
    '/Document/GetAll',
    queryParameters: {'companyId': company.id},
  );
  return (response.data as List).map((j) => Document.fromJson(j)).toList();
});

final allDocumentTypesProvider = FutureProvider.autoDispose<List<DocumentType>>(
  (ref) async {
    final dio = createDio();
    final response = await dio.get('/DocumentType/GetAll');
    return (response.data as List)
        .map((j) => DocumentType.fromJson(j))
        .toList();
  },
);

// Dynamic column visibility provider
final documentVisibleColumnsProvider = StateProvider<Map<String, bool>>((ref) {
  return {
    'ID': false,
    'Number': true,
    'Doc Type': true,
    'Paid': true,
    'Customer': true,
    'Date': true,
    'Order #': true,
    'User': false,
    'Discount': false,
    'Total': true,
    'Internal Note': false,
    'Note': false,
    'Created': false,
    'Updated': false,
    'Actions': true,
  };
});

// --- SCREEN ---
class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<DocumentType> _docTypes = [];
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  int? _filterPaidStatus; // null = all

  @override
  void dispose() {
    _tabController?.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso);
      return "${dt.day.toString().padLeft(2, '0')}-"
          "${_monthAbbr(dt.month)}-${dt.year.toString().substring(2)} "
          "${dt.hour.toString().padLeft(2, '0')}:"
          "${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return iso;
    }
  }

  String _monthAbbr(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }

  Widget _paidBadge(BuildContext context, int status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (status) {
      case 1:
        return _badge("Paid", isDark ? Colors.greenAccent : Colors.green);
      case 2:
        return _badge("Partial", isDark ? Colors.orangeAccent : Colors.orange);
      case 0:
        return _badge("Unpaid", isDark ? Colors.redAccent : Colors.red);
      default:
        return _badge("N/A", Colors.grey);
    }
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  List<Document> _applyFilters(List<Document> docs) {
    var items = docs;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items
          .where(
            (d) =>
                d.number.toLowerCase().contains(q) ||
                (d.customerName?.toLowerCase().contains(q) ?? false) ||
                (d.userName?.toLowerCase().contains(q) ?? false) ||
                (d.orderNumber?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }

    if (_filterPaidStatus != null) {
      items = items.where((d) => d.paidStatus == _filterPaidStatus).toList();
    }

    return items;
  }

  void _showColumnPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final columns = ref.watch(documentVisibleColumnsProvider);
          return AlertDialog(
            title: const Text("Show/Hide Columns"),
            content: SizedBox(
              width: 300,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: columns.keys.map((col) {
                    return CheckboxListTile(
                      title: Text(col),
                      value: columns[col],
                      onChanged: (val) {
                        ref
                            .read(documentVisibleColumnsProvider.notifier)
                            .update((state) => {...state, col: val ?? false});
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncDocs = ref.watch(allDocumentsProvider);
    final asyncTypes = ref.watch(allDocumentTypesProvider);
    final company = ref.watch(selectedCompanyProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return asyncTypes.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: Center(child: Text("Error loading document types: $e")),
      ),
      data: (types) {
        if (_tabController == null ||
            _tabController!.length != types.length + 1) {
          _tabController?.dispose();
          _tabController = TabController(length: types.length + 1, vsync: this);
          _docTypes = types;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Document Explorer"),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.view_column_rounded),
                tooltip: "Columns",
                onPressed: () => _showColumnPicker(context),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: "Refresh",
                onPressed: () => ref.invalidate(allDocumentsProvider),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton.icon(
                  onPressed: company == null
                      ? null
                      : () => showDocumentEditor(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("NEW"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                const Tab(text: "All Documents"),
                ...types.map((t) => Tab(text: t.name)),
              ],
            ),
          ),
          body: asyncDocs.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Error loading documents: $e")),
            data: (allDocs) {
              if (company == null) {
                return const Center(child: Text("No company selected."));
              }
              final int companyId = company.id;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- FILTER BAR ---
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3)
                          : theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                      border: Border(
                        bottom: BorderSide(
                          color: theme.dividerColor,
                          width: 0.5,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        // Search
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _searchCtrl,
                            decoration: InputDecoration(
                              hintText: "Search by number, customer...",
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                            ),
                            onChanged: (v) => setState(() => _searchQuery = v),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Paid status filter
                        Expanded(
                          child: DropdownButtonFormField<int?>(
                            initialValue: _filterPaidStatus,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                            ),
                            hint: const Text("Status Filter"),
                            items: const [
                              DropdownMenuItem(
                                value: null,
                                child: Text("All Statuses"),
                              ),
                              DropdownMenuItem(value: 1, child: Text("Paid")),
                              DropdownMenuItem(
                                value: 2,
                                child: Text("Partial"),
                              ),
                              DropdownMenuItem(value: 0, child: Text("Unpaid")),
                            ],
                            onChanged: (v) =>
                                setState(() => _filterPaidStatus = v),
                          ),
                        ),

                        const SizedBox(width: 16),
                        // Doc count
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              "TOTAL RESULTS",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            Text(
                              _applyFilters(allDocs).length.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- TAB VIEWS ---
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // All tab
                        _DocumentTable(
                          documents: _applyFilters(allDocs),
                          companyId: companyId,
                          formatDate: _formatDate,
                          paidBadge: (status) => _paidBadge(context, status),
                          onRefresh: () => ref.invalidate(allDocumentsProvider),
                        ),
                        // Per document type tabs
                        ...types.map(
                          (t) => _DocumentTable(
                            documents: _applyFilters(
                              allDocs
                                  .where((d) => d.documentTypeId == t.id)
                                  .toList(),
                            ),
                            companyId: companyId,
                            formatDate: _formatDate,
                            paidBadge: (status) => _paidBadge(context, status),
                            onRefresh: () =>
                                ref.invalidate(allDocumentsProvider),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// --- DOCUMENT TABLE ---
class _DocumentTable extends ConsumerWidget {
  final List<Document> documents;
  final int companyId;
  final String Function(String?) formatDate;
  final Widget Function(int) paidBadge;
  final VoidCallback onRefresh;

  const _DocumentTable({
    required this.documents,
    required this.companyId,
    required this.formatDate,
    required this.paidBadge,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final columnsVisibility = ref.watch(documentVisibleColumnsProvider);
    final sym = ref.watch(currencySymbolProvider);

    if (documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 64,
              color: theme.disabledColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              "No documents matching filters.",
              style: TextStyle(color: theme.disabledColor, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                isDark
                    ? theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.2,
                      )
                    : theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.4,
                      ),
              ),
              dataRowMinHeight: 52,
              dataRowMaxHeight: 60,
              columnSpacing: 24,
              dividerThickness: 0.5,
              columns: _buildColumns(columnsVisibility, theme),
              rows: documents.map((d) {
                return DataRow(
                  cells: _buildCells(context, ref, d, columnsVisibility, theme, sym),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns(
    Map<String, bool> visibility,
    ThemeData theme,
  ) {
    final List<DataColumn> cols = [];
    if (visibility['ID'] == true) {
      cols.add(const DataColumn(label: Text("ID"), numeric: true));
    }
    if (visibility['Number'] == true) {
      cols.add(const DataColumn(label: Text("NUMBER")));
    }
    if (visibility['Doc Type'] == true) {
      cols.add(const DataColumn(label: Text("TYPE")));
    }
    if (visibility['Paid'] == true) {
      cols.add(const DataColumn(label: Text("STATUS")));
    }
    if (visibility['Customer'] == true) {
      cols.add(const DataColumn(label: Text("CUSTOMER")));
    }
    if (visibility['Date'] == true) {
      cols.add(const DataColumn(label: Text("DATE")));
    }
    if (visibility['Order #'] == true) {
      cols.add(const DataColumn(label: Text("ORDER #")));
    }
    if (visibility['User'] == true) {
      cols.add(const DataColumn(label: Text("USER")));
    }
    if (visibility['Discount'] == true) {
      cols.add(const DataColumn(label: Text("DISC"), numeric: true));
    }
    if (visibility['Total'] == true) {
      cols.add(const DataColumn(label: Text("TOTAL"), numeric: true));
    }
    if (visibility['Internal Note'] == true) {
      cols.add(const DataColumn(label: Text("INTERNAL NOTE")));
    }
    if (visibility['Note'] == true) {
      cols.add(const DataColumn(label: Text("NOTE")));
    }
    if (visibility['Created'] == true) {
      cols.add(const DataColumn(label: Text("CREATED")));
    }
    if (visibility['Updated'] == true) {
      cols.add(const DataColumn(label: Text("UPDATED")));
    }
    if (visibility['Actions'] == true) {
      cols.add(const DataColumn(label: Text("ACTIONS")));
    }
    return cols;
  }

  List<DataCell> _buildCells(
    BuildContext context,
    WidgetRef ref,
    Document d,
    Map<String, bool> visibility,
    ThemeData theme,
    String sym,
  ) {
    final List<DataCell> cells = [];
    if (visibility['ID'] == true) {
      cells.add(
        DataCell(
          Text(
            d.id.toString(),
            style: TextStyle(color: theme.disabledColor, fontSize: 12),
          ),
        ),
      );
    }
    if (visibility['Number'] == true) {
      cells.add(
        DataCell(
          Text(d.number, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }
    if (visibility['Doc Type'] == true) {
      cells.add(
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description_outlined,
                size: 16,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(d.documentTypeName ?? '-'),
            ],
          ),
        ),
      );
    }
    if (visibility['Paid'] == true) {
      cells.add(DataCell(paidBadge(d.paidStatus)));
    }
    if (visibility['Customer'] == true) {
      cells.add(DataCell(Text(d.customerName ?? '-')));
    }
    if (visibility['Date'] == true) {
      cells.add(DataCell(Text(formatDate(d.date))));
    }
    if (visibility['Order #'] == true) {
      cells.add(DataCell(Text(d.orderNumber ?? 'N/A')));
    }
    if (visibility['User'] == true) {
      cells.add(DataCell(Text(d.userName ?? '-')));
    }
    if (visibility['Discount'] == true) {
      cells.add(DataCell(Text("${d.discount.toStringAsFixed(0)}%")));
    }
    if (visibility['Total'] == true) {
      cells.add(
        DataCell(
          Text(
            "${d.total.toStringAsFixed(2)} $sym",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      );
    }
    if (visibility['Internal Note'] == true) {
      cells.add(DataCell(Text(d.internalNote ?? '-')));
    }
    if (visibility['Note'] == true) {
      cells.add(DataCell(Text(d.note ?? '-')));
    }
    if (visibility['Created'] == true) {
      cells.add(DataCell(Text(formatDate(d.dateCreated))));
    }
    if (visibility['Updated'] == true) {
      cells.add(DataCell(Text(formatDate(d.dateUpdated))));
    }
    if (visibility['Actions'] == true) {
      cells.add(
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit_rounded,
                  color: theme.colorScheme.secondary,
                  size: 20,
                ),
                tooltip: "Edit",
                onPressed: () =>
                    showDocumentEditor(context, ref, existingDocument: d),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
                tooltip: "Delete",
                onPressed: () => _confirmDelete(context, ref, d),
              ),
            ],
          ),
        ),
      );
    }
    return cells;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Document d,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Document"),
        content: Text(
          "Are you sure you want to delete document '${d.number}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await _delete(context, ref, d.id, companyId);
      onRefresh();
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    int id,
    int companyId,
  ) async {
    try {
      final dio = createDio();
      await dio.delete(
        '/Document/Delete',
        queryParameters: {'id': id, 'companyId': companyId},
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Document deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } on DioException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.response?.data?.toString() ?? "Delete failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
