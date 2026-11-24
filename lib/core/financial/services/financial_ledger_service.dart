import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../services/commission_service.dart';
import '../models/financial_summary.dart';
import '../models/ledger_entry.dart';

final financialLedgerServiceProvider =
    StateNotifierProvider<FinancialLedgerService, List<LedgerEntry>>((ref) {
  return FinancialLedgerService();
});

class FinancialLedgerService extends StateNotifier<List<LedgerEntry>> {
  final Uuid _uuid;

  FinancialLedgerService([List<LedgerEntry> initialEntries = const []])
      : _uuid = const Uuid(),
        super(initialEntries);

  /// Records a confirmed booking in the financial ledger.
  /// Tracks Gross Booking Value (GBV), provider payout obligation,
  /// and TravelGo net platform revenue.
  LedgerEntry recordDirectBooking({
    required String bookingId,
    required String bookingReference,
    required PriceCalculationResult pricing,
    required String paymentMethod,
    String? paymentTransactionId,
    Map<String, dynamic> metadata = const {},
    String? notes,
  }) {
    final entry = LedgerEntry(
      id: _uuid.v4(),
      bookingId: bookingId,
      bookingReference: bookingReference,
      timestamp: DateTime.now(),
      type: LedgerEntryType.bookingCredit,
      grossBookingValueUSD: pricing.totalAmountUSD,
      basePriceUSD: pricing.basePriceUSD,
      taxesUSD: pricing.taxesUSD,
      platformFeeUSD: pricing.netPlatformRevenueUSD,
      providerPayoutUSD: pricing.providerPayoutUSD,
      currency: pricing.currency,
      paymentMethod: paymentMethod,
      paymentTransactionId: paymentTransactionId,
      status: LedgerEntryStatus.cleared,
      metadata: metadata,
      notes: notes ?? 'Direct booking payment collected',
    );

    state = [...state, entry];
    return entry;
  }

  /// Records an immutable cancellation and refund adjustment in the ledger.
  /// Follows double-entry accounting principles with compensatory debit entries.
  LedgerEntry recordCancellationRefund({
    required String bookingId,
    required String bookingReference,
    bool refundPlatformFee = false,
    double cancellationFeePercentage = 0.0,
    String? reason,
    String? refundTransactionId,
  }) {
    // Find previous booking credit
    final original = state.lastWhere(
      (e) => e.bookingId == bookingId && e.type == LedgerEntryType.bookingCredit,
      orElse: () => LedgerEntry(
        id: 'fallback',
        bookingId: bookingId,
        bookingReference: bookingReference,
        timestamp: DateTime.now(),
        type: LedgerEntryType.bookingCredit,
        grossBookingValueUSD: 0.0,
        basePriceUSD: 0.0,
        taxesUSD: 0.0,
        platformFeeUSD: 0.0,
        providerPayoutUSD: 0.0,
        paymentMethod: 'unknown',
      ),
    );

    final penalty = ((original.basePriceUSD * cancellationFeePercentage) * 100).round() / 100.0;
    final refundableBase = ((original.basePriceUSD - penalty) * 100).round() / 100.0;
    final platformFeeRefunded = refundPlatformFee ? original.platformFeeUSD : 0.0;

    final netRefundUSD = ((refundableBase + original.taxesUSD + platformFeeRefunded) * 100).round() / 100.0;
    final providerDeductionUSD = ((refundableBase) * 100).round() / 100.0;

    final adjustmentEntry = LedgerEntry(
      id: _uuid.v4(),
      bookingId: bookingId,
      bookingReference: bookingReference,
      timestamp: DateTime.now(),
      type: LedgerEntryType.cancellationDebit,
      grossBookingValueUSD: -netRefundUSD, // Negative debit to reverse GBV
      basePriceUSD: -refundableBase,
      taxesUSD: -original.taxesUSD,
      platformFeeUSD: -platformFeeRefunded,
      providerPayoutUSD: -providerDeductionUSD, // Reverse provider payout obligation
      currency: original.currency,
      paymentMethod: original.paymentMethod,
      paymentTransactionId: refundTransactionId,
      status: LedgerEntryStatus.refunded,
      metadata: {
        'originalEntryId': original.id,
        'cancellationPenaltyUSD': penalty,
        'platformFeeRetainedUSD': refundPlatformFee ? 0.0 : original.platformFeeUSD,
        'reason': reason ?? 'User requested cancellation',
      },
      notes: reason ?? 'Booking cancellation and refund adjustment',
    );

    state = [...state, adjustmentEntry];
    return adjustmentEntry;
  }

