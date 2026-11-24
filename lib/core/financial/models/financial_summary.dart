class FinancialSummary {
  final double grossBookingValueUSD;       // Net GBV (credits minus debits)
  final double totalGrossVolumeUSD;        // Cumulative gross volume (gross sales before refunds)
  final double totalProviderPayoutsUSD;    // Net payable to travel providers
  final double totalNetPlatformRevenueUSD; // TravelGo net earned platform fees & commissions
  final double totalTaxesUSD;              // Total pass-through taxes
  final double totalRefundedUSD;           // Total refunds disbursed
  final int totalEntries;                  // Total ledger transactions
  final int bookingCreditsCount;           // Count of positive bookings
  final int cancellationsCount;            // Count of cancellations/refunds
  final DateTime generatedAt;

  const FinancialSummary({
    required this.grossBookingValueUSD,
    required this.totalGrossVolumeUSD,
    required this.totalProviderPayoutsUSD,
    required this.totalNetPlatformRevenueUSD,
    required this.totalTaxesUSD,
    required this.totalRefundedUSD,
    required this.totalEntries,
    required this.bookingCreditsCount,
    required this.cancellationsCount,
    required this.generatedAt,
  });

  factory FinancialSummary.empty() {
    return FinancialSummary(
      grossBookingValueUSD: 0.0,
      totalGrossVolumeUSD: 0.0,
      totalProviderPayoutsUSD: 0.0,
      totalNetPlatformRevenueUSD: 0.0,
      totalTaxesUSD: 0.0,
      totalRefundedUSD: 0.0,
      totalEntries: 0,
      bookingCreditsCount: 0,
      cancellationsCount: 0,
      generatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'grossBookingValueUSD': grossBookingValueUSD,
      'totalGrossVolumeUSD': totalGrossVolumeUSD,
      'totalProviderPayoutsUSD': totalProviderPayoutsUSD,
      'totalNetPlatformRevenueUSD': totalNetPlatformRevenueUSD,
      'totalTaxesUSD': totalTaxesUSD,
      'totalRefundedUSD': totalRefundedUSD,
      'totalEntries': totalEntries,
      'bookingCreditsCount': bookingCreditsCount,
      'cancellationsCount': cancellationsCount,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}
