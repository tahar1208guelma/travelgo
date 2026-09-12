import { CommissionService } from '../src/services/commission.service';
import { WithdrawalService } from '../src/finance/withdrawal.service';
import { ManualBankTransferPayoutProvider } from '../src/providers/manual_transfer.payout.provider';
import { StripeConnectPayoutProvider } from '../src/providers/stripe_connect.payout.provider';

import { db } from '../src/config/database';

jest.mock('../src/config/database', () => ({
  db: {
    query: jest.fn(),
  },
}));

describe('Merchant Financial System & Commission Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Commission Calculations (0.75% standard rate)', () => {
    it('calculates exact 0.75% commission on 100 EUR', async () => {
      (db.query as jest.Mock).mockResolvedValue({ rows: [{ value: '0.0075' }] });
      const result = await CommissionService.calculate(100.0, 25.0, 'EUR');
      expect(result.commissionAmount).toBe(0.75);
      expect(result.commissionRate).toBe(0.0075);
      expect(result.totalPrice).toBe(125.75);
    });

    it('calculates exact commission on high value DZD booking', async () => {
      // 120,000 DZD flight -> 0.75% = 900 DZD
      (db.query as jest.Mock).mockResolvedValue({ rows: [{ value: '0.0075' }] });
      const result = await CommissionService.calculate(120000.0, 15000.0, 'DZD');
      expect(result.commissionAmount).toBe(900.0);
      expect(result.totalPrice).toBe(135900.0);
    });
  });

  describe('Withdrawal Thresholds and Validation', () => {
    it('returns default minimum withdrawal limits per currency', async () => {
      (db.query as jest.Mock).mockResolvedValue({ rows: [] }); // return empty to trigger fallback default minimums
      const eurMin = await WithdrawalService.getMinimumWithdrawal('EUR');
      const dzdMin = await WithdrawalService.getMinimumWithdrawal('DZD');
      const usdMin = await WithdrawalService.getMinimumWithdrawal('USD');

      expect(eurMin).toBe(50.0);
      expect(dzdMin).toBe(6500.0);
      expect(usdMin).toBe(50.0);
    });

    it('masks sensitive bank IBAN numbers correctly', () => {
      const maskedAlgeria = WithdrawalService.maskIban('DZ5002100012345678901234');
      expect(maskedAlgeria).toBe('DZ****1234');

      const maskedFrance = WithdrawalService.maskIban('FR7630006000011234567890189');
      expect(maskedFrance).toBe('FR****0189');

      const short = WithdrawalService.maskIban('123');
      expect(short).toBe('****');
    });
  });

  describe('Payout Providers Abstraction', () => {
    it('ManualBankTransferPayoutProvider issues structured reference wire instructions', async () => {
      const provider = new ManualBankTransferPayoutProvider();
      expect(provider.providerId).toBe('manual_transfer');
      expect(provider.isAutomated).toBe(false);

      const res = await provider.executePayout({
        withdrawalId: 'test-with-123',
        amount: 250.0,
        currency: 'EUR',
        bankAccount: {
          accountHolderName: 'Platform Owner',
          bankName: 'Société Générale',
          iban: 'DZ5002100012345678901234',
          swiftBic: 'SGEADZAL',
          country: 'Algeria',
        },
        description: 'Test Payout',
      });

      expect(res.isAutomated).toBe(false);
      expect(res.status).toBe('processing');
      expect(res.bankTransferReference).toContain('WIRE-TG-');
      expect(res.instructions).toContain('EUR 250');
      expect(res.instructions).toContain('DZ5002100012345678901234');
    });

    it('StripeConnectPayoutProvider creates automated payout transaction', async () => {
      const provider = new StripeConnectPayoutProvider();
      expect(provider.providerId).toBe('stripe_connect');
      expect(provider.isAutomated).toBe(true);

      const res = await provider.executePayout({
        withdrawalId: 'test-with-stripe-456',
        amount: 150.0,
        currency: 'USD',
        bankAccount: {
          accountHolderName: 'Platform Owner',
          bankName: 'Chase Bank',
          iban: 'US12CHAS000123456789',
          swiftBic: 'CHASUS33',
          country: 'United States',
        },
        description: 'Test Stripe Payout',
      });

      expect(res.isAutomated).toBe(true);
      expect(res.bankTransferReference).toContain('STRIPE-PAYOUT-po_');
    });
  });
});
