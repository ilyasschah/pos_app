import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/cart/checkout_models.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/customer/customer_model.dart';
import 'package:pos_app/api/customer_discount_models.dart';
import 'package:pos_app/customer/customer_provider.dart';
import 'package:pos_app/floor_plan/floor_plan_table_provider.dart';
import 'package:pos_app/promotions/promotion_provider.dart';
import 'package:pos_app/stock/warehouse_provider.dart';

class CartState {
  final int? activePosOrderId;
  final List<CartItem> items;
  final String? orderNumber;
  final bool isLoading;

  final Customer? selectedCustomer;
  final CustomerDiscountDto? selectedCustomerDiscount;
  final double manualCartDiscount;
  final int manualCartDiscountType; // 0 for %, 1 for $
  final double? customerDiscountValue;
  final int? customerDiscountType;
  final int? selectedProductId;
  final int serviceType; // 0 for Dine In, 1 for Takeaway
  final int serviceStatus; // 1 for Active, etc.
  final int? floorPlanTableId;
  final int? activeWarehouseId;

  CartState({
    this.activePosOrderId,
    this.items = const [],
    this.orderNumber,
    this.isLoading = false,
    this.selectedCustomer,
    this.selectedCustomerDiscount,
    this.manualCartDiscount = 0,
    this.manualCartDiscountType = 0,
    this.customerDiscountValue,
    this.customerDiscountType,
    this.selectedProductId,
    this.serviceType = 0,
    this.serviceStatus = 1,
    this.floorPlanTableId,
    this.activeWarehouseId,
  });

