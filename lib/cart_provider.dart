import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_model.dart';

// A simple model for an item inside the cart
class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

// The "Logic" that manages the list
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    return []; // Start empty
  }

  // Action: Add item (or increase quantity if already exists)
  void addProduct(Product product) {
    // Check if item is already in cart
    final index = state.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      // Update quantity logic
      final oldItem = state[index];
      final newItem =
          CartItem(product: product, quantity: oldItem.quantity + 1);

      // Update the list nicely
      final newState = [...state];
      newState[index] = newItem;
      state = newState;
    } else {
      // Add new item
      state = [...state, CartItem(product: product)];
    }
  }

  // Action: Remove Item
  void removeItem(Product product) {
    state = state.where((item) => item.product.id != product.id).toList();
  }

  // Action: Clear Cart
  void clear() {
    state = [];
  }

  // Convenience alias to match usages expecting `clearCart`
  void clearCart() {
    clear();
  }
}

// The Provider to access this logic
final cartProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

// Helper to calculate Grand Total
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold<double>(0.0, (sum, item) => sum + item.total);
});
