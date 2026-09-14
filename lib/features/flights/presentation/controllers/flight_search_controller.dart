import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers_layer/mock_travel_provider.dart';
import '../../../../providers_layer/travel_provider.dart';
import '../../data/repositories/flight_repository_impl.dart';
import '../../domain/entities/flight_entity.dart';
import '../../domain/entities/flight_search_params.dart';

enum FlightSortOption { cheapest, fastest, bestValue }

class FlightFilterState {
  final FlightSortOption sortOption;
  final int? maxStops; // null = any, 0 = direct, 1 = 1 stop
  final String? airlineFilter;
  final double? maxPriceUSD;

  const FlightFilterState({
    this.sortOption = FlightSortOption.cheapest,
    this.maxStops,
    this.airlineFilter,
    this.maxPriceUSD,
  });

  FlightFilterState copyWith({
    FlightSortOption? sortOption,
    int? maxStops,
    bool clearMaxStops = false,
    String? airlineFilter,
    bool clearAirline = false,
    double? maxPriceUSD,
  }) {
    return FlightFilterState(
      sortOption: sortOption ?? this.sortOption,
      maxStops: clearMaxStops ? null : (maxStops ?? this.maxStops),
      airlineFilter: clearAirline ? null : (airlineFilter ?? this.airlineFilter),
      maxPriceUSD: maxPriceUSD ?? this.maxPriceUSD,
    );
  }
}

class FlightSearchResultState {
  final FlightSearchParams params;
  final List<FlightEntity> rawFlights;
  final FlightFilterState filterState;
  final bool isLoading;
  final String? errorMessage;

  const FlightSearchResultState({
    required this.params,
    this.rawFlights = const [],
    this.filterState = const FlightFilterState(),
    this.isLoading = false,
    this.errorMessage,
  });

  List<FlightEntity> get filteredFlights {
    var list = List<FlightEntity>.from(rawFlights);

    if (filterState.maxStops != null) {
      list = list.where((f) => f.stops <= filterState.maxStops!).toList();
    }

    if (filterState.airlineFilter != null && filterState.airlineFilter!.isNotEmpty) {
      list = list.where((f) => f.airlineName.toLowerCase().contains(filterState.airlineFilter!.toLowerCase())).toList();
    }

    if (filterState.maxPriceUSD != null) {
      list = list.where((f) => f.totalUSD <= filterState.maxPriceUSD!).toList();
    }

    switch (filterState.sortOption) {
      case FlightSortOption.cheapest:
        list.sort((a, b) => a.totalUSD.compareTo(b.totalUSD));
        break;
      case FlightSortOption.fastest:
        list.sort((a, b) => a.totalDuration.compareTo(b.totalDuration));
        break;
      case FlightSortOption.bestValue:
        list.sort((a, b) {
          final scoreA = a.totalUSD + (a.stops * 80) + (a.totalDuration.inMinutes * 0.2);
          final scoreB = b.totalUSD + (b.stops * 80) + (b.totalDuration.inMinutes * 0.2);
          return scoreA.compareTo(scoreB);
        });
        break;
    }

    return list;
  }

  FlightSearchResultState copyWith({
    FlightSearchParams? params,
    List<FlightEntity>? rawFlights,
    FlightFilterState? filterState,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FlightSearchResultState(
      params: params ?? this.params,
      rawFlights: rawFlights ?? this.rawFlights,
      filterState: filterState ?? this.filterState,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final travelProviderRef = Provider<TravelProvider>((ref) {
  return MockTravelProvider();
});

final flightRepositoryProvider = Provider<FlightRepositoryImpl>((ref) {
  final provider = ref.watch(travelProviderRef);
  return FlightRepositoryImpl(provider);
});

final flightSearchControllerProvider = StateNotifierProvider<FlightSearchController, FlightSearchResultState>((ref) {
  final repository = ref.watch(flightRepositoryProvider);
  return FlightSearchController(repository);
});

class FlightSearchController extends StateNotifier<FlightSearchResultState> {
  final FlightRepositoryImpl _repository;

  FlightSearchController(this._repository)
      : super(FlightSearchResultState(
          params: FlightSearchParams(
            originCode: 'ALG',
            originCity: 'Algiers',
            destinationCode: 'DXB',
            destinationCity: 'Dubai',
            departureDate: DateTime.now().add(const Duration(days: 7)),
            returnDate: DateTime.now().add(const Duration(days: 14)),
          ),
        ));

  void updateSearchParams(FlightSearchParams newParams) {
    state = state.copyWith(params: newParams);
  }

  void updateFilter(FlightFilterState filter) {
    state = state.copyWith(filterState: filter);
  }

  Future<void> searchFlights() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final results = await _repository.searchFlights(state.params);
      state = state.copyWith(rawFlights: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
