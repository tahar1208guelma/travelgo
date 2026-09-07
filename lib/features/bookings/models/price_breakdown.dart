class PriceBreakdown {
  final double basePrice;
  final double? serviceFee;
  final double? taxesAndFees;
  final double? discount;
  final String currency;
  final double totalAmount;

  const PriceBreakdown({
    required this.basePrice,
    this.serviceFee,
    this.taxesAndFees,
    this.discount,
    required this.currency,
    required this.totalAmount,
  });

  bool get hasServiceFee => serviceFee != null && serviceFee! > 0;
  bool get hasTaxesAndFees => taxesAndFees != null && taxesAndFees! > 0;
  bool get hasDiscount => discount != null && discount! > 0;

  Map<String, dynamic> toMap() {
    return {
      'basePrice': basePrice,
      'serviceFee': serviceFee,
      'taxesAndFees': taxesAndFees,
      'discount': discount,
      'currency': currency,
      'totalAmount': totalAmount,
    };
  }

  factory PriceBreakdown.fromMap(Map<String, dynamic> map) {
    return PriceBreakdown(
      basePrice: (map['basePrice'] as num).toDouble(),
      serviceFee: (map['serviceFee'] as num?)?.toDouble(),
      taxesAndFees: (map['taxesAndFees'] as num?)?.toDouble(),
      discount: (map['discount'] as num?)?.toDouble(),
      currency: map['currency'] as String? ?? 'USD',
      totalAmount: (map['totalAmount'] as num).toDouble(),
    );
  }
  /// Constant representing TRAVELGO 0.75% platform service fee rate
  static const double travelGoFeeRate = 0.0075;

  /// Calculates a strict PriceBreakdown applying the 0.75% TRAVELGO service fee
  factory PriceBreakdown.calculateWithTravelGoFee({
    required double basePrice,
    double taxesAndFees = 0.0,
    double discount = 0.0,
    String currency = 'USD',
  }) {
    // 0.75% fee rounded to 2 decimal places
    final fee = double.parse((basePrice * travelGoFeeRate).toStringAsFixed(2));
    final total = double.parse((basePrice + taxesAndFees + fee - discount).toStringAsFixed(2));

    return PriceBreakdown(
      basePrice: basePrice,
      serviceFee: fee,
      taxesAndFees: taxesAndFees > 0 ? taxesAndFees : null,
      discount: discount > 0 ? discount : null,
      currency: currency,
      totalAmount: total,
    );
  }
}
