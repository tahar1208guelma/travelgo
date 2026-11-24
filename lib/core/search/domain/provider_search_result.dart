class ProviderMetadata {
  final String providerId;
  final String providerName;
  final Duration latency;
  final int resultCount;
  final bool isSuccessful;
  final String? errorMessage;
  final bool isCached;

  const ProviderMetadata({
    required this.providerId,
    required this.providerName,
    required this.latency,
    required this.resultCount,
    this.isSuccessful = true,
    this.errorMessage,
    this.isCached = false,
  });
}

class AggregatedSearchResult<T> {
  final List<T> results;
  final List<ProviderMetadata> providerMetrics;
  final Duration totalSearchDuration;
  final bool hasPartialErrors;

  const AggregatedSearchResult({
    required this.results,
    required this.providerMetrics,
    required this.totalSearchDuration,
    this.hasPartialErrors = false,
  });

  int get totalResults => results.length;
  List<String> get successfulProviders =>
      providerMetrics.where((m) => m.isSuccessful).map((m) => m.providerName).toList();
  List<String> get failedProviders =>
      providerMetrics.where((m) => !m.isSuccessful).map((m) => m.providerName).toList();
}
