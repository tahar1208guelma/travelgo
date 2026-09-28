import '../../../../providers_layer/travel_provider.dart';
import '../../models/booking_model.dart';
import '../entities/affiliate_click_entity.dart';

abstract class BookingRepository {
  Future<List<Booking>> getUserBookings(String userId);
  Future<Booking?> getBookingByReference(String reference);
  Future<Booking> createBooking(Booking booking);
  Future<Booking> createDirectBooking(DirectBookingRequest request);
  Future<AffiliateClickEntity> handleAffiliateRedirect({
    required String userId,
    required String productType,
    required String productId,
    required String rawTargetUrl,
  });
  Future<void> cancelBooking(String bookingId, {String? reason});
}
