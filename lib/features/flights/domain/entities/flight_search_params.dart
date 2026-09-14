enum TripType { roundTrip, oneWay }
enum CabinClass { economy, premiumEconomy, business, firstClass }

class FlightSearchParams {
  final TripType tripType;
  final String originCode;
  final String originCity;
  final String destinationCode;
  final String destinationCity;
  final DateTime departureDate;
  final DateTime? returnDate;
  final int adults;
  final int children;
  final int infants;
  final CabinClass cabinClass;
  final bool directOnly;

  const FlightSearchParams({
    this.tripType = TripType.roundTrip,
    required this.originCode,
    required this.originCity,
    required this.destinationCode,
    required this.destinationCity,
    required this.departureDate,
    this.returnDate,
    this.adults = 1,
    this.children = 0,
    this.infants = 0,
    this.cabinClass = CabinClass.economy,
    this.directOnly = false,
  });

  int get totalPassengers => adults + children + infants;

  FlightSearchParams copyWith({
    TripType? tripType,
    String? originCode,
    String? originCity,
    String? destinationCode,
    String? destinationCity,
    DateTime? departureDate,
    DateTime? returnDate,
    int? adults,
    int? children,
    int? infants,
    CabinClass? cabinClass,
    bool? directOnly,
  }) {
    return FlightSearchParams(
      tripType: tripType ?? this.tripType,
      originCode: originCode ?? this.originCode,
      originCity: originCity ?? this.originCity,
      destinationCode: destinationCode ?? this.destinationCode,
      destinationCity: destinationCity ?? this.destinationCity,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      infants: infants ?? this.infants,
      cabinClass: cabinClass ?? this.cabinClass,
      directOnly: directOnly ?? this.directOnly,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripType': tripType.name,
      'originCode': originCode,
      'originCity': originCity,
      'destinationCode': destinationCode,
      'destinationCity': destinationCity,
      'departureDate': departureDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'adults': adults,
      'children': children,
      'infants': infants,
      'cabinClass': cabinClass.name,
      'directOnly': directOnly,
    };
  }

  factory FlightSearchParams.fromJson(Map<String, dynamic> json) {
    return FlightSearchParams(
      tripType: TripType.values.firstWhere((e) => e.name == json['tripType'], orElse: () => TripType.roundTrip),
      originCode: json['originCode'] as String? ?? 'ALG',
      originCity: json['originCity'] as String? ?? 'Algiers',
      destinationCode: json['destinationCode'] as String? ?? 'DXB',
      destinationCity: json['destinationCity'] as String? ?? 'Dubai',
      departureDate: json['departureDate'] != null ? DateTime.parse(json['departureDate']) : DateTime.now().add(const Duration(days: 7)),
      returnDate: json['returnDate'] != null ? DateTime.parse(json['returnDate']) : DateTime.now().add(const Duration(days: 14)),
      adults: json['adults'] as int? ?? 1,
      children: json['children'] as int? ?? 0,
      infants: json['infants'] as int? ?? 0,
      cabinClass: CabinClass.values.firstWhere((e) => e.name == json['cabinClass'], orElse: () => CabinClass.economy),
      directOnly: json['directOnly'] as bool? ?? false,
    );
  }
}
