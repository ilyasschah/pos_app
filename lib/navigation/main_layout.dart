import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/app_settings/app_settings_model.dart';
import 'package:pos_app/app_settings/app_settings_provider.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/menu/menu_screen.dart';
import 'package:pos_app/menu/open_orders_screen.dart';
import 'package:pos_app/bookings/bookings_screen.dart';
import 'package:pos_app/navigation/nav_widgets.dart';
import 'package:pos_app/navigation/management_layout.dart';
import 'package:pos_app/navigation/power_modal.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final bookingEnabled =
        settings[SettingKeys.featureBookingEnabled]?.toLowerCase() == 'true';
    final company = ref.watch(selectedCompanyProvider);
    final companyName = company?.name ?? "Default Branch";

    // Define the views available in Tier 1
    final List<Widget> screens = [
      const MenuScreen(), // Index 0
      const OpenOrdersScreen(), // Index 1
      if (bookingEnabled) const BookingsScreen(),
      // Add other POS screens here (Cash In/Out, End of Day)
    ];

    return Scaffold(
      backgroundColor: kNavBg,
      body: Row(
        children: [
          // TIER 1 SIDEBAR
          Container(
            width: kSidebarW,
            color: kNavSidebar,
            child: Column(
              children: [
                NavSidebarHeader(name: companyName),

                // Management Transition Button
                NavItem(
                  icon: Icons.build_circle,
                  label: "Management",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManagementLayout(),
                      ),
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(color: kNavDivider, height: 24),
                ),

                // Main POS Functions
                NavItem(
                  icon: Icons.point_of_sale,
                  label: "POS",
                  isActive: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                NavItem(
                  icon: Icons.receipt_long,
                  label: "View sales history",
                  isActive: _selectedIndex == 99, // Add real index
                  onTap: () {},
                ),
                NavItem(
                  icon: Icons.layers,
                  label: "View open sales",
                  isActive: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                if (bookingEnabled)
                  NavItem(
                    icon: Icons.calendar_month,
                    label: "Bookings",
                    isActive: _selectedIndex == 2,
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                NavItem(
                  icon: Icons.download,
                  label: "Cash In / Out",
                  onTap: () {},
                ),
                NavItem(
                  icon: Icons.credit_card,
                  label: "Credit payments",
                  onTap: () {},
                ),
                NavItem(
                  icon: Icons.directions_run,
                  label: "End of day",
                  onTap: () {},
                ),

                const NavSectionLabel("User"),
                NavItem(
                  icon: Icons.person_outline,
                  label: "User info",
                  onTap: () {},
                ),
                NavItem(
                  icon: Icons.logout,
                  label: "Sign out",
                  onTap: () {
                    // Handle sign out
                  },
                ),

                const Spacer(),

                NavItem(icon: Icons.campaign, label: "Feedback", onTap: () {}),
                const SizedBox(height: 8),

                // BOTTOM HARDWARE BAR
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: kNavDivider)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      NavIconButton(
                        icon: Icons.tune,
                        tooltip: "Quick Settings",
                        onTap: () {},
                      ),
                      NavIconButton(
                        icon: Icons.fullscreen,
                        tooltip: "Full Screen",
                        onTap: () {
                          // Toggle window_manager full screen
                        },
                      ),
                      NavIconButton(
                        icon: Icons.power_settings_new,
                        tooltip: "Power",
                        iconColor: Colors.white,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => const PowerModal(),
                          );
                        },
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
