import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:travelgo/core/services/pdf_service.dart';
import 'package:travelgo/features/bookings/data/mock_booking_data.dart';
import 'package:travelgo/features/bookings/models/booking_document.dart';
import 'package:travelgo/features/bookings/models/booking_model.dart';
import 'package:travelgo/features/bookings/models/customer_info.dart';
import 'package:travelgo/features/bookings/models/flight_booking_details.dart';
import 'package:travelgo/features/bookings/models/hotel_booking_details.dart';
import 'package:travelgo/features/bookings/models/price_breakdown.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PdfService PDF Generation Tests', () {
    late PdfService pdfService;

    setUp(() {
      pdfService = PdfService();
    });

    bool isValidPdf(Uint8List bytes) {
      if (bytes.length < 5) return false;
      // PDF documents must start with %PDF-
      final header = utf8.decode(bytes.sublist(0, 5), allowMalformed: true);
      return header.startsWith('%PDF');
    }

    test('generateFlightBookingPdf generates valid PDF bytes for TRV-2026-000001', () async {
      final booking = MockBookingData.flightBooking;
      final pdfBytes = await pdfService.generateFlightBookingPdf(booking);

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      expect(isValidPdf(pdfBytes), isTrue);
      expect(pdfBytes.length, greaterThan(1000));
    });

    test('generateHotelBookingPdf generates valid Hotel Voucher PDF for TRV-2026-000002', () async {
      final booking = MockBookingData.hotelBooking;
      final pdfBytes = await pdfService.generateHotelBookingPdf(booking);

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      expect(isValidPdf(pdfBytes), isTrue);
      expect(pdfBytes.length, greaterThan(1000));
    });

    test('generateCombinedBookingPdf generates valid Combined Package PDF for TRV-2026-000003', () async {
      final booking = MockBookingData.combinedBooking;
      final pdfBytes = await pdfService.generateCombinedBookingPdf(booking);

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      expect(isValidPdf(pdfBytes), isTrue);
      expect(pdfBytes.length, greaterThan(1500));
    });

    test('generateBookingPdf dispatcher handles all booking types correctly', () async {
      final flightBytes = await pdfService.generateBookingPdf(MockBookingData.flightBooking);
      final hotelBytes = await pdfService.generateBookingPdf(MockBookingData.hotelBooking);
      final comboBytes = await pdfService.generateBookingPdf(MockBookingData.combinedBooking);

      expect(isValidPdf(flightBytes), isTrue);
      expect(isValidPdf(hotelBytes), isTrue);
      expect(isValidPdf(comboBytes), isTrue);
    });

    test('Handles missing / null optional fields without throwing exceptions', () async {
      final minimalBooking = Booking(
        bookingId: 'BK-MIN-001',
        bookingReference: 'TRV-MIN-001',
        bookingType: BookingType.flight,
        status: BookingStatus.confirmed,
        customer: const CustomerInfo(
          id: 'USR-0',
          fullName: 'Minimal User',
          email: 'minimal@example.com',
          phone: '',
        ),
        provider: 'Direct Air',
        priceBreakdown: const PriceBreakdown(
          basePrice: 100.0,
          serviceFee: 1.0,
          totalAmount: 101.0,
        ),
        createdAt: DateTime.now(),
        document: BookingDocument(
          documentId: 'DOC-MIN-001',
          bookingReference: 'TRV-MIN-001',
          issuedAt: DateTime.now(),
          qrData: 'TRV-MIN-001',
        ),
      );

      final bytes = await pdfService.generateBookingPdf(minimalBooking);
      expect(isValidPdf(bytes), isTrue);
    });

    test('Handles very long passenger names without overflow or crashing', () async {
      final longNameBooking = MockBookingData.multiSegmentBooking.copyWith(
        customer: const CustomerInfo(
          id: 'USR-LONG',
          fullName:
              'Dr. Tahar Braknia Ibn Abdelaziz Al-Mansouri Al-Andalusi The Third Extremely Long Royal Traveler Name',
          email: 'very.long.email.address.for.testing.overflow.safeguards@travelgo.example.com',
          phone: '+213 555 123 456 / +213 555 789 012',
          passengers: [
            PassengerInfo(
              fullName:
                  'Dr. Tahar Braknia Ibn Abdelaziz Al-Mansouri Al-Andalusi The Third Extremely Long Royal Traveler Name',
              passengerType: PassengerType.adult,
              ticketNumber: '082-998877665544332211',
            ),
          ],
        ),
      );

      final bytes = await pdfService.generateBookingPdf(longNameBooking);
      expect(isValidPdf(bytes), isTrue);
    });

    test('Handles multi-segment flight connecting itinerary', () async {
      final multiSegmentBooking = MockBookingData.multiSegmentBooking;
      expect(multiSegmentBooking.flightDetails!.segments.length, 2);

      final bytes = await pdfService.generateFlightBookingPdf(multiSegmentBooking);
      expect(isValidPdf(bytes), isTrue);
    });

    test('Handles multiple hotel rooms and multiple guests', () async {
      final multiRoomHotelBooking = MockBookingData.hotelBooking.copyWith(
        hotelDetails: MockBookingData.hotelBooking.hotelDetails!.copyWith(
          numberOfRooms: 3,
          numberOfGuests: 6,
          rooms: const [
            HotelRoomDetails(
              roomType: 'Deluxe King Sea View',
              numberOfGuests: 2,
              pricePerNightUSD: 130.0,
            ),
            HotelRoomDetails(
              roomType: 'Executive Suite',
              numberOfGuests: 2,
              pricePerNightUSD: 200.0,
            ),
            HotelRoomDetails(
              roomType: 'Standard Twin Room',
              numberOfGuests: 2,
              pricePerNightUSD: 90.0,
            ),
          ],
        ),
      );

      final bytes = await pdfService.generateHotelBookingPdf(multiRoomHotelBooking);
      expect(isValidPdf(bytes), isTrue);
    });

    test('Supports both A4 and US Letter page formats', () async {
      final a4Bytes = await pdfService.generateBookingPdf(
        MockBookingData.flightBooking,
        format: PdfPageFormat.a4,
      );

      final letterBytes = await pdfService.generateBookingPdf(
        MockBookingData.flightBooking,
        format: PdfPageFormat.letter,
      );

      expect(isValidPdf(a4Bytes), isTrue);
      expect(isValidPdf(letterBytes), isTrue);
    });
  });
}
