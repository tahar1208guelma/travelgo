class FlightSearchQuery {
  final String originCode;
  final String originCity;
  final String destinationCode;
  final String destinationCity;
  final DateTime departureDate;
  final DateTime? returnDate;
  final int adults;
  final int children;
  final int infants;
  final String cabinClass; // Economy, Premium Economy, Business, First
  final bool nonStopOnly;
  final double? maxPrice;
  final String currency;

  const FlightSearchQuery({
    required this.originCode,
    required this.originCity,
    required this.destinationCode,
    required this.destinationCity,
    required this.departureDate,
    this.returnDate,
    this.adults = 1,
    this.children = 0,
    this.infants = 0,
    this.cabinClass = 'Economy',
    this.nonStopOnly = false,
    this.maxPrice,
    this.currency = 'DZD',
  });

  bool get isRoundTrip => returnDate != null;
  int get totalPassengers => adults + children + infants;

  Map<String, dynamic> toQueryParams() {
    return {
      'origin': originCode,
      'destination': destinationCode,
      'departureDate': departureDate.toIso8601String().split('T').first,
      if (returnDate != null) 'returnDate': returnDate!.toIso8601String().split('T').first,
      'adults': adults,
      'children': children,
      'infants': infants,
      'cabinClass': cabinClass,
      'nonStopOnly': nonStopOnly,
      'currency': currency,
      if (maxPrice != null) 'maxPrice': maxPrice,
    };
  }
}
