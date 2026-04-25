import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/stock/warehouse_provider.dart';
import 'package:pos_app/stock/stock_model.dart';
import 'package:pos_app/product/product_provider.dart';

// --- PROVIDER ---
final allStocksProvider =
    FutureProvider.autoDispose<List<StockItem>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];
  final dio = createDio();

  // 1. Fetch all stocks
  final stockResponse = await dio.get(
    '/Stocks/GetAllStocks',
    queryParameters: {'companyId': company.id},
  );
  final stocks =
      (stockResponse.data as List).map((j) => StockItem.fromJson(j)).toList();

  // 2. Fetch product details for each unique productId
  final uniqueProductIds = stocks.map((s) => s.productId).toSet().toList();

  final Map<int, Map<String, dynamic>> productDetails = {};
  await Future.wait(uniqueProductIds.map((pid) async {
    try {
      final resp = await dio.get(
        '/Products/GetById',
        queryParameters: {'id': pid, 'companyId': company.id},
      );
      productDetails[pid] = resp.data as Map<String, dynamic>;
    } catch (_) {}
  }));

  // 3. Enrich stocks with product cost/price/code
  return stocks.map((s) {
    final detail = productDetails[s.productId];
    return s.copyWith(
      cost: (detail?['cost'] as num?)?.toDouble(),
      price: (detail?['price'] as num?)?.toDouble(),
      productCode: detail?['code'] as String?,
    );
  }).toList();
});

