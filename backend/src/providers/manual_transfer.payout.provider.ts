import { IPayoutProvider, PayoutRequest, PayoutResult } from './payout.provider.interface';

export class ManualBankTransferPayoutProvider implements IPayoutProvider {
  public readonly providerId = 'manual_transfer';
  public readonly providerName = 'Manual Verified Bank Wire Transfer Workflow';
  public readonly isAutomated = false;

  async executePayout(request: PayoutRequest): Promise<PayoutResult> {
    const wireRef = `WIRE-TG-${Date.now().toString().slice(-8)}`;
    return {
      payoutId: `MANUAL-${request.withdrawalId}`,
      providerCode: this.providerId,
      isAutomated: false,
      status: 'processing',
      bankTransferReference: wireRef,
      instructions: `Please execute manual SEPA/SWIFT wire of ${request.currency} ${request.amount} to IBAN ${request.bankAccount.iban} (${request.bankAccount.bankName}). Upon completion, enter bank transaction receipt into system.`,
    };
  }
}
