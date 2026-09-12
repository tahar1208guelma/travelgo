import '../models/hotel_search_query.dart';

abstract class HotelSearchEvent {
  const HotelSearchEvent();
}

class SearchHotelsRequested extends HotelSearchEvent {
  final HotelSearchQuery query;
  const SearchHotelsRequested(this.query);
}

class FilterHotelsRequested extends HotelSearchEvent {
  final int? minStarRating;
  final double? maxPrice;
  final String? sortBy; // 'price', 'rating', 'name'

  const FilterHotelsRequested({
    this.minStarRating,
    this.maxPrice,
    this.sortBy,
  });
}
