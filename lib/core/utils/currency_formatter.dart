import 'package:intl/intl.dart';
import '../../shared/models/currency.dart';

class AppCurrencyFormatter {
  AppCurrencyFormatter._();

  static String format(double amount, Currency currency, {String locale = 'en'}) {
    final convertedAmount = amount * currency.exchangeRateToUSD;
    final format = NumberFormat.currency(
      locale: locale,
      symbol: '${currency.symbol} ',
      decimalDigits: currency.code == 'DZD' ? 0 : 2,
    );
    return format.format(convertedAmount);
  }

  static String formatAmountOnly(double amount, Currency currency, {String locale = 'en'}) {
    final convertedAmount = amount * currency.exchangeRateToUSD;
    final format = NumberFormat.decimalPattern(locale);
    if (currency.code == 'DZD') {
      return format.format(convertedAmount.round());
    }
    return convertedAmount.toStringAsFixed(2);
  }
}
