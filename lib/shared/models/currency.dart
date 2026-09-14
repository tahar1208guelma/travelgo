class Currency {
  final String code;
  final String symbol;
  final String nameEn;
  final String nameAr;
  final double exchangeRateToUSD; // 1 USD = X Currency

  const Currency({
    required this.code,
    required this.symbol,
    required this.nameEn,
    required this.nameAr,
    required this.exchangeRateToUSD,
  });

  String getName({bool isArabic = false}) => isArabic ? nameAr : nameEn;

  static const List<Currency> supportedCurrencies = [
    Currency(
      code: 'USD',
      symbol: '\$',
      nameEn: 'US Dollar',
      nameAr: 'دولار أمريكي',
      exchangeRateToUSD: 1.0,
    ),
    Currency(
      code: 'EUR',
      symbol: '€',
      nameEn: 'Euro',
      nameAr: 'يورو',
      exchangeRateToUSD: 0.92,
    ),
    Currency(
      code: 'DZD',
      symbol: 'DA',
      nameEn: 'Algerian Dinar',
      nameAr: 'دينار جزائري',
      exchangeRateToUSD: 134.50,
    ),
    Currency(
      code: 'SAR',
      symbol: 'SAR',
      nameEn: 'Saudi Riyal',
      nameAr: 'ريال سعودي',
      exchangeRateToUSD: 3.75,
    ),
    Currency(
      code: 'TRY',
      symbol: '₺',
      nameEn: 'Turkish Lira',
      nameAr: 'ليرة تركية',
      exchangeRateToUSD: 33.20,
    ),
    Currency(
      code: 'GBP',
      symbol: '£',
      nameEn: 'British Pound',
      nameAr: 'جنيه إسترليني',
      exchangeRateToUSD: 0.78,
    ),
  ];

  static Currency get defaultCurrency => supportedCurrencies[0]; // USD
}
