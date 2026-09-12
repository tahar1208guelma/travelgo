import 'passenger.dart';

class FlightSegment {
  final String airline;
  final String flightNumber;
  final String departureAirport;
  final String departureAirportCode;
  final String? departureCity;
  final String? departureTerminal;
  final DateTime departureDateTime;
  final String arrivalAirport;
  final String arrivalAirportCode;
  final String? arrivalCity;
  final String? arrivalTerminal;
  final DateTime arrivalDateTime;
  final Duration duration;
  final String cabinClass;
  final String? baggageAllowance;
  final String? aircraftType;

  const FlightSegment({
    required this.airline,
    required this.flightNumber,
    required this.departureAirport,
    required this.departureAirportCode,
    this.departureCity,
    this.departureTerminal,
    required this.departureDateTime,
    required this.arrivalAirport,
    required this.arrivalAirportCode,
    this.arrivalCity,
    this.arrivalTerminal,
    required this.arrivalDateTime,
    required this.duration,
    this.cabinClass = 'Economy',
    this.baggageAllowance,
    this.aircraftType,
  });

  Map<String, dynamic> toMap() {
    return {
      'airline': airline,
      'flightNumber': flightNumber,
      'departureAirport': departureAirport,
      'departureAirportCode': departureAirportCode,
      'departureCity': departureCity,
      'departureTerminal': departureTerminal,
      'departureDateTime': departureDateTime.toIso8601String(),
      'arrivalAirport': arrivalAirport,
      'arrivalAirportCode': arrivalAirportCode,
      'arrivalCity': arrivalCity,
      'arrivalTerminal': arrivalTerminal,
      'arrivalDateTime': arrivalDateTime.toIso8601String(),
      'durationMinutes': duration.inMinutes,
      'cabinClass': cabinClass,
      'baggageAllowance': baggageAllowance,
      'aircraftType': aircraftType,
    };
  }

  factory FlightSegment.fromMap(Map<String, dynamic> map) {
    return FlightSegment(
      airline: map['airline'] as String,
      flightNumber: map['flightNumber'] as String,
      departureAirport: map['departureAirport'] as String,
      departureAirportCode: map['departureAirportCode'] as String,
      departureCity: map['departureCity'] as String?,
      departureTerminal: map['departureTerminal'] as String?,
      departureDateTime: DateTime.parse(map['departureDateTime'] as String),
      arrivalAirport: map['arrivalAirport'] as String,
      arrivalAirportCode: map['arrivalAirportCode'] as String,
      arrivalCity: map['arrivalCity'] as String?,
      arrivalTerminal: map['arrivalTerminal'] as String?,
      arrivalDateTime: DateTime.parse(map['arrivalDateTime'] as String),
      duration: Duration(minutes: map['durationMinutes'] as int? ?? 0),
      cabinClass: map['cabinClass'] as String? ?? 'Economy',
      baggageAllowance: map['baggageAllowance'] as String?,
      aircraftType: map['aircraftType'] as String?,
    );
  }
}

class FlightBookingDetails {
  final String? airlineBookingReference;
  final List<FlightSegment> segments;
  final List<Passenger> passengers;
  final Map<String, String>? ticketNumbers; // passengerId -> ticket number

  const FlightBookingDetails({
    this.airlineBookingReference,
    required this.segments,
    required this.passengers,
    this.ticketNumbers,
  });

  FlightSegment get primarySegment => segments.first;

  Map<String, dynamic> toMap() {
    return {
      'airlineBookingReference': airlineBookingReference,
      'segments': segments.map((s) => s.toMap()).toList(),
      'passengers': passengers.map((p) => p.toMap()).toList(),
      'ticketNumbers': ticketNumbers,
    };
  }

  factory FlightBookingDetails.fromMap(Map<String, dynamic> map) {
    return FlightBookingDetails(
      airlineBookingReference: map['airlineBookingReference'] as String?,
      segments: (map['segments'] as List<dynamic>)
          .map((s) => FlightSegment.fromMap(s as Map<String, dynamic>))
          .toList(),
      passengers: (map['passengers'] as List<dynamic>)
          .map((p) => Passenger.fromMap(p as Map<String, dynamic>))
          .toList(),
      ticketNumbers: (map['ticketNumbers'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v.toString()),
      ),
    );
  }
}
