import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:travelgo/core/services/pdf_service.dart';
import 'package:travelgo/features/bookings/data/mock_bookings_data.dart';
import 'package:travelgo/features/bookings/models/booking.dart';
import 'package:travelgo/features/bookings/models/booking_status.dart';
import 'package:travelgo/features/bookings/models/booking_type.dart';
import 'package:travelgo/features/bookings/models/flight_booking_details.dart';
import 'package:travelgo/features/bookings/models/hotel_booking_details.dart';
import 'package:travelgo/features/bookings/models/passenger.dart';
import 'package:travelgo/features/bookings/models/price_breakdown.dart';

void main() {
  late PdfService pdfService;

  setUp(() {
    pdfService = PdfService();
  });

  bool isValidPdf(Uint8List bytes) {
    if (bytes.length < 5) return false;
    final header = String.fromCharCodes(bytes.sublist(0, 5));
    return header.startsWith('%PDF');
  }

  group('PdfService - Generation Tests', () {
    test('generateFlightBookingPdf generates valid non-empty PDF bytes for primary mock', () async {
      final bytes = await pdfService.generateFlightBookingPdf(
        MockBookingsData.flightBookingMock,
        format: PdfPageFormat.a4,
      );

      expect(bytes, isNotEmpty);
      expect(isValidPdf(bytes), isTrue);
      expect(bytes.length, greaterThan(1000));
    });

    test('generateFlightBookingPdf supports US Letter page format', () async {
      final bytes = await pdfService.generateFlightBookingPdf(
        MockBookingsData.flightBookingMock,
        format: PdfPageFormat.letter,
      );

      expect(bytes, isNotEmpty);
      expect(isValidPdf(bytes), isTrue);
    });

    test('generateHotelBookingPdf generates valid non-empty PDF bytes', () async {
      final bytes = await pdfService.generateHotelBookingPdf(
        MockBookingsData.hotelBookingMock,
        format: PdfPageFormat.a4,
      );

      expect(bytes, isNotEmpty);
      expect(isValidPdf(bytes), isTrue);
    });

    test('generateCombinedBookingPdf generates valid non-empty PDF bytes', () async {
      final bytes = await pdfService.generateCombinedBookingPdf(
        MockBookingsData.combinedBookingMock,
        format: PdfPageFormat.a4,
      );

      expect(bytes, isNotEmpty);
      expect(isValidPdf(bytes), isTrue);
    });

    test('generateBookingPdf delegates correctly based on bookingType', () async {
      final flightBytes = await pdfService.generateBookingPdf(MockBookingsData.flightBookingMock);
      final hotelBytes = await pdfService.generateBookingPdf(MockBookingsData.hotelBookingMock);
      final comboBytes = await pdfService.generateBookingPdf(MockBookingsData.combinedBookingMock);

      expect(isValidPdf(flightBytes), isTrue);
      expect(isValidPdf(hotelBytes), isTrue);
      expect(isValidPdf(comboBytes), isTrue);
    });

    test('Handles long passenger names without overflow or error', () async {
      final longNameBooking = Booking(
        bookingId: 'BK-LONG-NAME-001',
        bookingReference: 'TRV-2026-LONGNAME',
        bookingType: BookingType.flight,
        status: BookingStatus.confirmed,
        customerName: 'His Royal Highness Prince Mohammed Al-Sayyid Abdulrahman bin Tariq Al-Mansoor',
        customerEmail: 'prince.abdulrahman.longemail@diplomatic-domain.example.com',
        provider: 'TRAVELGO VIP Aviation Services Direct',
        createdAt: DateTime(2026, 9, 1),
        price: const PriceBreakdown(
          basePrice: 1200.0,
          serviceFee: 15.0,
          currency: 'USD',
          totalAmount: 1215.0,
        ),
        flightDetails: FlightBookingDetails(
          passengers: const [
            Passenger(
              id: 'P-1',
              fullName: 'His Royal Highness Prince Mohammed Al-Sayyid Abdulrahman bin Tariq Al-Mansoor III',
              passengerType: PassengerType.adult,
            ),
          ],
          segments: [
            FlightSegment(
              airline: 'Emirates First Class Luxury Line',
              flightNumber: 'EK9999',
              departureAirport: 'Dubai International Airport Worldwide Terminal 3 Concourse A',
              departureAirportCode: 'DXB',
              departureCity: 'Dubai',
              departureDateTime: DateTime(2026, 9, 20, 8, 0),
              arrivalAirport: 'London Heathrow Airport Terminal 5 Queen Elizabeth Wing',
              arrivalAirportCode: 'LHR',
              arrivalCity: 'London',
              arrivalDateTime: DateTime(2026, 9, 20, 14, 0),
              duration: const Duration(hours: 7),
              cabinClass: 'First Class Private Suite',
              baggageAllowance: '3 x 32 kg check-in baggage + 2 x 10 kg cabin baggage',
            ),
          ],
        ),
      );

      final bytes = await pdfService.generateBookingPdf(longNameBooking);
      expect(isValidPdf(bytes), isTrue);
    });

    test('Handles multi-segment flights generating multi-page or structured PDF cleanly', () async {
      final multiSegmentBooking = Booking(
        bookingId: 'BK-MULTI-SEG',
        bookingReference: 'TRV-2026-MULTI01',
        bookingType: BookingType.flight,
        status: BookingStatus.confirmed,
        customerName: 'Tahar Braknia',
        customerEmail: 'tahar@example.com',
        provider: 'TRAVELGO Multi-City',
        createdAt: DateTime(2026, 8, 25),
        price: const PriceBreakdown(
          basePrice: 850.0,
          serviceFee: 5.0,
          taxesAndFees: 45.0,
          currency: 'USD',
          totalAmount: 900.0,
        ),
        flightDetails: FlightBookingDetails(
          passengers: const [
            Passenger(id: 'P-1', fullName: 'Tahar Braknia', seatNumber: '12A'),
            Passenger(id: 'P-2', fullName: 'Sarah Braknia', seatNumber: '12B'),
          ],
          segments: [
            FlightSegment(
              airline: 'Air Algerie',
              flightNumber: 'AH1000',
              departureAirport: 'Houari Boumediene',
              departureAirportCode: 'ALG',
              departureCity: 'Algiers',
              departureDateTime: DateTime(2026, 9, 15, 8, 0),
              arrivalAirport: 'Charles de Gaulle',
              arrivalAirportCode: 'CDG',
              arrivalCity: 'Paris',
              arrivalDateTime: DateTime(2026, 9, 15, 11, 30),
              duration: const Duration(hours: 2, minutes: 30),
            ),
            FlightSegment(
              airline: 'Air France',
              flightNumber: 'AF084',
              departureAirport: 'Charles de Gaulle',
              departureAirportCode: 'CDG',
              departureCity: 'Paris',
              departureDateTime: DateTime(2026, 9, 15, 15, 0),
              arrivalAirport: 'San Francisco Intl',
              arrivalAirportCode: 'SFO',
              arrivalCity: 'San Francisco',
              arrivalDateTime: DateTime(2026, 9, 15, 18, 45),
              duration: const Duration(hours: 11, minutes: 45),
            ),
          ],
        ),
      );

      final bytes = await pdfService.generateBookingPdf(multiSegmentBooking);
      expect(isValidPdf(bytes), isTrue);
    });

    test('Handles multiple hotel rooms and minimal optional fields', () async {
      final multiRoomBooking = Booking(
        bookingId: 'BK-HOTEL-MULTI',
        bookingReference: 'TRV-2026-HTL-MULTI',
        bookingType: BookingType.hotel,
        status: BookingStatus.confirmed,
        customerName: 'Tahar Braknia',
        customerEmail: 'tahar@example.com',
        provider: 'TRAVELGO Hotel Hub',
        createdAt: DateTime(2026, 8, 20),
        price: const PriceBreakdown(
          basePrice: 1200.0,
          currency: 'EUR',
          totalAmount: 1200.0,
        ),
        hotelDetails: HotelBookingDetails(
          hotelName: 'Algiers Bay Grand Resort & Spa',
          hotelAddress: 'Les Andalouses Coastal Boulevard',
          checkInDate: DateTime(2026, 10, 1),
          checkOutDate: DateTime(2026, 10, 8),
          numberOfNights: 7,
          numberOfGuests: 6,
          guestName: 'Tahar Braknia',
          mealPlan: 'All Inclusive',
          cancellationPolicy: 'Free cancellation up to 48h before arrival',
          rooms: const [
            HotelRoom(roomType: 'Presidential Suite', numberOfGuests: 2, bedType: '1 Super King'),
            HotelRoom(roomType: 'Deluxe Twin Room', numberOfGuests: 2, bedType: '2 Queen Beds'),
            HotelRoom(roomType: 'Standard King Room', numberOfGuests: 2, bedType: '1 King Bed'),
          ],
        ),
      );

      final bytes = await pdfService.generateBookingPdf(multiRoomBooking);
      expect(isValidPdf(bytes), isTrue);
    });
  });
}
