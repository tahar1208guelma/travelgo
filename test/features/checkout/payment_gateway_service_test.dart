import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/network/api_client.dart';
import 'package:travelgo/features/checkout/models/payment_intent.dart';
import 'package:travelgo/features/checkout/services/payment_gateway_service.dart';

void main() {
  group('PaymentGatewayService PCI-DSS & 3DS2 Tests', () {
    late PaymentGatewayService service;

    setUp(() {
      service = PaymentGatewayServiceImpl(apiClient: ApiClient());
    });

    test('createPaymentIntent returns valid client secret without exposing raw credentials', () async {
      final intent = await service.createPaymentIntent(
        amount: 251.88,
        currency: 'USD',
        bookingReference: 'TRV-2026-TEST01',
      );

      expect(intent.id, isNotEmpty);
      expect(intent.clientSecret, isNotEmpty);
      expect(intent.amount, equals(251.88));
      expect(intent.currency, equals('USD'));
      expect(intent.status, equals(PaymentIntentStatus.requiresPaymentMethod));
    });

    test('tokenizeHostedFields generates opaque vault token without storing card number', () async {
      final token = await service.tokenizeHostedFields(
        cardholderName: 'Tahar Braknia',
        cardBrand: 'Visa',
        last4: '4242',
        expiryMonth: '12',
        expiryYear: '28',
      );

      expect(token.paymentToken.startsWith('pm_visa_'), isTrue);
      expect(token.cardholderName, equals('Tahar Braknia'));
      expect(token.cardBrand, equals('Visa'));
      expect(token.last4, equals('4242'));
      expect(token.requires3DS, isTrue);
    });

    test('confirmPayment triggers 3-D Secure challenge for 3DS required card', () async {
      final intent = await service.createPaymentIntent(
        amount: 251.88,
        currency: 'USD',
        bookingReference: 'TRV-2026-TEST02',
      );

      final token = await service.tokenizeHostedFields(
        cardholderName: 'Tahar Braknia',
        cardBrand: 'Mastercard',
        last4: '5555',
        expiryMonth: '10',
        expiryYear: '27',
      );

      final confirmed = await service.confirmPayment(
        intent: intent,
        paymentMethod: token,
        idempotencyKey: 'IDEMP-TEST-001',
      );

      expect(confirmed.status, equals(PaymentIntentStatus.requiresAction));
      expect(confirmed.requires3DSChallenge, isTrue);
      expect(confirmed.nextActionUrl, isNotNull);

      // Verify challenge completion
      final finalIntent = await service.complete3DSecureChallenge(intent: confirmed);
      expect(finalIntent.status, equals(PaymentIntentStatus.succeeded));
      expect(finalIntent.isSuccessful, isTrue);
    });
  });
}
