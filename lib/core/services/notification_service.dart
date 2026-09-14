import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NotificationType { bookingConfirmed, bookingCancelled, priceAlert, promoOffer }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

final notificationServiceProvider = StateNotifierProvider<NotificationService, List<AppNotification>>((ref) {
  return NotificationService();
});

class NotificationService extends StateNotifier<List<AppNotification>> {
  NotificationService() : super([]) {
    _initDefaultNotifications();
  }

  void _initDefaultNotifications() {
    state = [
      AppNotification(
        id: 'notif_welcome',
        title: 'Welcome to TRAVELGO ✈️',
        body: 'Discover exclusive discounted flight & hotel deals across 500+ destinations.',
        type: NotificationType.promoOffer,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      AppNotification(
        id: 'notif_summer_promo',
        title: 'Dubai Luxury Getaway ☀️',
        body: 'Enjoy up to 25% off 5-star Dubai resorts this season with direct flight connections.',
        type: NotificationType.promoOffer,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  void addNotification({
    required String title,
    required String body,
    required NotificationType type,
  }) {
    final notif = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
    );
    state = [notif, ...state];
  }

  void markAsRead(String id) {
    state = state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
  }

  void clearAll() {
    state = [];
  }
}
