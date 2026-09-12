import '../models/hotel_offer.dart';
import '../models/hotel_search_query.dart';

abstract class HotelRepository {
  /// Queries available live hotel rates and room availability
  Future<List<HotelOffer>> searchHotels(HotelSearchQuery query);

  /// Retrieves comprehensive property details, room amenities, and photos
  Future<HotelOffer?> getHotelDetails(String hotelId);
}
