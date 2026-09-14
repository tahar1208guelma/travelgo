import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/currency.dart';

final currencyProvider = StateNotifierProvider<CurrencyNotifier, Currency>((ref) {
  return CurrencyNotifier();
});

class CurrencyNotifier extends StateNotifier<Currency> {
  static const String _key = 'currency_preference';

  CurrencyNotifier() : super(Currency.defaultCurrency) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_key);
      if (code != null) {
        final found = Currency.supportedCurrencies.firstWhere(
          (c) => c.code == code,
          orElse: () => Currency.defaultCurrency,
        );
        state = found;
      }
    } catch (_) {}
  }

  Future<void> setCurrency(Currency currency) async {
    state = currency;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, currency.code);
    } catch (_) {}
  }

  double convertFromUSD(double amountInUSD) {
    return amountInUSD * state.exchangeRateToUSD;
  }

  double convertToUSD(double amountInCurrentCurrency) {
    return amountInCurrentCurrency / state.exchangeRateToUSD;
  }
}
