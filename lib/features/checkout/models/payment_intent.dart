enum PaymentIntentStatus {
  requiresPaymentMethod,
  requiresAction, // 3-D Secure Challenge required
  processing,
  succeeded,
  cancelled,
  failed,
}

/// Represents a secure Payment Intent managed between client and backend
class PaymentIntent {
  final String id;
  final String clientSecret;
  final double amount;
  final String currency;
  final PaymentIntentStatus status;
  final String? nextActionUrl; // URL for 3-D Secure modal / redirect
  final String? failureMessage;

  const PaymentIntent({
    required this.id,
    required this.clientSecret,
    required this.amount,
    required this.currency,
    required this.status,
    this.nextActionUrl,
    this.failureMessage,
  });

  bool get requires3DSChallenge => status == PaymentIntentStatus.requiresAction;
  bool get isSuccessful => status == PaymentIntentStatus.succeeded;

  PaymentIntent copyWith({
    PaymentIntentStatus? status,
    String? nextActionUrl,
    String? failureMessage,
  }) {
    return PaymentIntent(
      id: id,
      clientSecret: clientSecret,
      amount: amount,
      currency: currency,
      status: status ?? this.status,
      nextActionUrl: nextActionUrl ?? this.nextActionUrl,
      failureMessage: failureMessage ?? this.failureMessage,
    );
  }
}