  /// Records disbursement / settlement of provider payout
  LedgerEntry recordProviderPayoutSettlement({
    required String bookingId,
    required String bookingReference,
    required double amountUSD,
    required String settlementReference,
    String? notes,
  }) {
    final entry = LedgerEntry(
      id: _uuid.v4(),
      bookingId: bookingId,
      bookingReference: bookingReference,
      timestamp: DateTime.now(),
      type: LedgerEntryType.providerPayoutSettled,
      grossBookingValueUSD: 0.0, // Does not affect user GBV
      basePriceUSD: 0.0,
      taxesUSD: 0.0,
      platformFeeUSD: 0.0,
      providerPayoutUSD: -amountUSD, // Clears payable balance
      currency: 'USD',
      paymentMethod: 'bank_transfer',
      paymentTransactionId: settlementReference,
      status: LedgerEntryStatus.reconciled,
      notes: notes ?? 'Provider payout settled via banking gateway',
    );

    state = [...state, entry];
    return entry;
  }

  /// Calculates aggregated financial metrics deterministically
  FinancialSummary calculateSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    double netGbv = 0.0;
    double grossVolume = 0.0;
    double providerPayouts = 0.0;
    double netRevenue = 0.0;
    double totalTaxes = 0.0;
    double totalRefunded = 0.0;
    int bookingCredits = 0;
    int cancellations = 0;

    for (final entry in state) {
      if (startDate != null && entry.timestamp.isBefore(startDate)) continue;
      if (endDate != null && entry.timestamp.isAfter(endDate)) continue;

      if (entry.type == LedgerEntryType.bookingCredit) {
        grossVolume += entry.grossBookingValueUSD;
        netGbv += entry.grossBookingValueUSD;
        providerPayouts += entry.providerPayoutUSD;
        netRevenue += entry.platformFeeUSD;
        totalTaxes += entry.taxesUSD;
        bookingCredits++;
      } else if (entry.type == LedgerEntryType.cancellationDebit) {
        final refund = entry.grossBookingValueUSD.abs();
        totalRefunded += refund;
        netGbv += entry.grossBookingValueUSD; // subtracts refund
        providerPayouts += entry.providerPayoutUSD; // subtracts provider portion
        netRevenue += entry.platformFeeUSD; // subtracts refunded fee if any
        totalTaxes += entry.taxesUSD;
        cancellations++;
      }
    }

    return FinancialSummary(
      grossBookingValueUSD: ((netGbv) * 100).round() / 100.0,
      totalGrossVolumeUSD: ((grossVolume) * 100).round() / 100.0,
      totalProviderPayoutsUSD: ((providerPayouts) * 100).round() / 100.0,
      totalNetPlatformRevenueUSD: ((netRevenue) * 100).round() / 100.0,
      totalTaxesUSD: ((totalTaxes) * 100).round() / 100.0,
      totalRefundedUSD: ((totalRefunded) * 100).round() / 100.0,
      totalEntries: state.length,
      bookingCreditsCount: bookingCredits,
      cancellationsCount: cancellations,
      generatedAt: DateTime.now(),
    );
  }

  /// Retrieves all ledger entries for a given booking ID
  List<LedgerEntry> getEntriesForBooking(String bookingId) {
    return state.where((e) => e.bookingId == bookingId).toList();
  }

  /// Clears the ledger (useful for clean unit test isolation)
  void clearLedger() {
    state = [];
  }
}
