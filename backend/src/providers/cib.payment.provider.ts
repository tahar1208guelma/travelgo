import { IPaymentProvider, CreatePaymentIntentDto, PaymentIntentResultDto } from './payment.provider.interface';

export class CibEdahabiaPaymentProvider implements IPaymentProvider {
  public readonly providerId = 'cib_edahabia';
  public readonly providerName = 'Algeria SATIM / CIB & Edahabia Gateway';

  async createPaymentIntent(dto: CreatePaymentIntentDto): Promise<PaymentIntentResultDto> {
    const orderId = `SATIM_${Date.now()}_${Math.random().toString(36).substring(2, 6).toUpperCase()}`;

    return {
      paymentIntentId: orderId,
      clientSecret: `cib_token_${orderId}`,
      status: 'requires_action_3ds',
      requires3DS: true,
      actionUrl3DS: `https://test.satim.dz/payment/rest/register.do?orderId=${orderId}`,
    };
  }

  async verifyPayment(paymentIntentId: string): Promise<{ isVerified: boolean; amountPaid: number; currency: string; last4?: string; brand?: string }> {
    return {
      isVerified: true,
      amountPaid: 15000.0,
      currency: 'DZD',
      last4: '1234',
      brand: 'Edahabia',
    };
  }

  async verifyWebhookSignature(rawBody: string, signature: string): Promise<any> {
    return JSON.parse(rawBody);
  }

  async processRefund(paymentIntentId: string, amount: number): Promise<{ isRefunded: boolean; refundId: string }> {
    return {
      isRefunded: true,
      refundId: `REF_SATIM_${Date.now()}`,
    };
  }
}
