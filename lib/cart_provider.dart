import 'package:flutter/material.dart';
import 'checkout_models.dart';
import 'api_client.dart';

class CartProvider extends ChangeNotifier {
  // --- STATE ---
  int? activePosOrderId;
  int activeWarehouseId = 1; // You can update this when the user logs in
  List<CartItem> _items = [];
  bool isLoading = false;

  // --- GETTERS ---
  List<CartItem> get items => _items;

  // 1. Subtotal (Price * Quantity)
  double get subtotal {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  // 2. Total Discounts Applied
  double get discountTotal {
    return _items.fold(0, (sum, item) => sum + (item.discount * item.quantity));
  }

  // 3. Complex Tax Calculation
  double get taxTotal {
    double totalTax = 0;
    for (var item in _items) {
      // Base price for this item's row after discounts
      double itemTotalAfterDiscount =
          (item.price - item.discount) * item.quantity;

      for (var tax in item.appliedTaxes) {
        if (tax.isFixed) {
          totalTax += tax.rate *
              item.quantity; // Fixed amount per item (e.g., $1 bottle tax)
        } else {
          totalTax += itemTotalAfterDiscount * (tax.rate / 100); // Percentage
        }
      }
    }
    return totalTax;
  }

  // 4. Grand Total
  double get grandTotal {
    // Note: If your system uses Tax Inclusive pricing, you might not add taxTotal here.
    // Assuming Tax Exclusive for this calculation:
    return subtotal - discountTotal + taxTotal;
  }

  // --- ACTIONS ---

  void setOrderContext(int orderId, int warehouseId) {
    activePosOrderId = orderId;
    activeWarehouseId = warehouseId;
    notifyListeners();
  }

  void addItem(MenuProduct product, {double quantity = 1}) {
    if (activePosOrderId == null)
      return; // Cannot add items without an active order

    // 1. Check if item already exists in cart
    final existingIndex = _items.indexWhere((i) => i.productId == product.id);

    if (existingIndex >= 0) {
      // 2. Validate Stock before incrementing
      final currentQty = _items[existingIndex].quantity;
      if (currentQty + quantity > product.stockQuantity) {
        throw Exception("Not enough stock in Warehouse $activeWarehouseId!");
      }
      _items[existingIndex].quantity += quantity;
    } else {
      // 3. Validate Stock before adding new
      if (quantity > product.stockQuantity) {
        throw Exception("Not enough stock in Warehouse $activeWarehouseId!");
      }

      // 4. Add the new item
      _items.add(
        CartItem(
          posOrderId: activePosOrderId!,
          productId: product.id,
          price: product.price,
          quantity: quantity,
          productName: product.name, // Used for UI only
          appliedTaxes: product.taxes, // Used for local tax math
        ),
      );
    }
    notifyListeners(); // Instantly updates the UI!
  }

  void updateQuantity(int productId, double newQuantity) {
    final index = _items.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void removeItem(int productId) {
    _items.removeWhere((i) => i.productId == productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    activePosOrderId = null;
    notifyListeners();
  }

  // --- API INTEGRATION ---

  // Called when the waiter clicks "Save Order"
  Future<bool> saveOrderToServer(ApiClient apiClient, int companyId) async {
    if (_items.isEmpty) return false;

    isLoading = true;
    notifyListeners();

    try {
      // Fires the massive JSON array to our C# BulkAdd endpoint
      final success = await apiClient.bulkAddPosOrderItems(companyId, _items);

      if (success) {
        // Once safely in the DB, clear the local memory
        clearCart();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