  CartState copyWith({
    int? activePosOrderId,
    List<CartItem>? items,
    bool? isLoading,
    Customer? selectedCustomer,
    CustomerDiscountDto? selectedCustomerDiscount,
    double? manualCartDiscount,
    int? manualCartDiscountType,
    int? selectedProductId,
    String? orderNumber,
    double? customerDiscountValue,
    int? customerDiscountType,
    int? serviceType,
    int? serviceStatus,
    int? floorPlanTableId,
    int? activeWarehouseId,
  }) {
    return CartState(
      activePosOrderId: activePosOrderId ?? this.activePosOrderId,
      items: items ?? this.items,
      orderNumber: orderNumber ?? this.orderNumber,
      isLoading: isLoading ?? this.isLoading,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      selectedCustomerDiscount:
          selectedCustomerDiscount ?? this.selectedCustomerDiscount,
      manualCartDiscount: manualCartDiscount ?? this.manualCartDiscount,
      manualCartDiscountType:
          manualCartDiscountType ?? this.manualCartDiscountType,
      customerDiscountValue:
          customerDiscountValue ?? this.customerDiscountValue,
      customerDiscountType: customerDiscountType ?? this.customerDiscountType,
      selectedProductId: selectedProductId ?? this.selectedProductId,
      serviceType: serviceType ?? this.serviceType,
      serviceStatus: serviceStatus ?? this.serviceStatus,
      floorPlanTableId: floorPlanTableId ?? this.floorPlanTableId,
      activeWarehouseId: activeWarehouseId ?? this.activeWarehouseId,
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => CartState();

  int get effectiveWarehouseId => ref.read(selectedWarehouseProvider)?.id ?? 1;

  double get subtotal =>
      state.items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  double get discountTotal => state.items.fold(
    0,
    (sum, item) =>
        sum + ((item.discount + item.promotionalDiscount) * item.quantity),
  );

  double get promotionalDiscountTotal => state.items.fold(
    0,
    (sum, item) => sum + (item.promotionalDiscount * item.quantity),
  );

  double get taxTotal {
    double total = 0;
    // Apply cart-level discount factor to the taxable base of each item
    double baseBeforeCartDiscounts = subtotal - discountTotal;
    double totalCartDiscounts =
        customerDiscountAmount + manualCartDiscountAmount;
    double discountFactor = baseBeforeCartDiscounts > 0
        ? (baseBeforeCartDiscounts - totalCartDiscounts) /
              baseBeforeCartDiscounts
        : 1.0;

    for (var item in state.items) {
      double itemTotalAfterItemDiscount =
          (item.price - item.discount - item.promotionalDiscount) *
          item.quantity;
      double itemTaxableBase = itemTotalAfterItemDiscount * discountFactor;

      for (var tax in item.appliedTaxes) {
        if (tax.isFixed) {
          total += tax.rate * item.quantity;
        } else {
          total += itemTaxableBase * (tax.rate / 100);
        }
      }
    }
    return total;
  }

  double get customerDiscountAmount {
    if (state.customerDiscountValue == null) return 0;
    double base = subtotal - discountTotal;
    if (state.customerDiscountType == 0) {
      return base * (state.customerDiscountValue! / 100);
    } else {
      return state.customerDiscountValue!;
    }
  }

  double get manualCartDiscountAmount {
    double base = subtotal - discountTotal - customerDiscountAmount;
    if (state.manualCartDiscountType == 0) {
      return base * (state.manualCartDiscount / 100);
    } else {
      return state.manualCartDiscount;
    }
  }

  double get grandTotal =>
      subtotal -
      discountTotal -
      customerDiscountAmount -
      manualCartDiscountAmount +
      taxTotal;

  void _applyPromotions(List<CartItem> items) {
    final activePromotions = ref.read(activePromotionsProvider);
    for (var item in items) {
      double bestDiscount = 0;
      for (var promo in activePromotions) {
        for (var pItem in promo.items) {
          if (pItem.productId == item.productId) {
            double currentDiscount = 0;
            // discountType: 0 for %, 1 for $
            if (pItem.discountType == 0) {
              currentDiscount = item.price * (pItem.value / 100);
            } else {
              currentDiscount = pItem.value;
            }
            if (currentDiscount > bestDiscount) {
              bestDiscount = currentDiscount;
            }
          }
        }
      }
      item.promotionalDiscount = bestDiscount;
    }
  }

  void setOrderContext(
    int orderId,
    int warehouseId, {
    int? tableId,
    String? orderNumber,
  }) {
    state = state.copyWith(
      activePosOrderId: orderId,
      floorPlanTableId: tableId,
      orderNumber: orderNumber,
      activeWarehouseId: warehouseId,
    );
    // Sync global warehouse
    final warehouses = ref.read(allWarehousesProvider).value ?? [];
    final wh = warehouses.where((w) => w.id == warehouseId).firstOrNull;
    if (wh != null) {
      ref.read(selectedWarehouseProvider.notifier).state = wh;
    }
  }

  Future<void> setCustomer(int companyId, Customer customer) async {
    final discount = await ApiClient().getCustomerDiscount(
      companyId,
      customer.id,
    );
    state = state.copyWith(
      selectedCustomer: customer,
      selectedCustomerDiscount: discount,
      customerDiscountValue: discount?.value,
      customerDiscountType: discount?.type,
    );
    // Auto-update current customer provider if not already set
    ref.read(currentCustomerProvider.notifier).setCustomer(customer);
  }

  void setWarehouseId(int warehouseId) {
    state = state.copyWith(activeWarehouseId: warehouseId);
    // Sync global provider
    final warehouses = ref.read(allWarehousesProvider).value ?? [];
    final wh = warehouses.where((w) => w.id == warehouseId).firstOrNull;
    if (wh != null) {
      ref.read(selectedWarehouseProvider.notifier).state = wh;
    }
  }

  void setCartDiscount(double discount, int type) {
    state = state.copyWith(
      manualCartDiscount: discount,
      manualCartDiscountType: type,
    );
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

  void clearCart({bool keepCustomer = false}) {
    state = CartState(
      activePosOrderId: state.activePosOrderId,
      items: const [],
      isLoading: false,
      selectedCustomer: keepCustomer ? state.selectedCustomer : null,
      customerDiscountValue: keepCustomer ? state.customerDiscountValue : null,
      customerDiscountType: keepCustomer ? state.customerDiscountType : null,
      manualCartDiscount: keepCustomer ? state.manualCartDiscount : 0,
      manualCartDiscountType: keepCustomer ? state.manualCartDiscountType : 0,
    );

    if (keepCustomer) return;

    // Reset to default Walk-In customer
    final customers = ref.read(allCustomersProvider).value ?? [];
    if (customers.isNotEmpty) {
      final walkIn = customers.firstWhere(
        (c) => c.code == 'C000',
        orElse: () => customers.first,
      );
      final companyId = ref.read(selectedCompanyProvider)?.id;
      if (companyId != null) {
        setCustomer(companyId, walkIn);
      }
    }
  }

  void addItem(
    MenuProduct product, {
    double quantity = 1,
    String? comment,
    String? measurementUnit,
  }) {
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
          comment: comment,
          measurementUnit: measurementUnit,
        ),
      );
    }
    _applyPromotions(items);
    state = state.copyWith(items: items);
  }

