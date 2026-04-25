import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/cart/cart_provider.dart';

class DiscountDialog extends ConsumerStatefulWidget {
  const DiscountDialog({super.key});

  @override
  ConsumerState<DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends ConsumerState<DiscountDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _cartValueCtrl = TextEditingController(text: '0');
  final TextEditingController _itemValueCtrl = TextEditingController(text: '0');

  int _cartDiscountType = 0;
  int _itemDiscountType =
      0; // if item discount is always fixed amount, or maybe we do math

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartState = ref.read(cartProvider);
      _cartValueCtrl.text = cartState.cartDiscount.toString();
      _cartDiscountType = cartState.cartDiscountType;

      if (cartState.selectedProductId != null) {
        final item = cartState.items.firstWhere(
          (i) => i.productId == cartState.selectedProductId,
          orElse: () => cartState.items.first,
        );
        _itemValueCtrl.text = item.discount.toString();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cartValueCtrl.dispose();
    _itemValueCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    final cartState = ref.read(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    if (_tabController.index == 0) {
      // Cart Discount
      final val = double.tryParse(_cartValueCtrl.text) ?? 0;
      cartNotifier.setCartDiscount(val, _cartDiscountType);
      Navigator.pop(context);
    } else {
      // Item Discount
      if (cartState.selectedProductId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No item selected!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final val = double.tryParse(_itemValueCtrl.text) ?? 0;

      // We only have one discount property on item, which is a fixed amount.
      // If user selected %, we calculate it.
      double finalDiscount = val;
      if (_itemDiscountType == 0) {
        // Percentage
        final item = cartState.items.firstWhere(
          (i) => i.productId == cartState.selectedProductId,
        );
        finalDiscount = item.price * (val / 100);
      }
      cartNotifier.setItemDiscount(cartState.selectedProductId!, finalDiscount);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Apply Discount"),
      content: SizedBox(
        width: 400,
        height: 300,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "Cart Discount"),
                Tab(text: "Item Discount"),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Cart Discount Tab
                  Column(
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: _cartDiscountType,
                        decoration: const InputDecoration(
                          labelText: "Discount Type",
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 0,
                            child: Text('Percentage (%)'),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text('Fixed Amount (\$)'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _cartDiscountType = v!),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _cartValueCtrl,
                        decoration: const InputDecoration(labelText: "Value"),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  // Item Discount Tab
                  Column(
                    children: [
                      if (ref.watch(cartProvider).selectedProductId == null)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Please select an item in the cart first.",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      DropdownButtonFormField<int>(
                        initialValue: _itemDiscountType,
                        decoration: const InputDecoration(
                          labelText: "Discount Type",
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 0,
                            child: Text('Percentage (%)'),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text('Fixed Amount (\$)'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _itemDiscountType = v!),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _itemValueCtrl,
                        decoration: const InputDecoration(labelText: "Value"),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(onPressed: _apply, child: const Text("Apply")),
      ],
    );
  }
}
