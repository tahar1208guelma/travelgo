import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/unified_search_repository_impl.dart';
import '../../domain/entities/unified_search_result_entity.dart';

enum SearchDisplayMode { grid, map }

final unifiedSearchRepositoryProvider = Provider<UnifiedSearchRepository>((ref) {
  return UnifiedSearchRepositoryImpl();
});

final searchDisplayModeProvider = StateProvider<SearchDisplayMode>((ref) => SearchDisplayMode.grid);

final searchFiltersProvider = StateProvider<UnifiedSearchFilters>((ref) {
  return const UnifiedSearchFilters();
});

final selectedMapItemProvider = StateProvider<UnifiedSearchResultEntity?>((ref) => null);

final unifiedSearchResultsProvider = FutureProvider.autoDispose<List<UnifiedSearchResultEntity>>((ref) async {
  final repository = ref.watch(unifiedSearchRepositoryProvider);
  final filters = ref.watch(searchFiltersProvider);
  return repository.search(filters);
});

final unifiedSearchControllerProvider = StateNotifierProvider<UnifiedSearchController, AsyncValue<List<UnifiedSearchResultEntity>>>((ref) {
  final repository = ref.watch(unifiedSearchRepositoryProvider);
  return UnifiedSearchController(repository, ref);
});

class UnifiedSearchController extends StateNotifier<AsyncValue<List<UnifiedSearchResultEntity>>> {
  final UnifiedSearchRepository _repository;
  final Ref _ref;
  Timer? _debounceTimer;

  UnifiedSearchController(this._repository, this._ref) : super(const AsyncValue.loading()) {
    executeSearch();
  }

  void updateQueryDebounced(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final current = _ref.read(searchFiltersProvider);
      _ref.read(searchFiltersProvider.notifier).state = current.copyWith(query: query);
      executeSearch();
    });
  }

  void updateDestination(String destination) {
    final current = _ref.read(searchFiltersProvider);
    _ref.read(searchFiltersProvider.notifier).state = current.copyWith(destination: destination);
    executeSearch();
  }

  void updateCategory(AccommodationType type) {
    final current = _ref.read(searchFiltersProvider);
    _ref.read(searchFiltersProvider.notifier).state = current.copyWith(accommodationType: type);
    executeSearch();
  }

  void updatePriceRange(double min, double max) {
    final current = _ref.read(searchFiltersProvider);
    _ref.read(searchFiltersProvider.notifier).state = current.copyWith(minPrice: min, maxPrice: max);
    executeSearch();
  }

  void updateRating(double minRating) {
    final current = _ref.read(searchFiltersProvider);
    _ref.read(searchFiltersProvider.notifier).state = current.copyWith(minRating: minRating);
    executeSearch();
  }

  void toggleFreeCancellation(bool value) {
    final current = _ref.read(searchFiltersProvider);
    _ref.read(searchFiltersProvider.notifier).state = current.copyWith(freeCancellationOnly: value);
    executeSearch();
  }

  void toggleBreakfastIncluded(bool value) {
    final current = _ref.read(searchFiltersProvider);
    _ref.read(searchFiltersProvider.notifier).state = current.copyWith(breakfastIncludedOnly: value);
    executeSearch();
  }

  void updateSortBy(SearchSortBy sortBy) {
    final current = _ref.read(searchFiltersProvider);
    _ref.read(searchFiltersProvider.notifier).state = current.copyWith(sortBy: sortBy);
    executeSearch();
  }

  void resetFilters() {
    _ref.read(searchFiltersProvider.notifier).state = const UnifiedSearchFilters();
    executeSearch();
  }

  Future<void> executeSearch() async {
    state = const AsyncValue.loading();
    try {
      final filters = _ref.read(searchFiltersProvider);
      final results = await _repository.search(filters);
      state = AsyncValue.data(results);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
