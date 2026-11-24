import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CommissionModel {
  fixedPlatformFee, // Standard $1.00 USD platform fee
  percentage,       // Percentage fee (e.g. 0.75% standard or partner tier rate)
  hybrid,           // $1.00 USD platform fee + percentage commission
}

enum PartnerTier {
  standardGds,      // 0.75% standard platform commission
  hotelDirect,      // 12.0% hotel partner direct portal commission
  tourOperator,     // 10.0% tour operator rate
  custom,           // Custom negotiated partner rate
}

class CommissionConfig {
  final double standardDirectServiceFeeUSD;
  final double standardAffiliateServiceFeeUSD;
  final bool enableAffiliateCommission;
  final double taxRatePercentage; // e.g. 0.05 for 5%
  final double percentageCommissionRate; // e.g. 0.0075 (0.75% standard)
  final CommissionModel model;
  final Map<String, double> partnerRates;

  const CommissionConfig({
    this.standardDirectServiceFeeUSD = 1.00, // $1.00 USD default
    this.standardAffiliateServiceFeeUSD = 0.0, // $0.00 transparent affiliate markup
    this.enableAffiliateCommission = false,
    this.taxRatePercentage = 0.0,
    this.percentageCommissionRate = 0.0075, // 0.75% default platform commission
    this.model = CommissionModel.fixedPlatformFee,
    this.partnerRates = const {
      'standard_gds': 0.0075, // 0.75%
      'hotel_direct': 0.12,   // 12%
      'tour_operator': 0.10,  // 10%
    },
  });

  CommissionConfig copyWith({
    double? standardDirectServiceFeeUSD,
    double? standardAffiliateServiceFeeUSD,
    bool? enableAffiliateCommission,
    double? taxRatePercentage,
    double? percentageCommissionRate,
    CommissionModel? model,
    Map<String, double>? partnerRates,
  }) {
    return CommissionConfig(
      standardDirectServiceFeeUSD: standardDirectServiceFeeUSD ?? this.standardDirectServiceFeeUSD,
      standardAffiliateServiceFeeUSD: standardAffiliateServiceFeeUSD ?? this.standardAffiliateServiceFeeUSD,
      enableAffiliateCommission: enableAffiliateCommission ?? this.enableAffiliateCommission,
      taxRatePercentage: taxRatePercentage ?? this.taxRatePercentage,
      percentageCommissionRate: percentageCommissionRate ?? this.percentageCommissionRate,
      model: model ?? this.model,
      partnerRates: partnerRates ?? this.partnerRates,
    );
  }

