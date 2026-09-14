import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/localization/app_localizations.dart';
import 'package:travelgo/features/bookings/data/mock_booking_data.dart';
import 'package:travelgo/features/bookings/presentation/pages/booking_details_screen.dart';
import 'package:travelgo/features/bookings/presentation/pages/booking_document_screen.dart';
import 'package:travelgo/features/bookings/presentation/pages/my_bookings_screen.dart';
import 'package:travelgo/features/bookings/presentation/widgets/booking_card.dart';
import 'package:travelgo/features/bookings/presentation/widgets/qr_code_widget.dart';

Widget createTestableWidget(Widget child) {
  return ProviderScope(
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
  testWidgets('SafeQrCodeWidget renders with caption', (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestableWidget(
        const Scaffold(
          body: SafeQrCodeWidget(
            qrData: 'TRV-2026-000001',
            caption: 'Scan to verify booking',
          ),
        ),
      ),
    );

    expect(find.text('Scan to verify booking'), findsOneWidget);
    expect(find.byType(SafeQrCodeWidget), findsOneWidget);
  });

  testWidgets('BookingCard displays flight details, price, reference, and View Document button',
      (WidgetTester tester) async {
    final booking = MockBookingData.flightBooking;

    await tester.pumpWidget(
      createTestableWidget(
        Scaffold(
          body: BookingCard(booking: booking),
        ),
      ),
    );

    // Verify booking reference & flight route & passenger
    expect(find.textContaining('TRV-2026-000001'), findsOneWidget);
    expect(find.text('Tahar Braknia'), findsOneWidget);
    expect(find.text('CONFIRMED'), findsOneWidget);
    expect(find.text('View Document'), findsOneWidget);
    expect(find.text('Trip Details'), findsOneWidget);
  });

  testWidgets('BookingDocumentScreen renders header, demo banner, QR code, and action buttons',
      (WidgetTester tester) async {
    final booking = MockBookingData.flightBooking;

    await tester.pumpWidget(
      createTestableWidget(
        BookingDocumentScreen(booking: booking),
      ),
    );

    // Verify Title & Reference
    expect(find.text('Booking Document'), findsOneWidget);
    expect(find.text('TRAVELGO'), findsOneWidget);
    expect(find.text('TRV-2026-000001'), findsOneWidget);
    expect(find.text('DEMO / TEST BOOKING'), findsOneWidget);
    expect(find.text('Tahar Braknia'), findsOneWidget);
    expect(find.text('View PDF'), findsOneWidget);
    expect(find.text('Save PDF'), findsOneWidget);
  });

  testWidgets('MyBookingsScreen renders upcoming, completed, and cancelled tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestableWidget(
        const MyBookingsScreen(),
      ),
    );

    expect(find.byType(TabBar), findsOneWidget);
    expect(find.byType(BookingCard), findsWidgets);
  });
}
