import '../datasources/hotel_remote_datasource.dart';
import '../models/hotel_offer.dart';
import '../models/hotel_search_query.dart';
import 'hotel_repository.dart';

class HotelRepositoryImpl implements HotelRepository {
  final HotelRemoteDataSource remoteDataSource;

  HotelRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<HotelOffer>> searchHotels(HotelSearchQuery query) async {
    return remoteDataSource.fetchHotelOffers(query);
  }

  @override
  Future<HotelOffer?> getHotelDetails(String hotelId) async {
    return remoteDataSource.fetchHotelDetails(hotelId);
  }
}
