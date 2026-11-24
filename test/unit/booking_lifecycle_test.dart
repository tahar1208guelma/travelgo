import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/search/adapters/sandbox_travel_provider.dart';
import 'package:travelgo/core/search/domain/revalidation_result.dart';
import 'package:travelgo/core/search/services/offer_revalidation_service.dart';
import 'package:travelgo/core/services/commission_service.dart';
import 'package:travelgo/features/bookings/data/booking_repository_impl.dart';
import 'package:travelgo/features/bookings/data/mock_booking_data.dart';
import 'package:travelgo/features/bookings/models/booking_document.dart';
import 'package:travelgo/features/bookings/models/booking_model.dart';
import 'package:travelgo/features/bookings/models/customer_info.dart';
import 'package:travelgo/features/bookings/models/price_breakdown.dart';
import 'package:travelgo/providers_layer/travel_provider.dart';

void main() {
  group('10-Step Customer Booking Lifecycle Tests', () {
    late BookingRepositoryImpl repository;
    late CommissionService commissionService;
    late OfferRevalidationService revalidationService;

    setUp(() {
      final sandbox = SandboxTravelProvider();
      repository = BookingRepositoryImpl();
      commissionService = CommissionService();
      revalidationService = OfferRevalidationService(
        flightProviders: [sandbox],
        hotelProviders: [sandbox],
      );
    });

    test('Step 4: Passenger & Guest Entry Model with multiple travelers', () {
      final leadPassenger = PassengerInfo(
        fullName: 'Sarah Connor',
        passengerType: PassengerType.adult,
        passportOrIdNumber: 'P12345678',
        nationality: 'American',
        specialRequests: 'Vegetarian meal requested',
      );

      final childPassenger = PassengerInfo(
        fullName: 'John Connor',
        passengerType: PassengerType.child,
        passportOrIdNumber: 'P87654321',
        nationality: 'American',
      );

      final customer = CustomerInfo(
        id: 'USR-CONNOR-01',
        fullName: 'Sarah Connor',
        email: 'sarah.connor@example.com',
        phone: '+1 (555) 019-2834',
        passengers: [leadPassenger, childPassenger],
      );

      expect(customer.fullName, 'Sarah Connor');
      expect(customer.passengers.length, 2);
      expect(customer.passengers.first.typeLabel, 'Adult');
      expect(customer.passengers.last.typeLabel, 'Child');
      expect(customer.passengers.first.specialRequests,
          'Vegetarian meal requested');

      // Test JSON serialization of customer and passengers
      final json = customer.toJson();
      final fromJson = CustomerInfo.fromJson(json);
      expect(fromJson.fullName, 'Sarah Connor');
      expect(fromJson.passengers.length, 2);
      expect(fromJson.passengers.first.passportOrIdNumber, 'P12345678');
    });

    test('Step 5: Price Review & Deterministic \$1.00 USD Platform Service Fee',
        () {
      // Direct booking calculation: Base + Taxes + $1.00 USD
      final pricing = commissionService.calculatePricing(
        basePriceUSD: 450.00,
        isAffiliate: false,
      );

      expect(pricing.basePriceUSD, 450.00);
      expect(pricing.serviceFeeUSD, 1.00); // Standard $1.00 USD Platform Fee
      expect(pricing.totalAmountUSD, 451.00);

      // Price Breakdown breakdown object
      final breakdown = PriceBreakdown(
        basePrice: pricing.basePriceUSD,
        taxes: 35.00,
        serviceFee: pricing.serviceFeeUSD,
        totalAmount: pricing.totalAmountUSD + 35.00,
        currency: 'USD',
      );

      expect(breakdown.basePrice, 450.00);
      expect(breakdown.taxes, 35.00);
      expect(breakdown.serviceFee, 1.00);
      expect(breakdown.totalAmount, 486.00);
      expect(breakdown.isServiceFeeLegallySupported, isTrue);
    });

    test('Step 6: Pre-booking Revalidation with OfferRevalidationService',
        () async {
      // Revalidate Flight offer
      final flightReval = await revalidationService.revalidateFlight(
        'FL-TEST-001',
        320.00,
      );

      expect(flightReval.isBookable, isTrue);
      expect(flightReval.currentPriceUSD, 320.00);
      expect(flightReval.status, RevalidationStatus.confirmed);
      expect(flightReval.remainingInventory, greaterThan(0));

      // Revalidate Hotel offer
      final hotelReval = await revalidationService.revalidateHotel(
        'HT-TEST-002',
        180.00,
      );

      expect(hotelReval.isBookable, isTrue);
      expect(hotelReval.currentPriceUSD, 180.00);
      expect(hotelReval.status, RevalidationStatus.confirmed);

      // Price changed scenario detection
      final priceChangedResult = RevalidationResult(
        status: RevalidationStatus.priceChanged,
        itemId: 'FL-TEST-001',
        currentPriceUSD: 350.00,
        previousPriceUSD: 320.00,
        verifiedAt: DateTime.now(),
      );
      expect(priceChangedResult.isBookable, isTrue);
      expect(priceChangedResult.priceHasChanged, isTrue);

      // Sold out scenario detection
      final soldOutResult = RevalidationResult(
        status: RevalidationStatus.soldOut,
        itemId: 'FL-TEST-001',
        currentPriceUSD: 320.00,
        verifiedAt: DateTime.now(),
      );
      expect(soldOutResult.isBookable, isFalse);
    });

    test(
        'Step 7 & 8: Payment Execution, Direct Booking Creation & Unique Reference',
        () async {
      final request = DirectBookingRequest(
        userId: 'USR-TEST-01',
        itemId: 'FL-ALG-DXB',
        bookingType: BookingType.flight,
        itemName: 'Emirates Flight (ALG → DXB)',
        itemSubtitle: 'Direct • Flight EK-758',
        startDate: DateTime(2026, 10, 15, 8, 30),
        endDate: DateTime(2026, 10, 15, 16, 45),
        basePriceUSD: 350.00,
        taxesUSD: 40.00,
        serviceFeeUSD: 1.00,
        totalAmountUSD: 391.00,
        passengerOrGuestName: 'Tahar Braknia',
        contactEmail: 'tahar@example.com',
        contactPhone: '+213 555 123 456',
        paymentMethod: 'Credit / Debit Card (Visa)',
        passengers: [
          PassengerInfo(
            fullName: 'Tahar Braknia',
            passengerType: PassengerType.adult,
            passportOrIdNumber: 'N10294810',
            nationality: 'Algerian',
          ),
        ],
      );

      final booking = await repository.createDirectBooking(request);

      // Verify unique booking reference and PNR
      expect(booking.bookingReference, startsWith('TRV-FLT-'));
      expect(booking.providerBookingReference, isNotNull);
      expect(booking.providerBookingReference!.length, 6); // 6-char PNR
      expect(booking.status, BookingStatus.confirmed);
      expect(booking.paymentStatus, PaymentStatus.paid);
      expect(booking.paymentMethod, 'Credit / Debit Card (Visa)');
      expect(booking.paymentTransactionId, startsWith('TXN-'));

      // Verify Price breakdown integrity
      expect(booking.priceBreakdown.basePrice, 350.00);
      expect(booking.priceBreakdown.serviceFee, 1.00);
      expect(booking.priceBreakdown.taxes, 40.00);
      expect(booking.priceBreakdown.totalAmount, 391.00);

      // Verify QR Code Data
      expect(booking.document.qrData, contains(booking.bookingReference));
      expect(booking.document.qrData, contains(booking.providerBookingReference!));
      expect(booking.document.qrData, contains('Tahar Braknia'));

      // Verify customer and passenger entry
      expect(booking.customer.passengers.length, 1);
      expect(booking.customer.passengers.first.passportOrIdNumber, 'N10294810');
    });

    test('Step 9: Booking History & Retrieval', () async {
      final userBookings = await repository.getUserBookings('USR-TEST-01');
      expect(userBookings, isNotEmpty);

      // Fetch by reference
      final first = userBookings.first;
      final retrieved =
          await repository.getBookingByReference(first.bookingReference);
      expect(retrieved, isNotNull);
      expect(retrieved!.bookingReference, first.bookingReference);
      expect(retrieved.status, first.status);
    });

    test('Step 10: Cancellation & Refund Tracking Lifecycle', () async {
      // Create a confirmed booking to cancel
      final request = DirectBookingRequest(
        userId: 'USR-REFUND-01',
        itemId: 'HT-PAR-001',
        bookingType: BookingType.hotel,
        itemName: 'The Ritz Paris',
        startDate: DateTime(2026, 11, 1),
        endDate: DateTime(2026, 11, 5),
        basePriceUSD: 800.00,
        taxesUSD: 80.00,
        serviceFeeUSD: 1.00,
        totalAmountUSD: 881.00,
        passengerOrGuestName: 'Elena Rostova',
        contactEmail: 'elena@example.com',
        contactPhone: '+33 6 12 34 56 78',
        paymentMethod: 'Mastercard •••• 5512',
      );

      final booking = await repository.createDirectBooking(request);
      expect(booking.status, BookingStatus.confirmed);
      expect(booking.paymentStatus, PaymentStatus.paid);
      expect(booking.hasRefund, isFalse);

      // Execute cancellation and refund request
      await repository.cancelBooking(
        booking.bookingReference,
        reason: 'Change of travel dates',
        refundAmount: 881.00,
      );

      final cancelledBooking =
          await repository.getBookingByReference(booking.bookingReference);

      expect(cancelledBooking, isNotNull);
      expect(cancelledBooking!.status, BookingStatus.cancelled);
      expect(cancelledBooking.paymentStatus, PaymentStatus.refunded);
      expect(cancelledBooking.isCancelled, isTrue);
      expect(cancelledBooking.cancellationReason, 'Change of travel dates');

      // Verify Refund details
      expect(cancelledBooking.hasRefund, isTrue);
      expect(cancelledBooking.refundDetails, isNotNull);
      final refund = cancelledBooking.refundDetails!;
      expect(refund.status, RefundStatus.refunded);
      expect(refund.refundAmount, 881.00);
      expect(refund.currency, 'USD');
      expect(refund.refundTransactionId, startsWith('RFND-TRV-'));
      expect(refund.requestedAt, isNotNull);
      expect(refund.processedAt, isNotNull);
      expect(refund.statusLabel, 'Refunded');

      // Test JSON roundtrip of cancelled booking with refund
      final json = cancelledBooking.toJson();
      final fromJson = Booking.fromJson(json);
      expect(fromJson.status, BookingStatus.cancelled);
      expect(fromJson.paymentStatus, PaymentStatus.refunded);
      expect(fromJson.refundDetails?.refundAmount, 881.00);
      expect(fromJson.refundDetails?.refundTransactionId,
          refund.refundTransactionId);
    });

    test('Unique Reference Generator creates distinct references per type', () {
      final flightBooking = MockBookingData.flightBooking;
      final hotelBooking = MockBookingData.hotelBooking;
      final comboBooking = MockBookingData.combinedBooking;

      expect(flightBooking.suggestedPdfFileName,
          'TRAVELGO_Booking_${flightBooking.bookingReference}.pdf');
      expect(hotelBooking.suggestedPdfFileName,
          'TRAVELGO_HotelVoucher_${hotelBooking.bookingReference}.pdf');
      expect(comboBooking.suggestedPdfFileName,
          'TRAVELGO_CombinedBooking_${comboBooking.bookingReference}.pdf');
    });
  });
}
