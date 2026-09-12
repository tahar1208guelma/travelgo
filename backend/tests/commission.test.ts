import { CommissionService } from '../src/services/commission.service';
import { db } from '../src/config/database';

jest.mock('../src/config/database', () => ({
  db: {
    query: jest.fn(),
  },
}));

describe('CommissionService Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('calculates 0.75% commission precisely on 100 EUR', async () => {
    (db.query as jest.Mock).mockResolvedValue({ rows: [{ value: '0.0075' }] });
    // Base = 100 EUR, Commission = 0.75 EUR, Taxes = 20 EUR, Total = 120.75 EUR
    const result = await CommissionService.calculate(100.0, 20.0, 'EUR');
    expect(result.basePrice).toBe(100.0);
    expect(result.commissionAmount).toBe(0.75);
    expect(result.taxes).toBe(20.0);
    expect(result.totalPrice).toBe(120.75);
    expect(result.currency).toBe('EUR');
  });

  it('handles multi-passenger fares correctly', async () => {
    (db.query as jest.Mock).mockResolvedValue({ rows: [{ value: '0.0075' }] });
    // 3 passengers at 250 USD each = 750 USD base. 0.75% of 750 = 5.625 -> 5.63 USD
    const result = await CommissionService.calculate(750.0, 126.0, 'USD');
    expect(result.commissionAmount).toBe(5.63);
    expect(result.totalPrice).toBe(750.0 + 126.0 + 5.63);
  });
});
