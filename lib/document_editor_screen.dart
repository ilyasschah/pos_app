import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'document_model.dart';
import 'customer_provider.dart';
import 'auth_provider.dart';
import 'warehouse_provider.dart';
import 'product_provider.dart';
import 'documents_screen.dart';

// --- PROVIDERS ---
final documentCategoriesProvider =
    FutureProvider.autoDispose<List<DocumentCategory>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];
  final dio = createDio();
  final response = await dio.get('/DocumentCategory/GettAll',
      queryParameters: {'companyId': company.id});
  return (response.data as List)
      .map((j) => DocumentCategory.fromJson(j))
      .toList();
});

final documentItemsByDocIdProvider = FutureProvider.autoDispose
    .family<List<DocumentItem>, int>((ref, documentId) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];
  final dio = createDio();
  final response =
      await dio.get('/DocumentItems/GetByDocumentId', queryParameters: {
    'documentId': documentId,
    'companyId': company.id,
  });
  return (response.data as List).map((j) => DocumentItem.fromJson(j)).toList();
});

// --- ENTRY POINT ---
Future<void> showDocumentEditor(BuildContext context, WidgetRef ref,
    {Document? existingDocument}) async {
  await showDialog(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (_) => _DocumentEditorDialog(existingDocument: existingDocument),
  );
  ref.invalidate(allDocumentsProvider);
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
  Document? _savedDocument; // <-- holds the doc after POST

  int? _selectedDocTypeId;
  String? _selectedDocTypeName;
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
      _selectedDocTypeId = d.documentTypeId;
      _selectedDocTypeName = d.documentTypeName;
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
      try {
        if (d.stockDate != null && d.stockDate!.isNotEmpty) {
          _stockDate = DateTime.parse(d.stockDate!);
        }
      } catch (_) {}
      try {
        if (d.dueDate != null && d.dueDate!.isNotEmpty) {
          _dueDate = DateTime.parse(d.dueDate!);
        }
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

  String _generateOrderNumber(String docTypeName) {
    final now = DateTime.now();
    final prefix = docTypeName
        .toUpperCase()
        .replaceAll(' ', '_')
        .substring(0, docTypeName.length.clamp(0, 6));
    final yy = now.year.toString().substring(2);
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    final hh = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');
    return "$prefix-$yy$mm$dd$hh$min$ss";
  }

  String _isoDate(DateTime dt) => dt.toIso8601String().split('.')[0];

  Future<void> _syncDocumentTotal(double itemsSubtotal) async {
    if (_savedDocumentId == null) return;
    try {
      final dio = createDio();
      final companyId = ref.read(selectedCompanyProvider)?.id ?? 0;
      double finalTotal = itemsSubtotal;
      if (_discountType == 1) {
        finalTotal -= _discount;
      } else if (_discountType == 0) {
        finalTotal -= finalTotal * (_discount / 100);
      }
      if (finalTotal < 0) finalTotal = 0;
      await dio.patch('/Document/Update',
          queryParameters: {'companyId': companyId},
          data: {'id': _savedDocumentId, 'total': finalTotal});
      ref.invalidate(allDocumentsProvider);
    } catch (e) {
      debugPrint("Sync failed: $e");
    }
  }

  Future<void> _saveOrUpdateHeader() async {
    final company = ref.read(selectedCompanyProvider);
    if (company == null) return;
    if (_selectedDocTypeId == null) {
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

      if (!_headerSaved) {
        // --- CREATE (POST) ---
        final payload = {
          'number': _numberCtrl.text.trim(),
          'userId': _selectedUserId,
          'customerId': _selectedCustomerId,
          'orderNumber': _generateOrderNumber(_selectedDocTypeName ?? 'DOC'),
          'date': _isoDate(_date),
          'stockDate': _isoDate(_stockDate),
          'dueDate': _isoDate(_dueDate),
          'total': 0,
          'isClockedOut': true,
          'documentTypeId': _selectedDocTypeId,
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

        final response = await dio.post('/Document/Add',
            queryParameters: {'companyId': company.id}, data: payload);

        int? newId;
        final data = response.data;
        if (data is Map) {
          newId =
              (data['id'] as num?)?.toInt() ?? (data['Id'] as num?)?.toInt();
        } else if (data is num) {
          newId = data.toInt();
        }

        if (newId == null || newId == 0) {
          throw Exception("Invalid Document ID returned.");
        }

        // Build a Document object from form state so _ItemsView can display it
        final createdDoc = Document(
          id: newId,
          number: _numberCtrl.text.trim(),
          userId: _selectedUserId ?? 0,
          customerId: _selectedCustomerId ?? 0,
          companyId: company.id,
          documentTypeId: _selectedDocTypeId ?? 0,
          documentTypeName: _selectedDocTypeName,
          warehouseId: _selectedWarehouseId ?? 0,
          date: _isoDate(_date),
          total: 0,
          discount: _discount,
          discountType: _discountType,
          discountApplyRule: _discountApplyRule,
          internalNote: _internalNoteCtrl.text.trim(),
          note: _noteCtrl.text.trim(),
        );

        setState(() {
          _savedDocumentId = newId;
          _savedDocument = createdDoc; // <-- KEY FIX
          _headerSaved = true;
          _isLoading = false;
        });
      } else {
        // --- UPDATE (PATCH) ---
        final payload = {
          'id': _savedDocumentId,
          'number': _numberCtrl.text.trim(),
          'customerId': _selectedCustomerId,
          'date': _isoDate(_date),
          'stockDate': _isoDate(_stockDate),
          'dueDate': _isoDate(_dueDate),
          'documentTypeId': _selectedDocTypeId,
          'warehouseId': _selectedWarehouseId,
          'internalNote': _internalNoteCtrl.text.trim(),
          'note': _noteCtrl.text.trim(),
          'referenceDocumentNumber': _refDocCtrl.text.trim(),
          'discount': _discount,
          'discountType': _discountType,
          'discountApplyRule': _discountApplyRule,
        };

        await dio.patch('/Document/Update',
            queryParameters: {'companyId': company.id}, data: payload);

        ref.invalidate(documentItemsByDocIdProvider(_savedDocumentId!));

        setState(() => _isLoading = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Document updated!"),
              backgroundColor: Colors.green));
        }
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?.toString() ?? "Operation failed.";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
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
          maxWidth: screenSize.width * 0.95,
          maxHeight: screenSize.height * 0.95,
          minWidth: 800,
        ),
        child: Column(
          children: [
            // Title bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.blueGrey[800],
              child: Row(
                children: [
                  const Icon(Icons.description, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isEditing
                          ? "Edit Document — ${_numberCtrl.text}"
                          : _headerSaved
                              ? "Document — ${_numberCtrl.text} (Add Items)"
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

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Header form — always visible
                    _HeaderForm(
                      isEditing: _headerSaved,
                      selectedDocTypeName: _selectedDocTypeName,
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
                      errorMessage: _errorMessage,
                      isLoading: _isLoading,
                      onSelectDocType: () async {
                        final result = await showDialog<DocumentType>(
                          context: context,
                          builder: (_) => const _SelectDocumentTypeDialog(),
                        );
                        if (result != null) {
                          setState(() {
                            _selectedDocTypeId = result.id;
                            _selectedDocTypeName =
                                "${result.code} - ${result.name}";
                            _selectedWarehouseId = result.warehouseId;
                            if (_numberCtrl.text.isEmpty) {
                              _numberCtrl.text =
                                  _generateOrderNumber(result.name);
                            }
                          });
                        }
                      },
                      onCustomerChanged: (v) =>
                          setState(() => _selectedCustomerId = v),
                      onUserChanged: (v) => setState(() => _selectedUserId = v),
                      onWarehouseChanged: (v) =>
                          setState(() => _selectedWarehouseId = v),
                      onDatePick: () async {
                        final picked = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030));
                        if (picked != null) setState(() => _date = picked);
                      },
                      onDueDatePick: () async {
                        final picked = await showDatePicker(
                            context: context,
                            initialDate: _dueDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030));
                        if (picked != null) setState(() => _dueDate = picked);
                      },
                      onStockDatePick: () async {
                        final picked = await showDatePicker(
                            context: context,
                            initialDate: _stockDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030));
                        if (picked != null) setState(() => _stockDate = picked);
                      },
                      onDiscountChanged: (v) => setState(() => _discount = v),
                      onDiscountTypeChanged: (v) =>
                          setState(() => _discountType = v),
                      onDiscountApplyRuleChanged: (v) =>
                          setState(() => _discountApplyRule = v),
                      onSave: _saveOrUpdateHeader,
                    ),

                    // Items section — only shown after header is saved
                    if (_headerSaved &&
                        _savedDocumentId != null &&
                        _savedDocument != null) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(thickness: 2),
                      ),
                      _ItemsView(
                        documentId: _savedDocumentId!,
                        companyId: ref.read(selectedCompanyProvider)?.id ?? 0,
                        onItemsChanged: _syncDocumentTotal,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- DOCUMENT TYPE SELECTOR ---
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
                            right: BorderSide(color: Colors.grey.shade300))),
                    child: ListView(
                      children: categories
                          .map((cat) => ListTile(
                                dense: true,
                                title: Text(cat.name),
                                selected: _selectedCategoryId == cat.id,
                                selectedTileColor: Colors.pink,
                                selectedColor: Colors.white,
                                onTap: () => setState(() {
                                  _selectedCategoryId = cat.id;
                                  _selectedType = null;
                                }),
                              ))
                          .toList(),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: filteredTypes
                          .map((t) => ListTile(
                                dense: true,
                                title: Text("${t.code} - ${t.name}"),
                                selected: _selectedType?.id == t.id,
                                selectedTileColor: Colors.pink,
                                selectedColor: Colors.white,
                                onTap: () => setState(() => _selectedType = t),
                              ))
                          .toList(),
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
            child: const Text("Cancel")),
        ElevatedButton(
            onPressed: _selectedType == null
                ? null
                : () => Navigator.of(context).pop(_selectedType),
            child: const Text("OK")),
      ],
    );
  }
}

