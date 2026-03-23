import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'document_model.dart';
import 'customer_model.dart';
import 'customer_provider.dart';
import 'auth_provider.dart';
import 'user_model.dart';
import 'warehouse_model.dart';
import 'warehouse_provider.dart';
import 'product_model.dart';
import 'product_provider.dart';
import 'documents_screen.dart';

// --- PROVIDERS ---
final documentCategoriesProvider =
    FutureProvider.autoDispose<List<DocumentCategory>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];
  final dio = createDio();
  final response = await dio.get(
    '/DocumentCategory/GetAll', // Fixed typo from GettAll
    queryParameters: {'companyId': company.id},
  );
  return (response.data as List)
      .map((j) => DocumentCategory.fromJson(j))
      .toList();
});

final documentItemsByDocIdProvider = FutureProvider.autoDispose
    .family<List<DocumentItem>, int>((ref, documentId) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];
  final dio = createDio();
  final response = await dio.get(
    '/DocumentItems/GetByDocumentId',
    queryParameters: {
      'documentId': documentId,
      'companyId': company.id,
    },
  );
  return (response.data as List).map((j) => DocumentItem.fromJson(j)).toList();
});

// --- MAIN DIALOG ENTRY POINT ---
Future<void> showDocumentEditor(
  BuildContext context,
  WidgetRef ref, {
  Document? existingDocument,
}) async {
  await showDialog(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (_) => _DocumentEditorDialog(
      existingDocument: existingDocument,
    ),
  );
  ref.invalidate(allDocumentsProvider);
}

// --- STEP 1: SELECT DOCUMENT TYPE DIALOG ---
class _SelectDocumentTypeDialog extends ConsumerStatefulWidget {
  const _SelectDocumentTypeDialog();

  @override
  ConsumerState<_SelectDocumentTypeDialog> createState() =>
      _SelectDocumentTypeDialogState();
}

