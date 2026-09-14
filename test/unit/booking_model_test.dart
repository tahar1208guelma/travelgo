import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/features/bookings/data/mock_booking_data.dart';
import 'package:travelgo/features/bookings/models/booking_document.dart';
import 'package:travelgo/features/bookings/models/booking_model.dart';
import 'package:travelgo/features/bookings/models/customer_info.dart';
import 'package:travelgo/features/bookings/models/flight_booking_details.dart';
import 'package:travelgo/features/bookings/models/hotel_booking_details.dart';
import 'package:travelgo/features/bookings/models/price_breakdown.dart';

void main() {
  group('Booking Models Tests', () {
    test('Standard Confirmed Flight Booking Model (TRV-2026-000001)', () {
      final booking = MockBookingData.flightBooking;

      expect(booking.bookingReference, 'TRV-2026-000001');
      expect(booking.customer.fullName, 'Tahar Braknia');
      expect(booking.bookingType, BookingType.flight);
      expect(booking.status, BookingStatus.confirmed);
      expect(booking.priceBreakdown.basePrice, 250.00);
      expect(booking.priceBreakdown.serviceFee, 1.00);
      expect(booking.priceBreakdown.totalAmount, 251.00);
      expect(booking.priceBreakdown.currency, 'USD');

      // Check flight details
      expect(booking.flightDetails, isNotNull);
      expect(booking.flightDetails!.segments.length, 1);
      final segment = booking.flightDetails!.primarySegment;
      expect(segment.airline, 'Demo Airline');
      expect(segment.flightNumber, 'TG100');
      expect(segment.departureAirportCode, 'ALG');
      expect(segment.arrivalAirportCode, 'IST');
      expect(segment.cabinClass, 'Economy');
      expect(booking.document.isDemo, isTrue);
      expect(booking.document.qrData, 'TRV-2026-000001');
    });

    test('Standard Hotel Voucher Model (TRV-2026-000002)', () {
      final hotelBooking = MockBookingData.hotelBooking;

      expect(hotelBooking.bookingReference, 'TRV-2026-000002');
      expect(hotelBooking.bookingType, BookingType.hotel);
      expect(hotelBooking.status, BookingStatus.confirmed);
      expect(hotelBooking.hotelDetails, isNotNull);
      expect(hotelBooking.hotelDetails!.hotelName, 'Bosphorus Grand Palace Hotel');
      expect(hotelBooking.hotelDetails!.numberOfNights, 5);
      expect(hotelBooking.hotelDetails!.numberOfGuests, 2);
      expect(hotelBooking.priceBreakdown.totalAmount, 651.00);
      expect(hotelBooking.suggestedPdfFileName, 'TRAVELGO_HotelVoucher_TRV-2026-000002.pdf');
    });

    test('Combined Flight + Hotel Booking Model (TRV-2026-000003)', () {
      final combo = MockBookingData.combinedBooking;

      expect(combo.bookingReference, 'TRV-2026-000003');
      expect(combo.bookingType, BookingType.flightAndHotel);
      expect(combo.flightDetails, isNotNull);
      expect(combo.hotelDetails, isNotNull);
      expect(combo.priceBreakdown.totalAmount, 891.00);
      expect(combo.suggestedPdfFileName, 'TRAVELGO_CombinedBooking_TRV-2026-000003.pdf');
    });

    test('Cancelled and Failed Booking States', () {
      final cancelled = MockBookingData.cancelledBooking;
      expect(cancelled.status, BookingStatus.cancelled);
      expect(cancelled.statusLabel, 'Cancelled');
      expect(cancelled.cancellationReason, isNotNull);

      final failed = cancelled.copyWith(status: BookingStatus.failed);
      expect(failed.status, BookingStatus.failed);
      expect(failed.statusLabel, 'Failed');
    });

    test('JSON Serialization and Deserialization Roundtrip', () {
      final original = MockBookingData.flightBooking;
      final jsonMap = original.toJson();
      final reconstructed = Booking.fromJson(jsonMap);

      expect(reconstructed.bookingId, original.bookingId);
      expect(reconstructed.bookingReference, original.bookingReference);
      expect(reconstructed.bookingType, original.bookingType);
      expect(reconstructed.status, original.status);
      expect(reconstructed.customer.fullName, original.customer.fullName);
      expect(reconstructed.priceBreakdown.totalAmount, original.priceBreakdown.totalAmount);
      expect(reconstructed.flightDetails?.originCode, original.flightDetails?.originCode);
      expect(reconstructed.flightDetails?.destinationCode, original.flightDetails?.destinationCode);
    });

    test('Price breakdown service fee integrity', () {
      const pricing = PriceBreakdown(
        basePrice: 500.0,
        serviceFee: 1.0,
        taxes: 50.0,
        totalAmount: 551.0,
      );

      expect(pricing.basePrice, 500.0);
      expect(pricing.serviceFee, 1.0);
      expect(pricing.taxes, 50.0);
      expect(pricing.totalAmount, 551.0);
    });
  });
}
