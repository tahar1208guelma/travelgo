import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelgo/core/localization/app_localizations.dart';
import 'package:travelgo/core/services/storage_service.dart';
import 'package:travelgo/features/hotel_partner/data/repositories/hotel_partner_repository.dart';
import 'package:travelgo/features/hotel_partner/presentation/controllers/hotel_partner_controller.dart';
import 'package:travelgo/features/hotel_partner/presentation/screens/hotel_partner_dashboard_screen.dart';
import 'package:travelgo/features/hotel_partner/presentation/screens/hotel_registration_wizard_screen.dart';
import 'package:travelgo/features/hotel_partner/presentation/widgets/partner_room_editor_sheet.dart';
import 'package:travelgo/features/partner_portal/presentation/screens/admin_panel_screen.dart';

Widget createTestableWidget(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    ),
  );
}

void main() {
  late StorageService storageService;
  late HotelPartnerRepository hotelRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storageService = await StorageService.init();
    hotelRepo = HotelPartnerRepository(storageService);
  });

  testWidgets('HotelPartnerDashboardScreen renders header, KPIs, and tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestableWidget(
        const HotelPartnerDashboardScreen(),
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
          hotelPartnerRepositoryProvider.overrideWithValue(hotelRepo),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // Verify TabBar is present
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('My Hotels'), findsWidgets);
    expect(find.text('Reservations'), findsWidgets);
    expect(find.text('Check-in Scanner'), findsWidgets);
    expect(find.text('Earnings & Payouts'), findsWidgets);

    // Switch to Reservations tab
    await tester.tap(find.text('Reservations').first);
    await tester.pumpAndSettle();
  });

  testWidgets('HotelRegistrationWizardScreen renders step indicator and inputs', (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestableWidget(
        const HotelRegistrationWizardScreen(),
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
          hotelPartnerRepositoryProvider.overrideWithValue(hotelRepo),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // Step 1 / 7 indicator
    expect(find.textContaining('Step 1 / 7'), findsOneWidget);
    expect(find.text('Property Details'), findsWidgets);

    // Next button
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('PartnerRoomEditorSheet renders room category and price fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestableWidget(
        Scaffold(
          body: PartnerRoomEditorSheet(
            hotelId: 'test_hotel',
            onSave: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PartnerRoomEditorSheet), findsOneWidget);
    expect(find.byType(DropdownButtonFormField), findsWidgets);
  });

  testWidgets('AdminPanelScreen renders super admin panel and approval tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestableWidget(
        const AdminPanelScreen(),
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
          hotelPartnerRepositoryProvider.overrideWithValue(hotelRepo),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Super Admin Approval Panel'), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.textContaining('Pending'), findsWidgets);
    expect(find.textContaining('Live / Approved'), findsWidgets);
    expect(find.textContaining('Rejected'), findsWidgets);
  });
}
