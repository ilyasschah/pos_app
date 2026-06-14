import 'package:flutter/material.dart';
import 'package:pos_app/auth/users_screen.dart';
import 'package:pos_app/cart/payment_types_screen.dart';
import 'package:pos_app/company/my_company_screen.dart';
import 'package:pos_app/customer/customers_screen.dart';
import 'package:pos_app/navigation/nav_widgets.dart';
import 'package:pos_app/dashboard/dashboard_screen.dart';
import 'package:pos_app/document/documents_screen.dart';
import 'package:pos_app/product/products_screen.dart';
import 'package:pos_app/product/product_groups_screen.dart';
import 'package:pos_app/stock/stock_screen.dart';
import 'package:pos_app/promotions/promotions_list_screen.dart';
import 'package:pos_app/reports/reports_screen.dart';
import 'package:pos_app/tax/tax_rates_screen.dart';
import 'package:pos_app/void_reason/void_reason_screen.dart';
import 'package:pos_app/loyalty/loyalty_cards_screen.dart';

class ManagementLayout extends StatefulWidget {
  const ManagementLayout({super.key});

  @override
  State<ManagementLayout> createState() => _ManagementLayoutState();
}

class _ManagementLayoutState extends State<ManagementLayout> {
  int _selectedIndex = 0;
  bool _isSidebarVisible = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 850;
    final showPermanentSidebar = isDesktop && _isSidebarVisible;
    final cs = Theme.of(context).colorScheme;

    void onMenuPressed() {
      if (isDesktop) {
        setState(() => _isSidebarVisible = true);
      } else {
        _scaffoldKey.currentState?.openDrawer();
      }
    }

    final List<Widget> screens = [
      DashboardScreen(onMenuPressed: showPermanentSidebar ? null : onMenuPressed),
      DocumentsScreen(onMenuPressed: showPermanentSidebar ? null : onMenuPressed),
      ProductsScreen(onMenuPressed: showPermanentSidebar ? null : onMenuPressed),
      ProductGroupsScreen(onMenuPressed: showPermanentSidebar ? null : onMenuPressed),
      StockScreen(onMenuPressed: showPermanentSidebar ? null : onMenuPressed),
      ReportsScreen(onMenuPressed: showPermanentSidebar ? null : onMenuPressed),
      CustomersScreen(onMenuPressed: showPermanentSidebar ? null : onMenuPressed),
      PromotionsListScreen(onMenuPressed: showPermanentSidebar ? null : onMenuPressed),
      UsersScreen(onMenuPressed: showPermanentSidebar ? null : onMenuPressed),
      PaymentTypesScreen(onMenuPressed: showPermanentSidebar ? null : onMenuPressed),
      TaxRatesScreen(onMenuPressed: showPermanentSidebar ? null : onMenuPressed),
      MyCompanyScreen(onMenuPressed: showPermanentSidebar ? null : onMenuPressed),
      VoidReasonsScreen(onMenuPressed: showPermanentSidebar ? null : onMenuPressed),
      LoyaltyCardsScreen(onMenuPressed: showPermanentSidebar ? null : onMenuPressed),
    ];

    void handleNavTap(int index) {
      setState(() => _selectedIndex = index);
      // Desktop sidebar stays put on tab select — only manual toggles hide it.
      if (!isDesktop && Scaffold.of(context).hasDrawer) {
        Navigator.pop(context);
      }
    }

    Widget sidebar = Container(
      width: kSidebarW,
      color: context.navSidebarBg,
      child: SafeArea(
        child: Column(
          children: [
            // Static title header — no back navigation, no tap interaction.
            // Padding mirrors NavSidebarHeader so both shells share the same
            // header rhythm. Colours read from adaptive nav tokens so the title
            // stays legible in Light Mode (charcoal) and Dark Mode (near-white).
            Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 8, 20),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Management Portal",
                      style: TextStyle(
                        color: context.navText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isDesktop)
                    IconButton(
                      icon: Icon(Icons.menu_open, color: context.navMuted),
                      tooltip: "Hide Sidebar",
                      onPressed: () =>
                          setState(() => _isSidebarVisible = false),
                    ),
                ],
              ),
            ),

