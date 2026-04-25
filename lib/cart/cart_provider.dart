import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/cart/checkout_models.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/customer/customer_model.dart';
import 'package:pos_app/api/customer_discount_models.dart';

class CartState {
  final int? activePosOrderId;
  final int activeWarehouseId;
  final List<CartItem> items;
  final bool isLoading;

  final Customer? selectedCustomer;
  final CustomerDiscountDto? selectedCustomerDiscount;
  final double cartDiscount;
  final int cartDiscountType; // 0 for %, 1 for $
  final int? selectedProductId;

  CartState({
    this.activePosOrderId,
    this.activeWarehouseId = 1,
    this.items = const [],
    this.isLoading = false,
    this.selectedCustomer,
    this.selectedCustomerDiscount,
    this.cartDiscount = 0,
    this.cartDiscountType = 0,
    this.selectedProductId,
  });

  CartState copyWith({
    int? activePosOrderId,
    int? activeWarehouseId,
    List<CartItem>? items,
    bool? isLoading,
    Customer? selectedCustomer,
    CustomerDiscountDto? selectedCustomerDiscount,
    double? cartDiscount,
    int? cartDiscountType,
    int? selectedProductId,
  }) {
    return CartState(
      activePosOrderId: activePosOrderId ?? this.activePosOrderId,
      activeWarehouseId: activeWarehouseId ?? this.activeWarehouseId,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      selectedCustomerDiscount:
          selectedCustomerDiscount ?? this.selectedCustomerDiscount,
      cartDiscount: cartDiscount ?? this.cartDiscount,
      cartDiscountType: cartDiscountType ?? this.cartDiscountType,
      selectedProductId: selectedProductId ?? this.selectedProductId,
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

  double get cartDiscountAmount {
    double subtotalAfterItemDiscounts = subtotal - discountTotal;
    if (state.cartDiscountType == 0) {
      return subtotalAfterItemDiscounts * (state.cartDiscount / 100);
    } else {
      return state.cartDiscount;
    }
  }

  double get grandTotal =>
      subtotal - discountTotal - cartDiscountAmount + taxTotal;

  void setOrderContext(int orderId, int warehouseId) {
    state = state.copyWith(
      activePosOrderId: orderId,
      activeWarehouseId: warehouseId,
    );
  }

  Future<void> setCustomer(int companyId, Customer customer) async {
    final discount = await ApiClient().getCustomerDiscount(
      companyId,
      customer.id,
    );
    state = state.copyWith(
      selectedCustomer: customer,
      selectedCustomerDiscount: discount,
      cartDiscount: discount?.value ?? 0,
      cartDiscountType: discount?.type ?? 0,
    );
  }

  void setCartDiscount(double discount, int type) {
    state = state.copyWith(cartDiscount: discount, cartDiscountType: type);
  }

  void setItemDiscount(int productId, double discount) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      items[index].discount = discount;
      state = state.copyWith(items: items);
    }
  }

  void setSelectedProduct(int? productId) {
    state = state.copyWith(selectedProductId: productId);
  }

  void clearCart() {
    state = CartState(
      activePosOrderId: state.activePosOrderId,
      activeWarehouseId: state.activeWarehouseId,
      items: const [],
      isLoading: false,
    );
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

  void incrementItem(int productId) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((i) => i.productId == productId);
    if (index >= 0) items[index].quantity += 1;
    state = state.copyWith(items: items);
  }

  void decrementItem(int productId) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((i) => i.productId == productId);
    if (index >= 0 && items[index].quantity > 1) items[index].quantity -= 1;
    state = state.copyWith(items: items);
  }

  void removeItem(int productId) {
    final items = List<CartItem>.from(state.items);
    items.removeWhere((i) => i.productId == productId);
    state = state.copyWith(items: items);
  }

  void updateItemTaxes(int productId, List<MenuTax> newTaxes) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      items[index].appliedTaxes = newTaxes;
    }
    state = state.copyWith(items: items);
  }

  Future<bool> loadExistingOrder(
    ApiClient apiClient,
    int companyId,
    int tableId,
    int warehouseId,
  ) async {
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
          appliedTaxes:
              (item['taxes'] as List?)
                  ?.map((t) => MenuTax.fromJson(t))
                  .toList() ??
              (item['Taxes'] as List?)
                  ?.map((t) => MenuTax.fromJson(t))
                  .toList() ??
              [],
          isSaved: true,
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
    if (state.items.isEmpty) return true;
    state = state.copyWith(isLoading: true);
    try {
      final success = await apiClient.bulkAddPosOrderItems(
        companyId,
        state.items,
      );
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

  Future<bool> loadOrderById(
    ApiClient apiClient,
    int companyId,
    int posOrderId,
    int warehouseId,
  ) async {
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
          appliedTaxes:
              (item['taxes'] as List?)
                  ?.map((t) => MenuTax.fromJson(t))
                  .toList() ??
              (item['Taxes'] as List?)
                  ?.map((t) => MenuTax.fromJson(t))
                  .toList() ??
              [],
          isSaved: true,
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

      List<CheckoutItemDto> checkoutItems = [];
      for (var item in state.items) {
        double priceAfterDiscount = item.price - item.discount;
        double totalAfterDiscount = priceAfterDiscount * item.quantity;
        double itemTaxTotal = 0;
        List<CheckoutItemTaxDto> itemTaxes = [];

        for (var tax in item.appliedTaxes) {
          double amount = tax.isFixed
              ? (tax.rate * item.quantity)
              : (totalAfterDiscount * (tax.rate / 100));
          itemTaxTotal += amount;
          itemTaxes.add(CheckoutItemTaxDto(taxId: tax.id, amount: amount));
        }

        double finalItemTotal = totalAfterDiscount + itemTaxTotal;

        checkoutItems.add(
          CheckoutItemDto(
            productId: item.productId,
            quantity: item.quantity,
            priceBeforeTaxAfterDiscount: priceAfterDiscount,
            priceAfterDiscount: priceAfterDiscount,
            total: finalItemTotal,
            totalAfterDocumentDiscount: totalAfterDiscount,
            taxes: itemTaxes,
          ),
        );
      }

      final request = CheckoutRequest(
        posOrderId: state.activePosOrderId!,
        paymentTypeId: paymentTypeId,
        amountPaid: amountPaid,
        documentTypeId: documentTypeId,
        warehouseId: state.activeWarehouseId,
        items: checkoutItems,
      );

      final success = await apiClient.checkoutPosOrder(
        companyId,
        userId,
        request,
      );

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

final cartProvider = NotifierProvider<CartNotifier, CartState>(
  () => CartNotifier(),
);

final cartTotalProvider = Provider<double>((ref) {
  final cartState = ref.watch(cartProvider);
  if (cartState.items.isEmpty) return 0.0;

  double subtotal = cartState.items.fold(
    0,
    (sum, item) => sum + (item.price * item.quantity),
  );
  double discountTotal = cartState.items.fold(
    0,
    (sum, item) => sum + (item.discount * item.quantity),
  );

  double taxTotal = 0;
  for (var item in cartState.items) {
    double itemTotalAfterDiscount =
        (item.price - item.discount) * item.quantity;
    for (var tax in item.appliedTaxes) {
      if (tax.isFixed) {
        taxTotal += tax.rate * item.quantity;
      } else {
        taxTotal += itemTotalAfterDiscount * (tax.rate / 100);
      }
    }
  }

  return subtotal - discountTotal + taxTotal;
});
