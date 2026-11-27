import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../financial/services/financial_ledger_service.dart';
import '../../services/commission_service.dart';
import '../contracts/payment_provider.dart';
import '../providers/mytpe_payment_provider.dart';
import '../providers/paypal_payment_provider.dart';
import '../providers/sandbox_payment_provider.dart';
import '../providers/stripe_payment_provider.dart';

final paymentGatewayServiceProvider = Provider<PaymentGatewayService>((ref) {
  final ledgerService = ref.watch(financialLedgerServiceProvider.notifier);
  return PaymentGatewayService(ledgerService: ledgerService);
});

class PaymentGatewayService {
  final FinancialLedgerService? _ledgerService;
  final Map<PaymentGatewayType, PaymentProvider> _providers;
  PaymentGatewayType _activeGateway;

  PaymentGatewayService({
    FinancialLedgerService? ledgerService,
    PaymentGatewayType defaultGateway = PaymentGatewayType.stripe,
  })  : _ledgerService = ledgerService,
        _activeGateway = defaultGateway,
        _providers = {
          PaymentGatewayType.stripe: StripePaymentProvider(),
          PaymentGatewayType.paypal: PayPalPaymentProvider(),
          PaymentGatewayType.mytpe: MyTpePaymentProvider(),
          PaymentGatewayType.sandbox: SandboxPaymentProvider(),
        };

  PaymentGatewayType get activeGateway => _activeGateway;

  void setActiveGateway(PaymentGatewayType gateway) {
    if (_providers.containsKey(gateway)) {
      _activeGateway = gateway;
    }
  }

  PaymentProvider getProvider(PaymentGatewayType gateway) {
    final provider = _providers[gateway];
    if (provider == null) {
      throw UnsupportedError('Payment provider not supported for $gateway');
    }
    return provider;
  }

  PaymentProvider get currentProvider => getProvider(_activeGateway);

  /// Initiates payment through active or specified gateway.
  /// Enforces Zero Client Secrets rule.
  Future<PaymentIntentResult> initiatePayment(
    PaymentIntentRequest request, {
    PaymentGatewayType? gateway,
  }) async {
    final provider = getProvider(gateway ?? _activeGateway);
    return await provider.createPaymentIntent(request);
  }

  /// Verifies transaction completion and records in Financial Ledger.
  Future<PaymentVerificationResult> completeAndRecordPayment({
    required PaymentVerificationRequest request,
    required String bookingId,
    required String bookingReference,
    required PriceCalculationResult pricing,
  }) async {
    final provider = getProvider(request.gatewayType);
    final result = await provider.verifyPayment(request);

    if (result.isSuccess) {
      _ledgerService?.recordDirectBooking(
        bookingId: bookingId,
        bookingReference: bookingReference,
        pricing: pricing,
        paymentMethod: request.gatewayType.name,
        paymentTransactionId: result.transactionId,
        metadata: {
          'gateway': request.gatewayType.name,
          'verifiedAt': result.timestamp.toIso8601String(),
        },
      );
    }

    return result;
  }

  /// Processes a cancellation refund and records the adjustment in the Financial Ledger.
  Future<RefundResult> processAndRecordRefund({
    required RefundRequest request,
    required String bookingReference,
    PaymentGatewayType? gateway,
    bool refundPlatformFee = false,
    double cancellationFeePercentage = 0.0,
  }) async {
    final provider = getProvider(gateway ?? _activeGateway);
    final refundResult = await provider.processRefund(request);

    if (refundResult.isSuccess) {
      _ledgerService?.recordCancellationRefund(
        bookingId: request.bookingId,
        bookingReference: bookingReference,
        refundPlatformFee: refundPlatformFee,
        cancellationFeePercentage: cancellationFeePercentage,
        reason: request.reason,
        refundTransactionId: refundResult.refundId,
      );
    }

    return refundResult;
  }

  /// Verifies and handles incoming webhook notification from payment providers
  Future<PaymentWebhookEvent> handleWebhook({
    required PaymentGatewayType gateway,
    required String rawPayload,
    required Map<String, String> headers,
    required String endpointSecret,
  }) async {
    final provider = getProvider(gateway);
    return await provider.verifyAndParseWebhook(
      rawPayload: rawPayload,
      headers: headers,
      webhookSecretOrSignature: endpointSecret,
    );
  }
}
