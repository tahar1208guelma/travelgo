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
          // 1. Hotel Image, Scrim, Verified Partner Badge & Wishlist Heart
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
                child: CachedNetworkImage(
                  imageUrl: hotel.mainImageUrl,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 190,
                    color: isDark ? AppColors.cardDarkElevated : AppColors.primaryContainer,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 190,
                    color: AppColors.primaryContainer,
                    child: Icon(Icons.hotel_rounded, size: 48, color: isDark ? AppColors.secondaryLight : AppColors.primary),
                  ),
                ),
              ),

              // Booking Channel & Verified Partner Badge
              Positioned(
                top: 12,
                left: isArabic ? null : 12,
                right: isArabic ? 12 : null,
                child: hotel.providerName == 'TRAVELGO Direct Partner'
                    ? BadgeChip(
                        label: isArabic ? '🌟 شريك فندقي معتمد' : '🌟 Verified Partner',
                        icon: Icons.verified_rounded,
                        backgroundColor: AppColors.secondary,
                        textColor: Colors.white,
                      )
                    : (hotel.isAffiliate
                        ? BadgeChip(
                            label: context.tr('affiliate_booking'),
                            icon: Icons.open_in_new_rounded,
                            backgroundColor: Colors.black.withValues(alpha: 0.65),
                            textColor: AppColors.secondaryLight,
                          )
                        : BadgeChip(
                            label: context.tr('direct_booking'),
                            icon: Icons.verified_rounded,
                            backgroundColor: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.9),
                            textColor: Colors.white,
                          )),
              ),

              // Wishlist Heart Button
              Positioned(
                top: 10,
                right: isArabic ? null : 10,
                left: isArabic ? 10 : null,
                child: GestureDetector(
                  onTap: () {
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
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? AppColors.accentCoral : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Star Rating & Luxury Score Overlay
              Positioned(
                bottom: 10,
                left: isArabic ? null : 12,
                right: isArabic ? 12 : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: RatingStars(rating: hotel.starRating.toDouble(), size: 12),
                ),
              ),
            ],
          ),

          // 2. Hotel Details Body
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Booking.com Score Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        hotel.getName(isArabic: isArabic),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.secondaryContainerDark : AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: AppColors.accentGold),
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
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: isDark ? AppColors.secondaryLight : AppColors.textMutedLight,
                    ),
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

                // Free Cancellation & Breakfast Badges
                Row(
                  children: [
                    if (hotel.freeCancellation) ...[
                      const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('hotel_free_cancellation'),
                        style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (hotel.breakfastIncluded) ...[
                      Icon(Icons.free_breakfast_rounded, size: 14, color: isDark ? AppColors.secondaryLight : AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('hotel_breakfast_included'),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.secondaryLight : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                const Divider(height: 22),

                // Price Row & View Deal Button
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
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                                color: isDark ? AppColors.secondaryLight : AppColors.primary,
                              ),
                            ),
                            Text(
                              ' / night',
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
                        backgroundColor: isDark ? AppColors.secondary : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                      ),
                      child: Text(
                        context.tr('see_details'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
