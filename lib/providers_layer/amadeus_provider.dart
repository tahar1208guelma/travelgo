import '../core/errors/exceptions.dart';
import '../features/booking/domain/entities/affiliate_click_entity.dart';
import '../features/booking/domain/entities/booking_entity.dart';
import '../features/flights/domain/entities/flight_entity.dart';
import '../features/flights/domain/entities/flight_search_params.dart';
import '../features/hotels/domain/entities/hotel_entity.dart';
import '../features/hotels/domain/entities/hotel_search_params.dart';
import 'travel_provider.dart';

/// AmadeusTravelProvider forwards all API calls to the secure Firebase Cloud Functions /
/// NestJS Backend Gateway, ensuring zero API secret keys are bundled into the client app.
class AmadeusTravelProvider implements TravelProvider {
  final String backendBaseUrl;

  AmadeusTravelProvider({this.backendBaseUrl = 'https://api.travelgo.app/v1'});

  @override
  String get providerName => 'Amadeus Global Distribution System';

  @override
  Future<List<FlightEntity>> searchFlights(FlightSearchParams params) async {
    // In production, makes HTTP POST to backend gateway:
    // final response = await http.post('$backendBaseUrl/amadeus/flights/search', body: params.toJson());
    // For now, falls back gracefully or throws if backend is unreachable
    throw ServerException(message: 'Production backend gateway not connected yet. Use MockTravelProvider in sandbox.');
  }

  @override
  Future<FlightEntity?> getFlightDetails(String flightId) async {
    throw ServerException(message: 'Production backend gateway not connected yet.');
  }

  @override
  Future<List<HotelEntity>> searchHotels(HotelSearchParams params) async {
    throw ServerException(message: 'Production backend gateway not connected yet.');
  }

  @override
  Future<HotelEntity?> getHotelDetails(String hotelId) async {
    throw ServerException(message: 'Production backend gateway not connected yet.');
  }

  @override
  Future<BookingEntity> createDirectBooking(DirectBookingRequest request) async {
    throw ServerException(message: 'Production payment gateway not connected yet.');
  }

  @override
  Future<AffiliateClickEntity> generateAffiliateLink({
    required String userId,
    required String productType,
    required String productId,
    required String rawTargetUrl,
  }) async {
    throw ServerException(message: 'Production affiliate engine not connected yet.');
  }
}
