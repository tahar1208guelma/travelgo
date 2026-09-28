import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/badge_chip.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../domain/entities/partner_entity.dart';
import '../controllers/partner_controller.dart';
import 'admin_panel_screen.dart';
import 'partner_add_property_screen.dart';

class PartnerDashboardScreen extends ConsumerWidget {
  const PartnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final currency = ref.watch(currencyProvider);
    final partnerUser = ref.watch(currentPartnerUserProvider);
    final listingsAsync = ref.watch(partnerListingsProvider);
    final bookingsAsync = ref.watch(partnerBookingsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.business_center_rounded, color: AppColors.secondary, size: 22),
            const SizedBox(width: 8),
            Text(
              isArabic ? 'بوابة الشركاء والملاك' : 'Partner Host Portal',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        actions: [
          // Admin Panel Shortcut Button
          TextButton.icon(
            icon: const Icon(Icons.admin_panel_settings_rounded, size: 18),
            label: const Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? AppColors.secondaryLight : AppColors.primary,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: ResponsiveWrapper(
          maxWidth: 1100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Host Profile Welcome Banner
              CustomCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                backgroundColor: isDark ? AppColors.cardDarkElevated : Colors.white,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            partnerUser?.businessName ?? 'Partner Host',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Host Contact: ${partnerUser?.contactName ?? "Host"} • ${partnerUser?.phone ?? ""}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PartnerAddPropertyScreen()),
                        );
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(isArabic ? 'إضافة عقار / رحلة' : 'Add Property / Tour'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.secondary : AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 2. Financial Metrics: Gross Revenue, 12% TRAVELGO Commission Owed, Net Earnings
              bookingsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading metrics: $e'),
                data: (bookings) {
                  final confirmedBookings = bookings.where((b) => b.status == PartnerBookingStatus.accepted).toList();
                  final grossTotal = confirmedBookings.fold<double>(0.0, (sum, b) => sum + b.grossTotalUSD);
                  final travelgo12PctFee = grossTotal * 0.12; // 12% automatically calculated
                  final netPartnerEarnings = grossTotal * 0.88;

                  return Row(
                    children: [
                      // Total Bookings Card
                      Expanded(
                        child: _buildMetricCard(
                          title: isArabic ? 'إجمالي الحجوزات' : 'Total Bookings',
                          value: '${bookings.length}',
                          subtitle: '${confirmedBookings.length} Confirmed',
                          icon: Icons.confirmation_number_rounded,
                          color: AppColors.info,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Gross Sales
                      Expanded(
                        child: _buildMetricCard(
                          title: isArabic ? 'إجمالي المبيعات' : 'Gross Revenue',
                          value: AppCurrencyFormatter.format(grossTotal, currency, locale: isArabic ? 'ar' : 'en'),
                          subtitle: 'Before platform fees',
                          icon: Icons.payments_rounded,
                          color: isDark ? AppColors.secondaryLight : AppColors.primary,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // 12% TRAVELGO Platform Commission Owed
                      Expanded(
                        child: _buildMetricCard(
                          title: isArabic ? 'عمولة TRAVELGO (12%)' : 'TRAVELGO Fee (12%)',
                          value: AppCurrencyFormatter.format(travelgo12PctFee, currency, locale: isArabic ? 'ar' : 'en'),
                          subtitle: 'Automatic 12% split',
                          icon: Icons.pie_chart_rounded,
                          color: AppColors.warning,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Net Host Earnings
                      Expanded(
                        child: _buildMetricCard(
                          title: isArabic ? 'صافي أرباح الشريك' : 'Net Partner Profit',
                          value: AppCurrencyFormatter.format(netPartnerEarnings, currency, locale: isArabic ? 'ar' : 'en'),
                          subtitle: 'Direct Host Payout',
                          icon: Icons.account_balance_wallet_rounded,
                          color: AppColors.success,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // 3. Incoming Booking Requests (Accept / Reject Actions)
              Text(
                isArabic ? 'طلبات الحجز الواردة' : 'Incoming Booking Requests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              bookingsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (bookings) {
                  if (bookings.isEmpty) {
                    return const Text('No incoming booking requests.');
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final b = bookings[index];
                      return CustomCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                color: isDark ? AppColors.secondaryLight : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        b.customerName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      BadgeChip(
                                        label: b.status.name.toUpperCase(),
                                        backgroundColor: b.status == PartnerBookingStatus.accepted
                                            ? AppColors.success.withValues(alpha: 0.15)
                                            : (b.status == PartnerBookingStatus.rejected
                                                ? AppColors.error.withValues(alpha: 0.15)
                                                : AppColors.warning.withValues(alpha: 0.15)),
                                        textColor: b.status == PartnerBookingStatus.accepted
                                            ? AppColors.success
                                            : (b.status == PartnerBookingStatus.rejected
                                                ? AppColors.error
                                                : AppColors.warning),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${b.listingTitle} • ${AppDateFormatter.formatDate(b.checkIn)} to ${AppDateFormatter.formatDate(b.checkOut)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Gross: ${AppCurrencyFormatter.format(b.grossTotalUSD, currency)} (TRAVELGO 12%: ${AppCurrencyFormatter.format(b.travelgoCommissionUSD, currency)} | Net: ${AppCurrencyFormatter.format(b.partnerNetEarningsUSD, currency)})',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.secondaryLight : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            // Accept / Reject Buttons for Pending Requests
                            if (b.status == PartnerBookingStatus.pending) ...[
                              ElevatedButton(
                                onPressed: () async {
                                  await ref.read(partnerRepositoryProvider).updateBookingStatus(b.id, PartnerBookingStatus.accepted);
                                  ref.invalidate(partnerBookingsProvider);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                child: Text(isArabic ? 'قبول' : 'Accept'),
                              ),
                              const SizedBox(width: 6),
                              OutlinedButton(
                                onPressed: () async {
                                  await ref.read(partnerRepositoryProvider).updateBookingStatus(b.id, PartnerBookingStatus.rejected);
                                  ref.invalidate(partnerBookingsProvider);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(color: AppColors.error),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                child: Text(isArabic ? 'رفض' : 'Reject'),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // 4. Partner Properties / Trips Listing
              Text(
                isArabic ? 'عقاراتي ورحلاتي المسجلة' : 'My Active Listings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              listingsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (listings) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = listings[index];
                      return CustomCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              child: CachedNetworkImage(
                                imageUrl: item.mainImageUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      BadgeChip(
                                        label: item.status == ListingStatus.approved ? 'LIVE IN SEARCH' : 'PENDING ADMIN APPROVAL',
                                        backgroundColor: item.status == ListingStatus.approved
                                            ? AppColors.success.withValues(alpha: 0.15)
                                            : AppColors.warning.withValues(alpha: 0.15),
                                        textColor: item.status == ListingStatus.approved
                                            ? AppColors.success
                                            : AppColors.warning,
                                        fontSize: 10,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${item.category} • ${item.address}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${AppCurrencyFormatter.format(item.pricePerNightUSD, currency)} / night',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.secondaryLight : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xxl),
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
    required Color color,
    required bool isDark,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
