import '../../../features/flights/domain/entities/flight_entity.dart';
import '../../../features/flights/domain/entities/flight_search_params.dart';
import 'revalidation_result.dart';

abstract class FlightSearchProvider {
  String get providerId;
  String get providerName;
  Duration get timeout;

  Future<List<FlightEntity>> searchFlights(FlightSearchParams params);
  Future<FlightEntity?> getFlightDetails(String flightId);
  Future<RevalidationResult> revalidateFlight(String flightId, double expectedPriceUSD);
}
