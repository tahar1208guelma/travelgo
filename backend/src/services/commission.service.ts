import { db } from '../config/database';
import { ENV } from '../config/env';

export interface CommissionCalculationResult {
  basePrice: number;
  commissionRate: number; // e.g. 0.0075 for 0.75%
  commissionAmount: number; // basePrice * commissionRate
  taxes: number;
  totalPrice: number; // basePrice + commissionAmount + taxes
  currency: string;
}

export class CommissionService {
  private static cachedRate: number | null = null;
  private static lastFetchTime = 0;
  private static readonly CACHE_TTL_MS = 60000; // 1 minute cache

  /**
   * Retrieves dynamic commission rate from Admin Settings in Database
   * Defaults to ENV.COMMISSION_RATE (0.0075 = 0.75%) if DB is initializing
   */
  static async getCommissionRate(): Promise<number> {
    const now = Date.now();
    if (this.cachedRate !== null && now - this.lastFetchTime < this.CACHE_TTL_MS) {
      return this.cachedRate;
    }

    try {
      const res = await db.query('SELECT value FROM settings WHERE key = $1', ['commission_rate']);
      if (res.rows.length > 0) {
        const rate = parseFloat(res.rows[0].value);
        if (!isNaN(rate) && rate >= 0 && rate <= 0.5) {
          this.cachedRate = rate;
          this.lastFetchTime = now;
          return rate;
        }
      }
    } catch (err) {
      // Fallback to environment default if DB read fails
    }

    return ENV.COMMISSION_RATE; // 0.0075
  }

  /**
   * Updates commission rate in Database Admin Settings
   */
  static async updateCommissionRate(newRate: number, adminUserId?: string): Promise<void> {
    if (newRate < 0 || newRate > 0.5) {
      throw new Error('Commission rate must be between 0.0% (0.0) and 50.0% (0.50)');
    }

    await db.query(
      `INSERT INTO settings (key, value, description, updated_by, updated_at)
       VALUES ('commission_rate', $1, 'TravelGo platform service fee percentage', $2, CURRENT_TIMESTAMP)
       ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_by = EXCLUDED.updated_by, updated_at = CURRENT_TIMESTAMP`,
      [newRate.toString(), adminUserId || null]
    );

    this.cachedRate = newRate;
    this.lastFetchTime = Date.now();
  }

  /**
   * Calculates platform commission and final total breakdown strictly on the Backend
   */
  static async calculate(basePrice: number, taxes: number = 0, currency: string = 'USD'): Promise<CommissionCalculationResult> {
    const rate = await this.getCommissionRate();
    const rawCommission = basePrice * rate;
    const commissionAmount = Math.round(rawCommission * 100) / 100; // 2 decimal precision
    const totalPrice = Math.round((basePrice + taxes + commissionAmount) * 100) / 100;

    return {
      basePrice: Math.round(basePrice * 100) / 100,
      commissionRate: rate,
      commissionAmount,
      taxes: Math.round(taxes * 100) / 100,
      totalPrice,
      currency,
    };
  }
}
