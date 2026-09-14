import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/commission_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../providers_layer/travel_provider.dart';
import '../../../flights/presentation/controllers/flight_search_controller.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/affiliate_click_entity.dart';
import '../../domain/entities/booking_entity.dart';

final bookingRepositoryProvider = Provider<BookingRepositoryImpl>((ref) {
  final provider = ref.watch(travelProviderRef);
  return BookingRepositoryImpl(provider);
});

final bookingListProvider = StateNotifierProvider<BookingListNotifier, List<BookingEntity>>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return BookingListNotifier(repository);
});

class BookingListNotifier extends StateNotifier<List<BookingEntity>> {
  final BookingRepositoryImpl _repository;

  BookingListNotifier(this._repository) : super([]);

  Future<void> loadUserBookings(String userId) async {
    final list = await _repository.getUserBookings(userId);
    state = list;
  }

  void addBooking(BookingEntity booking) {
    state = [booking, ...state];
  }

  Future<void> cancelBooking(String bookingId) async {
    await _repository.cancelBooking(bookingId);
    state = state.map((b) => b.id == bookingId ? b.copyWith(status: BookingStatus.cancelled) : b).toList();
  }
}

final bookingControllerProvider = StateNotifierProvider<BookingController, AsyncValue<BookingEntity?>>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider.notifier);
  final listNotifier = ref.watch(bookingListProvider.notifier);
  return BookingController(repository, notificationService, listNotifier);
});

class BookingController extends StateNotifier<AsyncValue<BookingEntity?>> {
  final BookingRepositoryImpl _repository;
  final NotificationService _notificationService;
  final BookingListNotifier _listNotifier;

  BookingController(this._repository, this._notificationService, this._listNotifier)
      : super(const AsyncValue.data(null));

  Future<BookingEntity?> processDirectBooking(DirectBookingRequest request) async {
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
