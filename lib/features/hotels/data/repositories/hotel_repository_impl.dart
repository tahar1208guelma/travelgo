import '../../../../providers_layer/travel_provider.dart';
import '../../domain/entities/hotel_entity.dart';
import '../../domain/entities/hotel_search_params.dart';

abstract class HotelRepository {
  Future<List<HotelEntity>> searchHotels(HotelSearchParams params);
  Future<HotelEntity?> getHotelDetails(String hotelId);
}

class HotelRepositoryImpl implements HotelRepository {
  final TravelProvider _provider;

  HotelRepositoryImpl(this._provider);

  @override
  Future<List<HotelEntity>> searchHotels(HotelSearchParams params) {
    return _provider.searchHotels(params);
  }

  @override
  Future<HotelEntity?> getHotelDetails(String hotelId) {
    return _provider.getHotelDetails(hotelId);
  }
}
