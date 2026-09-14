import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/badge_chip.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../booking/domain/entities/booking_entity.dart';
import '../../../booking/presentation/screens/booking_summary_screen.dart';
import '../../../hotels/domain/entities/hotel_entity.dart';
import '../../../hotels/presentation/screens/hotel_details_screen.dart';

class AIHotelRecommendationCard extends ConsumerWidget {
  final HotelEntity hotel;
  final String? rationale;

  const AIHotelRecommendationCard({
    super.key,
    required this.hotel,
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
        customBorder: BorderSide(color: AppColors.secondary.withOpacity(0.35), width: 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: AI Recommendation & Score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        isArabic ? 'إقامة موصى بها' : 'Top Stay Pick',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                BadgeChip(
                  label: '★ ${hotel.userRating}',
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                  fontSize: 11,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Hotel Image & Name
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: CachedNetworkImage(
                    imageUrl: hotel.mainImageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.primaryContainer,
                      child: const Icon(Icons.hotel, size: 28, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotel.getName(isArabic: isArabic),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${hotel.getCity(isArabic: isArabic)} • ${hotel.distanceToCenter}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (hotel.breakfastIncluded)
                            Text(
                              context.tr('hotel_breakfast_included'),
                              style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppCurrencyFormatter.format(hotel.pricePerNightUSD, currency, locale: isArabic ? 'ar' : 'en'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                      ),
                    ),
                    Text(
                      context.tr('hotel_per_night'),
                      style: TextStyle(fontSize: 10, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                    ),
                  ],
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
                    const Icon(Icons.tips_and_updates_outlined, size: 14, color: AppColors.secondary),
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

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => HotelDetailsScreen(hotel: hotel)),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: AppColors.secondary),
                      foregroundColor: AppColors.secondary,
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
                            bookingType: BookingType.hotel,
                            itemId: hotel.id,
                            itemName: hotel.getName(isArabic: isArabic),
                            itemSubtitle: '${hotel.getCity(isArabic: isArabic)}, ${hotel.getCountry(isArabic: isArabic)}',
                            itemImageUrl: hotel.mainImageUrl,
                            startDate: DateTime.now().add(const Duration(days: 7)),
                            endDate: DateTime.now().add(const Duration(days: 11)),
                            basePriceUSD: hotel.pricePerNightUSD * 4,
                            taxesUSD: hotel.taxesPerNightUSD * 4,
                            isAffiliate: hotel.isAffiliate,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
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
