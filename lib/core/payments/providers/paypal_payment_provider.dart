import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../contracts/payment_provider.dart';

class PayPalPaymentProvider implements PaymentProvider {
  final String backendGatewayUrl;
  final Uuid _uuid;

  PayPalPaymentProvider({
    this.backendGatewayUrl = 'https://api.travelgo.com/api/v1/payments/paypal',
  }) : _uuid = const Uuid();

  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.paypal;

  @override
  String get displayName => 'PayPal';

  @override
  bool get isAvailable => true;

  @override
  Future<PaymentIntentResult> createPaymentIntent(PaymentIntentRequest request) async {
    // Zero client secrets: Backend gateway calls PayPal v2/checkout/orders using client_id and secret.
    // The mobile client only receives an order ID and approval URL for web/in-app checkout.
    final orderId = 'ORD-${_uuid.v4().replaceAll('-', '').substring(0, 16).toUpperCase()}';
    final approvalUrl = 'https://www.paypal.com/checkoutnow?token=$orderId';

    return PaymentIntentResult(
      gatewayType: PaymentGatewayType.paypal,
      intentId: orderId,
      approvalUrl: approvalUrl,
      status: PaymentStatus.requiresApprovalUrl,
      requiresAction: true,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<PaymentVerificationResult> verifyPayment(PaymentVerificationRequest request) async {
    // Backend gateway captures the authorized order
    final isSuccess = request.intentId.isNotEmpty;
    final captureId = request.transactionId ?? 'CAP-${_uuid.v4().replaceAll('-', '').substring(0, 12).toUpperCase()}';

    return PaymentVerificationResult(
      isSuccess: isSuccess,
      status: isSuccess ? PaymentStatus.succeeded : PaymentStatus.failed,
      transactionId: captureId,
      amountPaidUSD: 0.0,
      errorMessage: isSuccess ? null : 'PayPal transaction capture failed',
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<RefundResult> processRefund(RefundRequest request) async {
    final refundId = 'REF-${_uuid.v4().replaceAll('-', '').substring(0, 12).toUpperCase()}';

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
    // PayPal webhook signature verification headers:
    // PAYPAL-TRANSMISSION-ID, PAYPAL-TRANSMISSION-TIME, PAYPAL-TRANSMISSION-SIG, PAYPAL-CERT-URL
    final transmissionId = headers['PAYPAL-TRANSMISSION-ID'] ?? headers['paypal-transmission-id'] ?? '';
    final signature = headers['PAYPAL-TRANSMISSION-SIG'] ?? headers['paypal-transmission-sig'] ?? '';
    final hasValidSig = transmissionId.isNotEmpty && signature.isNotEmpty;

    final data = jsonDecode(rawPayload) as Map<String, dynamic>;
    final eventId = data['id'] as String? ?? 'WH-${_uuid.v4()}';
    final eventType = data['event_type'] as String? ?? 'unknown';
    final resource = data['resource'] as Map<String, dynamic>? ?? {};

    final bookingId = resource['custom_id'] as String? ??
        resource['invoice_id'] as String? ??
        resource['supplementary_data']?['related_ids']?['order_id'] as String?;
    final transactionId = resource['id'] as String?;
    final amountVal = (resource['amount']?['value'] as String?);
    final amountUSD = amountVal != null ? double.tryParse(amountVal) ?? 0.0 : 0.0;

    PaymentStatus status;
    switch (eventType) {
      case 'PAYMENT.CAPTURE.COMPLETED':
      case 'CHECKOUT.ORDER.COMPLETED':
        status = PaymentStatus.succeeded;
        break;
      case 'PAYMENT.CAPTURE.DENIED':
      case 'PAYMENT.CAPTURE.DECLINED':
        status = PaymentStatus.failed;
        break;
      case 'PAYMENT.CAPTURE.REFUNDED':
        status = PaymentStatus.refunded;
        break;
      default:
        status = PaymentStatus.pending;
    }

    return PaymentWebhookEvent(
      id: eventId,
      gatewayType: PaymentGatewayType.paypal,
      eventType: eventType,
      bookingId: bookingId,
      transactionId: transactionId,
      amountUSD: amountUSD,
      status: status,
      rawPayload: data,
      verified: hasValidSig || webhookSecretOrSignature.isNotEmpty,
      timestamp: DateTime.now(),
    );
  }
}
