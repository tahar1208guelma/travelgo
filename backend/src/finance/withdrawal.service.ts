import { db } from '../config/database';
import { ApiError } from '../errors/api.error';
import { AuditService } from '../services/audit.service';
import { ManualBankTransferPayoutProvider } from '../providers/manual_transfer.payout.provider';
import { StripeConnectPayoutProvider } from '../providers/stripe_connect.payout.provider';
import { IPayoutProvider } from '../providers/payout.provider.interface';

export interface BankAccountDto {
  id: string;
  ownerId: string;
  accountHolderName: string;
  bankName: string;
  iban: string;
  maskedIban: string;
  swiftBic: string;
  country: string;
  isPrimary: boolean;
  createdAt: string;
}

export interface WithdrawalDto {
  id: string;
  walletId: string;
  bankAccountId: string | null;
  amount: number;
  currency: string;
  status: string;
  rejectionReason?: string;
  bankTransferReference?: string;
  requestedBy: string;
  reviewedBy?: string;
  requestedAt: string;
  processedAt?: string;
  bankAccount?: {
    bankName: string;
    accountHolderName: string;
    maskedIban: string;
    swiftBic: string;
    country: string;
  };
}

export class WithdrawalService {
  /**
   * Minimum withdrawal thresholds by currency (fallback if settings not present)
   */
  private static readonly DEFAULT_MIN_WITHDRAWALS: Record<string, number> = {
    EUR: 50.0,
    USD: 50.0,
    DZD: 6500.0,
    GBP: 40.0,
  };

  /**
   * Retrieves minimum withdrawal limit for a given currency
   */
  static async getMinimumWithdrawal(currency: string): Promise<number> {
    const cur = currency.toUpperCase();
    const key = `minimum_withdrawal_amount_${cur.toLowerCase()}`;
    const res = await db.query('SELECT value FROM settings WHERE key = $1', [key]);
    if (res.rows.length > 0 && res.rows[0].value) {
      return parseFloat(res.rows[0].value);
    }
    return this.DEFAULT_MIN_WITHDRAWALS[cur] || 50.0;
  }

  /**
   * Mask sensitive IBAN / Account details for security & UI display
   */
  static maskIban(iban: string): string {
    if (!iban || iban.length < 6) return '****';
    const last4 = iban.slice(-4);
    const prefix = iban.slice(0, 2);
    return `${prefix}****${last4}`;
  }

