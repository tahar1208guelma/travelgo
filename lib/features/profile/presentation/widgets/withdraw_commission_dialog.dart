import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class WithdrawCommissionDialog extends StatefulWidget {
  final double availableBalance;
  final ValueChanged<double>? onWithdrawSuccess;

  const WithdrawCommissionDialog({
    super.key,
    required this.availableBalance,
    this.onWithdrawSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    required double availableBalance,
    ValueChanged<double>? onWithdrawSuccess,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => WithdrawCommissionDialog(
        availableBalance: availableBalance,
        onWithdrawSuccess: onWithdrawSuccess,
      ),
    );
  }

  @override
  State<WithdrawCommissionDialog> createState() => _WithdrawCommissionDialogState();
}

class _WithdrawCommissionDialogState extends State<WithdrawCommissionDialog> {
  final _formKey = GlobalKey<FormState>();
  String _selectedMethod = 'Bank Transfer (IBAN/SWIFT)';
  final _amountController = TextEditingController();
  final _accountNameController = TextEditingController(text: 'Tahar Braknia');
  final _ibanController = TextEditingController(text: 'DZ0020001234567890123456');
  final _bankNameController = TextEditingController(text: 'Banque Nationale d\'Algérie (BNA)');
  final _swiftController = TextEditingController(text: 'BNALDZALXXX');
  bool _isSubmitting = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.availableBalance.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountNameController.dispose();
    _ibanController.dispose();
    _bankNameController.dispose();
    _swiftController.dispose();
    super.dispose();
  }

  void _processPayout() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0 || amount > widget.availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid withdrawal amount. Must be between \$1.00 and available balance.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate enterprise payout gateway submission (e.g. Stripe Connect / Bank Wire API)
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _isSuccess = true;
    });

    widget.onWithdrawSuccess?.call(amount);
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Payout Request Initiated!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 8),
              Text(
                'Your withdrawal of \$${_amountController.text} via $_selectedMethod has been dispatched for processing.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.slateBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: AppTheme.accentBlue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Estimated settlement time: 1-2 business days into your designated bank account.',
                        style: TextStyle(fontSize: 11, color: AppTheme.primaryNavy),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.payments, color: AppTheme.accentBlue, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Withdraw Commission',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Transfer your accumulated 0.75% platform commission fees to your corporate bank account or payment provider.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),

                // Balance Info Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.slateBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Available Commission Balance', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                          Text('Ready for payout', style: TextStyle(fontSize: 10, color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text(
                        '\$${widget.availableBalance.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Payout Method Selector
                const Text('Payout Destination', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedMethod,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.slateBackground,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Bank Transfer (IBAN/SWIFT)', child: Text('Bank Transfer (IBAN / SWIFT)')),
                    DropdownMenuItem(value: 'Stripe Connect Direct Payout', child: Text('Stripe Connect (Automated Daily)')),
                    DropdownMenuItem(value: 'Wise Business Transfer', child: Text('Wise Business (Low-fee FX)')),
                    DropdownMenuItem(value: 'Payoneer Multi-Currency', child: Text('Payoneer Business Account')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedMethod = val);
                  },
                ),
                const SizedBox(height: 14),

                // Amount to withdraw
                const Text('Amount to Withdraw (USD)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.attach_money, size: 20, color: AppTheme.accentBlue),
                    filled: true,
                    fillColor: AppTheme.slateBackground,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  validator: (v) {
                    final val = double.tryParse(v ?? '');
                    if (val == null || val <= 0) return 'Enter a valid amount';
                    if (val > widget.availableBalance) return 'Exceeds available balance';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Beneficiary Name
                const Text('Account Holder Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _accountNameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.slateBackground,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),

                // Bank Details
                if (_selectedMethod.contains('Bank') || _selectedMethod.contains('Wise')) ...[
                  const Text('IBAN / Account Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _ibanController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.slateBackground,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Bank Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _bankNameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppTheme.slateBackground,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('SWIFT / BIC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _swiftController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppTheme.slateBackground,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _processPayout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isSubmitting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                              SizedBox(width: 12),
                              Text('Processing Transfer...', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          )
                        : const Text('Confirm & Transfer Funds', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
