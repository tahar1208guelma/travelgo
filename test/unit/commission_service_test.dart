import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/services/commission_service.dart';

void main() {
  group('CommissionService Tests', () {
    late CommissionService service;

    setUp(() {
      service = CommissionService();
    });

    test('Default direct booking includes standard 1 USD service fee', () {
      final pricing = service.calculatePricing(
        basePriceUSD: 250.0,
        isAffiliate: false,
      );

      expect(pricing.basePriceUSD, 250.0);
      expect(pricing.serviceFeeUSD, 1.0);
      expect(pricing.totalAmountUSD, 251.0);
      expect(pricing.grossBookingValueUSD, 251.0);
      expect(pricing.providerPayoutUSD, 250.0);
      expect(pricing.netPlatformRevenueUSD, 1.0);
      expect(pricing.isAffiliate, false);
    });

    test('Affiliate booking does not add service fee by default (transparent \$0 markup)', () {
      final pricing = service.calculatePricing(
        basePriceUSD: 250.0,
        isAffiliate: true,
      );

      expect(pricing.basePriceUSD, 250.0);
      expect(pricing.serviceFeeUSD, 0.0);
      expect(pricing.platformCommissionUSD, 0.0);
      expect(pricing.totalAmountUSD, 250.0);
      expect(pricing.providerPayoutUSD, 250.0);
      expect(pricing.isAffiliate, true);
    });

    test('Configurable service fee dynamically changes direct fee', () {
      service.updateServiceFeeUSD(2.50);
      final pricing = service.calculatePricing(
        basePriceUSD: 100.0,
        isAffiliate: false,
      );

      expect(pricing.serviceFeeUSD, 2.50);
      expect(pricing.totalAmountUSD, 102.50);
      expect(pricing.netPlatformRevenueUSD, 2.50);
    });

    test('Percentage-based commission calculates deterministic 0.75% fee', () {
      service.updateCommissionModel(CommissionModel.percentage);
      // 0.75% of 200.0 = 1.50
      final pricing = service.calculatePricing(
        basePriceUSD: 200.0,
        isAffiliate: false,
      );

      expect(pricing.platformCommissionUSD, 1.50);
      expect(pricing.serviceFeeUSD, 1.50);
      expect(pricing.totalAmountUSD, 201.50);
      expect(pricing.partnerPayoutUSD, 198.50); // 200.0 - 1.50
      expect(pricing.netPlatformRevenueUSD, 1.50);
    });

    test('Partner tier rates calculate correct commission (e.g. 12% hotel direct)', () {
      service.updateCommissionModel(CommissionModel.percentage);
      final hotelRate = service.state.getRateForPartnerTier(PartnerTier.hotelDirect); // 12%
      expect(hotelRate, 0.12);

      final pricing = service.calculatePricing(
        basePriceUSD: 100.0,
        isAffiliate: false,
        customCommissionRate: hotelRate,
      );

      expect(pricing.platformCommissionUSD, 12.0);
      expect(pricing.serviceFeeUSD, 12.0);
      expect(pricing.partnerPayoutUSD, 88.0);
      expect(pricing.netPlatformRevenueUSD, 12.0);
    });

    test('Taxes and service fee are rounded to 2 decimal places deterministically', () {
      final pricing = service.calculatePricing(
        basePriceUSD: 133.33,
        isAffiliate: false,
        customTaxRate: 0.075, // 7.5%
      );

      // Tax: 133.33 * 0.075 = 9.99975 -> 10.00
      expect(pricing.taxesUSD, 10.00);
      expect(pricing.serviceFeeUSD, 1.00);
      // Total: 133.33 + 10.00 + 1.00 = 144.33
      expect(pricing.totalAmountUSD, 144.33);
    });

    test('Cancellation refund calculation retains platform fee when configured', () {
      final refund = service.calculateCancellationRefund(
        grossTotalUSD: 251.0,
        basePriceUSD: 250.0,
        taxesUSD: 0.0,
        platformFeeUSD: 1.0,
        providerPayoutUSD: 250.0,
        refundPlatformFee: false, // TravelGo retains $1.00 fee
      );

      expect(refund.platformFeeRetainedUSD, 1.0);
      expect(refund.platformFeeRefundedUSD, 0.0);
      expect(refund.netCustomerRefundUSD, 250.0);
      expect(refund.providerPayoutDeductionUSD, 250.0);
    });

    test('Cancellation refund calculation refunds platform fee when full waiver is applied', () {
      final refund = service.calculateCancellationRefund(
        grossTotalUSD: 251.0,
        basePriceUSD: 250.0,
        taxesUSD: 0.0,
        platformFeeUSD: 1.0,
        providerPayoutUSD: 250.0,
        refundPlatformFee: true, // Full waiver
      );

      expect(refund.platformFeeRetainedUSD, 0.0);
      expect(refund.platformFeeRefundedUSD, 1.0);
      expect(refund.netCustomerRefundUSD, 251.0);
      expect(refund.providerPayoutDeductionUSD, 250.0);
    });
  });
}
