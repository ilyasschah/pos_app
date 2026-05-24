import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/app_settings/app_settings_model.dart';
import 'package:pos_app/app_settings/app_settings_provider.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/menu/menu_screen.dart';
import 'package:pos_app/menu/open_orders_screen.dart';
import 'package:pos_app/bookings/bookings_screen.dart';
import 'package:pos_app/bookings/booking_history_screen.dart';
import 'package:pos_app/floor_plan/floor_plan_screen.dart';
import 'package:pos_app/reports/z_report_screen.dart';
import 'package:pos_app/navigation/nav_widgets.dart';
import 'package:pos_app/navigation/management_layout.dart';
import 'package:pos_app/navigation/power_modal.dart';
import 'package:pos_app/settings/settings_screen.dart';
import 'package:window_manager/window_manager.dart';
import 'package:pos_app/auth/user_info_screen.dart';
import 'package:pos_app/auth/auth_provider.dart';
import 'package:pos_app/auth/login_screen.dart';
import 'package:pos_app/cash/cash_movement_screen.dart';
import 'package:pos_app/reports/sales_history_screen.dart';
import 'package:pos_app/credit/credit_payment_dialog.dart';

class MainLayout extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  late int _selectedIndex;
  bool _isSidebarVisible = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    // ✨ Only show the permanent sidebar if we are on Desktop AND it hasn't been hidden
    final showPermanentSidebar = isDesktop && _isSidebarVisible;

    final settings = ref.watch(appSettingsProvider);
    final bookingEnabled =
        settings[SettingKeys.featureBookingEnabled]?.toLowerCase() == 'true';
    final floorPlanEnabled =
        settings[SettingKeys.featureFloorPlanEnabled]?.toLowerCase() == 'true';
    final company = ref.watch(selectedCompanyProvider);
    final companyName = company?.name ?? "Default Branch";

    final List<Widget> screens = [
      MenuScreen(
        showAppBarNavigation: !showPermanentSidebar,
        onToggleSidebar: isDesktop
            ? () => setState(() => _isSidebarVisible = true)
            : () => _scaffoldKey.currentState?.openDrawer(),
      ),
      const OpenOrdersScreen(),
      bookingEnabled ? const BookingsScreen() : const SizedBox.shrink(),
      bookingEnabled ? const BookingHistoryScreen() : const SizedBox.shrink(),
      floorPlanEnabled ? const FloorPlanScreen() : const SizedBox.shrink(),
      const EndOfDayScreen(),
      const UserInfoScreen(),
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
            NavSidebarHeader(
              name: companyName,
              onHideSidebar: isDesktop
                  ? () => setState(() => _isSidebarVisible = false)
                  : null,
            ),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Divider(color: context.navDivider, height: 24),
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
                      onTap: () {
                        if (!isDesktop && Scaffold.of(context).hasDrawer)
                          Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SalesHistoryScreen(),
                          ),
                        );
                      },
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
                    if (bookingEnabled)
                      NavItem(
                        icon: Icons.history,
                        label: "Booking History",
                        isActive: _selectedIndex == 3,
                        onTap: () => handleNavTap(3),
                      ),
                    if (floorPlanEnabled)
                      NavItem(
                        icon: Icons.grid_view,
                        label:
                            settings[SettingKeys.tablesButtonLabel] ?? "Tables",
                        isActive: _selectedIndex == 4,
                        onTap: () => handleNavTap(4),
                      ),
                    NavItem(
                      icon: Icons.download,
                      label: "Cash In / Out",
                      onTap: () {
                        if (!isDesktop && Scaffold.of(context).hasDrawer)
                          Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CashMovementScreen(),
                          ),
                        );
                      },
                    ),
                    NavItem(
                      icon: Icons.credit_card,
                      label: "Credit payments",
                      onTap: () {
                        if (!isDesktop && Scaffold.of(context).hasDrawer)
                          Navigator.pop(context);
                        CreditPaymentsDialog.show(context);
                      },
                    ),
                    NavItem(
                      icon: Icons.directions_run,
                      label: "End of day",
                      isActive: _selectedIndex == 5,
                      onTap: () => handleNavTap(5),
                    ),

                    const NavSectionLabel("User"),
                    NavItem(
                      icon: Icons.person_outline,
                      label: "User info",
                      isActive: _selectedIndex == 6,
                      onTap: () => handleNavTap(6),
                    ),
                    NavItem(
                      icon: Icons.logout,
                      label: "Sign out",
                      onTap: () {
                        ref.read(currentUserProvider.notifier).logout();
                        ref.invalidate(allUsersProvider);

                        if (!isDesktop && Scaffold.of(context).hasDrawer) {
                          Navigator.pop(context);
                        }
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
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
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.navDivider)),
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
              child: _selectedIndex != 0 && !showPermanentSidebar && isDesktop
                  ? Stack(
                      children: [
                        screens[_selectedIndex],
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Material(
                            color: Colors.transparent,
                            child: IconButton(
                              icon: const Icon(Icons.menu),
                              tooltip: 'Show navigation',
                              onPressed: () =>
                                  setState(() => _isSidebarVisible = true),
                            ),
                          ),
                        ),
                      ],
                    )
                  : screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
