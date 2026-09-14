enum BookingChannel { direct, affiliate }

class FlightSegment {
  final String flightNumber;
  final String airlineCode;
  final String airlineName;
  final String airlineLogoUrl;
  final String departureAirportCode;
  final String departureAirportName;
  final String departureCity;
  final DateTime departureTime;
  final String arrivalAirportCode;
  final String arrivalAirportName;
  final String arrivalCity;
  final DateTime arrivalTime;
  final Duration duration;
  final String aircraftType;
  final String cabinClass;

  const FlightSegment({
    required this.flightNumber,
    required this.airlineCode,
    required this.airlineName,
    required this.airlineLogoUrl,
    required this.departureAirportCode,
    required this.departureAirportName,
    required this.departureCity,
    required this.departureTime,
    required this.arrivalAirportCode,
    required this.arrivalAirportName,
    required this.arrivalCity,
    required this.arrivalTime,
    required this.duration,
    required this.aircraftType,
    required this.cabinClass,
  });
}

class FlightEntity {
  final String id;
  final String providerName; // e.g. "Amadeus", "Duffel", "Skyscanner"
  final BookingChannel bookingChannel; // direct vs affiliate
  final String? affiliateUrl;
  final String airlineName;
  final String airlineCode;
  final String airlineLogo;
  final String departureAirportCode;
  final String departureCity;
  final DateTime departureTime;
  final String arrivalAirportCode;
  final String arrivalCity;
  final DateTime arrivalTime;
  final Duration totalDuration;
  final int stops;
  final String? layoverInfo;
  final double basePriceUSD;
  final double taxesUSD;
  final double totalUSD;
  final bool baggageIncluded;
  final int remainingSeats;
  final List<FlightSegment> segments;

  const FlightEntity({
    required this.id,
    required this.providerName,
    required this.bookingChannel,
    this.affiliateUrl,
    required this.airlineName,
    required this.airlineCode,
    required this.airlineLogo,
    required this.departureAirportCode,
    required this.departureCity,
    required this.departureTime,
    required this.arrivalAirportCode,
    required this.arrivalCity,
    required this.arrivalTime,
    required this.totalDuration,
    required this.stops,
    this.layoverInfo,
    required this.basePriceUSD,
    required this.taxesUSD,
    required this.totalUSD,
    this.baggageIncluded = true,
    this.remainingSeats = 7,
    this.segments = const [],
  });

  bool get isDirect => stops == 0;
  bool get isAffiliate => bookingChannel == BookingChannel.affiliate;
}
