import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';

class WithdrawalRequestModal extends StatefulWidget {
  final Map<String, double> availableBalances; // e.g. {'EUR': 125.50, 'USD': 80.00, 'DZD': 24500.0, 'GBP': 65.0}
  final List<Map<String, dynamic>> bankAccounts;
  final Function(String currency, double amount, String bankAccountId) onRequestSubmitted;

  const WithdrawalRequestModal({
    super.key,
    required this.availableBalances,
    required this.bankAccounts,
    required this.onRequestSubmitted,
  });

  @override
  State<WithdrawalRequestModal> createState() => _WithdrawalRequestModalState();
}

class _WithdrawalRequestModalState extends State<WithdrawalRequestModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  late String _selectedCurrency;
  String? _selectedBankAccountId;
  bool _isSubmitting = false;

  // Minimum withdrawal limits
  final Map<String, double> _minLimits = {
    'EUR': 50.0,
    'USD': 50.0,
    'DZD': 6500.0,
    'GBP': 40.0,
  };

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.availableBalances.keys.firstWhere(
      (c) => (widget.availableBalances[c] ?? 0.0) > 0,
      orElse: () => 'EUR',
    );

    if (widget.bankAccounts.isNotEmpty) {
      _selectedBankAccountId = widget.bankAccounts.first['id'];
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _availableBalance => widget.availableBalances[_selectedCurrency] ?? 0.0;
  double get _minLimit => _minLimits[_selectedCurrency] ?? 50.0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 480),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.account_balance, color: AppTheme.accentBlue, size: 22),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Request Commission Payout',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Withdraw confirmed platform commissions directly to your verified bank account.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 20),

                // Currency Selector
                const Text('Payout Currency (Strict Currency Isolation)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCurrency,
                      isExpanded: true,
                      items: widget.availableBalances.keys.map((cur) {
                        final bal = widget.availableBalances[cur] ?? 0.0;
                        return DropdownMenuItem<String>(
                          value: cur,
                          child: Row(
                            children: [
                              Text(cur, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Text(
                                'Available: ${CurrencyFormatter.format(bal, currency: cur)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: bal >= (_minLimits[cur] ?? 0.0) ? AppTheme.successGreen : AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCurrency = val;
                            _amountController.clear();
                          });
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Available balance & minimum info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Available to Withdraw', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            Text(
                              CurrencyFormatter.format(_availableBalance, currency: _selectedCurrency),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.accentBlue),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Minimum Threshold', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                          Text(
                            CurrencyFormatter.format(_minLimit, currency: _selectedCurrency),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Amount Field
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Withdrawal Amount ($_selectedCurrency)',
                    hintText: 'Enter amount (e.g. ${_minLimit.toStringAsFixed(0)})',
                    prefixIcon: const Icon(Icons.payments_outlined),
                    suffixIcon: TextButton(
                      onPressed: () {
                        setState(() {
                          _amountController.text = _availableBalance.toStringAsFixed(2);
                        });
                      },
                      child: const Text('MAX', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentBlue)),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amt = double.tryParse(val.trim());
                    if (amt == null || amt <= 0) {
                      return 'Enter a valid positive number';
                    }
                    if (amt < _minLimit) {
                      return 'Minimum withdrawal for $_selectedCurrency is ${CurrencyFormatter.format(_minLimit, currency: _selectedCurrency)}';
                    }
                    if (amt > _availableBalance) {
                      return 'Amount exceeds available balance (${CurrencyFormatter.format(_availableBalance, currency: _selectedCurrency)})';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Bank Account Selection
                const Text('Destination Bank Account', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (widget.bankAccounts.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No bank accounts registered. Please register your bank details first.',
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedBankAccountId,
                        isExpanded: true,
                        itemHeight: 56,
                        items: widget.bankAccounts.map((b) {
                          return DropdownMenuItem<String>(
                            value: b['id'],
                            child: Text(
                              '${b["bankName"]} • ${b["maskedIban"]} (${b["country"]})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedBankAccountId = val);
                          }
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Payout Disclaimers & Fee Note
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Text('Platform Payout Fee:', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ),
                      Text('0.00% (FREE for Merchant)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.successGreen)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting || widget.bankAccounts.isEmpty || _availableBalance < _minLimit
                            ? null
                            : () async {
                                if (_formKey.currentState?.validate() ?? false) {
                                  setState(() => _isSubmitting = true);
                                  final amt = double.parse(_amountController.text.trim());
                                  widget.onRequestSubmitted(_selectedCurrency, amt, _selectedBankAccountId!);
                                  Navigator.of(context).pop();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Submit Payout Request', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