// --- SCREEN ---
class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  int? _selectedWarehouseId; // null = all
  String _searchQuery = '';
  int? _selectedStockId;

  // Filters
  bool _showNegative = false;
  bool _showNonZero = false;
  bool _showZero = false;

  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _rowColor(double qty) {
    if (qty > 0) return Colors.green.withValues(alpha: 0.08);
    if (qty < 0) return Colors.red.withValues(alpha: 0.12);
    return Colors.blue.withValues(alpha: 0.08);
  }

  Color _quantityColor(double qty) {
    if (qty > 0) return Colors.green[700]!;
    if (qty < 0) return Colors.red[700]!;
    return Colors.blue[700]!;
  }

  List<StockItem> _applyFilters(List<StockItem> all) {
    var items = all;

    // Warehouse filter
    if (_selectedWarehouseId != null) {
      items =
          items.where((s) => s.warehouseId == _selectedWarehouseId).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items
          .where((s) =>
              s.productName.toLowerCase().contains(q) ||
              (s.productCode?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    // Quantity filters
    if (_showNegative) items = items.where((s) => s.quantity < 0).toList();
    if (_showZero) items = items.where((s) => s.quantity == 0).toList();
    if (_showNonZero) items = items.where((s) => s.quantity != 0).toList();

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final asyncStocks = ref.watch(allStocksProvider);
    final asyncWarehouses = ref.watch(allWarehousesProvider);
    final company = ref.watch(selectedCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: () {
              ref.invalidate(allStocksProvider);
              ref.invalidate(allWarehousesProvider);
            },
          ),
        ],
      ),
      body: asyncStocks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error loading stock: $e")),
        data: (allStocks) {
          if (company == null) {
            return const Center(child: Text("No company selected."));
          }

          final filtered = _applyFilters(allStocks);
          final selected = _selectedStockId != null
              ? filtered.where((s) => s.id == _selectedStockId).firstOrNull
              : null;

          // Totals for bottom bar
          final totalCost = filtered.fold<double>(
              0, (sum, s) => sum + ((s.cost ?? 0) * s.quantity));
          final totalValue = filtered.fold<double>(
              0, (sum, s) => sum + ((s.price ?? 0) * s.quantity));

          return Column(
            children: [
              // --- FILTER BAR ---
              Container(
                color: Colors.grey[100],
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _filterChip("Negative qty", _showNegative, (v) {
                      setState(() {
                        _showNegative = v;
                        if (v) {
                          _showZero = false;
                          _showNonZero = false;
                        }
                      });
                    }),
                    const SizedBox(width: 8),
                    _filterChip("Non zero qty", _showNonZero, (v) {
                      setState(() {
                        _showNonZero = v;
                        if (v) {
                          _showZero = false;
                          _showNegative = false;
                        }
                      });
                    }),
                    const SizedBox(width: 8),
                    _filterChip("Zero qty", _showZero, (v) {
                      setState(() {
                        _showZero = v;
                        if (v) {
                          _showNegative = false;
                          _showNonZero = false;
                        }
                      });
                    }),
                    const SizedBox(width: 16),
                    // Search
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: "Product name",
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
                    const Spacer(),
                    // Products count
                    Text(
                      "Products count: ${filtered.length}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),

              // --- MAIN BODY: sidebar + table ---
              Expanded(
                child: Row(
                  children: [
                    // WAREHOUSE SIDEBAR
                    Container(
                      width: 180,
                      color: Colors.grey[50],
                      child: asyncWarehouses.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Center(child: Text("Error")),
                        data: (warehouses) {
                          return ListView(
                            children: [
                              // "All" option
                              _warehouseTile(
                                label: "All Products",
                                icon: Icons.inventory_2,
                                selected: _selectedWarehouseId == null,
                                onTap: () =>
                                    setState(() => _selectedWarehouseId = null),
                              ),
                              const Divider(height: 1),
                              ...warehouses.map((w) => _warehouseTile(
                                    label: w.name,
                                    icon: Icons.warehouse,
                                    selected: _selectedWarehouseId == w.id,
                                    onTap: () => setState(
                                        () => _selectedWarehouseId = w.id),
                                  )),
                            ],
                          );
                        },
                      ),
                    ),

                    const VerticalDivider(width: 1),

                    // STOCK TABLE
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text("No stock items found.",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16)))
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                child: DataTable(
                                  showCheckboxColumn: false,
                                  headingRowColor: WidgetStateProperty.all(
                                      Colors.blueGrey[50]),
                                  columns: const [
                                    DataColumn(label: Text("#")),
                                    DataColumn(label: Text("Code")),
                                    DataColumn(label: Text("Name")),
                                    DataColumn(
                                        label: Text("Quantity"), numeric: true),
                                    DataColumn(
                                        label: Text("Cost Price"),
                                        numeric: true),
                                    DataColumn(
                                        label: Text("Cost"), numeric: true),
                                    DataColumn(
                                        label: Text("Sale Price"),
                                        numeric: true),
                                    DataColumn(
                                        label: Text("Value"), numeric: true),
                                  ],
                                  rows: filtered.asMap().entries.map((entry) {
                                    final i = entry.key + 1;
                                    final s = entry.value;
                                    final isSelected = _selectedStockId == s.id;
                                    final cost = s.cost ?? 0;
                                    final price = s.price ?? 0;
                                    final totalCostRow = cost * s.quantity;
                                    final totalValueRow = price * s.quantity;

                                    return DataRow(
                                      selected: isSelected,
                                      color: WidgetStateProperty.resolveWith(
                                          (states) {
                                        if (states
                                            .contains(WidgetState.selected)) {
                                          return Colors.pink
                                              .withValues(alpha: 0.3);
                                        }
                                        return _rowColor(s.quantity);
                                      }),
                                      onSelectChanged: (_) {
                                        setState(() {
                                          _selectedStockId =
                                              isSelected ? null : s.id;
                                        });
                                      },
                                      cells: [
                                        DataCell(Text(i.toString())),
                                        DataCell(Text(s.productCode ?? '-')),
                                        DataCell(Text(s.productName)),
                                        DataCell(Text(
                                          s.quantity.toStringAsFixed(
                                              s.quantity % 1 == 0 ? 0 : 2),
                                          style: TextStyle(
                                            color: _quantityColor(s.quantity),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                        DataCell(Text(cost.toStringAsFixed(2))),
                                        DataCell(Text(
                                            totalCostRow.toStringAsFixed(2))),
                                        DataCell(
                                            Text(price.toStringAsFixed(2))),
                                        DataCell(Text(
                                            totalValueRow.toStringAsFixed(2))),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              // --- QUICK INVENTORY BAR ---
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey[50],
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit_note, size: 16),
                      label: const Text("Quick Inventory"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedStockId != null
                            ? Colors.indigo
                            : Colors.grey[300],
                        foregroundColor: _selectedStockId != null
                            ? Colors.white
                            : Colors.grey[600],
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => _QuickInventoryDialog(
                            companyId: company.id,
                            existingStock: selected,
                            allStocks: allStocks,
                          ),
                        ).then((_) {
                          setState(() => _selectedStockId = null);
                          ref.invalidate(allStocksProvider);
                        });
                      },
                    ),
                    if (_selectedStockId != null && selected != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        "Selected: ${selected.productName} "
                        "(${selected.warehouseName})",
                        style: const TextStyle(
                            color: Colors.indigo,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () =>
                            setState(() => _selectedStockId = null),
                        child: const Text("Clear selection"),
                      ),
                    ],
                  ],
                ),
              ),

              // --- BOTTOM SUMMARY BAR ---
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, -2))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _summaryBlock("Cost price", "Total cost:", totalCost),
                    const SizedBox(width: 48),
                    _summaryBlock("Sale price", "Total:", totalValue),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip(String label, bool active, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: active,
          onChanged: (v) => onChanged(v ?? false),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _warehouseTile({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon,
          size: 18, color: selected ? Colors.indigo : Colors.grey[600]),
      title: Text(label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.indigo : null,
          )),
      selected: selected,
      selectedTileColor: Colors.indigo.withValues(alpha: 0.08),
      onTap: onTap,
    );
  }

  Widget _summaryBlock(String title, String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Row(
          children: [
            Text("$label ",
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value.toStringAsFixed(2),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ],
    );
  }
}

// --- QUICK INVENTORY DIALOG ---
class _QuickInventoryDialog extends ConsumerStatefulWidget {
  final int companyId;
  final StockItem? existingStock; // null = Add mode
  final List<StockItem> allStocks;

  const _QuickInventoryDialog({
    required this.companyId,
    required this.allStocks,
    this.existingStock,
  });

  @override
  ConsumerState<_QuickInventoryDialog> createState() =>
      _QuickInventoryDialogState();
}

class _QuickInventoryDialogState extends ConsumerState<_QuickInventoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _qtyCtrl;
  bool _isLoading = false;
  String? _errorMessage;

  // For add mode — selected product and warehouse
  int? _selectedProductId;
  int? _selectedWarehouseId;

  bool get _isEditing => widget.existingStock != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final qty = widget.existingStock!.quantity;
      _qtyCtrl = TextEditingController(
          text: qty % 1 == 0 ? qty.toInt().toString() : qty.toString());
      _selectedProductId = widget.existingStock!.productId;
      _selectedWarehouseId = widget.existingStock!.warehouseId;
    } else {
      _qtyCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final newQty = double.tryParse(_qtyCtrl.text.trim());
    if (newQty == null) {
      setState(() => _errorMessage = "Invalid quantity.");
      return;
    }
    if (_selectedProductId == null || _selectedWarehouseId == null) {
      setState(() => _errorMessage = "Please select a product and warehouse.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = createDio();

      if (_isEditing) {
        // UPDATE existing stock
        await dio.patch(
          '/Stocks/Update',
          queryParameters: {'companyId': widget.companyId},
          data: {
            'id': widget.existingStock!.id,
            'newQuantity': newQty,
            'newWarehouseId': _selectedWarehouseId,
            'newProductId': _selectedProductId,
          },
        );
      } else {
        // ADD new stock entry
        await dio.post(
          '/Stocks/Add',
          queryParameters: {'companyId': widget.companyId},
          data: {
            'quantity': newQty,
            'warehouseId': _selectedWarehouseId,
            'productId': _selectedProductId,
          },
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?.toString() ?? "Operation failed.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncProducts = ref.watch(allProductsListProvider);
    final asyncWarehouses = ref.watch(allWarehousesProvider);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.edit_note, color: Colors.indigo),
          const SizedBox(width: 8),
          Text(_isEditing
              ? "Quick Inventory — ${widget.existingStock!.productName}"
              : "Quick Inventory — Add Stock"),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product dropdown
              asyncProducts.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text("Error loading products: $e",
                    style: const TextStyle(color: Colors.red)),
                data: (products) => DropdownButtonFormField<int>(
                  initialValue: _selectedProductId,
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
                  onChanged: (v) => setState(() => _selectedProductId = v),
                  validator: (v) => v == null ? "Required" : null,
                ),
              ),
              const SizedBox(height: 16),

              // Warehouse dropdown
              asyncWarehouses.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text("Error loading warehouses: $e",
                    style: const TextStyle(color: Colors.red)),
                data: (warehouses) => DropdownButtonFormField<int>(
                  initialValue: _selectedWarehouseId,
                  decoration: const InputDecoration(
                    labelText: "Warehouse *",
                    border: OutlineInputBorder(),
                  ),
                  items: warehouses
                      .map((w) => DropdownMenuItem(
                            value: w.id,
                            child: Text(w.name),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedWarehouseId = v),
                  validator: (v) => v == null ? "Required" : null,
                ),
              ),
              const SizedBox(height: 16),

              // Quantity field
              TextFormField(
                controller: _qtyCtrl,
                decoration: const InputDecoration(
                  labelText: "Quantity *",
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: !_isEditing,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Required";
                  if (double.tryParse(v.trim()) == null) {
                    return "Enter a valid number";
                  }
                  return null;
                },
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel")),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          )
        else
          ElevatedButton.icon(
            icon: Icon(_isEditing ? Icons.save : Icons.add, size: 16),
            label: Text(_isEditing ? "Update" : "Add Stock"),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: _submit,
          ),
      ],
    );
  }
}
