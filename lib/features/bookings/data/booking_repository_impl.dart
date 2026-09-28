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

  @override
  Future<List<Booking>> getUserBookings(String userId) async {
    // Return all mock bookings in order (newest first)
    return List.unmodifiable(_bookings);
  }

  @override
  Future<Booking?> getBookingByReference(String reference) async {
    try {
      return _bookings.firstWhere((b) => b.bookingReference == reference);
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
    if (_travelProvider != null) {
      final bookingEntity = await _travelProvider!.createDirectBooking(request);
      final booking = Booking(
        bookingId: bookingEntity.id,
        bookingReference: bookingEntity.externalBookingReference,
        bookingType: bookingEntity.bookingType == BookingType.flight
            ? BookingType.flight
            : BookingType.hotel,
        status: BookingStatus.confirmed,
        customer: CustomerInfo(
          id: bookingEntity.userId,
          fullName: bookingEntity.passengerOrGuestName,
          email: bookingEntity.contactEmail,
          phone: bookingEntity.contactPhone,
        ),
        provider: bookingEntity.provider,
        priceBreakdown: PriceBreakdown(
          basePrice: bookingEntity.basePriceUSD,
          taxes: bookingEntity.taxesUSD,
          serviceFee: bookingEntity.serviceFeeUSD,
          totalAmount: bookingEntity.totalAmountUSD,
          currency: bookingEntity.currency,
        ),
        createdAt: bookingEntity.createdAt,
        document: BookingDocument(
          documentId: 'DOC-${bookingEntity.externalBookingReference}',
          bookingReference: bookingEntity.externalBookingReference,
          issuedAt: bookingEntity.createdAt,
          qrData: bookingEntity.externalBookingReference,
        ),
      );
      _bookings.insert(0, booking);
      return booking;
    }

    final newBooking = Booking(
      bookingId: 'BK-${DateTime.now().millisecondsSinceEpoch}',
      bookingReference: 'TRV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      bookingType: request.bookingType,
      status: BookingStatus.confirmed,
      customer: CustomerInfo(
        id: request.userId,
        fullName: request.passengerOrGuestName,
        email: request.contactEmail,
        phone: request.contactPhone,
      ),
      provider: 'TRAVELGO Direct',
      priceBreakdown: PriceBreakdown(
        basePrice: request.basePriceUSD,
        taxes: request.taxesUSD,
        serviceFee: request.serviceFeeUSD,
        totalAmount: request.totalAmountUSD,
        currency: 'USD',
      ),
      createdAt: DateTime.now(),
      document: BookingDocument(
        documentId: 'DOC-${DateTime.now().millisecondsSinceEpoch}',
        bookingReference: 'TRV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        issuedAt: DateTime.now(),
        qrData: 'TRV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      ),
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
  Future<void> cancelBooking(String bookingId, {String? reason}) async {
    final index = _bookings.indexWhere((b) => b.bookingId == bookingId || b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.cancelled,
        cancellationReason: reason ?? 'Cancelled by customer',
      );
    }
  }
}