// --- HEADER FORM ---
class _HeaderForm extends ConsumerWidget {
  final bool isEditing;
  final String? selectedDocTypeName;
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
    super.key,
    required this.isEditing,
    required this.selectedDocTypeName,
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

  String _fmt(DateTime dt) => "${dt.day.toString().padLeft(2, '0')}-${[
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
      ][dt.month - 1]}-${dt.year}";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCustomers = ref.watch(allCustomersProvider);
    final asyncUsers = ref.watch(allUsersProvider);
    final asyncWarehouses = ref.watch(allWarehousesProvider);
    final isSupplier =
        selectedDocTypeName?.toLowerCase().contains('purchase') == true ||
            selectedDocTypeName?.toLowerCase().contains('return') == true;

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
              label: Text(selectedDocTypeName ?? "Select document type..."),
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
                      labelText: "Number", border: OutlineInputBorder())),
            ),
            const SizedBox(width: 12),
            Expanded(
                flex: 2, child: _datePicker("Date", date, onDatePick, _fmt)),
            const SizedBox(width: 12),
            Expanded(
                flex: 2,
                child: _datePicker("Due Date", dueDate, onDueDatePick, _fmt)),
            const SizedBox(width: 12),
            Expanded(
                flex: 2,
                child: _datePicker(
                    "Stock Date", stockDate, onStockDatePick, _fmt)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Customer / Supplier
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
                        border: const OutlineInputBorder()),
                    items: filtered
                        .map((c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: onCustomerChanged,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // User
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
                        labelText: "User *", border: OutlineInputBorder()),
                    items: users
                        .map((u) => DropdownMenuItem(
                            value: u.id, child: Text(u.displayName)))
                        .toList(),
                    onChanged: onUserChanged,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Warehouse
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
                        labelText: "Warehouse *", border: OutlineInputBorder()),
                    items: warehouses
                        .map((w) =>
                            DropdownMenuItem(value: w.id, child: Text(w.name)))
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
                      border: OutlineInputBorder())),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: discount.toString(),
                decoration: const InputDecoration(
                    labelText: "Document Discount",
                    border: OutlineInputBorder()),
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 12)),
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
              child: Row(children: [
                Checkbox(
                    value: discountApplyRule,
                    onChanged: (v) => onDiscountApplyRuleChanged(v ?? true)),
                const Text("Apply after tax"),
              ]),
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
                      border: OutlineInputBorder())),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                  controller: noteCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: "Note", border: OutlineInputBorder())),
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
                icon: Icon(isEditing ? Icons.save : Icons.arrow_forward),
                label: Text(
                    isEditing ? "Save Header Changes" : "Create & Add Items"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14)),
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
            suffixIcon: const Icon(Icons.calendar_today, size: 16)),
        child: Text(fmt(value)),
      ),
    );
  }
}

