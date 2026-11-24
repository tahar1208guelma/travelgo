import '../../../../core/search/services/hotel_search_aggregator.dart';
import '../../../../providers_layer/travel_provider.dart';
import '../../domain/entities/hotel_entity.dart';
import '../../domain/entities/hotel_search_params.dart';

abstract class HotelRepository {
  Future<List<HotelEntity>> searchHotels(HotelSearchParams params);
  Future<HotelEntity?> getHotelDetails(String hotelId);
}

class HotelRepositoryImpl implements HotelRepository {
  final TravelProvider _provider;
  final HotelSearchAggregator? _aggregator;

  HotelRepositoryImpl(this._provider, [this._aggregator]);

  @override
  Future<List<HotelEntity>> searchHotels(HotelSearchParams params) async {
    if (_aggregator != null) {
      final aggregated = await _aggregator!.searchAll(params);
      if (aggregated.results.isNotEmpty) {
        return aggregated.results;
      }
    }
    return _provider.searchHotels(params);
  }

  @override
  Future<HotelEntity?> getHotelDetails(String hotelId) {
    return _provider.getHotelDetails(hotelId);
  }
}
