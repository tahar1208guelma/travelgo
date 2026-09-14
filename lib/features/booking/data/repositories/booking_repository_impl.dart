import '../../../../providers_layer/travel_provider.dart';
import '../../domain/entities/affiliate_click_entity.dart';
import '../../domain/entities/booking_entity.dart';

abstract class BookingRepository {
  Future<List<BookingEntity>> getUserBookings(String userId);
  Future<BookingEntity> createDirectBooking(DirectBookingRequest request);
  Future<AffiliateClickEntity> handleAffiliateRedirect({
    required String userId,
    required String productType,
    required String productId,
    required String rawTargetUrl,
  });
  Future<void> cancelBooking(String bookingId);
}

class BookingRepositoryImpl implements BookingRepository {
  final TravelProvider _provider;
  final List<BookingEntity> _inMemoryBookings = [];

  BookingRepositoryImpl(this._provider);

  @override
  Future<List<BookingEntity>> getUserBookings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _inMemoryBookings;
  }

  @override
  Future<BookingEntity> createDirectBooking(DirectBookingRequest request) async {
    final booking = await _provider.createDirectBooking(request);
    _inMemoryBookings.insert(0, booking);
    return booking;
  }

  @override
  Future<AffiliateClickEntity> handleAffiliateRedirect({
    required String userId,
    required String productType,
    required String productId,
    required String rawTargetUrl,
  }) {
    return _provider.generateAffiliateLink(
      userId: userId,
      productType: productType,
      productId: productId,
      rawTargetUrl: rawTargetUrl,
    );
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    final index = _inMemoryBookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _inMemoryBookings[index] = _inMemoryBookings[index].copyWith(
        status: BookingStatus.cancelled,
        updatedAt: DateTime.now(),
      );
    }
  }
}
