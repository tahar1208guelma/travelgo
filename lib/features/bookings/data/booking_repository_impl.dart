import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../booking/domain/entities/affiliate_click_entity.dart';
import '../models/booking_model.dart';
import 'mock_booking_data.dart';

abstract class BookingRepository {
  Future<List<Booking>> getUserBookings(String userId);
  Future<Booking?> getBookingByReference(String reference);
  Future<Booking> createBooking(Booking booking);
  Future<void> cancelBooking(String bookingId, {String? reason});
}

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepositoryImpl();
});

class BookingRepositoryImpl implements BookingRepository {
  final List<Booking> _bookings = List.from(MockBookingData.defaultBookings);

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
