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
import 'package:pos_app/app_settings/app_settings_model.dart';
import 'package:pos_app/app_settings/app_settings_provider.dart';
import 'package:pos_app/app_settings/industry_packs.dart';
import 'package:pos_app/currency/currencies_provider.dart';

import 'package:pos_app/promotions/promotion_provider.dart';
import 'package:pos_app/promotions/promotions_list_screen.dart';
import 'package:pos_app/bookings/bookings_screen.dart';
import 'package:pos_app/bookings/bookings_provider.dart';
import 'package:pos_app/floor_plan/floor_plan_table.dart';
import 'package:pos_app/auth/user_model.dart';
import 'package:pos_app/product/product_comment_model.dart';
import 'package:pos_app/product/product_comment_provider.dart';
import 'package:pos_app/menu/open_orders_screen.dart';

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
    final cartState = ref.watch(cartProvider);
    final currentCustomer = ref.watch(currentCustomerProvider);
    final asyncCustomers = ref.watch(allCustomersProvider);
    final settings = ref.watch(appSettingsProvider);
    final bookingEnabled       = settings[SettingKeys.featureBookingEnabled]?.toLowerCase() == 'true';
    final floorPlanEnabled     = settings[SettingKeys.featureFloorPlanEnabled]?.toLowerCase() == 'true';
    final serviceTypeEnabled   = settings[SettingKeys.featureServiceTypeEnabled]?.toLowerCase() == 'true';
    final serviceStatusEnabled = settings[SettingKeys.featureServiceStatusEnabled]?.toLowerCase() == 'true';
    final serviceTypePack   = settings[SettingKeys.appServiceTypePack]   ?? 'Restaurant';
    final serviceStatusPack = settings[SettingKeys.appServiceStatusPack] ?? 'Restaurant';
    final orderTypes  = IndustryPacks.getOrderTypes(serviceTypePack);
    final svcStatuses = IndustryPacks.getServiceStatuses(serviceStatusPack);

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
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text("Open Orders"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const OpenOrdersScreen()),
                );
              },
            ),
            const Divider();
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
          // --- Order Controls ---
          SizedBox(
            height: kToolbarHeight - 16,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  asyncCustomers.when(
                    loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (all) {
                      final customers = all.where((c) => c.isCustomer).toList();
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.person, size: 15),
                          label: Text(
                            currentCustomer?.name ?? "Customer",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () => showDialog(
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
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      );
                    },
                  ),
                  // ── Dynamic Order Type button ──────────────────────────
                  if (serviceTypeEnabled) Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ElevatedButton(
                      onPressed: () async {
                        final val = await showDialog<int>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Select Order Type'),
                            contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                            content: SizedBox(
                              width: 500,
                              child: Row(
                                children: orderTypes.asMap().entries.expand((e) => [
                                  if (e.key > 0) const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, e.key),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _kOrderTypePalette[e.key % _kOrderTypePalette.length],
                                        minimumSize: const Size(0, 100),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                      ),
                                      child: Text(
                                        e.value,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ]).toList(),
                              ),
                            ),
                          ),
                        );
                        if (val == null) return;
                        if (val != 0) {
                          ref.read(cartProvider.notifier).clearFloorPlanTable(val);
                          if (ref.read(cartProvider).activePosOrderId == null) {
                            final companyId = ref.read(selectedCompanyProvider)?.id;
                            final user = ref.read(currentUserProvider);
                            if (companyId != null && user != null) {
                              try {
                                await ref.read(cartProvider.notifier).startTablelessOrder(ApiClient(), companyId, user.id, val);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error creating order: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            }
                          }
                        } else {
                          ref.read(cartProvider.notifier).state = ref.read(cartProvider).copyWith(serviceType: val);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kOrderTypePalette[cartState.serviceType % _kOrderTypePalette.length],
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        cartState.serviceType < orderTypes.length ? orderTypes[cartState.serviceType] : 'Order Type',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  // ── Dynamic Service Status button ──────────────────────
                  if (serviceStatusEnabled) Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ElevatedButton.icon(
                      icon: Icon(ServiceStatusHelper.getIcon(cartState.serviceStatus), size: 15),
                      label: Text(
                        svcStatuses
                            .where((s) => s['id'] == cartState.serviceStatus)
                            .map((s) => s['label'] as String)
                            .firstOrNull ?? ServiceStatusHelper.getLabel(cartState.serviceStatus),
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () {
                        final enabled = svcStatuses;
                        showDialog<int>(
                          context: context,
                          builder: (ctx) {
                            if (enabled.isEmpty) {
                              return AlertDialog(
                                title: const Text('Service Status'),
                                content: const Text('No service statuses configured.'),
                                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
                              );
                            }
                            return AlertDialog(
                              title: const Text('Select Service Status'),
                              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                              content: SizedBox(
                                width: 500,
                                child: Row(
                                  children: enabled.asMap().entries.expand((e) {
                                    final s     = e.value;
                                    final id    = s['id'] as int? ?? 0;
                                    final label = s['label'] as String? ?? 'Status';
                                    final color = _colorFromName(s['color'] as String? ?? '');
                                    return [
                                      if (e.key > 0) const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => Navigator.pop(ctx, id),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: color,
                                            minimumSize: const Size(0, 100),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                          ),
                                          child: Text(
                                            label,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ];
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ).then((val) {
                          if (val != null) {
                            ref.read(cartProvider.notifier).state = cartState.copyWith(serviceStatus: val);
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: svcStatuses
                            .where((s) => s['id'] == cartState.serviceStatus)
                            .map((s) => _colorFromName(s['color'] as String? ?? ''))
                            .firstOrNull ?? ServiceStatusHelper.getColor(cartState.serviceStatus),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.percent, color: Colors.white),
                    tooltip: "Discount",
                    onPressed: () => showDialog(context: context, builder: (_) => const DiscountDialog()),
                  ),
                  IconButton(
                    icon: const Icon(Icons.receipt, color: Colors.white),
                    tooltip: "Tax",
                    onPressed: () {
                      final selectedProductId = cartState.selectedProductId;
                      if (selectedProductId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please select an item first"), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      final item = cartState.items.firstWhere((i) => i.productId == selectedProductId);
                      showDialog(context: context, builder: (_) => _ItemTaxDialog(item: item));
                    },
                  ),
                  if (floorPlanEnabled || bookingEnabled)
                    IconButton(
                      icon: const Icon(Icons.swap_horiz, color: Colors.white),
                      tooltip: "Transfer",
                      onPressed: cartState.activePosOrderId == null
                          ? null
                          : () => showDialog(
                                context: context,
                                builder: (_) => _TransferDialog(cartState: cartState),
                              ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
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

          if (bookingEnabled)
            TextButton.icon(
              onPressed: () {
                ref.read(cartProvider.notifier).clearCart();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingsScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.calendar_month, color: Colors.white),
              label: const Text(
                'Bookings',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          if (floorPlanEnabled) ...[
            if (bookingEnabled)
              const SizedBox(width: 4),
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
              label: Text(
                settings[SettingKeys.tablesButtonLabel] ?? 'Tables',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
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

// Colour palette cycled by order-type index (no colour in the JSON for order types).
const _kOrderTypePalette = [
  Colors.indigo,
  Colors.deepOrange,
  Colors.green,
  Colors.purple,
  Colors.teal,
  Colors.brown,
];

// Maps a colour-name string (from the service-status JSON) to a Flutter Color.
Color _colorFromName(String name) {
  switch (name.toLowerCase()) {
    case 'blue':   return Colors.blue;
    case 'orange': return Colors.orange;
    case 'teal':   return Colors.teal;
    case 'green':  return Colors.green;
    case 'purple': return Colors.purple;
    case 'red':    return Colors.red;
    case 'indigo': return Colors.indigo;
    case 'amber':  return Colors.amber;
    case 'pink':   return Colors.pink;
    case 'grey':   return Colors.grey;
    default:       return Colors.blueGrey;
  }
}

class BrowserSection extends ConsumerStatefulWidget {
  const BrowserSection({super.key});

  @override
  ConsumerState<BrowserSection> createState() => _BrowserSectionState();
}

class _BrowserSectionState extends ConsumerState<BrowserSection> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    ref.listen(currentGroupProvider, (_, __) {
      if (mounted) setState(() => _currentPage = 0);
    });
    ref.listen(searchQueryProvider, (_, __) {
      if (mounted) setState(() => _currentPage = 0);
    });

    final asyncGroups = ref.watch(allProductGroupsProvider);
    final asyncProducts = ref.watch(allProductsListProvider);
    final currentGroup = ref.watch(currentGroupProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedCompany = ref.watch(selectedCompanyProvider);
    final settings = ref.watch(appSettingsProvider);
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
        if (!p.isEnabled) return false;
        final query = searchQuery.toLowerCase();
        return p.name.toLowerCase().contains(query) ||
            (p.code?.toLowerCase().contains(query) ?? false);
      }).toList();
    } else {
      final visibleGroups = allGroups
          .where((g) => g.parentGroupId == currentGroup?.id)
          .toList();
      final visibleProducts = allProducts
          .where((p) => p.productGroupId == currentGroup?.id && p.isEnabled)
          .toList();
      itemsToDisplay = [...visibleGroups, ...visibleProducts];
    }

    final cols = int.tryParse(settings[SettingKeys.menuGridCols] ?? '4') ?? 4;
    final rows = int.tryParse(settings[SettingKeys.menuGridRows] ?? '4') ?? 4;
    final itemsPerPage = cols * rows;
    final totalPages = itemsToDisplay.isEmpty
        ? 1
        : ((itemsToDisplay.length + itemsPerPage - 1) ~/ itemsPerPage);
    final safePage = _currentPage.clamp(0, totalPages - 1);
    final pageStart = safePage * itemsPerPage;
    final pageEnd = (pageStart + itemsPerPage).clamp(0, itemsToDisplay.length);
    final pageItems = itemsToDisplay.sublist(pageStart, pageEnd);

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
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: pageItems.length,
                  itemBuilder: (context, index) {
                    final item = pageItems[index];
                    if (item is ProductGroup)
                      return _buildGroupCard(context, ref, item);
                    if (item is Product)
                      return _buildProductCard(context, ref, item);
                    return const SizedBox();
                  },
                ),
        ),
        _PaginationBar(
          currentPage: safePage,
          totalPages: totalPages,
          onFirst: () => setState(() => _currentPage = 0),
          onPrevious: () => setState(() => _currentPage = safePage - 1),
          onNext: () => setState(() => _currentPage = safePage + 1),
          onLast: () => setState(() => _currentPage = totalPages - 1),
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
    final sym = ref.watch(currencySymbolProvider);

    return InkWell(
      onTap: () async {
        final cartState = ref.read(cartProvider);
        if (cartState.activePosOrderId == null) {
          final floorPlanOn = ref.read(appSettingsProvider)[SettingKeys.featureFloorPlanEnabled]
                  ?.toLowerCase() ==
              'true';
          if (cartState.serviceType != 0 || !floorPlanOn) {
            // Walk-in / Takeaway / Delivery (or floor plan disabled) — auto-create a tableless order
            final companyId = ref.read(selectedCompanyProvider)?.id;
            final user = ref.read(currentUserProvider);
            if (companyId == null || user == null) return;
            try {
              await ref.read(cartProvider.notifier).startTablelessOrder(
                ApiClient(),
                companyId,
                user.id,
                cartState.serviceType,
              );
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error creating order: $e'), backgroundColor: Colors.red),
              );
              return;
            }
          } else {
            // Dine-In with floor plan enabled — a table must be selected first
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a Table from the Floor Plan first!'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }

        // Step 2: Age restriction warning
        if (product.ageRestriction != null) {
          final confirmed = await _showAgeRestrictionDialog(
            context,
            product.ageRestriction!,
          );
          if (!confirmed) return;
        }

        // Step 3: Custom quantity when isUsingDefaultQuantity is false
        double quantity = 1.0;
        if (!product.isUsingDefaultQuantity) {
          final qty = await _showQuantityInputDialog(
            context,
            product.measurementUnit,
          );
          if (qty == null) return;
          quantity = qty;
        }

        // Step 4: Price change when isPriceChangeAllowed is true
        double price = product.price;
        if (product.isPriceChangeAllowed) {
          final p = await _showPriceInputDialog(context, product.price);
          if (p == null) return;
          price = p;
        }

        // Step 5: Product comments / modifiers
        String? comment;
        try {
          final comments = await ref.read(
            productCommentsProvider(product.id).future,
          );
          if (comments.isNotEmpty) {
            if (!context.mounted) return;
            final result = await showDialog<String?>(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => _ProductCommentsDialog(
                productName: product.name,
                predefinedComments: comments,
              ),
            );
            if (result == null) return;
            comment = result.trim().isEmpty ? null : result.trim();
          }
        } catch (_) {
          // Proceed without comments if fetch fails
        }

        if (!context.mounted) return;
        try {
          final menuProduct = MenuProduct(
            id: product.id,
            name: product.name,
            price: price,
            isTaxInclusivePrice: product.isTaxInclusivePrice,
            color: product.color,
            stockQuantity: 9999,
            taxes: [],
            isEnabled: product.isEnabled,
            ageRestriction: product.ageRestriction,
            isPriceChangeAllowed: product.isPriceChangeAllowed,
            isUsingDefaultQuantity: product.isUsingDefaultQuantity,
            measurementUnit: product.measurementUnit,
          );
          ref.read(cartProvider.notifier).addItem(
            menuProduct,
            quantity: quantity,
            comment: comment,
            measurementUnit: product.measurementUnit,
          );
        } catch (e) {
          if (!context.mounted) return;
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            product.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (getActivePromotionCountForProduct(ref, product.id) > 0)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.star, color: Colors.amber, size: 16),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${product.price.toStringAsFixed(2)} $sym",
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

// ─────────────────────────────────────────────────────────────────────────────
// PAGINATION BAR
// ─────────────────────────────────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onFirst;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onLast;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onFirst,
    required this.onPrevious,
    required this.onNext,
    required this.onLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFirst = currentPage == 0;
    final isLast = currentPage >= totalPages - 1;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NavButton(label: '<<', tooltip: 'First', onTap: isFirst ? null : onFirst),
          _NavButton(label: '<', tooltip: 'Previous', onTap: isFirst ? null : onPrevious),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Page ${currentPage + 1} of $totalPages',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          _NavButton(label: '>', tooltip: 'Next', onTap: isLast ? null : onNext),
          _NavButton(label: '>>', tooltip: 'Last', onTap: isLast ? null : onLast),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final String tooltip;
  final VoidCallback? onTap;

  const _NavButton({
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onTap != null;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: enabled ? theme.colorScheme.primary : theme.disabledColor,
            ),
          ),
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
  Future<void> _handleSave(BuildContext context, WidgetRef ref) async {
    final companyId = ref.read(selectedCompanyProvider)?.id;
    if (companyId == null) return;
    final currentUser = ref.read(currentUserProvider);
    final List<String> capturedWarnings = [];

    // Capture routing context before saveOrderToServer clears the cart
    final wasBookingOrder  = ref.read(cartProvider).bookingId != null;
    final wasTableOrder    = ref.read(cartProvider).floorPlanTableId != null;
    final savedSettings    = ref.read(appSettingsProvider);
    final floorPlanEnabled = savedSettings[SettingKeys.featureFloorPlanEnabled]?.toLowerCase() == 'true';

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
            SnackBar(
              content: Text(wasBookingOrder
                  ? 'Booking Saved!'
                  : wasTableOrder
                      ? 'Order Saved to Table!'
                      : 'Order Saved!'),
              backgroundColor: Colors.blue,
            ),
          );
        }

        if (wasBookingOrder) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const BookingsScreen()),
            (route) => false,
          );
        } else if (wasTableOrder || floorPlanEnabled) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const FloorPlanScreen()),
            (route) => false,
          );
        }
        // else: walk-in with both features off — stay on MenuScreen
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final subtotal = cartNotifier.subtotal;
    final discountTotal = cartNotifier.discountTotal;
    final taxTotal = cartNotifier.taxTotal;
    final grandTotal = cartNotifier.grandTotal;
    final sym = ref.watch(currencySymbolProvider);

    // Booking banner data
    final allUsers = ref.watch(allUsersProvider).value ?? [];
    final staffName = cartState.bookingStaffId != null
        ? allUsers
            .where((u) => u.id == cartState.bookingStaffId)
            .map((u) => u.displayName)
            .firstOrNull ?? 'Staff #${cartState.bookingStaffId}'
        : null;
    final guestName = cartState.orderNumber?.replaceFirst('APT- ', '');

    // Dynamic context label
    final allRooms = ref.watch(allRoomsProvider).value ?? [];
    final dailyOrderNumber = ref.watch(dailyOrderNumberProvider);
    final String contextLabel;
    if (cartState.bookingId != null) {
      final tableName = cartState.floorPlanTableId != null
          ? allRooms.where((t) => t.id == cartState.floorPlanTableId).firstOrNull?.name
          : null;
      final prefix = tableName ?? (guestName?.isNotEmpty == true ? guestName! : 'Booking');
      contextLabel = staffName != null ? '$prefix · Staff: $staffName' : prefix;
    } else if (cartState.floorPlanTableId != null) {
      contextLabel = allRooms
              .where((t) => t.id == cartState.floorPlanTableId)
              .firstOrNull
              ?.name ??
          'Table #${cartState.floorPlanTableId}';
    } else {
      contextLabel = 'Order #$dailyOrderNumber';
    }

    return Column(
      children: [
        if (cartState.bookingId != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: Colors.teal.withValues(alpha: 0.15),
            child: Row(
              children: [
                const Icon(Icons.event, size: 16, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: [
                      const TextSpan(
                        text: 'Booking: ',
                        style: TextStyle(
                            color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      TextSpan(
                        text: guestName ?? '—',
                        style: const TextStyle(
                            color: Colors.teal, fontSize: 12),
                      ),
                      if (staffName != null) ...[
                        const TextSpan(
                          text: '  ·  Staff: ',
                          style: TextStyle(
                              color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        TextSpan(
                          text: staffName,
                          style: const TextStyle(
                              color: Colors.teal, fontSize: 12),
                        ),
                      ],
                    ]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  contextLabel,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
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
                        "${_formatCartQty(item)} (Tap to modify)",
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
                                text: item.quantity % 1 == 0
                                    ? item.quantity.toInt().toString()
                                    : item.quantity.toStringAsFixed(2),
                              );
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Enter Quantity"),
                                  content: TextField(
                                    controller: controller,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      labelText: "Quantity",
                                      suffixText: item.measurementUnit,
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
                              _formatCartQty(item),
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
                                  "${(item.price * item.quantity).toStringAsFixed(2)} $sym",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                "${((item.price - item.discount - item.promotionalDiscount) * item.quantity).toStringAsFixed(2)} $sym",
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
                    "${subtotal.toStringAsFixed(2)} $sym",
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
                        "-${discountTotal.toStringAsFixed(2)} $sym",
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
                        "Customer Discount (${cartState.customerDiscountType == 0 ? '${cartState.customerDiscountValue?.toInt()}%' : '${cartState.customerDiscountValue?.toStringAsFixed(2)} $sym'})",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        "-${cartNotifier.customerDiscountAmount.toStringAsFixed(2)} $sym",
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
                        "-${cartNotifier.manualCartDiscountAmount.toStringAsFixed(2)} $sym",
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
                        "-${cartNotifier.promotionalDiscountTotal.toStringAsFixed(2)} $sym",
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
                    "${taxTotal.toStringAsFixed(2)} $sym",
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
                    "${grandTotal.toStringAsFixed(2)} $sym",
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

// --- Quantity display helper (top-level so both BrowserSection and CartSection can use it) ---
String _formatCartQty(CartItem item) {
  final qty = item.quantity % 1 == 0
      ? item.quantity.toInt().toString()
      : item.quantity.toStringAsFixed(2);
  if (item.measurementUnit != null && item.measurementUnit!.isNotEmpty) {
    return '$qty ${item.measurementUnit}';
  }
  return 'x$qty';
}

// --- Dialog helpers (called from _buildProductCard async onTap) ---
Future<double?> _showQuantityInputDialog(
  BuildContext context,
  String? unit,
) async {
  final controller = TextEditingController();
  return showDialog<double?>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Enter Quantity'),
      content: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Quantity',
          suffixText: unit,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final val = double.tryParse(controller.text);
            if (val != null && val > 0) Navigator.pop(ctx, val);
          },
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}

Future<double?> _showPriceInputDialog(
  BuildContext context,
  double defaultPrice,
) async {
  final controller = TextEditingController(
    text: defaultPrice.toStringAsFixed(2),
  );
  return showDialog<double?>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Set Sale Price'),
      content: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Price',
          prefixText: '\$',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final val = double.tryParse(controller.text);
            if (val != null && val >= 0) Navigator.pop(ctx, val);
          },
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}

Future<bool> _showAgeRestrictionDialog(
  BuildContext context,
  int minAge,
) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
          const SizedBox(width: 8),
          const Text('Age Restriction'),
        ],
      ),
      content: Text(
        'This product requires customers to be at least $minAge years old.\n\n'
        'Please confirm the customer meets this requirement before proceeding.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('Confirm ($minAge+)'),
        ),
      ],
    ),
  );
  return result ?? false;
}

// --- Product comments / modifiers dialog ---
class _ProductCommentsDialog extends StatefulWidget {
  final String productName;
  final List<ProductComment> predefinedComments;

  const _ProductCommentsDialog({
    required this.productName,
    required this.predefinedComments,
  });

  @override
  State<_ProductCommentsDialog> createState() => _ProductCommentsDialogState();
}

class _ProductCommentsDialogState extends State<_ProductCommentsDialog> {
  final Set<int> _selectedIds = {};
  final TextEditingController _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Comments: ${widget.productName}'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...widget.predefinedComments.map(
                (c) => SwitchListTile(
                  title: Text(c.comment),
                  value: _selectedIds.contains(c.id),
                  onChanged: (val) => setState(() {
                    val ? _selectedIds.add(c.id) : _selectedIds.remove(c.id);
                  }),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _customController,
                decoration: const InputDecoration(
                  labelText: 'Custom comment',
                  hintText: 'Add a note...',
                  prefixIcon: Icon(Icons.edit_note),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final parts = widget.predefinedComments
                .where((c) => _selectedIds.contains(c.id))
                .map((c) => c.comment)
                .toList();
            final custom = _customController.text.trim();
            if (custom.isNotEmpty) parts.add(custom);
            Navigator.pop(context, parts.join(', '));
          },
          child: const Text('Add to Cart'),
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

// ────────────────────────────────────────────────────────────────────────────
// Transfer Dialog — reassign staff and/or room for the active order/booking
// ────────────────────────────────────────────────────────────────────────────
class _TransferDialog extends ConsumerStatefulWidget {
  final CartState cartState;

  const _TransferDialog({required this.cartState});

  @override
  ConsumerState<_TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends ConsumerState<_TransferDialog> {
  User? _selectedStaff;
  FloorPlanTable? _selectedRoom;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Pre-select current staff if bookingStaffId is set
    final staffId = widget.cartState.bookingStaffId;
    if (staffId != null) {
      final users = ref.read(allUsersProvider).value ?? [];
      _selectedStaff = users.where((u) => u.id == staffId).firstOrNull;
    }
    // Pre-select current room if floorPlanTableId is set
    final tableId = widget.cartState.floorPlanTableId;
    if (tableId != null) {
      final rooms = ref.read(allRoomsProvider).value ?? [];
      _selectedRoom = rooms.where((r) => r.id == tableId).firstOrNull;
    }
  }

  Future<void> _confirm() async {
    setState(() => _saving = true);
    try {
      // Update CartState
      ref.read(cartProvider.notifier).state = widget.cartState.copyWith(
        bookingStaffId: _selectedStaff?.id,
        floorPlanTableId: _selectedRoom?.id,
      );

      // Sync backend if this order is linked to a booking
      final bookingId = widget.cartState.bookingId;
      final companyId = ref.read(selectedCompanyProvider)?.id;
      if (bookingId != null && companyId != null) {
        await ApiClient().updateBookingResource(
          companyId,
          bookingId,
          userId: _selectedStaff?.id,
          floorPlanTableId: _selectedRoom?.id,
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transfer failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync   = ref.watch(allUsersProvider);
    final roomsAsync   = ref.watch(allRoomsProvider);
    final floorPlanOn  = ref.watch(appSettingsProvider)[SettingKeys.featureFloorPlanEnabled]
            ?.toLowerCase() ==
        'true';

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.swap_horiz),
          SizedBox(width: 8),
          Text('Transfer Order'),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Staff dropdown
            usersAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (users) {
                final enabled = users.where((u) => u.isEnabled).toList();
                return DropdownButtonFormField<User?>(
                  initialValue: _selectedStaff,
                  decoration: const InputDecoration(
                    labelText: 'Assign Staff',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<User?>(value: null, child: Text('Unassigned')),
                    ...enabled.map((u) => DropdownMenuItem<User?>(
                          value: u,
                          child: Text(u.displayName),
                        )),
                  ],
                  onChanged: (u) => setState(() => _selectedStaff = u),
                );
              },
            ),
            if (floorPlanOn) ...[
              const SizedBox(height: 16),
              // Room / resource dropdown
              roomsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
                data: (rooms) => DropdownButtonFormField<FloorPlanTable?>(
                  initialValue: _selectedRoom,
                  decoration: const InputDecoration(
                    labelText: 'Assign Room / Resource',
                    prefixIcon: Icon(Icons.meeting_room),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<FloorPlanTable?>(
                        value: null, child: Text('No room')),
                    ...rooms.map((t) => DropdownMenuItem<FloorPlanTable?>(
                          value: t,
                          child: Text(t.name),
                        )),
                  ],
                  onChanged: (t) => setState(() => _selectedRoom = t),
                ),
              ),
            ],
            if (widget.cartState.bookingId != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.sync, size: 14,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Calendar booking will be updated automatically.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          icon: _saving
              ? const SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.swap_horiz, color: Colors.white),
          label: const Text('Confirm Transfer',
              style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          onPressed: _saving ? null : _confirm,
        ),
      ],
    );
  }
}
