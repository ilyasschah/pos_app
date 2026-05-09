import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/app_settings/app_settings_model.dart';
import 'package:pos_app/app_settings/app_settings_provider.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/menu/menu_screen.dart';
import 'package:pos_app/menu/open_orders_screen.dart';
import 'package:pos_app/bookings/bookings_screen.dart';
import 'package:pos_app/floor_plan/floor_plan_screen.dart';
import 'package:pos_app/reports/z_report_screen.dart';
import 'package:pos_app/navigation/nav_widgets.dart';
import 'package:pos_app/navigation/management_layout.dart';
import 'package:pos_app/navigation/power_modal.dart';
import 'package:pos_app/settings/settings_screen.dart';
import 'package:window_manager/window_manager.dart';

class MainLayout extends ConsumerStatefulWidget {
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
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Detect if we are on a desktop/tablet vs small mobile screen
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    final settings = ref.watch(appSettingsProvider);
    final bookingEnabled =
        settings[SettingKeys.featureBookingEnabled]?.toLowerCase() == 'true';
    final floorPlanEnabled =
        settings[SettingKeys.featureFloorPlanEnabled]?.toLowerCase() == 'true';
    final company = ref.watch(selectedCompanyProvider);
    final companyName = company?.name ?? "Default Branch";

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

    // Helper to change screens and automatically close the drawer on mobile
    void handleNavTap(int index) {
      setState(() => _selectedIndex = index);
      if (!isDesktop && Scaffold.of(context).hasDrawer) {
        Navigator.pop(context); // Close Hamburger Drawer
      }
    }

    // 2. Wrap the sidebar in a variable so we can use it in both Row AND Drawer
    Widget sidebar = Container(
      width: kSidebarW,
      color: kNavSidebar,
      child: SafeArea(
        child: Column(
          children: [
            NavSidebarHeader(name: companyName),

            // 3. Make the middle section Scrollable so it never overflows!
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    NavItem(
                      icon: Icons.build_circle,
                      label: "Management",
                      onTap: () {
                        if (!isDesktop && Scaffold.of(context).hasDrawer)
                          Navigator.pop(context);
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

                    NavItem(
                      icon: Icons.point_of_sale,
                      label: "POS",
                      isActive: _selectedIndex == 0,
                      onTap: () => handleNavTap(0),
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
                      onTap: () => handleNavTap(1),
                    ),
                    if (bookingEnabled)
                      NavItem(
                        icon: Icons.calendar_month,
                        label: "Bookings",
                        isActive: _selectedIndex == 2,
                        onTap: () => handleNavTap(2),
                      ),
                    if (floorPlanEnabled)
                      NavItem(
                        icon: Icons.grid_view,
                        label:
                            settings[SettingKeys.tablesButtonLabel] ?? "Tables",
                        isActive: _selectedIndex == 3,
                        onTap: () => handleNavTap(3),
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
                      onTap: () => handleNavTap(4),
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
                      onTap: () {},
                    ),
                    NavItem(
                      icon: Icons.campaign,
                      label: "Feedback",
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

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
                      if (!isDesktop && Scaffold.of(context).hasDrawer)
                        Navigator.pop(context);
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
                      if (!isDesktop && Scaffold.of(context).hasDrawer)
                        Navigator.pop(context);
                      bool isFullScreen = await windowManager.isFullScreen();
                      await windowManager.setFullScreen(!isFullScreen);
                    },
                  ),
                  NavIconButton(
                    icon: Icons.power_settings_new,
                    tooltip: "Power",
                    iconColor: Colors.white,
                    onTap: () {
                      if (!isDesktop && Scaffold.of(context).hasDrawer)
                        Navigator.pop(context);
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
    );

    return Scaffold(
      backgroundColor: kNavBg,
      // 4. Attach the sidebar to the Drawer only when in mobile view!
      drawer: isDesktop
          ? null
          : Drawer(backgroundColor: kNavSidebar, child: sidebar),
      body: Row(
        children: [
          // If desktop, permanently show the sidebar
          if (isDesktop) sidebar,

          Expanded(
            child: ClipRect(
              child: Column(
                children: [
                  // 5. Create a mini top bar with Hamburger menu for Mobile ONLY
                  if (!isDesktop)
                    Container(
                      height: kToolbarHeight,
                      color: kNavSidebar,
                      child: Row(
                        children: [
                          Builder(
                            builder: (ctx) => IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white),
                              onPressed: () => Scaffold.of(ctx).openDrawer(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              companyName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // The actual active screen
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
