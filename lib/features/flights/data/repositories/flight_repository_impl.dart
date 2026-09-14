import '../../../../providers_layer/travel_provider.dart';
import '../../domain/entities/flight_entity.dart';
import '../../domain/entities/flight_search_params.dart';

abstract class FlightRepository {
  Future<List<FlightEntity>> searchFlights(FlightSearchParams params);
  Future<FlightEntity?> getFlightDetails(String flightId);
}

class FlightRepositoryImpl implements FlightRepository {
  final TravelProvider _provider;

  FlightRepositoryImpl(this._provider);

  @override
  Future<List<FlightEntity>> searchFlights(FlightSearchParams params) {
    return _provider.searchFlights(params);
  }

  @override
  Future<FlightEntity?> getFlightDetails(String flightId) {
    return _provider.getFlightDetails(flightId);
  }
}
