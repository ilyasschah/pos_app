import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_app/menu/open_orders_screen.dart';
import 'package:pos_app/navigation/main_layout.dart';
import 'package:pos_app/product/product_provider.dart';
import 'package:pos_app/product/product_model.dart';
import 'package:pos_app/cart/cart_provider.dart';
import 'package:pos_app/auth/auth_provider.dart';
import 'package:pos_app/customer/customer_provider.dart';
import 'package:pos_app/stock/warehouse_provider.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/menu/discount_dialog.dart';
import 'package:pos_app/product/product_group_model.dart';
import 'package:pos_app/product/product_group_provider.dart';
import 'package:pos_app/cart/checkout_models.dart';
import 'package:pos_app/cart/checkout_dialog.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/tax/tax_provider.dart';
import 'package:pos_app/app_settings/app_settings_model.dart';
import 'package:pos_app/app_settings/app_settings_provider.dart';
import 'package:pos_app/currency/currencies_provider.dart';
import 'package:pos_app/promotions/promotion_provider.dart';
import 'package:pos_app/promotions/promotions_list_screen.dart';
import 'package:pos_app/bookings/bookings_provider.dart';
import 'package:pos_app/floor_plan/floor_plan_table.dart';
import 'package:pos_app/auth/user_model.dart';
import 'package:pos_app/product/product_comment_model.dart';
import 'package:pos_app/product/product_comment_provider.dart';
// import 'package:pos_app/menu/open_orders_screen.dart';
import 'package:pos_app/printer/receipt_printer_service.dart';
import 'package:pos_app/printer/printer_provider.dart';

final currentGroupProvider = StateProvider<ProductGroup?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => "");
final cartWidthProvider = StateProvider<double>((ref) => 350.0);

// --- MAIN SCREEN ---
class MenuScreen extends ConsumerStatefulWidget {
  final bool showAppBarNavigation;
  final VoidCallback? onToggleSidebar;

