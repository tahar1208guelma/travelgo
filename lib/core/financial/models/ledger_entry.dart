enum LedgerEntryType {
  bookingCredit,          // Initial customer payment (+GBV, +provider payout payable, +platform revenue)
  cancellationDebit,      // Full cancellation refund (-GBV, -provider payout, -platform revenue/adjusted)
  refundAdjustment,       // Partial or penalty-based refund adjustment
  providerPayoutSettled,  // Payout disbursed to provider
  feeRetained,            // Non-refundable fee retained on cancellation
  chargebackDebit,        // Disputed or chargeback payment
  affiliateCommission,    // Affiliate lead generation commission
}

enum LedgerEntryStatus {
  pending,
  cleared,
  reconciled,
  adjusted,
  refunded,
}

class LedgerEntry {
  final String id;
  final String bookingId;
  final String bookingReference;
  final DateTime timestamp;
  final LedgerEntryType type;
  final double grossBookingValueUSD;
  final double basePriceUSD;
  final double taxesUSD;
  final double platformFeeUSD;
  final double providerPayoutUSD;
  final String currency;
  final String paymentMethod;
  final String? paymentTransactionId;
  final LedgerEntryStatus status;
  final Map<String, dynamic> metadata;
  final String? notes;

  const LedgerEntry({
    required this.id,
    required this.bookingId,
    required this.bookingReference,
    required this.timestamp,
    required this.type,
    required this.grossBookingValueUSD,
    required this.basePriceUSD,
    required this.taxesUSD,
    required this.platformFeeUSD,
    required this.providerPayoutUSD,
    this.currency = 'USD',
    required this.paymentMethod,
    this.paymentTransactionId,
    this.status = LedgerEntryStatus.cleared,
    this.metadata = const {},
    this.notes,
  });

  bool get isCredit => grossBookingValueUSD >= 0;
  bool get isDebit => grossBookingValueUSD < 0;

  LedgerEntry copyWith({
    String? id,
    String? bookingId,
    String? bookingReference,
    DateTime? timestamp,
    LedgerEntryType? type,
    double? grossBookingValueUSD,
    double? basePriceUSD,
    double? taxesUSD,
    double? platformFeeUSD,
    double? providerPayoutUSD,
    String? currency,
    String? paymentMethod,
    String? paymentTransactionId,
    LedgerEntryStatus? status,
    Map<String, dynamic>? metadata,
    String? notes,
  }) {
    return LedgerEntry(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      bookingReference: bookingReference ?? this.bookingReference,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      grossBookingValueUSD: grossBookingValueUSD ?? this.grossBookingValueUSD,
      basePriceUSD: basePriceUSD ?? this.basePriceUSD,
      taxesUSD: taxesUSD ?? this.taxesUSD,
      platformFeeUSD: platformFeeUSD ?? this.platformFeeUSD,
      providerPayoutUSD: providerPayoutUSD ?? this.providerPayoutUSD,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      notes: notes ?? this.notes,
    );
  }

  factory LedgerEntry.fromMap(Map<String, dynamic> map) {
    return LedgerEntry(
      id: map['id'] as String,
      bookingId: map['bookingId'] as String,
      bookingReference: map['bookingReference'] as String? ?? '',
      timestamp: DateTime.parse(map['timestamp'] as String),
      type: LedgerEntryType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => LedgerEntryType.bookingCredit,
      ),
      grossBookingValueUSD: (map['grossBookingValueUSD'] as num).toDouble(),
      basePriceUSD: (map['basePriceUSD'] as num).toDouble(),
      taxesUSD: (map['taxesUSD'] as num).toDouble(),
      platformFeeUSD: (map['platformFeeUSD'] as num).toDouble(),
      providerPayoutUSD: (map['providerPayoutUSD'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'USD',
      paymentMethod: map['paymentMethod'] as String? ?? 'card',
      paymentTransactionId: map['paymentTransactionId'] as String?,
      status: LedgerEntryStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => LedgerEntryStatus.cleared,
      ),
      metadata: (map['metadata'] as Map<String, dynamic>?) ?? const {},
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'bookingReference': bookingReference,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'grossBookingValueUSD': grossBookingValueUSD,
      'basePriceUSD': basePriceUSD,
      'taxesUSD': taxesUSD,
      'platformFeeUSD': platformFeeUSD,
      'providerPayoutUSD': providerPayoutUSD,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'paymentTransactionId': paymentTransactionId,
      'status': status.name,
      'metadata': metadata,
      'notes': notes,
    };
  }
}
