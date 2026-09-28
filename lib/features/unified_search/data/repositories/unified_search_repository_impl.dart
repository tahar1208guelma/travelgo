import '../datasources/amadeus_search_datasource.dart';
import '../datasources/booking_affiliate_datasource.dart';
import '../datasources/local_search_datasource.dart';
import '../../domain/entities/unified_search_result_entity.dart';
import '../../domain/services/search_cache_manager.dart';
import '../../domain/services/search_deduplicator.dart';

abstract class UnifiedSearchRepository {
  Future<List<UnifiedSearchResultEntity>> search(UnifiedSearchFilters filters);
  Future<Map<String, dynamic>> handleApiSearchEndpoint(Map<String, dynamic> queryParams);
}

class UnifiedSearchRepositoryImpl implements UnifiedSearchRepository {
  final LocalSearchDataSource _localDataSource;
  final AmadeusSearchDataSource _amadeusDataSource;
  final BookingAffiliateDataSource _affiliateDataSource;
  final SearchCacheManager _cacheManager;

  UnifiedSearchRepositoryImpl({
    LocalSearchDataSource? localDataSource,
    AmadeusSearchDataSource? amadeusDataSource,
    BookingAffiliateDataSource? affiliateDataSource,
    SearchCacheManager? cacheManager,
  })  : _localDataSource = localDataSource ?? LocalSearchDataSource(),
        _amadeusDataSource = amadeusDataSource ?? AmadeusSearchDataSource(),
        _affiliateDataSource = affiliateDataSource ?? BookingAffiliateDataSource(),
        _cacheManager = cacheManager ?? SearchCacheManager();

  @override
  Future<List<UnifiedSearchResultEntity>> search(UnifiedSearchFilters filters) async {
    final cacheKey = filters.toCacheKey();

    // 1. Check 1-hour in-memory / Redis cache
    final cached = _cacheManager.get(cacheKey);
    if (cached != null) {
      return cached;
    }

    // 2. Fetch concurrently from all 3 data sources
    final results = await Future.wait([
      _localDataSource.search(filters),
      _amadeusDataSource.search(filters),
      _affiliateDataSource.search(filters),
    ]);

    final List<UnifiedSearchResultEntity> rawCombined = [
      ...results[0],
      ...results[1],
      ...results[2],
    ];

    // 3. Deduplicate based on fuzzy name + GPS coordinates
    final deduplicated = SearchDeduplicator.deduplicate(rawCombined);

    // 4. Apply Advanced Filters
    final filtered = deduplicated.where((item) {
      // Price range
      if (item.price < filters.minPrice || item.price > filters.maxPrice) {
        return false;
      }
      // Star rating
      if (filters.minRating > 0 && item.rating < filters.minRating) {
        return false;
      }
      // Accommodation type
      if (filters.accommodationType != AccommodationType.all &&
          item.type != filters.accommodationType) {
        return false;
      }
      // Free cancellation
      if (filters.freeCancellationOnly && !item.freeCancellation) {
        return false;
      }
      // Breakfast included
      if (filters.breakfastIncludedOnly && !item.breakfastIncluded) {
        return false;
      }
      // Required amenities
      if (filters.requiredAmenities.isNotEmpty) {
        for (final req in filters.requiredAmenities) {
          if (!item.amenities.any((a) => a.toLowerCase().contains(req.toLowerCase()))) {
            return false;
          }
        }
      }
      return true;
    }).toList();

    // 5. Apply Sorting
    switch (filters.sortBy) {
      case SearchSortBy.priceLowToHigh:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SearchSortBy.priceHighToLow:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SearchSortBy.rating:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SearchSortBy.relevance:
        // Prioritize verified partners and highest rated items
        filtered.sort((a, b) {
          if (a.isPartnerVerified && !b.isPartnerVerified) return -1;
          if (b.isPartnerVerified && !a.isPartnerVerified) return 1;
          return b.rating.compareTo(a.rating);
        });
        break;
    }

    // 6. Cache valid response for 1 hour
    _cacheManager.put(cacheKey, filtered);

    return filtered;
  }

  /// Single unified `/api/search` endpoint representation
  @override
  Future<Map<String, dynamic>> handleApiSearchEndpoint(Map<String, dynamic> queryParams) async {
    final filters = UnifiedSearchFilters(
      query: queryParams['q']?.toString() ?? '',
      destination: queryParams['destination']?.toString() ?? '',
      guests: int.tryParse(queryParams['guests']?.toString() ?? '1') ?? 1,
      minPrice: double.tryParse(queryParams['minPrice']?.toString() ?? '0') ?? 0,
      maxPrice: double.tryParse(queryParams['maxPrice']?.toString() ?? '2000') ?? 2000,
      minRating: double.tryParse(queryParams['minRating']?.toString() ?? '0') ?? 0,
      accommodationType: AccommodationType.values.firstWhere(
        (e) => e.name == queryParams['type'],
        orElse: () => AccommodationType.all,
      ),
      freeCancellationOnly: queryParams['freeCancellation'] == 'true',
      breakfastIncludedOnly: queryParams['breakfastIncluded'] == 'true',
      sortBy: SearchSortBy.values.firstWhere(
        (e) => e.name == queryParams['sortBy'],
        orElse: () => SearchSortBy.relevance,
      ),
    );

    final results = await search(filters);

    return {
      'status': 'success',
      'timestamp': DateTime.now().toIso8601String(),
      'cached': _cacheManager.hits > 0,
      'total': results.length,
      'filters_applied': {
        'query': filters.query,
        'destination': filters.destination,
        'minPrice': filters.minPrice,
        'maxPrice': filters.maxPrice,
        'type': filters.accommodationType.name,
      },
      'results': results.map((r) => r.toJson()).toList(),
    };
  }
}
