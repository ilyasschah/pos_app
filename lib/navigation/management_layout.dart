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

    // ✨ Only show the permanent sidebar if we are on Desktop AND it hasn't been hidden
    final showPermanentSidebar = isDesktop && _isSidebarVisible;

    void onMenuPressed() {
      if (isDesktop) {
        setState(() => _isSidebarVisible = true);
      } else {
        _scaffoldKey.currentState?.openDrawer();
      }
    }

    final List<Widget> screens = [
      const DashboardScreen(), // Index 0
      const DocumentsScreen(), // Index 1
      ProductsScreen(onMenuPressed: showPermanentSidebar ? null : onMenuPressed), // Index 2
      ProductGroupsScreen(onMenuPressed: showPermanentSidebar ? null : onMenuPressed), // Index 3
      const StockScreen(), // Index 4
      const ReportsScreen(), // Index 5
      const CustomersScreen(), // Index 6
      const PromotionsListScreen(), // Index 7
      const UsersScreen(), // Index 8
      const PaymentTypesScreen(), // Index 9
      const TaxRatesScreen(), // Index 10
      const MyCompanyScreen(), // Index 11
      const VoidReasonsScreen(), // Index 12
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
            // ✨ Top header with Desktop collapse button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: const [
                          Icon(Icons.arrow_back, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "POS System",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                    const SizedBox(height: 16),
                  ],
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
          // ✨ Conditionally show sidebar based on our new variable
          if (showPermanentSidebar) sidebar,

          Expanded(
            child: ClipRect(
              child: Column(
                children: [
                  // Show the top bar only when sidebar is hidden AND not on the Products screen
                  if (!showPermanentSidebar && _selectedIndex != 2 && _selectedIndex != 3)
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

                  // Active Screen
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

// Keep this at the bottom for any screens you haven't built yet!
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
