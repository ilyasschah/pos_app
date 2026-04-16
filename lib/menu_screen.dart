import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_client.dart';
import 'product_model.dart';
import 'cart_provider.dart';
import 'auth_provider.dart';
import 'customer_provider.dart';
import 'customer_model.dart';
import 'documents_screen.dart';
import 'company_provider.dart';
import 'my_company_screen.dart';
import 'customers_screen.dart';
import 'product_provider.dart';
import 'users_screen.dart';
import 'reports_screen.dart';
import 'payment_types_screen.dart';
import 'warehouses_screen.dart';
import 'tax_rates_screen.dart';
import 'stock_screen.dart';
import 'product_groups_screen.dart';
import 'currencies_screen.dart';
import 'products_screen.dart';
import 'z_report_screen.dart';
import 'payment_type_provider.dart';
import 'product_group_model.dart';
import 'product_group_provider.dart';

// 1. Current Folder State (Null = Root)
class CurrentGroupNotifier extends Notifier<ProductGroup?> {
  @override
  ProductGroup? build() => null;
}

final currentGroupProvider =
    NotifierProvider<CurrentGroupNotifier, ProductGroup?>(
        () => CurrentGroupNotifier());

// 2. Search Query State
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => "";
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(() => SearchQueryNotifier());

// --- MAIN SCREEN ---
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  void _handleLogout(BuildContext context, WidgetRef ref) {
    // Clear user and cart
    ref.read(currentUserProvider.notifier).state = null;
    ref.read(CartProvider.notifier).clearCart();
    // 🧹 Completely clear the navigation stack and go back to root (User Selection)
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final selectedCompany = ref.watch(selectedCompanyProvider);

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
                  const Icon(Icons.point_of_sale,
                      color: Colors.white, size: 36),
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MyCompanyScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text("Documents"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DocumentsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Customers"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CustomersScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text("Payment Types"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PaymentTypesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text("Stock"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const StockScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: const Text("Currencies"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CurrenciesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.percent),
              title: const Text("Tax Rates"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TaxRatesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.warehouse),
              title: const Text("Warehouses"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const WarehousesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.fastfood),
              title: const Text("Products"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProductsScreen()));
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
                        builder: (_) => const ProductGroupsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: const Text("Users"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const UsersScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text("Reports"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ReportsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_clock),
              title: const Text("End of Day"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const EndOfDayScreen()));
              },
            ),
            const Divider(),

            // Logout
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
          IconButton(
            icon: const Icon(Icons.kitchen, color: Colors.purple),
            tooltip: "Open Kitchen Screen",
            onPressed: () async {
              final Uri url = Uri.parse('/#/kitchen');
              if (!await launchUrl(url, webOnlyWindowName: '_blank')) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Could not launch kitchen screen")));
              }
            },
          ),
          if (MediaQuery.of(context).size.width > 600)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "User: ${currentUser?.displayName ?? 'Unknown'}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
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
          // 🌗 Browser Section: Now uses Theme background instead of hardcoded grey
          Expanded(
            flex: 2,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: const BrowserSection(),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          // 🌗 Cart Section: Now uses Theme surface color instead of hardcoded white
          Expanded(
            flex: 1,
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: const CartSection(),
            ),
          ),
        ],
      ),
    );
  }
}

