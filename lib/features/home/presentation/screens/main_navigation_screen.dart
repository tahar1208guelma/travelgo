import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/responsive.dart';
import '../../../ai_agent/presentation/screens/ai_travel_agent_screen.dart';
import '../../../bookings/presentation/screens/my_bookings_screen.dart';
import '../../../favorites/presentation/screens/favorites_screen.dart';
import '../../../flights/presentation/controllers/flight_search_controller.dart';
import '../../../flights/presentation/screens/flight_search_screen.dart';
import '../../../hotels/presentation/controllers/hotel_search_controller.dart';
import '../../../partner_portal/presentation/screens/admin_panel_screen.dart';
import '../../../partner_portal/presentation/screens/partner_dashboard_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../unified_search/presentation/screens/unified_search_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const MainNavigationScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;

    // Trigger initial warm-up fetch for flight & hotel catalogues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(flightSearchControllerProvider.notifier).searchFlights();
      ref.read(hotelSearchControllerProvider.notifier).searchHotels();
    });
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);

    final List<Widget> screens = [
      HomeScreen(onNavigateTab: _onTabSelected),
      const UnifiedSearchScreen(),
      const FlightSearchScreen(),
      const MyBookingsScreen(),
      const ProfileScreen(),
    ];

    if (!isMobile) {
      // Tablet and Desktop Adaptive Layout with Sidebar / NavigationRail
      return Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: Row(
          children: [
            // Desktop / Tablet Sidebar
            Material(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              child: Container(
                width: isDesktop ? 260 : 80,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                children: [
                  // App Brand Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Row(
                      mainAxisAlignment: isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 20),
                        ),
                        if (isDesktop) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TRAVELGO',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                                  ),
                                ),
                                const Text(
                                  'Unified Travel Engine',
                                  style: TextStyle(fontSize: 10, color: AppColors.secondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Navigation Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        _buildSidebarTile(
                          index: 0,
                          icon: Icons.home_outlined,
                          selectedIcon: Icons.home_rounded,
                          label: context.tr('nav_home'),
                          isDesktop: isDesktop,
                          isDark: isDark,
                        ),
                        _buildSidebarTile(
                          index: 1,
                          icon: Icons.travel_explore_outlined,
                          selectedIcon: Icons.travel_explore_rounded,
                          label: 'Unified Search & Map',
                          isDesktop: isDesktop,
                          isDark: isDark,
                        ),
                        _buildSidebarTile(
                          index: 2,
                          icon: Icons.flight_outlined,
                          selectedIcon: Icons.flight_rounded,
                          label: context.tr('nav_flights'),
                          isDesktop: isDesktop,
                          isDark: isDark,
                        ),
                        _buildSidebarTile(
                          index: 3,
                          icon: Icons.confirmation_number_outlined,
                          selectedIcon: Icons.confirmation_number_rounded,
                          label: context.tr('nav_bookings'),
                          isDesktop: isDesktop,
                          isDark: isDark,
                        ),
                        _buildSidebarTile(
                          index: 4,
                          icon: Icons.person_outline_rounded,
                          selectedIcon: Icons.person_rounded,
                          label: context.tr('nav_profile'),
                          isDesktop: isDesktop,
                          isDark: isDark,
                        ),
                        const Divider(height: 16),
                        // Quick Host / Admin Links
                        if (isDesktop) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: Text(
                              'PORTALS & TOOLS',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMutedLight),
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.business_center_rounded, size: 20, color: AppColors.secondary),
                            title: const Text('Partner Portal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const PartnerDashboardScreen()),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.admin_panel_settings_rounded, size: 20, color: AppColors.primaryLight),
                            title: const Text('Admin Panel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.favorite_rounded, size: 20, color: AppColors.accentCoral),
                            title: const Text('Wishlist', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Bottom Quick Settings (Theme toggle)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: IconButton(
                      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                      tooltip: 'Toggle Theme',
                      onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                    ),
                  ),
                ],
              ),
            ),
          ),

            // Main Content Area
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: screens,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AITravelAgentScreen()),
            );
          },
          backgroundColor: isDark ? AppColors.secondary : AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.auto_awesome_rounded),
          label: Text(context.tr('ai_assistant_title')),
          tooltip: context.tr('ai_assistant_title'),
        ),
      );
    }

    // Mobile Bottom Navigation Layout
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AITravelAgentScreen()),
          );
        },
        backgroundColor: isDark ? AppColors.secondary : AppColors.primary,
        foregroundColor: Colors.white,
        tooltip: context.tr('ai_assistant_title'),
        child: const Icon(Icons.auto_awesome_rounded),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabSelected,
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          indicatorColor: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.15),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: isDark ? AppColors.secondaryLight : AppColors.primary),
              label: context.tr('nav_home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.travel_explore_outlined),
              selectedIcon: Icon(Icons.travel_explore_rounded, color: isDark ? AppColors.secondaryLight : AppColors.primary),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: const Icon(Icons.flight_outlined),
              selectedIcon: Icon(Icons.flight_rounded, color: isDark ? AppColors.secondaryLight : AppColors.primary),
              label: context.tr('nav_flights'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.confirmation_number_outlined),
              selectedIcon: Icon(Icons.confirmation_number_rounded, color: isDark ? AppColors.secondaryLight : AppColors.primary),
              label: context.tr('nav_bookings'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: isDark ? AppColors.secondaryLight : AppColors.primary),
              label: context.tr('nav_profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarTile({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isDesktop,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;
    final primaryColor = isDark ? AppColors.secondaryLight : AppColors.primary;

    if (!isDesktop) {
      return IconButton(
        icon: Icon(isSelected ? selectedIcon : icon, color: isSelected ? primaryColor : null),
        tooltip: label,
        onPressed: () => _onTabSelected(index),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(
            isSelected ? selectedIcon : icon,
            color: isSelected ? primaryColor : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
            size: 22,
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? primaryColor
                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            ),
          ),
          onTap: () => _onTabSelected(index),
        ),
      ),
    );
  }
}
