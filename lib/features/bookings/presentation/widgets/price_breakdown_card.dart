import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/services/commission_service.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/custom_card.dart';

class PriceBreakdownCard extends ConsumerWidget {
  final double basePriceUSD;
  final double taxesUSD;
  final bool isAffiliate;

  const PriceBreakdownCard({
    super.key,
    required this.basePriceUSD,
    required this.taxesUSD,
    required this.isAffiliate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final currency = ref.watch(currencyProvider);
    final commissionService = ref.watch(commissionServiceProvider.notifier);

    final pricing = commissionService.calculatePricing(
      basePriceUSD: basePriceUSD,
      isAffiliate: isAffiliate,
    );

    return CustomCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('booking_payment_details'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Base Fare
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('booking_base_fare'),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              Text(
                AppCurrencyFormatter.format(pricing.basePriceUSD, currency, locale: isArabic ? 'ar' : 'en'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Taxes & Airport Fees
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('booking_taxes'),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              Text(
                AppCurrencyFormatter.format(taxesUSD, currency, locale: isArabic ? 'ar' : 'en'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Service Fee ($1 USD platform fee)
          if (!isAffiliate) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      context.tr('booking_service_fee'),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                  ],
                ),
                Text(
                  AppCurrencyFormatter.format(pricing.serviceFeeUSD, currency, locale: isArabic ? 'ar' : 'en'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              context.tr('booking_service_fee_note'),
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
          ],
          const Divider(height: 24),

          // Total Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('booking_total'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                AppCurrencyFormatter.format(pricing.totalAmountUSD + taxesUSD, currency, locale: isArabic ? 'ar' : 'en'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