  const MenuScreen({
    super.key,
    this.showAppBarNavigation = false,
    this.onToggleSidebar,
  });

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final company = ref.read(selectedCompanyProvider);
      if (company != null) {
        final hasActiveOrder = ref.read(cartProvider).activePosOrderId != null;
        if (!hasActiveOrder) {
          syncLatestOrderNumber(ref, company.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final currentCustomer = ref.watch(currentCustomerProvider);
    final asyncCustomers = ref.watch(allCustomersProvider);
    final settings = ref.watch(appSettingsProvider);
    final bookingEnabled =
        settings[SettingKeys.featureBookingEnabled]?.toLowerCase() == 'true';
    final floorPlanEnabled =
        settings[SettingKeys.featureFloorPlanEnabled]?.toLowerCase() == 'true';
    final serviceTypeEnabled =
        settings[SettingKeys.featureServiceTypeEnabled]?.toLowerCase() ==
        'true';
    final serviceStatusEnabled =
        settings[SettingKeys.featureServiceStatusEnabled]?.toLowerCase() ==
        'true';
    final customServiceTypes = ref
        .read(appSettingsProvider.notifier)
        .customServiceTypes;
    final customServiceStatuses = ref
        .read(appSettingsProvider.notifier)
        .customServiceStatuses;
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

    // Sync daily order counter when company changes mid-session
    ref.listen(selectedCompanyProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        final hasActiveOrder = ref.read(cartProvider).activePosOrderId != null;
        if (!hasActiveOrder) {
          syncLatestOrderNumber(ref, next.id);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 62,
        automaticallyImplyLeading: false,
        leading: widget.showAppBarNavigation
            ? IconButton(
                icon: Icon(
                  Icons.menu,
                  size: 26,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: widget.onToggleSidebar,
              )
            : null,
        title: widget.showAppBarNavigation
            ? Text(
                ref.watch(selectedCompanyProvider)?.name ?? 'Branch',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              )
            : null,
        actions: [
          // --- Order Controls ---
          SizedBox(
            height: 46,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  asyncCustomers.when(
                    loading: () => const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (all) {
                      final customers = all.where((c) => c.isCustomer).toList();
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: IconButton(
                          iconSize: 26,
                          icon: const Icon(Icons.person),
                          tooltip: currentCustomer?.name ?? "Select Customer",
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
                                      subtitle: Text(
                                        c.phoneNumber ?? c.email ?? "",
                                      ),
                                      onTap: () {
                                        ref
                                            .read(
                                              currentCustomerProvider.notifier,
                                            )
                                            .setCustomer(c);
                                        final companyId = ref
                                            .read(selectedCompanyProvider)
                                            ?.id;
                                        if (companyId != null) {
                                          ref
                                              .read(cartProvider.notifier)
                                              .setCustomer(companyId, c);
                                        }
                                        Navigator.pop(ctx);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // ── Dynamic Order Type button ──────────────────────────
                  if (serviceTypeEnabled)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ElevatedButton(
                        onPressed: () async {
                          final val = await showDialog<int>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Select Order Type'),
                              contentPadding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                16,
                              ),
                              content: SizedBox(
                                width: 500,
                                child: Row(
                                  children: customServiceTypes
                                      .asMap()
                                      .entries
                                      .expand(
                                        (e) => [
                                          if (e.key > 0)
                                            const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () => Navigator.pop(
                                                ctx,
                                                e.value.id,
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    _kOrderTypePalette[e.key %
                                                        _kOrderTypePalette
                                                            .length],
                                                minimumSize: const Size(0, 100),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                      horizontal: 8,
                                                    ),
                                              ),
                                              child: Text(
                                                e.value.name,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          );
                          if (val == null) return;
                          final companyId = ref
                              .read(selectedCompanyProvider)
                              ?.id;
                          if (val != 0) {
                            if (companyId != null) {
                              await ref
                                  .read(cartProvider.notifier)
                                  .clearFloorPlanTable(
                                    val,
                                    companyId: companyId,
                                  );
                            }
                            if (ref.read(cartProvider).activePosOrderId ==
                                null) {
                              final user = ref.read(currentUserProvider);
                              if (companyId != null && user != null) {
                                try {
                                  await ref
                                      .read(cartProvider.notifier)
                                      .startTablelessOrder(
                                        ApiClient(),
                                        companyId,
                                        user.id,
                                        val,
                                      );
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error creating order: $e',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                          } else {
                            final cart = ref.read(cartProvider);
                            final floorPlanOn =
                                ref
                                    .read(
                                      appSettingsProvider,
                                    )[SettingKeys.featureFloorPlanEnabled]
                                    ?.toLowerCase() ==
                                'true';

                            if (cart.floorPlanTableId == null && floorPlanOn) {
                              final selectedSpace =
                                  await showDialog<FloorPlanTable>(
                                    context: context,
                                    builder: (_) =>
                                        const _SelectAvailableSpaceDialog(),
                                  );
                              if (selectedSpace == null) return;
                              if (!context.mounted) return;

                              final cId = ref.read(selectedCompanyProvider)?.id;
                              final uId =
                                  ref.read(currentUserProvider)?.id ?? 0;
                              if (cId == null) return;

                              final newOrderNumber =
                                  'ORD- ${selectedSpace.name}';

                              await ApiClient().updatePosOrder(cId, {
                                'id': cart.activePosOrderId,
                                'userId': uId,
                                'number': newOrderNumber,
                                'floorPlanTableId': selectedSpace.id,
                                'serviceType': 0,
                                'serviceStatus': cart.serviceStatus,
                                'discount': cart.manualCartDiscount,
                                'discountType': cart.manualCartDiscountType,
                                'total': ref.read(cartTotalProvider),
                                'customerId': cart.selectedCustomer?.id,
                                'warehouseId': cart.activeWarehouseId ?? 1,
                              });

                              if (!context.mounted) return;

                              ref
                                  .read(cartProvider.notifier)
                                  .setOrderContext(
                                    cart.activePosOrderId!,
                                    cart.activeWarehouseId ?? 1,
                                    tableId: selectedSpace.id,
                                    orderNumber: newOrderNumber,
                                  );
                              ref.read(cartProvider.notifier).state = ref
                                  .read(cartProvider)
                                  .copyWith(serviceType: 0);
                            } else {
                              ref
                                  .read(cartProvider.notifier)
                                  .setServiceType(val);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _kOrderTypePalette[customServiceTypes
                                  .indexWhere(
                                    (t) => t.id == cartState.serviceType,
                                  )
                                  .clamp(0, _kOrderTypePalette.length - 1)],
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: Text(
                          customServiceTypes
                                  .where((t) => t.id == cartState.serviceType)
                                  .map((t) => t.name)
                                  .firstOrNull ??
                              'Order Type',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  // ── Dynamic Service Status button ──────────────────────
                  if (serviceStatusEnabled)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.label_outline,
                          size: 15,
                          color: Colors.white,
                        ),
                        label: Text(
                          customServiceStatuses
                                  .where((s) => s.id == cartState.serviceStatus)
                                  .map((s) => s.name)
                                  .firstOrNull ??
                              'Status #${cartState.serviceStatus}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          showDialog<int>(
                            context: context,
                            builder: (ctx) {
                              if (customServiceStatuses.isEmpty) {
                                return AlertDialog(
                                  title: const Text('Service Status'),
                                  content: const Text(
                                    'No service statuses configured.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                );
                              }
                              return AlertDialog(
                                title: const Text('Select Service Status'),
                                contentPadding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  16,
                                ),
                                content: SizedBox(
                                  width: 500,
                                  child: Row(
                                    children: customServiceStatuses
                                        .asMap()
                                        .entries
                                        .expand((e) {
                                          final s = e.value;
                                          return [
                                            if (e.key > 0)
                                              const SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, s.id),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: s.color,
                                                  minimumSize: const Size(
                                                    0,
                                                    100,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 16,
                                                        horizontal: 8,
                                                      ),
                                                ),
                                                child: Text(
                                                  s.name,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ];
                                        })
                                        .toList(),
                                  ),
                                ),
                              );
                            },
                          ).then((val) {
                            if (val != null) {
                              ref.read(cartProvider.notifier).state = cartState
                                  .copyWith(serviceStatus: val);
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              customServiceStatuses
                                  .where((s) => s.id == cartState.serviceStatus)
                                  .map((s) => s.color)
                                  .firstOrNull ??
                              Colors.blueGrey,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  IconButton(
                    iconSize: 26,
                    icon: const Icon(Icons.percent),
                    tooltip: "Discount",
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => const DiscountDialog(),
                    ),
                  ),
                  IconButton(
                    iconSize: 26,
                    icon: const Icon(Icons.receipt),
                    tooltip: "Tax",
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
                  IconButton(
                    iconSize: 26,
                    icon: const Icon(Icons.swap_horiz),
                    tooltip: "Transfer",
                    onPressed: cartState.activePosOrderId == null
                        ? null
                        : () => showDialog(
                            context: context,
                            builder: (_) =>
                                _TransferDialog(cartState: cartState),
                          ),
                  ),

                  IconButton(
                    iconSize: 26,
                    icon: const Icon(Icons.soup_kitchen),
                    tooltip: "Send to Kitchen",
                    onPressed: cartState.items.isEmpty
                        ? null
                        : () async {
                            try {
                              // 1. Await the future directly so the data is
                              //    guaranteed to be loaded (never reads a
                              //    synchronous / stale AsyncValue snapshot).
                              final selections = await ref.read(
                                allPrinterSelectionsProvider.future,
                              );

                              // 2. Find the kitchen printer selection.
                              final kitchenSelection = selections
                                  .where((s) => s.key == 'kitchen_printer')
                                  .firstOrNull;

                              if (kitchenSelection == null ||
                                  !kitchenSelection.isEnabled) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Kitchen printer is not configured or disabled.',
                                      ),
                                    ),
                                  );
                                }
                                return;
                              }

                              // 3. Await the layout settings for that selection.
                              final settings = await ref.read(
                                printerSelectionSettingsByIdProvider(
                                  kitchenSelection.id,
                                ).future,
                              );

                              if (settings == null) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Kitchen printer layout settings not found.',
                                      ),
                                    ),
                                  );
                                }
                                return;
                              }

                              // 4. Gather order context and print.
                              final cashier = ref.read(currentUserProvider);
                              final cartItems = ref.read(cartProvider).items;
                              final serviceLabel =
                                  switch (cartState.serviceType) {
                                    0 => 'Dine In',
                                    1 => 'Takeaway',
                                    _ => 'Order',
                                  };
                              final roundNum = cartItems.isNotEmpty
                                  ? cartItems.first.roundNumber
                                  : 1;

                              await ReceiptPrinterService().printKitchenTicket(
                                orderNumber: cartState.orderNumber ?? 'WALK-IN',
                                cashierName: cashier?.displayName ?? 'Unknown',
                                serviceType: serviceLabel,
                                roundNumber: roundNum,
                                printTime: DateTime.now(),
                                items: cartItems,
                                printerSelection: kitchenSelection,
                                settings: settings,
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Kitchen print error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
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

          // --- Warehouse Switcher (Icon Only) ---
          Consumer(
            builder: (context, ref, child) {
              final selectedWarehouse = ref.watch(selectedWarehouseProvider);
              final warehouses = ref.watch(allWarehousesProvider);

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: PopupMenuButton<int>(
                  tooltip: selectedWarehouse?.name ?? "Select Warehouse",
                  iconSize: 26,
                  icon: const Icon(Icons.warehouse),
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
                  MaterialPageRoute(
                    builder: (_) => const MainLayout(initialIndex: 2),
                  ), // Index 2 is Bookings
                  (route) => false,
                );
              },
              icon: const Icon(Icons.calendar_month, size: 22),
              label: const Text(
                'Bookings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          if (floorPlanEnabled) ...[
            if (bookingEnabled) const SizedBox(width: 4),
            TextButton.icon(
              onPressed: () async {
                final cart = ref.read(cartProvider);
                final companyId = ref.read(selectedCompanyProvider)?.id;

                if (cart.items.isEmpty) {
                  if (cart.activePosOrderId != null && companyId != null) {
                    try {
                      await ApiClient().deletePosOrder(
                        companyId,
                        cart.activePosOrderId!,
                        cart.activeWarehouseId ??
                            ref.read(selectedWarehouseProvider)?.id ??
                            1,
                      );
                    } catch (_) {}
                  }
                  ref.read(cartProvider.notifier).clearCart();
                } else {
                  if (companyId != null) {
                    final user = ref.read(currentUserProvider);
                    try {
                      await ref
                          .read(cartProvider.notifier)
                          .saveAndSuspend(
                            apiClient: ApiClient(),
                            companyId: companyId,
                            userId: user?.id ?? 0,
                          );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not save order: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }
                  }
                }

                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainLayout(initialIndex: 4),
                    ),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.grid_view, size: 22),
              label: Text(
                settings[SettingKeys.tablesButtonLabel] ?? 'Tables',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
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

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        // ── Search bar ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const PhosphorIcon(
                  PhosphorIconsRegular.magnifyingGlass, size: 20),
              fillColor: cs.surfaceContainer,
              filled: true,
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const PhosphorIcon(PhosphorIconsRegular.x, size: 18),
                      onPressed: () =>
                          ref.read(searchQueryProvider.notifier).state = '',
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 16),
            ),
            onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
          ),
        ),

        // ── Breadcrumb ──────────────────────────────────────────────────────
        if (!isSearching && currentGroup != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: cs.surfaceContainerHighest,
            child: Row(
              children: [
                IconButton(
                  icon: const PhosphorIcon(
                      PhosphorIconsRegular.arrowLeft, size: 20),
                  onPressed: () {
                    if (currentGroup.parentGroupId == null) {
                      ref.read(currentGroupProvider.notifier).state = null;
                    } else {
                      try {
                        final parent = allGroups.firstWhere(
                          (g) => g.id == currentGroup.parentGroupId,
                        );
                        ref.read(currentGroupProvider.notifier).state = parent;
                      } catch (_) {
                        ref.read(currentGroupProvider.notifier).state = null;
                      }
                    }
                  },
                ),
                const Gap(4),
                PhosphorIcon(PhosphorIconsRegular.folder,
                    size: 18, color: cs.primary),
                const Gap(8),
                Expanded(
                  child: Text(
                    currentGroup.name,
                    style: tt.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

        // ── Product / group grid ────────────────────────────────────────────
        Expanded(
          child: itemsToDisplay.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PhosphorIcon(
                        isSearching
                            ? PhosphorIconsRegular.magnifyingGlass
                            : PhosphorIconsRegular.tray,
                        size: 56,
                        color: cs.onSurface.withValues(alpha: 0.25),
                      ),
                      const Gap(12),
                      Text(
                        isSearching
                            ? 'No products found for "$searchQuery"'
                            : 'This folder is empty',
                        style: tt.bodyLarge?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.45),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (ctx, constraints) {
                    final maxExtent =
                        (constraints.maxWidth / cols).clamp(100.0, 240.0);
                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: maxExtent,
                        childAspectRatio: 0.82,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: pageItems.length,
                      itemBuilder: (context, index) {
                        final item = pageItems[index];
                        Widget card;
                        if (item is ProductGroup) {
                          card = _buildGroupCard(context, ref, item);
                        } else if (item is Product) {
                          card = _buildProductCard(context, ref, item);
                        } else {
                          return const SizedBox();
                        }
                        return card
                            .animate()
                            .fadeIn(
                                duration: 180.ms,
                                delay: (index * 28).ms)
                            .scale(
                                begin: const Offset(0.94, 0.94),
                                end: const Offset(1, 1),
                                duration: 180.ms,
                                delay: (index * 28).ms);
                      },
                    );
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accent =
        (group.flutterColor == Colors.transparent ||
                group.flutterColor == Colors.white)
            ? cs.primary
            : group.flutterColor;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accent.withValues(alpha: 0.45), width: 1.5),
      ),
      color: cs.surface,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ref.read(currentGroupProvider.notifier).state = group;
          ref.read(searchQueryProvider.notifier).state = '';
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: group.imageBytes != null
                  ? Image.memory(group.imageBytes!, fit: BoxFit.cover)
                  : Container(
                      color: accent.withValues(alpha: 0.1),
                      child: Center(
                        child: PhosphorIcon(
                          PhosphorIconsRegular.folder,
                          size: 52,
                          color: accent.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              color: accent.withValues(alpha: 0.1),
              child: Text(
                group.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final sym = ref.watch(currencySymbolProvider);
    final hasPromo = getActivePromotionCountForProduct(ref, product.id) > 0;

    return InkWell(
      onTap: () async {
        final cartState = ref.read(cartProvider);
        if (cartState.activePosOrderId == null) {
          final floorPlanOn =
              ref
                  .read(
                    appSettingsProvider,
                  )[SettingKeys.featureFloorPlanEnabled]
                  ?.toLowerCase() ==
              'true';
          if (cartState.serviceType != 0 || !floorPlanOn) {
            final companyId = ref.read(selectedCompanyProvider)?.id;
            final user = ref.read(currentUserProvider);
            if (companyId == null || user == null) return;
            try {
              await ref
                  .read(cartProvider.notifier)
                  .startTablelessOrder(
                    ApiClient(),
                    companyId,
                    user.id,
                    cartState.serviceType,
                  );
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error creating order: $e'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
          } else {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please select a Table from the Floor Plan first!',
                ),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }

        if (product.ageRestriction != null) {
          final confirmed = await _showAgeRestrictionDialog(
            context,
            product.ageRestriction!,
          );
          if (!confirmed) return;
        }

        double quantity = 1.0;
        if (!product.isUsingDefaultQuantity) {
          final qty = await _showQuantityInputDialog(
            context,
            product.measurementUnit,
          );
          if (qty == null) return;
          quantity = qty;
        }

        double price = product.price;
        if (product.isPriceChangeAllowed) {
          final p = await _showPriceInputDialog(context, product.price);
          if (p == null) return;
          price = p;
        }

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
        } catch (_) {}

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
          ref
              .read(cartProvider.notifier)
              .addItem(
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
      child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.5), width: 1),
          ),
          color: cs.surfaceContainer,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: product.imageBytes != null
                    ? Image.memory(product.imageBytes!, fit: BoxFit.cover)
                    : Container(
                        color: cs.surfaceContainerHighest,
                        child: Center(
                          child: PhosphorIcon(
                            PhosphorIconsRegular.forkKnife,
                            size: 44,
                            color: cs.onSurface.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                color: cs.surface,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasPromo)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: PhosphorIcon(
                          PhosphorIconsFill.star,
                          size: 14,
                          color: cs.tertiary,
                        ),
                      ),
                    Text(
                      product.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '${product.price.toStringAsFixed(2)} $sym',
                      style: tt.labelMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
    final cs = Theme.of(context).colorScheme;
    final isFirst = currentPage == 0;
    final isLast = currentPage >= totalPages - 1;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        border: Border(
            top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NavButton(
            icon: PhosphorIconsRegular.skipBack,
            tooltip: 'First',
            onTap: isFirst ? null : onFirst,
          ),
          _NavButton(
            icon: PhosphorIconsRegular.caretLeft,
            tooltip: 'Previous',
            onTap: isFirst ? null : onPrevious,
          ),
          const Gap(12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Text(
              '${currentPage + 1} / $totalPages',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
            ),
          ),
          const Gap(12),
          _NavButton(
            icon: PhosphorIconsRegular.caretRight,
            tooltip: 'Next',
            onTap: isLast ? null : onNext,
          ),
          _NavButton(
            icon: PhosphorIconsRegular.skipForward,
            tooltip: 'Last',
            onTap: isLast ? null : onLast,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final enabled = onTap != null;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: PhosphorIcon(
            icon,
            size: 18,
            color: enabled ? cs.primary : cs.onSurface.withValues(alpha: 0.25),
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

    final wasBookingOrder = ref.read(cartProvider).bookingId != null;
    final wasTableOrder = ref.read(cartProvider).floorPlanTableId != null;
    final savedSettings = ref.read(appSettingsProvider);
    final bookingEnabled =
        savedSettings[SettingKeys.featureBookingEnabled]?.toLowerCase() ==
        'true';
    final floorPlanEnabled =
        savedSettings[SettingKeys.featureFloorPlanEnabled]?.toLowerCase() ==
        'true';

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
              content: Text(
                wasBookingOrder
                    ? 'Booking Saved!'
                    : wasTableOrder
                    ? 'Order Saved to Table!'
                    : 'Order Saved!',
              ),
              backgroundColor: Colors.blue,
            ),
          );
        }

        if (wasBookingOrder && bookingEnabled) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const MainLayout(initialIndex: 2),
            ),
            (route) => false,
          );
        } else if (wasTableOrder && floorPlanEnabled) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const MainLayout(initialIndex: 4),
            ),
            (route) => false,
          );
        } else if (bookingEnabled) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const MainLayout(initialIndex: 2),
            ),
            (route) => false,
          );
        } else if (floorPlanEnabled) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const MainLayout(initialIndex: 4),
            ),
            (route) => false,
          );
        } else {
          ref.read(cartProvider.notifier).clearCart();
          await syncLatestOrderNumber(ref, companyId);
        }
      } else {
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
                      ref.read(cartProvider.notifier).setWarehouseId(wh['id']);
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

    final allUsers = ref.watch(allUsersProvider).value ?? [];
    final staffName = cartState.bookingStaffId != null
        ? allUsers
                  .where((u) => u.id == cartState.bookingStaffId)
                  .map((u) => u.displayName)
                  .firstOrNull ??
              'Staff #${cartState.bookingStaffId}'
        : null;
    final guestName = cartState.orderNumber?.replaceFirst('APT- ', '');

    final allRooms = ref.watch(allRoomsProvider).value ?? [];
    final dailyOrderNumber = ref.watch(dailyOrderNumberProvider);
    final String contextLabel;
    if (cartState.bookingId != null) {
      final tableName = cartState.floorPlanTableId != null
          ? allRooms
                .where((t) => t.id == cartState.floorPlanTableId)
                .firstOrNull
                ?.name
          : null;
      final prefix =
          tableName ?? (guestName?.isNotEmpty == true ? guestName! : 'Booking');
      contextLabel = staffName != null ? '$prefix · Staff: $staffName' : prefix;
    } else if (cartState.floorPlanTableId != null) {
      contextLabel =
          allRooms
              .where((t) => t.id == cartState.floorPlanTableId)
              .firstOrNull
              ?.name ??
          'Table #${cartState.floorPlanTableId}';
    } else {
      final stored = cartState.orderNumber;
      if (stored != null && stored.isNotEmpty) {
        contextLabel = stored;
      } else {
        final types = ref.read(appSettingsProvider.notifier).customServiceTypes;
        final prefix =
            types
                .where((t) => t.id == cartState.serviceType)
                .map((t) => t.prefix)
                .firstOrNull ??
            'ORDER';
        contextLabel =
            '$prefix #${dailyOrderNumber.toString().padLeft(3, '0')}';
      }
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
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Booking: ',
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: guestName ?? '—',
                          style: const TextStyle(
                            color: Colors.teal,
                            fontSize: 12,
                          ),
                        ),
                        if (staffName != null) ...[
                          const TextSpan(
                            text: '  ·  Staff: ',
                            style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: staffName,
                            style: const TextStyle(
                              color: Colors.teal,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Refresh order number',
                onPressed: () async {
                  final companyId = ref.read(selectedCompanyProvider)?.id;
                  if (companyId == null) return;
                  ref.invalidate(openOrdersProvider);
                  await Future.delayed(const Duration(milliseconds: 300));
                  await ref
                      .read(cartProvider.notifier)
                      .syncOrderNumber(companyId);
                },
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

                      subtitle: Text("${_formatCartQty(item)} (Tap to modify)"),
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
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
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
                                        final newQty = double.tryParse(
                                          controller.text,
                                        );
                                        if (newQty != null && newQty >= 0) {
                                          ref
                                              .read(cartProvider.notifier)
                                              .addItem(
                                                MenuProduct(
                                                  id: item.productId,
                                                  name: item.productName,
                                                  price: item.price,
                                                  isTaxInclusivePrice: true,
                                                  color: "Transparent",
                                                  stockQuantity: 9999,
                                                  taxes: item.appliedTaxes,
                                                ),
                                                quantity:
                                                    newQty - item.quantity,
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
            color: isDark ? const Color(0xFF1E293B) : Colors.blueGrey[50],
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
                      final wasBookingOrder = cartState.bookingId != null;
                      final wasTableOrder = cartState.floorPlanTableId != null;
                      try {
                        await ApiClient().deletePosOrder(
                          companyId,
                          cartState.activePosOrderId!,
                          cartState.activeWarehouseId ?? 1,
                        );
                        ref.read(cartProvider.notifier).clearCart();
                        await syncLatestOrderNumber(ref, companyId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Order Voided'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          final settings = ref.read(appSettingsProvider);
                          final bookingEnabled =
                              settings[SettingKeys.featureBookingEnabled]
                                  ?.toLowerCase() ==
                              'true';
                          final floorPlanEnabled =
                              settings[SettingKeys.featureFloorPlanEnabled]
                                  ?.toLowerCase() ==
                              'true';
                          int? voidIndex;
                          if (wasBookingOrder && bookingEnabled) {
                            voidIndex = 2;
                          } else if (wasTableOrder && floorPlanEnabled) {
                            voidIndex = 4;
                          } else if (bookingEnabled) {
                            voidIndex = 2;
                          } else if (floorPlanEnabled) {
                            voidIndex = 4;
                          }
                          if (voidIndex != null) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MainLayout(initialIndex: voidIndex!),
                              ),
                              (route) => false,
                            );
                          }
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

// --- Quantity display helper
String _formatCartQty(CartItem item) {
  final qty = item.quantity % 1 == 0
      ? item.quantity.toInt().toString()
      : item.quantity.toStringAsFixed(2);
  if (item.measurementUnit != null && item.measurementUnit!.isNotEmpty) {
    return '$qty ${item.measurementUnit}';
  }
  return 'x$qty';
}

// --- Dialog helpers
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
        decoration: InputDecoration(labelText: 'Quantity', suffixText: unit),
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
        decoration: const InputDecoration(labelText: 'Price', prefixText: '\$'),
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

Future<bool> _showAgeRestrictionDialog(BuildContext context, int minAge) async {
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
    final staffId = widget.cartState.bookingStaffId;
    if (staffId != null) {
      final users = ref.read(allUsersProvider).value ?? [];
      _selectedStaff = users.where((u) => u.id == staffId).firstOrNull;
    }
    final tableId = widget.cartState.floorPlanTableId;
    if (tableId != null) {
      final rooms = ref.read(allRoomsProvider).value ?? [];
      _selectedRoom = rooms.where((r) => r.id == tableId).firstOrNull;
    }
  }

  Future<void> _confirm() async {
    setState(() => _saving = true);
    final companyId = ref.read(selectedCompanyProvider)?.id;
    try {
      final activePosOrderId = widget.cartState.activePosOrderId;
      final bookingId = widget.cartState.bookingId;

      if (activePosOrderId != null && companyId != null) {
        final updateRequest = {
          "id": activePosOrderId,
          "userId":
              _selectedStaff?.id ?? ref.read(currentUserProvider)?.id ?? 0,
          "number": widget.cartState.orderNumber ?? "ORD-TEMP",
          "discount": widget.cartState.manualCartDiscount,
          "discountType": widget.cartState.manualCartDiscountType,
          "total": ref.read(cartTotalProvider),
          "customerId": widget.cartState.selectedCustomer?.id,
          "serviceType": widget.cartState.serviceType,
          "serviceStatus": widget.cartState.serviceStatus,
          "floorPlanTableId": _selectedRoom?.id,
          "warehouseId":
              widget.cartState.activeWarehouseId ??
              ref.read(selectedWarehouseProvider)?.id ??
              1,
        };
        await ApiClient().updatePosOrder(companyId, updateRequest);

        final oldTableId = widget.cartState.floorPlanTableId;
        final newTable = _selectedRoom;
        if (oldTableId != null &&
            newTable != null &&
            oldTableId != newTable.id) {
          try {
            await ApiClient().freeFloorPlanTable(companyId, oldTableId);
          } catch (_) {}
        }

        if (newTable != null) {
          final newOrderNumber = 'ORD- ${newTable.name}';
          ref
              .read(cartProvider.notifier)
              .setOrderContext(
                activePosOrderId,
                widget.cartState.activeWarehouseId ?? 1,
                tableId: newTable.id,
                orderNumber: newOrderNumber,
              );
        }
      }

      if (bookingId != null && companyId != null) {
        await ApiClient().updateBookingResource(
          companyId,
          bookingId,
          userId: _selectedStaff?.id,
          floorPlanTableId: _selectedRoom?.id,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Order Transferred')));
      }

      ref.read(cartProvider.notifier).clearCart();
      ref.invalidate(openOrdersProvider);
      await Future.delayed(const Duration(milliseconds: 300));
      if (companyId != null) {
        await syncLatestOrderNumber(ref, companyId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transfer failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    final roomsAsync = ref.watch(allRoomsProvider);
    final floorPlanOn =
        ref
            .watch(appSettingsProvider)[SettingKeys.featureFloorPlanEnabled]
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
                    const DropdownMenuItem<User?>(
                      value: null,
                      child: Text('Unassigned'),
                    ),
                    ...enabled.map(
                      (u) => DropdownMenuItem<User?>(
                        value: u,
                        child: Text(u.displayName),
                      ),
                    ),
                  ],
                  onChanged: (u) => setState(() => _selectedStaff = u),
                );
              },
            ),
            if (floorPlanOn) ...[
              const SizedBox(height: 16),
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
                      value: null,
                      child: Text('No room'),
                    ),
                    ...rooms.map(
                      (t) => DropdownMenuItem<FloorPlanTable?>(
                        value: t,
                        child: Text(t.name),
                      ),
                    ),
                  ],
                  onChanged: (t) => setState(() => _selectedRoom = t),
                ),
              ),
            ],
            if (widget.cartState.bookingId != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.sync,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
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
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.swap_horiz, color: Colors.white),
          label: const Text(
            'Confirm Transfer',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          onPressed: _saving ? null : _confirm,
        ),
      ],
    );
  }
}

class _SelectAvailableSpaceDialog extends ConsumerWidget {
  const _SelectAvailableSpaceDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final roomsAsync = ref.watch(allRoomsProvider);
    final spaceLabel =
        ref.watch(appSettingsProvider)[SettingKeys.tablesButtonLabel] ??
        'Table';

    return AlertDialog(
      title: Text('Select Available $spaceLabel'),
      contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
      content: SizedBox(
        width: 380,
        child: roomsAsync.when(
          loading: () => const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Error loading spaces: $e',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
          data: (rooms) {
            final free = rooms.where((t) => t.status == 0).toList();
            if (free.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 48,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No free ${spaceLabel.toLowerCase()}s available',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: free.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final t = free[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.15,
                      ),
                      child: Icon(
                        Icons.table_restaurant,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      t.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Navigator.pop(ctx, t),
                  );
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
