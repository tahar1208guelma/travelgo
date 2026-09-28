import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../providers_layer/travel_provider.dart';
import '../../data/booking_repository_impl.dart';
import '../../domain/entities/affiliate_click_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../models/booking_model.dart';

final bookingListProvider = StateNotifierProvider<BookingListNotifier, List<Booking>>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return BookingListNotifier(repository);
});

class BookingListNotifier extends StateNotifier<List<Booking>> {
  final BookingRepository _repository;

  BookingListNotifier(this._repository) : super([]) {
    loadUserBookings('default_usr');
  }

  Future<void> loadUserBookings(String userId) async {
    final list = await _repository.getUserBookings(userId);
    state = list;
  }

  void addBooking(Booking booking) {
    state = [booking, ...state];
  }

  Future<void> cancelBooking(String bookingId, {String? reason}) async {
    await _repository.cancelBooking(bookingId, reason: reason);
    state = state.map((b) => b.id == bookingId ? b.copyWith(status: BookingStatus.cancelled, cancellationReason: reason) : b).toList();
  }
}

final bookingControllerProvider = StateNotifierProvider<BookingController, AsyncValue<Booking?>>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider.notifier);
  final listNotifier = ref.watch(bookingListProvider.notifier);
  return BookingController(repository, notificationService, listNotifier);
});

class BookingController extends StateNotifier<AsyncValue<Booking?>> {
  final BookingRepository _repository;
  final NotificationService _notificationService;
  final BookingListNotifier _listNotifier;

  BookingController(this._repository, this._notificationService, this._listNotifier)
      : super(const AsyncValue.data(null));

  Future<Booking?> processDirectBooking(DirectBookingRequest request) async {
    state = const AsyncValue.loading();
    try {
      final booking = await _repository.createDirectBooking(request);
      _listNotifier.addBooking(booking);
      
      _notificationService.addNotification(
        title: 'Booking Confirmed! ✈️',
        body: 'Reservation for ${booking.itemName} (PNR: ${booking.externalBookingReference}) is confirmed.',
        type: NotificationType.bookingConfirmed,
      );

      state = AsyncValue.data(booking);
      return booking;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<AffiliateClickEntity?> trackAffiliateRedirect({
    required String userId,
    required String productType,
    required String productId,
    required String rawTargetUrl,
  }) async {
    try {
      final click = await _repository.handleAffiliateRedirect(
        userId: userId,
        productType: productType,
        productId: productId,
        rawTargetUrl: rawTargetUrl,
      );
      return click;
    } catch (e) {
      return null;
    }
  }
}
