import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/responsive/adaptive_scaffold.dart';
import 'package:travelgo/core/services/pdf_service.dart';
import 'package:travelgo/core/services/print_service.dart';
import 'package:travelgo/core/services/share_service.dart';
import 'package:travelgo/core/theme/app_theme.dart';
import 'package:travelgo/features/bookings/services/booking_repository.dart';

void main() {
  late MockBookingRepository repository;
  late PdfService pdfService;
  late PrintService printService;
  late ShareService shareService;

  setUp(() {
    repository = MockBookingRepository();
    pdfService = PdfService();
    printService = PrintService();
    shareService = ShareService();
  });

  Widget buildAdaptiveApp() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: AdaptiveScaffold(
        repository: repository,
        pdfService: pdfService,
        printService: printService,
        shareService: shareService,
      ),
    );
  }

  group('AdaptiveScaffold & Responsive UI Tests', () {
    testWidgets('Renders Mobile Bottom Navigation on compact screens (< 600px)', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildAdaptiveApp());
      await tester.pumpAndSettle();

      // Mobile BottomNavigationBar must be present
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      // NavigationRail must not be present
      expect(find.byType(NavigationRail), findsNothing);

      // Verify tabs
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('Wallet'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Renders Desktop Sidebar / Navigation Rail on wide screens (> 1024px)', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildAdaptiveApp());
      await tester.pumpAndSettle();

      // NavigationRail must be present
      expect(find.byType(NavigationRail), findsOneWidget);
      // BottomNavigationBar must not be present
      expect(find.byType(BottomNavigationBar), findsNothing);

      // Desktop branding header
      expect(find.text('TRAVELGO'), findsWidgets);
      expect(find.text('Cross-Platform'), findsOneWidget);
    });

    testWidgets('Navigation switches destinations cleanly', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildAdaptiveApp());
      await tester.pumpAndSettle();

      // Tap 'My Bookings' destination via its icon
      await tester.tap(find.byIcon(Icons.confirmation_number_outlined));
      await tester.pumpAndSettle();

      expect(find.text('My Bookings'), findsWidgets);

      // Tap 'Settings' destination via its icon
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('TRAVELGO • Settings & Preferences'), findsOneWidget);
      expect(find.text('Default Currency'), findsOneWidget);
    });
  });
}
