import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/stock/warehouse_provider.dart';
import 'package:pos_app/stock/stock_model.dart';
import 'package:pos_app/product/product_provider.dart';
import 'package:pos_app/product/product_model.dart';
import 'package:pos_app/currency/currencies_provider.dart';

// --- MODELS ---
class StockMasterItem {
  final Product product;
  final List<StockItem> stocks;

  StockMasterItem({required this.product, required this.stocks});

  double get totalQuantity => stocks.fold(0, (sum, s) => sum + s.quantity);
}

// --- PROVIDER ---
final stockMasterProvider =
    FutureProvider.autoDispose<List<StockMasterItem>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];

  final apiClient = ApiClient();
  final dio = createDio(); // For raw calls if needed, but prefer ApiClient

  // 1. Fetch all products
  final products = await ref.watch(allProductsListProvider.future);

  // 2. Fetch all stocks
  final stockResponse = await dio.get(
    '/Stocks/GetAllStocks',
    queryParameters: {'companyId': company.id},
  );
  final allStocks =
      (stockResponse.data as List).map((j) => StockItem.fromJson(j)).toList();

  // 3. Merge
  return products.map((p) {
    final productStocks = allStocks.where((s) => s.productId == p.id).toList();
    return StockMasterItem(product: p, stocks: productStocks);
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

  // Filters
  bool _showUnassigned = false;
  bool _showLowStock = false;

  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<StockMasterItem> _applyFilters(List<StockMasterItem> all) {
    var items = all;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items
          .where((s) =>
              s.product.name.toLowerCase().contains(q) ||
              (s.product.code?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    // Warehouse filter
    if (_selectedWarehouseId != null) {
      items = items.where((m) => m.stocks.any((s) => s.warehouseId == _selectedWarehouseId)).toList();
    }

    // Unassigned filter
    if (_showUnassigned) {
      items = items.where((m) => m.stocks.isEmpty).toList();
    }

    // Low stock filter (Example: total < 5)
    if (_showLowStock) {
      items = items.where((m) => m.totalQuantity < 5 && m.stocks.isNotEmpty).toList();
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final asyncMaster = ref.watch(stockMasterProvider);
    final asyncWarehouses = ref.watch(allWarehousesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sym = ref.watch(currencySymbolProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Inventory Master List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(stockMasterProvider),
          ),
        ],
      ),
      body: asyncMaster.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (masterList) {
          final filtered = _applyFilters(masterList);

          return Column(
            children: [
              // --- TOP FILTER BAR ---
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: "Search by product name or code...",
                          prefixIcon: const Icon(Icons.search),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilterChip(
                      label: const Text("Unassigned"),
                      selected: _showUnassigned,
                      onSelected: (v) => setState(() => _showUnassigned = v),
                      selectedColor: Colors.orange.withValues(alpha: 0.2),
                      checkmarkColor: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text("Low Stock"),
                      selected: _showLowStock,
                      onSelected: (v) => setState(() => _showLowStock = v),
                      selectedColor: Colors.red.withValues(alpha: 0.2),
                      checkmarkColor: Colors.red,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SIDEBAR ---
                    Container(
                      width: 220,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
                      ),
                      child: asyncWarehouses.when(
                        loading: () => const SizedBox(),
                        error: (_, __) => const Text("Error"),
                        data: (warehouses) => ListView(
                          children: [
                            _sidebarTile(
                              title: "All Warehouses",
                              icon: Icons.inventory_2,
                              selected: _selectedWarehouseId == null,
                              onTap: () => setState(() => _selectedWarehouseId = null),
                            ),
                            const Divider(height: 1),
                            ...warehouses.map((w) => _sidebarTile(
                                  title: w.name,
                                  icon: Icons.warehouse,
                                  selected: _selectedWarehouseId == w.id,
                                  onTap: () => setState(() => _selectedWarehouseId = w.id),
                                )),
                          ],
                        ),
                      ),
                    ),

                    // --- TABLE VIEW ---
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                Theme.of(context).colorScheme.surfaceContainerHighest,
                              ),
                              columnSpacing: 24,
                              columns: const [
                                DataColumn(label: Text("Product")),
                                DataColumn(label: Text("Code")),
                                DataColumn(label: Text("Quantity")),
                                DataColumn(label: Text("Value (Total)")),
                                DataColumn(label: Text("Actions")),
                              ],
                              rows: filtered.map((item) => _buildRow(context, item, sym)).toList(),
                            ),
                          ),
                        ),
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
  }

  Widget _sidebarTile({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      selected: selected,
      leading: Icon(icon, color: selected ? Colors.blue : Colors.blueGrey),
      title: Text(title, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      onTap: onTap,
      selectedTileColor: Colors.blue.withValues(alpha: 0.1),
    );
  }

  DataRow _buildRow(BuildContext context, StockMasterItem item, String sym) {
    final product = item.product;
    final stocks = _selectedWarehouseId == null
        ? item.stocks
        : item.stocks.where((s) => s.warehouseId == _selectedWarehouseId).toList();

    final double totalQty = stocks.fold(0, (sum, s) => sum + s.quantity);
    final double totalValue = totalQty * product.price;

    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              product.imageBytes != null
                  ? CircleAvatar(
                      radius: 16,
                      backgroundImage: MemoryImage(product.imageBytes!),
                    )
                  : const CircleAvatar(
                      radius: 16,
                      child: Icon(Icons.inventory_2, size: 16),
                    ),
              const SizedBox(width: 12),
              Text(product.name, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        DataCell(Text(product.code ?? "-")),
        DataCell(
          stocks.isEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.warning_amber, size: 14, color: Colors.red),
                      SizedBox(width: 4),
                      Text("Unassigned", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                )
              : Text(
                  totalQty.toStringAsFixed(totalQty % 1 == 0 ? 0 : 2),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: totalQty < 5 ? Colors.red : Colors.green,
                  ),
                ),
        ),
        DataCell(Text("$sym${totalValue.toStringAsFixed(2)}")),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_box, color: Colors.green),
                tooltip: "Assign / Add Stock",
                onPressed: () => _showAssignDialog(context, product),
              ),
              if (stocks.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.history, color: Colors.blue),
                  tooltip: "Stock Details",
                  onPressed: () {
                    // Could show warehouse breakdown
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAssignDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => _AssignStockDialog(product: product),
    ).then((success) {
      if (success == true) {
        ref.invalidate(stockMasterProvider);
      }
    });
  }
}

class _AssignStockDialog extends ConsumerStatefulWidget {
  final Product product;
  const _AssignStockDialog({required this.product});

  @override
  ConsumerState<_AssignStockDialog> createState() => _AssignStockDialogState();
}

class _AssignStockDialogState extends ConsumerState<_AssignStockDialog> {
  int? _selectedWarehouseId;
  final _qtyCtrl = TextEditingController(text: "0");
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final asyncWarehouses = ref.watch(allWarehousesProvider);

    return AlertDialog(
      title: Text("Assign ${widget.product.name} to Warehouse"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          asyncWarehouses.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text("Error: $e"),
            data: (warehouses) => DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: "Warehouse"),
              items: warehouses
                  .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedWarehouseId = v),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _qtyCtrl,
            decoration: const InputDecoration(labelText: "Initial Quantity"),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("Save"),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (_selectedWarehouseId == null) return;
    final qty = double.tryParse(_qtyCtrl.text) ?? 0;
    final company = ref.read(selectedCompanyProvider);
    if (company == null) return;

    setState(() => _isSaving = true);
    try {
      await ApiClient().addStock(company.id, widget.product.id, _selectedWarehouseId!, qty);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        setState(() => _isSaving = false);
      }
    }
  }
}
