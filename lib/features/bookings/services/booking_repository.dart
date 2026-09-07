import '../data/mock_bookings_data.dart';
import '../models/booking.dart';
import '../models/booking_status.dart';
import '../models/booking_type.dart';

abstract class BookingRepository {
  Future<List<Booking>> getBookings({
    BookingType? typeFilter,
    BookingStatus? statusFilter,
  });
  Future<Booking?> getBookingById(String bookingId);
  Future<Booking?> getBookingByReference(String reference);
}

class MockBookingRepository implements BookingRepository {
  final List<Booking> _bookings;

  MockBookingRepository({List<Booking>? initialBookings})
      : _bookings = initialBookings ?? List.of(MockBookingsData.allMockBookings);

  @override
  Future<List<Booking>> getBookings({
    BookingType? typeFilter,
    BookingStatus? statusFilter,
  }) async {
    // Simulate brief asynchronous delay
    await Future.delayed(const Duration(milliseconds: 50));
    return _bookings.where((b) {
      if (typeFilter != null && b.bookingType != typeFilter) return false;
      if (statusFilter != null && b.status != statusFilter) return false;
      return true;
    }).toList();
  }

  @override
  Future<Booking?> getBookingById(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 30));
    try {
      return _bookings.firstWhere((b) => b.bookingId == bookingId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Booking?> getBookingByReference(String reference) async {
    await Future.delayed(const Duration(milliseconds: 30));
    try {
      return _bookings.firstWhere((b) => b.bookingReference.toUpperCase() == reference.toUpperCase());
    } catch (_) {
      return null;
    }
  }
}
