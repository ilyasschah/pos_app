import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'product_group_provider.dart';
import 'product_model.dart';
import 'product_group_model.dart';
import 'product_groups_screen.dart';
import 'product_provider.dart';
import 'tax_provider.dart';
import 'product_comment_model.dart';
import 'product_comment_provider.dart';
import 'customer_provider.dart';
import 'stock_control_model.dart';
import 'stock_control_provider.dart';
import 'barcode_model.dart';
import 'barcode_provider.dart';

// --- HELPER ---
String _parseApiError(dynamic e) {
  if (e is DioException && e.response?.data != null) {
    final data = e.response!.data;
    if (data is Map && data.containsKey('message'))
      return data['message'].toString();
    if (data is String && !data.contains('<html') && data.length < 150)
      return data;
  }
  return "A server error occurred. Please check your inputs.";
}

// --- MAIN SCREEN ---
class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: const Text("Inventory / Products"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Add Product"),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo, foregroundColor: Colors.white),

            // --- TWO-PHASE CREATION FLOW ---
            onPressed: () async {
              // PHASE 1: General Info
              final result = await showDialog(
                context: context,
                builder: (_) =>
                    const _ProductEditorDialog(isPostCreation: false),
              );

              ref.invalidate(productsByGroupProvider);

              if (result is Product && context.mounted) {
                showDialog(
                  context: context,
                  builder: (_) => _ProductEditorDialog(
                      existingProduct: result, isPostCreation: true),
                ).then((_) => ref.invalidate(productsByGroupProvider));
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT SIDEBAR
          Container(
            width: 280,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blueGrey[50],
                  child: const Text("CATEGORIES",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.2)),
                ),
                const Expanded(child: _GroupTreeSidebar()),
              ],
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          // RIGHT AREA
          const Expanded(child: _ProductListContent()),
        ],
      ),
    );
  }
}

// --- CUSTOM TREE SIDEBAR WIDGET ---
class _GroupTreeSidebar extends ConsumerWidget {
  const _GroupTreeSidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGroups = ref.watch(allProductGroupsProvider);

    return asyncGroups.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text("Error loading groups")),
        data: (groups) {
          final rootGroups = groups
              .where((g) => g.parentGroupId == null)
              .toList()
            ..sort((a, b) => a.rank.compareTo(b.rank));

          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.all_inbox, color: Colors.blueGrey),
                title: const Text("All Products",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                selected: ref.watch(selectedProductGroupIdProvider) == null,
                selectedTileColor: Colors.blue.withOpacity(0.15),
                onTap: () => ref
                    .read(selectedProductGroupIdProvider.notifier)
                    .state = null,
              ),
              const Divider(height: 1),
              ...rootGroups.map((g) =>
                  _TreeNode(group: g, allGroups: groups, depth: 0, ref: ref)),
            ],
          );
        });
  }
}

// --- RECURSIVE TREE NODE ---
class _TreeNode extends StatefulWidget {
  final ProductGroup group;
  final List<ProductGroup> allGroups;
  final int depth;
  final WidgetRef ref;

  const _TreeNode(
      {required this.group,
      required this.allGroups,
      required this.depth,
      required this.ref});

  @override
  State<_TreeNode> createState() => _TreeNodeState();
}

class _TreeNodeState extends State<_TreeNode> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final children = widget.allGroups
        .where((g) => g.parentGroupId == widget.group.id)
        .toList()
      ..sort((a, b) => a.rank.compareTo(b.rank));
    final hasChildren = children.isNotEmpty;
    final isSelected =
        widget.ref.watch(selectedProductGroupIdProvider) == widget.group.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => widget.ref
              .read(selectedProductGroupIdProvider.notifier)
              .state = widget.group.id,
          child: Container(
            color:
                isSelected ? Colors.blue.withOpacity(0.15) : Colors.transparent,
            padding: EdgeInsets.only(
                left: 8.0 + (widget.depth * 16.0),
                right: 8.0,
                top: 6,
                bottom: 6),
            child: Row(
              children: [
                if (hasChildren)
                  InkWell(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                          _isExpanded
                              ? Icons.arrow_drop_down
                              : Icons.arrow_right,
                          size: 22,
                          color: Colors.grey[700]),
                    ),
                  )
                else
                  const SizedBox(width: 30),
                Icon(
                    hasChildren
                        ? (_isExpanded ? Icons.folder_open : Icons.folder)
                        : Icons.folder_outlined,
                    color: widget.group.flutterColor,
                    size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(widget.group.name,
                      style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.blue[900] : Colors.black87,
                          fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded && hasChildren)
          ...children.map((c) => _TreeNode(
              group: c,
              allGroups: widget.allGroups,
              depth: widget.depth + 1,
              ref: widget.ref)),
      ],
    );
  }
}

