import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/print_service.dart';
import 'withdrawal_request_modal.dart';
import 'booking_financial_details_sheet.dart';

class AdminFinanceScreen extends StatefulWidget {
  const AdminFinanceScreen({super.key});

  @override
  State<AdminFinanceScreen> createState() => _AdminFinanceScreenState();
}

class _AdminFinanceScreenState extends State<AdminFinanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PdfService _pdfService = PdfService();
  final PrintService _printService = PrintService();

  // Multi-Currency Isolated Wallets State
  final Map<String, Map<String, double>> _wallets = {
    'EUR': {
      'available': 125.50,
      'pending': 32.40,
      'earned': 1580.75,
      'withdrawn': 1422.85,
    },
    'USD': {
      'available': 80.00,
      'pending': 15.20,
      'earned': 950.00,
      'withdrawn': 854.80,
    },
    'DZD': {
      'available': 24500.00,
      'pending': 6800.00,
      'earned': 185000.00,
      'withdrawn': 153700.00,
    },
    'GBP': {
      'available': 65.00,
      'pending': 0.00,
      'earned': 420.00,
      'withdrawn': 355.00,
    },
  };

  // Bank Accounts (Masked IBAN)
  final List<Map<String, dynamic>> _bankAccounts = [
    {
      'id': 'bank-dz-01',
      'bankName': 'Société Générale Algérie',
      'accountHolderName': 'TravelGo Global Ltd / Platform Owner',
      'iban': 'DZ5002100012345678901234',
      'maskedIban': 'DZ****1234',
      'swiftBic': 'SGEADZAL',
      'country': 'Algeria',
      'isPrimary': true,
    },
    {
      'id': 'bank-fr-02',
      'bankName': 'BNP Paribas International',
      'accountHolderName': 'TravelGo Global Settlement Corp',
      'iban': 'FR7630006000011234567890189',
      'maskedIban': 'FR****0189',
      'swiftBic': 'BNPAFR22',
      'country': 'France (SEPA)',
      'isPrimary': false,
    },
  ];

  // Withdrawals Registry
  final List<Map<String, dynamic>> _withdrawals = [
    {
      'id': 'with-89412',
      'amount': 250.00,
      'currency': 'EUR',
      'status': 'completed',
      'bankName': 'BNP Paribas International',
      'accountHolderName': 'TravelGo Global Settlement Corp',
      'maskedIban': 'FR****0189',
      'swiftBic': 'BNPAFR22',
      'bankTransferReference': 'WIRE-TG-84920194',
      'requestedAt': DateTime.now().subtract(const Duration(days: 3)),
      'processedAt': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': 'with-89411',
      'amount': 65000.00,
      'currency': 'DZD',
      'status': 'completed',
      'bankName': 'Société Générale Algérie',
      'accountHolderName': 'TravelGo Global Ltd / Platform Owner',
      'maskedIban': 'DZ****1234',
      'swiftBic': 'SGEADZAL',
      'bankTransferReference': 'WIRE-TG-77301942',
      'requestedAt': DateTime.now().subtract(const Duration(days: 7)),
      'processedAt': DateTime.now().subtract(const Duration(days: 6)),
    },
    {
      'id': 'with-89410',
      'amount': 100.00,
      'currency': 'EUR',
      'status': 'processing',
      'bankName': 'BNP Paribas International',
      'accountHolderName': 'TravelGo Global Settlement Corp',
      'maskedIban': 'FR****0189',
      'swiftBic': 'BNPAFR22',
      'bankTransferReference': 'WIRE-TG-99014522',
      'requestedAt': DateTime.now().subtract(const Duration(hours: 14)),
      'processedAt': null,
    },
  ];

  // Immutable Financial Ledger Transactions
  final List<Map<String, dynamic>> _ledger = [
    {
      'id': 'tx-1008',
      'type': 'commission',
      'referenceId': 'BK-AH-84920',
      'amount': 2.40,
      'currency': 'EUR',
      'balanceBefore': 123.10,
      'balanceAfter': 125.50,
      'status': 'completed',
      'description': 'TravelGo Platform Commission 0.75% for Flight Booking BK-AH-84920 (Released after PNR issuance)',
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': 'tx-1007',
      'type': 'withdrawal',
      'referenceId': 'with-89410',
      'amount': -100.00,
      'currency': 'EUR',
      'balanceBefore': 223.10,
      'balanceAfter': 123.10,
      'status': 'completed',
      'description': 'Bank Wire Transfer Withdrawal #with-89410 to BNP Paribas (FR****0189)',
      'createdAt': DateTime.now().subtract(const Duration(hours: 14)),
    },
    {
      'id': 'tx-1006',
      'type': 'commission',
      'referenceId': 'BK-HOTEL-5502',
      'amount': 4.50,
      'currency': 'EUR',
      'balanceBefore': 218.60,
      'balanceAfter': 223.10,
      'status': 'completed',
      'description': 'TravelGo Platform Commission 0.75% for Hotel Booking BK-HOTEL-5502 (Released after Voucher issuance)',
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': 'tx-1005',
      'type': 'commission',
      'referenceId': 'BK-DZD-3301',
      'amount': 900.00,
      'currency': 'DZD',
      'balanceBefore': 23600.00,
      'balanceAfter': 24500.00,
      'status': 'completed',
      'description': 'TravelGo Commission 0.75% for Booking BK-DZD-3301',
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
    },
  ];

  // Recent Commission Entries (Tracking 9-stage lifecycle)
  final List<Map<String, dynamic>> _commissions = [
    {
      'bookingReference': 'BK-AH-84920',
      'providerReference': 'AH-ALG-CDG-771',
      'basePrice': 320.00,
      'taxes': 45.00,
      'commissionRate': 0.0075,
      'commissionAmount': 2.40,
      'totalPrice': 367.40,
      'currency': 'EUR',
      'bookingStatus': 'confirmed',
      'commissionStatus': 'available',
      'bookingType': 'Flight (Air Algérie ALG ➔ CDG)',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'bookingReference': 'BK-HOTEL-5502',
      'providerReference': 'VCH-HOTEL-PARIS-99',
      'basePrice': 600.00,
      'taxes': 60.00,
      'commissionRate': 0.0075,
      'commissionAmount': 4.50,
      'totalPrice': 664.50,
      'currency': 'EUR',
      'bookingStatus': 'confirmed',
      'commissionStatus': 'available',
      'bookingType': 'Hotel (Hôtel Plaza Athénée, Paris)',
      'date': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'bookingReference': 'BK-TK-90214',
      'providerReference': null,
      'basePrice': 4320.00,
      'taxes': 280.00,
      'commissionRate': 0.0075,
      'commissionAmount': 32.40,
      'totalPrice': 4632.40,
      'currency': 'EUR',
      'bookingStatus': 'paid',
      'commissionStatus': 'pending',
      'bookingType': 'Flight (Turkish Airlines ALG ➔ IST)',
      'date': DateTime.now().subtract(const Duration(minutes: 45)),
    },
    {
      'bookingReference': 'BK-DZD-3301',
      'providerReference': 'AH-DZD-8812',
      'basePrice': 120000.00,
      'taxes': 15000.00,
      'commissionRate': 0.0075,
      'commissionAmount': 900.00,
      'totalPrice': 135900.00,
      'currency': 'DZD',
      'bookingStatus': 'confirmed',
      'commissionStatus': 'available',
      'bookingType': 'Flight (Air Algérie ALG ➔ ORN)',
      'date': DateTime.now().subtract(const Duration(days: 1)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleWithdrawalSubmitted(String currency, double amount, String bankAccountId) {
    final bank = _bankAccounts.firstWhere((b) => b['id'] == bankAccountId);

    setState(() {
      // Deduct from available balance
      final currentAvail = _wallets[currency]?['available'] ?? 0.0;
      _wallets[currency]?['available'] = (currentAvail - amount);

      final newWith = {
        'id': 'with-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        'amount': amount,
        'currency': currency,
        'status': 'pending',
        'bankName': bank['bankName'],
        'accountHolderName': bank['accountHolderName'],
        'maskedIban': bank['maskedIban'],
        'swiftBic': bank['swiftBic'],
        'bankTransferReference': 'PENDING_DISPATCH',
        'requestedAt': DateTime.now(),
        'processedAt': null,
      };

      _withdrawals.insert(0, newWith);

      // Append to immutable ledger
      _ledger.insert(0, {
        'id': 'tx-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        'type': 'withdrawal',
        'referenceId': newWith['id'],
        'amount': -amount,
        'currency': currency,
        'balanceBefore': currentAvail,
        'balanceAfter': currentAvail - amount,
        'status': 'pending',
        'description': 'Payout Request #${newWith["id"]} to ${bank["bankName"]} (${bank["maskedIban"]})',
        'createdAt': DateTime.now(),
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.successGreen,
        content: Text(
          'Withdrawal request for ${CurrencyFormatter.format(amount, currency: currency)} successfully submitted for bank payout!',
        ),
      ),
    );
  }

  void _showAddBankAccountDialog() {
    final holderCtrl = TextEditingController();
    final bankCtrl = TextEditingController();
    final ibanCtrl = TextEditingController();
    final swiftCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.account_balance, color: AppTheme.accentBlue),
            SizedBox(width: 8),
            Text('Register Bank Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add a verified business account for receiving 0.75% commission payouts.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: holderCtrl,
                  decoration: const InputDecoration(labelText: 'Account Holder Name', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: bankCtrl,
                  decoration: const InputDecoration(labelText: 'Bank Name (e.g. Société Générale, BEA)', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ibanCtrl,
                  decoration: const InputDecoration(labelText: 'IBAN / RIB Account Number', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().length < 10) ? 'Enter valid IBAN/RIB' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: swiftCtrl,
                  decoration: const InputDecoration(labelText: 'SWIFT / BIC Code', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final rawIban = ibanCtrl.text.trim();
                final masked = rawIban.length >= 6 ? '${rawIban.substring(0, 2)}****${rawIban.substring(rawIban.length - 4)}' : '****';
                setState(() {
                  _bankAccounts.add({
                    'id': 'bank-${DateTime.now().millisecondsSinceEpoch}',
                    'bankName': bankCtrl.text.trim(),
                    'accountHolderName': holderCtrl.text.trim(),
                    'iban': rawIban,
                    'maskedIban': masked,
                    'swiftBic': swiftCtrl.text.trim().toUpperCase(),
                    'country': 'Algeria / International',
                    'isPrimary': false,
                  });
                });
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bank account registered successfully.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentBlue, foregroundColor: Colors.white),
            child: const Text('Save Bank Account'),
          ),
        ],
      ),
    );
  }

  void _showBankAccountsModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Registered Bank Accounts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppTheme.accentBlue),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _showAddBankAccountDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              itemCount: _bankAccounts.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (c, idx) {
                final b = _bankAccounts[idx];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.electricCyan,
                    foregroundColor: Colors.white,
                    child: Icon(Icons.account_balance, size: 20),
                  ),
                  title: Text('${b["bankName"]} • ${b["maskedIban"]}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('${b["accountHolderName"]} • SWIFT: ${b["swiftBic"]}'),
                  trailing: b['isPrimary'] == true
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppTheme.successGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                          child: const Text('Primary', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.successGreen)),
                        )
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReconciliationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.balance, color: AppTheme.successGreen),
            SizedBox(width: 8),
            Text('Financial Reconciliation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppTheme.successGreen.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: AppTheme.successGreen, size: 16),
                  SizedBox(width: 6),
                  Text('STATUS: FULLY BALANCED (Zero Discrepancy)', style: TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Audit Comparison for Current Period (EUR):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            _buildRecRow('Total Platform Bookings Gross:', '€ 210,766.60'),
            _buildRecRow('Platform Commissions (0.75%):', '€ 1,580.75'),
            _buildRecRow('Total Disbursed Bank Payouts:', '€ 1,422.85'),
            _buildRecRow('Pending Provider Confirmation:', '€ 32.40'),
            const Divider(height: 16),
            _buildRecRow('Net Active Wallet Available:', '€ 125.50', isBold: true),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white),
            child: const Text('Dismiss Audit'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecRow(String label, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: isBold ? AppTheme.primaryNavy : AppTheme.textMuted, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(val, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: isBold ? AppTheme.accentBlue : AppTheme.primaryNavy)),
        ],
      ),
    );
  }

  Future<void> _printReceipt(Map<String, dynamic> w) async {
    try {
      final bytes = await _pdfService.generateWithdrawalReceiptPdf(
        withdrawalId: w['id'],
        amount: w['amount'],
        currency: w['currency'],
        status: w['status'],
        bankName: w['bankName'],
        accountHolderName: w['accountHolderName'],
        maskedIban: w['maskedIban'],
        swiftBic: w['swiftBic'],
        bankTransferReference: w['bankTransferReference'],
        requestedAt: w['requestedAt'],
        processedAt: w['processedAt'],
      );

      await _printService.printDocument(pdfBytes: bytes, documentName: 'TravelGo_Payout_Receipt_${w["id"]}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating receipt: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TravelGo • Merchant Financial Wallet'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Reconciliation Report',
            icon: const Icon(Icons.balance),
            onPressed: _showReconciliationDialog,
          ),
          IconButton(
            tooltip: 'Bank Accounts',
            icon: const Icon(Icons.account_balance),
            onPressed: _showBankAccountsModal,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentBlue,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.wallet), text: 'Wallets'),
            Tab(icon: Icon(Icons.pie_chart), text: 'Commissions'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Ledger'),
            Tab(icon: Icon(Icons.output), text: 'Payouts'),
          ],
        ),
      ),
      body: ResponsiveContainer(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildWalletsTab(),
            _buildCommissionsTab(),
            _buildLedgerTab(),
            _buildPayoutsTab(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: MULTI-CURRENCY WALLETS OVERVIEW
  // ==========================================
  Widget _buildWalletsTab() {
    final availableMap = <String, double>{};
    _wallets.forEach((cur, data) {
      availableMap[cur] = data['available'] ?? 0.0;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Platform Owner Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.accentBlue,
                  child: Icon(Icons.verified_user, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Platform Owner Earnings Wallet',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '0.75% platform commission on every flight & hotel booking. Wallets are strictly isolated by currency.',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (c) => WithdrawalRequestModal(
                        availableBalances: availableMap,
                        bankAccounts: _bankAccounts,
                        onRequestSubmitted: _handleWithdrawalSubmitted,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.payments, size: 16),
                  label: const Text('Withdraw', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 9-STAGE LIFECYCLE DIAGRAM
          _buildLifecycleStepper(),

          const SizedBox(height: 20),

          const Text(
            'Multi-Currency Isolated Balances',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
          ),
          const SizedBox(height: 6),
          const Text(
            'Each currency operates as an independent balance. EUR, USD, DZD, and GBP are never mixed.',
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 12),

          // 4 Multi-Currency Wallet Cards
          ..._wallets.entries.map((e) => _buildCurrencyWalletCard(e.key, e.value)),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLifecycleStepper() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.shield, color: AppTheme.accentBlue, size: 18),
                SizedBox(width: 8),
                Text(
                  'TravelGo 9-Stage Financial Security Pipeline',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStepPill('1. Booking', Icons.book_online, false),
                  _buildStepArrow(),
                  _buildStepPill('2. Payment', Icons.check_circle_outline, false),
                  _buildStepArrow(),
                  _buildStepPill('3. Provider PNR', Icons.airplane_ticket, false),
                  _buildStepArrow(),
                  _buildStepPill('4. 0.75% Calculated', Icons.calculate, false),
                  _buildStepArrow(),
                  _buildStepPill('5. Pending Balance', Icons.hourglass_top, true, color: AppTheme.warningOrange),
                  _buildStepArrow(),
                  _buildStepPill('6. Available Balance', Icons.account_balance_wallet, true, color: AppTheme.successGreen),
                  _buildStepArrow(),
                  _buildStepPill('7. Withdrawal Request', Icons.arrow_outward, false),
                  _buildStepArrow(),
                  _buildStepPill('8. Admin Verification', Icons.fact_check, false),
                  _buildStepArrow(),
                  _buildStepPill('9. Bank Payout', Icons.account_balance, true, color: AppTheme.accentBlue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepPill(String title, IconData icon, bool isKeyStage, {Color? color}) {
    final c = color ?? (isKeyStage ? AppTheme.accentBlue : AppTheme.textDark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? AppTheme.textMuted).withValues(alpha: isKeyStage ? 0.12 : 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withValues(alpha: isKeyStage ? 0.4 : 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 6),
          Text(title, style: TextStyle(fontSize: 11, fontWeight: isKeyStage ? FontWeight.bold : FontWeight.w500, color: c)),
        ],
      ),
    );
  }

  Widget _buildStepArrow() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.arrow_forward_ios, size: 10, color: AppTheme.textMuted),
    );
  }

  Widget _buildCurrencyWalletCard(String currency, Map<String, double> data) {
    final available = data['available'] ?? 0.0;
    final pending = data['pending'] ?? 0.0;
    final earned = data['earned'] ?? 0.0;
    final withdrawn = data['withdrawn'] ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currency,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.accentBlue),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$currency Merchant Wallet',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy),
                    ),
                  ],
                ),
                Text(
                  'Available: ${CurrencyFormatter.format(available, currency: currency)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.successGreen),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildWalletMetric('Pending Confirmation', CurrencyFormatter.format(pending, currency: currency), AppTheme.warningOrange),
                ),
                Expanded(
                  child: _buildWalletMetric('Total Earned', CurrencyFormatter.format(earned, currency: currency), AppTheme.accentBlue),
                ),
                Expanded(
                  child: _buildWalletMetric('Total Withdrawn', CurrencyFormatter.format(withdrawn, currency: currency), AppTheme.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // ==========================================
  // TAB 2: COMMISSIONS LIFECYCLE
  // ==========================================
  Widget _buildCommissionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _commissions.length,
      itemBuilder: (ctx, idx) {
        final c = _commissions[idx];
        final isAvail = c['commissionStatus'] == 'available';

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppTheme.cardBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(c['bookingType'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isAvail ? AppTheme.successGreen : AppTheme.warningOrange).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isAvail ? 'AVAILABLE' : 'PENDING PNR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isAvail ? AppTheme.successGreen : AppTheme.warningOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ref: ${c["bookingReference"]}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    Text(
                      '+${CurrencyFormatter.format(c["commissionAmount"], currency: c["currency"])} (0.75%)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.accentBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Fare: ${CurrencyFormatter.format(c["totalPrice"], currency: c["currency"])}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    TextButton.icon(
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      icon: const Icon(Icons.info_outline, size: 14),
                      label: const Text('View Financial Breakdown', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (bCtx) => BookingFinancialDetailsSheet(
                            bookingReference: c['bookingReference'],
                            providerReference: c['providerReference'],
                            basePrice: c['basePrice'],
                            taxes: c['taxes'],
                            commissionRate: c['commissionRate'],
                            commissionAmount: c['commissionAmount'],
                            totalPrice: c['totalPrice'],
                            currency: c['currency'],
                            status: c['bookingStatus'],
                            commissionStatus: c['commissionStatus'],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 3: IMMUTABLE FINANCIAL LEDGER
  // ==========================================
  Widget _buildLedgerTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _ledger.length,
      itemBuilder: (ctx, idx) {
        final tx = _ledger[idx];
        final isPositive = (tx['amount'] as double) >= 0;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppTheme.cardBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getTxTypeColor(tx['type']).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            (tx['type'] as String).toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: _getTxTypeColor(tx['type'])),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(tx['referenceId'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryNavy)),
                      ],
                    ),
                    Text(
                      '${isPositive ? "+" : ""}${CurrencyFormatter.format(tx["amount"], currency: tx["currency"])}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isPositive ? AppTheme.successGreen : AppTheme.errorRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(tx['description'], style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                const Divider(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Balance: ${CurrencyFormatter.format(tx["balanceBefore"], currency: tx["currency"])} ➔ ${CurrencyFormatter.format(tx["balanceAfter"], currency: tx["currency"])}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                    ),
                    Text(DateFormatter.formatDateFull(tx['createdAt']), style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getTxTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'commission':
        return AppTheme.accentBlue;
      case 'withdrawal':
        return Colors.purple;
      case 'refund':
        return AppTheme.errorRed;
      case 'adjustment':
        return Colors.orange;
      default:
        return AppTheme.primaryNavy;
    }
  }

  // ==========================================
  // TAB 4: WITHDRAWALS & PDF RECEIPTS
  // ==========================================
  Widget _buildPayoutsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _withdrawals.length,
      itemBuilder: (ctx, idx) {
        final w = _withdrawals[idx];
        final isCompleted = w['status'] == 'completed';

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppTheme.cardBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payout #${w["id"]}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isCompleted ? AppTheme.successGreen : AppTheme.warningOrange).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        (w['status'] as String).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? AppTheme.successGreen : AppTheme.warningOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.format(w['amount'], currency: w['currency']),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.accentBlue),
                ),
                const SizedBox(height: 8),
                Text('${w["bankName"]} • ${w["maskedIban"]}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Text('Wire Ref: ${w["bankTransferReference"] ?? "Pending Transfer"}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Requested: ${DateFormatter.formatDateFull(w["requestedAt"])}', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNavy,
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      icon: const Icon(Icons.picture_as_pdf, size: 14),
                      label: const Text('PDF Receipt', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () => _printReceipt(w),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
