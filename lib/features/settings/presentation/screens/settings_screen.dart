import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/services/commission_service.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/models/currency.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final selectedCurrency = ref.watch(currencyProvider);
    final user = ref.watch(authStateProvider).value;
    final commissionConfig = ref.watch(commissionServiceProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Section 1: Localization & Display
          Text(
            'Preferences',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          CustomCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Language selection
                ListTile(
                  leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                  title: Text(context.tr('profile_language')),
                  subtitle: Text(isArabic ? 'العربية' : 'English'),
                  trailing: const Icon(Icons.swap_horiz_rounded),
                  onTap: () => ref.read(languageProvider.notifier).toggleLanguage(),
                ),
                const Divider(height: 1),

                // Currency selection
                ListTile(
                  leading: const Icon(Icons.monetization_on_outlined, color: AppColors.secondary),
                  title: Text(context.tr('profile_currency')),
                  subtitle: Text('${selectedCurrency.code} — ${selectedCurrency.getName(isArabic: isArabic)}'),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
                      ),
                      builder: (ctx) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 12),
                            const Text('Select Preferred Currency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 12),
                            ...Currency.supportedCurrencies.map((c) {
                              final isSelected = c.code == selectedCurrency.code;
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                  ),
                                  child: Text(
                                    c.symbol,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : AppColors.primary,
                                    ),
                                  ),
                                ),
                                title: Text('${c.code} • ${c.getName(isArabic: isArabic)}'),
                                trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
                                onTap: () {
                                  ref.read(currencyProvider.notifier).setCurrency(c);
                                  Navigator.of(ctx).pop();
                                },
                              );
                            }),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),

                // Theme Mode
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.info),
                  title: Text(context.tr('profile_theme')),
                  value: isDark,
                  onChanged: (_) => ref.read(themeModeProvider.notifier).toggleTheme(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Section 2: Push Notifications
          Text(
            'Notifications',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          CustomCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                  title: const Text('Booking Confirmations & Flight Status'),
                  value: true,
                  onChanged: (val) {},
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.local_offer_outlined, color: AppColors.secondary),
                  title: const Text('Price Drop Alerts & Special Promos'),
                  value: true,
                  onChanged: (val) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Section 3: Administrator Commission Config Panel (Only for admin roles or testing)
          if (user?.role == UserRole.admin || true) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Admin Commission Control',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
                const Text(
                  'Admin Role',
                  style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            CustomCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Direct Booking Fee (USD):',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        '\$${commissionConfig.standardDirectServiceFeeUSD.toStringAsFixed(2)} USD',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.success),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configured dynamically in backend document (Default: \$1.00 USD per direct booking).',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
