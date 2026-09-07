import '../../bookings/models/flight_booking_details.dart';
import '../../bookings/models/price_breakdown.dart';

/// Represents a live flight offer returned by the GDS / TRAVELGO Flight Engine
class FlightOffer {
  final String offerId;
  final String validatingAirline;
  final String validatingAirlineCode;
  final String? airlineLogoUrl;
  final List<FlightSegment> outboundSegments;
  final List<FlightSegment>? returnSegments;
  final PriceBreakdown price;
  final int seatsRemaining;
  final bool isRefundable;
  final String baggageSummary;
  final DateTime priceLockExpiry;

  const FlightOffer({
    required this.offerId,
    required this.validatingAirline,
    required this.validatingAirlineCode,
    this.airlineLogoUrl,
    required this.outboundSegments,
    this.returnSegments,
    required this.price,
    this.seatsRemaining = 9,
    this.isRefundable = false,
    this.baggageSummary = '1 x 23 kg checked baggage',
    required this.priceLockExpiry,
  });

  bool get isRoundTrip => returnSegments != null && returnSegments!.isNotEmpty;
  FlightSegment get primaryOutboundSegment => outboundSegments.first;
  FlightSegment get firstSegment => outboundSegments.first;
  FlightSegment get lastSegment => outboundSegments.last;
  String get departureAirportCode => firstSegment.departureAirportCode;
  String get arrivalAirportCode => lastSegment.arrivalAirportCode;
  DateTime get departureDateTime => firstSegment.departureDateTime;
  DateTime get arrivalDateTime => lastSegment.arrivalDateTime;

  int get stopsCount => outboundSegments.length - 1;
  bool get isDirect => outboundSegments.length == 1;

  List<String> get transitAirportCodes {
    if (isDirect) return [];
    return outboundSegments
        .sublist(0, stopsCount)
        .map((seg) => seg.arrivalAirportCode)
        .toList();
  }

  String get stopsLabel {
    if (isDirect) return 'Direct • مباشر';
    if (stopsCount == 1) {
      final transit = transitAirportCodes.first;
      return '1 Stop ($transit) • ترانزيت 1';
    }
    final transits = transitAirportCodes.join(', ');
    return '$stopsCount Stops ($transits) • ترانزيت $stopsCount';
  }

  Duration get totalOutboundDuration => outboundSegments.fold(
        Duration.zero,
        (prev, seg) => prev + seg.duration,
      );

  Duration get totalJourneyDuration =>
      lastSegment.arrivalDateTime.difference(firstSegment.departureDateTime);

  Map<String, dynamic> toMap() {
    return {
      'offerId': offerId,
      'validatingAirline': validatingAirline,
      'validatingAirlineCode': validatingAirlineCode,
      'airlineLogoUrl': airlineLogoUrl,
      'outboundSegments': outboundSegments.map((s) => s.toMap()).toList(),
      'returnSegments': returnSegments?.map((s) => s.toMap()).toList(),
      'price': price.toMap(),
      'seatsRemaining': seatsRemaining,
      'isRefundable': isRefundable,
      'baggageSummary': baggageSummary,
      'priceLockExpiry': priceLockExpiry.toIso8601String(),
    };
  }

  factory FlightOffer.fromMap(Map<String, dynamic> map) {
    return FlightOffer(
      offerId: map['offerId'] as String,
      validatingAirline: map['validatingAirline'] as String,
      validatingAirlineCode: map['validatingAirlineCode'] as String,
      airlineLogoUrl: map['airlineLogoUrl'] as String?,
      outboundSegments: (map['outboundSegments'] as List<dynamic>)
          .map((s) => FlightSegment.fromMap(s as Map<String, dynamic>))
          .toList(),
      returnSegments: map['returnSegments'] != null
          ? (map['returnSegments'] as List<dynamic>)
              .map((s) => FlightSegment.fromMap(s as Map<String, dynamic>))
              .toList()
          : null,
      price: PriceBreakdown.fromMap(map['price'] as Map<String, dynamic>),
      seatsRemaining: map['seatsRemaining'] as int? ?? 9,
      isRefundable: map['isRefundable'] as bool? ?? false,
      baggageSummary: map['baggageSummary'] as String? ?? '1 x 23 kg checked baggage',
      priceLockExpiry: DateTime.parse(map['priceLockExpiry'] as String),
    );
  }
}
