import 'package:flutter/material.dart';
import 'package:pos_app/navigation/nav_widgets.dart';

class ManagementLayout extends StatefulWidget {
  const ManagementLayout({super.key});

  @override
  State<ManagementLayout> createState() => _ManagementLayoutState();
}

class _ManagementLayoutState extends State<ManagementLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const PlaceholderScreen(title: "Dashboard"), // Index 0
      const PlaceholderScreen(title: "Documents"), // Index 1
      const PlaceholderScreen(title: "Products"), // Index 2
      const PlaceholderScreen(title: "Stock"), // Index 3
      const PlaceholderScreen(title: "Reporting"), // Index 4
      const PlaceholderScreen(title: "Customers & suppliers"), // Index 5
      const PlaceholderScreen(title: "Promotions"), // Index 6
      const PlaceholderScreen(title: "Users & security"), // Index 7
      const PlaceholderScreen(title: "Payment types"), // Index 8
      const PlaceholderScreen(title: "Countries"), // Index 9
      const PlaceholderScreen(title: "Tax rates"), // Index 10
      const PlaceholderScreen(title: "My company"), // Index 11
    ];

    return Scaffold(
      backgroundColor: kNavBg,
      body: Row(
        children: [
          // TIER 2 SIDEBAR
          Container(
            width: kSidebarW,
            color: kNavSidebar,
            child: Column(
              children: [
                // Top Back Button
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: const [
                        Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
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
                ),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      NavItem(
                        icon: Icons.dashboard,
                        label: "Dashboard",
                        isActive: _selectedIndex == 0,
                        onTap: () => setState(() => _selectedIndex = 0),
                      ),
                      NavItem(
                        icon: Icons.description,
                        label: "Documents",
                        isActive: _selectedIndex == 1,
                        onTap: () => setState(() => _selectedIndex = 1),
                      ),
                      NavItem(
                        icon: Icons.local_offer,
                        label: "Products",
                        isActive: _selectedIndex == 2,
                        onTap: () => setState(() => _selectedIndex = 2),
                      ),
                      NavItem(
                        icon: Icons.inventory_2,
                        label: "Stock",
                        isActive: _selectedIndex == 3,
                        onTap: () => setState(() => _selectedIndex = 3),
                      ),
                      NavItem(
                        icon: Icons.bar_chart,
                        label: "Reporting",
                        isActive: _selectedIndex == 4,
                        onTap: () => setState(() => _selectedIndex = 4),
                      ),
                      NavItem(
                        icon: Icons.people,
                        label: "Customers & suppliers",
                        isActive: _selectedIndex == 5,
                        onTap: () => setState(() => _selectedIndex = 5),
                      ),
                      NavItem(
                        icon: Icons.favorite,
                        label: "Promotions",
                        isActive: _selectedIndex == 6,
                        onTap: () => setState(() => _selectedIndex = 6),
                      ),
                      NavItem(
                        icon: Icons.vpn_key,
                        label: "Users & security",
                        isActive: _selectedIndex == 7,
                        onTap: () => setState(() => _selectedIndex = 7),
                      ),
                      NavItem(
                        icon: Icons.credit_card,
                        label: "Payment types",
                        isActive: _selectedIndex == 8,
                        onTap: () => setState(() => _selectedIndex = 8),
                      ),
                      NavItem(
                        icon: Icons.public,
                        label: "Countries",
                        isActive: _selectedIndex == 9,
                        onTap: () => setState(() => _selectedIndex = 9),
                      ),
                      NavItem(
                        icon: Icons.percent,
                        label: "Tax rates",
                        isActive: _selectedIndex == 10,
                        onTap: () => setState(() => _selectedIndex = 10),
                      ),
                      NavItem(
                        icon: Icons.business,
                        label: "My company",
                        isActive: _selectedIndex == 11,
                        onTap: () => setState(() => _selectedIndex = 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ACTIVE SCREEN CONTENT
          Expanded(child: ClipRect(child: screens[_selectedIndex])),
        ],
      ),
    );
  }
}

// Simple placeholder for screens we haven't built yet
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