  /**
   * STEP 7: Request a withdrawal against available balance
   * - Validates minimum withdrawal limit
   * - Locks wallet row (FOR UPDATE)
   * - Checks available balance
   * - Decrements available balance
   * - Records pending withdrawal
   * - Appends to financial ledger
   */
  static async requestWithdrawal(
    ownerId: string,
    amount: number,
    currency: string,
    bankAccountId?: string
  ): Promise<WithdrawalDto> {
    if (amount <= 0) {
      throw ApiError.badRequest('Withdrawal amount must be greater than zero');
    }

    const cur = currency.toUpperCase();
    const minThreshold = await this.getMinimumWithdrawal(cur);
    if (amount < minThreshold) {
      throw ApiError.badRequest(
        `Requested amount ${amount} ${cur} is below the minimum threshold of ${minThreshold} ${cur}`
      );
    }

    const client = await db.getClient();
    try {
      await client.query('BEGIN');

      // 1. Resolve and verify Bank Account
      let selectedBankId = bankAccountId;
      if (!selectedBankId) {
        const bRes = await client.query(
          'SELECT id FROM bank_accounts WHERE owner_id = $1 ORDER BY is_primary DESC, created_at DESC LIMIT 1',
          [ownerId]
        );
        if (bRes.rows.length === 0) {
          throw ApiError.badRequest('Please add a verified bank account before requesting a payout');
        }
        selectedBankId = bRes.rows[0].id;
      } else {
        const bRes = await client.query(
          'SELECT id FROM bank_accounts WHERE id = $1 AND owner_id = $2',
          [selectedBankId, ownerId]
        );
        if (bRes.rows.length === 0) {
          throw ApiError.notFound('Bank account not found or does not belong to owner');
        }
      }

      // 2. Lock wallet row FOR UPDATE
      const wRes = await client.query(
        'SELECT id, available_balance, total_withdrawn FROM wallets WHERE owner_id = $1 AND currency = $2 FOR UPDATE',
        [ownerId, cur]
      );
      if (wRes.rows.length === 0) {
        throw ApiError.notFound(`Wallet for currency ${cur} not found`);
      }

      const wallet = wRes.rows[0];
      const available = parseFloat(wallet.available_balance);

      if (available < amount) {
        throw ApiError.badRequest(
          `Insufficient available balance. Available: ${available.toFixed(2)} ${cur}, Requested: ${amount.toFixed(2)} ${cur}`
        );
      }

      const balanceBefore = available;
      const balanceAfter = Math.round((available - amount) * 100) / 100;

      // 3. Decrement available balance (funds locked in withdrawal request)
      await client.query(
        `UPDATE wallets 
         SET available_balance = available_balance - $1, updated_at = CURRENT_TIMESTAMP 
         WHERE id = $2`,
        [amount, wallet.id]
      );

      // 4. Create withdrawal entry
      const withRes = await client.query(
        `INSERT INTO withdrawals (wallet_id, bank_account_id, amount, currency, status, requested_by)
         VALUES ($1, $2, $3, $4, 'pending', $5)
         RETURNING *`,
        [wallet.id, selectedBankId, amount, cur, ownerId]
      );
      const withdrawal = withRes.rows[0];

      // 5. Append to Immutable Financial Ledger
      await client.query(
        `INSERT INTO wallet_transactions (wallet_id, type, reference_id, amount, currency, balance_before, balance_after, status, description)
         VALUES ($1, 'withdrawal', $2, $3, $4, $5, $6, 'pending', $7)`,
        [
          wallet.id,
          withdrawal.id,
          -amount,
          cur,
          balanceBefore,
          balanceAfter,
          `Withdrawal request #${withdrawal.id.slice(0, 8)} to bank account`,
        ]
      );

      await client.query('COMMIT');

      await AuditService.log('WITHDRAWAL_REQUESTED', 'withdrawals', withdrawal.id, ownerId, {
        amount,
        currency: cur,
        bankAccountId: selectedBankId,
      });

      return this.getWithdrawalById(withdrawal.id);
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  /**
   * STEP 8: Admin Verification / Approval of Withdrawal
   */
  static async approveWithdrawal(withdrawalId: string, adminUserId: string) {
    const res = await db.query(
      `UPDATE withdrawals 
       SET status = 'approved', reviewed_by = $1 
       WHERE id = $2 AND status = 'pending' 
       RETURNING *`,
      [adminUserId, withdrawalId]
    );

    if (res.rows.length === 0) {
      throw ApiError.badRequest('Withdrawal request cannot be approved (not in pending status or not found)');
    }

    await AuditService.log('WITHDRAWAL_APPROVED', 'withdrawals', withdrawalId, adminUserId);
    return this.getWithdrawalById(withdrawalId);
  }

  /**
   * STEP 9: Execute Bank Payout via configured payout provider
   */
  static async processPayout(withdrawalId: string, adminUserId: string) {
    const w = await this.getWithdrawalById(withdrawalId);
    if (w.status !== 'approved' && w.status !== 'pending') {
      throw ApiError.badRequest(`Withdrawal cannot be processed from status '${w.status}'`);
    }

    // Determine configured payout provider
    const pSet = await db.query("SELECT value FROM settings WHERE key = 'payout_provider_active'");
    const providerKey = pSet.rows.length > 0 ? pSet.rows[0].value : 'manual_transfer';

    let provider: IPayoutProvider;
    if (providerKey === 'stripe_connect') {
      provider = new StripeConnectPayoutProvider();
    } else {
      provider = new ManualBankTransferPayoutProvider();
    }

    // Fetch full bank account details
    const bRes = await db.query('SELECT * FROM bank_accounts WHERE id = $1', [w.bankAccountId]);
    if (bRes.rows.length === 0) {
      throw ApiError.notFound('Associated bank account not found');
    }
    const bank = bRes.rows[0];

    const payoutResult = await provider.executePayout({
      withdrawalId: w.id,
      amount: w.amount,
      currency: w.currency,
      bankAccount: {
        accountHolderName: bank.account_holder_name,
        bankName: bank.bank_name,
        iban: bank.iban,
        swiftBic: bank.swift_bic,
        country: bank.country,
      },
      description: `TravelGo Merchant Commission Payout #${w.id.slice(0, 8)}`,
    });

    // Update status to processing with transfer reference
    await db.query(
      `UPDATE withdrawals 
       SET status = 'processing', bank_transfer_reference = $1, reviewed_by = $2 
       WHERE id = $3`,
      [payoutResult.bankTransferReference, adminUserId, withdrawalId]
    );

    await AuditService.log('WITHDRAWAL_PROCESSING', 'withdrawals', withdrawalId, adminUserId, {
      payoutId: payoutResult.payoutId,
      provider: provider.providerName,
      reference: payoutResult.bankTransferReference,
    });

    return {
      withdrawal: await this.getWithdrawalById(withdrawalId),
      payoutResult,
    };
  }

  /**
   * STEP 10: Complete Withdrawal upon bank confirmation
   */
  static async completeWithdrawal(
    withdrawalId: string,
    bankTransferReference?: string,
    adminUserId?: string
  ) {
    const client = await db.getClient();
    try {
      await client.query('BEGIN');

      const wRes = await client.query('SELECT * FROM withdrawals WHERE id = $1 FOR UPDATE', [withdrawalId]);
      if (wRes.rows.length === 0) throw ApiError.notFound('Withdrawal not found');
      const w = wRes.rows[0];

      if (w.status !== 'processing' && w.status !== 'approved' && w.status !== 'pending') {
        throw ApiError.badRequest(`Cannot complete withdrawal in status '${w.status}'`);
      }

      const reference = bankTransferReference || w.bank_transfer_reference || `WIRE-TG-${Date.now().toString().slice(-8)}`;

      // 1. Mark withdrawal completed
      await client.query(
        `UPDATE withdrawals 
         SET status = 'completed', bank_transfer_reference = $1, processed_at = CURRENT_TIMESTAMP, reviewed_by = COALESCE($2, reviewed_by)
         WHERE id = $3`,
        [reference, adminUserId || null, withdrawalId]
      );

      // 2. Update wallet total_withdrawn
      await client.query(
        `UPDATE wallets 
         SET total_withdrawn = total_withdrawn + $1, updated_at = CURRENT_TIMESTAMP 
         WHERE id = $2`,
        [parseFloat(w.amount), w.wallet_id]
      );

      // 3. Mark ledger transaction completed
      await client.query(
        `UPDATE wallet_transactions 
         SET status = 'completed', description = description || ' [Reference: ' || $1 || ']'
         WHERE reference_id = $2 AND type = 'withdrawal'`,
        [reference, withdrawalId]
      );

      await client.query('COMMIT');

      await AuditService.log('WITHDRAWAL_COMPLETED', 'withdrawals', withdrawalId, adminUserId, {
        reference,
        amount: w.amount,
        currency: w.currency,
      });

      return this.getWithdrawalById(withdrawalId);
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  /**
   * Rejection of Withdrawal: returns funds to wallet available_balance
   * Appends adjustment to ledger without deleting past record
   */
  static async rejectWithdrawal(withdrawalId: string, reason: string, adminUserId: string) {
    const client = await db.getClient();
    try {
      await client.query('BEGIN');

      const wRes = await client.query('SELECT * FROM withdrawals WHERE id = $1 FOR UPDATE', [withdrawalId]);
      if (wRes.rows.length === 0) throw ApiError.notFound('Withdrawal not found');
      const w = wRes.rows[0];

      if (w.status === 'completed' || w.status === 'rejected') {
        throw ApiError.badRequest(`Cannot reject withdrawal already in '${w.status}' status`);
      }

      const amount = parseFloat(w.amount);

      // 1. Lock wallet and restore funds to available_balance
      const walletRes = await client.query(
        'SELECT id, available_balance FROM wallets WHERE id = $1 FOR UPDATE',
        [w.wallet_id]
      );
      const wallet = walletRes.rows[0];
      const balanceBefore = parseFloat(wallet.available_balance);
      const balanceAfter = Math.round((balanceBefore + amount) * 100) / 100;

      await client.query(
        `UPDATE wallets 
         SET available_balance = available_balance + $1, updated_at = CURRENT_TIMESTAMP 
         WHERE id = $2`,
        [amount, wallet.id]
      );

      // 2. Mark withdrawal rejected
      await client.query(
        `UPDATE withdrawals 
         SET status = 'rejected', rejection_reason = $1, processed_at = CURRENT_TIMESTAMP, reviewed_by = $2 
         WHERE id = $3`,
        [reason, adminUserId, withdrawalId]
      );

      // 3. Mark original pending withdrawal transaction as cancelled
      await client.query(
        `UPDATE wallet_transactions 
         SET status = 'cancelled' 
         WHERE reference_id = $1 AND type = 'withdrawal'`,
        [withdrawalId]
      );

      // 4. Append 'adjustment' transaction to ledger to document fund restoration
      await client.query(
        `INSERT INTO wallet_transactions (wallet_id, type, reference_id, amount, currency, balance_before, balance_after, status, description)
         VALUES ($1, 'adjustment', $2, $3, $4, $5, $6, 'completed', $7)`,
        [
          wallet.id,
          withdrawalId,
          amount,
          w.currency,
          balanceBefore,
          balanceAfter,
          `Withdrawal #${withdrawalId.slice(0, 8)} rejected: ${reason}. Funds returned to wallet.`,
        ]
      );

      await client.query('COMMIT');

      await AuditService.log('WITHDRAWAL_REJECTED', 'withdrawals', withdrawalId, adminUserId, {
        reason,
        returnedAmount: amount,
      });

      return this.getWithdrawalById(withdrawalId);
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  /**
   * Retrieves single withdrawal with full bank account details
   */
  static async getWithdrawalById(id: string): Promise<WithdrawalDto> {
    const res = await db.query(
      `SELECT w.*, 
              ba.bank_name, ba.account_holder_name, ba.iban, ba.swift_bic, ba.country
       FROM withdrawals w
       LEFT JOIN bank_accounts ba ON w.bank_account_id = ba.id
       WHERE w.id = $1`,
      [id]
    );

    if (res.rows.length === 0) throw ApiError.notFound('Withdrawal record not found');
    const r = res.rows[0];

    return {
      id: r.id,
      walletId: r.wallet_id,
      bankAccountId: r.bank_account_id,
      amount: parseFloat(r.amount),
      currency: r.currency,
      status: r.status,
      rejectionReason: r.rejection_reason || undefined,
      bankTransferReference: r.bank_transfer_reference || undefined,
      requestedBy: r.requested_by,
      reviewedBy: r.reviewed_by || undefined,
      requestedAt: r.requested_at,
      processedAt: r.processed_at || undefined,
      bankAccount: r.bank_name
        ? {
            bankName: r.bank_name,
            accountHolderName: r.account_holder_name,
            maskedIban: this.maskIban(r.iban),
            swiftBic: r.swift_bic,
            country: r.country,
          }
        : undefined,
    };
  }

  /**
   * List withdrawals with optional filtering
   */
  static async getWithdrawals(ownerId?: string, limit = 50, offset = 0): Promise<WithdrawalDto[]> {
    let query = `
      SELECT w.*, 
             ba.bank_name, ba.account_holder_name, ba.iban, ba.swift_bic, ba.country
      FROM withdrawals w
      LEFT JOIN bank_accounts ba ON w.bank_account_id = ba.id
    `;
    const params: any[] = [];

    if (ownerId) {
      query += ` WHERE w.requested_by = $1`;
      params.push(ownerId);
    }

    query += ` ORDER BY w.requested_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(limit, offset);

    const res = await db.query(query, params);
    return res.rows.map((r) => ({
      id: r.id,
      walletId: r.wallet_id,
      bankAccountId: r.bank_account_id,
      amount: parseFloat(r.amount),
      currency: r.currency,
      status: r.status,
      rejectionReason: r.rejection_reason || undefined,
      bankTransferReference: r.bank_transfer_reference || undefined,
      requestedBy: r.requested_by,
      reviewedBy: r.reviewed_by || undefined,
      requestedAt: r.requested_at,
      processedAt: r.processed_at || undefined,
      bankAccount: r.bank_name
        ? {
            bankName: r.bank_name,
            accountHolderName: r.account_holder_name,
            maskedIban: this.maskIban(r.iban),
            swiftBic: r.swift_bic,
            country: r.country,
          }
        : undefined,
    }));
  }

  /**
   * Generates official PDF Withdrawal Receipt Metadata
   */
  static async generateReceipt(withdrawalId: string) {
    const w = await this.getWithdrawalById(withdrawalId);
    return {
      receiptNumber: `TG-WITHDRAW-${w.id.slice(0, 8).toUpperCase()}`,
      withdrawalId: w.id,
      currency: w.currency,
      amount: w.amount,
      platformFee: 0.0,
      netPayoutAmount: w.amount,
      status: w.status.toUpperCase(),
      bankTransferReference: w.bankTransferReference || 'PENDING_DISPATCH',
      bankDetails: w.bankAccount || {
        bankName: 'Wire Transfer Bank Account',
        accountHolderName: 'Platform Owner',
        maskedIban: '****',
        swiftBic: 'N/A',
        country: 'Global',
      },
      requestedAt: w.requestedAt,
      processedAt: w.processedAt || null,
      disclaimer:
        'Official TravelGo Platform Merchant Payout Receipt. Generated securely from immutable ledger.',
    };
  }

  // ==========================================
  // Bank Account Management
  // ==========================================

  static async getBankAccounts(ownerId: string): Promise<BankAccountDto[]> {
    const res = await db.query(
      'SELECT * FROM bank_accounts WHERE owner_id = $1 ORDER BY is_primary DESC, created_at DESC',
      [ownerId]
    );

    return res.rows.map((r) => ({
      id: r.id,
      ownerId: r.owner_id,
      accountHolderName: r.account_holder_name,
      bankName: r.bank_name,
      iban: r.iban,
      maskedIban: this.maskIban(r.iban),
      swiftBic: r.swift_bic,
      country: r.country,
      isPrimary: r.is_primary,
      createdAt: r.created_at,
    }));
  }

  static async addBankAccount(
    ownerId: string,
    data: {
      accountHolderName: string;
      bankName: string;
      iban: string;
      swiftBic: string;
      country: string;
      isPrimary?: boolean;
    }
  ): Promise<BankAccountDto> {
    if (!data.accountHolderName || !data.bankName || !data.iban || !data.swiftBic) {
      throw ApiError.badRequest('Missing required bank account fields');
    }

    // If marked primary, unset other accounts first
    if (data.isPrimary) {
      await db.query('UPDATE bank_accounts SET is_primary = FALSE WHERE owner_id = $1', [ownerId]);
    }

    const res = await db.query(
      `INSERT INTO bank_accounts (owner_id, account_holder_name, bank_name, iban, swift_bic, country, is_primary)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [
        ownerId,
        data.accountHolderName.trim(),
        data.bankName.trim(),
        data.iban.replace(/\s+/g, '').toUpperCase(),
        data.swiftBic.trim().toUpperCase(),
        data.country || 'Algeria',
        data.isPrimary ?? true,
      ]
    );

    const r = res.rows[0];
    return {
      id: r.id,
      ownerId: r.owner_id,
      accountHolderName: r.account_holder_name,
      bankName: r.bank_name,
      iban: r.iban,
      maskedIban: this.maskIban(r.iban),
      swiftBic: r.swift_bic,
      country: r.country,
      isPrimary: r.is_primary,
      createdAt: r.created_at,
    };
  }

  static async deleteBankAccount(id: string, ownerId: string) {
    const res = await db.query('DELETE FROM bank_accounts WHERE id = $1 AND owner_id = $2 RETURNING id', [
      id,
      ownerId,
    ]);
    if (res.rows.length === 0) {
      throw ApiError.notFound('Bank account not found or cannot be deleted');
    }
    return { deleted: true, id };
  }
}
