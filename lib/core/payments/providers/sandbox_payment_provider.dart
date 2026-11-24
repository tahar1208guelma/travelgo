import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../contracts/payment_provider.dart';

class SandboxPaymentProvider implements PaymentProvider {
  final Uuid _uuid;
  bool shouldSimulateFailure;

  SandboxPaymentProvider({
    this.shouldSimulateFailure = false,
  }) : _uuid = const Uuid();

  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.sandbox;

  @override
  String get displayName => 'Sandbox Simulator (Local Test Gateway)';

  @override
  bool get isAvailable => true;

  @override
  Future<PaymentIntentResult> createPaymentIntent(PaymentIntentRequest request) async {
    final intentId = 'sandbox_pi_${_uuid.v4().substring(0, 8)}';
    return PaymentIntentResult(
      gatewayType: PaymentGatewayType.sandbox,
      intentId: intentId,
      clientSecret: '${intentId}_secret_test',
      status: shouldSimulateFailure ? PaymentStatus.failed : PaymentStatus.requiresAction,
      requiresAction: !shouldSimulateFailure,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<PaymentVerificationResult> verifyPayment(PaymentVerificationRequest request) async {
    if (shouldSimulateFailure) {
      return PaymentVerificationResult(
        isSuccess: false,
        status: PaymentStatus.failed,
        transactionId: 'sandbox_failed_tx',
        amountPaidUSD: 0.0,
        errorMessage: 'Simulated sandbox test failure',
        timestamp: DateTime.now(),
      );
    }

    final txId = request.transactionId ?? 'sandbox_tx_${_uuid.v4().substring(0, 12)}';
    return PaymentVerificationResult(
      isSuccess: true,
      status: PaymentStatus.succeeded,
      transactionId: txId,
      amountPaidUSD: 0.0,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<RefundResult> processRefund(RefundRequest request) async {
    final refundId = 'sandbox_ref_${_uuid.v4().substring(0, 12)}';
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
    final data = jsonDecode(rawPayload) as Map<String, dynamic>;
    final eventId = data['id'] as String? ?? 'sandbox_evt_${_uuid.v4()}';
    final eventType = data['type'] as String? ?? 'sandbox.payment.succeeded';
    final bookingId = data['bookingId'] as String?;
    final amountUSD = (data['amountUSD'] as num?)?.toDouble() ?? 0.0;

    return PaymentWebhookEvent(
      id: eventId,
      gatewayType: PaymentGatewayType.sandbox,
      eventType: eventType,
      bookingId: bookingId,
      transactionId: 'sandbox_tx_123',
      amountUSD: amountUSD,
      status: PaymentStatus.succeeded,
      rawPayload: data,
      verified: true,
      timestamp: DateTime.now(),
    );
  }
}