  void incrementItem(int productId) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      items[index].quantity += 1;
      _applyPromotions(items);
    }
    state = state.copyWith(items: items);
  }

  void decrementItem(int productId) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((i) => i.productId == productId);
    if (index >= 0 && items[index].quantity > 1) {
      items[index].quantity -= 1;
      _applyPromotions(items);
    }
    state = state.copyWith(items: items);
  }

  void removeItem(int productId) {
    final items = List<CartItem>.from(state.items);
    items.removeWhere((i) => i.productId == productId);
    _applyPromotions(items);
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
      final orderNumber = order['number'] ?? order['Number'] ?? "ORD-TEMP";
      final discount = (order['discount'] ?? order['Discount'] ?? 0).toDouble();
      final discountType = (order['discountType'] ?? order['DiscountType'] ?? 0)
          .toInt();

      final itemsData = await apiClient.getOrderItems(companyId, posOrderId);

      // Restore customer if present
      final customerId = order['customerId'] ?? order['CustomerId'];
      if (customerId != null) {
        final customers = ref.read(allCustomersProvider).value ?? [];
        final customer = customers.where((c) => c.id == customerId).firstOrNull;
        if (customer != null) {
          await setCustomer(companyId, customer);
        }
      }

      final serviceType = (order['serviceType'] ?? order['ServiceType'] ?? 0)
          .toInt();
      final serviceStatus =
          (order['serviceStatus'] ?? order['ServiceStatus'] ?? 1).toInt();
      final floorPlanTableId =
          order['floorPlanTableId'] ?? order['FloorPlanTableId'];

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

      _applyPromotions(loadedItems);

      state = state.copyWith(
        activePosOrderId: posOrderId,
        items: loadedItems,
        orderNumber: orderNumber,
        manualCartDiscount: discount,
        manualCartDiscountType: discountType,
        serviceType: serviceType,
        serviceStatus: serviceStatus,
        floorPlanTableId: floorPlanTableId,
        activeWarehouseId: warehouseId,
        isLoading: false,
      );

      // Sync global warehouse
      final warehouses = ref.read(allWarehousesProvider).value ?? [];
      final wh = warehouses.where((w) => w.id == warehouseId).firstOrNull;
      if (wh != null) {
        ref.read(selectedWarehouseProvider.notifier).state = wh;
      }

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> saveOrderToServer({
    required ApiClient apiClient,
    required int companyId,
    required int userId,
    required void Function(List<String> warnings) onWarnings,
  }) async {
    if (state.items.isEmpty || state.activePosOrderId == null) {
      return {'success': true};
    }
    state = state.copyWith(isLoading: true);
    try {
      // 1. Save items
      final response = await apiClient.bulkAddPosOrderItems(
        companyId,
        effectiveWarehouseId,
        state.items,
      );

      if (response['success'] != true) {
        return response;
      }

      final warnings = List<String>.from(response['warnings'] ?? []);
      if (warnings.isNotEmpty) {
        onWarnings(warnings);
      }

      // 2. Sync Order Header (Discounts & Total)
      String orderNumber = state.orderNumber ?? "ORD- Takeaway";
      if (state.orderNumber == null) {
        final tableId = ref.read(floorPlanTableProvider);
        if (tableId != null) {
          final tables = ref.read(tablesByFloorPlanProvider).value ?? [];
          final table = tables.where((t) => t.id == tableId).firstOrNull;
          if (table != null) {
            orderNumber = "ORD- ${table.name}";
          }
        }
      }

      final updateRequest = {
        "id": state.activePosOrderId,
        "userId": userId,
        "number": orderNumber,
        "discount": state.manualCartDiscount,
        "discountType": state.manualCartDiscountType,
        "total": grandTotal,
        "customerId": state.selectedCustomer?.id,
        "serviceType": state.serviceType,
        "serviceStatus": state.serviceStatus,
        "floorPlanTableId": state.floorPlanTableId,
        "warehouseId": effectiveWarehouseId,
      };

      final headerSuccess = await apiClient.updatePosOrder(
        companyId,
        updateRequest,
      );
      if (headerSuccess) {
        clearCart();
        return {'success': true, 'warnings': warnings};
      }
      return {'success': false, 'message': 'Failed to update order header.'};
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
      final order = await apiClient.getPosOrderById(companyId, posOrderId);
      final orderNumber = order['number'] ?? order['Number'] ?? "ORD-TEMP";
      final discount = (order['discount'] ?? order['Discount'] ?? 0).toDouble();
      final discountType = (order['discountType'] ?? order['DiscountType'] ?? 0)
          .toInt();

      final itemsData = await apiClient.getOrderItems(companyId, posOrderId);

      // Restore customer if present
      final customerId = order['customerId'] ?? order['CustomerId'];
      if (customerId != null) {
        final customers = ref.read(allCustomersProvider).value ?? [];
        final customer = customers.where((c) => c.id == customerId).firstOrNull;
        if (customer != null) {
          await setCustomer(companyId, customer);
        }
      }

      final serviceType = (order['serviceType'] ?? order['ServiceType'] ?? 0)
          .toInt();
      final serviceStatus =
          (order['serviceStatus'] ?? order['ServiceStatus'] ?? 1).toInt();
      final floorPlanTableId =
          order['floorPlanTableId'] ?? order['FloorPlanTableId'];

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

      _applyPromotions(loadedItems);

      state = state.copyWith(
        activePosOrderId: posOrderId,
        items: loadedItems,
        orderNumber: orderNumber,
        manualCartDiscount: discount,
        manualCartDiscountType: discountType,
        serviceType: serviceType,
        serviceStatus: serviceStatus,
        floorPlanTableId: floorPlanTableId,
        activeWarehouseId: warehouseId,
        isLoading: false,
      );

      // Sync global warehouse
      final warehouses = ref.read(allWarehousesProvider).value ?? [];
      final wh = warehouses.where((w) => w.id == warehouseId).firstOrNull;
      if (wh != null) {
        ref.read(selectedWarehouseProvider.notifier).state = wh;
      }

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
      final response = await apiClient.bulkAddPosOrderItems(
        companyId,
        effectiveWarehouseId,
        state.items,
      );

      if (response['success'] != true) {
        throw Exception(
          response['message'] ?? "Failed to save cart before checkout.",
        );
      }

      List<CheckoutItemDto> checkoutItems = [];
      for (var item in state.items) {
        double priceAfterDiscount =
            item.price - item.discount - item.promotionalDiscount;
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
        warehouseId: effectiveWarehouseId,
        items: checkoutItems,
        grandTotal: grandTotal,
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
  final cartNotifier = ref.watch(cartProvider.notifier);

  if (cartState.items.isEmpty) return 0.0;

  double subtotal = cartNotifier.subtotal;
  double discountTotal = cartNotifier.discountTotal;
  double customerDiscountAmount = cartNotifier.customerDiscountAmount;
  double manualCartDiscountAmount = cartNotifier.manualCartDiscountAmount;

  double baseBeforeCartDiscounts = subtotal - discountTotal;
  double totalCartDiscounts = customerDiscountAmount + manualCartDiscountAmount;
  double discountFactor = baseBeforeCartDiscounts > 0
      ? (baseBeforeCartDiscounts - totalCartDiscounts) / baseBeforeCartDiscounts
      : 1.0;

  double taxTotal = 0;
  for (var item in cartState.items) {
    double itemTotalAfterItemDiscount =
        (item.price - item.discount - item.promotionalDiscount) * item.quantity;
    double itemTaxableBase = itemTotalAfterItemDiscount * discountFactor;
    for (var tax in item.appliedTaxes) {
      if (tax.isFixed) {
        taxTotal += tax.rate * item.quantity;
      } else {
        taxTotal += itemTaxableBase * (tax.rate / 100);
      }
    }
  }

  return subtotal - discountTotal - totalCartDiscounts + taxTotal;
});
