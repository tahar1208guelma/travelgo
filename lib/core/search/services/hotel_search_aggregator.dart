import 'dart:async';
import '../../../features/hotels/domain/entities/hotel_entity.dart';
import '../../../features/hotels/domain/entities/hotel_search_params.dart';
import '../domain/hotel_search_provider.dart';
import '../domain/provider_search_result.dart';
import 'hotel_deduplicator.dart';

/// Concurrent multi-provider hotel search engine.
///
/// Features:
/// - Parallel query fanout across direct partner inventory, affiliate channels (Booking.com/Agoda), and global inventory
/// - Partial failure resilience: failures in one provider do not disrupt results from other providers
/// - Geographic proximity deduplication (<= 150m) and name normalization via [HotelDeduplicator]
/// - Comprehensive latency and response metrics
class HotelSearchAggregator {
  final List<HotelSearchProvider> _providers;
  final HotelDeduplicator _deduplicator;

  HotelSearchAggregator({
    required List<HotelSearchProvider> providers,
    HotelDeduplicator? deduplicator,
  })  : _providers = providers,
        _deduplicator = deduplicator ?? HotelDeduplicator();

  List<HotelSearchProvider> get providers => List.unmodifiable(_providers);

  Future<AggregatedSearchResult<HotelEntity>> searchAll(HotelSearchParams params) async {
    final overallStopwatch = Stopwatch()..start();
    final List<ProviderMetadata> metrics = [];
    final List<HotelEntity> collectedHotels = [];
    bool hasErrors = false;

    final futures = _providers.map((provider) async {
      final pStopwatch = Stopwatch()..start();
      try {
        final results = await provider.searchHotels(params).timeout(provider.timeout);
        pStopwatch.stop();

        metrics.add(ProviderMetadata(
          providerId: provider.providerId,
          providerName: provider.providerName,
          latency: pStopwatch.elapsed,
          resultCount: results.length,
          isSuccessful: true,
        ));

        return results;
      } catch (e) {
        pStopwatch.stop();
        hasErrors = true;

        metrics.add(ProviderMetadata(
          providerId: provider.providerId,
          providerName: provider.providerName,
          latency: pStopwatch.elapsed,
          resultCount: 0,
          isSuccessful: false,
          errorMessage: e.toString(),
        ));

        return <HotelEntity>[];
      }
    });

    final allResults = await Future.wait(futures);
    for (final batch in allResults) {
      collectedHotels.addAll(batch);
    }

    final deduplicated = _deduplicator.deduplicate(collectedHotels);
    overallStopwatch.stop();

    return AggregatedSearchResult<HotelEntity>(
      results: deduplicated,
      providerMetrics: metrics,
      totalSearchDuration: overallStopwatch.elapsed,
      hasPartialErrors: hasErrors,
    );
  }
}
