export interface PayoutRequest {
  withdrawalId: string;
  amount: number;
  currency: string;
  bankAccount: {
    accountHolderName: string;
    bankName: string;
    iban: string;
    swiftBic: string;
    country: string;
  };
  description: string;
}

export interface PayoutResult {
  payoutId: string;
  providerCode: string;
  isAutomated: boolean;
  status: 'processing' | 'completed' | 'pending';
  bankTransferReference?: string;
  instructions?: string;
}

export interface IPayoutProvider {
  readonly providerId: string;
  readonly providerName: string;
  readonly isAutomated: boolean;

  executePayout(request: PayoutRequest): Promise<PayoutResult>;
}
