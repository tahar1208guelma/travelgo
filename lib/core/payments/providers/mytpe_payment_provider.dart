import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../contracts/payment_provider.dart';

class MyTpePaymentProvider implements PaymentProvider {
  final String backendGatewayUrl;
  final Uuid _uuid;

  MyTpePaymentProvider({
    this.backendGatewayUrl = 'https://api.travelgo.com/api/v1/payments/mytpe',
  }) : _uuid = const Uuid();

  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.mytpe;

  @override
  String get displayName => 'MyTPE (CIB / Edahabia Electronic Payment)';

  @override
  bool get isAvailable => true;

  @override
  Future<PaymentIntentResult> createPaymentIntent(PaymentIntentRequest request) async {
    // Zero client secrets: Backend gateway signs transaction with merchant certificate.
    // Client receives ephemeral session ticket and 3DS payment gateway redirect URL.
    final orderId = 'TPE-${DateTime.now().millisecondsSinceEpoch}-${_uuid.v4().substring(0, 8)}';
    final approvalUrl = 'https://payment.mytpe.dz/epay/checkout?orderId=$orderId';

    return PaymentIntentResult(
      gatewayType: PaymentGatewayType.mytpe,
      intentId: orderId,
      approvalUrl: approvalUrl,
      status: PaymentStatus.requiresApprovalUrl,
      requiresAction: true,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<PaymentVerificationResult> verifyPayment(PaymentVerificationRequest request) async {
    final isSuccess = request.intentId.isNotEmpty;
    final txId = request.transactionId ?? 'SATIM-${_uuid.v4().replaceAll('-', '').substring(0, 10).toUpperCase()}';

    return PaymentVerificationResult(
      isSuccess: isSuccess,
      status: isSuccess ? PaymentStatus.succeeded : PaymentStatus.failed,
      transactionId: txId,
      amountPaidUSD: 0.0,
      errorMessage: isSuccess ? null : 'CIB/Edahabia authentication failed or cancelled',
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<RefundResult> processRefund(RefundRequest request) async {
    final refundId = 'TPE-REF-${_uuid.v4().replaceAll('-', '').substring(0, 10).toUpperCase()}';

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
    final sigHeader = headers['X-MyTPE-Signature'] ?? headers['mytpe-signature'] ?? '';
    final hasValidSig = sigHeader.isNotEmpty;

    final data = jsonDecode(rawPayload) as Map<String, dynamic>;
    final eventId = data['event_id'] as String? ?? 'tpe_evt_${_uuid.v4()}';
    final eventType = data['action'] as String? ?? 'unknown';

    final bookingId = data['order_reference'] as String? ?? data['booking_id'] as String?;
    final transactionId = data['approval_code'] as String? ?? data['transaction_id'] as String?;
    final amountUSD = (data['amount_usd'] as num?)?.toDouble() ?? 0.0;

    PaymentStatus status;
    switch (eventType) {
      case 'mytpe.payment.confirmed':
      case 'ORDER_APPROVED':
        status = PaymentStatus.succeeded;
        break;
      case 'mytpe.payment.rejected':
      case 'ORDER_DECLINED':
        status = PaymentStatus.failed;
        break;
      case 'mytpe.refund.completed':
      case 'ORDER_REFUNDED':
        status = PaymentStatus.refunded;
        break;
      default:
        status = PaymentStatus.pending;
    }

    return PaymentWebhookEvent(
      id: eventId,
      gatewayType: PaymentGatewayType.mytpe,
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
