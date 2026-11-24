import '../../../features/flights/domain/entities/flight_entity.dart';

/// Flight deduplication engine.
///
/// Identifies duplicate flight options returned by distinct GDS aggregators, NDC APIs,
/// and affiliate channels for the same physical route and schedule.
///
/// When duplicates are detected:
/// 1. Prioritizes the lowest price offer (`totalUSD`).
/// 2. If prices are identical, prioritizes Direct in-app booking (`BookingChannel.direct`)
///    over Affiliate outbound redirects.
/// 3. If channels are identical, prioritizes included checked baggage and inventory depth.
class FlightDeduplicator {
  List<FlightEntity> deduplicate(List<FlightEntity> offers) {
    if (offers.length <= 1) return offers;

    final List<FlightEntity> uniqueOffers = [];

    for (final offer in offers) {
      int matchIndex = -1;

      for (var i = 0; i < uniqueOffers.length; i++) {
        final existing = uniqueOffers[i];

        if (_isSameFlight(offer, existing)) {
          matchIndex = i;
          break;
        }
      }

      if (matchIndex == -1) {
        uniqueOffers.add(offer);
      } else {
        final existing = uniqueOffers[matchIndex];
        if (_shouldReplace(existing, offer)) {
          uniqueOffers[matchIndex] = offer;
        }
      }
    }

    return uniqueOffers;
  }

  bool _isSameFlight(FlightEntity a, FlightEntity b) {
    // 1. Check segment flight numbers match if available
    if (a.segments.isNotEmpty && b.segments.isNotEmpty) {
      final aNumbers = a.segments.map((s) => s.flightNumber.replaceAll(' ', '').toUpperCase()).toSet();
      final bNumbers = b.segments.map((s) => s.flightNumber.replaceAll(' ', '').toUpperCase()).toSet();
      final common = aNumbers.intersection(bNumbers);
      if (common.isNotEmpty) {
        final dayDiff = a.departureTime.difference(b.departureTime).inHours.abs();
        if (dayDiff < 12) return true;
      }
    }

    // 2. Check route, airline, and departure schedule within +/- 45 minutes
    if (a.airlineCode.toUpperCase() == b.airlineCode.toUpperCase() &&
        a.departureAirportCode.toUpperCase() == b.departureAirportCode.toUpperCase() &&
        a.arrivalAirportCode.toUpperCase() == b.arrivalAirportCode.toUpperCase() &&
        a.stops == b.stops) {
      final diffMinutes = a.departureTime.difference(b.departureTime).inMinutes.abs();
      if (diffMinutes <= 45) {
        return true;
      }
    }

    return false;
  }

  bool _shouldReplace(FlightEntity current, FlightEntity candidate) {
    // 1. Lower total price always wins
    if (candidate.totalUSD < current.totalUSD - 0.01) {
      return true;
    }
    if (current.totalUSD < candidate.totalUSD - 0.01) {
      return false;
    }

    // 2. Equal price: prefer direct booking over affiliate
    if (candidate.bookingChannel == BookingChannel.direct && current.bookingChannel != BookingChannel.direct) {
      return true;
    }
    if (current.bookingChannel == BookingChannel.direct && candidate.bookingChannel != BookingChannel.direct) {
      return false;
    }

    // 3. Prefer baggage included
    if (candidate.baggageIncluded && !current.baggageIncluded) {
      return true;
    }
    if (current.baggageIncluded && !candidate.baggageIncluded) {
      return false;
    }

    // 4. Prefer higher remaining seats inventory
    return candidate.remainingSeats > current.remainingSeats;
  }
}
