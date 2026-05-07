import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_app/cart/checkout_models.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/app_settings/app_settings_model.dart';
import 'package:pos_app/app_settings/app_settings_provider.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/customer/customer_model.dart';
import 'package:pos_app/api/customer_discount_models.dart';
import 'package:pos_app/customer/customer_provider.dart';
import 'package:pos_app/floor_plan/floor_plan_table_provider.dart';
import 'package:pos_app/promotions/promotion_provider.dart';
import 'package:pos_app/stock/warehouse_provider.dart';

final dailyOrderNumberProvider = StateProvider<int>((ref) => 1);

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
  final int
  serviceType; // 0 for Dine In / Appointment, 1 for Takeaway / Walk-In
  final int serviceStatus; // 1 for Active, etc.
  final int? floorPlanTableId;
  final int? activeWarehouseId;
  final int? bookingId;
  final int? bookingStaffId;

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
    this.bookingId,
    this.bookingStaffId,
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
    int? bookingId,
    int? bookingStaffId,
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
      bookingId: bookingId ?? this.bookingId,
      bookingStaffId: bookingStaffId ?? this.bookingStaffId,
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => CartState();

  // Prefer the warehouse that was set when this order was created/loaded.
  // Fall back to the globally selected warehouse, then to 1 as a last resort.
  // Never returns 0 — a zero would fail the backend's inventory guard.
  int get effectiveWarehouseId {
    final fromState = state.activeWarehouseId;
    if (fromState != null && fromState > 0) return fromState;
    final fromProvider = ref.read(selectedWarehouseProvider)?.id ?? 0;
    return fromProvider > 0 ? fromProvider : 1;
  }

  // Returns the ALL-CAPS order number prefix for a given serviceType id.
  // Looks up the matching CustomServiceType from settings; falls back to
  // 'ORDER' so the label is always safe even on a fresh install.
  String _getPrefix(int serviceType) {
    final types = ref.read(appSettingsProvider.notifier).customServiceTypes;
    return types
            .where((t) => t.id == serviceType)
            .map((t) => t.prefix)
            .firstOrNull ??
        'ORDER';
  }

  // Per-company high-water mark for the daily sequence number.
  // Keyed by companyId so switching tenants never cross-contaminates counters.
  // Static so it survives Notifier rebuilds within the same app session.
  static final Map<int, int> _highestSeenSequence = {};

  // Scans BOTH open POS orders AND today's paid Documents to find the true
  // daily maximum, then advances dailyOrderNumberProvider to max+1.
  //
  // Why both sources?
  //   - Open orders:  carry the label in their `number` field.
  //   - Paid docs:    the POS label is stored in `orderNumber`; once an order
  //                   is checked out it disappears from the POS list.
  // Filtering documents to today prevents yesterday's #099 from blocking
  // today's counter from resetting to #1.
  //
  // The high-water map makes the counter strictly monotonic: transferring an
  // order removes it from the open-orders list, so a naive scan would compute
  // a lower max and silently re-use a sequence number.  By never letting the
  // remembered value decrease we prevent that collision.
  //
  // No ref.invalidate needed: this method calls ApiClient() directly on every
  // invocation — it never reads from a cached Riverpod provider, so the data
  // is always fresh regardless of when it's called.
  Future<void> syncOrderNumber(int companyId) async {
    try {
      final client = ApiClient();
      final results = await Future.wait([
        client.getAllPosOrders(companyId).catchError((_) => <dynamic>[]),
        client.getAllDocuments(companyId).catchError((_) => <dynamic>[]),
      ]);

      // Compare in UTC throughout so a device timezone never shifts the day
      // boundary relative to the ISO-8601 strings the API returns.
      final todayUtc = DateTime.now().toUtc();
      int absoluteMax = 0;

      // Open POS orders — always current-session, no date filter needed.
      for (final o in results[0]) {
        final raw = (o['number'] ?? o['Number'] ?? '') as String;
        final match = RegExp(r'[#-](\d+)$').firstMatch(raw);
        if (match != null) {
          final parsed = int.tryParse(match.group(1)!);
          if (parsed != null && parsed > absoluteMax) absoluteMax = parsed;
        }
      }

      // Paid documents — filter to today only so yesterday's numbers don't
      // block a fresh daily reset.
      for (final d in results[1]) {
        // Prefer dateCreated (set by EF Core on insert); fall back to date
        // (the business date, always present on Document).  A newly committed
        // document may return dateCreated=null in the first API read, so the
        // fallback ensures it is still counted.
        final rawDate = (d['dateCreated'] ?? d['DateCreated'] ??
            d['date'] ?? d['Date'] ?? '') as String;
        if (rawDate.isNotEmpty) {
          final created = DateTime.tryParse(rawDate)?.toUtc();
          if (created != null) {
            if (created.year != todayUtc.year ||
                created.month != todayUtc.month ||
                created.day != todayUtc.day) continue;
          }
          // If parse fails we still include the document (fail-open keeps
          // the counter safe; we'd rather skip the reset than under-count).
        }

        final raw = (d['orderNumber'] ?? d['OrderNumber'] ?? '') as String;
        if (raw.isEmpty) continue;
        final match = RegExp(r'[#-](\d+)$').firstMatch(raw);
        if (match != null) {
          final parsed = int.tryParse(match.group(1)!);
          if (parsed != null && parsed > absoluteMax) absoluteMax = parsed;
        }
      }

      // Monotonic high-water mark — the counter for this company must never
      // go backwards (e.g. after a transfer drops an order from the scan).
      final currentHighWater = _highestSeenSequence[companyId] ?? 0;
      if (absoluteMax > currentHighWater) {
        _highestSeenSequence[companyId] = absoluteMax;
      }
      final nextNumber = _highestSeenSequence[companyId]! + 1;

      ref.read(dailyOrderNumberProvider.notifier).state = nextNumber;
    } catch (_) {
      // Non-fatal — counter stays at current value
    }
  }

  // Reactively switches serviceType and re-labels the orderNumber with the new
  // prefix while preserving the existing counter number (e.g. TAKEAWAY #005 →
  // ORDER #005). Silently blocks the switch if the service-type feature is
  // globally disabled in settings.
  void setServiceType(int newType) {
    final settings = ref.read(appSettingsProvider);
    final typeEnabled =
        settings[SettingKeys.featureServiceTypeEnabled]?.toLowerCase() == 'true';
    if (newType != 0 && !typeEnabled) return;

    final numMatch = RegExp(r'[#-](\d+)$').firstMatch(state.orderNumber ?? '');
    // Never read dailyOrderNumberProvider here — it is already one ahead of
    // the current order, which would silently add +1 to the label.
    // If extraction fails (e.g. a table name like "ORD- T1"), keep '001' as a
    // safe fallback; the label is cosmetic only until the next syncOrderNumber.
    final num = numMatch?.group(1) ?? '001';

    state = state.copyWith(
      serviceType: newType,
      orderNumber: '${_getPrefix(newType)} #$num',
    );
  }

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

  Future<void> clearFloorPlanTable(int newServiceType, {required int companyId}) async {
    if (state.floorPlanTableId != null) {
      try {
        await ApiClient().freeFloorPlanTable(companyId, state.floorPlanTableId!);
      } catch (_) {}
    }
    // Preserve the existing sequence number when only the service type is
    // changing (tableless switch). Fall back to dailyOrderNumber only when
    // there is no existing numeric label to extract from (e.g. a fresh cart).
    final _existingNum = RegExp(r'[#-](\d+)$').firstMatch(state.orderNumber ?? '')?.group(1);
    final _newOrderNumber = _existingNum != null
        ? '${_getPrefix(newServiceType)} #$_existingNum'
        : '${_getPrefix(newServiceType)} #${ref.read(dailyOrderNumberProvider).toString().padLeft(3, '0')}';
    state = CartState(
      activePosOrderId: state.activePosOrderId,
      items: state.items,
      orderNumber: _newOrderNumber,
      isLoading: state.isLoading,
      selectedCustomer: state.selectedCustomer,
      selectedCustomerDiscount: state.selectedCustomerDiscount,
      manualCartDiscount: state.manualCartDiscount,
      manualCartDiscountType: state.manualCartDiscountType,
      customerDiscountValue: state.customerDiscountValue,
      customerDiscountType: state.customerDiscountType,
      selectedProductId: state.selectedProductId,
      serviceType: newServiceType,
      serviceStatus: state.serviceStatus,
      floorPlanTableId: null,
      activeWarehouseId: state.activeWarehouseId,
      bookingId: state.bookingId,
      bookingStaffId: state.bookingStaffId,
    );
  }

  Future<void> startTablelessOrder(
    ApiClient apiClient,
    int companyId,
    int userId,
    int serviceType,
  ) async {
    final orderNum = ref.read(dailyOrderNumberProvider);
    final label = orderNum.toString().padLeft(3, '0');
    final orderNumber = '${_getPrefix(serviceType)} #$label';
    state = state.copyWith(isLoading: true);
    try {
      final newOrderId = await apiClient.createPosOrder(
        companyId,
        userId,
        serviceType,
        null,
        orderNumber,
        effectiveWarehouseId,
      );
      state = CartState(
        activePosOrderId: newOrderId,
        serviceType: serviceType,
        serviceStatus: 1,
        floorPlanTableId: null,
        orderNumber: orderNumber,
        activeWarehouseId: effectiveWarehouseId,
        selectedCustomer: state.selectedCustomer,
        selectedCustomerDiscount: state.selectedCustomerDiscount,
        customerDiscountValue: state.customerDiscountValue,
        customerDiscountType: state.customerDiscountType,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> startBookingOrder(
    ApiClient apiClient,
    int companyId,
    int userId,
    int bookingId,
    String guestName, {
    int? staffUserId,
    int? floorPlanTableId,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final newOrderId = await apiClient.createPosOrder(
        companyId,
        userId,
        0,
        null,
        guestName,
        effectiveWarehouseId,
        bookingId: bookingId,
      );
      state = CartState(
        activePosOrderId: newOrderId,
        serviceType: 0,
        serviceStatus: 1,
        floorPlanTableId: floorPlanTableId,
        orderNumber: 'APT- $guestName',
        activeWarehouseId: effectiveWarehouseId,
        bookingId: bookingId,
        bookingStaffId: staffUserId,
      );
      try {
        await apiClient.linkBookingToPosOrder(companyId, bookingId, newOrderId);
      } catch (e) {
        print("Failed to link booking: $e");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  void setWarehouseId(int warehouseId) {
    state = state.copyWith(activeWarehouseId: warehouseId);
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
      final activeTableId = state.floorPlanTableId ?? ref.read(floorPlanTableProvider);
      final _saveOrderNum = ref.read(dailyOrderNumberProvider).toString().padLeft(3, '0');
      String orderNumber = state.orderNumber ?? '${_getPrefix(state.serviceType)} #$_saveOrderNum';
      if (state.orderNumber == null && activeTableId != null) {
        final tables = ref.read(tablesByFloorPlanProvider).value ?? [];
        final table = tables.where((t) => t.id == activeTableId).firstOrNull;
        if (table != null) {
          orderNumber = "ORD- ${table.name}";
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
        "floorPlanTableId": activeTableId,
        "warehouseId": effectiveWarehouseId,
      };

      final headerSuccess = await apiClient.updatePosOrder(
        companyId,
        updateRequest,
      );
      if (headerSuccess) {
        // Preserve full order context (orderNumber, activePosOrderId, table, serviceType, etc.)
        // Only clear the locally-drafted items since they are now committed to the backend.
        state = state.copyWith(items: const []);
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

      // Sync order header (customer, discounts, total) before finalising payment
      final activeTableId = state.floorPlanTableId ?? ref.read(floorPlanTableProvider);
      final _checkoutOrderNum = ref.read(dailyOrderNumberProvider).toString().padLeft(3, '0');
      String orderNumber = state.orderNumber ?? '${_getPrefix(state.serviceType)} #$_checkoutOrderNum';
      if (state.orderNumber == null && activeTableId != null) {
        final tables = ref.read(tablesByFloorPlanProvider).value ?? [];
        final table = tables.where((t) => t.id == activeTableId).firstOrNull;
        if (table != null) orderNumber = "ORD- ${table.name}";
      }
      await apiClient.updatePosOrder(companyId, {
        "id": state.activePosOrderId,
        "userId": userId,
        "number": orderNumber,
        "discount": state.manualCartDiscount,
        "discountType": state.manualCartDiscountType,
        "total": grandTotal,
        "customerId": state.selectedCustomer?.id,
        "serviceType": state.serviceType,
        "serviceStatus": state.serviceStatus,
        "floorPlanTableId": activeTableId,
        "warehouseId": effectiveWarehouseId,
      });

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
        orderNumber: orderNumber,
      );

      final success = await apiClient.checkoutPosOrder(
        companyId,
        userId,
        request,
      );

      if (success) {
        // Auto-complete any linked booking
        if (state.bookingId != null) {
          try {
            await apiClient.updateBookingStatus(companyId, state.bookingId!, 4);
          } catch (_) {
            // Non-fatal: payment succeeded, booking status update failure is acceptable
          }
        }
        clearCart();
        // Brief buffer so the DB write is visible to the subsequent GetAll read.
        await Future.delayed(const Duration(milliseconds: 300));
        await syncOrderNumber(companyId);
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Voids the active POS order: creates a tombstone Document on the backend
  // (preserving the order number so syncOrderNumber can count it), restores
  // stock, then clears the cart and advances the daily counter.
  Future<bool> voidOrder({
    required ApiClient apiClient,
    required int companyId,
  }) async {
    if (state.activePosOrderId == null) return false;
    state = state.copyWith(isLoading: true);
    try {
      final success = await apiClient.voidPosOrder(
        companyId,
        state.activePosOrderId!,
        state.activeWarehouseId ?? 1,
      );
      if (success) {
        clearCart();
        await Future.delayed(const Duration(milliseconds: 300));
        await syncOrderNumber(companyId);
      }
      return success;
    } catch (e) {
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Commits all local items to the backend, updates the order header, then
  // fully clears the cart (order stays open in DB for later retrieval) and
  // advances the daily counter.
  Future<bool> saveAndSuspend({
    required ApiClient apiClient,
    required int companyId,
    required int userId,
    void Function(List<String> warnings)? onWarnings,
  }) async {
    if (state.activePosOrderId == null) return false;
    state = state.copyWith(isLoading: true);
    try {
      if (state.items.isNotEmpty) {
        final response = await apiClient.bulkAddPosOrderItems(
          companyId,
          effectiveWarehouseId,
          state.items,
        );
        if (response['success'] != true) {
          throw Exception(
            response['message'] ?? 'Failed to save items before suspending.',
          );
        }
        final warnings = List<String>.from(response['warnings'] ?? []);
        if (warnings.isNotEmpty) onWarnings?.call(warnings);
      }

      final activeTableId =
          state.floorPlanTableId ?? ref.read(floorPlanTableProvider);
      final num =
          ref.read(dailyOrderNumberProvider).toString().padLeft(3, '0');
      final orderNumber =
          state.orderNumber ?? '${_getPrefix(state.serviceType)} #$num';

      await apiClient.updatePosOrder(companyId, {
        "id": state.activePosOrderId,
        "userId": userId,
        "number": orderNumber,
        "discount": state.manualCartDiscount,
        "discountType": state.manualCartDiscountType,
        "total": grandTotal,
        "customerId": state.selectedCustomer?.id,
        "serviceType": state.serviceType,
        "serviceStatus": state.serviceStatus,
        "floorPlanTableId": activeTableId,
        "warehouseId": effectiveWarehouseId,
      });

      clearCart();
      await Future.delayed(const Duration(milliseconds: 300));
      await syncOrderNumber(companyId);
      return true;
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

// Top-level convenience wrapper — delegates to CartNotifier.syncOrderNumber so
// all counter logic lives in one place. Call this on login / app resume.
Future<void> syncLatestOrderNumber(WidgetRef ref, int companyId) =>
    ref.read(cartProvider.notifier).syncOrderNumber(companyId);

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
