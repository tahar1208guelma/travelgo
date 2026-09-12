import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../models/price_breakdown.dart';

class PriceSummaryCard extends StatelessWidget {
  final PriceBreakdown price;

  const PriceSummaryCard({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.receipt_long_outlined, color: AppTheme.accentBlue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Price Breakdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: AppTheme.borderSubtle),
            _buildPriceRow(
              'Base Price',
              CurrencyFormatter.format(price.basePrice, currency: price.currency),
            ),
            if (price.hasServiceFee)
              _buildPriceRow(
                'TRAVELGO Platform Fee (0.75%)',
                CurrencyFormatter.format(price.serviceFee!, currency: price.currency),
                color: AppTheme.accentBlue,
              ),
            if (price.hasTaxesAndFees)
              _buildPriceRow(
                'Taxes & Charges',
                CurrencyFormatter.format(price.taxesAndFees!, currency: price.currency),
              ),
            if (price.hasDiscount)
              _buildPriceRow(
                'Discount',
                '-${CurrencyFormatter.format(price.discount!, currency: price.currency)}',
                color: AppTheme.successGreen,
              ),
            const Divider(height: 20, color: AppTheme.borderSubtle),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(price.totalAmount, currency: price.currency),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textMuted)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color ?? AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
