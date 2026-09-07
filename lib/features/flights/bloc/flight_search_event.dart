import '../models/flight_search_query.dart';

abstract class FlightSearchEvent {
  const FlightSearchEvent();
}

class SearchFlightsRequested extends FlightSearchEvent {
  final FlightSearchQuery query;
  const SearchFlightsRequested(this.query);
}

class FilterFlightsRequested extends FlightSearchEvent {
  final String? airlineFilter;
  final bool? nonStopOnly;
  final double? maxPrice;
  final String? sortBy; // 'price', 'duration', 'departure'

  const FilterFlightsRequested({
    this.airlineFilter,
    this.nonStopOnly,
    this.maxPrice,
    this.sortBy,
  });
}

class SelectFlightOfferRequested extends FlightSearchEvent {
  final String offerId;
  const SelectFlightOfferRequested(this.offerId);
}
