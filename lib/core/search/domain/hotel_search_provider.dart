import '../../../features/hotels/domain/entities/hotel_entity.dart';
import '../../../features/hotels/domain/entities/hotel_search_params.dart';
import 'revalidation_result.dart';

abstract class HotelSearchProvider {
  String get providerId;
  String get providerName;
  Duration get timeout;

  Future<List<HotelEntity>> searchHotels(HotelSearchParams params);
  Future<HotelEntity?> getHotelDetails(String hotelId);
  Future<RevalidationResult> revalidateHotel(String hotelId, double expectedPriceUSD);
}
