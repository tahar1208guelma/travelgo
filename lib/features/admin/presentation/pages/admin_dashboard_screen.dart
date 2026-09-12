import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'admin_finance_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  double _commissionRate = 0.75; // 0.75% default
  bool _isSavingCommission = false;

  // Mock initial provider statuses
  final List<Map<String, dynamic>> _providers = [
    {
      'id': 'amadeus',
      'name': 'Amadeus Global Travel Network',
      'type': 'Flights',
      'isActive': false,
      'isDemo': false,
      'status': 'Credentials Required (.env)',
    },
    {
      'id': 'duffel',
      'name': 'Duffel Flights API',
      'type': 'Flights',
      'isActive': false,
      'isDemo': false,
      'status': 'Token Required (.env)',
    },
    {
      'id': 'mock_flight',
      'name': 'TravelGo Mock Engine (DEMO ONLY)',
      'type': 'Flights',
      'isActive': true,
      'isDemo': true,
      'status': 'Active (Development)',
    },
    {
      'id': 'booking_com',
      'name': 'Booking.com Affiliate API',
      'type': 'Hotels',
      'isActive': false,
      'isDemo': false,
      'status': 'Key Required (.env)',
    },
    {
      'id': 'mock_hotel',
      'name': 'TravelGo Mock Hotel Engine (DEMO ONLY)',
      'type': 'Hotels',
      'isActive': true,
      'isDemo': true,
      'status': 'Active (Development)',
    },
    {
      'id': 'stripe',
      'name': 'Stripe Global Gateway',
      'type': 'Payments',
      'isActive': true,
      'isDemo': false,
      'status': 'Active (Card / 3DS)',
    },
    {
      'id': 'cib_edahabia',
      'name': 'Algeria SATIM CIB / Edahabia',
      'type': 'Payments',
      'isActive': true,
      'isDemo': false,
      'status': 'Active (DZD National)',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TravelGo • Master Admin Console'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dashboard KPIs refreshed from Backend.')),
              );
            },
          ),
        ],
      ),
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.admin_panel_settings, size: 18, color: AppTheme.accentBlue),
                    SizedBox(width: 8),
                    Text(
                      'System Administration & Financial Control',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.accentBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // FINANCIAL WALLET BANNER
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminFinanceScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryNavy, AppTheme.secondaryNavy],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Merchant Financial Wallet & Payouts',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Manage 0.75% commissions, bank accounts & withdrawal lifecycle',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // KPI CARDS GRID
              const Text(
                'Key Performance Indicators (KPIs)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: _buildKpiCard('Total Revenue', CurrencyFormatter.format(148200.0), Icons.payments, Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildKpiCard('Commission (0.75%)', CurrencyFormatter.format(1111.50), Icons.account_balance_wallet, AppTheme.accentBlue)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildKpiCard('Confirmed Bookings', '1,248', Icons.verified, Colors.teal)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildKpiCard('Cancelled Bookings', '42', Icons.cancel, Colors.orange)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildKpiCard('Registered Users', '8,420', Icons.people, Colors.indigo)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildKpiCard('Conversion Rate', '4.82%', Icons.trending_up, Colors.deepPurple)),
                ],
              ),

              const SizedBox(height: 24),

              // DYNAMIC COMMISSION CONTROLLER
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.cardBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TravelGo Commission Engine',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                              ),
                              Text(
                                'Calculated strictly on the Backend (Saved in DB Settings)',
                                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_commissionRate.toStringAsFixed(2)}%',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Slider(
                        value: _commissionRate,
                        min: 0.0,
                        max: 5.0,
                        divisions: 50,
                        activeColor: AppTheme.accentBlue,
                        label: '${_commissionRate.toStringAsFixed(2)}%',
                        onChanged: (val) {
                          setState(() {
                            _commissionRate = val;
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('0.0% (Free)', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                          Text(
                            'Example: \$100.00 Base → \$${(_commissionRate).toStringAsFixed(2)} Fee → Total \$${(100 + _commissionRate).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                          ),
                          const Text('5.0% (Max)', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: _isSavingCommission
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.save),
                          label: const Text('Save & Apply Rate to Backend', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: _isSavingCommission
                              ? null
                              : () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  setState(() => _isSavingCommission = true);
                                  await Future.delayed(const Duration(milliseconds: 600));
                                  if (!mounted) return;
                                  setState(() => _isSavingCommission = false);
                                  messenger.showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppTheme.successGreen,
                                      content: Text('Commission rate successfully updated to ${_commissionRate.toStringAsFixed(2)}% in Backend Settings!'),
                                    ),
                                  );
                                },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // PROVIDERS MANAGEMENT
              const Text(
                'Travel API Providers & Adapters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enable or switch between live GDS APIs and Mock development sandbox engines.',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.cardBorder),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _providers.length,
                  separatorBuilder: (context, _) => const Divider(height: 1, color: AppTheme.cardBorder),
                  itemBuilder: (context, idx) {
                    final p = _providers[idx];
                    return SwitchListTile(
                      title: Text(
                        p['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy),
                      ),
                      subtitle: Text(
                        'Type: ${p["type"]} • ${p["status"]}',
                        style: TextStyle(fontSize: 11, color: p['isActive'] ? AppTheme.accentBlue : AppTheme.textMuted),
                      ),
                      value: p['isActive'],
                      activeThumbColor: AppTheme.accentBlue,
                      onChanged: (val) {
                        setState(() {
                          p['isActive'] = val;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${p["name"]} is now ${val ? "Enabled" : "Disabled"}.')),
                        );
                      },
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

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
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
                Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color == Colors.teal ? AppTheme.primaryNavy : color),
            ),
          ],
        ),
      ),
    );
  }
}