  factory CommissionConfig.fromMap(Map<String, dynamic> map) {
    return CommissionConfig(
      standardDirectServiceFeeUSD: (map['standardDirectServiceFeeUSD'] as num?)?.toDouble() ?? 1.00,
      standardAffiliateServiceFeeUSD: (map['standardAffiliateServiceFeeUSD'] as num?)?.toDouble() ?? 0.0,
      enableAffiliateCommission: map['enableAffiliateCommission'] as bool? ?? false,
      taxRatePercentage: (map['taxRatePercentage'] as num?)?.toDouble() ?? 0.0,
      percentageCommissionRate: (map['percentageCommissionRate'] as num?)?.toDouble() ?? 0.0075,
      model: CommissionModel.values.firstWhere(
        (m) => m.name == map['model'],
        orElse: () => CommissionModel.fixedPlatformFee,
      ),
      partnerRates: (map['partnerRates'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          const {
            'standard_gds': 0.0075,
            'hotel_direct': 0.12,
            'tour_operator': 0.10,
          },
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'standardDirectServiceFeeUSD': standardDirectServiceFeeUSD,
      'standardAffiliateServiceFeeUSD': standardAffiliateServiceFeeUSD,
      'enableAffiliateCommission': enableAffiliateCommission,
      'taxRatePercentage': taxRatePercentage,
      'percentageCommissionRate': percentageCommissionRate,
      'model': model.name,
      'partnerRates': partnerRates,
    };
  }

  double getRateForPartnerTier(PartnerTier tier) {
    switch (tier) {
      case PartnerTier.standardGds:
        return partnerRates['standard_gds'] ?? 0.0075;
      case PartnerTier.hotelDirect:
        return partnerRates['hotel_direct'] ?? 0.12;
      case PartnerTier.tourOperator:
        return partnerRates['tour_operator'] ?? 0.10;
      case PartnerTier.custom:
        return percentageCommissionRate;
    }
  }
}

class PriceCalculationResult {
  final double basePriceUSD;
  final double taxesUSD;
  final double serviceFeeUSD;
  final double platformCommissionUSD;
  final double totalAmountUSD; // Gross Booking Value (GBV)
  final double partnerPayoutUSD; // Provider payout
  final double netPlatformRevenueUSD; // TravelGo Net Platform Revenue
  final bool isAffiliate;
  final String currency;

  const PriceCalculationResult({
    required this.basePriceUSD,
    required this.taxesUSD,
    required this.serviceFeeUSD,
    this.platformCommissionUSD = 0.0,
    required this.totalAmountUSD,
    this.partnerPayoutUSD = 0.0,
    double? netPlatformRevenueUSD,
    required this.isAffiliate,
    this.currency = 'USD',
  }) : netPlatformRevenueUSD = netPlatformRevenueUSD ?? platformCommissionUSD;

  // Explicit aliases for financial domain precision
  double get grossBookingValueUSD => totalAmountUSD;
  double get providerPayoutUSD => partnerPayoutUSD;

  Map<String, dynamic> toMap() {
    return {
      'basePriceUSD': basePriceUSD,
      'taxesUSD': taxesUSD,
      'serviceFeeUSD': serviceFeeUSD,
      'platformCommissionUSD': platformCommissionUSD,
      'totalAmountUSD': totalAmountUSD,
      'grossBookingValueUSD': totalAmountUSD,
      'partnerPayoutUSD': partnerPayoutUSD,
      'providerPayoutUSD': partnerPayoutUSD,
      'netPlatformRevenueUSD': netPlatformRevenueUSD,
      'isAffiliate': isAffiliate,
      'currency': currency,
    };
  }
}

class RefundCalculationResult {
  final double originalTotalUSD;
  final double refundedGrossUSD;
  final double providerPayoutDeductionUSD;
  final double platformFeeRetainedUSD;
  final double platformFeeRefundedUSD;
  final double netCustomerRefundUSD;

  const RefundCalculationResult({
    required this.originalTotalUSD,
    required this.refundedGrossUSD,
    required this.providerPayoutDeductionUSD,
    required this.platformFeeRetainedUSD,
    required this.platformFeeRefundedUSD,
    required this.netCustomerRefundUSD,
  });
}

final commissionServiceProvider = StateNotifierProvider<CommissionService, CommissionConfig>((ref) {
  return CommissionService();
});

class CommissionService extends StateNotifier<CommissionConfig> {
  CommissionService([CommissionConfig initialConfig = const CommissionConfig()]) : super(initialConfig);

  void updateConfig(CommissionConfig newConfig) {
    state = newConfig;
  }

  void updateServiceFeeUSD(double newFeeUSD) {
    state = state.copyWith(standardDirectServiceFeeUSD: newFeeUSD);
  }

  void updateCommissionPercentage(double rate) {
    state = state.copyWith(percentageCommissionRate: rate);
  }

  void updateCommissionModel(CommissionModel model) {
    state = state.copyWith(model: model);
  }

  void setPartnerRate(String partnerKey, double rate) {
    final updated = Map<String, double>.from(state.partnerRates);
    updated[partnerKey] = rate;
    state = state.copyWith(partnerRates: updated);
  }

  /// Deterministic price and commission deduction calculation
  /// Conforms strictly to AGENTS.md financial rules.
  PriceCalculationResult calculatePricing({
    required double basePriceUSD,
    required bool isAffiliate,
    double customTaxRate = 0.0,
    double? customCommissionRate,
    CommissionModel? modelOverride,
    String currency = 'USD',
  }) {
    final activeModel = modelOverride ?? state.model;
    final taxRate = customTaxRate > 0 ? customTaxRate : state.taxRatePercentage;
    final taxes = ((basePriceUSD * taxRate) * 100).round() / 100.0;

    double serviceFee = 0.0;
    double platformCommission = 0.0;
    double partnerPayout = 0.0;

    if (!isAffiliate) {
      final rate = customCommissionRate ?? state.percentageCommissionRate;
      switch (activeModel) {
        case CommissionModel.fixedPlatformFee:
          // Direct Standard: Base Fare + Taxes + Standard Platform Fee ($1.00 USD default)
          serviceFee = state.standardDirectServiceFeeUSD;
          platformCommission = serviceFee;
          // Provider receives full base price; fee is kept by TravelGo
          partnerPayout = ((basePriceUSD) * 100).round() / 100.0;
          break;

        case CommissionModel.percentage:
          // Formula: Platform Commission = Base Fare * percentageCommissionRate (0.75% default or partner rate)
          platformCommission = ((basePriceUSD * rate) * 100).round() / 100.0;
          serviceFee = platformCommission;
          // Provider net payout after deducting app commission
          partnerPayout = ((basePriceUSD - platformCommission) * 100).round() / 100.0;
          break;

        case CommissionModel.hybrid:
          final perc = ((basePriceUSD * rate) * 100).round() / 100.0;
          serviceFee = ((state.standardDirectServiceFeeUSD + perc) * 100).round() / 100.0;
          platformCommission = serviceFee;
          partnerPayout = ((basePriceUSD) * 100).round() / 100.0;
          break;
      }
    } else {
      // Affiliate Redirection: Transparent markup $0.00 by default per AGENTS.md Section 12.2
      if (state.enableAffiliateCommission) {
        serviceFee = state.standardAffiliateServiceFeeUSD;
        platformCommission = serviceFee;
      } else {
        serviceFee = 0.0;
        platformCommission = 0.0;
      }
      partnerPayout = ((basePriceUSD) * 100).round() / 100.0;
    }

    final total = ((basePriceUSD + taxes + serviceFee) * 100).round() / 100.0;

    return PriceCalculationResult(
      basePriceUSD: ((basePriceUSD) * 100).round() / 100.0,
      taxesUSD: taxes,
      serviceFeeUSD: serviceFee,
      platformCommissionUSD: platformCommission,
      totalAmountUSD: total,
      partnerPayoutUSD: partnerPayout,
      netPlatformRevenueUSD: platformCommission,
      isAffiliate: isAffiliate,
      currency: currency,
    );
  }

  /// Calculates cancellation and refund adjustments deterministically
  RefundCalculationResult calculateCancellationRefund({
    required double grossTotalUSD,
    required double basePriceUSD,
    required double taxesUSD,
    required double platformFeeUSD,
    required double providerPayoutUSD,
    bool refundPlatformFee = false,
    double cancellationFeePercentage = 0.0, // e.g. 0.10 for 10% cancellation penalty
  }) {
    final penalty = ((basePriceUSD * cancellationFeePercentage) * 100).round() / 100.0;
    final refundableBase = ((basePriceUSD - penalty) * 100).round() / 100.0;
    
    final platformFeeRefunded = refundPlatformFee ? platformFeeUSD : 0.0;
    final platformFeeRetained = refundPlatformFee ? 0.0 : platformFeeUSD;

    final netCustomerRefund = ((refundableBase + taxesUSD + platformFeeRefunded) * 100).round() / 100.0;
    final providerDeduction = ((refundableBase) * 100).round() / 100.0;

    return RefundCalculationResult(
      originalTotalUSD: grossTotalUSD,
      refundedGrossUSD: netCustomerRefund,
      providerPayoutDeductionUSD: providerDeduction,
      platformFeeRetainedUSD: platformFeeRetained,
      platformFeeRefundedUSD: platformFeeRefunded,
      netCustomerRefundUSD: netCustomerRefund,
    );
  }

  /// Computes partner net payout after deducting app commission
  double calculatePartnerPayout({
    required double grossAmountUSD,
    double commissionRate = 0.10, // 10% partner commission default
  }) {
    final commission = grossAmountUSD * commissionRate;
    return ((grossAmountUSD - commission) * 100).round() / 100.0;
  }
}
