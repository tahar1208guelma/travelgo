import 'package:intl/intl.dart';

class AppDateFormatter {
  AppDateFormatter._();

  static String formatDate(DateTime date, {String locale = 'en'}) {
    return DateFormat('EEE, d MMM yyyy', locale).format(date);
  }

  static String formatShortDate(DateTime date, {String locale = 'en'}) {
    return DateFormat('d MMM', locale).format(date);
  }

  static String formatTime(DateTime dateTime, {String locale = 'en'}) {
    return DateFormat('HH:mm', locale).format(dateTime);
  }

  static String formatDateTime(DateTime dateTime, {String locale = 'en'}) {
    return DateFormat('d MMM yyyy, HH:mm', locale).format(dateTime);
  }

  static String formatDuration(Duration duration, {bool isArabic = false}) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (isArabic) {
      if (hours > 0 && minutes > 0) {
        return '$hours س $minutes د';
      } else if (hours > 0) {
        return '$hours س';
      } else {
        return '$minutes د';
      }
    } else {
      if (hours > 0 && minutes > 0) {
        return '${hours}h ${minutes}m';
      } else if (hours > 0) {
        return '${hours}h';
      } else {
        return '${minutes}m';
      }
    }
  }

  static int calculateNights(DateTime checkIn, DateTime checkOut) {
    final start = DateTime(checkIn.year, checkIn.month, checkIn.day);
    final end = DateTime(checkOut.year, checkOut.month, checkOut.day);
    final diff = end.difference(start).inDays;
    return diff > 0 ? diff : 1;
  }
}
