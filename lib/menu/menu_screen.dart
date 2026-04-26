import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_app/customer/customers_screen.dart';
import 'package:pos_app/product/product_provider.dart';
import 'package:pos_app/product/product_model.dart';
import 'package:pos_app/cart/cart_provider.dart';
import 'package:pos_app/auth/auth_provider.dart';
import 'package:pos_app/customer/customer_provider.dart';
import 'package:pos_app/stock/warehouse_provider.dart';
import 'package:pos_app/utils/status_helper.dart';
import 'package:pos_app/customer/customer_model.dart';
import 'package:pos_app/document/documents_screen.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/company/my_company_screen.dart';
import 'package:pos_app/menu/discount_dialog.dart';
import 'package:pos_app/auth/users_screen.dart';
import 'package:pos_app/reports/reports_screen.dart';
import 'package:pos_app/cart/payment_types_screen.dart';
import 'package:pos_app/stock/warehouses_screen.dart';
import 'package:pos_app/tax/tax_rates_screen.dart';
import 'package:pos_app/stock/stock_screen.dart';
import 'package:pos_app/product/product_groups_screen.dart';
import 'package:pos_app/currency/currencies_screen.dart';
import 'package:pos_app/product/products_screen.dart';
import 'package:pos_app/reports/z_report_screen.dart';
import 'package:pos_app/product/product_group_model.dart';
import 'package:pos_app/product/product_group_provider.dart';
import 'package:pos_app/floor_plan/floor_plan_screen.dart';
import 'package:pos_app/cart/checkout_models.dart';
import 'package:pos_app/cart/checkout_dialog.dart';
import 'package:pos_app/settings/settings_screen.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/tax/tax_provider.dart';

import 'package:pos_app/promotions/promotion_provider.dart';
import 'package:pos_app/promotions/promotions_list_screen.dart';

final currentGroupProvider = StateProvider<ProductGroup?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => "");
final cartWidthProvider = StateProvider<double>((ref) => 350.0);

