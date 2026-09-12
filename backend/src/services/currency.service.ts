import { db } from '../config/database';

export interface CurrencyRate {
  code: string;
  name: string;
  symbol: string;
  rateToUsd: number;
}

export class CurrencyService {
  private static ratesCache: Map<string, CurrencyRate> = new Map();
  private static lastUpdate = 0;
  private static readonly TTL_MS = 5 * 60 * 1000; // 5 minutes

  /**
   * Initializes and retrieves all active currencies
   */
  static async getCurrencies(): Promise<CurrencyRate[]> {
    const now = Date.now();
    if (this.ratesCache.size > 0 && now - this.lastUpdate < this.TTL_MS) {
      return Array.from(this.ratesCache.values());
    }

    try {
      const res = await db.query('SELECT code, name, symbol, exchange_rate_to_usd FROM currencies WHERE is_active = TRUE');
      if (res.rows.length > 0) {
        this.ratesCache.clear();
        res.rows.forEach((r) => {
          this.ratesCache.set(r.code, {
            code: r.code,
            name: r.name,
            symbol: r.symbol,
            rateToUsd: parseFloat(r.exchange_rate_to_usd),
          });
        });
        this.lastUpdate = now;
        return Array.from(this.ratesCache.values());
      }
    } catch (err) {
      // Fallback below
    }

    // Default static fallback if DB unseeded
    return [
      { code: 'USD', name: 'US Dollar', symbol: '$', rateToUsd: 1.0 },
      { code: 'EUR', name: 'Euro', symbol: '€', rateToUsd: 0.92 },
      { code: 'DZD', name: 'Algerian Dinar', symbol: 'DA', rateToUsd: 134.5 },
      { code: 'GBP', name: 'British Pound', symbol: '£', rateToUsd: 0.79 },
    ];
  }

  /**
   * Converts an amount between any two supported currencies
   */
  static async convert(amount: number, fromCurrency: string, toCurrency: string): Promise<number> {
    if (fromCurrency === toCurrency) return amount;
    const currencies = await this.getCurrencies();
    const from = currencies.find((c) => c.code === fromCurrency) || { rateToUsd: 1.0 };
    const to = currencies.find((c) => c.code === toCurrency) || { rateToUsd: 1.0 };

    // Amount in USD = amount / from.rateToUsd
    const inUsd = amount / from.rateToUsd;
    // Target amount = inUsd * to.rateToUsd
    const converted = inUsd * to.rateToUsd;
    return Math.round(converted * 100) / 100;
  }
}
