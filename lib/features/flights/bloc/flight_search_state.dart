import '../models/flight_offer.dart';
import '../models/flight_search_query.dart';

abstract class FlightSearchState {
  const FlightSearchState();
}

class FlightSearchInitial extends FlightSearchState {
  const FlightSearchInitial();
}

class FlightSearchLoading extends FlightSearchState {
  final FlightSearchQuery query;
  const FlightSearchLoading(this.query);
}

class FlightSearchSuccess extends FlightSearchState {
  final FlightSearchQuery query;
  final List<FlightOffer> allOffers;
  final List<FlightOffer> filteredOffers;
  final String? activeAirlineFilter;
  final String activeSort;

  const FlightSearchSuccess({
    required this.query,
    required this.allOffers,
    required this.filteredOffers,
    this.activeAirlineFilter,
    this.activeSort = 'price',
  });

  FlightSearchSuccess copyWith({
    List<FlightOffer>? filteredOffers,
    String? activeAirlineFilter,
    String? activeSort,
  }) {
    return FlightSearchSuccess(
      query: query,
      allOffers: allOffers,
      filteredOffers: filteredOffers ?? this.filteredOffers,
      activeAirlineFilter: activeAirlineFilter ?? this.activeAirlineFilter,
      activeSort: activeSort ?? this.activeSort,
    );
  }
}

class FlightSearchFailure extends FlightSearchState {
  final String errorMessage;
  final FlightSearchQuery query;

  const FlightSearchFailure({required this.errorMessage, required this.query});
}
