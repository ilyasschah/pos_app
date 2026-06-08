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

    void onMenuPressed() {
      if (isDesktop) {
        setState(() => _isSidebarVisible = true);
      } else {
        _scaffoldKey.currentState?.openDrawer();
      }
    }

    final List<Widget> screens = [
      const DashboardScreen(),
      const DocumentsScreen(),
      ProductsScreen(onMenuPressed: showPermanentSidebar ? null : onMenuPressed),
      ProductGroupsScreen(onMenuPressed: showPermanentSidebar ? null : onMenuPressed),
      const StockScreen(),
      const ReportsScreen(),
      const CustomersScreen(),
      const PromotionsListScreen(),
      UsersScreen(onMenuPressed: showPermanentSidebar ? null : onMenuPressed),
      const PaymentTypesScreen(),
      const TaxRatesScreen(),
      const MyCompanyScreen(),
      const VoidReasonsScreen(),
      LoyaltyCardsScreen(onMenuPressed: showPermanentSidebar ? null : onMenuPressed),
    ];

    void handleNavTap(int index) {
      setState(() => _selectedIndex = index);
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
            // Static title header — no back navigation, no tap interaction
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Management Portal",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isDesktop)
                    IconButton(
                      icon: const Icon(Icons.menu_open, color: Colors.white70),
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

            // Pinned exit button at the bottom of the sidebar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: SizedBox(
                width: double.infinity,
                child: Material(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.exit_to_app, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            "Exit Management",
                            style: TextStyle(
                              color: Colors.white,
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
          if (showPermanentSidebar) sidebar,

          Expanded(
            child: ClipRect(
              child: Column(
                children: [
                  if (!showPermanentSidebar &&
                      _selectedIndex != 2 &&
                      _selectedIndex != 3 &&
                      _selectedIndex != 8 &&
                      _selectedIndex != 13)
                    Container(
                      height: kToolbarHeight,
                      color: context.navSidebarBg,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: onMenuPressed,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Management",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  Expanded(child: screens[_selectedIndex]),
                ],
              ),
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
