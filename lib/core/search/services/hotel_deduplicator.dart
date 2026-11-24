import 'dart:math';
import '../../../features/hotels/domain/entities/hotel_entity.dart';

/// Hotel deduplication engine.
///
/// Discovers duplicate property listings across Direct Partner portals,
/// GDS networks (Amadeus), and OTA affiliates (Booking.com/Agoda).
///
/// Match criteria:
/// - Exact or substring normalized property name (English or Arabic)
/// - Geographic proximity (Haversine distance <= 150 meters)
///
/// Resolution priority:
/// 1. Direct partner listings take precedence over OTA affiliates (guaranteeing in-app direct booking).
/// 2. If both are the same channel, lowest price per night is retained.
/// 3. If prices are identical, higher user rating / review volume is preserved.
class HotelDeduplicator {
  List<HotelEntity> deduplicate(List<HotelEntity> hotels) {
    if (hotels.length <= 1) return hotels;

    final List<HotelEntity> uniqueHotels = [];

    for (final hotel in hotels) {
      final normEn = _normalizeEnglishName(hotel.nameEn);
      final normAr = _normalizeArabicName(hotel.nameAr);
      int matchIndex = -1;

      for (var i = 0; i < uniqueHotels.length; i++) {
        final existing = uniqueHotels[i];
        final existingNormEn = _normalizeEnglishName(existing.nameEn);
        final existingNormAr = _normalizeArabicName(existing.nameAr);

        // Check 1: English name normalization similarity
        final enMatch = _isNameMatch(normEn, existingNormEn);

        // Check 2: Arabic name normalization similarity
        final arMatch = _isNameMatch(normAr, existingNormAr);

        // Check 3: Geo-coordinate proximity (<= 150 meters)
        final distanceMeters = _haversineMeters(
          hotel.latitude,
          hotel.longitude,
          existing.latitude,
          existing.longitude,
        );
        final geoMatch = distanceMeters > 0 && distanceMeters <= 150.0;

        if (enMatch || arMatch || geoMatch) {
          matchIndex = i;
          break;
        }
      }

      if (matchIndex == -1) {
        uniqueHotels.add(hotel);
      } else {
        final existing = uniqueHotels[matchIndex];
        if (_shouldReplace(existing, hotel)) {
          uniqueHotels[matchIndex] = hotel;
        }
      }
    }

    return uniqueHotels;
  }

  bool _isNameMatch(String a, String b) {
    if (a.isEmpty || b.isEmpty) return false;
    if (a == b) return true;
    if (a.length > 8 && b.contains(a)) return true;
    if (b.length > 8 && a.contains(b)) return true;
    return false;
  }

  bool _shouldReplace(HotelEntity current, HotelEntity candidate) {
    // 1. Prefer direct partner over affiliate
    if (candidate.isDirect && !current.isDirect) {
      return true;
    }
    if (current.isDirect && !candidate.isDirect) {
      return false;
    }

    // 2. Lower price per night
    if (candidate.pricePerNightUSD < current.pricePerNightUSD - 0.01) {
      return true;
    }
    if (current.pricePerNightUSD < candidate.pricePerNightUSD - 0.01) {
      return false;
    }

    // 3. Higher rating
    if (candidate.userRating > current.userRating) {
      return true;
    }
    if (current.userRating > candidate.userRating) {
      return false;
    }

    // 4. Higher review volume
    return candidate.reviewCount > current.reviewCount;
  }

  String _normalizeEnglishName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'\b(hotel|spa|resort|suites|inn|palace|grand|residences|motel|lodge)\b'), '')
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .trim();
  }

  String _normalizeArabicName(String name) {
    return name
        .replaceAll(RegExp(r'\b(فندق|منتجع|أجنحة|نزل|قصر|ريزيدنس|شقق)\b'), '')
        .replaceAll(RegExp(r'^(ال)'), '')
        .replaceAll(RegExp(r'[\s\p{P}]', unicode: true), '')
        .trim();
  }

  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    if ((lat1 == 0.0 && lon1 == 0.0) || (lat2 == 0.0 && lon2 == 0.0)) return -1.0;
    const earthRadius = 6371000.0; // meters
    final dLat = (lat2 - lat1) * pi / 180.0;
    final dLon = (lon2 - lon1) * pi / 180.0;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180.0) * cos(lat2 * pi / 180.0) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }
}
