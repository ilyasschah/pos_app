import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_client.dart';
import 'product_model.dart';
import 'cart_provider.dart';
import 'auth_provider.dart';
import 'customer_provider.dart';
import 'customer_model.dart';
import 'group_model.dart';
import 'documents_screen.dart';
import 'company_provider.dart';
import 'my_company_screen.dart';
import 'customers_screen.dart';
import 'users_screen.dart';
import 'reports_screen.dart';
import 'payment_types_screen.dart';
import 'payment_type_model.dart';
import 'warehouses_screen.dart';
import 'tax_rates_screen.dart';
import 'stock_screen.dart';
import 'product_groups_screen.dart';
// --- PROVIDERS ---

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

// 3. Fetch ALL Groups — filtered by selected company
final groupsProvider = FutureProvider<List<ProductGroup>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];
  final dio = createDio();
  final response = await dio.get(
    'https://localhost:7002/api/ProductGroups/GetAll',
    queryParameters: {'companyId': company.id},
  );
  final data = response.data as List;
  return data.map((json) => ProductGroup.fromJson(json)).toList();
});

// 4. Fetch ALL Products — filtered by selected company
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];
  final dio = createDio();
  final response = await dio.get(
    'https://localhost:7002/api/Products/GetAll',
    queryParameters: {'companyId': company.id},
  );
  final data = response.data as List;
  return data.map((json) => Product.fromJson(json)).toList();
});

// 5. Fetch Payment Types
final paymentTypesProvider = FutureProvider<List<PaymentType>>((ref) async {
  final dio = createDio();
  final response =
      await dio.get('https://localhost:7002/api/PaymentTypes/GetAll');
  final data = response.data as List;
  return data.map((json) => PaymentType.fromJson(json)).toList();
});

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
    final asyncGroups = ref.watch(groupsProvider);
    final asyncProducts = ref.watch(productsProvider);
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
        color: Colors.blue[50],
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder, size: 48, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              group.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
  // Removed the initState and dispose methods completely!

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

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<Customer>>>(allCustomersProvider,
        (previous, next) {
      final customers = next.value;
      if (customers != null &&
          customers.isNotEmpty &&
          ref.read(currentCustomerProvider) == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(currentCustomerProvider.notifier).setDefault(customers);
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
              ElevatedButton(
                onPressed:
                    cartItems.isEmpty ? null : () {/* Trigger Checkout */},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("PAY", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ],
    );
  }
}
