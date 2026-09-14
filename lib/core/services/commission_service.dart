import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommissionConfig {
  final double standardDirectServiceFeeUSD;
  final double standardAffiliateServiceFeeUSD;
  final bool enableAffiliateCommission;
  final double taxRatePercentage; // e.g. 0.05 for 5%

  const CommissionConfig({
    this.standardDirectServiceFeeUSD = 1.00, // 1 USD default
    this.standardAffiliateServiceFeeUSD = 0.0,
    this.enableAffiliateCommission = false,
    this.taxRatePercentage = 0.0,
  });

  CommissionConfig copyWith({
    double? standardDirectServiceFeeUSD,
    double? standardAffiliateServiceFeeUSD,
    bool? enableAffiliateCommission,
    double? taxRatePercentage,
  }) {
    return CommissionConfig(
      standardDirectServiceFeeUSD: standardDirectServiceFeeUSD ?? this.standardDirectServiceFeeUSD,
      standardAffiliateServiceFeeUSD: standardAffiliateServiceFeeUSD ?? this.standardAffiliateServiceFeeUSD,
      enableAffiliateCommission: enableAffiliateCommission ?? this.enableAffiliateCommission,
      taxRatePercentage: taxRatePercentage ?? this.taxRatePercentage,
    );
  }

  factory CommissionConfig.fromMap(Map<String, dynamic> map) {
    return CommissionConfig(
      standardDirectServiceFeeUSD: (map['standardDirectServiceFeeUSD'] as num?)?.toDouble() ?? 1.00,
      standardAffiliateServiceFeeUSD: (map['standardAffiliateServiceFeeUSD'] as num?)?.toDouble() ?? 0.0,
      enableAffiliateCommission: map['enableAffiliateCommission'] as bool? ?? false,
      taxRatePercentage: (map['taxRatePercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'standardDirectServiceFeeUSD': standardDirectServiceFeeUSD,
      'standardAffiliateServiceFeeUSD': standardAffiliateServiceFeeUSD,
      'enableAffiliateCommission': enableAffiliateCommission,
      'taxRatePercentage': taxRatePercentage,
    };
  }
}

class PriceCalculationResult {
  final double basePriceUSD;
  final double taxesUSD;
  final double serviceFeeUSD;
  final double totalAmountUSD;
  final bool isAffiliate;

  const PriceCalculationResult({
    required this.basePriceUSD,
    required this.taxesUSD,
    required this.serviceFeeUSD,
    required this.totalAmountUSD,
    required this.isAffiliate,
  });
}

final commissionServiceProvider = StateNotifierProvider<CommissionService, CommissionConfig>((ref) {
  return CommissionService();
});

class CommissionService extends StateNotifier<CommissionConfig> {
  CommissionService() : super(const CommissionConfig());

  void updateConfig(CommissionConfig newConfig) {
    state = newConfig;
  }

  void updateServiceFeeUSD(double newFeeUSD) {
    state = state.copyWith(standardDirectServiceFeeUSD: newFeeUSD);
  }

  PriceCalculationResult calculatePricing({
    required double basePriceUSD,
    required bool isAffiliate,
    double customTaxRate = 0.0,
  }) {
    final taxRate = customTaxRate > 0 ? customTaxRate : state.taxRatePercentage;
    final taxes = basePriceUSD * taxRate;
    
    double serviceFee = 0.0;
    if (!isAffiliate) {
      // Direct booking: apply configurable service fee ($1 USD default)
      serviceFee = state.standardDirectServiceFeeUSD;
    } else {
      // Affiliate booking: only apply if specifically configured and legally supported
      if (state.enableAffiliateCommission) {
        serviceFee = state.standardAffiliateServiceFeeUSD;
      }
    }

    final total = basePriceUSD + taxes + serviceFee;

    return PriceCalculationResult(
      basePriceUSD: basePriceUSD,
      taxesUSD: taxes,
      serviceFeeUSD: serviceFee,
      totalAmountUSD: total,
      isAffiliate: isAffiliate,
    );
  }
}
