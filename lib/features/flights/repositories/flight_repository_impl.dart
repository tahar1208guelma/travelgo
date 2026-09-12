import '../../bookings/models/passenger.dart';
import '../datasources/flight_remote_datasource.dart';
import '../models/flight_offer.dart';
import '../models/flight_search_query.dart';
import 'flight_repository.dart';

class FlightRepositoryImpl implements FlightRepository {
  final FlightRemoteDataSource remoteDataSource;

  FlightRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<FlightOffer>> searchFlights(FlightSearchQuery query) async {
    return remoteDataSource.fetchFlightOffers(query);
  }

  @override
  Future<FlightOffer?> getFlightOfferDetails(String offerId) async {
    return remoteDataSource.fetchOfferDetails(offerId);
  }

  @override
  Future<String> holdFlightOffer({
    required String offerId,
    required List<Passenger> passengers,
  }) async {
    return remoteDataSource.executeSeatHold(offerId, passengers);
  }
}
