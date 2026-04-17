import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'checkout_models.dart';
import 'api_client.dart';

// --- THE STATE OBJECT ---
class CartState {
  final int? activePosOrderId;
  final int activeWarehouseId;
  final List<CartItem> items;
  final bool isLoading;

  CartState({
    this.activePosOrderId,
    this.activeWarehouseId = 1,
    this.items = const [],
    this.isLoading = false,
  });

  CartState copyWith({
    int? activePosOrderId,
    int? activeWarehouseId,
    List<CartItem>? items,
    bool? isLoading,
  }) {
    return CartState(
      activePosOrderId: activePosOrderId ?? this.activePosOrderId,
      activeWarehouseId: activeWarehouseId ?? this.activeWarehouseId,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => CartState();

  double get subtotal =>
      state.items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  double get discountTotal =>
      state.items.fold(0, (sum, item) => sum + (item.discount * item.quantity));

  double get taxTotal {
    double total = 0;
    for (var item in state.items) {
      double itemTotalAfterDiscount =
          (item.price - item.discount) * item.quantity;
      for (var tax in item.appliedTaxes) {
        if (tax.isFixed) {
          total += tax.rate * item.quantity;
        } else {
          total += itemTotalAfterDiscount * (tax.rate / 100);
        }
      }
    }
    return total;
  }

  double get grandTotal => subtotal - discountTotal + taxTotal;

  void setOrderContext(int orderId, int warehouseId) {
    state = state.copyWith(
        activePosOrderId: orderId, activeWarehouseId: warehouseId);
  }

  void addItem(MenuProduct product, {double quantity = 1}) {
    if (state.activePosOrderId == null) return;

    final items = List<CartItem>.from(state.items);
    final existingIndex = items.indexWhere((i) => i.productId == product.id);

    if (existingIndex >= 0) {
      if (items[existingIndex].quantity + quantity > product.stockQuantity) {
        throw Exception("Not enough stock!");
      }
      items[existingIndex].quantity += quantity;
    } else {
      if (quantity > product.stockQuantity) {
        throw Exception("Not enough stock!");
      }
      items.add(
        CartItem(
          posOrderId: state.activePosOrderId!,
          productId: product.id,
          price: product.price,
          quantity: quantity,
          productName: product.name,
          appliedTaxes: product.taxes,
        ),
      );
    }
    state = state.copyWith(items: items);
  }

  void removeItem(int productId) {
    final items = List<CartItem>.from(state.items)
      ..removeWhere((i) => i.productId == productId);
    state = state.copyWith(items: items);
  }

  void clearCart() {
    state = CartState();
  }

  Future<bool> loadExistingOrder(
      ApiClient apiClient, int companyId, int tableId, int warehouseId) async {
    state = state.copyWith(isLoading: true);
    try {
      final order = await apiClient.getActiveOrderForTable(companyId, tableId);
      if (order == null) return false;

      final posOrderId = order['id'] ?? order['Id'];

      final itemsData = await apiClient.getOrderItems(companyId, posOrderId);

      final List<CartItem> loadedItems = itemsData.map((item) {
        return CartItem(
          posOrderId: posOrderId,
          productId: item['productId'] ?? item['ProductId'],
          price: (item['price'] ?? item['Price'] ?? 0).toDouble(),
          quantity: (item['quantity'] ?? item['Quantity'] ?? 1).toDouble(),
          discount: (item['discount'] ?? item['Discount'] ?? 0).toDouble(),
          productName: item['productName'] ?? item['ProductName'] ?? 'Item',
          appliedTaxes: [],
        );
      }).toList();

      state = CartState(
        activePosOrderId: posOrderId,
        activeWarehouseId: warehouseId,
        items: loadedItems,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<bool> saveOrderToServer(ApiClient apiClient, int companyId) async {
    if (state.items.isEmpty) return false;
    state = state.copyWith(isLoading: true);

    try {
      final success =
          await apiClient.bulkAddPosOrderItems(companyId, state.items);
      if (success) {
        clearCart();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> loadOrderById(ApiClient apiClient, int companyId, int posOrderId,
      int warehouseId) async {
    state = state.copyWith(isLoading: true);
    try {
      final itemsData = await apiClient.getOrderItems(companyId, posOrderId);

      final List<CartItem> loadedItems = itemsData.map((item) {
        return CartItem(
          posOrderId: posOrderId,
          productId: item['productId'] ?? item['ProductId'],
          price: (item['price'] ?? item['Price'] ?? 0).toDouble(),
          quantity: (item['quantity'] ?? item['Quantity'] ?? 1).toDouble(),
          discount: (item['discount'] ?? item['Discount'] ?? 0).toDouble(),
          productName: item['productName'] ?? item['ProductName'] ?? 'Item',
          appliedTaxes: [],
        );
      }).toList();

      // 3. Update the cart
      state = CartState(
        activePosOrderId: posOrderId,
        activeWarehouseId: warehouseId,
        items: loadedItems,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<bool> checkoutOrder({
    required ApiClient apiClient,
    required int companyId,
    required int userId,
    required int paymentTypeId,
    required double amountPaid,
    required int documentTypeId,
  }) async {
    if (state.activePosOrderId == null || state.items.isEmpty) return false;

    state = state.copyWith(isLoading: true);

    try {
      await apiClient.bulkAddPosOrderItems(companyId, state.items);
      final request = CheckoutRequest(
        posOrderId: state.activePosOrderId!,
        paymentTypeId: paymentTypeId,
        amountPaid: amountPaid,
        documentTypeId: documentTypeId,
        warehouseId: state.activeWarehouseId,
      );

      final success =
          await apiClient.checkoutPosOrder(companyId, userId, request);

      if (success) {
        clearCart();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final cartProvider =
    NotifierProvider<CartNotifier, CartState>(() => CartNotifier());

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider.notifier).grandTotal;
});
