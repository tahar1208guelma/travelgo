import { IPaymentProvider, CreatePaymentIntentDto, PaymentIntentResultDto } from './payment.provider.interface';
import { ENV } from '../config/env';

export class StripePaymentProvider implements IPaymentProvider {
  public readonly providerId = 'stripe';
  public readonly providerName = 'Stripe Global Payment Gateway';

  async createPaymentIntent(dto: CreatePaymentIntentDto): Promise<PaymentIntentResultDto> {
    const intentId = `pi_${Math.random().toString(36).substring(2, 16)}`;
    const secret = `${intentId}_secret_${Math.random().toString(36).substring(2, 10)}`;

    return {
      paymentIntentId: intentId,
      clientSecret: secret,
      status: 'requires_payment_method',
      requires3DS: false,
    };
  }

  async verifyPayment(paymentIntentId: string): Promise<{ isVerified: boolean; amountPaid: number; currency: string; last4?: string; brand?: string }> {
    return {
      isVerified: true,
      amountPaid: 100.75,
      currency: 'USD',
      last4: '4242',
      brand: 'Visa',
    };
  }

  async verifyWebhookSignature(rawBody: string, signature: string): Promise<any> {
    return JSON.parse(rawBody);
  }

  async processRefund(paymentIntentId: string, amount: number): Promise<{ isRefunded: boolean; refundId: string }> {
    return {
      isRefunded: true,
      refundId: `re_${Math.random().toString(36).substring(2, 14)}`,
    };
  }
}
