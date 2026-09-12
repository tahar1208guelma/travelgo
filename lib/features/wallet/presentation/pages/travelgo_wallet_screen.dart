import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_breakpoints.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/widgets/withdraw_commission_dialog.dart';

class TravelGoWalletScreen extends StatefulWidget {
  const TravelGoWalletScreen({super.key});

  @override
  State<TravelGoWalletScreen> createState() => _TravelGoWalletScreenState();
}

class _TravelGoWalletScreenState extends State<TravelGoWalletScreen> {
  double _availableBalance = 148.35;
  final double _pendingBalance = 24.50;
  final double _totalGrossVolume = 19780.00;
  final int _totalBookingsCount = 24;
  bool _autoPayoutEnabled = true;
  String _activeFilter = 'All';

  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TXN-9021',
      'ref': 'TRV-2026-000001',
      'title': 'Air Algerie (ALG → CDG Paris)',
      'type': 'flight',
      'gross': 342.55,
      'fee': 2.57,
      'date': 'Today, 11:20 AM',
      'status': 'Settled',
    },
    {
      'id': 'TXN-9020',
      'ref': 'TRV-2026-000002',
      'title': 'Grand Hotel Bosphorus Istanbul',
      'type': 'hotel',
      'gross': 650.00,
      'fee': 4.88,
      'date': 'Yesterday, 04:15 PM',
      'status': 'Settled',
    },
    {
      'id': 'TXN-9019',
      'ref': 'TRV-2026-000003',
      'title': 'Turkish Airlines (ALG → IST Istanbul)',
      'type': 'flight',
      'gross': 285.00,
      'fee': 2.14,
      'date': 'Sep 01, 2026',
      'status': 'Settled',
    },
    {
      'id': 'TXN-9018',
      'ref': 'TRV-2026-000004',
      'title': 'Emirates Non-stop (DXB → LHR London)',
      'type': 'flight',
      'gross': 725.40,
      'fee': 5.44,
      'date': 'Aug 29, 2026',
      'status': 'Settled',
    },
    {
      'id': 'TXN-9017',
      'ref': 'WD-2026-0082',
      'title': 'Bank Wire Payout (BNA IBAN)',
      'type': 'payout',
      'gross': -120.00,
      'fee': -120.00,
      'date': 'Aug 25, 2026',
      'status': 'Paid Out',
    },
  ];

  void _openWithdrawDialog() {
    WithdrawCommissionDialog.show(
      context,
      availableBalance: _availableBalance,
      onWithdrawSuccess: (withdrawnAmount) {
        setState(() {
          _availableBalance = (_availableBalance - withdrawnAmount).clamp(0.0, double.infinity);
          _transactions.insert(0, {
            'id': 'WD-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
            'ref': 'PAYOUT-DIRECT',
            'title': 'Bank Wire Withdrawal Request',
            'type': 'payout',
            'gross': -withdrawnAmount,
            'fee': -withdrawnAmount,
            'date': 'Just now',
            'status': 'Processing',
          });
        });
      },
    );
  }

  void _showStatementNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Monthly Commission Statement (PDF) generated and sent to tahar.braknia@example.com'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void _showAutoPayoutModal() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Automated Payout Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'When enabled, your 0.75% earnings are automatically transferred directly to your designated IBAN on a scheduled basis.',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Enable Auto-Payout', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                subtitle: const Text('Direct automated settlement without manual requests'),
                value: _autoPayoutEnabled,
                activeThumbColor: AppTheme.accentBlue,
                onChanged: (val) {
                  setModalState(() => _autoPayoutEnabled = val);
                  setState(() => _autoPayoutEnabled = val);
                },
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.account_balance, color: AppTheme.accentBlue),
                title: Text('Settlement Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('Banque Nationale d\'Algérie (BNA) • DZ0020001234567890123456', style: TextStyle(fontSize: 12)),
              ),
              const ListTile(
                leading: Icon(Icons.schedule, color: AppTheme.electricCyan),
                title: Text('Settlement Frequency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('Weekly (Every Monday at 00:00 UTC)', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Save & Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    final filteredTxns = _transactions.where((t) {
      if (_activeFilter == 'Flights') return t['type'] == 'flight';
      if (_activeFilter == 'Hotels') return t['type'] == 'hotel';
      if (_activeFilter == 'Payouts') return t['type'] == 'payout';
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('TRAVELGO • Digital Wallet & Commissions'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Export PDF Statement',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: _showStatementNotice,
          ),
          IconButton(
            tooltip: 'Auto-Payout Settings',
            icon: const Icon(Icons.tune),
            onPressed: _showAutoPayoutModal,
          ),
        ],
      ),
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // DIGITAL WALLET HERO CARD
              // ============================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryNavy, Color(0xFF0F172A), AppTheme.accentBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryNavy.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.account_balance_wallet, color: AppTheme.electricCyan, size: 28),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TRAVELGO Wallet',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '0.75% Fixed Platform Fee & Settlement',
                                  style: TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.electricCyan.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.electricCyan, width: 1),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield_outlined, size: 14, color: AppTheme.electricCyan),
                              SizedBox(width: 4),
                              Text('Active Tier', style: TextStyle(color: AppTheme.electricCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Balance Display
                    const Text('Available Commission Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '\$${_availableBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('USD', style: TextStyle(color: AppTheme.electricCyan, fontWeight: FontWeight.bold, fontSize: 15)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Pending: +\$${_pendingBalance.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions Row
                    if (isDesktop)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.outbox, size: 18),
                              label: const Text('Withdraw Funds / سحب الأرباح', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.electricCyan,
                                foregroundColor: AppTheme.primaryNavy,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _openWithdrawDialog,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.tune, size: 18, color: Colors.white),
                              label: const Text('Auto-Payout Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white38),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _showAutoPayoutModal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.file_download_outlined, size: 18, color: Colors.white),
                              label: const Text('Export Statement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white38),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _showStatementNotice,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.outbox, size: 18),
                              label: const Text('Withdraw Funds / سحب الأرباح', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.electricCyan,
                                foregroundColor: AppTheme.primaryNavy,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _openWithdrawDialog,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.tune, size: 16, color: Colors.white),
                                  label: const Text('Auto-Payout', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.white38),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: _showAutoPayoutModal,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.file_download_outlined, size: 16, color: Colors.white),
                                  label: const Text('Statement', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.white38),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: _showStatementNotice,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ============================================================
              // KEY WALLET METRICS
              // ============================================================
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Gross Turnover',
                      value: '\$${_totalGrossVolume.toStringAsFixed(2)}',
                      subtitle: 'Total Volume Processed',
                      icon: Icons.show_chart,
                      iconColor: AppTheme.accentBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Bookings Issued',
                      value: '$_totalBookingsCount Orders',
                      subtitle: 'Flights & Hotel Nights',
                      icon: Icons.flight_takeoff,
                      iconColor: AppTheme.successGreen,
                    ),
                  ),
                  if (isDesktop) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Fixed Commission',
                        value: '0.75%',
                        subtitle: 'Transparent Net Fee',
                        icon: Icons.percent,
                        iconColor: AppTheme.electricCyan,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // ============================================================
              // LINKED BANK & PAYOUT ACCOUNT
              // ============================================================
              Text(
                'Linked Bank Accounts & Payout Destination',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppTheme.cardBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance, color: AppTheme.accentBlue, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Banque Nationale d\'Algérie (BNA) • Primary IBAN',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'IBAN: DZ00 2000 1234 5678 9012 3456 • SWIFT: BNALDZALXXX',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Verified',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.successGreen),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ============================================================
              // COMMISSION & TRANSACTION LEDGER
              // ============================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Commission Earnings Ledger',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryNavy,
                        ),
                  ),
                  // Filter Chips
                  Row(
                    children: ['All', 'Flights', 'Hotels', 'Payouts'].map((filter) {
                      final isSelected = _activeFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: ChoiceChip(
                          label: Text(filter, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          selected: isSelected,
                          selectedColor: AppTheme.accentBlue.withValues(alpha: 0.15),
                          onSelected: (_) => setState(() => _activeFilter = filter),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppTheme.cardBorder),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredTxns.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: AppTheme.cardBorder),
                  itemBuilder: (ctx, idx) {
                    final txn = filteredTxns[idx];
                    final isPayout = txn['type'] == 'payout';
                    final fee = txn['fee'] as double;
                    final gross = txn['gross'] as double;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isPayout
                              ? AppTheme.warningOrange.withValues(alpha: 0.15)
                              : AppTheme.accentBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPayout
                              ? Icons.outbox
                              : txn['type'] == 'flight'
                                  ? Icons.flight
                                  : Icons.hotel,
                          color: isPayout ? AppTheme.warningOrange : AppTheme.accentBlue,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        txn['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppTheme.primaryNavy),
                      ),
                      subtitle: Text(
                        '${txn['ref']} • ${txn['date']}',
                        style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            isPayout
                                ? '-\$${fee.abs().toStringAsFixed(2)}'
                                : '+\$${fee.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isPayout ? AppTheme.primaryNavy : AppTheme.successGreen,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isPayout ? 'Payout' : 'Gross: \$${gross.toStringAsFixed(2)} (0.75%)',
                            style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 0,
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
                Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                Icon(icon, color: iconColor, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}
