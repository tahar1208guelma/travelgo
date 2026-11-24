import 'dart:async';
import '../../../features/flights/domain/entities/flight_entity.dart';
import '../../../features/flights/domain/entities/flight_search_params.dart';
import '../../../shared/models/airport.dart';
import '../domain/flight_search_provider.dart';
import '../domain/provider_search_result.dart';
import 'city_airports_resolver.dart';
import 'flight_deduplicator.dart';

/// Concurrent multi-provider flight search engine.
///
/// Features:
/// - Parallel query fanout across all registered flight providers (Amadeus, Duffel, Travelpayouts, Sandbox)
/// - Multi-airport city expansion (e.g. LON -> LHR, LGW, STN; NYC -> JFK, EWR, LGA)
/// - Proximity lookup: nearby airports within +150 km
/// - Flexible dates search (+/- flexibleDays)
/// - Partial failure resilience: individual timeouts or gateway errors never block other providers
/// - Deduplication and best-fare retention via [FlightDeduplicator]
class FlightSearchAggregator {
  final List<FlightSearchProvider> _providers;
  final FlightDeduplicator _deduplicator;
  final CityAirportsResolver _cityResolver;

  FlightSearchAggregator({
    required List<FlightSearchProvider> providers,
    FlightDeduplicator? deduplicator,
    CityAirportsResolver? cityResolver,
  })  : _providers = providers,
        _deduplicator = deduplicator ?? FlightDeduplicator(),
        _cityResolver = cityResolver ?? const CityAirportsResolver();

  List<FlightSearchProvider> get providers => List.unmodifiable(_providers);

  Future<AggregatedSearchResult<FlightEntity>> searchAll(FlightSearchParams params) async {
    final overallStopwatch = Stopwatch()..start();
    final List<ProviderMetadata> metrics = [];
    final List<FlightEntity> collectedOffers = [];
    bool hasErrors = false;

    // 1. Resolve multi-airport city codes and nearby airports (+150 km)
    final originAirports = _cityResolver.resolveAirportCodes(
      params.originCode,
      includeNearby: params.includeNearbyAirports,
    );
    final destAirports = _cityResolver.resolveAirportCodes(
      params.destinationCode,
      includeNearby: params.includeNearbyAirports,
    );

    // Limit combinatorial fanout to prevent exceeding rate limits (max top 3 origins x 3 destinations)
    final topOrigins = originAirports.take(3).toList();
    final topDests = destAirports.take(3).toList();

    // 2. Resolve flexible dates if requested (+/- flexibleDays, up to 3 days)
    final List<DateTime> departureDates = [params.departureDate];
    if (params.flexibleDays > 0) {
      final daysRange = params.flexibleDays.clamp(1, 3);
      for (var d = 1; d <= daysRange; d++) {
        final before = params.departureDate.subtract(Duration(days: d));
        if (before.isAfter(DateTime.now().subtract(const Duration(hours: 12)))) {
          departureDates.add(before);
        }
        departureDates.add(params.departureDate.add(Duration(days: d)));
      }
    }

    // 3. Build distinct query params for multi-airport / flexible search
    final List<FlightSearchParams> queryVariants = [];
    if (topOrigins.length <= 1 && topDests.length <= 1 && departureDates.length <= 1) {
      queryVariants.add(params);
    } else {
      for (final orig in topOrigins) {
        for (final dest in topDests) {
          if (orig == dest) continue;
          final origAirport = Airport.findByCode(orig);
          final destAirport = Airport.findByCode(dest);
          for (final depDate in departureDates) {
            queryVariants.add(params.copyWith(
              originCode: orig,
              originCity: origAirport?.cityEn ?? params.originCity,
              destinationCode: dest,
              destinationCity: destAirport?.cityEn ?? params.destinationCity,
              departureDate: depDate,
            ));
          }
        }
      }
      if (queryVariants.isEmpty) queryVariants.add(params);
    }

    // 4. Concurrently query all registered providers
    final providerTasks = _providers.map((provider) async {
      final pStopwatch = Stopwatch()..start();
      final List<FlightEntity> providerOffers = [];
      String? failureError;

      try {
        // Query the primary variant first
        final primaryFuture = provider.searchFlights(queryVariants.first).timeout(provider.timeout);

        // If there are additional multi-airport variants, run them concurrently (up to 4 variants)
        if (queryVariants.length > 1) {
          final additionalFutures = queryVariants.skip(1).take(3).map((variant) {
            return provider.searchFlights(variant).timeout(provider.timeout).catchError((_) => <FlightEntity>[]);
          });
          final results = await Future.wait([primaryFuture, ...additionalFutures]);
          for (final batch in results) {
            providerOffers.addAll(batch);
          }
        } else {
          final singleResult = await primaryFuture;
          providerOffers.addAll(singleResult);
        }
      } catch (e) {
        failureError = e.toString();
        hasErrors = true;
      } finally {
        pStopwatch.stop();
      }

      final isSuccess = failureError == null;
      metrics.add(ProviderMetadata(
        providerId: provider.providerId,
        providerName: provider.providerName,
        latency: pStopwatch.elapsed,
        resultCount: providerOffers.length,
        isSuccessful: isSuccess,
        errorMessage: failureError,
      ));

      return providerOffers;
    });

    final allProviderResults = await Future.wait(providerTasks);
    for (final batch in allProviderResults) {
      collectedOffers.addAll(batch);
    }

    // 5. Deduplicate and preserve optimal fares
    final deduplicated = _deduplicator.deduplicate(collectedOffers);
    overallStopwatch.stop();

    return AggregatedSearchResult<FlightEntity>(
      results: deduplicated,
      providerMetrics: metrics,
      totalSearchDuration: overallStopwatch.elapsed,
      hasPartialErrors: hasErrors,
    );
  }
}
