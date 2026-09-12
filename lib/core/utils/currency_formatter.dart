import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String currency = 'USD'}) {
    final numberFormat = NumberFormat('#,##0.00', 'en_US');
    final formattedNumber = numberFormat.format(amount);
    
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$$formattedNumber';
      case 'EUR':
        return 'EUR $formattedNumber';
      case 'GBP':
        return 'GBP $formattedNumber';
      case 'DZD':
        return '$formattedNumber DZD';
      default:
        return '$currency $formattedNumber';
    }
  }
}