// --- PRODUCT DATA TABLE WIDGET ---
class _ProductListContent extends ConsumerWidget {
  const _ProductListContent();

  Future<void> _deleteProduct(
      BuildContext context, WidgetRef ref, Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Product"),
        content: Text("Are you sure you want to delete '${product.name}'?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel")),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text("Delete", style: TextStyle(color: Colors.white))),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      final dio = createDio();
      await dio.delete('/Products/Delete',
          queryParameters: {'id': product.id, 'companyId': product.companyId});
      ref.invalidate(productsByGroupProvider);
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Product deleted"), backgroundColor: Colors.green));
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_parseApiError(e)), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(productsByGroupProvider);
    final groups = ref.watch(allProductGroupsProvider).value ?? [];

    return asyncProducts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: ${_parseApiError(e)}")),
        data: (products) {
          if (products.isEmpty)
            return const Center(
                child: Text("No products found.",
                    style: TextStyle(color: Colors.grey, fontSize: 18)));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.blueGrey[50]),
                dataRowMaxHeight: 65,
                columns: const [
                  DataColumn(label: Text("Image")),
                  DataColumn(label: Text("Code")),
                  DataColumn(label: Text("Name")),
                  DataColumn(label: Text("Category")),
                  DataColumn(label: Text("Price")),
                  DataColumn(label: Text("Cost")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: products.map((p) {
                  final groupName = groups
                          .where((g) => g.id == p.productGroupId)
                          .firstOrNull
                          ?.name ??
                      '-';

                  return DataRow(
                      color: WidgetStateProperty.all(
                          p.isEnabled ? Colors.transparent : Colors.grey[200]),
                      cells: [
                        DataCell(Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                            image: p.imageBytes != null
                                ? DecorationImage(
                                    image: MemoryImage(p.imageBytes!),
                                    fit: BoxFit.cover)
                                : null,
                          ),
                          child: p.imageBytes == null
                              ? const Icon(Icons.inventory_2,
                                  color: Colors.grey)
                              : null,
                        )),
                        DataCell(Text(p.code ?? '-')),
                        DataCell(Text(p.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: p.isEnabled
                                    ? null
                                    : TextDecoration.lineThrough))),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(groupName,
                              style: TextStyle(
                                  color: Colors.blue[900],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        )),
                        DataCell(Text("\$${p.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold))),
                        DataCell(Text("\$${p.cost.toStringAsFixed(2)}",
                            style: const TextStyle(color: Colors.redAccent))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.blueGrey, size: 20),
                              onPressed: () => showDialog(
                                  context: context,
                                  builder: (_) => _ProductEditorDialog(
                                      existingProduct: p)).then((_) =>
                                  ref.invalidate(productsByGroupProvider)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent, size: 20),
                              onPressed: () => _deleteProduct(context, ref, p),
                            ),
                          ],
                        )),
                      ]);
                }).toList(),
              ),
            ),
          );
        });
  }
}

// --- ADD/EDIT TABBED DIALOG ---
class _ProductEditorDialog extends ConsumerStatefulWidget {
  final Product? existingProduct;
  final bool isPostCreation; // Determines if we are in "Phase 2" of creation

  const _ProductEditorDialog(
      {this.existingProduct, this.isPostCreation = false});

  @override
  ConsumerState<_ProductEditorDialog> createState() =>
      _ProductEditorDialogState();
}

