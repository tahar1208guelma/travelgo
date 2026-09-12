import { Router, Request, Response, NextFunction } from 'express';
import { FinanceService } from './finance.service';
import { WithdrawalService } from './withdrawal.service';
import { authenticateJwt, requireRole } from '../auth/auth.middleware';
import { db } from '../config/database';

export const financeRouter = Router();

// Protect all finance endpoints: must be authenticated admin
financeRouter.use(authenticateJwt);
financeRouter.use(requireRole('admin'));

// Helper to resolve owner ID from authenticated user or fallback to seeded owner
const getOwnerId = (req: Request): string => {
  return req.user?.userId || '00000000-0000-0000-0000-000000000001';
};

/**
 * GET /admin/finance/wallets
 * Multi-currency wallets overview (EUR, USD, DZD, GBP)
 */
financeRouter.get('/wallets', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const ownerId = getOwnerId(req);
    const wallets = await FinanceService.getAllOwnerWallets(ownerId);
    res.json({ success: true, data: wallets });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /admin/finance/wallets/:currency
 * Single currency wallet
 */
financeRouter.get('/wallets/:currency', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const ownerId = getOwnerId(req);
    const wallet = await FinanceService.getOrCreateWallet(ownerId, req.params.currency);
    res.json({ success: true, data: wallet });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /admin/finance/transactions
 * Immutable Financial Ledger transactions
 */
financeRouter.get('/transactions', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { walletId, currency, limit = '50' } = req.query;
    let targetWalletId = walletId as string;

    if (!targetWalletId) {
      const ownerId = getOwnerId(req);
      const cur = (currency as string) || 'EUR';
      const w = await FinanceService.getOrCreateWallet(ownerId, cur);
      targetWalletId = w.walletId;
    }

    const txs = await FinanceService.getLedgerTransactions(targetWalletId, parseInt(limit as string, 10));
    res.json({ success: true, data: txs });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /admin/finance/commissions
 * Commissions lifecycle list with timeline analytics
 */
financeRouter.get('/commissions', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { status, period, limit = '50', offset = '0' } = req.query;
    let query = `
      SELECT c.*, b.booking_reference, b.booking_type, b.total_price, b.customer_name, b.status as booking_status
      FROM commissions c
      LEFT JOIN bookings b ON c.booking_id = b.id
    `;
    const params: any[] = [];

    const conditions: string[] = [];
    if (status) {
      conditions.push(`c.status = $${params.length + 1}`);
      params.push(status);
    }

    if (period === 'today') {
      conditions.push(`c.created_at >= CURRENT_DATE`);
    } else if (period === 'week') {
      conditions.push(`c.created_at >= CURRENT_DATE - INTERVAL '7 days'`);
    } else if (period === 'month') {
      conditions.push(`c.created_at >= CURRENT_DATE - INTERVAL '30 days'`);
    }

    if (conditions.length > 0) {
      query += ` WHERE ${conditions.join(' AND ')}`;
    }

    query += ` ORDER BY c.created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(parseInt(limit as string, 10), parseInt(offset as string, 10));

    const resComms = await db.query(query, params);

    // Period summary stats
    const statsRes = await db.query(`
      SELECT 
        currency,
        COALESCE(SUM(commission_amount) FILTER (WHERE created_at >= CURRENT_DATE), 0) as today,
        COALESCE(SUM(commission_amount) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'), 0) as week,
        COALESCE(SUM(commission_amount) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'), 0) as month,
        COALESCE(SUM(commission_amount), 0) as all_time,
        COALESCE(SUM(commission_amount) FILTER (WHERE status = 'pending'), 0) as pending_total,
        COALESCE(SUM(commission_amount) FILTER (WHERE status = 'available'), 0) as available_total
      FROM commissions
      GROUP BY currency
    `);

    res.json({
      success: true,
      data: {
        commissions: resComms.rows,
        summaryByCurrency: statsRes.rows,
      },
    });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /admin/finance/commissions/:bookingId/release
 * Step 6: Releases pending commission to available balance upon provider confirmation
 */
financeRouter.post('/commissions/:bookingId/release', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const ownerId = getOwnerId(req);
    const result = await FinanceService.releaseCommissionToAvailable(ownerId, req.params.bookingId);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /admin/finance/withdrawals
 * List withdrawal requests
 */
financeRouter.get('/withdrawals', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const limit = parseInt(req.query.limit as string || '50', 10);
    const offset = parseInt(req.query.offset as string || '0', 10);
    const withdrawals = await WithdrawalService.getWithdrawals(undefined, limit, offset);
    res.json({ success: true, data: withdrawals });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /admin/finance/withdrawals
 * Step 7: Request a withdrawal
 */
financeRouter.post('/withdrawals', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const ownerId = getOwnerId(req);
    const { amount, currency, bankAccountId } = req.body;
    if (!amount || !currency) {
      return res.status(400).json({ success: false, error: 'amount and currency are required' });
    }

    const withdrawal = await WithdrawalService.requestWithdrawal(
      ownerId,
      parseFloat(amount),
      currency,
      bankAccountId
    );
    res.status(201).json({ success: true, data: withdrawal });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /admin/finance/withdrawals/:id
 */
financeRouter.get('/withdrawals/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const withdrawal = await WithdrawalService.getWithdrawalById(req.params.id);
    res.json({ success: true, data: withdrawal });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /admin/finance/withdrawals/:id/approve
 * Step 8: Admin approval
 */
financeRouter.post('/withdrawals/:id/approve', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const adminId = getOwnerId(req);
    const result = await WithdrawalService.approveWithdrawal(req.params.id, adminId);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /admin/finance/withdrawals/:id/process
 * Step 9: Bank payout execution via payout provider
 */
financeRouter.post('/withdrawals/:id/process', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const adminId = getOwnerId(req);
    const result = await WithdrawalService.processPayout(req.params.id, adminId);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /admin/finance/withdrawals/:id/complete
 * Step 10: Final completion with bank transfer reference
 */
financeRouter.post('/withdrawals/:id/complete', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const adminId = getOwnerId(req);
    const { bankTransferReference } = req.body;
    const result = await WithdrawalService.completeWithdrawal(req.params.id, bankTransferReference, adminId);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /admin/finance/withdrawals/:id/reject
 * Reject withdrawal and refund funds to available balance
 */
financeRouter.post('/withdrawals/:id/reject', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const adminId = getOwnerId(req);
    const { reason } = req.body;
    if (!reason) {
      return res.status(400).json({ success: false, error: 'Rejection reason is required' });
    }
    const result = await WithdrawalService.rejectWithdrawal(req.params.id, reason, adminId);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /admin/finance/withdrawals/:id/receipt
 * Official PDF Withdrawal Receipt metadata
 */
financeRouter.get('/withdrawals/:id/receipt', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const receipt = await WithdrawalService.generateReceipt(req.params.id);
    res.json({ success: true, data: receipt });
  } catch (err) {
    next(err);
  }
});

/**
 * Bank Accounts Management
 */
financeRouter.get('/bank-accounts', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const ownerId = getOwnerId(req);
    const accounts = await WithdrawalService.getBankAccounts(ownerId);
    res.json({ success: true, data: accounts });
  } catch (err) {
    next(err);
  }
});

financeRouter.post('/bank-accounts', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const ownerId = getOwnerId(req);
    const account = await WithdrawalService.addBankAccount(ownerId, req.body);
    res.status(201).json({ success: true, data: account });
  } catch (err) {
    next(err);
  }
});

financeRouter.delete('/bank-accounts/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const ownerId = getOwnerId(req);
    const result = await WithdrawalService.deleteBankAccount(req.params.id, ownerId);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /admin/finance/reconciliation
 * Audit reconciliation across Bookings, Commissions, and Payouts
 */
financeRouter.get('/reconciliation', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const cur = (req.query.currency as string) || 'EUR';
    const report = await FinanceService.getReconciliationReport(cur);
    res.json({ success: true, data: report });
  } catch (err) {
    next(err);
  }
});