// --- ITEMS VIEW ---
class _ItemsView extends ConsumerWidget {
  final int documentId;
  final int companyId;
  final ValueChanged<double> onItemsChanged;

  const _ItemsView({
    super.key,
    required this.documentId,
    required this.companyId,
    required this.onItemsChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<List<DocumentItem>>>(
      documentItemsByDocIdProvider(documentId),
      (previous, next) {
        next.whenData((items) {
          final subtotal = items.fold<double>(0, (s, i) => s + i.total);
          onItemsChanged(subtotal);
        });
      },
    );

    final asyncItems = ref.watch(documentItemsByDocIdProvider(documentId));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Document Items",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Add Product"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink, foregroundColor: Colors.white),
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (_) => _AddItemDialog(
                        documentId: documentId, companyId: companyId));
                ref.invalidate(documentItemsByDocIdProvider(documentId));
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        asyncItems.when(
          loading: () => const CircularProgressIndicator(),
          error: (e, _) =>
              Text("Error: $e", style: const TextStyle(color: Colors.red)),
          data: (items) {
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text("No items added yet.",
                    style: TextStyle(color: Colors.grey)),
              );
            }

            final total = items.fold<double>(0, (s, i) => s + i.total);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.all(Colors.blueGrey[50]),
                    columns: const [
                      DataColumn(label: Text("Product")),
                      DataColumn(label: Text("Qty"), numeric: true),
                      DataColumn(label: Text("Price"), numeric: true),
                      DataColumn(label: Text("Item Disc."), numeric: true),
                      DataColumn(label: Text("Subtotal"), numeric: true),
                      DataColumn(label: Text("Total"), numeric: true),
                      DataColumn(label: Text("Actions")),
                    ],
                    rows: items
                        .map((item) => DataRow(cells: [
                              DataCell(Text(item.productName ?? '-')),
                              DataCell(Text(item.quantity.toStringAsFixed(
                                  item.quantity % 1 == 0 ? 0 : 2))),
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
                                                companyId: companyId));
                                        ref.invalidate(
                                            documentItemsByDocIdProvider(
                                                documentId));
                                      }),
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
                                                      Navigator.of(ctx)
                                                          .pop(false),
                                                  child: const Text("Cancel")),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.red),
                                                onPressed: () =>
                                                    Navigator.of(ctx).pop(true),
                                                child: const Text("Delete",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          final dio = createDio();
                                          await dio.delete(
                                              '/DocumentItems/Delete',
                                              queryParameters: {
                                                'id': item.id,
                                                'companyId': companyId
                                              });
                                          ref.invalidate(
                                              documentItemsByDocIdProvider(
                                                  documentId));
                                        }
                                      }),
                                ],
                              )),
                            ]))
                        .toList(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  alignment: Alignment.centerRight,
                  child: Text("Items Base Total: \$${total.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// --- ADD ITEM DIALOG ---
class _AddItemDialog extends ConsumerStatefulWidget {
  final int documentId;
  final int companyId;
  const _AddItemDialog({required this.documentId, required this.companyId});

  @override
  ConsumerState<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends ConsumerState<_AddItemDialog> {
  int? _selectedProductId;
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
      await dio.post('/DocumentItems/Add', queryParameters: {
        'companyId': widget.companyId
      }, data: {
        'documentId': widget.documentId,
        'productId': _selectedProductId,
        'quantity': double.tryParse(_qtyCtrl.text) ?? 1,
        'expectedQuantity': double.tryParse(_qtyCtrl.text) ?? 1,
        'priceBeforeTax': double.tryParse(_priceBeforeTaxCtrl.text) ?? 0,
        'price': double.tryParse(_priceCtrl.text) ?? 0,
        'discount': double.tryParse(_discountCtrl.text) ?? 0,
        'discountType': _discountType,
        'discountApplyRule': _discountApplyRule,
      });
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
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            asyncProducts.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text("Error: $e"),
              data: (products) => DropdownButtonFormField<int>(
                value: _selectedProductId,
                decoration: const InputDecoration(
                    labelText: "Product *", border: OutlineInputBorder()),
                items: products
                    .map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(
                          "${p.name}${p.code != null ? ' (${p.code})' : ''}",
                          overflow: TextOverflow.ellipsis,
                        )))
                    .toList(),
                onChanged: (v) {
                  final p = products.firstWhere((prod) => prod.id == v);
                  setState(() {
                    _selectedProductId = v;
                    _priceCtrl.text = p.price.toStringAsFixed(2);
                    _priceBeforeTaxCtrl.text = p.price.toStringAsFixed(2);
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: TextFormField(
                      controller: _qtyCtrl,
                      decoration: const InputDecoration(
                          labelText: "Quantity",
                          border: OutlineInputBorder()))),
              const SizedBox(width: 12),
              Expanded(
                  child: TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(
                          labelText: "Price", border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: TextFormField(
                      controller: _discountCtrl,
                      decoration: const InputDecoration(
                          labelText: "Item Discount",
                          border: OutlineInputBorder()))),
              const SizedBox(width: 12),
              Expanded(
                  child: DropdownButtonFormField<int>(
                value: _discountType,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 0, child: Text("%")),
                  DropdownMenuItem(value: 1, child: Text("Fixed")),
                ],
                onChanged: (v) => setState(() => _discountType = v ?? 0),
              )),
            ]),
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
  late final TextEditingController _discountCtrl;
  late int _discountType;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(text: widget.item.quantity.toString());
    _priceCtrl = TextEditingController(text: widget.item.price.toString());
    _discountCtrl =
        TextEditingController(text: widget.item.discount.toString());
    _discountType = widget.item.discountType;
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
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
      await dio.patch('/DocumentItems/Update', queryParameters: {
        'companyId': widget.companyId
      }, data: {
        'id': widget.item.id,
        'documentId': widget.item.documentId,
        'productId': widget.item.productId,
        'quantity': double.tryParse(_qtyCtrl.text) ?? widget.item.quantity,
        'expectedQuantity':
            double.tryParse(_qtyCtrl.text) ?? widget.item.quantity,
        'priceBeforeTax': widget.item.priceBeforeTax,
        'price': double.tryParse(_priceCtrl.text) ?? widget.item.price,
        'discount': double.tryParse(_discountCtrl.text) ?? widget.item.discount,
        'discountType': _discountType,
        'productCost': widget.item.productCost,
        'discountApplyRule': widget.item.discountApplyRule,
      });
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
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Expanded(
                  child: TextFormField(
                      controller: _qtyCtrl,
                      decoration: const InputDecoration(
                          labelText: "Quantity",
                          border: OutlineInputBorder()))),
              const SizedBox(width: 12),
              Expanded(
                  child: TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(
                          labelText: "Price", border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: TextFormField(
                      controller: _discountCtrl,
                      decoration: const InputDecoration(
                          labelText: "Discount",
                          border: OutlineInputBorder()))),
              const SizedBox(width: 12),
              Expanded(
                  child: DropdownButtonFormField<int>(
                value: _discountType,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 0, child: Text("%")),
                  DropdownMenuItem(value: 1, child: Text("Fixed")),
                ],
                onChanged: (v) => setState(() => _discountType = v ?? 0),
              )),
            ]),
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
