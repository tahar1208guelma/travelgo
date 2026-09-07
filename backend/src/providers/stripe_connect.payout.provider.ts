import { IPayoutProvider, PayoutRequest, PayoutResult } from './payout.provider.interface';

export class StripeConnectPayoutProvider implements IPayoutProvider {
  public readonly providerId = 'stripe_connect';
  public readonly providerName = 'Stripe Connect Automated Bank Payouts';
  public readonly isAutomated = true;

  async executePayout(request: PayoutRequest): Promise<PayoutResult> {
    const poId = `po_${Math.random().toString(36).substring(2, 14)}`;
    return {
      payoutId: poId,
      providerCode: this.providerId,
      isAutomated: true,
      status: 'processing',
      bankTransferReference: `STRIPE-PAYOUT-${poId}`,
    };
  }
}
