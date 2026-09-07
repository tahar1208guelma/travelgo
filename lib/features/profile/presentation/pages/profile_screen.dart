import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_breakpoints.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../admin/presentation/pages/admin_dashboard_screen.dart';
import '../../../admin/presentation/pages/admin_finance_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TRAVELGO • Dashboard & Profile'),
        elevation: 0,
      ),
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User header card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.cardBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        backgroundColor: AppTheme.accentBlue,
                        child: Text(
                          'TB',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tahar Braknia',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                            ),
                            const Text(
                              'tahar.braknia@example.com',
                              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.electricCyan.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'TRAVELGO Partner & Administrator • 0.75% Commission Tier',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ============================================================
              // TRAVELGO COMMISSION & EARNINGS DASHBOARD
              // ============================================================
              Text(
                'TRAVELGO Commission & Revenue (0.75%)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryNavy, Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryNavy.withValues(alpha: 0.15),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.account_balance_wallet, color: AppTheme.electricCyan, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Total Commission Balance',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        Chip(
                          label: Text('Rate: 0.75%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          backgroundColor: AppTheme.accentBlue,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (context.isDesktop)
                      const Row(
                        children: [
                          Expanded(child: _StatTile(title: 'Accumulated Earnings', value: '\$148.35', icon: Icons.trending_up, isHighlight: true)),
                          SizedBox(width: 12),
                          Expanded(child: _StatTile(title: 'Gross Volume Processed', value: '\$19,780.00', icon: Icons.payments)),
                          SizedBox(width: 12),
                          Expanded(child: _StatTile(title: 'Total Bookings Issued', value: '24 Bookings', icon: Icons.confirmation_number)),
                        ],
                      )
                    else
                      const Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _StatTile(title: 'Earned Commission', value: '\$148.35', icon: Icons.trending_up, isHighlight: true)),
                              SizedBox(width: 10),
                              Expanded(child: _StatTile(title: 'Gross Volume', value: '\$19,780.00', icon: Icons.payments)),
                            ],
                          ),
                          SizedBox(height: 10),
                          _StatTile(title: 'Total Bookings Processed', value: '24 Successful Bookings', icon: Icons.confirmation_number),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.outbox, size: 18),
                            label: const Text('Withdraw Commission / سحب الأرباح', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.electricCyan,
                              foregroundColor: AppTheme.primaryNavy,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AdminFinanceScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.admin_panel_settings, size: 18),
                          label: const Text('Admin Console', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Recent Commission Breakdown Table
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppTheme.cardBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recent Commission Earnings Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy)),
                          Text('0.75% Fixed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentBlue)),
                        ],
                      ),
                      const Divider(height: 20, color: AppTheme.cardBorder),

                      _buildCommissionRow('TRV-2026-000001 (Flight ALG → IST)', 'Base: \$250.00', '+\$1.88 Fee'),
                      const Divider(height: 16, color: AppTheme.cardBorder),
                      _buildCommissionRow('TRV-2026-000002 (Hotel Grand Bosphorus)', 'Base: \$650.00', '+\$4.88 Fee'),
                      const Divider(height: 16, color: AppTheme.cardBorder),
                      _buildCommissionRow('TRV-2026-000003 (Flight + Hotel Combo)', 'Base: \$1,200.00', '+\$9.00 Fee'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Saved Passenger Profiles Section
              Text(
                'Saved Travel Profiles',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
              ),
              const SizedBox(height: 12),
              if (context.isDesktop)
                Row(
                  children: [
                    Expanded(child: _buildPassengerCard('Tahar Braknia', 'Adult (Primary)', 'Passport: 24DZ88921', 'Algeria')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildPassengerCard('Sarah Braknia', 'Adult (Companion)', 'Passport: 24DZ99104', 'Algeria')),
                  ],
                )
              else
                Column(
                  children: [
                    _buildPassengerCard('Tahar Braknia', 'Adult (Primary)', 'Passport: 24DZ88921', 'Algeria'),
                    const SizedBox(height: 12),
                    _buildPassengerCard('Sarah Braknia', 'Adult (Companion)', 'Passport: 24DZ99104', 'Algeria'),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildCommissionRow(String description, String grossAmount, String feeAmount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy)),
              Text(grossAmount, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            feeAmount,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.successGreen),
          ),
        ),
      ],
    );
  }

  static Widget _buildPassengerCard(String name, String type, String passport, String nationality) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy)),
                const Icon(Icons.person_pin, color: AppTheme.accentBlue, size: 22),
              ],
            ),
            const SizedBox(height: 4),
            Text(type, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            Text('$passport • $nationality', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isHighlight;

  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isHighlight ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHighlight ? AppTheme.electricCyan : Colors.white12,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isHighlight ? AppTheme.electricCyan : Colors.white70, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isHighlight ? AppTheme.electricCyan : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
