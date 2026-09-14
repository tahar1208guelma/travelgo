import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/badge_chip.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../booking/domain/entities/booking_entity.dart';
import '../../../booking/presentation/screens/booking_summary_screen.dart';
import '../../../flights/domain/entities/flight_entity.dart';
import '../../../flights/presentation/screens/flight_details_screen.dart';

class AIFlightRecommendationCard extends ConsumerWidget {
  final FlightEntity flight;
  final String? rationale;

  const AIFlightRecommendationCard({
    super.key,
    required this.flight,
    this.rationale,
  });

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
        customBorder: BorderSide(color: AppColors.primary.withOpacity(0.35), width: 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge Row: AI Recommendation + Verified Fare
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        isArabic ? 'توصية الذكاء الاصطناعي' : 'AI Pick',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                BadgeChip(
                  label: context.tr('ai_badge_verified'),
                  icon: Icons.verified_outlined,
                  backgroundColor: AppColors.successLight,
                  textColor: AppColors.success,
                  fontSize: 10,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Airline Info & Time
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: CachedNetworkImage(
                    imageUrl: flight.airlineLogo,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 36,
                      height: 36,
                      color: AppColors.primaryContainer,
                      child: const Icon(Icons.flight, size: 20, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flight.airlineName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        '${flight.departureAirportCode} ➔ ${flight.arrivalAirportCode} • ${flight.stops == 0 ? "Direct" : "${flight.stops} Stop"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  AppCurrencyFormatter.format(flight.totalUSD, currency, locale: isArabic ? 'ar' : 'en'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                ),
              ],
            ),

            if (rationale != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        rationale!,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),

            // Action Buttons (Details / Book)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => FlightDetailsScreen(flight: flight)),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                    ),
                    child: Text(context.tr('see_details'), style: const TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BookingSummaryScreen(
                            bookingType: BookingType.flight,
                            itemId: flight.id,
                            itemName: '${flight.airlineName} Flight (${flight.departureAirportCode} → ${flight.arrivalAirportCode})',
                            itemSubtitle: '${flight.stops == 0 ? "Direct" : "${flight.stops} Stop"} • ${AppDateFormatter.formatDuration(flight.totalDuration, isArabic: isArabic)}',
                            itemImageUrl: flight.airlineLogo,
                            startDate: flight.departureTime,
                            endDate: flight.arrivalTime,
                            basePriceUSD: flight.basePriceUSD,
                            taxesUSD: flight.taxesUSD,
                            isAffiliate: flight.isAffiliate,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                    ),
                    child: Text(context.tr('book_now'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
