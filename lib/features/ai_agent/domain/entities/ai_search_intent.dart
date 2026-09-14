import '../../../flights/domain/entities/flight_search_params.dart';
import '../../../hotels/domain/entities/hotel_search_params.dart';

enum AISearchType { flight, hotel, package, general }

class AISearchIntent {
  final String rawQuery;
  final AISearchType searchType;
  final String? originCode;
  final String? originCity;
  final String? destinationCode;
  final String? destinationCity;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final int dateFlexibilityDays;
  final TripType tripType;
  final int adults;
  final int children;
  final int infants;
  final CabinClass cabinClass;
  final bool nonstopPreference;
  final int? hotelMinStars;
  final String? hotelLocationPreference;
  final int numberOfRooms;
  final int? numberOfNights;
  final double? budgetUSD;
  final String currency;
  final List<String> userPreferences;
  final List<String> missingFields;
  final List<String> validationErrors;

  const AISearchIntent({
    required this.rawQuery,
    this.searchType = AISearchType.flight,
    this.originCode,
    this.originCity,
    this.destinationCode,
    this.destinationCity,
    this.departureDate,
    this.returnDate,
    this.dateFlexibilityDays = 0,
    this.tripType = TripType.roundTrip,
    this.adults = 1,
    this.children = 0,
    this.infants = 0,
    this.cabinClass = CabinClass.economy,
    this.nonstopPreference = false,
    this.hotelMinStars,
    this.hotelLocationPreference,
    this.numberOfRooms = 1,
    this.numberOfNights,
    this.budgetUSD,
    this.currency = 'USD',
    this.userPreferences = const [],
    this.missingFields = const [],
    this.validationErrors = const [],
  });

  bool get isFlightSearch => searchType == AISearchType.flight || searchType == AISearchType.package;
  bool get isHotelSearch => searchType == AISearchType.hotel || searchType == AISearchType.package;

  bool get isCompleteForFlightSearch =>
      originCode != null &&
      originCode!.isNotEmpty &&
      destinationCode != null &&
      destinationCode!.isNotEmpty &&
      departureDate != null &&
      adults >= 1;

  bool get isCompleteForHotelSearch =>
      (destinationCity != null && destinationCity!.isNotEmpty) &&
      departureDate != null &&
      adults >= 1;

  bool get isComplete =>
      missingFields.isEmpty &&
      validationErrors.isEmpty &&
      (isFlightSearch ? isCompleteForFlightSearch : isCompleteForHotelSearch);

  FlightSearchParams? toFlightSearchParams() {
    if (!isCompleteForFlightSearch) return null;
    return FlightSearchParams(
      tripType: tripType,
      originCode: originCode!,
      originCity: originCity ?? originCode!,
      destinationCode: destinationCode!,
      destinationCity: destinationCity ?? destinationCode!,
      departureDate: departureDate!,
      returnDate: tripType == TripType.roundTrip ? returnDate : null,
      adults: adults,
      children: children,
      infants: infants,
      cabinClass: cabinClass,
      directOnly: nonstopPreference,
    );
  }

  HotelSearchParams? toHotelSearchParams() {
    if (!isCompleteForHotelSearch) return null;
    final checkIn = departureDate!;
    final checkOut = returnDate ?? checkIn.add(Duration(days: numberOfNights ?? 4));

    return HotelSearchParams(
      destination: destinationCity ?? destinationCode ?? 'Dubai',
      checkInDate: checkIn,
      checkOutDate: checkOut,
      adults: adults,
      children: children,
      rooms: numberOfRooms,
    );
  }

  AISearchIntent copyWith({
    String? rawQuery,
    AISearchType? searchType,
    String? originCode,
    String? originCity,
    String? destinationCode,
    String? destinationCity,
    DateTime? departureDate,
    DateTime? returnDate,
    int? dateFlexibilityDays,
    TripType? tripType,
    int? adults,
    int? children,
    int? infants,
    CabinClass? cabinClass,
    bool? nonstopPreference,
    int? hotelMinStars,
    String? hotelLocationPreference,
    int? numberOfRooms,
    int? numberOfNights,
    double? budgetUSD,
    String? currency,
    List<String>? userPreferences,
    List<String>? missingFields,
    List<String>? validationErrors,
  }) {
    return AISearchIntent(
      rawQuery: rawQuery ?? this.rawQuery,
      searchType: searchType ?? this.searchType,
      originCode: originCode ?? this.originCode,
      originCity: originCity ?? this.originCity,
      destinationCode: destinationCode ?? this.destinationCode,
      destinationCity: destinationCity ?? this.destinationCity,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      dateFlexibilityDays: dateFlexibilityDays ?? this.dateFlexibilityDays,
      tripType: tripType ?? this.tripType,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      infants: infants ?? this.infants,
      cabinClass: cabinClass ?? this.cabinClass,
      nonstopPreference: nonstopPreference ?? this.nonstopPreference,
      hotelMinStars: hotelMinStars ?? this.hotelMinStars,
      hotelLocationPreference: hotelLocationPreference ?? this.hotelLocationPreference,
      numberOfRooms: numberOfRooms ?? this.numberOfRooms,
      numberOfNights: numberOfNights ?? this.numberOfNights,
      budgetUSD: budgetUSD ?? this.budgetUSD,
      currency: currency ?? this.currency,
      userPreferences: userPreferences ?? this.userPreferences,
      missingFields: missingFields ?? this.missingFields,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rawQuery': rawQuery,
      'searchType': searchType.name,
      'originCode': originCode,
      'originCity': originCity,
      'destinationCode': destinationCode,
      'destinationCity': destinationCity,
      'departureDate': departureDate?.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'dateFlexibilityDays': dateFlexibilityDays,
      'tripType': tripType.name,
      'adults': adults,
      'children': children,
      'infants': infants,
      'cabinClass': cabinClass.name,
      'nonstopPreference': nonstopPreference,
      'hotelMinStars': hotelMinStars,
      'hotelLocationPreference': hotelLocationPreference,
      'numberOfRooms': numberOfRooms,
      'numberOfNights': numberOfNights,
      'budgetUSD': budgetUSD,
      'currency': currency,
      'userPreferences': userPreferences,
      'missingFields': missingFields,
      'validationErrors': validationErrors,
      'isComplete': isComplete,
    };
  }
}
