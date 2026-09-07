import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/features/bookings/data/mock_bookings_data.dart';
import 'package:travelgo/features/bookings/models/booking.dart';
import 'package:travelgo/features/bookings/models/booking_status.dart';
import 'package:travelgo/features/bookings/models/booking_type.dart';
import 'package:travelgo/features/bookings/models/price_breakdown.dart';

void main() {
  group('Booking Model & PriceBreakdown Tests', () {
    test('Primary mock booking matches Requirement 17 specification', () {
      final b = MockBookingsData.flightBookingMock;
      expect(b.bookingReference, equals('TRV-2026-000001'));
      expect(b.customerName, equals('Tahar Braknia'));
      expect(b.flightDetails, isNotNull);
      expect(b.flightDetails!.passengers.first.fullName, equals('Tahar Braknia'));
      expect(b.flightDetails!.primarySegment.departureAirportCode, equals('ALG'));
      expect(b.flightDetails!.primarySegment.arrivalAirportCode, equals('IST'));
      expect(b.flightDetails!.primarySegment.airline, equals('Demo Airline'));
      expect(b.flightDetails!.primarySegment.flightNumber, equals('TG100'));
      expect(b.flightDetails!.primarySegment.cabinClass, equals('Economy'));
      expect(b.price.basePrice, equals(250.00));
      expect(b.price.serviceFee, equals(1.00));
      expect(b.price.totalAmount, equals(251.00));
      expect(b.price.currency, equals('USD'));
      expect(b.isDemo, isTrue);
      expect(b.status, equals(BookingStatus.confirmed));
    });

    test('Hotel voucher mock model structure and fields', () {
      final h = MockBookingsData.hotelBookingMock;
      expect(h.bookingReference, equals('TRV-2026-000002'));
      expect(h.bookingType, equals(BookingType.hotel));
      expect(h.hotelDetails, isNotNull);
      expect(h.hotelDetails!.hotelName, equals('Bosphorus View Grand Hotel'));
      expect(h.hotelDetails!.numberOfNights, equals(5));
      expect(h.price.serviceFee, isNull);
      expect(h.price.totalAmount, equals(650.00));
    });

    test('Booking status and types verification', () {
      expect(MockBookingsData.cancelledBookingMock.status, equals(BookingStatus.cancelled));
      expect(MockBookingsData.failedBookingMock.status, equals(BookingStatus.failed));
      expect(MockBookingsData.combinedBookingMock.bookingType, equals(BookingType.flightAndHotel));
    });

    test('PriceBreakdown calculation helper flags', () {
      const priceWithFee = PriceBreakdown(
        basePrice: 100,
        serviceFee: 5,
        currency: 'USD',
        totalAmount: 105,
      );
      expect(priceWithFee.hasServiceFee, isTrue);
      expect(priceWithFee.hasTaxesAndFees, isFalse);
      expect(priceWithFee.hasDiscount, isFalse);

      const priceWithoutFee = PriceBreakdown(
        basePrice: 100,
        serviceFee: null,
        taxesAndFees: 10,
        discount: 5,
        currency: 'USD',
        totalAmount: 105,
      );
      expect(priceWithoutFee.hasServiceFee, isFalse);
      expect(priceWithoutFee.hasTaxesAndFees, isTrue);
      expect(priceWithoutFee.hasDiscount, isTrue);
    });

    test('Booking model serialization toMap and fromMap roundtrip', () {
      final original = MockBookingsData.flightBookingMock;
      final map = original.toMap();
      final reconstructed = Booking.fromMap(map);

      expect(reconstructed.bookingId, equals(original.bookingId));
      expect(reconstructed.bookingReference, equals(original.bookingReference));
      expect(reconstructed.bookingType, equals(original.bookingType));
      expect(reconstructed.status, equals(original.status));
      expect(reconstructed.customerName, equals(original.customerName));
      expect(reconstructed.price.totalAmount, equals(original.price.totalAmount));
      expect(reconstructed.flightDetails?.primarySegment.flightNumber,
          equals(original.flightDetails?.primarySegment.flightNumber));
    });

    test('PriceBreakdown.calculateWithTravelGoFee calculates precise 0.75% fee', () {
      // 0.75% of 250 = 1.88 (rounded to 2 decimal places)
      final p1 = PriceBreakdown.calculateWithTravelGoFee(basePrice: 250.00);
      expect(p1.basePrice, equals(250.00));
      expect(p1.serviceFee, equals(1.88));
      expect(p1.totalAmount, equals(251.88));
      expect(p1.hasServiceFee, isTrue);

      // 0.75% of 1000 = 7.50
      final p2 = PriceBreakdown.calculateWithTravelGoFee(
        basePrice: 1000.00,
        taxesAndFees: 120.00,
      );
      expect(p2.basePrice, equals(1000.00));
      expect(p2.serviceFee, equals(7.50));
      expect(p2.taxesAndFees, equals(120.00));
      expect(p2.totalAmount, equals(1127.50));

      // 0.75% of 100 = 0.75
      final p3 = PriceBreakdown.calculateWithTravelGoFee(
        basePrice: 100.00,
        discount: 10.00,
      );
      expect(p3.serviceFee, equals(0.75));
      expect(p3.totalAmount, equals(90.75));
    });
  });
}
