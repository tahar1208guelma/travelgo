import '../../../../core/search/services/flight_search_aggregator.dart';
import '../../../../providers_layer/travel_provider.dart';
import '../../domain/entities/flight_entity.dart';
import '../../domain/entities/flight_search_params.dart';

abstract class FlightRepository {
  Future<List<FlightEntity>> searchFlights(FlightSearchParams params);
  Future<FlightEntity?> getFlightDetails(String flightId);
}

class FlightRepositoryImpl implements FlightRepository {
  final TravelProvider _provider;
  final FlightSearchAggregator? _aggregator;

  FlightRepositoryImpl(this._provider, [this._aggregator]);

  @override
  Future<List<FlightEntity>> searchFlights(FlightSearchParams params) async {
    if (_aggregator != null) {
      final aggregated = await _aggregator!.searchAll(params);
      if (aggregated.results.isNotEmpty) {
        return aggregated.results;
      }
    }
    return _provider.searchFlights(params);
  }

  @override
  Future<FlightEntity?> getFlightDetails(String flightId) {
    return _provider.getFlightDetails(flightId);
  }
}
