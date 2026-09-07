import '../../bookings/models/passenger.dart';
import '../models/flight_offer.dart';
import '../models/flight_search_query.dart';

abstract class FlightRepository {
  /// Queries available live flight offers matching search criteria
  Future<List<FlightOffer>> searchFlights(FlightSearchQuery query);

  /// Validates price and retrieves full seat map / fare rules for an offer
  Future<FlightOffer?> getFlightOfferDetails(String offerId);

  /// Performs price lock and temporary seat hold with the GDS / Airline
  Future<String> holdFlightOffer({
    required String offerId,
    required List<Passenger> passengers,
  });
}
