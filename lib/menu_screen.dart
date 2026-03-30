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
import 'payment_type_model.dart';
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

            // My Company — navigates to edit screen, NOT selection screen
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
            // Customers
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
            // Payment Types
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
            // Warehouses
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
              leading: const Icon(Icons.fastfood), // Or Icons.inventory
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
                      builder: (_) => const ProductGroupsScreen()),
                );
              },
            ),
            // Users
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

            // Reports
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

            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                ref.read(currentUserProvider.notifier).state = null;
                ref.read(cartProvider.notifier).clearCart();
                Navigator.of(context).pushReplacementNamed('/');
              },
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
            onPressed: () {
              ref.read(currentUserProvider.notifier).state = null;
              ref.read(cartProvider.notifier).clearCart();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[100],
              child: const BrowserSection(),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
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
          color: Colors.white,
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search products...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () =>
                          ref.read(searchQueryProvider.notifier).state = "",
                    )
                  : null,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
            color: Colors.grey[200],
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
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: itemsToDisplay.length,
                  itemBuilder: (context, index) {
                    final item = itemsToDisplay[index];
                    if (item is ProductGroup) return _buildGroupCard(ref, item);
                    if (item is Product) return _buildProductCard(ref, item);
                    return const SizedBox();
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildGroupCard(WidgetRef ref, ProductGroup group) {
    return InkWell(
      onTap: () {
        ref.read(currentGroupProvider.notifier).state = group;
        ref.read(searchQueryProvider.notifier).state = "";
      },
      child: Card(
        color: group.flutterColor.withOpacity(0.15),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:
              BorderSide(color: group.flutterColor.withOpacity(0.5), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (group.imageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  group.imageBytes!,
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) =>
                      Icon(Icons.folder, size: 48, color: group.flutterColor),
                ),
              )
            else
              Icon(Icons.folder, size: 54, color: group.flutterColor),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                group.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: group.flutterColor == Colors.white
                      ? Colors.black
                      : group.flutterColor
                          .withOpacity(0.9), // Ensures text is readable
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(WidgetRef ref, Product product) {
    return InkWell(
      onTap: () => ref.read(cartProvider.notifier).addProduct(product),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fastfood, size: 40, color: Colors.orange),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                product.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              "\$${product.price.toStringAsFixed(2)}",
              style: TextStyle(color: Colors.grey[700]),
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
        // 👇 WRAP IN A CONSUMER SO IT LISTENS FOR UPDATES!
        return Consumer(
          builder: (context, ref, child) {
            // Now we WATCH the provider, so it updates when the API finishes
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
                              // Trigger the backend API call
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

  // --- NEW: SEND DATA TO BACKEND ---
  Future<void> _submitTransaction(BuildContext dialogContext, WidgetRef ref,
      int paymentTypeId, double totalAmount) async {
    final companyId = ref.read(selectedCompanyProvider)?.id;
    final userId = ref.read(currentUserProvider)?.id;
    final customerId = ref.read(currentCustomerProvider)?.id;
    final cartItems = ref.read(cartProvider);

    if (companyId == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Missing Company or User ID.")));
      return;
    }

    // Close the popup dialog immediately to show loading state
    Navigator.pop(dialogContext);
    setState(() => _isProcessing = true);

    try {
      final dio = createDio();

      // ⚠️ IMPORTANT: Adjust these JSON keys to perfectly match your C# 'CreateDocumentRequest' DTO!
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
      ref.read(cartProvider.notifier).clearCart();

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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // ref.read(currentCustomerProvider.notifier).setDefault(customers);
        });
      }
    });

    final cartItems = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final currentCustomer = ref.watch(currentCustomerProvider);
    final asyncCustomers = ref.watch(allCustomersProvider);

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
              ? const Center(
                  child: Text("Cart is empty",
                      style: TextStyle(color: Colors.grey)))
              : ListView.separated(
                  itemCount: cartItems.length,
                  separatorBuilder: (ctx, i) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return ListTile(
                      title: Text(item.product.name),
                      subtitle: Text("x${item.quantity}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("\$${item.total.toStringAsFixed(2)}"),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.red, size: 16),
                            onPressed: () => ref
                                .read(cartProvider.notifier)
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
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total: \$${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),

              // --- UPDATED PAY BUTTON ---
              _isProcessing
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: cartItems.isEmpty
                          ? null
                          : () => _showCheckoutDialog(context, ref, total),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
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