            // Scrollable nav items
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    NavItem(
                      icon: Icons.dashboard,
                      label: "Dashboard",
                      isActive: _selectedIndex == 0,
                      onTap: () => handleNavTap(0),
                    ),
                    NavItem(
                      icon: Icons.description,
                      label: "Documents",
                      isActive: _selectedIndex == 1,
                      onTap: () => handleNavTap(1),
                    ),
                    NavItem(
                      icon: Icons.local_offer,
                      label: "Products",
                      isActive: _selectedIndex == 2,
                      onTap: () => handleNavTap(2),
                    ),
                    NavItem(
                      icon: Icons.folder,
                      label: "Product Groups",
                      isActive: _selectedIndex == 3,
                      onTap: () => handleNavTap(3),
                    ),
                    NavItem(
                      icon: Icons.inventory_2,
                      label: "Stock",
                      isActive: _selectedIndex == 4,
                      onTap: () => handleNavTap(4),
                    ),
                    NavItem(
                      icon: Icons.bar_chart,
                      label: "Reporting",
                      isActive: _selectedIndex == 5,
                      onTap: () => handleNavTap(5),
                    ),
                    NavItem(
                      icon: Icons.people,
                      label: "Customers & suppliers",
                      isActive: _selectedIndex == 6,
                      onTap: () => handleNavTap(6),
                    ),
                    NavItem(
                      icon: Icons.favorite,
                      label: "Promotions",
                      isActive: _selectedIndex == 7,
                      onTap: () => handleNavTap(7),
                    ),
                    NavItem(
                      icon: Icons.vpn_key,
                      label: "Users & security",
                      isActive: _selectedIndex == 8,
                      onTap: () => handleNavTap(8),
                    ),
                    NavItem(
                      icon: Icons.credit_card,
                      label: "Payment types",
                      isActive: _selectedIndex == 9,
                      onTap: () => handleNavTap(9),
                    ),
                    NavItem(
                      icon: Icons.percent,
                      label: "Tax rates",
                      isActive: _selectedIndex == 10,
                      onTap: () => handleNavTap(10),
                    ),
                    NavItem(
                      icon: Icons.business,
                      label: "My company",
                      isActive: _selectedIndex == 11,
                      onTap: () => handleNavTap(11),
                    ),
                    NavItem(
                      icon: Icons.block,
                      label: "Void reasons",
                      isActive: _selectedIndex == 12,
                      onTap: () => handleNavTap(12),
                    ),
                    NavItem(
                      icon: Icons.card_giftcard,
                      label: "Loyalty Cards",
                      isActive: _selectedIndex == 13,
                      onTap: () => handleNavTap(13),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Pinned exit button at the bottom of the sidebar.
            // Tonal "danger" treatment: subtle error-tinted fill + border so it
            // reads as a destructive/exit action without a heavy solid block.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: SizedBox(
                width: double.infinity,
                child: Material(
                  color: cs.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: cs.error.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: cs.error, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            "Exit Management",
                            style: TextStyle(
                              color: cs.error,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: context.navScaffoldBg,
      drawer: isDesktop
          ? null
          : Drawer(backgroundColor: context.navSidebarBg, child: sidebar),
      body: Row(
        children: [
          // Permanent sidebar shows/hides instantly via conditional inclusion.
          if (showPermanentSidebar) sidebar,

          Expanded(
            child: Stack(
              children: [
                // Every management screen renders its own AppBar with a menu
                // leading (no back-arrow), so the shell needs no fallback bar.
                // No auto-hide — the sidebar only changes on manual toggles.
                LazyIndexedStack(
                  index: _selectedIndex,
                  children: screens,
                ),

                // Flat edge toggle to manually bring the sidebar back (desktop).
                if (isDesktop && !_isSidebarVisible)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: NavEdgeToggle(
                        onTap: () =>
                            setState(() => _isSidebarVisible = true),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Text(
          "$title Screen\n(Coming Soon)",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, color: Colors.grey),
        ),
      ),
    );
  }
}
