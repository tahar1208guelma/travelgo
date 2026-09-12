import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/services/pdf_service.dart';
import 'package:travelgo/core/services/print_service.dart';
import 'package:travelgo/core/services/share_service.dart';
import 'package:travelgo/core/theme/app_theme.dart';
import 'package:travelgo/features/bookings/data/mock_bookings_data.dart';
import 'package:travelgo/features/bookings/presentation/pages/booking_details_screen.dart';
import 'package:travelgo/features/bookings/presentation/pages/booking_document_screen.dart';
import 'package:travelgo/features/bookings/presentation/pages/my_bookings_screen.dart';
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

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    );
  }

  group('Presentation Screens Widget Tests', () {
    testWidgets('MyBookingsScreen renders booking cards with mock data', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MyBookingsScreen(
            repository: repository,
            pdfService: pdfService,
            printService: printService,
            shareService: shareService,
          ),
        ),
      );

      // Initial loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Pump through repository async delay
      await tester.pumpAndSettle();

      // Verify header and booking reference
      expect(find.text('TRAVELGO • My Bookings'), findsOneWidget);
      expect(find.text('TRV-2026-000001'), findsOneWidget);
      expect(find.text('Algiers → Istanbul'), findsOneWidget);
      expect(find.text('\$251.00'), findsOneWidget);
      expect(find.text('View Document'), findsWidgets);
    });

    testWidgets('MyBookingsScreen filter tabs filter bookings accurately', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MyBookingsScreen(
            repository: repository,
            pdfService: pdfService,
            printService: printService,
            shareService: shareService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap 'Hotels' tab
      await tester.tap(find.text('Hotels'));
      await tester.pumpAndSettle();

      expect(find.text('TRV-2026-000002'), findsOneWidget);
      expect(find.text('Bosphorus View Grand Hotel'), findsOneWidget);
    });

    testWidgets('BookingDetailsScreen renders booking details, price breakdown and actions', (tester) async {
      final booking = MockBookingsData.flightBookingMock;

      await tester.pumpWidget(
        createTestWidget(
          BookingDetailsScreen(
            booking: booking,
            pdfService: pdfService,
            printService: printService,
            shareService: shareService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Booking TRV-2026-000001'), findsOneWidget);
      expect(find.text('Flight Itinerary'), findsOneWidget);
      expect(find.text('ALG'), findsOneWidget);
      expect(find.text('IST'), findsOneWidget);
      expect(find.text('Demo Airline • TG100'), findsOneWidget);
      expect(find.text('Passenger Information'), findsOneWidget);
      expect(find.text('Tahar Braknia'), findsWidgets);
      expect(find.text('Price Breakdown'), findsOneWidget);
      expect(find.text('View PDF'), findsOneWidget);
      expect(find.text('Print'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('BookingDocumentScreen renders digital confirmation with QR code and buttons', (tester) async {
      final booking = MockBookingsData.flightBookingMock;

      await tester.pumpWidget(
        createTestWidget(
          BookingDocumentScreen(
            booking: booking,
            pdfService: pdfService,
            printService: printService,
            shareService: shareService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Travel Booking Confirmation'), findsOneWidget);
      expect(find.text('DEMO / TEST BOOKING — Not a real airline or hotel reservation.'), findsOneWidget);
      expect(find.text('TRV-2026-000001'), findsWidgets);
      expect(find.text('Tahar Braknia'), findsWidgets);
      expect(find.text('Scan to verify'), findsOneWidget);
      expect(find.text('Save PDF'), findsOneWidget);
      expect(find.text('Print'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });
  });
}
