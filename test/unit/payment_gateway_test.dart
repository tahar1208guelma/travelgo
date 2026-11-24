import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/financial/financial.dart';
import 'package:travelgo/core/payments/payments.dart';
import 'package:travelgo/core/services/commission_service.dart';

void main() {
  group('Payment Provider Abstraction Tests', () {
    late FinancialLedgerService ledger;
    late PaymentGatewayService paymentGateway;
    late CommissionService commissionService;

    setUp(() {
      ledger = FinancialLedgerService();
      paymentGateway = PaymentGatewayService(ledgerService: ledger);
      commissionService = CommissionService();
    });

    group('StripePaymentProvider', () {
      final stripe = StripePaymentProvider();

      test('createPaymentIntent yields ephemeral clientSecret and no private keys', () async {
        final result = await stripe.createPaymentIntent(
          const PaymentIntentRequest(
            bookingId: 'BK-STRIPE-1',
            bookingReference: 'PNR-ST1',
            amountUSD: 150.0,
            customerEmail: 'traveler@travelgo.com',
            customerName: 'Alice Traveler',
          ),
        );

        expect(result.gatewayType, PaymentGatewayType.stripe);
        expect(result.intentId.startsWith('pi_'), isTrue);
        expect(result.clientSecret, isNotNull);
        expect(result.clientSecret!.contains('_secret_'), isTrue);
        // Guarantee Zero Client Secrets: clientSecret is ephemeral client token, not sk_live
        expect(result.clientSecret!.startsWith('sk_'), isFalse);
        expect(result.requiresAction, isTrue);
      });

      test('verifyPayment confirms transaction', () async {
        final verification = await stripe.verifyPayment(
          const PaymentVerificationRequest(
            gatewayType: PaymentGatewayType.stripe,
            intentId: 'pi_test_123',
          ),
        );

        expect(verification.isSuccess, isTrue);
        expect(verification.status, PaymentStatus.succeeded);
        expect(verification.transactionId.startsWith('ch_'), isTrue);
      });

      test('processRefund issues valid refund', () async {
        final refund = await stripe.processRefund(
          const RefundRequest(
            bookingId: 'BK-STRIPE-1',
            transactionId: 'ch_test_123',
            refundAmountUSD: 150.0,
          ),
        );

        expect(refund.isSuccess, isTrue);
        expect(refund.refundId.startsWith('re_'), isTrue);
        expect(refund.refundedAmountUSD, 150.0);
      });

      test('verifyAndParseWebhook parses Stripe payment_intent.succeeded payload', () async {
        final rawPayload = jsonEncode({
          'id': 'evt_test_1',
          'type': 'payment_intent.succeeded',
          'data': {
            'object': {
              'id': 'pi_success_123',
              'amount': 25100, // 251.00 USD in cents
              'metadata': {'bookingId': 'BK-STRIPE-99'},
            }
          }
        });

        final headers = {
          'Stripe-Signature': 't=1600000000,v1=5257a869e7ecebeda32affa62cd496d1b9',
        };

        final event = await stripe.verifyAndParseWebhook(
          rawPayload: rawPayload,
          headers: headers,
          webhookSecretOrSignature: 'whsec_test_secret',
        );

        expect(event.id, 'evt_test_1');
        expect(event.gatewayType, PaymentGatewayType.stripe);
        expect(event.eventType, 'payment_intent.succeeded');
        expect(event.bookingId, 'BK-STRIPE-99');
        expect(event.amountUSD, 251.0);
        expect(event.status, PaymentStatus.succeeded);
        expect(event.verified, isTrue);
      });
    });

    group('PayPalPaymentProvider', () {
      final paypal = PayPalPaymentProvider();

      test('createPaymentIntent yields orderId and approvalUrl', () async {
        final result = await paypal.createPaymentIntent(
          const PaymentIntentRequest(
            bookingId: 'BK-PAYPAL-1',
            bookingReference: 'PNR-PP1',
            amountUSD: 200.0,
            customerEmail: 'john@travelgo.com',
            customerName: 'John Doe',
          ),
        );

        expect(result.gatewayType, PaymentGatewayType.paypal);
        expect(result.intentId.startsWith('ORD-'), isTrue);
        expect(result.approvalUrl, isNotNull);
        expect(result.approvalUrl!.contains('paypal.com'), isTrue);
        expect(result.status, PaymentStatus.requiresApprovalUrl);
      });

      test('verifyAndParseWebhook parses PayPal PAYMENT.CAPTURE.COMPLETED', () async {
        final rawPayload = jsonEncode({
          'id': 'WH-PP-1',
          'event_type': 'PAYMENT.CAPTURE.COMPLETED',
          'resource': {
            'id': 'CAP-12345',
            'custom_id': 'BK-PAYPAL-77',
            'amount': {'value': '201.00', 'currency_code': 'USD'},
          }
        });

        final headers = {
          'PAYPAL-TRANSMISSION-ID': 'trans-id-123',
          'PAYPAL-TRANSMISSION-SIG': 'trans-sig-456',
        };

        final event = await paypal.verifyAndParseWebhook(
          rawPayload: rawPayload,
          headers: headers,
          webhookSecretOrSignature: 'test_secret',
        );

        expect(event.gatewayType, PaymentGatewayType.paypal);
        expect(event.eventType, 'PAYMENT.CAPTURE.COMPLETED');
        expect(event.bookingId, 'BK-PAYPAL-77');
        expect(event.amountUSD, 201.0);
        expect(event.status, PaymentStatus.succeeded);
        expect(event.verified, isTrue);
      });
    });

    group('MyTpePaymentProvider', () {
      final mytpe = MyTpePaymentProvider();

      test('createPaymentIntent yields orderId and CIB/Edahabia approvalUrl', () async {
        final result = await mytpe.createPaymentIntent(
          const PaymentIntentRequest(
            bookingId: 'BK-MYTPE-1',
            bookingReference: 'PNR-TPE1',
            amountUSD: 85.0,
            customerEmail: 'samir@travelgo.dz',
            customerName: 'Samir Benali',
          ),
        );

        expect(result.gatewayType, PaymentGatewayType.mytpe);
        expect(result.intentId.startsWith('TPE-'), isTrue);
        expect(result.approvalUrl, isNotNull);
        expect(result.approvalUrl!.contains('mytpe.dz'), isTrue);
        expect(result.status, PaymentStatus.requiresApprovalUrl);
      });

      test('verifyAndParseWebhook parses MyTPE confirmed event', () async {
        final rawPayload = jsonEncode({
          'event_id': 'tpe_evt_99',
          'action': 'mytpe.payment.confirmed',
          'order_reference': 'BK-MYTPE-1',
          'approval_code': 'SATIM-888999',
          'amount_usd': 86.0,
        });

        final headers = {
          'X-MyTPE-Signature': 'sha256-signature-token-mytpe',
        };

        final event = await mytpe.verifyAndParseWebhook(
          rawPayload: rawPayload,
          headers: headers,
          webhookSecretOrSignature: 'secret',
        );

        expect(event.gatewayType, PaymentGatewayType.mytpe);
        expect(event.eventType, 'mytpe.payment.confirmed');
        expect(event.bookingId, 'BK-MYTPE-1');
        expect(event.amountUSD, 86.0);
        expect(event.status, PaymentStatus.succeeded);
        expect(event.verified, isTrue);
      });
    });

    group('PaymentGatewayService End-to-End Orchestration', () {
      test('Complete payment creates ledger entry automatically', () async {
        final pricing = commissionService.calculatePricing(
          basePriceUSD: 250.0,
          isAffiliate: false,
          customTaxRate: 0.10, // $25.00
        );
        // Total = 276.00 USD (Base 250, Tax 25, Service Fee 1)

        final verification = await paymentGateway.completeAndRecordPayment(
          request: const PaymentVerificationRequest(
            gatewayType: PaymentGatewayType.stripe,
            intentId: 'pi_verified_101',
          ),
          bookingId: 'BK-E2E-1',
          bookingReference: 'PNR-E2E-1',
          pricing: pricing,
        );

        expect(verification.isSuccess, isTrue);

        // Verification in financial ledger
        expect(ledger.state.length, 1);
        final entry = ledger.state.first;
        expect(entry.bookingId, 'BK-E2E-1');
        expect(entry.grossBookingValueUSD, 276.0);
        expect(entry.basePriceUSD, 250.0);
        expect(entry.taxesUSD, 25.0);
        expect(entry.platformFeeUSD, 1.0);
        expect(entry.providerPayoutUSD, 250.0);
      });

      test('Process refund creates compensatory cancellation entry automatically', () async {
        final pricing = commissionService.calculatePricing(
          basePriceUSD: 100.0,
          isAffiliate: false,
        );

        await paymentGateway.completeAndRecordPayment(
          request: const PaymentVerificationRequest(
            gatewayType: PaymentGatewayType.paypal,
            intentId: 'ORD-REF-TEST',
          ),
          bookingId: 'BK-REF-1',
          bookingReference: 'PNR-REF-1',
          pricing: pricing,
        );

        expect(ledger.state.length, 1);

        final refundResult = await paymentGateway.processAndRecordRefund(
          request: const RefundRequest(
            bookingId: 'BK-REF-1',
            transactionId: 'CAP-REF-1',
            refundAmountUSD: 100.0,
            reason: 'Flight schedule rescheduled',
          ),
          bookingReference: 'PNR-REF-1',
          gateway: PaymentGatewayType.paypal,
          refundPlatformFee: false, // TravelGo retains $1.00 fee
        );

        expect(refundResult.isSuccess, isTrue);
        expect(ledger.state.length, 2);

        final summary = ledger.calculateSummary();
        expect(summary.totalGrossVolumeUSD, 101.0); // 100 base + 1 fee
        expect(summary.totalRefundedUSD, 100.0); // 100 base refunded
        expect(summary.grossBookingValueUSD, 1.0); // Net GBV remaining
        expect(summary.totalNetPlatformRevenueUSD, 1.0); // $1 retained fee
        expect(summary.totalProviderPayoutsUSD, 0.0); // Provider payable reversed
      });
    });
  });
}
