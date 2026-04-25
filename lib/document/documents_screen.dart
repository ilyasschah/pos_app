import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/document/document_model.dart';
import 'package:pos_app/document/document_editor_screen.dart';

// --- PROVIDERS ---
final allDocumentsProvider =
    FutureProvider.autoDispose<List<Document>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];
  final dio = createDio();
  final response = await dio.get(
    '/Document/GetAll',
    queryParameters: {'companyId': company.id},
  );
  return (response.data as List).map((j) => Document.fromJson(j)).toList();
});

final allDocumentTypesProvider =
    FutureProvider.autoDispose<List<DocumentType>>((ref) async {
  final dio = createDio();
  final response = await dio.get('/DocumentType/GetAll');
  return (response.data as List).map((j) => DocumentType.fromJson(j)).toList();
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
  // String? _filterCustomer;
  // String? _filterUser;
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
      'Dec'
    ];
    return months[m - 1];
  }

  Widget _paidBadge(int status) {
    switch (status) {
      case 1:
        return _badge("Paid", Colors.green);
      case 2:
        return _badge("Partial", Colors.orange);
      default:
        return _badge("N/A", Colors.grey);
    }
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  List<Document> _applyFilters(List<Document> docs) {
    var items = docs;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items
          .where((d) =>
              d.number.toLowerCase().contains(q) ||
              (d.customerName?.toLowerCase().contains(q) ?? false) ||
              (d.userName?.toLowerCase().contains(q) ?? false) ||
              (d.orderNumber?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    if (_filterPaidStatus != null) {
      items = items.where((d) => d.paidStatus == _filterPaidStatus).toList();
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final asyncDocs = ref.watch(allDocumentsProvider);
    final asyncTypes = ref.watch(allDocumentTypesProvider);
    final company = ref.watch(selectedCompanyProvider);

    return asyncTypes.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
          body: Center(child: Text("Error loading document types: $e"))),
      data: (types) {
        // Build tab controller when types load
        if (_tabController == null ||
            _tabController!.length != types.length + 1) {
          _tabController?.dispose();
          _tabController = TabController(length: types.length + 1, vsync: this);
          _docTypes = types;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Documents"),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: "Refresh",
                onPressed: () => ref.invalidate(allDocumentsProvider),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: "New Document",
                onPressed: company == null
                    ? null
                    : () => showDocumentEditor(context, ref),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: [
                const Tab(text: "All"),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- FILTER BAR ---
                  Container(
                    color: Colors.grey[100],
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        // Search
                        SizedBox(
                          width: 240,
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: InputDecoration(
                              hintText: "Number, customer, user...",
                              prefixIcon: const Icon(Icons.search, size: 18),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 16),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              isDense: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                            ),
                            onChanged: (v) => setState(() => _searchQuery = v),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Paid status filter
                        DropdownButton<int?>(
                          value: _filterPaidStatus,
                          hint: const Text("All transactions"),
                          items: const [
                            DropdownMenuItem(
                                value: null, child: Text("All transactions")),
                            DropdownMenuItem(value: 1, child: Text("Paid")),
                            DropdownMenuItem(value: 2, child: Text("Partial")),
                            DropdownMenuItem(value: 0, child: Text("Unpaid")),
                          ],
                          onChanged: (v) =>
                              setState(() => _filterPaidStatus = v),
                        ),

                        const Spacer(),
                        // Doc count
                        asyncDocs.when(
                          data: (docs) {
                            final tabIndex = _tabController?.index ?? 0;
                            final filtered = tabIndex == 0
                                ? _applyFilters(docs)
                                : _applyFilters(docs
                                    .where((d) =>
                                        d.documentTypeId ==
                                        _docTypes[tabIndex - 1].id)
                                    .toList());
                            return Text(
                              "Documents (${filtered.length})",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey),
                            );
                          },
                          loading: () => const SizedBox(),
                          error: (_, __) => const SizedBox(),
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
                          paidBadge: _paidBadge,
                          onRefresh: () => ref.invalidate(allDocumentsProvider),
                        ),
                        // Per document type tabs
                        ...types.map((t) => _DocumentTable(
                              documents: _applyFilters(allDocs
                                  .where((d) => d.documentTypeId == t.id)
                                  .toList()),
                              companyId: companyId,
                              formatDate: _formatDate,
                              paidBadge: _paidBadge,
                              onRefresh: () =>
                                  ref.invalidate(allDocumentsProvider),
                            )),
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

// class _ExpandableDocumentRow extends ConsumerWidget {
//   final Document document;

//   const _ExpandableDocumentRow({super.key, required this.document});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // 1. Watch the items for this specific document
//     final itemsAsync = ref.watch(documentItemsByDocIdProvider(document.id));

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       child: ExpansionTile(
//         title: Text(document.number,
//             style: const TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Text(
//           "${document.customerName ?? 'Unknown'} • ${document.documentTypeName ?? ''}",
//           style: TextStyle(color: Colors.grey[600]),
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // --- 2. DYNAMIC FRONTEND TOTAL CALCULATION ---
//             itemsAsync.when(
//               data: (items) {
//                 // Sum up the items
//                 double computedTotal =
//                     items.fold<double>(0, (sum, item) => sum + item.total);

//                 // Apply the parent document's discount
//                 if (document.discountType == 1) {
//                   // Fixed amount
//                   computedTotal -= document.discount;
//                 } else if (document.discountType == 0) {
//                   // Percentage
//                   computedTotal -= computedTotal * (document.discount / 100);
//                 }

//                 if (computedTotal < 0) computedTotal = 0;

//                 return Text(
//                   "\$${computedTotal.toStringAsFixed(2)}",
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: Colors.green),
//                 );
//               },
//               loading: () => const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(strokeWidth: 2)),
//               // Fallback to the backend total if there's an error fetching items
//               error: (e, _) => Text(
//                 "\$${document.total.toStringAsFixed(2)}",
//                 style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.red),
//               ),
//             ),
//             // ---------------------------------------------
//             const SizedBox(width: 16),
//             IconButton(
//               icon: const Icon(Icons.edit, color: Colors.blueGrey),
//               onPressed: () =>
//                   showDocumentEditor(context, ref, existingDocument: document),
//             ),
//             IconButton(
//               icon: const Icon(Icons.delete, color: Colors.redAccent),
//               onPressed: () {
//                 // Your delete logic
//               },
//             ),
//           ],
//         ),
//         children: [
//           Container(
//             width: double.infinity,
//             color: Colors.grey[50],
//             padding: const EdgeInsets.all(16),
//             child: itemsAsync.when(
//               loading: () => const Center(
//                   child: Padding(
//                       padding: EdgeInsets.all(16),
//                       child: CircularProgressIndicator())),
//               error: (e, _) => Text("Failed to load items: $e",
//                   style: const TextStyle(color: Colors.red)),
//               data: (items) {
//                 if (items.isEmpty) {
//                   return const Text("No products inside this document.",
//                       style: TextStyle(
//                           color: Colors.grey, fontStyle: FontStyle.italic));
//                 }
//                 return DataTable(
//                   headingRowHeight: 32,
//                   dataRowMinHeight: 40,
//                   dataRowMaxHeight: 40,
//                   columns: const [
//                     DataColumn(
//                         label: Text("Product",
//                             style: TextStyle(fontWeight: FontWeight.bold))),
//                     DataColumn(
//                         label: Text("Qty",
//                             style: TextStyle(fontWeight: FontWeight.bold))),
//                     DataColumn(
//                         label: Text("Price",
//                             style: TextStyle(fontWeight: FontWeight.bold))),
//                     DataColumn(
//                         label: Text("Subtotal",
//                             style: TextStyle(fontWeight: FontWeight.bold))),
//                   ],
//                   rows: items
//                       .map((i) => DataRow(cells: [
//                             DataCell(Text(i.productName ?? '-')),
//                             DataCell(Text(i.quantity
//                                 .toStringAsFixed(i.quantity % 1 == 0 ? 0 : 2))),
//                             DataCell(Text("\$${i.price.toStringAsFixed(2)}")),
//                             DataCell(Text("\$${i.total.toStringAsFixed(2)}",
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold))),
//                           ]))
//                       .toList(),
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// --- DOCUMENT TABLE ---
class _DocumentTable extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return const Center(
        child: Text("No documents found.",
            style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.blueGrey[50]),
          columnSpacing: 16,
          columns: const [
            DataColumn(label: Text("ID"), numeric: true),
            DataColumn(label: Text("Number")),
            DataColumn(label: Text("Doc Type")),
            DataColumn(label: Text("Paid")),
            DataColumn(label: Text("Customer")),
            DataColumn(label: Text("Date")),
            DataColumn(label: Text("Order #")),
            DataColumn(label: Text("User")),
            DataColumn(label: Text("Discount"), numeric: true),
            DataColumn(label: Text("Total"), numeric: true),
            DataColumn(label: Text("Internal Note")),
            DataColumn(label: Text("Note")),
            DataColumn(label: Text("Created")),
            DataColumn(label: Text("Updated")),
            DataColumn(label: Text("Actions")),
          ],
          rows: documents.map((d) {
            return DataRow(cells: [
              DataCell(Text(d.id.toString())),
              DataCell(Text(d.number)),
              DataCell(Text(d.documentTypeName ?? '-')),
              DataCell(paidBadge(d.paidStatus)),
              DataCell(Text(d.customerName ?? '-')),
              DataCell(Text(formatDate(d.date))),
              DataCell(Text(d.orderNumber ?? 'N/A')),
              DataCell(Text(d.userName ?? '-')),
              DataCell(Text("${d.discount.toStringAsFixed(0)}%")),
              DataCell(Text(
                d.total.toStringAsFixed(2),
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
              DataCell(
                d.internalNote != null && d.internalNote!.isNotEmpty
                    ? Tooltip(
                        message: d.internalNote!,
                        child: Text(
                          d.internalNote!.length > 20
                              ? '${d.internalNote!.substring(0, 20)}...'
                              : d.internalNote!,
                        ),
                      )
                    : const Text('-'),
              ),
              DataCell(
                d.note != null && d.note!.isNotEmpty
                    ? Tooltip(
                        message: d.note!,
                        child: Text(
                          d.note!.length > 20
                              ? '${d.note!.substring(0, 20)}...'
                              : d.note!,
                        ),
                      )
                    : const Text('-'),
              ),
              DataCell(Text(formatDate(d.dateCreated))),
              DataCell(Text(formatDate(d.dateUpdated))),
              DataCell(
                Consumer(
                  builder: (context, ref, _) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.blueGrey, size: 18),
                        tooltip: "Edit",
                        onPressed: () => showDocumentEditor(
                          context,
                          ref,
                          existingDocument: d,
                        ),
                      ),
                      // Delete
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 18),
                        tooltip: "Delete",
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Delete Document"),
                              content: Text("Delete document '${d.number}'?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text("Delete",
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            await _delete(context, ref, d.id, companyId);
                            onRefresh();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, int id, int companyId) async {
    try {
      final dio = createDio();
      await dio.delete(
        '/Document/Delete',
        queryParameters: {'id': id, 'companyId': companyId},
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Document deleted"), backgroundColor: Colors.green),
      );
    } on DioException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.response?.data?.toString() ?? "Delete failed"),
        backgroundColor: Colors.red,
      ));
    }
  }
}
