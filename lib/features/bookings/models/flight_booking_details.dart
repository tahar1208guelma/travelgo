import 'customer_info.dart';

class FlightSegment {
  final String airline;
  final String? airlineCode;
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
  final String flightDuration;
  final String cabinClass;
  final String? baggageAllowance;
  final String? aircraft;
  final String? seatNumber;

  const FlightSegment({
    required this.airline,
    this.airlineCode,
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
    required this.flightDuration,
    this.cabinClass = 'Economy',
    this.baggageAllowance,
    this.aircraft,
    this.seatNumber,
  });

  String get routeDisplay => '$departureAirportCode → $arrivalAirportCode';

  FlightSegment copyWith({
    String? airline,
    String? airlineCode,
    String? flightNumber,
    String? departureAirport,
    String? departureAirportCode,
    String? departureCity,
    String? departureTerminal,
    DateTime? departureDateTime,
    String? arrivalAirport,
    String? arrivalAirportCode,
    String? arrivalCity,
    String? arrivalTerminal,
    DateTime? arrivalDateTime,
    String? flightDuration,
    String? cabinClass,
    String? baggageAllowance,
    String? aircraft,
    String? seatNumber,
  }) {
    return FlightSegment(
      airline: airline ?? this.airline,
      airlineCode: airlineCode ?? this.airlineCode,
      flightNumber: flightNumber ?? this.flightNumber,
      departureAirport: departureAirport ?? this.departureAirport,
      departureAirportCode: departureAirportCode ?? this.departureAirportCode,
      departureCity: departureCity ?? this.departureCity,
      departureTerminal: departureTerminal ?? this.departureTerminal,
      departureDateTime: departureDateTime ?? this.departureDateTime,
      arrivalAirport: arrivalAirport ?? this.arrivalAirport,
      arrivalAirportCode: arrivalAirportCode ?? this.arrivalAirportCode,
      arrivalCity: arrivalCity ?? this.arrivalCity,
      arrivalTerminal: arrivalTerminal ?? this.arrivalTerminal,
      arrivalDateTime: arrivalDateTime ?? this.arrivalDateTime,
      flightDuration: flightDuration ?? this.flightDuration,
      cabinClass: cabinClass ?? this.cabinClass,
      baggageAllowance: baggageAllowance ?? this.baggageAllowance,
      aircraft: aircraft ?? this.aircraft,
      seatNumber: seatNumber ?? this.seatNumber,
    );
  }

  factory FlightSegment.fromJson(Map<String, dynamic> json) {
    return FlightSegment(
      airline: json['airline'] as String? ?? '',
      airlineCode: json['airlineCode'] as String?,
      flightNumber: json['flightNumber'] as String? ?? '',
      departureAirport: json['departureAirport'] as String? ?? '',
      departureAirportCode: json['departureAirportCode'] as String? ?? '',
      departureCity: json['departureCity'] as String?,
      departureTerminal: json['departureTerminal'] as String?,
      departureDateTime: DateTime.parse(json['departureDateTime'] as String),
      arrivalAirport: json['arrivalAirport'] as String? ?? '',
      arrivalAirportCode: json['arrivalAirportCode'] as String? ?? '',
      arrivalCity: json['arrivalCity'] as String?,
      arrivalTerminal: json['arrivalTerminal'] as String?,
      arrivalDateTime: DateTime.parse(json['arrivalDateTime'] as String),
      flightDuration: json['flightDuration'] as String? ?? '',
      cabinClass: json['cabinClass'] as String? ?? 'Economy',
      baggageAllowance: json['baggageAllowance'] as String?,
      aircraft: json['aircraft'] as String?,
      seatNumber: json['seatNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'airline': airline,
      'airlineCode': airlineCode,
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
      'flightDuration': flightDuration,
      'cabinClass': cabinClass,
      'baggageAllowance': baggageAllowance,
      'aircraft': aircraft,
      'seatNumber': seatNumber,
    };
  }
}

class FlightBookingDetails {
  final String airlineBookingReference; // PNR
  final String? ticketNumber;
  final List<FlightSegment> segments;
  final List<PassengerInfo> passengers;
  final String? baggageAllowance;
  final String cabinClass;
  final bool isDirect;

  const FlightBookingDetails({
    required this.airlineBookingReference,
    this.ticketNumber,
    required this.segments,
    this.passengers = const [],
    this.baggageAllowance,
    this.cabinClass = 'Economy',
    this.isDirect = true,
  });

  FlightSegment get primarySegment => segments.isNotEmpty
      ? segments.first
      : FlightSegment(
          airline: 'Airline',
          flightNumber: 'TG000',
          departureAirport: 'Origin',
          departureAirportCode: 'ORG',
          departureDateTime: DateTime.now(),
          arrivalAirport: 'Destination',
          arrivalAirportCode: 'DST',
          arrivalDateTime: DateTime.now().add(const Duration(hours: 2)),
          flightDuration: '2h 00m',
        );

  FlightSegment get lastSegment => segments.isNotEmpty ? segments.last : primarySegment;

  String get originCode => primarySegment.departureAirportCode;
  String get destinationCode => lastSegment.arrivalAirportCode;
  String get originAirportName => primarySegment.departureAirport;
  String get destinationAirportName => lastSegment.arrivalAirport;
  DateTime get departureDateTime => primarySegment.departureDateTime;
  DateTime get arrivalDateTime => lastSegment.arrivalDateTime;
  String get airlineName => primarySegment.airline;
  String get flightNumber => primarySegment.flightNumber;
  String get overallDuration => primarySegment.flightDuration;

  FlightBookingDetails copyWith({
    String? airlineBookingReference,
    String? ticketNumber,
    List<FlightSegment>? segments,
    List<PassengerInfo>? passengers,
    String? baggageAllowance,
    String? cabinClass,
    bool? isDirect,
  }) {
    return FlightBookingDetails(
      airlineBookingReference: airlineBookingReference ?? this.airlineBookingReference,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      segments: segments ?? this.segments,
      passengers: passengers ?? this.passengers,
      baggageAllowance: baggageAllowance ?? this.baggageAllowance,
      cabinClass: cabinClass ?? this.cabinClass,
      isDirect: isDirect ?? this.isDirect,
    );
  }

  factory FlightBookingDetails.fromJson(Map<String, dynamic> json) {
    return FlightBookingDetails(
      airlineBookingReference: json['airlineBookingReference'] as String? ?? 'TG-PNR',
      ticketNumber: json['ticketNumber'] as String?,
      segments: (json['segments'] as List<dynamic>?)
              ?.map((e) => FlightSegment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      passengers: (json['passengers'] as List<dynamic>?)
              ?.map((e) => PassengerInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      baggageAllowance: json['baggageAllowance'] as String?,
      cabinClass: json['cabinClass'] as String? ?? 'Economy',
      isDirect: json['isDirect'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'airlineBookingReference': airlineBookingReference,
      'ticketNumber': ticketNumber,
      'segments': segments.map((s) => s.toJson()).toList(),
      'passengers': passengers.map((p) => p.toJson()).toList(),
      'baggageAllowance': baggageAllowance,
      'cabinClass': cabinClass,
      'isDirect': isDirect,
    };
  }
}
