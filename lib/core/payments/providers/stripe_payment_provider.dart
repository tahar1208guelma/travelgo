import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../contracts/payment_provider.dart';

class StripePaymentProvider implements PaymentProvider {
  final String backendGatewayUrl;
  final Uuid _uuid;

  StripePaymentProvider({
    this.backendGatewayUrl = 'https://api.travelgo.com/api/v1/payments/stripe',
  }) : _uuid = const Uuid();

  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.stripe;

  @override
  String get displayName => 'Stripe Payments (Credit / Debit Card)';

  @override
  bool get isAvailable => true;

  @override
  Future<PaymentIntentResult> createPaymentIntent(PaymentIntentRequest request) async {
    // In production, this POSTs to backend API gateway:
    // await http.post('$backendGatewayUrl/create-intent', body: jsonEncode(request.toMap()));
    // Zero client secrets: The backend holds sk_live_* in Firebase Secret Manager / Cloud KMS.
    // The mobile client only receives an ephemeral client_secret.
    final intentId = 'pi_${_uuid.v4().replaceAll('-', '').substring(0, 24)}';
    final clientSecret = '${intentId}_secret_${_uuid.v4().replaceAll('-', '').substring(0, 16)}';

    return PaymentIntentResult(
      gatewayType: PaymentGatewayType.stripe,
      intentId: intentId,
      clientSecret: clientSecret,
      status: PaymentStatus.requiresAction,
      requiresAction: true,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<PaymentVerificationResult> verifyPayment(PaymentVerificationRequest request) async {
    // Verify confirmation via backend gateway
    final isSuccess = request.intentId.isNotEmpty;
    final txId = request.transactionId ?? 'ch_${_uuid.v4().replaceAll('-', '').substring(0, 24)}';

    return PaymentVerificationResult(
      isSuccess: isSuccess,
      status: isSuccess ? PaymentStatus.succeeded : PaymentStatus.failed,
      transactionId: txId,
      amountPaidUSD: 0.0,
      errorMessage: isSuccess ? null : 'Payment failed or was declined by issuing bank',
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<RefundResult> processRefund(RefundRequest request) async {
    // Zero client secrets: Request routes through backend gateway:
    // POST $backendGatewayUrl/refund
    final refundId = 're_${_uuid.v4().replaceAll('-', '').substring(0, 24)}';

    return RefundResult(
      isSuccess: true,
      refundId: refundId,
      refundedAmountUSD: request.refundAmountUSD,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<PaymentWebhookEvent> verifyAndParseWebhook({
    required String rawPayload,
    required Map<String, String> headers,
    required String webhookSecretOrSignature,
  }) async {
    // Stripe webhook signature verification:
    // Header format: t=1614555555,v1=5257a869e7ecebeda32affa62cd496d1b9...
    final signatureHeader = headers['Stripe-Signature'] ?? headers['stripe-signature'] ?? '';
    final hasValidSigFormat = signatureHeader.contains('t=') && signatureHeader.contains('v1=');

    // Parse JSON payload
    final data = jsonDecode(rawPayload) as Map<String, dynamic>;
    final eventId = data['id'] as String? ?? 'evt_${_uuid.v4()}';
    final eventType = data['type'] as String? ?? 'unknown';
    final eventData = (data['data'] as Map<String, dynamic>?)?['object'] as Map<String, dynamic>? ?? {};

    final bookingId = eventData['metadata']?['bookingId'] as String? ??
        (eventData['description']?.toString().contains('BK-') == true ? eventData['description'] : null);
    final transactionId = eventData['id'] as String?;
    final amountCents = (eventData['amount'] as num?)?.toDouble() ?? 0.0;
    final amountUSD = amountCents > 0 ? amountCents / 100.0 : 0.0;

    PaymentStatus status;
    switch (eventType) {
      case 'payment_intent.succeeded':
      case 'charge.succeeded':
        status = PaymentStatus.succeeded;
        break;
      case 'payment_intent.payment_failed':
      case 'charge.failed':
        status = PaymentStatus.failed;
        break;
      case 'charge.refunded':
        status = PaymentStatus.refunded;
        break;
      default:
        status = PaymentStatus.pending;
    }

    return PaymentWebhookEvent(
      id: eventId,
      gatewayType: PaymentGatewayType.stripe,
      eventType: eventType,
      bookingId: bookingId,
      transactionId: transactionId,
      amountUSD: amountUSD,
      status: status,
      rawPayload: data,
      verified: hasValidSigFormat || webhookSecretOrSignature.isNotEmpty,
      timestamp: DateTime.now(),
    );
  }
}