// --- MAIN SCREEN ---
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  void _handleLogout(BuildContext context, WidgetRef ref) {
    ref.invalidate(currentUserProvider);
    ref.read(cartProvider.notifier).clearCart();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final selectedCompany = ref.watch(selectedCompanyProvider);

    // ✨ Task 2: Auto-select Walk-In Customer if none selected
    ref.listen(allCustomersProvider, (previous, next) {
      next.whenData((all) {
        final customers = all.where((c) => c.isCustomer).toList();
        final currentCartCustomer = ref.read(cartProvider).selectedCustomer;
        if (currentCartCustomer == null && customers.isNotEmpty) {
          final walkIn = customers.firstWhere(
            (c) => c.code == 'C000',
            orElse: () => customers.first,
          );
          final companyId = ref.read(selectedCompanyProvider)?.id;
          if (companyId != null) {
            ref.read(cartProvider.notifier).setCustomer(companyId, walkIn);
          }
        }
      });
    });

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blueGrey),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.point_of_sale,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedCompany?.name ?? "POS System",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    currentUser?.displayName ?? "",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text("My Company"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyCompanyScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text("Documents"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DocumentsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Customers"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomersScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text("Payment Types"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentTypesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text("Stock"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StockScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: const Text("Currencies"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CurrenciesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.percent),
              title: const Text("Tax Rates"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TaxRatesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.warehouse),
              title: const Text("Warehouses"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WarehousesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.fastfood),
              title: const Text("Products"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_special),
              title: const Text("Product Groups"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductGroupsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text("Promotions"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PromotionsListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: const Text("Users"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UsersScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text("Reports"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_clock),
              title: const Text("End of Day"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EndOfDayScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () => _handleLogout(context, ref),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("POS System"),
        actions: [
          if (ref.watch(activePromotionsProvider).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PromotionsListScreen(),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        "${ref.watch(activePromotionsProvider).length}x Active Promotions",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // --- Warehouse Switcher ---
          Consumer(
            builder: (context, ref, child) {
              final selectedWarehouse = ref.watch(selectedWarehouseProvider);
              final warehouses = ref.watch(allWarehousesProvider);

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: PopupMenuButton<int>(
                  tooltip: "Select Warehouse",
                  onSelected: (id) {
                    warehouses.whenData((list) {
                      final wh = list.firstWhere((w) => w.id == id);
                      ref.read(selectedWarehouseProvider.notifier).state = wh;
                    });
                  },
                  itemBuilder: (ctx) => warehouses.when(
                    data: (list) => list
                        .map(
                          (w) =>
                              PopupMenuItem(value: w.id, child: Text(w.name)),
                        )
                        .toList(),
                    loading: () => [],
                    error: (_, __) => [],
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blueGrey, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warehouse, color: Colors.blueGrey),
                        const SizedBox(width: 8),
                        Text(
                          selectedWarehouse?.name ?? "Warehouse",
                          style: const TextStyle(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.blueGrey,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          TextButton.icon(
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const FloorPlanScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.grid_view, color: Colors.white),
            label: const Text(
              "Tables",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          if (MediaQuery.of(context).size.width > 600)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "User: ${currentUser?.displayName ?? 'Unknown'}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: "Logout",
            onPressed: () => _handleLogout(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: const BrowserSection(),
            ),
          ),
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              final currentWidth = ref.read(cartWidthProvider);
              final screenWidth = MediaQuery.of(context).size.width;
              final maxWidth = screenWidth * 0.5;
              double newWidth = currentWidth - details.delta.dx;
              if (newWidth < 250) newWidth = 250;
              if (newWidth > maxWidth) newWidth = maxWidth;
              ref.read(cartWidthProvider.notifier).state = newWidth;
            },
            child: const MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight,
              child: SizedBox(
                width: 8,
                child: VerticalDivider(width: 8, thickness: 1),
              ),
            ),
          ),
          Container(
            width: ref.watch(cartWidthProvider),
            color: Theme.of(context).colorScheme.surface,
            child: const CartSection(),
          ),
        ],
      ),
    );
  }
}

class BrowserSection extends ConsumerWidget {
  const BrowserSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGroups = ref.watch(allProductGroupsProvider);
    final asyncProducts = ref.watch(allProductsListProvider);
    final currentGroup = ref.watch(currentGroupProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedCompany = ref.watch(selectedCompanyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (selectedCompany == null)
      return const Center(
        child: Text("No company selected. Open the menu and pick a company."),
      );
    if (asyncGroups.isLoading || asyncProducts.isLoading)
      return const Center(child: CircularProgressIndicator());
    if (asyncGroups.hasError || asyncProducts.hasError)
      return const Center(child: Text("Error loading data"));

    final allGroups = asyncGroups.value ?? [];
    final allProducts = asyncProducts.value ?? [];

    List<dynamic> itemsToDisplay = [];
    bool isSearching = searchQuery.isNotEmpty;

    if (isSearching) {
      itemsToDisplay = allProducts.where((p) {
        final query = searchQuery.toLowerCase();
        return p.name.toLowerCase().contains(query) ||
            (p.code?.toLowerCase().contains(query) ?? false);
      }).toList();
    } else {
      final visibleGroups = allGroups
          .where((g) => g.parentGroupId == currentGroup?.id)
          .toList();
      final visibleProducts = allProducts
          .where((p) => p.productGroupId == currentGroup?.id)
          .toList();
      itemsToDisplay = [...visibleGroups, ...visibleProducts];
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search products...",
              prefixIcon: const Icon(Icons.search),
              fillColor: Theme.of(context).cardColor,
              filled: true,
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () =>
                          ref.read(searchQueryProvider.notifier).state = "",
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 12,
              ),
            ),
            onChanged: (value) =>
                ref.read(searchQueryProvider.notifier).state = value,
          ),
        ),
        if (!isSearching && currentGroup != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? Colors.grey[850] : Colors.grey[200],
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 20),
                  onPressed: () {
                    if (currentGroup.parentGroupId == null) {
                      ref.read(currentGroupProvider.notifier).state = null;
                    } else {
                      try {
                        final parent = allGroups.firstWhere(
                          (g) => g.id == currentGroup.parentGroupId,
                        );
                        ref.read(currentGroupProvider.notifier).state = parent;
                      } catch (e) {
                        ref.read(currentGroupProvider.notifier).state = null;
                      }
                    }
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  currentGroup.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: itemsToDisplay.isEmpty
              ? Center(
                  child: Text(
                    isSearching
                        ? "No products found matching '$searchQuery'"
                        : "Empty Folder",
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    // Dynamic crossAxisCount: aim for ~180px per item
                    final crossAxisCount = (constraints.maxWidth / 180)
                        .floor()
                        .clamp(2, 10);

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio:
                            0.85, // Slightly taller for better text visibility
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: itemsToDisplay.length,
                      itemBuilder: (context, index) {
                        final item = itemsToDisplay[index];
                        if (item is ProductGroup)
                          return _buildGroupCard(context, ref, item);
                        if (item is Product)
                          return _buildProductCard(context, ref, item);
                        return const SizedBox();
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    WidgetRef ref,
    ProductGroup group,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        (group.flutterColor == Colors.transparent ||
            group.flutterColor == Colors.white)
        ? Colors.blueGrey
        : group.flutterColor;
    final bgColor = isDark ? baseColor.withAlpha(51) : baseColor.withAlpha(38);
    final borderColor = isDark
        ? baseColor.withAlpha(128)
        : baseColor.withAlpha(76);

    return InkWell(
      onTap: () {
        ref.read(currentGroupProvider.notifier).state = group;
        ref.read(searchQueryProvider.notifier).state = "";
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black45
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: group.imageBytes != null
                  ? Image.memory(group.imageBytes!, fit: BoxFit.cover)
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            baseColor.withValues(alpha: 0.4),
                            baseColor.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.folder_rounded,
                        size: 58,
                        color: isDark
                            ? baseColor.withValues(alpha: 0.9)
                            : baseColor,
                      ),
                    ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.white54,
                ),
                alignment: Alignment.center,
                child: Text(
                  group.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.blueGrey[900],
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        final cartState = ref.read(cartProvider);
        if (cartState.activePosOrderId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a Table from the Floor Plan first!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        try {
          final menuProduct = MenuProduct(
            id: product.id,
            name: product.name,
            price: product.price,
            isTaxInclusivePrice: product.isTaxInclusivePrice,
            color: product.color,
            stockQuantity: 9999,
            taxes: [],
          );
          ref.read(cartProvider.notifier).addItem(menuProduct);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll("Exception: ", "")),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black45
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: product.imageBytes != null
                  ? Image.memory(product.imageBytes!, fit: BoxFit.cover)
                  : Container(
                      color: isDark ? Colors.grey[850] : Colors.grey[50],
                      child: Icon(
                        Icons.restaurant_rounded,
                        size: 48,
                        color: isDark
                            ? Colors.blueGrey[700]
                            : Colors.blueGrey[100],
                      ),
                    ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${product.price.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: isDark ? Colors.greenAccent[400] : Colors.green[800],
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartSection extends ConsumerStatefulWidget {
  const CartSection({super.key});

  @override
  ConsumerState<CartSection> createState() => _CartSectionState();
}

class _CartSectionState extends ConsumerState<CartSection> {
  void _showCustomerDialog(
    BuildContext context,
    WidgetRef ref,
    List<Customer> customers,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Select Customer"),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.separated(
            itemCount: customers.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (ctx, i) {
              final c = customers[i];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(c.name),
                subtitle: Text(c.phoneNumber ?? c.email ?? ""),
                onTap: () {
                  ref.read(currentCustomerProvider.notifier).setCustomer(c);
                  final companyId = ref.read(selectedCompanyProvider)?.id;
                  if (companyId != null) {
                    ref.read(cartProvider.notifier).setCustomer(companyId, c);
                  }
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave(BuildContext context, WidgetRef ref) async {
    final companyId = ref.read(selectedCompanyProvider)?.id;
    if (companyId == null) return;
    final currentUser = ref.read(currentUserProvider);
    final List<String> capturedWarnings = [];

    try {
      final result = await ref
          .read(cartProvider.notifier)
          .saveOrderToServer(
            apiClient: ApiClient(),
            companyId: companyId,
            userId: currentUser?.id ?? 0,
            onWarnings: (warnings) {
              capturedWarnings.addAll(warnings);
            },
          );

      if (!context.mounted) return;

      if (result['success'] == true) {
        if (capturedWarnings.isNotEmpty) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Row(
                children: const [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Text("Stock Warning"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: capturedWarnings
                    .map(
                      (w) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text("• $w"),
                      ),
                    )
                    .toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order Saved to Table!'),
              backgroundColor: Colors.blue,
            ),
          );
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const FloorPlanScreen()),
          (route) => false,
        );
      } else {
        // success == false
        final fallbackWarehouses = result['fallbackWarehouses'] as List?;

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.inventory, color: Colors.orange, size: 28),
                SizedBox(width: 10),
                Text("Inventory Notice"),
              ],
            ),
            content: Text(result['message'] ?? "Unknown inventory error."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              if (fallbackWarehouses != null)
                ...fallbackWarehouses.map(
                  (wh) => ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      // Update active warehouse state
                      ref.read(cartProvider.notifier).setWarehouseId(wh['id']);
                      // Automatically retry save
                      _handleSave(context, ref);
                    },
                    child: Text("Switch to ${wh['name']} & Retry"),
                  ),
                ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.red, size: 28),
                SizedBox(width: 10),
                Text("Error"),
              ],
            ),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("CLOSE"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.watch(cartProvider.notifier);
    final cartItems = cartState.items;
    final currentCustomer = ref.watch(currentCustomerProvider);
    final asyncCustomers = ref.watch(allCustomersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final subtotal = cartNotifier.subtotal;
    final discountTotal = cartNotifier.discountTotal;
    final taxTotal = cartNotifier.taxTotal;
    final grandTotal = cartNotifier.grandTotal;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Order Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              ElevatedButton.icon(
                onPressed: cartItems.isEmpty
                    ? null
                    : () => _handleSave(context, ref),
                icon: const Icon(Icons.save, size: 18, color: Colors.white),
                label: const Text(
                  "SAVE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ),

        // Header actions wrapped for responsiveness
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          children: [
            asyncCustomers.when(
              loading: () => const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, __) => const Icon(Icons.error, color: Colors.red),
              data: (all) {
                final customers = all.where((c) => c.isCustomer).toList();
                return ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 120),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person, size: 16),
                    label: Text(
                      currentCustomer?.name ?? "Select Customer",
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () =>
                        _showCustomerDialog(context, ref, customers),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                );
              },
            ),
            Builder(
              builder: (context) {
                final isSelected = List.generate(
                  3,
                  (i) => cartState.serviceType == i,
                );
                return ToggleButtons(
                  isSelected: isSelected,
                  onPressed: (index) {
                    ref.read(cartProvider.notifier).state = cartState.copyWith(
                      serviceType: index,
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  selectedBorderColor: Colors.blueAccent,
                  fillColor: Colors.blueAccent.withValues(alpha: 0.2),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("Dine In"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("Takeaway"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("Delivery"),
                    ),
                  ],
                );
              },
            ),
            ElevatedButton.icon(
              icon: Icon(
                ServiceStatusHelper.getIcon(cartState.serviceStatus),
                size: 18,
              ),
              label: Text(
                ServiceStatusHelper.getLabel(cartState.serviceStatus),
              ),
              onPressed: () {
                showDialog<int>(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text('Select Service Status'),
                    children: [1, 2, 3].map((status) {
                      return SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, status),
                        child: Row(
                          children: [
                            Icon(ServiceStatusHelper.getIcon(status), size: 18),
                            const SizedBox(width: 8),
                            Text(ServiceStatusHelper.getLabel(status)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ).then((val) {
                  if (val != null) {
                    ref.read(cartProvider.notifier).state = cartState.copyWith(
                      serviceStatus: val,
                    );
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ServiceStatusHelper.getColor(
                  cartState.serviceStatus,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),

        // Action Bar for Discount and Tax
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.percent, size: 16),
                label: const Text("Discount"),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const DiscountDialog(),
                  );
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.receipt, size: 16),
                label: const Text("Tax"),
                onPressed: () {
                  final selectedProductId = cartState.selectedProductId;
                  if (selectedProductId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select an item first"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  final item = cartState.items.firstWhere(
                    (i) => i.productId == selectedProductId,
                  );
                  showDialog(
                    context: context,
                    builder: (_) => _ItemTaxDialog(item: item),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: cartItems.isEmpty
              ? Center(
                  child: Text(
                    "Cart is empty",
                    style: TextStyle(
                      color: isDark ? Colors.grey[600] : Colors.grey,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: cartItems.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final isSelected =
                        cartState.selectedProductId == item.productId;
                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: isDark
                          ? Colors.blue[900]?.withValues(alpha: 0.3)
                          : Colors.blue[50],
                      onTap: () {
                        ref
                            .read(cartProvider.notifier)
                            .setSelectedProduct(item.productId);
                      },
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.appliedTaxes.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withAlpha(38),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.receipt_long,
                                      size: 10,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      "TAX",
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (item.discount > 0)
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withAlpha(38),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.sell,
                                      size: 10,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      "-${item.discountType == 0 ? item.discount.toInt() : item.discount.toStringAsFixed(1)}",
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (item.promotionalDiscount > 0)
                            const Padding(
                              padding: EdgeInsets.only(left: 6.0),
                              child: Text("⭐", style: TextStyle(fontSize: 12)),
                            ),
                        ],
                      ),

                      subtitle: Text(
                        "x${item.quantity.toInt()} (Tap to modify)",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.blueGrey,
                            ),
                            onPressed: () => ref
                                .read(cartProvider.notifier)
                                .decrementItem(item.productId),
                          ),

                          InkWell(
                            onTap: () {
                              final controller = TextEditingController(
                                text: item.quantity.toInt().toString(),
                              );
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Enter Quantity"),
                                  content: TextField(
                                    controller: controller,
                                    keyboardType: TextInputType.number,
                                    autofocus: true,
                                    decoration: const InputDecoration(
                                      labelText: "Quantity",
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        final newQty = double.tryParse(controller.text);
                                        if (newQty != null && newQty >= 0) {
                                          ref.read(cartProvider.notifier).addItem(
                                            MenuProduct(
                                              id: item.productId,
                                              name: item.productName,
                                              price: item.price,
                                              isTaxInclusivePrice: true, // fallback
                                              color: "Transparent",
                                              stockQuantity: 9999,
                                              taxes: item.appliedTaxes,
                                            ),
                                            quantity: newQty - item.quantity,
                                          );
                                        }
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text("Set"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Text(
                              "${item.quantity.toInt()}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.blueGrey,
                            ),
                            onPressed: () => ref
                                .read(cartProvider.notifier)
                                .incrementItem(item.productId),
                          ),
                          const SizedBox(width: 8),
                          // Price
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (item.discount > 0 ||
                                  item.promotionalDiscount > 0)
                                Text(
                                  "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                "\$${((item.price - item.discount - item.promotionalDiscount) * item.quantity).toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      (item.discount > 0 ||
                                          item.promotionalDiscount > 0)
                                      ? Colors.green
                                      : null,
                                ),
                              ),
                            ],
                          ),

                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: isDark ? Colors.redAccent : Colors.red,
                              size: 24,
                            ),
                            onPressed: () => ref
                                .read(cartProvider.notifier)
                                .removeItem(item.productId),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E293B)
                : Colors.blueGrey[50], // Dark Slate Background
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black38 : Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Subtotal", style: TextStyle(fontSize: 16)),
                  Text(
                    "\$${subtotal.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              if (discountTotal > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Item Discounts",
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                      Text(
                        "-\$${discountTotal.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              if (cartState.customerDiscountValue != null &&
                  cartState.customerDiscountValue! > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Customer Discount (${cartState.customerDiscountType == 0 ? '${cartState.customerDiscountValue?.toInt()}%' : '\$${cartState.customerDiscountValue?.toStringAsFixed(2)}'})",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        "-\$${cartNotifier.customerDiscountAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              if (cartState.manualCartDiscount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Cart Discount",
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                      Text(
                        "-\$${cartNotifier.manualCartDiscountAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              if (cartNotifier.promotionalDiscountTotal > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Promotional Discount",
                        style: TextStyle(fontSize: 16, color: Colors.amber),
                      ),
                      Text(
                        "-\$${cartNotifier.promotionalDiscountTotal.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Taxes", style: TextStyle(fontSize: 16)),
                  Text(
                    "\$${taxTotal.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1, thickness: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Due",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.greenAccent[400] : Colors.green,
                    ),
                  ),
                  Text(
                    "\$${grandTotal.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.greenAccent[400] : Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final companyId = ref.read(selectedCompanyProvider)?.id;
                      if (companyId == null ||
                          cartState.activePosOrderId == null)
                        return;
                      try {
                        await ApiClient().deletePosOrder(
                          companyId,
                          cartState.activePosOrderId!,
                          cartState.activeWarehouseId ?? 1,
                        );
                        ref.read(cartProvider.notifier).clearCart();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Order Deleted from Database'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FloorPlanScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        if (context.mounted)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      "VOID",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: cartItems.isEmpty
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const CheckoutDialog(),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: isDark
                          ? Colors.grey[800]
                          : Colors.grey[300],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      "PAY",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ItemTaxDialog extends ConsumerStatefulWidget {
  final CartItem item;
  const _ItemTaxDialog({required this.item});

  @override
  ConsumerState<_ItemTaxDialog> createState() => _ItemTaxDialogState();
}

class _ItemTaxDialogState extends ConsumerState<_ItemTaxDialog> {
  late List<MenuTax> _selectedTaxes;

  @override
  void initState() {
    super.initState();
    _selectedTaxes = List.from(widget.item.appliedTaxes);
  }

  @override
  Widget build(BuildContext context) {
    final allTaxesAsync = ref.watch(allTaxesProvider);

    return AlertDialog(
      title: Text("Taxes: ${widget.item.productName}"),
      content: SizedBox(
        width: double.maxFinite,
        child: allTaxesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text("Error: $e"),
          data: (taxes) {
            if (taxes.isEmpty)
              return const Text("No taxes available in system.");
            return ListView.builder(
              shrinkWrap: true,
              itemCount: taxes.length,
              itemBuilder: (ctx, i) {
                final tax = taxes[i];
                final isSelected = _selectedTaxes.any((t) => t.id == tax.id);

                return CheckboxListTile(
                  title: Text(tax.name),
                  subtitle: Text("${tax.rate}${tax.isFixed ? '' : '%'}"),
                  value: isSelected,
                  activeColor: Colors.pink,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedTaxes.add(
                          MenuTax(
                            id: tax.id,
                            name: tax.name,
                            rate: tax.rate,
                            isFixed: tax.isFixed,
                            isTaxOnTotal: tax.isTaxOnTotal,
                          ),
                        );
                      } else {
                        _selectedTaxes.removeWhere((t) => t.id == tax.id);
                      }
                    });
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            ref
                .read(cartProvider.notifier)
                .updateItemTaxes(widget.item.productId, _selectedTaxes);
            Navigator.pop(context);
          },
          child: const Text("Apply Taxes"),
        ),
      ],
    );
  }
}
