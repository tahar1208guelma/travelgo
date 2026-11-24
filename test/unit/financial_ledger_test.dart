import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/financial/financial.dart';
import 'package:travelgo/core/services/commission_service.dart';

void main() {
  group('FinancialLedgerService Tests', () {
    late FinancialLedgerService ledger;
    late CommissionService commissionService;

    setUp(() {
      ledger = FinancialLedgerService();
      commissionService = CommissionService();
    });

    test('Records direct booking credit with GBV, provider payout, and net platform revenue', () {
      final pricing = commissionService.calculatePricing(
        basePriceUSD: 300.0,
        isAffiliate: false,
        customTaxRate: 0.10, // 10% tax = $30.00
      );
      // Pricing: Base 300.00, Tax 30.00, Service Fee 1.00 -> Total 331.00 USD
      expect(pricing.totalAmountUSD, 331.0);
      expect(pricing.providerPayoutUSD, 300.0);
      expect(pricing.netPlatformRevenueUSD, 1.0);

      final entry = ledger.recordDirectBooking(
        bookingId: 'BK-101',
        bookingReference: 'PNR-ABC123',
        pricing: pricing,
        paymentMethod: 'stripe',
        paymentTransactionId: 'ch_test_101',
      );

      expect(entry.bookingId, 'BK-101');
      expect(entry.bookingReference, 'PNR-ABC123');
      expect(entry.type, LedgerEntryType.bookingCredit);
      expect(entry.grossBookingValueUSD, 331.0);
      expect(entry.basePriceUSD, 300.0);
      expect(entry.taxesUSD, 30.0);
      expect(entry.platformFeeUSD, 1.0);
      expect(entry.providerPayoutUSD, 300.0);
      expect(entry.status, LedgerEntryStatus.cleared);
      expect(ledger.state.length, 1);
    });

    test('Records cancellation refund with immutable compensatory debit entry', () {
      final pricing = commissionService.calculatePricing(
        basePriceUSD: 200.0,
        isAffiliate: false,
        customTaxRate: 0.05, // 5% tax = $10.00
      );
      // Total = 211.00 USD (Base 200, Tax 10, Platform Fee 1)

      ledger.recordDirectBooking(
        bookingId: 'BK-202',
        bookingReference: 'PNR-XYZ789',
        pricing: pricing,
        paymentMethod: 'paypal',
        paymentTransactionId: 'PAYPAL-CAP-1',
      );

      // Cancel with TravelGo retaining $1.00 platform fee
      final refundEntry = ledger.recordCancellationRefund(
        bookingId: 'BK-202',
        bookingReference: 'PNR-XYZ789',
        refundPlatformFee: false,
        reason: 'Traveler cancelled due to schedule conflict',
        refundTransactionId: 'REF-PAYPAL-1',
      );

      expect(refundEntry.type, LedgerEntryType.cancellationDebit);
      expect(refundEntry.grossBookingValueUSD, -210.0); // User refunded Base (200) + Tax (10)
      expect(refundEntry.basePriceUSD, -200.0);
      expect(refundEntry.taxesUSD, -10.0);
      expect(refundEntry.platformFeeUSD, 0.0); // Retained fee is not debited
      expect(refundEntry.providerPayoutUSD, -200.0); // Obligation to provider is reversed
      expect(refundEntry.status, LedgerEntryStatus.refunded);

      // Audit trail maintains both records
      expect(ledger.state.length, 2);
      final bookingEntries = ledger.getEntriesForBooking('BK-202');
      expect(bookingEntries.length, 2);
      expect(bookingEntries[0].type, LedgerEntryType.bookingCredit);
      expect(bookingEntries[1].type, LedgerEntryType.cancellationDebit);
    });

    test('Calculates aggregated FinancialSummary correctly across multiple transactions', () {
      // Booking 1: $100 base, $0 tax, $1 platform fee = $101 total
      final pricing1 = commissionService.calculatePricing(
        basePriceUSD: 100.0,
        isAffiliate: false,
      );
      ledger.recordDirectBooking(
        bookingId: 'BK-1',
        bookingReference: 'PNR-1',
        pricing: pricing1,
        paymentMethod: 'stripe',
      );

      // Booking 2: $200 base, $20 tax, $1 platform fee = $221 total
      final pricing2 = commissionService.calculatePricing(
        basePriceUSD: 200.0,
        isAffiliate: false,
        customTaxRate: 0.10,
      );
      ledger.recordDirectBooking(
        bookingId: 'BK-2',
        bookingReference: 'PNR-2',
        pricing: pricing2,
        paymentMethod: 'mytpe',
      );

      // Booking 3: $300 base, $0 tax, $1 platform fee = $301 total
      final pricing3 = commissionService.calculatePricing(
        basePriceUSD: 300.0,
        isAffiliate: false,
      );
      ledger.recordDirectBooking(
        bookingId: 'BK-3',
        bookingReference: 'PNR-3',
        pricing: pricing3,
        paymentMethod: 'paypal',
      );

      // Cancel Booking 1 (Full refund with platform fee waiver)
      ledger.recordCancellationRefund(
        bookingId: 'BK-1',
        bookingReference: 'PNR-1',
        refundPlatformFee: true,
      );

      final summary = ledger.calculateSummary();

      // Cumulative Gross Sales Volume = 101 + 221 + 301 = 623.00 USD
      expect(summary.totalGrossVolumeUSD, 623.00);
      // Total Refunded = 101.00 USD
      expect(summary.totalRefundedUSD, 101.00);
      // Net GBV = 623.00 - 101.00 = 522.00 USD
      expect(summary.grossBookingValueUSD, 522.00);
      // Provider Payouts Net = (100 - 100) + 200 + 300 = 500.00 USD
      expect(summary.totalProviderPayoutsUSD, 500.00);
      // Net Platform Revenue = (1 - 1) + 1 + 1 = 2.00 USD
      expect(summary.totalNetPlatformRevenueUSD, 2.00);
      // Total Taxes = 0 + 20 + 0 = 20.00 USD
      expect(summary.totalTaxesUSD, 20.00);

      // Strict Mathematical Conservation of Money Check:
      // Net GBV ($522) = Provider Payouts ($500) + Net Revenue ($2) + Taxes ($20)
      expect(summary.grossBookingValueUSD, summary.totalProviderPayoutsUSD + summary.totalNetPlatformRevenueUSD + summary.totalTaxesUSD);
    });

    test('Records provider payout settlement without affecting gross booking value', () {
      final pricing = commissionService.calculatePricing(
        basePriceUSD: 500.0,
        isAffiliate: false,
      );
      ledger.recordDirectBooking(
        bookingId: 'BK-SETTLE-1',
        bookingReference: 'PNR-S1',
        pricing: pricing,
        paymentMethod: 'stripe',
      );

      final settlement = ledger.recordProviderPayoutSettlement(
        bookingId: 'BK-SETTLE-1',
        bookingReference: 'PNR-S1',
        amountUSD: 500.0,
        settlementReference: 'ACH-WIRE-8899',
      );

      expect(settlement.type, LedgerEntryType.providerPayoutSettled);
      expect(settlement.grossBookingValueUSD, 0.0);
      expect(settlement.providerPayoutUSD, -500.0);
      expect(settlement.status, LedgerEntryStatus.reconciled);
    });
  });
}
