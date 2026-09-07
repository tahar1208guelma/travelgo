import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';

class BookingFinancialDetailsSheet extends StatelessWidget {
  final String bookingReference;
  final String? providerReference;
  final double basePrice;
  final double taxes;
  final double commissionRate;
  final double commissionAmount;
  final double totalPrice;
  final String currency;
  final String status;
  final String commissionStatus; // 'pending' | 'available' | 'withdrawn'

  const BookingFinancialDetailsSheet({
    super.key,
    required this.bookingReference,
    this.providerReference,
    required this.basePrice,
    required this.taxes,
    required this.commissionRate,
    required this.commissionAmount,
    required this.totalPrice,
    required this.currency,
    required this.status,
    required this.commissionStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = commissionStatus.toLowerCase() == 'available' || commissionStatus.toLowerCase() == 'withdrawn';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking Financial Audit',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                    ),
                    Text(
                      'Ref: $bookingReference',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isAvailable ? AppTheme.successGreen : AppTheme.warningOrange).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (isAvailable ? AppTheme.successGreen : AppTheme.warningOrange).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAvailable ? Icons.check_circle : Icons.hourglass_top,
                        size: 14,
                        color: isAvailable ? AppTheme.successGreen : AppTheme.warningOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isAvailable ? 'Commission Available' : 'Commission Pending',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isAvailable ? AppTheme.successGreen : AppTheme.warningOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Breakdown Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                children: [
                  _buildRow('Base Fare / Provider Price', CurrencyFormatter.format(basePrice, currency: currency)),
                  const SizedBox(height: 10),
                  _buildRow('Taxes & Airport / Local Fees', CurrencyFormatter.format(taxes, currency: currency)),
                  const SizedBox(height: 10),
                  _buildRow(
                    'TravelGo Commission (${(commissionRate * 100).toStringAsFixed(2)}%)',
                    CurrencyFormatter.format(commissionAmount, currency: currency),
                    isHighlighted: true,
                    highlightColor: AppTheme.accentBlue,
                  ),
                  const Divider(height: 24),
                  _buildRow(
                    'Total Customer Paid',
                    CurrencyFormatter.format(totalPrice, currency: currency),
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Provider reference info
            if (providerReference != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.confirmation_number_outlined, size: 20, color: AppTheme.accentBlue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Provider Confirmation Reference (PNR/Voucher)', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                          Text(providerReference!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Lifecycle explanation banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, size: 18, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Commission Security Protocol: Earnings are held in Pending status until the flight/hotel provider confirms booking and issues tickets. Once confirmed, funds automatically move to your Available Wallet for bank withdrawal.',
                      style: TextStyle(fontSize: 11, color: Colors.brown, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, bool isHighlighted = false, Color? highlightColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppTheme.primaryNavy : AppTheme.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: (isBold || isHighlighted) ? FontWeight.bold : FontWeight.w600,
            color: highlightColor ?? (isBold ? AppTheme.primaryNavy : Colors.black87),
          ),
        ),
      ],
    );
  }
}
