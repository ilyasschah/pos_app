import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/app_settings/app_settings_model.dart';
import 'package:pos_app/app_settings/app_settings_provider.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/menu/menu_screen.dart';
import 'package:pos_app/menu/open_orders_screen.dart';
import 'package:pos_app/bookings/bookings_screen.dart';
import 'package:pos_app/floor_plan/floor_plan_screen.dart'; // Make sure to import this!
import 'package:pos_app/reports/z_report_screen.dart';
import 'package:pos_app/navigation/nav_widgets.dart';
import 'package:pos_app/navigation/management_layout.dart';
import 'package:pos_app/navigation/power_modal.dart';
import 'package:pos_app/settings/settings_screen.dart';
import 'package:window_manager/window_manager.dart';

class MainLayout extends ConsumerStatefulWidget {
  // Add this so we can start the app on any screen!
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    // Set the starting screen based on the parameter passed in
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final bookingEnabled =
        settings[SettingKeys.featureBookingEnabled]?.toLowerCase() == 'true';
    final floorPlanEnabled =
        settings[SettingKeys.featureFloorPlanEnabled]?.toLowerCase() == 'true';
    final company = ref.watch(selectedCompanyProvider);
    final companyName = company?.name ?? "Default Branch";

    // Define the views available in Tier 1
    final List<Widget> screens = [
      const MenuScreen(), // Index 0
      const OpenOrdersScreen(), // Index 1
      bookingEnabled
          ? const BookingsScreen()
          : const SizedBox.shrink(), // Index 2
      floorPlanEnabled
          ? const FloorPlanScreen()
          : const SizedBox.shrink(), // Index 3
      const EndOfDayScreen(), // Index 4
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
                  isActive: _selectedIndex == 99,
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
                if (floorPlanEnabled)
                  NavItem(
                    icon: Icons.grid_view,
                    label: settings[SettingKeys.tablesButtonLabel] ?? "Tables",
                    isActive: _selectedIndex == 3,
                    onTap: () => setState(() => _selectedIndex = 3),
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
                  isActive: _selectedIndex == 4,
                  onTap: () => setState(() => _selectedIndex = 4),
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                      NavIconButton(
                        icon: Icons.fullscreen,
                        tooltip: "Full Screen",
                        onTap: () async {
                          bool isFullScreen = await windowManager
                              .isFullScreen();
                          await windowManager.setFullScreen(!isFullScreen);
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
