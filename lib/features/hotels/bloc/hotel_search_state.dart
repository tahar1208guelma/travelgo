import '../models/hotel_offer.dart';
import '../models/hotel_search_query.dart';

abstract class HotelSearchState {
  const HotelSearchState();
}

class HotelSearchInitial extends HotelSearchState {
  const HotelSearchInitial();
}

class HotelSearchLoading extends HotelSearchState {
  final HotelSearchQuery query;
  const HotelSearchLoading(this.query);
}

class HotelSearchSuccess extends HotelSearchState {
  final HotelSearchQuery query;
  final List<HotelOffer> allHotels;
  final List<HotelOffer> filteredHotels;
  final int? activeMinStarRating;
  final String activeSort;

  const HotelSearchSuccess({
    required this.query,
    required this.allHotels,
    required this.filteredHotels,
    this.activeMinStarRating,
    this.activeSort = 'rating',
  });

  HotelSearchSuccess copyWith({
    List<HotelOffer>? filteredHotels,
    int? activeMinStarRating,
    String? activeSort,
  }) {
    return HotelSearchSuccess(
      query: query,
      allHotels: allHotels,
      filteredHotels: filteredHotels ?? this.filteredHotels,
      activeMinStarRating: activeMinStarRating ?? this.activeMinStarRating,
      activeSort: activeSort ?? this.activeSort,
    );
  }
}

class HotelSearchFailure extends HotelSearchState {
  final String errorMessage;
  final HotelSearchQuery query;

  const HotelSearchFailure({required this.errorMessage, required this.query});
}
