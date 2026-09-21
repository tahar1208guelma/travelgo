import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/widgets/badge_chip.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../authentication/presentation/screens/login_screen.dart';
import '../../../favorites/presentation/screens/favorites_screen.dart';
import '../../../bookings/presentation/pages/my_bookings_screen.dart';
import '../../../hotel_partner/presentation/screens/hotel_partner_dashboard_screen.dart';
import '../../../hotel_partner/presentation/screens/hotel_registration_wizard_screen.dart';
import 'package:travelgo/features/settings/presentation/screens/settings_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('auth_logout')),
        content: Text(context.tr('auth_logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: Text(context.tr('auth_logout')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authStateProvider).value;
    final currency = ref.watch(currencyProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          context.tr('profile_title'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // User Avatar & Name Card
            CustomCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primaryContainer,
                    backgroundImage: user?.profileImage != null ? NetworkImage(user!.profileImage!) : null,
                    child: user?.profileImage == null
                        ? const Icon(Icons.person, size: 36, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user?.name ?? 'Guest Traveler',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (user?.role == UserRole.admin)
                              const BadgeChip(
                                label: 'ADMIN',
                                backgroundColor: AppColors.primary,
                                textColor: Colors.white,
                                fontSize: 10,
                              )
                            else if (user?.isGuest ?? true)
                              BadgeChip(
                                label: context.tr('profile_guest_badge'),
                                backgroundColor: AppColors.warningLight,
                                textColor: AppColors.warning,
                                fontSize: 10,
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? 'guest@travelgo.app',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Hotel Partner & Host Portal Entry Banner Card
            CustomCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primaryContainer.withOpacity(0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.apartment_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              language.languageCode == 'ar' ? 'بوابة شركاء الفنادق والاستضافة' : 'Hotel Partner & Host Portal',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              language.languageCode == 'ar'
                                  ? 'سجّل فندقك، وأدر الغرف واستقبل الحجوزات المباشرة فوراً'
                                  : 'List properties, manage rooms & direct guest bookings',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const HotelPartnerDashboardScreen()),
                            );
                          },
                          icon: const Icon(Icons.dashboard_rounded, size: 15, color: Colors.white),
                          label: Text(
                            language.languageCode == 'ar' ? 'لوحة الشريك' : 'Host Dashboard',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const HotelRegistrationWizardScreen()),
                          );
                        },
                        icon: const Icon(Icons.add_business_rounded, size: 15),
                        label: Text(
                          language.languageCode == 'ar' ? '+ إضافة فندق' : '+ Add Hotel',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Profile Navigation Items
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.confirmation_number_outlined, color: AppColors.primary),
                    title: Text(context.tr('profile_my_bookings')),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.favorite_outline_rounded, color: AppColors.error),
                    title: Text(context.tr('profile_favorites')),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                    title: Text(context.tr('profile_language')),
                    trailing: Text(
                      language.languageCode == 'ar' ? 'العربية' : 'English',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                      ),
                    ),
                    onTap: () => ref.read(languageProvider.notifier).toggleLanguage(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.attach_money_rounded, color: AppColors.secondary),
                    title: Text(context.tr('profile_currency')),
                    trailing: Text(
                      '${currency.code} (${currency.symbol})',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => SettingsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.info),
                    title: Text(context.tr('profile_theme')),
                    value: isDark,
                    onChanged: (val) => ref.read(themeModeProvider.notifier).toggleTheme(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Legal & Support Group
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text(context.tr('profile_privacy_policy')),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(context.tr('profile_terms_service')),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded),
                    title: Text(context.tr('profile_help_support')),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Logout Tile
            CustomCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: Text(
                  context.tr('auth_logout'),
                  style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                ),
                onTap: () => _showLogoutDialog(context, ref),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Version info
            Text(
              'TRAVELGO v1.0.0 (Build 2026.1)',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
