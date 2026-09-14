class PriceBreakdown {
  final double basePrice;
  final double serviceFee;
  final double taxes;
  final double discount;
  final double totalAmount;
  final String currency;
  final bool isServiceFeeLegallySupported;

  const PriceBreakdown({
    required this.basePrice,
    this.serviceFee = 1.00,
    this.taxes = 0.0,
    this.discount = 0.0,
    required this.totalAmount,
    this.currency = 'USD',
    this.isServiceFeeLegallySupported = true,
  });

  PriceBreakdown copyWith({
    double? basePrice,
    double? serviceFee,
    double? taxes,
    double? discount,
    double? totalAmount,
    String? currency,
    bool? isServiceFeeLegallySupported,
  }) {
    return PriceBreakdown(
      basePrice: basePrice ?? this.basePrice,
      serviceFee: serviceFee ?? this.serviceFee,
      taxes: taxes ?? this.taxes,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      isServiceFeeLegallySupported: isServiceFeeLegallySupported ?? this.isServiceFeeLegallySupported,
    );
  }

  factory PriceBreakdown.fromJson(Map<String, dynamic> json) {
    return PriceBreakdown(
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      serviceFee: (json['serviceFee'] as num?)?.toDouble() ?? 0.0,
      taxes: (json['taxes'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      isServiceFeeLegallySupported: json['isServiceFeeLegallySupported'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basePrice': basePrice,
      'serviceFee': serviceFee,
      'taxes': taxes,
      'discount': discount,
      'totalAmount': totalAmount,
      'currency': currency,
      'isServiceFeeLegallySupported': isServiceFeeLegallySupported,
    };
  }
}
