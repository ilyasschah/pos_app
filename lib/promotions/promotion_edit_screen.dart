import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/api/promotion_models.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/product/product_provider.dart';
import 'package:pos_app/product/product_group_provider.dart';
import 'package:pos_app/product/product_group_model.dart';
import 'package:pos_app/product/product_model.dart';

class EditablePromoItem {
  int id;
  int productId;
  int discountType;
  int priceType;
  double value;
  bool isConditional;
  double quantity;
  int conditionType;
  double quantityLimit;
  String? productName;

  EditablePromoItem({
    required this.id,
    required this.productId,
    required this.discountType,
    required this.priceType,
    required this.value,
    required this.isConditional,
    required this.quantity,
    required this.conditionType,
    required this.quantityLimit,
    this.productName,
  });
}

class PromotionEditScreen extends ConsumerStatefulWidget {
  final PromotionDto? promotion;

  const PromotionEditScreen({super.key, this.promotion});

  @override
  ConsumerState<PromotionEditScreen> createState() =>
      _PromotionEditScreenState();
}

class _PromotionEditScreenState extends ConsumerState<PromotionEditScreen> {
  late TextEditingController _nameController;
  late int _daysOfWeek;
  late bool _isEnabled;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  List<EditablePromoItem> _items = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.promotion?.name ?? '');
    _daysOfWeek = widget.promotion?.daysOfWeek ?? 127;
    _isEnabled = widget.promotion?.isEnabled ?? true;
    _startDate = widget.promotion?.startDate;

    if (widget.promotion?.startTime != null &&
        widget.promotion!.startTime!.isNotEmpty) {
      final parts = widget.promotion!.startTime!.split(':');
      if (parts.length >= 2) {
        _startTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }

    _endDate = widget.promotion?.endDate;

    if (widget.promotion?.endTime != null &&
        widget.promotion!.endTime!.isNotEmpty) {
      final parts = widget.promotion!.endTime!.split(':');
      if (parts.length >= 2) {
        _endTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }

    if (widget.promotion != null) {
      _items = widget.promotion!.items
          .map(
            (i) => EditablePromoItem(
              id: i.id,
              productId: i.productId,
              discountType: i.discountType,
              priceType: i.priceType,
              value: i.value,
              isConditional: i.isConditional,
              quantity: i.quantity,
              conditionType: i.conditionType,
              quantityLimit: i.quantityLimit,
            ),
          )
          .toList();
    }
  }

  void _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }

    final companyId = ref.read(selectedCompanyProvider)?.id;
    if (companyId == null) return;

    final startStr = _startTime != null
        ? "${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}"
        : null;
    final endStr = _endTime != null
        ? "${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}"
        : null;

    try {
      if (widget.promotion == null) {
        final request = CreatePromotionRequest(
          name: _nameController.text,
          daysOfWeek: _daysOfWeek,
          startDate: _startDate,
          startTime: startStr,
          endDate: _endDate,
          endTime: endStr,
          items: _items
              .map(
                (i) => CreatePromotionItemRequest(
                  productId: i.productId,
                  discountType: i.discountType,
                  priceType: i.priceType,
                  value: i.value,
                  isConditional: i.isConditional,
                  quantity: i.quantity,
                  conditionType: i.conditionType,
                  quantityLimit: i.quantityLimit,
                ),
              )
              .toList(),
        );
        await ApiClient().createPromotion(companyId, request);
      } else {
        final request = UpdatePromotionRequest(
          id: widget.promotion!.id,
          name: _nameController.text,
          daysOfWeek: _daysOfWeek,
          isEnabled: _isEnabled,
          startDate: _startDate,
          startTime: startStr,
          endDate: _endDate,
          endTime: endStr,
          items: _items
              .map(
                (i) => UpdatePromotionItemRequest(
                  id: i.id,
                  productId: i.productId,
                  discountType: i.discountType,
                  priceType: i.priceType,
                  value: i.value,
                  isConditional: i.isConditional,
                  quantity: i.quantity,
                  conditionType: i.conditionType,
                  quantityLimit: i.quantityLimit,
                ),
              )
              .toList(),
        );
        await ApiClient().updatePromotion(companyId, request);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildTree(
    List<ProductGroup> groups,
    List<Product> products,
    int? parentId,
  ) {
    final childGroups = groups
        .where((g) => g.parentGroupId == parentId)
        .toList();
    final childProducts = products
        .where((p) => p.productGroupId == parentId)
        .toList();

    if (childGroups.isEmpty && childProducts.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...childGroups.map(
          (g) => ExpansionTile(
            title: Text(
              g.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: const Icon(Icons.folder, color: Colors.blueGrey),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: _buildTree(groups, products, g.id),
              ),
            ],
          ),
        ),
        ...childProducts.map(
          (p) => ListTile(
            title: Text(p.name),
            leading: const Icon(
              Icons.inventory_2,
              color: Colors.blueGrey,
              size: 20,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () {
                setState(() {
                  if (!_items.any((i) => i.productId == p.id)) {
                    _items.add(
                      EditablePromoItem(
                        id: 0,
                        productId: p.id,
                        discountType: 0,
                        priceType: 0,
                        value: 0,
                        isConditional: false,
                        quantity: 1,
                        conditionType: 0,
                        quantityLimit: 0,
                        productName: p.name,
                      ),
                    );
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(allProductGroupsProvider);
    final productsAsync = ref.watch(allProductsListProvider);
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.promotion == null ? 'Create Promotion' : 'Edit Promotion',
        ),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Promotion Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: SwitchListTile(
                        title: const Text('Is Active'),
                        value: _isEnabled,
                        onChanged: (v) => setState(() => _isEnabled = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      "Days of Week: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...List.generate(7, (i) {
                      bool isSelected = (_daysOfWeek & (1 << i)) != 0;
                      return FilterChip(
                        label: Text(days[i]),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _daysOfWeek |= (1 << i);
                            } else {
                              _daysOfWeek &= ~(1 << i);
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        _startDate == null
                            ? "Start Date"
                            : "${_startDate!.toLocal()}".split(' ')[0],
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) setState(() => _startDate = date);
                      },
                    ),
                    if (_startDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _startDate = null),
                      ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        _startTime == null
                            ? "Start Time"
                            : _startTime!.format(context),
                      ),
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _startTime ?? TimeOfDay.now(),
                        );
                        if (time != null) setState(() => _startTime = time);
                      },
                    ),
                    if (_startTime != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _startTime = null),
                      ),
                    const SizedBox(width: 32),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        _endDate == null
                            ? "End Date"
                            : "${_endDate!.toLocal()}".split(' ')[0],
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) setState(() => _endDate = date);
                      },
                    ),
                    if (_endDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _endDate = null),
                      ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        _endTime == null
                            ? "End Time"
                            : _endTime!.format(context),
                      ),
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _endTime ?? TimeOfDay.now(),
                        );
                        if (time != null) setState(() => _endTime = time);
                      },
                    ),
                    if (_endTime != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _endTime = null),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Split Pane
          Expanded(
            child: Row(
              children: [
                // Left Pane: Hierarchy
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    child: groupsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                      data: (groups) => productsAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, stack) =>
                            Center(child: Text('Error: $err')),
                        data: (products) {
                          // Update product names in items list for display
                          for (var item in _items) {
                            if (item.productName == null) {
                              final match = products
                                  .where((p) => p.id == item.productId)
                                  .firstOrNull;
                              if (match != null) item.productName = match.name;
                            }
                          }
                          return SingleChildScrollView(
                            child: _buildTree(groups, products, null),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Right Pane: Selected Items
                Expanded(
                  flex: 2,
                  child: _items.isEmpty
                      ? const Center(
                          child: Text(
                            "Select products from the left to add to the promotion.",
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          separatorBuilder: (ctx, i) => const Divider(),
                          itemBuilder: (ctx, i) {
                            final item = _items[i];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.productName ??
                                              'Product ID: ${item.productId}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _items.removeAt(i);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            initialValue: item.value.toString(),
                                            decoration: const InputDecoration(
                                              labelText: 'Discount Value',
                                              border: OutlineInputBorder(),
                                            ),
                                            keyboardType: TextInputType.number,
                                            onChanged: (v) => item.value =
                                                double.tryParse(v) ?? 0,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: DropdownButtonFormField<int>(
                                            initialValue: item.discountType,
                                            decoration: const InputDecoration(
                                              labelText: 'Discount Type',
                                              border: OutlineInputBorder(),
                                            ),
                                            items: const [
                                              DropdownMenuItem(
                                                value: 0,
                                                child: Text('Percentage (%)'),
                                              ),
                                              DropdownMenuItem(
                                                value: 1,
                                                child: Text(
                                                  'Fixed Amount (\$)',
                                                ),
                                              ),
                                            ],
                                            onChanged: (v) => setState(
                                              () => item.discountType = v!,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    CheckboxListTile(
                                      title: const Text(
                                        "Is Conditional (e.g. Buy 2 get 1)",
                                      ),
                                      value: item.isConditional,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      contentPadding: EdgeInsets.zero,
                                      onChanged: (v) => setState(
                                        () => item.isConditional = v ?? false,
                                      ),
                                    ),
                                    if (item.isConditional)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              initialValue: item.quantity
                                                  .toString(),
                                              decoration: const InputDecoration(
                                                labelText: 'Required Quantity',
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (v) => item.quantity =
                                                  double.tryParse(v) ?? 1,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: DropdownButtonFormField<int>(
                                              initialValue: item.conditionType,
                                              decoration: const InputDecoration(
                                                labelText:
                                                    'Condition Applied To',
                                                border: OutlineInputBorder(),
                                              ),
                                              items: const [
                                                DropdownMenuItem(
                                                  value: 0,
                                                  child: Text('Same Product'),
                                                ),
                                                // Could extend this later
                                              ],
                                              onChanged: (v) => setState(
                                                () => item.conditionType = v!,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
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
