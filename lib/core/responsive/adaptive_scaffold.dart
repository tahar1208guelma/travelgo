import 'package:flutter/material.dart';
import '../../core/services/pdf_service.dart';
import '../../core/services/print_service.dart';
import '../../core/services/share_service.dart';
import '../../core/theme/app_theme.dart';
import '../../features/bookings/presentation/pages/my_bookings_screen.dart';
import '../../features/bookings/services/booking_repository.dart';
import '../../features/explore/presentation/pages/explore_search_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/wallet/presentation/pages/travelgo_wallet_screen.dart';
import 'responsive_breakpoints.dart';

class AdaptiveScaffold extends StatefulWidget {
  final BookingRepository repository;
  final PdfService pdfService;
  final PrintService printService;
  final ShareService shareService;
  final int initialIndex;

  const AdaptiveScaffold({
    super.key,
    required this.repository,
    required this.pdfService,
    required this.printService,
    required this.shareService,
    this.initialIndex = 0, // Default to Explore & Search
  });

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  List<Widget> _buildScreens() {
    return [
      const ExploreSearchScreen(),
      MyBookingsScreen(
        repository: widget.repository,
        pdfService: widget.pdfService,
        printService: widget.printService,
        shareService: widget.shareService,
      ),
      const TravelGoWalletScreen(),
      const ProfileScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screens = _buildScreens();
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;

    if (isDesktop || isTablet) {
      return Scaffold(
        body: Row(
          children: [
            // Left Sidebar / NavigationRail for Desktop and Tablet
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.primaryNavy,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(2, 0),
                  ),
                ],
              ),
              child: NavigationRail(
                backgroundColor: Colors.transparent,
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                extended: isDesktop,
                minWidth: 72,
                minExtendedWidth: 220,
                leading: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: isDesktop ? 16.0 : 8.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'TG',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (isDesktop) ...[
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'TRAVELGO',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.1,
                              ),
                            ),
                            Text(
                              'Cross-Platform',
                              style: TextStyle(
                                color: AppTheme.electricCyan,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                selectedIconTheme: const IconThemeData(color: AppTheme.electricCyan, size: 26),
                unselectedIconTheme: const IconThemeData(color: Colors.white60, size: 24),
                selectedLabelTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelTextStyle: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.explore_outlined),
                    selectedIcon: Icon(Icons.explore),
                    label: Text('Explore & Search'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.confirmation_number_outlined),
                    selectedIcon: Icon(Icons.confirmation_number),
                    label: Text('My Bookings'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.account_balance_wallet_outlined),
                    selectedIcon: Icon(Icons.account_balance_wallet),
                    label: Text('TRAVELGO Wallet'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: Text('Passengers'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: Text('Settings'),
                  ),
                ],
              ),
            ),
            // Main content area
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: screens,
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout with BottomNavigationBar
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.primaryNavy,
          selectedItemColor: AppTheme.electricCyan,
          unselectedItemColor: Colors.white60,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined),
              activeIcon: Icon(Icons.confirmation_number),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
