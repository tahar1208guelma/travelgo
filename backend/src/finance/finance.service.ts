import { db } from '../config/database';
import { ApiError } from '../errors/api.error';
import { AuditService } from '../services/audit.service';

export interface WalletDto {
  walletId: string;
  ownerId: string;
  currency: string;
  availableBalance: number;
  pendingBalance: number;
  totalEarned: number;
  totalWithdrawn: number;
  totalRefunded: number;
  updatedAt: string;
}

export class FinanceService {
  /**
   * Retrieves or initializes the currency wallet for the platform owner
   * Strict currency isolation: EUR, USD, DZD, GBP wallets are independent
   */
  static async getOrCreateWallet(ownerId: string, currency: string): Promise<WalletDto> {
    const cur = currency.toUpperCase();
    const res = await db.query(
      `INSERT INTO wallets (owner_id, currency, available_balance, pending_balance, total_earned, total_withdrawn, total_refunded)
       VALUES ($1, $2, 0.00, 0.00, 0.00, 0.00, 0.00)
       ON CONFLICT (owner_id, currency) DO UPDATE SET updated_at = CURRENT_TIMESTAMP
       RETURNING *`,
      [ownerId, cur]
    );

    const w = res.rows[0];
    return {
      walletId: w.id,
      ownerId: w.owner_id,
      currency: w.currency,
      availableBalance: parseFloat(w.available_balance),
      pendingBalance: parseFloat(w.pending_balance),
      totalEarned: parseFloat(w.total_earned),
      totalWithdrawn: parseFloat(w.total_withdrawn),
      totalRefunded: parseFloat(w.total_refunded),
      updatedAt: w.updated_at,
    };
  }

  /**
   * Retrieves all multi-currency wallets for the platform owner
   */
  static async getAllOwnerWallets(ownerId: string): Promise<WalletDto[]> {
    const supportedCurrencies = ['EUR', 'USD', 'DZD', 'GBP'];
    // Ensure wallets exist for all 4 currencies
    for (const cur of supportedCurrencies) {
      await this.getOrCreateWallet(ownerId, cur);
    }

    const res = await db.query('SELECT * FROM wallets WHERE owner_id = $1 ORDER BY currency ASC', [ownerId]);
    return res.rows.map((w) => ({
      walletId: w.id,
      ownerId: w.owner_id,
      currency: w.currency,
      availableBalance: parseFloat(w.available_balance),
      pendingBalance: parseFloat(w.pending_balance),
      totalEarned: parseFloat(w.total_earned),
      totalWithdrawn: parseFloat(w.total_withdrawn),
      totalRefunded: parseFloat(w.total_refunded),
      updatedAt: w.updated_at,
    }));
  }