class _SelectDocumentTypeDialogState
    extends ConsumerState<_SelectDocumentTypeDialog> {
  int? _selectedCategoryId;
  DocumentType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final asyncCategories = ref.watch(documentCategoriesProvider);
    final asyncTypes = ref.watch(allDocumentTypesProvider);

    return AlertDialog(
      title: const Text("Select document type"),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 520,
        height: 380,
        child: asyncCategories.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Error: $e")),
          data: (categories) => asyncTypes.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Error: $e")),
            data: (types) {
              if (_selectedCategoryId == null && categories.isNotEmpty) {
                _selectedCategoryId = categories.first.id;
              }

              final filteredTypes = types
                  .where((t) => t.documentCategoryId == _selectedCategoryId)
                  .toList();

              return Row(
                children: [
                  Container(
                    width: 160,
                    decoration: BoxDecoration(
                      border: Border(
                          right: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: ListView(
                      children: categories.map((cat) {
                        final isSelected = _selectedCategoryId == cat.id;
                        return ListTile(
                          dense: true,
                          title: Text(cat.name),
                          selected: isSelected,
                          selectedTileColor: Colors.pink,
                          selectedColor: Colors.white,
                          onTap: () => setState(() {
                            _selectedCategoryId = cat.id;
                            _selectedType = null;
                          }),
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: filteredTypes.map((t) {
                        final isSelected = _selectedType?.id == t.id;
                        return ListTile(
                          dense: true,
                          title: Text("${t.code} - ${t.name}"),
                          selected: isSelected,
                          selectedTileColor: Colors.pink,
                          selectedColor: Colors.white,
                          onTap: () => setState(() => _selectedType = t),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text("✕  Cancel"),
        ),
        ElevatedButton(
          onPressed: _selectedType == null
              ? null
              : () => Navigator.of(context).pop(_selectedType),
          child: const Text("✓  OK"),
        ),
      ],
    );
  }
}

// --- MAIN EDITOR DIALOG ---
class _DocumentEditorDialog extends ConsumerStatefulWidget {
  final Document? existingDocument;

  const _DocumentEditorDialog({this.existingDocument});

  @override
  ConsumerState<_DocumentEditorDialog> createState() =>
      _DocumentEditorDialogState();
}

class _DocumentEditorDialogState extends ConsumerState<_DocumentEditorDialog> {
  bool _headerSaved = false;
  int? _savedDocumentId;
  Document? _savedDocument;

  DocumentType? _selectedDocType;
  int? _selectedCustomerId;
  int? _selectedUserId;
  int? _selectedWarehouseId;
  late DateTime _date;
  late DateTime _dueDate;
  late DateTime _stockDate;
  final _numberCtrl = TextEditingController();
  final _internalNoteCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _refDocCtrl = TextEditingController();
  double _discount = 0;
  int _discountType = 0;
  bool _discountApplyRule = true;
  int _serviceType = 0;

  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditing => widget.existingDocument != null;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    _dueDate = DateTime.now().add(const Duration(days: 30));
    _stockDate = DateTime.now();

    if (_isEditing) {
      final d = widget.existingDocument!;
      _savedDocumentId = d.id;
      _savedDocument = d;
      _headerSaved = true;
      _selectedCustomerId = d.customerId;
      _selectedUserId = d.userId;
      _selectedWarehouseId = d.warehouseId;
      _numberCtrl.text = d.number;
      _internalNoteCtrl.text = d.internalNote ?? '';
      _noteCtrl.text = d.note ?? '';
      _refDocCtrl.text = d.referenceDocumentNumber ?? '';
      _discount = d.discount;
      _discountType = d.discountType;
      _discountApplyRule = d.discountApplyRule;
      _serviceType = d.serviceType;
      try {
        _date = DateTime.parse(d.date);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _internalNoteCtrl.dispose();
    _noteCtrl.dispose();
    _refDocCtrl.dispose();
    super.dispose();
  }

  String _generateOrderNumber(DocumentType type) {
    final now = DateTime.now();
    final prefix = type.name
        .toUpperCase()
        .replaceAll(' ', '_')
        .substring(0, type.name.length.clamp(0, 6));
    final datePart =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    return "$prefix-$datePart";
  }

  String _isoDate(DateTime dt) => dt.toIso8601String();

  bool _isSupplierDocument() {
    if (_selectedDocType == null) return false;
    final name = _selectedDocType!.name.toLowerCase();
    return name.contains('purchase') || name.contains('stock return');
  }

  Future<void> _pickDate(BuildContext context, DateTime current,
      ValueChanged<DateTime> onPick) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) onPick(picked);
  }

  Future<void> _saveHeader() async {
    final company = ref.read(selectedCompanyProvider);
    if (company == null) return;
    if (_selectedDocType == null) {
      setState(() => _errorMessage = "Please select a document type.");
      return;
    }
    if (_selectedCustomerId == null) {
      setState(() => _errorMessage = "Please select a customer/supplier.");
      return;
    }
    if (_selectedUserId == null) {
      setState(() => _errorMessage = "Please select a user.");
      return;
    }
    if (_selectedWarehouseId == null) {
      setState(() => _errorMessage = "Please select a warehouse.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = createDio();
      final payload = {
        'number': _numberCtrl.text.trim(),
        'userId': _selectedUserId,
        'customerId': _selectedCustomerId,
        'orderNumber': _generateOrderNumber(_selectedDocType!),
        'date': _isoDate(_date),
        'stockDate': _isoDate(_stockDate),
        'dueDate': _isoDate(_dueDate),
        'total': 0,
        'isClockedOut': true,
        'documentTypeId': _selectedDocType!.id,
        'warehouseId': _selectedWarehouseId,
        'internalNote': _internalNoteCtrl.text.trim(),
        'note': _noteCtrl.text.trim(),
        'referenceDocumentNumber': _refDocCtrl.text.trim(),
        'discount': _discount,
        'discountType': _discountType,
        'paidStatus': 0,
        'discountApplyRule': _discountApplyRule,
        'serviceType': _serviceType,
      };

      final response = await dio.post(
        '/Document/Add',
        queryParameters: {'companyId': company.id},
        data: payload,
      );

      final newId = (response.data is Map<String, dynamic>)
          ? (response.data['id'] as num?)?.toInt()
          : null;

      if (newId == null || newId == 0) {
        throw Exception("Server did not return a valid Document ID.");
      }

      setState(() {
        _savedDocumentId = newId;
        _headerSaved = true;
        _isLoading = false;
      });
    } on DioException catch (e) {
      setState(() {
        _errorMessage =
            e.response?.data?.toString() ?? "Failed to save document.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenSize.width * 0.92,
          maxHeight: screenSize.height * 0.90,
          minWidth: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.blueGrey[800],
              child: Row(
                children: [
                  Icon(
                    _headerSaved ? Icons.description : Icons.add_circle_outline,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isEditing
                          ? "Edit Document — ${widget.existingDocument!.number}"
                          : _headerSaved
                              ? "New Document — Add Items"
                              : "New Document",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: _headerSaved && _savedDocumentId != null
                  ? _ItemsView(
                      documentId: _savedDocumentId!,
                      document: _savedDocument ?? widget.existingDocument!,
                      companyId: ref.read(selectedCompanyProvider)?.id ?? 0,
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _HeaderForm(
                        selectedDocType: _selectedDocType,
                        selectedCustomerId: _selectedCustomerId,
                        selectedUserId: _selectedUserId,
                        selectedWarehouseId: _selectedWarehouseId,
                        date: _date,
                        dueDate: _dueDate,
                        stockDate: _stockDate,
                        numberCtrl: _numberCtrl,
                        internalNoteCtrl: _internalNoteCtrl,
                        noteCtrl: _noteCtrl,
                        refDocCtrl: _refDocCtrl,
                        discount: _discount,
                        discountType: _discountType,
                        discountApplyRule: _discountApplyRule,
                        isSupplier: _isSupplierDocument(),
                        errorMessage: _errorMessage,
                        isLoading: _isLoading,
                        onSelectDocType: () async {
                          final result = await showDialog<DocumentType>(
                            context: context,
                            builder: (_) => const _SelectDocumentTypeDialog(),
                          );
                          if (result != null) {
                            setState(() {
                              _selectedDocType = result;
                              _selectedWarehouseId = result.warehouseId;
                              if (_numberCtrl.text.isEmpty) {
                                _numberCtrl.text = _generateOrderNumber(result);
                              }
                            });
                          }
                        },
                        onCustomerChanged: (v) =>
                            setState(() => _selectedCustomerId = v),
                        onUserChanged: (v) =>
                            setState(() => _selectedUserId = v),
                        onWarehouseChanged: (v) =>
                            setState(() => _selectedWarehouseId = v),
                        onDatePick: () => _pickDate(
                            context, _date, (d) => setState(() => _date = d)),
                        onDueDatePick: () => _pickDate(context, _dueDate,
                            (d) => setState(() => _dueDate = d)),
                        onStockDatePick: () => _pickDate(context, _stockDate,
                            (d) => setState(() => _stockDate = d)),
                        onDiscountChanged: (v) => setState(() => _discount = v),
                        onDiscountTypeChanged: (v) =>
                            setState(() => _discountType = v),
                        onDiscountApplyRuleChanged: (v) =>
                            setState(() => _discountApplyRule = v),
                        onSave: _saveHeader,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HEADER FORM ---
class _HeaderForm extends ConsumerWidget {
  final DocumentType? selectedDocType;
  final int? selectedCustomerId;
  final int? selectedUserId;
  final int? selectedWarehouseId;
  final DateTime date;
  final DateTime dueDate;
  final DateTime stockDate;
  final TextEditingController numberCtrl;
  final TextEditingController internalNoteCtrl;
  final TextEditingController noteCtrl;
  final TextEditingController refDocCtrl;
  final double discount;
  final int discountType;
  final bool discountApplyRule;
  final bool isSupplier;
  final String? errorMessage;
  final bool isLoading;
  final VoidCallback onSelectDocType;
  final ValueChanged<int?> onCustomerChanged;
  final ValueChanged<int?> onUserChanged;
  final ValueChanged<int?> onWarehouseChanged;
  final VoidCallback onDatePick;
  final VoidCallback onDueDatePick;
  final VoidCallback onStockDatePick;
  final ValueChanged<double> onDiscountChanged;
  final ValueChanged<int> onDiscountTypeChanged;
  final ValueChanged<bool> onDiscountApplyRuleChanged;
  final VoidCallback onSave;

  const _HeaderForm({
    required this.selectedDocType,
    required this.selectedCustomerId,
    required this.selectedUserId,
    required this.selectedWarehouseId,
    required this.date,
    required this.dueDate,
    required this.stockDate,
    required this.numberCtrl,
    required this.internalNoteCtrl,
    required this.noteCtrl,
    required this.refDocCtrl,
    required this.discount,
    required this.discountType,
    required this.discountApplyRule,
    required this.isSupplier,
    required this.errorMessage,
    required this.isLoading,
    required this.onSelectDocType,
    required this.onCustomerChanged,
    required this.onUserChanged,
    required this.onWarehouseChanged,
    required this.onDatePick,
    required this.onDueDatePick,
    required this.onStockDatePick,
    required this.onDiscountChanged,
    required this.onDiscountTypeChanged,
    required this.onDiscountApplyRuleChanged,
    required this.onSave,
  });

  String _fmt(DateTime dt) =>
      "${dt.day.toString().padLeft(2, '0')}-${_monthAbbr(dt.month)}-${dt.year}";

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCustomers = ref.watch(allCustomersProvider);
    final asyncUsers = ref.watch(allUsersProvider);
    final asyncWarehouses = ref.watch(allWarehousesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Document Type *",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.list_alt),
              label: Text(selectedDocType != null
                  ? "${selectedDocType!.code} - ${selectedDocType!.name}"
                  : "Select document type..."),
              onPressed: onSelectDocType,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: numberCtrl,
                decoration: const InputDecoration(
                  labelText: "Number",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _datePicker("Date", date, onDatePick, _fmt),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _datePicker("Due Date", dueDate, onDueDatePick, _fmt),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child:
                  _datePicker("Stock Date", stockDate, onStockDatePick, _fmt),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: asyncCustomers.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text("Error: $e"),
                data: (customers) {
                  final filtered = isSupplier
                      ? customers.where((c) => c.isSupplier).toList()
                      : customers.where((c) => c.isCustomer).toList();
                  final isValid = selectedCustomerId == null ||
                      filtered.any((c) => c.id == selectedCustomerId);

                  return DropdownButtonFormField<int>(
                    value: isValid ? selectedCustomerId : null,
                    decoration: InputDecoration(
                      labelText: isSupplier ? "Supplier *" : "Customer *",
                      border: const OutlineInputBorder(),
                    ),
                    items: filtered
                        .map((c) => DropdownMenuItem(
                              value: c.id,
                              child:
                                  Text(c.name, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: onCustomerChanged,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: asyncUsers.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text("Error: $e"),
                data: (users) {
                  final isValidUser = selectedUserId == null ||
                      users.any((u) => u.id == selectedUserId);
                  return DropdownButtonFormField<int>(
                    value: isValidUser ? selectedUserId : null,
                    decoration: const InputDecoration(
                      labelText: "User *",
                      border: OutlineInputBorder(),
                    ),
                    items: users
                        .map((u) => DropdownMenuItem(
                              value: u.id,
                              child: Text(u.displayName,
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: onUserChanged,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: asyncWarehouses.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text("Error: $e"),
                data: (warehouses) {
                  final isValidWH = selectedWarehouseId == null ||
                      warehouses.any((w) => w.id == selectedWarehouseId);
                  return DropdownButtonFormField<int>(
                    value: isValidWH ? selectedWarehouseId : null,
                    decoration: const InputDecoration(
                      labelText: "Warehouse *",
                      border: OutlineInputBorder(),
                    ),
                    items: warehouses
                        .map((w) => DropdownMenuItem(
                              value: w.id,
                              child:
                                  Text(w.name, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: onWarehouseChanged,
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: refDocCtrl,
                decoration: const InputDecoration(
                  labelText: "Reference Document",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: discount.toString(),
                decoration: const InputDecoration(
                  labelText: "Discount",
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) => onDiscountChanged(double.tryParse(v) ?? 0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<int>(
                value: discountType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 0, child: Text("%")),
                  DropdownMenuItem(value: 1, child: Text("Fixed")),
                ],
                onChanged: (v) => onDiscountTypeChanged(v ?? 0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Checkbox(
                    value: discountApplyRule,
                    onChanged: (v) => onDiscountApplyRuleChanged(v ?? true),
                  ),
                  const Expanded(
                    child: Text("Apply discount after tax",
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: internalNoteCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Internal Note",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: noteCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Note",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.red),
            ),
            child:
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save & Add Items"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                onPressed: onSave,
              ),
          ],
        ),
      ],
    );
  }

  Widget _datePicker(String label, DateTime value, VoidCallback onTap,
      String Function(DateTime) fmt) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today, size: 16),
        ),
        child: Text(fmt(value), overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

// --- ITEMS VIEW ---
class _ItemsView extends ConsumerStatefulWidget {
  final int documentId;
  final Document document;
  final int companyId;

  const _ItemsView({
    required this.documentId,
    required this.document,
    required this.companyId,
  });

  @override
  ConsumerState<_ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends ConsumerState<_ItemsView> {
  // Automatically recalculate and sync parent document total to backend
  Future<void> _syncDocumentTotal() async {
    try {
      final dio = createDio();
      final resp =
          await dio.get('/DocumentItems/GetByDocumentId', queryParameters: {
        'documentId': widget.documentId,
        'companyId': widget.companyId,
      });
      final itemsList =
          (resp.data as List).map((j) => DocumentItem.fromJson(j)).toList();
      final newTotal = itemsList.fold<double>(0, (s, i) => s + i.total);

      await dio.patch('/Document/Update', queryParameters: {
        'companyId': widget.companyId
      }, data: {
        'id': widget.documentId,
        'total': newTotal,
      });
      ref.invalidate(allDocumentsProvider);
    } catch (e) {
      debugPrint("Failed to sync document total: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncItems =
        ref.watch(documentItemsByDocIdProvider(widget.documentId));

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: Colors.grey[100],
          child: Row(
            children: [
              Text("Doc #: ${widget.document.number}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 24),
              Text("Type: ${widget.document.documentTypeName ?? '-'}"),
              const SizedBox(width: 24),
              Text("Customer: ${widget.document.customerName ?? '-'}"),
              const SizedBox(width: 24),
              Text("Warehouse: ${widget.document.warehouseName ?? '-'}"),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text("Add Product"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (_) => _AddItemDialog(
                      documentId: widget.documentId,
                      companyId: widget.companyId,
                    ),
                  );
                  ref.invalidate(
                      documentItemsByDocIdProvider(widget.documentId));
                  await _syncDocumentTotal();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: asyncItems.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Error loading items: $e")),
            data: (items) {
              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    "No items yet. Click 'Add Product' to start.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                );
              }

              final totalBeforeTax = items.fold<double>(
                  0, (s, i) => s + i.priceBeforeTaxAfterDiscount);
              final total = items.fold<double>(0, (s, i) => s + i.total);

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor:
                              WidgetStateProperty.all(Colors.blueGrey[50]),
                          columnSpacing: 14,
                          columns: const [
                            DataColumn(label: Text("ID"), numeric: true),
                            DataColumn(label: Text("Name")),
                            DataColumn(label: Text("Qty"), numeric: true),
                            DataColumn(
                                label: Text("Price before tax"), numeric: true),
                            DataColumn(label: Text("Price"), numeric: true),
                            DataColumn(label: Text("Discount"), numeric: true),
                            DataColumn(
                                label: Text("Total before tax"), numeric: true),
                            DataColumn(label: Text("Total"), numeric: true),
                            DataColumn(label: Text("Actions")),
                          ],
                          rows: items.map((item) {
                            return DataRow(cells: [
                              DataCell(Text(item.id.toString())),
                              DataCell(Text(item.productName ?? '-')),
                              DataCell(Text(item.quantity.toStringAsFixed(
                                  item.quantity % 1 == 0 ? 0 : 2))),
                              DataCell(
                                  Text(item.priceBeforeTax.toStringAsFixed(2))),
                              DataCell(Text(item.price.toStringAsFixed(2))),
                              DataCell(Text(
                                  "${item.discount.toStringAsFixed(0)}${item.discountType == 0 ? '%' : ''}")),
                              DataCell(Text(item.priceBeforeTaxAfterDiscount
                                  .toStringAsFixed(2))),
                              DataCell(Text(
                                item.total.toStringAsFixed(2),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )),
                              DataCell(Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blueGrey, size: 18),
                                    onPressed: () async {
                                      await showDialog(
                                        context: context,
                                        builder: (_) => _EditItemDialog(
                                          item: item,
                                          companyId: widget.companyId,
                                        ),
                                      );
                                      ref.invalidate(
                                          documentItemsByDocIdProvider(
                                              widget.documentId));
                                      await _syncDocumentTotal();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red, size: 18),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text("Delete Item"),
                                          content: Text(
                                              "Delete '${item.productName}'?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(false),
                                              child: const Text("Cancel"),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red),
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(true),
                                              child: const Text("Delete",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true && context.mounted) {
                                        await _deleteItem(
                                            context, item.id, widget.companyId);
                                        ref.invalidate(
                                            documentItemsByDocIdProvider(
                                                widget.documentId));
                                        await _syncDocumentTotal();
                                      }
                                    },
                                  ),
                                ],
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, -2))
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _totalBlock("Total before tax:",
                            totalBeforeTax.toStringAsFixed(2)),
                        const SizedBox(width: 32),
                        _totalBlock("Total:", total.toStringAsFixed(2),
                            bold: true),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _totalBlock(String label, String value, {bool bold = false}) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(width: 8),
        Text(value,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: bold ? 16 : 13)),
      ],
    );
  }

  Future<void> _deleteItem(BuildContext context, int id, int companyId) async {
    try {
      final dio = createDio();
      await dio.delete(
        '/DocumentItems/Delete',
        queryParameters: {'id': id, 'companyId': companyId},
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Item deleted"), backgroundColor: Colors.green),
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

// --- ADD ITEM DIALOG ---
class _AddItemDialog extends ConsumerStatefulWidget {
  final int documentId;
  final int companyId;

  const _AddItemDialog({
    required this.documentId,
    required this.companyId,
  });

  @override
  ConsumerState<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends ConsumerState<_AddItemDialog> {
  int? _selectedProductId;
  double? _selectedProductCost;
  double? _selectedProductPrice;
  final _qtyCtrl = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController();
  final _priceBeforeTaxCtrl = TextEditingController();
  final _discountCtrl = TextEditingController(text: '0');
  int _discountType = 0;
  bool _discountApplyRule = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _priceBeforeTaxCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedProductId == null) {
      setState(() => _errorMessage = "Please select a product.");
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = createDio();
      await dio.post(
        '/DocumentItems/Add',
        queryParameters: {'companyId': widget.companyId},
        data: {
          'documentId': widget.documentId,
          'productId': _selectedProductId,
          'quantity': double.tryParse(_qtyCtrl.text.trim()) ?? 1,
          'expectedQuantity': double.tryParse(_qtyCtrl.text.trim()) ?? 1,
          'priceBeforeTax':
              double.tryParse(_priceBeforeTaxCtrl.text.trim()) ?? 0,
          'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
          'discount': double.tryParse(_discountCtrl.text.trim()) ?? 0,
          'discountType': _discountType,
          'productCost': _selectedProductCost ?? 0,
          'discountApplyRule': _discountApplyRule,
        },
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?.toString() ?? "Failed to add item.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncProducts = ref.watch(allProductsListProvider);

    return AlertDialog(
      title: const Text("Add Product"),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            asyncProducts.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text("Error: $e"),
              data: (products) => DropdownButtonFormField<int>(
                value: _selectedProductId,
                decoration: const InputDecoration(
                  labelText: "Product *",
                  border: OutlineInputBorder(),
                ),
                items: products
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(
                            "${p.name}${p.code != null ? ' (${p.code})' : ''}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  final product = products.firstWhere((p) => p.id == v);
                  setState(() {
                    _selectedProductId = v;
                    _selectedProductCost = product.cost;
                    _selectedProductPrice = product.price;
                    _priceCtrl.text = product.price.toStringAsFixed(2);
                    _priceBeforeTaxCtrl.text = product.price.toStringAsFixed(2);
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qtyCtrl,
                    decoration: const InputDecoration(
                        labelText: "Quantity", border: OutlineInputBorder()),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _priceBeforeTaxCtrl,
                    decoration: const InputDecoration(
                        labelText: "Price before tax",
                        border: OutlineInputBorder()),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _priceCtrl,
                    decoration: const InputDecoration(
                        labelText: "Price", border: OutlineInputBorder()),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _discountCtrl,
                    decoration: const InputDecoration(
                        labelText: "Discount", border: OutlineInputBorder()),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _discountType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text("%")),
                      DropdownMenuItem(value: 1, child: Text("Fixed")),
                    ],
                    onChanged: (v) => setState(() => _discountType = v ?? 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: _discountApplyRule,
                        onChanged: (v) =>
                            setState(() => _discountApplyRule = v ?? true),
                      ),
                      const Expanded(
                          child: Text("After tax",
                              overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel")),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          )
        else
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Add"),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: _submit,
          ),
      ],
    );
  }
}

// --- EDIT ITEM DIALOG ---
class _EditItemDialog extends ConsumerStatefulWidget {
  final DocumentItem item;
  final int companyId;

  const _EditItemDialog({required this.item, required this.companyId});

  @override
  ConsumerState<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends ConsumerState<_EditItemDialog> {
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _priceBeforeTaxCtrl;
  late final TextEditingController _discountCtrl;
  late int _discountType;
  late bool _discountApplyRule;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    _qtyCtrl = TextEditingController(
        text: i.quantity % 1 == 0
            ? i.quantity.toInt().toString()
            : i.quantity.toString());
    _priceCtrl = TextEditingController(text: i.price.toStringAsFixed(2));
    _priceBeforeTaxCtrl =
        TextEditingController(text: i.priceBeforeTax.toStringAsFixed(2));
    _discountCtrl = TextEditingController(text: i.discount.toStringAsFixed(0));
    _discountType = i.discountType;
    _discountApplyRule = i.discountApplyRule;
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _priceBeforeTaxCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final dio = createDio();
      await dio.patch(
        '/DocumentItems/Update',
        queryParameters: {'companyId': widget.companyId},
        data: {
          'id': widget.item.id,
          'documentId': widget.item.documentId,
          'productId': widget.item.productId,
          'quantity':
              double.tryParse(_qtyCtrl.text.trim()) ?? widget.item.quantity,
          'expectedQuantity':
              double.tryParse(_qtyCtrl.text.trim()) ?? widget.item.quantity,
          'priceBeforeTax': double.tryParse(_priceBeforeTaxCtrl.text.trim()) ??
              widget.item.priceBeforeTax,
          'price': double.tryParse(_priceCtrl.text.trim()) ?? widget.item.price,
          'discount': double.tryParse(_discountCtrl.text.trim()) ??
              widget.item.discount,
          'discountType': _discountType,
          'productCost': widget.item.productCost,
          'discountApplyRule': _discountApplyRule,
        },
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?.toString() ?? "Update failed.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit — ${widget.item.productName ?? ''}"),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qtyCtrl,
                    decoration: const InputDecoration(
                        labelText: "Quantity", border: OutlineInputBorder()),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _priceBeforeTaxCtrl,
                    decoration: const InputDecoration(
                        labelText: "Price before tax",
                        border: OutlineInputBorder()),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _priceCtrl,
                    decoration: const InputDecoration(
                        labelText: "Price", border: OutlineInputBorder()),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _discountCtrl,
                    decoration: const InputDecoration(
                        labelText: "Discount", border: OutlineInputBorder()),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _discountType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text("%")),
                      DropdownMenuItem(value: 1, child: Text("Fixed")),
                    ],
                    onChanged: (v) => setState(() => _discountType = v ?? 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: _discountApplyRule,
                        onChanged: (v) =>
                            setState(() => _discountApplyRule = v ?? true),
                      ),
                      const Expanded(
                          child: Text("After tax",
                              overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel")),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          )
        else
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text("Update"),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: _submit,
          ),
      ],
    );
  }
}