class _ProductEditorDialogState extends ConsumerState<_ProductEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _pluCtrl = TextEditingController();
  final _measurementUnitCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '');
  final _costCtrl = TextEditingController(text: '');
  final _markupCtrl = TextEditingController();
  final _rankCtrl = TextEditingController(text: '');
  final _ageRestrictionCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _newCommentCtrl = TextEditingController();
  final _newBarcodeCtrl = TextEditingController();
  // Toggles
  bool _isTaxInclusive = true;
  bool _isService = false;
  bool _isPriceChangeAllowed = false;
  bool _isUsingDefaultQuantity = true;
  bool _isEnabled = true;
  bool _isBarcodeChipActive = false;

  // State
  int? _selectedGroupId;
  String? _selectedImageBase64;
  int? _selectedTaxId;
  int? _originalTaxId;
  String _selectedHexColor = '#000000';

  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditing =>
      widget.existingProduct != null && !widget.isPostCreation;

  final List<Color> _colorPalette = [
    Colors.blueGrey,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.black,
  ];

  String _colorToHex(Color color) =>
      '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

  @override
  void initState() {
    super.initState();

    if (widget.existingProduct != null) {
      final p = widget.existingProduct!;
      _nameCtrl.text = p.name;
      _codeCtrl.text = p.code ?? '';
      _pluCtrl.text = p.plu?.toString() ?? '';
      _measurementUnitCtrl.text = p.measurementUnit ?? '';
      _priceCtrl.text = p.price.toString();
      _costCtrl.text = p.cost.toString();
      _markupCtrl.text = p.markup?.toString() ?? '';
      _rankCtrl.text = p.rank?.toString() ?? '0';
      _ageRestrictionCtrl.text = p.ageRestriction?.toString() ?? '';
      _descriptionCtrl.text = p.description ?? '';

      _isTaxInclusive = p.isTaxInclusivePrice;
      _isService = p.isService;
      _isPriceChangeAllowed = p.isPriceChangeAllowed;
      _isUsingDefaultQuantity = p.isUsingDefaultQuantity;
      _isEnabled = p.isEnabled;

      _selectedGroupId = p.productGroupId;
      _selectedImageBase64 = p.image;
      _selectedHexColor = p.color.isNotEmpty ? p.color : '#000000';

      _fetchAssignedTax(p.id);
    } else {
      _selectedGroupId = ref.read(selectedProductGroupIdProvider);
    }
  }

  Future<void> _fetchAssignedTax(int productId) async {
    final companyId = ref.read(selectedCompanyProvider)?.id;
    if (companyId == null) return;
    try {
      final dio = createDio();
      final res = await dio.get('/ProductTaxes/GetByProductId',
          queryParameters: {'productId': productId, 'companyId': companyId});
      final List taxes = res.data;
      if (taxes.isNotEmpty && mounted) {
        setState(() {
          _selectedTaxId = taxes.first['taxId'];
          _originalTaxId = _selectedTaxId;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _pluCtrl.dispose();
    _measurementUnitCtrl.dispose();
    _priceCtrl.dispose();
    _costCtrl.dispose();
    _markupCtrl.dispose();
    _rankCtrl.dispose();
    _ageRestrictionCtrl.dispose();
    _descriptionCtrl.dispose();
    _newCommentCtrl.dispose();
    _newBarcodeCtrl.dispose();

    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85);
    if (xFile != null) {
      final bytes = await xFile.readAsBytes();
      setState(() => _selectedImageBase64 = base64Encode(bytes));
    }
  }

  Future<void> _submit() async {
    final companyId = ref.read(selectedCompanyProvider)?.id;
    if (companyId == null) return;

    // SCENARIO 1: We are in "Phase 1" of creation (Only General Tab)
    if (widget.existingProduct == null && !widget.isPostCreation) {
      if (_nameCtrl.text.trim().isEmpty) {
        setState(() => _errorMessage = "Please enter a Product Name.");
        return;
      }
      if (_formKey.currentState?.validate() == false) return;

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        final dio = createDio();
        final payload = {
          'name': _nameCtrl.text.trim(),
          'productGroupId': _selectedGroupId,
          'code': _codeCtrl.text.trim().isEmpty ? null : _codeCtrl.text.trim(),
          'plu': int.tryParse(_pluCtrl.text.trim()),
          'measurementUnit': _measurementUnitCtrl.text.trim().isEmpty
              ? null
              : _measurementUnitCtrl.text.trim(),
          'price': double.tryParse(_priceCtrl.text) ?? 0,
          'cost': double.tryParse(_costCtrl.text) ?? 0,
          'markup': double.tryParse(_markupCtrl.text.trim()),
          'rank': int.tryParse(_rankCtrl.text.trim()) ?? 0,
          'ageRestriction': int.tryParse(_ageRestrictionCtrl.text.trim()),
          'description': _descriptionCtrl.text.trim().isEmpty
              ? null
              : _descriptionCtrl.text.trim(),
          'isTaxInclusivePrice': _isTaxInclusive,
          'isService': _isService,
          'isPriceChangeAllowed': _isPriceChangeAllowed,
          'isUsingDefaultQuantity': _isUsingDefaultQuantity,
          'isEnabled': _isEnabled,
          'imageBase64': _selectedImageBase64 ?? "",
          'color': _selectedHexColor == 'Transparent'
              ? '#000000'
              : _selectedHexColor,
        };

        final res = await dio.post('/Products/Add',
            queryParameters: {'companyId': companyId}, data: payload);
        final responseData = res.data['data'] ?? res.data;
        final newProduct = Product.fromJson(responseData);

        if (mounted) {
          // Send the new product back to the main screen to launch Phase 2!
          Navigator.of(context).pop(newProduct);
        }
      } catch (e) {
        setState(() {
          _errorMessage = _parseApiError(e);
          _isLoading = false;
        });
      }
      return;
    }

    // SCENARIO 2 & 3: We are in "Phase 2" of creation, OR normal Editing
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final dio = createDio();
      final savedProductId = widget.existingProduct!.id;

      // Only update the General properties if we are in normal Edit mode
      if (_isEditing) {
        if (_formKey.currentState?.validate() == false) {
          setState(() => _isLoading = false);
          return;
        }
        final payload = {
          'id': savedProductId,
          'name': _nameCtrl.text.trim(),
          'productGroupId': _selectedGroupId,
          'code': _codeCtrl.text.trim().isEmpty ? null : _codeCtrl.text.trim(),
          'plu': int.tryParse(_pluCtrl.text.trim()),
          'measurementUnit': _measurementUnitCtrl.text.trim().isEmpty
              ? null
              : _measurementUnitCtrl.text.trim(),
          'price': double.tryParse(_priceCtrl.text) ?? 0,
          'cost': double.tryParse(_costCtrl.text) ?? 0,
          'markup': double.tryParse(_markupCtrl.text.trim()),
          'rank': int.tryParse(_rankCtrl.text.trim()) ?? 0,
          'ageRestriction': int.tryParse(_ageRestrictionCtrl.text.trim()),
          'description': _descriptionCtrl.text.trim().isEmpty
              ? null
              : _descriptionCtrl.text.trim(),
          'isTaxInclusivePrice': _isTaxInclusive,
          'isService': _isService,
          'isPriceChangeAllowed': _isPriceChangeAllowed,
          'isUsingDefaultQuantity': _isUsingDefaultQuantity,
          'isEnabled': _isEnabled,
          'imageBase64': _selectedImageBase64 ?? "",
          'color': _selectedHexColor == 'Transparent'
              ? '#000000'
              : _selectedHexColor,
        };
        await dio.patch('/Products/Update',
            queryParameters: {'id': savedProductId, 'companyId': companyId},
            data: payload);
      }

      // Handle Taxes (Applies to both Edit and Phase 2 Creation)
      if (_originalTaxId != null && _originalTaxId != _selectedTaxId) {
        await dio.delete('/ProductTaxes/Delete', queryParameters: {
          'productId': savedProductId,
          'taxId': _originalTaxId,
          'companyId': companyId
        });
      }
      if (_selectedTaxId != null && _selectedTaxId != _originalTaxId) {
        await dio.post('/ProductTaxes/Add',
            queryParameters: {'companyId': companyId},
            data: {'productId': savedProductId, 'taxId': _selectedTaxId});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(widget.isPostCreation
                ? "Setup Complete!"
                : "Product updated successfully!"),
            backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = _parseApiError(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Determine Dialog Title and Button Text
    String title = "New Product";
    String buttonText = "Next: Taxes & Stock";

    if (_isEditing) {
      title = "Edit Product";
      buttonText = "Save Changes";
    } else if (widget.isPostCreation) {
      title = "Set Taxes & Inventory: ${widget.existingProduct?.name}";
      buttonText = "Finish Setup";
    }

    // 2. Build Tabs Based on Current Mode
    final List<Widget> dialogTabs = [];
    final List<Widget> dialogTabViews = [];

    // Add General Tab (If creating Phase 1, OR if normal editing)
    if (!widget.isPostCreation) {
      dialogTabs.add(const Tab(text: "General"));
      dialogTabViews.add(_buildGeneralTab());
    }

    // Add Advanced Tabs (If creating Phase 2, OR if normal editing)
    if (_isEditing || widget.isPostCreation) {
      dialogTabs.addAll([
        const Tab(text: "Taxes"),
        const Tab(text: "Stock Control"),
        const Tab(text: "Barcodes"),
        const Tab(text: "Comments"),
      ]);
      dialogTabViews.addAll([
        _buildTaxesTab(),
        _buildStockControlTab(),
        _buildBarcodesTab(),
        _buildCommentsTab(),
      ]);
    }

    return DefaultTabController(
      length: dialogTabs.length,
      child: AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: _formKey,
          child: SizedBox(
            width: 950,
            height: 650,
            child: Column(
              children: [
                TabBar(
                  labelColor: Colors.indigo,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.indigo,
                  tabs: dialogTabs,
                ),
                Expanded(child: TabBarView(children: dialogTabViews)),
                if (_errorMessage != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(_errorMessage!,
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                  )
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          if (_isLoading)
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)))
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
              onPressed: _submit,
              child: Text(buttonText),
            ),
        ],
      ),
    );
  }

  // --- SUB-WIDGETS TO KEEP THE BUILD TREE CLEAN ---

  Widget _buildGeneralTab() {
    final allGroupsAsync = ref.watch(allProductGroupsProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                                labelText: "Product Name *",
                                border: OutlineInputBorder()))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: allGroupsAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const Text("Error loading groups"),
                        data: (groups) => DropdownButtonFormField<int?>(
                          value: _selectedGroupId,
                          decoration: const InputDecoration(
                              labelText: "Category / Group",
                              border: OutlineInputBorder()),
                          items: [
                            const DropdownMenuItem(
                                value: null,
                                child: Text("None (Uncategorized)")),
                            ...groups.map((g) => DropdownMenuItem(
                                value: g.id, child: Text(g.name))),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedGroupId = v),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                            controller: _codeCtrl,
                            decoration: const InputDecoration(
                                labelText: "Product Code / SKU",
                                border: OutlineInputBorder()))),
                    const SizedBox(width: 16),
                    Expanded(
                        child: TextFormField(
                            controller: _pluCtrl,
                            decoration: const InputDecoration(
                                labelText: "PLU", border: OutlineInputBorder()),
                            keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                            controller: _measurementUnitCtrl,
                            decoration: const InputDecoration(
                                labelText: "Measurement Unit",
                                border: OutlineInputBorder(),
                                hintText: "e.g. kg, pcs"))),
                    const SizedBox(width: 16),
                    Expanded(
                        child: TextFormField(
                            controller: _ageRestrictionCtrl,
                            decoration: const InputDecoration(
                                labelText: "Age Restriction",
                                border: OutlineInputBorder(),
                                hintText: "e.g. 18"),
                            keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                            controller: _priceCtrl,
                            decoration: const InputDecoration(
                                labelText: "Selling Price *",
                                border: OutlineInputBorder(),
                                prefixText: "\$"),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true))),
                    const SizedBox(width: 16),
                    Expanded(
                        child: TextFormField(
                            controller: _costCtrl,
                            decoration: const InputDecoration(
                                labelText: "Purchase Cost",
                                border: OutlineInputBorder(),
                                prefixText: "\$"),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                            controller: _markupCtrl,
                            decoration: const InputDecoration(
                                labelText: "Margin / Markup (%)",
                                border: OutlineInputBorder(),
                                suffixText: "%"),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true))),
                    const SizedBox(width: 16),
                    Expanded(
                        child: TextFormField(
                            controller: _rankCtrl,
                            decoration: const InputDecoration(
                                labelText: "Rank (Display Order)",
                                border: OutlineInputBorder()),
                            keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _descriptionCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true)),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      SwitchListTile(
                          title: const Text("Product Price is Tax Inclusive"),
                          value: _isTaxInclusive,
                          onChanged: (v) => setState(() => _isTaxInclusive = v),
                          visualDensity: VisualDensity.compact),
                      SwitchListTile(
                          title: const Text("Is Service (Not physical)"),
                          value: _isService,
                          onChanged: (v) => setState(() => _isService = v),
                          visualDensity: VisualDensity.compact),
                      SwitchListTile(
                          title: const Text("Change Price Allowed"),
                          value: _isPriceChangeAllowed,
                          onChanged: (v) =>
                              setState(() => _isPriceChangeAllowed = v),
                          visualDensity: VisualDensity.compact),
                      SwitchListTile(
                          title: const Text("Is Enabled (Visible)"),
                          value: _isEnabled,
                          activeColor: Colors.green,
                          onChanged: (v) => setState(() => _isEnabled = v),
                          visualDensity: VisualDensity.compact),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text("Product Color Marker",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _colorPalette.map((color) {
                    final hex = _colorToHex(color);
                    final isSelected =
                        _selectedHexColor.toUpperCase() == hex.toUpperCase();
                    return InkWell(
                      onTap: () => setState(() => _selectedHexColor = hex),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 3)
                                : null,
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                    color: color.withOpacity(0.4),
                                    blurRadius: 6,
                                    spreadRadius: 1)
                            ]),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text("Product Image",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[400]!)),
                      child: _selectedImageBase64 != null &&
                              _selectedImageBase64!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                  base64Decode(_selectedImageBase64!),
                                  fit: BoxFit.cover))
                          : const Icon(Icons.image,
                              color: Colors.grey, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                            icon: const Icon(Icons.upload, size: 18),
                            label: const Text("Upload"),
                            onPressed: _pickImage),
                        if (_selectedImageBase64 != null &&
                            _selectedImageBase64!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          TextButton(
                              onPressed: () =>
                                  setState(() => _selectedImageBase64 = null),
                              child: const Text("Remove Image",
                                  style: TextStyle(color: Colors.red))),
                        ]
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxesTab() {
    final allTaxesAsync = ref.watch(allTaxesProvider);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Apply Taxes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          allTaxesAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text("Failed to load taxes"),
              data: (taxes) {
                return DropdownButtonFormField<int?>(
                  value: _selectedTaxId,
                  decoration: const InputDecoration(
                      labelText: "Primary Tax Rate",
                      border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(value: null, child: Text("No Tax")),
                    ...taxes.map((t) => DropdownMenuItem(
                        value: t.id, child: Text("${t.name} (${t.rate}%)"))),
                  ],
                  onChanged: (v) => setState(() => _selectedTaxId = v),
                );
              }),
        ],
      ),
    );
  }

  Widget _buildCommentsTab() {
    // Safety check - we know the product exists because this tab is only shown in Edit/Phase 2 mode!
    if (widget.existingProduct == null) return const SizedBox();

    final productId = widget.existingProduct!.id;
    final asyncComments = ref.watch(productCommentsProvider(productId));
    final companyId = ref.read(selectedCompanyProvider)?.id;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Product Modifiers & Comments",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text(
              "Add specific notes like 'Extra Spicy' or 'Contains Nuts'.",
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),

          // INPUT ROW
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newCommentCtrl,
                  decoration: const InputDecoration(
                    labelText: "New Modifier / Comment",
                    hintText: "e.g. No Onions",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Add"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                  ),
                  onPressed: () async {
                    if (_newCommentCtrl.text.trim().isEmpty ||
                        companyId == null) return;

                    try {
                      final dio = createDio();
                      // Instantly push to your C# API!
                      await dio.post('/ProductComments/Add', queryParameters: {
                        'companyId': companyId
                      }, data: {
                        'productId': productId,
                        'comment': _newCommentCtrl.text.trim()
                      });
                      _newCommentCtrl.clear();
                      // Tell Riverpod to instantly refresh the list below!
                      ref.invalidate(productCommentsProvider(productId));
                    } catch (e) {
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(_parseApiError(e)),
                            backgroundColor: Colors.red));
                    }
                  })
            ],
          ),

          const SizedBox(height: 32),

          // LIST OF COMMENTS
          Expanded(
            child: asyncComments.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                    child: Text("Error: ${_parseApiError(e)}",
                        style: const TextStyle(color: Colors.red))),
                data: (comments) {
                  if (comments.isEmpty)
                    return const Center(
                        child: Text("No comments added yet.",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 16)));

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final c = comments[index];
                        return ListTile(
                          leading:
                              const Icon(Icons.comment, color: Colors.blueGrey),
                          title: Text(c.comment,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            tooltip: "Delete Comment",
                            onPressed: () async {
                              if (companyId == null) return;
                              try {
                                final dio = createDio();
                                // Instantly delete from C# API!
                                await dio.delete('/ProductComments/Delete',
                                    queryParameters: {
                                      'id': c.id,
                                      'companyId': companyId
                                    });
                                ref.invalidate(
                                    productCommentsProvider(productId));
                              } catch (e) {
                                if (mounted)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(_parseApiError(e)),
                                          backgroundColor: Colors.red));
                              }
                            },
                          ),
                        );
                      },
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }

  Widget _buildBarcodesTab() {
    if (widget.existingProduct == null) return const SizedBox();

    final productId = widget.existingProduct!.id;
    final asyncBarcodes = ref.watch(barcodesByProductIdProvider(productId));
    final companyId = ref.read(selectedCompanyProvider)?.id;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Product Barcodes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text(
              "Assign multiple barcodes (e.g., individual item, box, or pallet).",
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),

          // INPUT ROW WITH GENERATOR
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _newBarcodeCtrl,
                      readOnly:
                          _isBarcodeChipActive, // Prevents keyboard popping up when chip is active
                      onSubmitted: (val) {
                        // Bonus: If they manually type a barcode and hit enter, it also turns into a chip!
                        if (val.trim().isNotEmpty) {
                          setState(() => _isBarcodeChipActive = true);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Barcode",
                        hintText:
                            _isBarcodeChipActive ? "" : "Scan or enter barcode",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.qr_code_scanner),
                        prefix: _isBarcodeChipActive
                            ? Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                        0xFFD81B60), // The pink color from your image!
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _newBarcodeCtrl.text,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _newBarcodeCtrl.clear();
                                            _isBarcodeChipActive = false;
                                          });
                                        },
                                        child: const Icon(Icons.close,
                                            color: Colors.white, size: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : null,
                      ),
                      style: TextStyle(
                        color: _isBarcodeChipActive
                            ? Colors.transparent
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        setState(() {
                          _newBarcodeCtrl.text =
                              DateTime.now().millisecondsSinceEpoch.toString();
                          _isBarcodeChipActive = true;
                        });
                      },
                      child: const Text("Generate barcode",
                          style: TextStyle(color: Colors.lightBlue)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Add"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                  ),
                  onPressed: () async {
                    if (_newBarcodeCtrl.text.trim().isEmpty ||
                        companyId == null) return;

                    try {
                      final dio = createDio();
                      await dio.post('/Barcodes/Add', queryParameters: {
                        'companyId': companyId
                      }, data: {
                        'productId': productId,
                        'value': _newBarcodeCtrl.text.trim()
                      });

                      setState(() {
                        _newBarcodeCtrl.clear();
                        _isBarcodeChipActive = false;
                      });

                      ref.invalidate(barcodesByProductIdProvider(productId));
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(_parseApiError(e)),
                            backgroundColor: Colors.red));
                      }
                    }
                  })
            ],
          ),

          const SizedBox(height: 16),

          Expanded(
            child: asyncBarcodes.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                    child: Text("Error: ${_parseApiError(e)}",
                        style: const TextStyle(color: Colors.red))),
                data: (barcodes) {
                  if (barcodes.isEmpty)
                    return const Center(
                        child: Text("No barcodes assigned yet.",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 16)));

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      itemCount: barcodes.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final b = barcodes[index];
                        return ListTile(
                          leading:
                              const Icon(Icons.qr_code, color: Colors.blueGrey),
                          title: Text(b.value,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            tooltip: "Delete Barcode",
                            onPressed: () async {
                              if (companyId == null) return;
                              try {
                                final dio = createDio();
                                await dio.delete('/Barcodes/Delete',
                                    queryParameters: {
                                      'id': b.id,
                                      'companyId': companyId
                                    });
                                ref.invalidate(
                                    barcodesByProductIdProvider(productId));
                              } catch (e) {
                                if (mounted)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(_parseApiError(e)),
                                          backgroundColor: Colors.red));
                              }
                            },
                          ),
                        );
                      },
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }

  Widget _buildStockControlTab() {
    if (widget.existingProduct == null) return const SizedBox();
    final productId = widget.existingProduct!.id;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("General Stock Settings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SwitchListTile(
              title: const Text("Track Inventory (Is Using Default Quantity)"),
              subtitle: const Text(
                  "Enable this to allow standard stock tracking for this product."),
              value: _isUsingDefaultQuantity,
              onChanged: (v) => setState(() => _isUsingDefaultQuantity = v),
            ),
          ),
          const SizedBox(height: 32),
          const Text("Advanced Stock Rules",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text(
              "Configure reorder points, low stock warnings, and preferred suppliers.",
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Expanded(
            child: _StockControlRulesEditor(productId: productId),
          ),
        ],
      ),
    );
  }
}