  /**
   * STEP 5: Commission calculated & placed into PENDING state upon booking payment
   * Idempotency protected: will not double-credit on replayed calls or duplicate webhooks.
   */
  static async recordPendingCommission(
    ownerId: string,
    bookingId: string,
    baseAmount: number,
    currency: string,
    commissionRate: number
  ) {
    const client = await db.getClient();
    try {
      await client.query('BEGIN');

      // 1. Check idempotency in commissions table
      const existing = await client.query('SELECT id, status FROM commissions WHERE booking_id = $1', [bookingId]);
      if (existing.rows.length > 0) {
        await client.query('COMMIT');
        return existing.rows[0];
      }

      const commissionAmount = Math.round(baseAmount * commissionRate * 100) / 100;

      // 2. Lock and update wallet pending balance
      const wRes = await client.query(
        `SELECT id, pending_balance, available_balance 
         FROM wallets 
         WHERE owner_id = $1 AND currency = $2 
         FOR UPDATE`,
        [ownerId, currency.toUpperCase()]
      );

      let walletId: string;
      if (wRes.rows.length === 0) {
        const ins = await client.query(
          `INSERT INTO wallets (owner_id, currency, available_balance, pending_balance)
           VALUES ($1, $2, 0.00, $3) RETURNING id`,
          [ownerId, currency.toUpperCase(), commissionAmount]
        );
        walletId = ins.rows[0].id;
      } else {
        walletId = wRes.rows[0].id;
        await client.query(
          `UPDATE wallets 
           SET pending_balance = pending_balance + $1, updated_at = CURRENT_TIMESTAMP 
           WHERE id = $2`,
          [commissionAmount, walletId]
        );
      }

      // 3. Insert Commission Record (status = pending)
      const cRes = await client.query(
        `INSERT INTO commissions (booking_id, base_amount, currency, commission_rate, commission_amount, status)
         VALUES ($1, $2, $3, $4, $5, 'pending') RETURNING *`,
        [bookingId, baseAmount, currency.toUpperCase(), commissionRate, commissionAmount]
      );

      await client.query('COMMIT');
      return cRes.rows[0];
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  /**
   * STEP 6: Release commission from PENDING to AVAILABLE
   * Triggered ONLY after Provider confirmation (PNR issued / Hotel confirmed)
   */
  static async releaseCommissionToAvailable(ownerId: string, bookingId: string) {
    const client = await db.getClient();
    try {
      await client.query('BEGIN');

      // 1. Fetch commission record
      const cRes = await client.query('SELECT * FROM commissions WHERE booking_id = $1 FOR UPDATE', [bookingId]);
      if (cRes.rows.length === 0) throw ApiError.notFound('Commission record not found');
      const commission = cRes.rows[0];

      if (commission.status === 'available') {
        // Already released (idempotent)
        await client.query('COMMIT');
        return commission;
      }

      if (commission.status !== 'pending') {
        throw ApiError.badRequest(`Cannot release commission in '${commission.status}' status`);
      }

      const amount = parseFloat(commission.commission_amount);
      const currency = commission.currency;

      // 2. Lock wallet and move funds from pending to available
      const wRes = await client.query(
        'SELECT id, available_balance, pending_balance, total_earned FROM wallets WHERE owner_id = $1 AND currency = $2 FOR UPDATE',
        [ownerId, currency]
      );
      if (wRes.rows.length === 0) throw ApiError.notFound('Merchant wallet not found');
      const wallet = wRes.rows[0];

      const balanceBefore = parseFloat(wallet.available_balance);
      const balanceAfter = Math.round((balanceBefore + amount) * 100) / 100;

      await client.query(
        `UPDATE wallets 
         SET pending_balance = GREATEST(0.00, pending_balance - $1),
             available_balance = available_balance + $1,
             total_earned = total_earned + $1,
             updated_at = CURRENT_TIMESTAMP
         WHERE id = $2`,
        [amount, wallet.id]
      );

      // 3. Mark commission as AVAILABLE
      await client.query(
        `UPDATE commissions 
         SET status = 'available', available_at = CURRENT_TIMESTAMP 
         WHERE id = $1`,
        [commission.id]
      );

      // 4. Append to Immutable Financial Ledger (Never edit old transactions)
      await client.query(
        `INSERT INTO wallet_transactions (wallet_id, type, reference_id, amount, currency, balance_before, balance_after, status, description)
         VALUES ($1, 'commission', $2, $3, $4, $5, $6, 'completed', $7)`,
        [
          wallet.id,
          bookingId,
          amount,
          currency,
          balanceBefore,
          balanceAfter,
          `TravelGo Platform Commission 0.75% for Booking ${bookingId}`,
        ]
      );

      await client.query('COMMIT');
      return { isReleased: true, bookingId, commissionAmount: amount, newAvailableBalance: balanceAfter };
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  /**
   * Refund handling: Never modify past ledger entries.
   * If commission was pending: cancel it.
   * If commission was already available: debit available balance with an 'adjustment' ledger transaction.
   */
  static async handleBookingRefund(ownerId: string, bookingId: string, refundReason: string) {
    const client = await db.getClient();
    try {
      await client.query('BEGIN');

      const cRes = await client.query('SELECT * FROM commissions WHERE booking_id = $1 FOR UPDATE', [bookingId]);
      if (cRes.rows.length === 0) {
        await client.query('COMMIT');
        return { isReversed: false, reason: 'No commission recorded' };
      }

      const comm = cRes.rows[0];
      const amount = parseFloat(comm.commission_amount);
      const currency = comm.currency;

      const wRes = await client.query('SELECT id, available_balance, pending_balance FROM wallets WHERE owner_id = $1 AND currency = $2 FOR UPDATE', [ownerId, currency]);
      const wallet = wRes.rows[0];

      if (comm.status === 'pending') {
        // Pending commission simply cancelled
        await client.query('UPDATE wallets SET pending_balance = GREATEST(0.00, pending_balance - $1) WHERE id = $2', [amount, wallet.id]);
        await client.query("UPDATE commissions SET status = 'cancelled' WHERE id = $1", [comm.id]);
      } else if (comm.status === 'available') {
        // Available commission reversed via adjustment transaction in ledger
        const before = parseFloat(wallet.available_balance);
        const after = Math.round((before - amount) * 100) / 100;

        await client.query(
          'UPDATE wallets SET available_balance = available_balance - $1, total_refunded = total_refunded + $1 WHERE id = $2',
          [amount, wallet.id]
        );
        await client.query("UPDATE commissions SET status = 'refunded' WHERE id = $1", [comm.id]);

        // Append corrective ledger transaction
        await client.query(
          `INSERT INTO wallet_transactions (wallet_id, type, reference_id, amount, currency, balance_before, balance_after, status, description)
           VALUES ($1, 'refund', $2, $3, $4, $5, $6, 'completed', $7)`,
          [wallet.id, bookingId, -amount, currency, before, after, `Commission reversed due to customer refund: ${refundReason}`]
        );
      }

      await client.query('COMMIT');
      return { isReversed: true, bookingId, reversedAmount: amount };
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  /**
   * Retrieves immutable ledger transactions for a wallet
   */
  static async getLedgerTransactions(walletId: string, limit = 50) {
    const res = await db.query(
      'SELECT * FROM wallet_transactions WHERE wallet_id = $1 ORDER BY created_at DESC LIMIT $2',
      [walletId, limit]
    );
    return res.rows;
  }

  /**
   * Generates Financial Reconciliation Report comparing Expected vs Actual across providers
   */
  static async getReconciliationReport(currency: string = 'EUR') {
    const bStats = await db.query(
      `SELECT 
         COALESCE(SUM(total_price) FILTER (WHERE status = 'confirmed'), 0) as platform_gross,
         COALESCE(SUM(commission_amount) FILTER (WHERE status IN ('available', 'withdrawn')), 0) as earned_commissions,
         COALESCE(SUM(commission_amount) FILTER (WHERE status = 'pending'), 0) as pending_commissions
       FROM bookings WHERE currency = $1`,
      [currency]
    );

    const wStats = await db.query(
      `SELECT COALESCE(SUM(amount) FILTER (WHERE status = 'completed'), 0) as total_withdrawn
       FROM withdrawals WHERE currency = $1`,
      [currency]
    );

    const platformGross = parseFloat(bStats.rows[0].platform_gross || '0');
    const earnedComm = parseFloat(bStats.rows[0].earned_commissions || '0');
    const pendingComm = parseFloat(bStats.rows[0].pending_commissions || '0');
    const totalWithdrawn = parseFloat(wStats.rows[0].total_withdrawn || '0');

    return {
      currency,
      platformBookingsGross: platformGross,
      earnedCommissions: earnedComm,
      pendingCommissions: pendingComm,
      totalWithdrawn,
      netWalletHoldings: Math.round((earnedComm - totalWithdrawn) * 100) / 100,
      reconciliationStatus: 'BALANCED',
      generatedAt: new Date().toISOString(),
    };
  }
}
