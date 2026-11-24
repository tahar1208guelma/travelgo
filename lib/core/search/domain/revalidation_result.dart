enum RevalidationStatus {
  confirmed,
  priceChanged,
  soldOut,
  providerUnavailable,
}

class RevalidationResult {
  final RevalidationStatus status;
  final String itemId;
  final double currentPriceUSD;
  final double? previousPriceUSD;
  final int remainingInventory;
  final String? statusMessage;
  final DateTime verifiedAt;

  const RevalidationResult({
    required this.status,
    required this.itemId,
    required this.currentPriceUSD,
    this.previousPriceUSD,
    this.remainingInventory = 5,
    this.statusMessage,
    required this.verifiedAt,
  });

  bool get isBookable =>
      status == RevalidationStatus.confirmed || status == RevalidationStatus.priceChanged;

  bool get priceHasChanged =>
      previousPriceUSD != null && (currentPriceUSD - previousPriceUSD!).abs() > 0.01;
}
