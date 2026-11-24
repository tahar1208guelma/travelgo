enum PaymentGatewayType {
  stripe,
  paypal,
  mytpe,   // CIB & Edahabia regional payment gateway
  sandbox,
}

enum PaymentStatus {
  pending,
  requiresAction,
  requiresApprovalUrl,
  processing,
  succeeded,
  failed,
  refunded,
}

class PaymentIntentRequest {
  final String bookingId;
  final String bookingReference;
  final double amountUSD;
  final String currency;
  final String customerEmail;
  final String customerName;
  final Map<String, dynamic> metadata;

  const PaymentIntentRequest({
    required this.bookingId,
    required this.bookingReference,
    required this.amountUSD,
    this.currency = 'USD',
    required this.customerEmail,
    required this.customerName,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'bookingReference': bookingReference,
      'amountUSD': amountUSD,
      'currency': currency,
      'customerEmail': customerEmail,
      'customerName': customerName,
      'metadata': metadata,
    };
  }
}

class PaymentIntentResult {
  final PaymentGatewayType gatewayType;
  final String intentId;
  final String? clientSecret; // Ephemeral client-only token from backend; NEVER a private key
  final String? approvalUrl;  // External checkout/redirect URL (e.g. PayPal or MyTPE 3DS)
  final PaymentStatus status;
  final bool requiresAction;
  final DateTime createdAt;

  const PaymentIntentResult({
    required this.gatewayType,
    required this.intentId,
    this.clientSecret,
    this.approvalUrl,
    required this.status,
    this.requiresAction = false,
    required this.createdAt,
  });
}

class PaymentVerificationRequest {
  final PaymentGatewayType gatewayType;
  final String intentId;
  final String? transactionId;
  final String? tokenOrSignature;

  const PaymentVerificationRequest({
    required this.gatewayType,
    required this.intentId,
    this.transactionId,
    this.tokenOrSignature,
  });
}

class PaymentVerificationResult {
  final bool isSuccess;
  final PaymentStatus status;
  final String transactionId;
  final double amountPaidUSD;
  final String currency;
  final String? errorMessage;
  final DateTime timestamp;

  const PaymentVerificationResult({
    required this.isSuccess,
    required this.status,
    required this.transactionId,
    required this.amountPaidUSD,
    this.currency = 'USD',
    this.errorMessage,
    required this.timestamp,
  });
}

class RefundRequest {
  final String bookingId;
  final String transactionId;
  final double refundAmountUSD;
  final String currency;
  final String reason;

  const RefundRequest({
    required this.bookingId,
    required this.transactionId,
    required this.refundAmountUSD,
    this.currency = 'USD',
    this.reason = 'Customer requested cancellation',
  });
}

class RefundResult {
  final bool isSuccess;
  final String refundId;
  final double refundedAmountUSD;
  final String? errorMessage;
  final DateTime timestamp;

  const RefundResult({
    required this.isSuccess,
    required this.refundId,
    required this.refundedAmountUSD,
    this.errorMessage,
    required this.timestamp,
  });
}

class PaymentWebhookEvent {
  final String id;
  final PaymentGatewayType gatewayType;
  final String eventType;
  final String? bookingId;
  final String? transactionId;
  final double? amountUSD;
  final PaymentStatus status;
  final Map<String, dynamic> rawPayload;
  final bool verified;
  final DateTime timestamp;

  const PaymentWebhookEvent({
    required this.id,
    required this.gatewayType,
    required this.eventType,
    this.bookingId,
    this.transactionId,
    this.amountUSD,
    required this.status,
    required this.rawPayload,
    required this.verified,
    required this.timestamp,
  });
}

abstract class PaymentProvider {
  PaymentGatewayType get gatewayType;
  String get displayName;
  bool get isAvailable;

  /// Step 1: Request payment intent from backend API gateway.
  /// ZERO CLIENT SECRETS: The client NEVER stores secret keys. All intents are created
  /// server-side, returning only an ephemeral client_secret or approval redirect URL.
  Future<PaymentIntentResult> createPaymentIntent(PaymentIntentRequest request);

  /// Step 2: Confirm or verify payment completion with backend / gateway.
  Future<PaymentVerificationResult> verifyPayment(PaymentVerificationRequest request);

  /// Step 3: Process a refund via backend API gateway.
  Future<RefundResult> processRefund(RefundRequest request);

  /// Step 4: Webhook verification and payload parser schema.
  Future<PaymentWebhookEvent> verifyAndParseWebhook({
    required String rawPayload,
    required Map<String, String> headers,
    required String webhookSecretOrSignature,
  });
}
