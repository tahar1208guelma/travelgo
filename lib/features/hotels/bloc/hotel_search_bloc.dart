import '../../../core/architecture/bloc_base.dart';
import '../models/hotel_offer.dart';
import '../repositories/hotel_repository.dart';
import 'hotel_search_event.dart';
import 'hotel_search_state.dart';

class HotelSearchBloc extends Bloc<HotelSearchEvent, HotelSearchState> {
  final HotelRepository repository;

  HotelSearchBloc({required this.repository}) : super(const HotelSearchInitial());

  @override
  void onEvent(HotelSearchEvent event) async {
    if (event is SearchHotelsRequested) {
      await _handleSearch(event);
    } else if (event is FilterHotelsRequested) {
      _handleFilter(event);
    }
  }

  Future<void> _handleSearch(SearchHotelsRequested event) async {
    emit(HotelSearchLoading(event.query));

    try {
      final hotels = await repository.searchHotels(event.query);
      if (hotels.isEmpty) {
        emit(HotelSearchFailure(
          errorMessage: 'No accommodations found for "${event.query.destination}".',
          query: event.query,
        ));
      } else {
        // Sort by user rating by default
        final sorted = List<HotelOffer>.from(hotels)
          ..sort((a, b) => b.userRating.compareTo(a.userRating));

        emit(HotelSearchSuccess(
          query: event.query,
          allHotels: hotels,
          filteredHotels: sorted,
          activeSort: 'rating',
        ));
      }
    } catch (e) {
      emit(HotelSearchFailure(
        errorMessage: 'Failed to search accommodations: $e',
        query: event.query,
      ));
    }
  }

  void _handleFilter(FilterHotelsRequested event) {
    final currentState = state;
    if (currentState is! HotelSearchSuccess) return;

    var result = List<HotelOffer>.from(currentState.allHotels);

    if (event.minStarRating != null) {
      result = result.where((h) => h.starRating >= event.minStarRating!).toList();
    }

    if (event.maxPrice != null) {
      result = result.where((h) => h.price.totalAmount <= event.maxPrice!).toList();
    }

    final sortBy = event.sortBy ?? currentState.activeSort;
    if (sortBy == 'price') {
      result.sort((a, b) => a.price.totalAmount.compareTo(b.price.totalAmount));
    } else if (sortBy == 'rating') {
      result.sort((a, b) => b.userRating.compareTo(a.userRating));
    } else if (sortBy == 'name') {
      result.sort((a, b) => a.name.compareTo(b.name));
    }

    emit(currentState.copyWith(
      filteredHotels: result,
      activeMinStarRating: event.minStarRating,
      activeSort: sortBy,
    ));
  }
}
