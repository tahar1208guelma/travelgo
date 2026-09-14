import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/utils/currency_formatter.dart';
import 'package:travelgo/shared/models/currency.dart';

void main() {
  group('Currency & Formatter Tests', () {
    test('USD formatting', () {
      const usd = Currency(
        code: 'USD',
        symbol: '\$',
        nameEn: 'US Dollar',
        nameAr: 'دولار أمريكي',
        exchangeRateToUSD: 1.0,
      );

      final formatted = AppCurrencyFormatter.formatAmountOnly(100.0, usd);
      expect(formatted, '100.00');
    });

    test('EUR conversion and formatting', () {
      const eur = Currency(
        code: 'EUR',
        symbol: '€',
        nameEn: 'Euro',
        nameAr: 'يورو',
        exchangeRateToUSD: 0.92,
      );

      final converted = AppCurrencyFormatter.formatAmountOnly(100.0, eur);
      expect(converted, '92.00');
    });

    test('DZD conversion and integer formatting', () {
      const dzd = Currency(
        code: 'DZD',
        symbol: 'DA',
        nameEn: 'Algerian Dinar',
        nameAr: 'دينار جزائري',
        exchangeRateToUSD: 134.50,
      );

      final converted = AppCurrencyFormatter.formatAmountOnly(100.0, dzd);
      expect(converted, '13,450');
    });
  });
}
