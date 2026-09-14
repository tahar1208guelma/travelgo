import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../domain/entities/ai_budget_breakdown.dart';

class AIBudgetOptimizerCard extends ConsumerWidget {
  final AIBudgetBreakdown budget;
  final void Function(double newTotal)? onBudgetChanged;

  const AIBudgetOptimizerCard({
    super.key,
    required this.budget,
    this.onBudgetChanged,
  });

  Widget _buildBudgetBar(String label, double amount, double percentage, Color color, BuildContext context, dynamic currency, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Text(
              '${AppCurrencyFormatter.format(amount, currency, locale: isArabic ? 'ar' : 'en')} (${percentage.toStringAsFixed(0)}%)',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final currency = ref.watch(currencyProvider);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: CustomCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.savings_outlined, color: AppColors.success, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      context.tr('ai_budget_title'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                Text(
                  AppCurrencyFormatter.format(budget.totalBudgetUSD, currency, locale: isArabic ? 'ar' : 'en'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Budget Breakdown Rows
            _buildBudgetBar(
              context.tr('ai_flight_budget'),
              budget.flightBudgetUSD,
              budget.flightPercentage,
              AppColors.primary,
              context,
              currency,
              isArabic,
            ),
            _buildBudgetBar(
              context.tr('ai_hotel_budget'),
              budget.hotelBudgetUSD,
              budget.hotelPercentage,
              AppColors.secondary,
              context,
              currency,
              isArabic,
            ),
            _buildBudgetBar(
              context.tr('ai_activities_budget'),
              budget.activitiesBudgetUSD,
              budget.activitiesPercentage,
              AppColors.success,
              context,
              currency,
              isArabic,
            ),

            if (onBudgetChanged != null) ...[
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Adjust Budget Ceiling:',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                  Text(
                    '\$${budget.totalBudgetUSD.round()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              Slider(
                value: budget.totalBudgetUSD,
                min: 300,
                max: 5000,
                divisions: 47,
                activeColor: AppColors.primary,
                onChanged: onBudgetChanged,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
