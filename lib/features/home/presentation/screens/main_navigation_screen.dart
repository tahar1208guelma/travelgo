import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/responsive.dart';
import '../../../ai_agent/presentation/screens/ai_travel_agent_screen.dart';
import '../../../bookings/presentation/pages/my_bookings_screen.dart';
import '../../../flights/presentation/controllers/flight_search_controller.dart';
import '../../../flights/presentation/screens/flight_search_screen.dart';
import '../../../hotels/presentation/controllers/hotel_search_controller.dart';
import '../../../hotels/presentation/screens/hotel_search_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
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
      const FlightSearchScreen(),
      const HotelSearchScreen(),
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
            Container(
              width: isDesktop ? 240 : 80,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                border: Border(
                  right: BorderSide(
                    color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
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
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 20),
                        ),
                        if (isDesktop) ...[
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TRAVELGO',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  'Cross-Platform App',
                                  style: TextStyle(fontSize: 10, color: Colors.grey),
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
                          icon: Icons.flight_outlined,
                          selectedIcon: Icons.flight_rounded,
                          label: context.tr('nav_flights'),
                          isDesktop: isDesktop,
                          isDark: isDark,
                        ),
                        _buildSidebarTile(
                          index: 2,
                          icon: Icons.hotel_outlined,
                          selectedIcon: Icons.hotel_rounded,
                          label: context.tr('nav_hotels'),
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
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // AI Travel Assistant Action
                  if (isDesktop)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const AITravelAgentScreen()),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      context.tr('ai_assistant_title'),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                                    ),
                                    child: const Text(
                                      'AI',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                          tooltip: context.tr('ai_assistant_title'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AITravelAgentScreen()),
                            );
                          },
                        ),
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
          backgroundColor: AppColors.primary,
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
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        tooltip: context.tr('ai_assistant_title'),
        child: const Icon(Icons.auto_awesome_rounded),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabSelected,
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          indicatorColor: isDark ? AppColors.cardDark : AppColors.primaryContainer,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded, color: AppColors.primary),
              label: context.tr('nav_home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.flight_outlined),
              selectedIcon: const Icon(Icons.flight_rounded, color: AppColors.primary),
              label: context.tr('nav_flights'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.hotel_outlined),
              selectedIcon: const Icon(Icons.hotel_rounded, color: AppColors.primary),
              label: context.tr('nav_hotels'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.confirmation_number_outlined),
              selectedIcon: const Icon(Icons.confirmation_number_rounded, color: AppColors.primary),
              label: context.tr('nav_bookings'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded, color: AppColors.primary),
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

    if (!isDesktop) {
      // Tablet Icon-only
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: IconButton(
          icon: Icon(isSelected ? selectedIcon : icon),
          color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
          style: IconButton.styleFrom(
            backgroundColor: isSelected ? AppColors.primaryContainer.withOpacity(0.5) : null,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
          ),
          tooltip: label,
          onPressed: () => _onTabSelected(index),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: () => _onTabSelected(index),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? AppColors.cardDark : AppColors.primaryContainer.withOpacity(0.6))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  size: 22,
                  color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
