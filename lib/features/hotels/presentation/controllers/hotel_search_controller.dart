import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers_layer/travel_provider.dart';
import '../../../flights/presentation/controllers/flight_search_controller.dart';
import '../../data/repositories/hotel_repository_impl.dart';
import '../../domain/entities/hotel_entity.dart';
import '../../domain/entities/hotel_search_params.dart';

enum HotelSortOption { priceLowToHigh, ratingHighToLow, popular }

class HotelFilterState {
  final HotelSortOption sortOption;
  final int? minStarRating;
  final bool freeCancellationOnly;
  final bool breakfastIncludedOnly;
  final double? maxPriceUSD;

  const HotelFilterState({
    this.sortOption = HotelSortOption.popular,
    this.minStarRating,
    this.freeCancellationOnly = false,
    this.breakfastIncludedOnly = false,
    this.maxPriceUSD,
  });

  HotelFilterState copyWith({
    HotelSortOption? sortOption,
    int? minStarRating,
    bool clearStarRating = false,
    bool? freeCancellationOnly,
    bool? breakfastIncludedOnly,
    double? maxPriceUSD,
  }) {
    return HotelFilterState(
      sortOption: sortOption ?? this.sortOption,
      minStarRating: clearStarRating ? null : (minStarRating ?? this.minStarRating),
      freeCancellationOnly: freeCancellationOnly ?? this.freeCancellationOnly,
      breakfastIncludedOnly: breakfastIncludedOnly ?? this.breakfastIncludedOnly,
      maxPriceUSD: maxPriceUSD ?? this.maxPriceUSD,
    );
  }
}

class HotelSearchResultState {
  final HotelSearchParams params;
  final List<HotelEntity> rawHotels;
  final HotelFilterState filterState;
  final bool isLoading;
  final String? errorMessage;

  const HotelSearchResultState({
    required this.params,
    this.rawHotels = const [],
    this.filterState = const HotelFilterState(),
    this.isLoading = false,
    this.errorMessage,
  });

  List<HotelEntity> get filteredHotels {
    var list = List<HotelEntity>.from(rawHotels);

    if (filterState.minStarRating != null) {
      list = list.where((h) => h.starRating >= filterState.minStarRating!).toList();
    }

    if (filterState.freeCancellationOnly) {
      list = list.where((h) => h.freeCancellation).toList();
    }

    if (filterState.breakfastIncludedOnly) {
      list = list.where((h) => h.breakfastIncluded).toList();
    }

    if (filterState.maxPriceUSD != null) {
      list = list.where((h) => h.pricePerNightUSD <= filterState.maxPriceUSD!).toList();
    }

    switch (filterState.sortOption) {
      case HotelSortOption.priceLowToHigh:
        list.sort((a, b) => a.pricePerNightUSD.compareTo(b.pricePerNightUSD));
        break;
      case HotelSortOption.ratingHighToLow:
        list.sort((a, b) => b.userRating.compareTo(a.userRating));
        break;
      case HotelSortOption.popular:
        list.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
    }

    return list;
  }

  HotelSearchResultState copyWith({
    HotelSearchParams? params,
    List<HotelEntity>? rawHotels,
    HotelFilterState? filterState,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HotelSearchResultState(
      params: params ?? this.params,
      rawHotels: rawHotels ?? this.rawHotels,
      filterState: filterState ?? this.filterState,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final hotelRepositoryProvider = Provider<HotelRepositoryImpl>((ref) {
  final provider = ref.watch(travelProviderRef);
  return HotelRepositoryImpl(provider);
});

final hotelSearchControllerProvider = StateNotifierProvider<HotelSearchController, HotelSearchResultState>((ref) {
  final repository = ref.watch(hotelRepositoryProvider);
  return HotelSearchController(repository);
});

class HotelSearchController extends StateNotifier<HotelSearchResultState> {
  final HotelRepositoryImpl _repository;

  HotelSearchController(this._repository)
      : super(HotelSearchResultState(
          params: HotelSearchParams(
            destination: 'Dubai',
            checkInDate: DateTime.now().add(const Duration(days: 5)),
            checkOutDate: DateTime.now().add(const Duration(days: 9)),
          ),
        ));

  void updateSearchParams(HotelSearchParams newParams) {
    state = state.copyWith(params: newParams);
  }

  void updateFilter(HotelFilterState filter) {
    state = state.copyWith(filterState: filter);
  }

  Future<void> searchHotels() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final results = await _repository.searchHotels(state.params);
      state = state.copyWith(rawHotels: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
