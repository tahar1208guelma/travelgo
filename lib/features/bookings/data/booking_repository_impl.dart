import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers_layer/mock_travel_provider.dart';
import '../../../../providers_layer/travel_provider.dart';
import '../domain/entities/affiliate_click_entity.dart';
import '../domain/repositories/booking_repository.dart';
import '../models/booking_document.dart';
import '../models/booking_model.dart';
import '../models/customer_info.dart';
import '../models/price_breakdown.dart';
import 'mock_booking_data.dart';

final travelProvider = Provider<TravelProvider>((ref) => MockTravelProvider());

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final provider = ref.watch(travelProvider);
  return BookingRepositoryImpl(provider);
});

class BookingRepositoryImpl implements BookingRepository {
  final TravelProvider? _travelProvider;
  final List<Booking> _bookings = List.from(MockBookingData.defaultBookings);

  BookingRepositoryImpl([this._travelProvider]);

  String _generateReference(BookingType type) {
    final prefix = type == BookingType.flight
        ? 'FLT'
        : (type == BookingType.hotel ? 'HTL' : 'PKG');
    final year = DateTime.now().year;
    final randomSuffix = (Random().nextInt(900000) + 100000).toString();
    return 'TRV-$prefix-$year-$randomSuffix';
  }

  String _generatePnr() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  @override
  Future<List<Booking>> getUserBookings(String userId) async {
    return List.unmodifiable(_bookings);
  }

  @override
  Future<Booking?> getBookingByReference(String reference) async {
    try {
      return _bookings.firstWhere(
        (b) =>
            b.bookingReference == reference ||
            b.bookingId == reference ||
            b.id == reference,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Booking> createBooking(Booking booking) async {
    _bookings.insert(0, booking);
    return booking;
  }

  @override
  Future<Booking> createDirectBooking(DirectBookingRequest request) async {
    final reference = _generateReference(request.bookingType);
    final pnr = _generatePnr();
    final now = DateTime.now();

    final passengers = request.passengers != null && request.passengers!.isNotEmpty
        ? request.passengers!
        : [
            PassengerInfo(
              fullName: request.passengerOrGuestName,
              passengerType: PassengerType.adult,
              specialRequests: request.specialRequests,
            ),
          ];

    final customer = CustomerInfo(
      id: request.userId,
      fullName: request.passengerOrGuestName,
      email: request.contactEmail,
      phone: request.contactPhone,
      passengers: passengers,
    );

    final newBooking = Booking(
      bookingId: 'BK-${now.millisecondsSinceEpoch}',
      bookingReference: reference,
      providerBookingReference: pnr,
      bookingType: request.bookingType,
      status: BookingStatus.confirmed,
      paymentStatus: PaymentStatus.paid,
      customer: customer,
      provider: request.bookingType == BookingType.flight
          ? (request.itemSubtitle?.split('•').first.trim().isNotEmpty == true
              ? request.itemSubtitle!.split('•').first.trim()
              : 'TRAVELGO Flights Direct')
          : (request.bookingType == BookingType.hotel
              ? request.itemName
              : 'TRAVELGO Vacations Package'),
      priceBreakdown: PriceBreakdown(
        basePrice: request.basePriceUSD,
        taxes: request.taxesUSD,
        serviceFee: request.serviceFeeUSD, // $1.00 USD standard platform fee
        totalAmount: request.totalAmountUSD,
        currency: 'USD',
      ),
      flightDetails: request.flightDetails,
      hotelDetails: request.hotelDetails,
      createdAt: now,
      document: BookingDocument(
        documentId: 'DOC-$reference',
        bookingReference: reference,
        issuedAt: now,
        qrData: 'TRAVELGO:$reference:$pnr:${request.passengerOrGuestName}:${request.totalAmountUSD.toStringAsFixed(2)}',
        isDemo: true,
      ),
      paymentMethod: request.paymentMethod,
      paymentTransactionId: 'TXN-${now.millisecondsSinceEpoch}',
      customItemName: request.itemName,
      customItemSubtitle: request.itemSubtitle,
      customItemImageUrl: request.itemImageUrl,
    );

    _bookings.insert(0, newBooking);
    return newBooking;
  }

  @override
  Future<AffiliateClickEntity> handleAffiliateRedirect({
    required String userId,
    required String productType,
    required String productId,
    required String rawTargetUrl,
  }) {
    if (_travelProvider != null) {
      return _travelProvider!.generateAffiliateLink(
        userId: userId,
        productType: productType,
        productId: productId,
        rawTargetUrl: rawTargetUrl,
      );
    }
    return Future.value(
      AffiliateClickEntity(
        id: 'aff_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        provider: 'Affiliate Partner',
        productType: productType,
        productId: productId,
        trackingId: 'TRV-AFF-${DateTime.now().millisecondsSinceEpoch}',
        targetUrl: rawTargetUrl,
        clickedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> cancelBooking(
    String bookingId, {
    String? reason,
    double? refundAmount,
  }) async {
    final index = _bookings.indexWhere((b) =>
        b.bookingId == bookingId ||
        b.id == bookingId ||
        b.bookingReference == bookingId);

    if (index != -1) {
      final old = _bookings[index];
      final amount = refundAmount ?? old.priceBreakdown.totalAmount;
      final refund = RefundDetails(
        status: RefundStatus.refunded,
        refundAmount: amount,
        currency: old.priceBreakdown.currency,
        refundTransactionId:
            'RFND-TRV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        reason: reason ?? 'Cancelled by customer',
        requestedAt: DateTime.now(),
        processedAt: DateTime.now(),
        notes:
            'Refund processed back to original payment method (${old.paymentMethod ?? "Credit Card"}).',
      );

      _bookings[index] = old.copyWith(
        status: BookingStatus.cancelled,
        paymentStatus: PaymentStatus.refunded,
        cancellationReason: reason ?? 'Cancelled by customer',
        refundDetails: refund,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<RefundDetails?> requestRefund(
    String bookingId, {
    required String reason,
    double? amount,
  }) async {
    await cancelBooking(bookingId, reason: reason, refundAmount: amount);
    final booking = await getBookingByReference(bookingId);
    return booking?.refundDetails;
  }
}
