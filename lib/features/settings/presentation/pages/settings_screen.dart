import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TRAVELGO • Settings & Preferences'),
        elevation: 0,
      ),
      body: ResponsiveContainer(
        child: ListView(
          children: [
            _buildSectionHeader('Regional & Currency Preferences'),
            _buildSettingTile(
              icon: Icons.attach_money,
              title: 'Default Currency',
              subtitle: 'USD (\$)',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
            _buildSettingTile(
              icon: Icons.language,
              title: 'Application Language',
              subtitle: 'English (US)',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader('Documents & Printing'),
            _buildSettingTile(
              icon: Icons.picture_as_pdf,
              title: 'Default PDF Page Format',
              subtitle: 'ISO A4 (210 x 297 mm)',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
            _buildSettingTile(
              icon: Icons.offline_pin,
              title: 'Save Vouchers Offline',
              subtitle: 'Automatic caching for offline airport access',
              trailing: Switch(value: true, onChanged: (_) {}),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader('Platform & System Information'),
            _buildSettingTile(
              icon: Icons.devices,
              title: 'App Version',
              subtitle: 'TRAVELGO v1.0.0 (Build 1) • Cross-Platform Release',
            ),
            _buildSettingTile(
              icon: Icons.security,
              title: 'Privacy & Data Security',
              subtitle: 'Safe booking verification QR identifiers enabled',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppTheme.accentBlue,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.cardBorder),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accentBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.accentBlue, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.primaryNavy)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        trailing: trailing,
      ),
    );
  }
}
