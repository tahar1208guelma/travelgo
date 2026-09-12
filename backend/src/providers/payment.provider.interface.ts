export interface CreatePaymentIntentDto {
  bookingId: string;
  amount: number;
  currency: string;
  idempotencyKey: string;
  description: string;
  customerEmail: string;
}

export interface PaymentIntentResultDto {
  paymentIntentId: string;
  clientSecret: string;
  status: 'requires_payment_method' | 'requires_action_3ds' | 'succeeded' | 'failed';
  requires3DS: boolean;
  actionUrl3DS?: string;
}

export interface IPaymentProvider {
  readonly providerId: string;
  readonly providerName: string;

  createPaymentIntent(dto: CreatePaymentIntentDto): Promise<PaymentIntentResultDto>;
  verifyPayment(paymentIntentId: string): Promise<{ isVerified: boolean; amountPaid: number; currency: string; last4?: string; brand?: string }>;
  verifyWebhookSignature(rawBody: string, signature: string): Promise<any>;
  processRefund(paymentIntentId: string, amount: number): Promise<{ isRefunded: boolean; refundId: string }>;
}