class _StockControlRulesEditor extends ConsumerStatefulWidget {
  final int productId;
  const _StockControlRulesEditor({required this.productId});

  @override
  ConsumerState<_StockControlRulesEditor> createState() =>
      _StockControlRulesEditorState();
}

class _StockControlRulesEditorState
    extends ConsumerState<_StockControlRulesEditor> {
  final _formKey = GlobalKey<FormState>();
  bool _isInitialized = false;
  int? _existingId;
  int? _selectedSupplierId;

  late final TextEditingController _reorderPointCtrl;
  late final TextEditingController _preferredQtyCtrl;
  late final TextEditingController _lowStockWarningQtyCtrl;

  bool _isWarningEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _reorderPointCtrl = TextEditingController(text: '0');
    _preferredQtyCtrl = TextEditingController(text: '0');
    _lowStockWarningQtyCtrl = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _reorderPointCtrl.dispose();
    _preferredQtyCtrl.dispose();
    _lowStockWarningQtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveRules(int companyId) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dio = createDio();
      final payload = {
        'reorderPoint': double.tryParse(_reorderPointCtrl.text) ?? 0,
        'preferredQuantity': double.tryParse(_preferredQtyCtrl.text) ?? 0,
        'lowStockWarningQuantity':
            double.tryParse(_lowStockWarningQtyCtrl.text) ?? 0,
        'isLowStockWarningEnabled': _isWarningEnabled,
        'customerId':
            _selectedSupplierId, // Will automatically send null if unselected!
      };

      if (_existingId != null) {
        payload['id'] = _existingId;
        await dio.patch('/StockControls/Update',
            queryParameters: {'companyId': companyId}, data: payload);
      } else {
        payload['productId'] = widget.productId;
        await dio.post('/StockControls/Add',
            queryParameters: {'companyId': companyId}, data: payload);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Stock rules saved successfully!"),
            backgroundColor: Colors.green));
        ref.invalidate(stockControlByProductIdProvider(widget.productId));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_parseApiError(e)), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyId = ref.watch(selectedCompanyProvider)?.id;
    final asyncRules =
        ref.watch(stockControlByProductIdProvider(widget.productId));
    final asyncSuppliers = ref.watch(allCustomersProvider);

    return asyncRules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text("Error: ${_parseApiError(e)}",
                style: const TextStyle(color: Colors.red))),
        data: (rules) {
          // Populate controllers once when data arrives
          if (!_isInitialized) {
            if (rules != null) {
              _existingId = rules.id;
              _selectedSupplierId = rules.customerId;
              _reorderPointCtrl.text = rules.reorderPoint.toString();
              _preferredQtyCtrl.text = rules.preferredQuantity.toString();
              _lowStockWarningQtyCtrl.text =
                  rules.lowStockWarningQuantity.toString();
              _isWarningEnabled = rules.isLowStockWarningEnabled;
            }
            _isInitialized = true;
          }

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _reorderPointCtrl,
                          decoration: const InputDecoration(
                              labelText: "Reorder Point",
                              border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _preferredQtyCtrl,
                          decoration: const InputDecoration(
                              labelText: "Preferred Order Qty",
                              border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Supplier Dropdown
                  asyncSuppliers.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text("Error loading suppliers"),
                      data: (customers) {
                        final suppliers =
                            customers.where((c) => c.isSupplier).toList();
                        // Prevent dropdown crash if saved supplier ID was deleted
                        final isValid = _selectedSupplierId == null ||
                            suppliers.any((s) => s.id == _selectedSupplierId);

                        return DropdownButtonFormField<int?>(
                          value: isValid ? _selectedSupplierId : null,
                          decoration: const InputDecoration(
                              labelText: "Preferred Supplier",
                              border: OutlineInputBorder()),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text("None")),
                            ...suppliers.map((s) => DropdownMenuItem(
                                value: s.id, child: Text(s.name))),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedSupplierId = v),
                        );
                      }),

                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8)),
                    child: SwitchListTile(
                      title: const Text("Low Stock Warning Enabled"),
                      value: _isWarningEnabled,
                      onChanged: (v) => setState(() => _isWarningEnabled = v),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isWarningEnabled)
                    TextFormField(
                      controller: _lowStockWarningQtyCtrl,
                      decoration: const InputDecoration(
                          labelText: "Warning Threshold Qty",
                          border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),

                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text("Save Stock Rules"),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white),
                            onPressed: () {
                              if (companyId != null) _saveRules(companyId);
                            },
                          ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
