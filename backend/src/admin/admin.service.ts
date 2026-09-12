import { db } from '../config/database';
import { CommissionService } from '../services/commission.service';
import { AuditService } from '../services/audit.service';
import { FinanceService } from '../finance/finance.service';

export class AdminService {
  static async getDashboardMetrics() {
    // 1. Bookings breakdown
    const bStats = await db.query(`
      SELECT 
        COUNT(*) as total_bookings,
        COUNT(*) FILTER (WHERE status = 'confirmed') as confirmed_bookings,
        COUNT(*) FILTER (WHERE status = 'cancelled') as cancelled_bookings,
        COALESCE(SUM(total_price) FILTER (WHERE status = 'confirmed'), 0) as total_revenue,
        COALESCE(SUM(commission_amount) FILTER (WHERE status = 'confirmed'), 0) as total_commission
      FROM bookings
    `);

    // 2. Users count
    const uStats = await db.query('SELECT COUNT(*) as total_users FROM users');

    // 3. Searches count for conversion rate calculation
    const sStats = await db.query('SELECT COUNT(*) as total_searches FROM flight_searches');

    const totalBookings = parseInt(bStats.rows[0].total_bookings || '0', 10);
    const confirmedBookings = parseInt(bStats.rows[0].confirmed_bookings || '0', 10);
    const cancelledBookings = parseInt(bStats.rows[0].cancelled_bookings || '0', 10);
    const totalRevenue = parseFloat(bStats.rows[0].total_revenue || '0');
    const totalCommission = parseFloat(bStats.rows[0].total_commission || '0');
    const totalUsers = parseInt(uStats.rows[0].total_users || '0', 10);
    const totalSearches = parseInt(sStats.rows[0].total_searches || '0', 10);

    const conversionRate = totalSearches > 0 
      ? Math.round((confirmedBookings / totalSearches) * 10000) / 100 
      : (totalBookings > 0 ? Math.round((confirmedBookings / totalBookings) * 10000) / 100 : 0);

    // Current commission rate
    const currentCommissionRate = await CommissionService.getCommissionRate();

    // Providers status
    const pStats = await db.query('SELECT id, name, type, is_active, is_demo FROM providers ORDER BY type, name');

    return {
      kpi: {
        totalBookings,
        confirmedBookings,
        cancelledBookings,
        totalRevenue: Math.round(totalRevenue * 100) / 100,
        totalCommission: Math.round(totalCommission * 100) / 100,
        totalUsers,
        conversionRatePercent: conversionRate,
        currentCommissionRate: currentCommissionRate * 100, // as percentage (0.75%)
      },
      providers: pStats.rows,
    };
  }

  static async getAllBookings(limit = 50, offset = 0) {
    const res = await db.query(
      `SELECT b.*, u.email as user_email, u.first_name, u.last_name
       FROM bookings b
       LEFT JOIN users u ON b.user_id = u.id
       ORDER BY b.created_at DESC
       LIMIT $1 OFFSET $2`,
      [limit, offset]
    );
    return res.rows;
  }

  static async getAllUsers(limit = 50, offset = 0) {
    const res = await db.query(
      `SELECT id, email, first_name, last_name, phone, country, is_active, created_at
       FROM users
       ORDER BY created_at DESC
       LIMIT $1 OFFSET $2`,
      [limit, offset]
    );
    return res.rows;
  }

  static async updateCommissionRate(ratePercentage: number, adminUserId?: string) {
    // ratePercentage e.g. 0.75 or 1.2
    const decimalRate = ratePercentage / 100;
    await CommissionService.updateCommissionRate(decimalRate, adminUserId);
    await AuditService.log('COMMISSION_RATE_UPDATED', 'settings', 'commission_rate', adminUserId, { newRate: ratePercentage });
    return { commissionRatePercent: ratePercentage, commissionRateDecimal: decimalRate };
  }

  static async toggleProvider(providerId: string, isActive: boolean, adminUserId?: string) {
    await db.query('UPDATE providers SET is_active = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2', [isActive, providerId]);
    await AuditService.log('PROVIDER_TOGGLED', 'providers', providerId, adminUserId, { isActive });
    return { providerId, isActive };
  }

  static async issueRefund(bookingId: string, amount: number, reason: string, adminUserId?: string) {
    const res = await db.query('SELECT * FROM bookings WHERE id = $1', [bookingId]);
    if (res.rows.length === 0) throw new Error('Booking not found');
    const booking = res.rows[0];

    const refundRes = await db.query(
      `INSERT INTO refunds (booking_id, amount, currency, reason, status, processed_by)
       VALUES ($1, $2, $3, $4, 'completed', $5) RETURNING id`,
      [bookingId, amount, booking.currency, reason, adminUserId || null]
    );

    await db.query(`UPDATE bookings SET status = 'refunded', updated_at = CURRENT_TIMESTAMP WHERE id = $1`, [bookingId]);
    await AuditService.log('REFUND_ISSUED', 'refunds', refundRes.rows[0].id, adminUserId, { bookingId, amount });

    // Reversal of merchant commission: cancels pending commission or writes adjustment to ledger
    const ownerId = '00000000-0000-0000-0000-000000000001';
    await FinanceService.handleBookingRefund(ownerId, bookingId, reason);

    return { refundId: refundRes.rows[0].id, bookingId, status: 'refunded' };
  }

  static async getAuditLogs(limit = 50) {
    const res = await db.query('SELECT * FROM audit_logs ORDER BY created_at DESC LIMIT $1', [limit]);
    return res.rows;
  }
}
