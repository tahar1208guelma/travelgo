import '../../../core/architecture/bloc_base.dart';
import '../models/flight_offer.dart';
import '../repositories/flight_repository.dart';
import 'flight_search_event.dart';
import 'flight_search_state.dart';

class FlightSearchBloc extends Bloc<FlightSearchEvent, FlightSearchState> {
  final FlightRepository repository;

  FlightSearchBloc({required this.repository}) : super(const FlightSearchInitial());

  @override
  void onEvent(FlightSearchEvent event) async {
    if (event is SearchFlightsRequested) {
      await _handleSearch(event);
    } else if (event is FilterFlightsRequested) {
      _handleFilter(event);
    }
  }

  Future<void> _handleSearch(SearchFlightsRequested event) async {
    emit(FlightSearchLoading(event.query));

    try {
      final offers = await repository.searchFlights(event.query);
      if (offers.isEmpty) {
        emit(FlightSearchFailure(
          errorMessage: 'No flights found matching your route and dates.',
          query: event.query,
        ));
      } else {
        // Sort by price by default
        final sorted = List<FlightOffer>.from(offers)
          ..sort((a, b) => a.price.totalAmount.compareTo(b.price.totalAmount));

        emit(FlightSearchSuccess(
          query: event.query,
          allOffers: offers,
          filteredOffers: sorted,
          activeSort: 'price',
        ));
      }
    } catch (e) {
      emit(FlightSearchFailure(
        errorMessage: 'Failed to search flights: $e',
        query: event.query,
      ));
    }
  }

  void _handleFilter(FilterFlightsRequested event) {
    final currentState = state;
    if (currentState is! FlightSearchSuccess) return;

    var result = List<FlightOffer>.from(currentState.allOffers);

    if (event.airlineFilter != null && event.airlineFilter!.isNotEmpty) {
      result = result.where((o) => o.validatingAirline == event.airlineFilter).toList();
    }

    if (event.maxPrice != null) {
      result = result.where((o) => o.price.totalAmount <= event.maxPrice!).toList();
    }

    final sortBy = event.sortBy ?? currentState.activeSort;
    if (sortBy == 'price') {
      result.sort((a, b) => a.price.totalAmount.compareTo(b.price.totalAmount));
    } else if (sortBy == 'duration') {
      result.sort((a, b) => a.totalOutboundDuration.compareTo(b.totalOutboundDuration));
    } else if (sortBy == 'departure') {
      result.sort((a, b) => a.primaryOutboundSegment.departureDateTime
          .compareTo(b.primaryOutboundSegment.departureDateTime));
    }

    emit(currentState.copyWith(
      filteredOffers: result,
      activeAirlineFilter: event.airlineFilter,
      activeSort: sortBy,
    ));
  }
}
