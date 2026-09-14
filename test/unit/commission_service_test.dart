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
      expect(pricing.isAffiliate, false);
    });

    test('Affiliate booking does not add service fee by default', () {
      final pricing = service.calculatePricing(
        basePriceUSD: 250.0,
        isAffiliate: true,
      );

      expect(pricing.basePriceUSD, 250.0);
      expect(pricing.serviceFeeUSD, 0.0);
      expect(pricing.totalAmountUSD, 250.0);
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
    });
  });
}