// --- BROWSER SECTION ---
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

    if (selectedCompany == null) {
      return const Center(
        child: Text("No company selected. Open the menu and pick a company."),
      );
    }

    if (asyncGroups.isLoading || asyncProducts.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (asyncGroups.hasError || asyncProducts.hasError) {
      return const Center(child: Text("Error loading data"));
    }

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
      final visibleGroups =
          allGroups.where((g) => g.parentGroupId == currentGroup?.id).toList();
      final visibleProducts = allProducts
          .where((p) => p.productGroupId == currentGroup?.id)
          .toList();
      itemsToDisplay = [...visibleGroups, ...visibleProducts];
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          // Adaptive background for search bar area
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
                borderSide: BorderSide.none, // Cleaner look
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
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
                            (g) => g.id == currentGroup.parentGroupId);
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
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        Expanded(
          child: itemsToDisplay.isEmpty
              ? Center(
                  child: Text(isSearching
                      ? "No products found matching '$searchQuery'"
                      : "Empty Folder"))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                    childAspectRatio:
                        0.9, // Slightly taller to fit images better
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
                ),
        ),
      ],
    );
  }

  // --- 🎨 REDESIGNED GROUP CARD ---
  Widget _buildGroupCard(
      BuildContext context, WidgetRef ref, ProductGroup group) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fallback if they pick white/transparent in the backend
    final baseColor = (group.flutterColor == Colors.transparent ||
            group.flutterColor == Colors.white)
        ? Colors.blueGrey
        : group.flutterColor;

    final bgColor =
        isDark ? baseColor.withOpacity(0.2) : baseColor.withOpacity(0.15);
    final borderColor =
        isDark ? baseColor.withOpacity(0.5) : baseColor.withOpacity(0.3);

    return InkWell(
      onTap: () {
        ref.read(currentGroupProvider.notifier).state = group;
        ref.read(searchQueryProvider.notifier).state = "";
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: group.imageBytes != null
                  ? Image.memory(group.imageBytes!, fit: BoxFit.cover)
                  : Center(
                      child: Icon(Icons.folder,
                          size: 54,
                          color:
                              isDark ? baseColor.withOpacity(0.8) : baseColor),
                    ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: Text(
                  group.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 🎨 REDESIGNED PRODUCT CARD ---
  Widget _buildProductCard(
      BuildContext context, WidgetRef ref, Product product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => ref.read(CartProvider.notifier).addProduct(product),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[300]!, width: 1),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section (Expands nicely)
            Expanded(
              flex: 3,
              child: product.imageBytes != null
                  ? Image.memory(product.imageBytes!, fit: BoxFit.cover)
                  : Container(
                      color: isDark ? Colors.grey[850] : Colors.grey[100],
                      child: Icon(Icons.inventory_2,
                          size: 48,
                          color: isDark ? Colors.grey[600] : Colors.grey[400]),
                    ),
            ),
            // Text Section
            Expanded(
              flex: 2,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                color: isDark ? Colors.grey[900] : Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${product.price.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: isDark
                            ? Colors.greenAccent[400]
                            : Colors.green[700],
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
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

// --- CART SECTION ---
class CartSection extends ConsumerStatefulWidget {
  const CartSection({super.key});

  @override
  ConsumerState<CartSection> createState() => _CartSectionState();
}

class _CartSectionState extends ConsumerState<CartSection> {
  bool _isProcessing = false;

  void _showCustomerDialog(
      BuildContext context, WidgetRef ref, List<Customer> customers) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Select Customer"),
        content: SizedBox(
          width: 300,
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
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showCheckoutDialog(
      BuildContext context, WidgetRef parentRef, double total) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, child) {
            final paymentTypesAsync = ref.watch(allPaymentTypesProvider);

            return AlertDialog(
              title: const Text("Checkout"),
              content: SizedBox(
                width: 400,
                child: paymentTypesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text("Error loading payment types: $e"),
                  data: (paymentTypes) {
                    if (paymentTypes.isEmpty) {
                      return const Text(
                          "No payment types configured for this company.",
                          style: TextStyle(color: Colors.red));
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Total Due: \$${total.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                        const SizedBox(height: 24),
                        const Text("Select Payment Method:",
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: paymentTypes.map((pt) {
                            return ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16),
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () =>
                                  _submitTransaction(ctx, ref, pt.id, total),
                              icon: const Icon(Icons.payment),
                              label: Text(pt.name,
                                  style: const TextStyle(fontSize: 16)),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child:
                      const Text("Cancel", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitTransaction(BuildContext dialogContext, WidgetRef ref,
      int paymentTypeId, double totalAmount) async {
    final companyId = ref.read(selectedCompanyProvider)?.id;
    final userId = ref.read(currentUserProvider)?.id;
    final customerId = ref.read(currentCustomerProvider)?.id;
    final cartItems = ref.read(CartProvider);

    if (companyId == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Missing Company or User ID.")));
      return;
    }

    Navigator.pop(dialogContext);
    setState(() => _isProcessing = true);

    try {
      final dio = createDio();

      final payload = {
        "companyId": companyId,
        "userId": userId,
        "customerId": customerId,
        "total": totalAmount,
        "items": cartItems
            .map((item) => {
                  "productId": item.product.id,
                  "quantity": item.quantity,
                  "price": item.product.price,
                })
            .toList(),
        "payments": [
          {"paymentTypeId": paymentTypeId, "amount": totalAmount}
        ]
      };

      await dio.post('/Documents/Create', data: payload);
      ref.read(CartProvider.notifier).clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Transaction Saved Successfully!"),
              backgroundColor: Colors.green),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        final errorMsg =
            e.response?.data?['message'] ?? "Failed to process transaction.";
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<Customer>>>(allCustomersProvider,
        (previous, next) {
      final customers = next.value;
      if (customers != null &&
          customers.isNotEmpty &&
          ref.read(currentCustomerProvider) == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {});
      }
    });

    final cartItems = ref.watch(CartProvider);
    final total = ref.watch(CartTotalProvider);
    final currentCustomer = ref.watch(currentCustomerProvider);
    final asyncCustomers = ref.watch(allCustomersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Order Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              asyncCustomers.when(
                loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, __) => const Icon(Icons.error, color: Colors.red),
                data: (customers) => TextButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(currentCustomer?.name ?? "Select Customer"),
                  onPressed: () => _showCustomerDialog(context, ref, customers),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: cartItems.isEmpty
              ? Center(
                  child: Text("Cart is empty",
                      style: TextStyle(
                          color: isDark ? Colors.grey[600] : Colors.grey)))
              : ListView.separated(
                  itemCount: cartItems.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return ListTile(
                      title: Text(item.product.name,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text("x${item.quantity}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("\$${item.total.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 15)),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: isDark ? Colors.redAccent : Colors.red,
                                size: 20),
                            onPressed: () => ref
                                .read(CartProvider.notifier)
                                .removeItem(item.product),
                          )
                        ],
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                  color: isDark ? Colors.black38 : Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, -4))
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total: \$${total.toStringAsFixed(2)}",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.greenAccent[400] : Colors.green)),
              _isProcessing
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: cartItems.isEmpty
                          ? null
                          : () => _showCheckoutDialog(context, ref, total),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          disabledBackgroundColor:
                              isDark ? Colors.grey[800] : Colors.grey[300],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16)),
                      child: const Text("PAY",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    )
            ],
          ),
        ),
      ],
    );
  }
}
