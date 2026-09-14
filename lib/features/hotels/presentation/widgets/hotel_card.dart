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
import '../../../../shared/widgets/rating_stars.dart';
import '../../../favorites/domain/entities/favorite_item_entity.dart';
import '../../../favorites/presentation/controllers/favorites_controller.dart';
import '../../domain/entities/hotel_entity.dart';

class HotelCard extends ConsumerWidget {
  final HotelEntity hotel;
  final VoidCallback onTap;

  const HotelCard({
    super.key,
    required this.hotel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final currency = ref.watch(currencyProvider);
    final isFav = ref.watch(favoritesControllerProvider.notifier).isFavorite(hotel.id);

    return CustomCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hotel Image, Badges & Favorite Heart
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
                child: CachedNetworkImage(
                  imageUrl: hotel.mainImageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    height: 180,
                    color: AppColors.primaryContainer,
                    child: const Icon(Icons.hotel, size: 48, color: AppColors.primary),
                  ),
                ),
              ),

              // Booking Channel Badge
              Positioned(
                top: 12,
                left: isArabic ? null : 12,
                right: isArabic ? 12 : null,
                child: hotel.isAffiliate
                    ? BadgeChip(
                        label: context.tr('affiliate_booking'),
                        icon: Icons.open_in_new_rounded,
                        backgroundColor: Colors.black.withOpacity(0.7),
                        textColor: AppColors.secondary,
                      )
                    : BadgeChip(
                        label: context.tr('direct_booking'),
                        icon: Icons.verified_rounded,
                        backgroundColor: AppColors.primary.withOpacity(0.85),
                        textColor: Colors.white,
                      ),
              ),

              // Favorite Heart Button
              Positioned(
                top: 8,
                right: isArabic ? null : 8,
                left: isArabic ? 8 : null,
                child: Material(
                  color: Colors.black.withOpacity(0.4),
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? AppColors.error : Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      ref.read(favoritesControllerProvider.notifier).toggleFavorite(
                        FavoriteItemEntity(
                          id: hotel.id,
                          title: hotel.getName(isArabic: isArabic),
                          subtitle: '${hotel.getCity(isArabic: isArabic)}, ${hotel.getCountry(isArabic: isArabic)}',
                          imageUrl: hotel.mainImageUrl,
                          priceUSD: hotel.pricePerNightUSD,
                          type: 'hotel',
                          rating: hotel.userRating,
                          createdAt: DateTime.now(),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Star Rating overlay
              Positioned(
                bottom: 12,
                left: isArabic ? null : 12,
                right: isArabic ? 12 : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: RatingStars(rating: hotel.starRating.toDouble(), size: 12),
                ),
              ),
            ],
          ),

          // Hotel Info Body
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and User Score
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        hotel.getName(isArabic: isArabic),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            hotel.userRating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Location & Distance
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMutedLight),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${hotel.getCity(isArabic: isArabic)} • ${hotel.distanceToCenter} ${context.tr('hotel_distance_to_center')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Free Cancellation & Breakfast Chips
                Row(
                  children: [
                    if (hotel.freeCancellation) ...[
                      const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('hotel_free_cancellation'),
                        style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (hotel.breakfastIncluded) ...[
                      const Icon(Icons.free_breakfast_outlined, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('hotel_breakfast_included'),
                        style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
                const Divider(height: 20),

                // Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              AppCurrencyFormatter.format(hotel.pricePerNightUSD, currency, locale: isArabic ? 'ar' : 'en'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.primaryLight : AppColors.primary,
                              ),
                            ),
                            Text(
                              ' ${context.tr('hotel_per_night')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                      ),
                      child: Text(
                        context.tr('see_details'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
