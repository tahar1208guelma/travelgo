import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/badge_chip.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../favorites/domain/entities/favorite_item_entity.dart';
import '../../../favorites/presentation/controllers/favorites_controller.dart';
import '../../domain/entities/unified_search_result_entity.dart';

class UnifiedSearchCard extends ConsumerWidget {
  final UnifiedSearchResultEntity item;
  final VoidCallback onTap;

  const UnifiedSearchCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  String _getTypeBadge(AccommodationType type, bool isArabic) {
    switch (type) {
      case AccommodationType.hotel:
        return isArabic ? 'فندق' : 'Hotel';
      case AccommodationType.apartment:
        return isArabic ? 'شقة فاخرة' : 'Apartment';
      case AccommodationType.desertCamp:
        return isArabic ? 'مخيم صحراوي' : 'Desert Camp';
      case AccommodationType.hostel:
        return isArabic ? 'نزل اقتصادي' : 'Hostel';
      case AccommodationType.luxuryVilla:
        return isArabic ? 'فيلا خاصة' : 'Luxury Villa';
      case AccommodationType.flight:
        return isArabic ? 'رحلة طيران' : 'Flight';
      case AccommodationType.package:
        return isArabic ? 'باقة متكاملة' : 'Package';
      case AccommodationType.all:
        return isArabic ? 'إقامة' : 'Stay';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final currency = ref.watch(currencyProvider);
    final isFav = ref.watch(favoritesControllerProvider.notifier).isFavorite(item.id);

    return CustomCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image Header, Badges & Wishlist Heart
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  height: 155,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 155,
                    color: isDark ? AppColors.cardDarkElevated : AppColors.primaryContainer,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 155,
                    color: AppColors.primaryContainer,
                    child: Icon(
                      Icons.travel_explore_rounded,
                      size: 44,
                      color: isDark ? AppColors.secondaryLight : AppColors.primary,
                    ),
                  ),
                ),
              ),

              // Category & Source Badge
              Positioned(
                top: 10,
                left: isArabic ? null : 10,
                right: isArabic ? 10 : null,
                child: Row(
                  children: [
                    BadgeChip(
                      label: _getTypeBadge(item.type, isArabic),
                      backgroundColor: (isDark ? AppColors.cardDark : Colors.black).withValues(alpha: 0.75),
                      textColor: Colors.white,
                      fontSize: 10,
                    ),
                    if (item.isPartnerVerified) ...[
                      const SizedBox(width: 4),
                      BadgeChip(
                        label: isArabic ? 'شريك موثق' : 'Verified Partner',
                        icon: Icons.verified_rounded,
                        backgroundColor: AppColors.secondary,
                        textColor: Colors.white,
                        fontSize: 10,
                      ),
                    ],
                  ],
                ),
              ),

              // Wishlist Heart Button
              Positioned(
                top: 8,
                right: isArabic ? null : 8,
                left: isArabic ? 8 : null,
                child: GestureDetector(
                  onTap: () {
                    ref.read(favoritesControllerProvider.notifier).toggleFavorite(
                      FavoriteItemEntity(
                        id: item.id,
                        title: item.getDisplayTitle(isArabic),
                        subtitle: item.getDisplaySubtitle(isArabic),
                        imageUrl: item.imageUrl,
                        priceUSD: item.price,
                        type: 'hotel',
                        rating: item.rating,
                        createdAt: DateTime.now(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? AppColors.accentCoral : Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),

              // Rating Score Pill
              Positioned(
                bottom: 10,
                left: isArabic ? null : 10,
                right: isArabic ? 10 : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.accentGold),
                      const SizedBox(width: 3),
                      Text(
                        item.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.reviewCount > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(${item.reviewCount})',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 2. Card Content Body
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  item.getDisplayTitle(isArabic),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Location Subtitle
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
                        item.getDisplaySubtitle(isArabic),
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
                const SizedBox(height: 8),

                // Amenities Badges (WiFi, Breakfast, Free Cancellation)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (item.freeCancellation)
                      _buildMiniBadge(
                        icon: Icons.check_circle_outline_rounded,
                        text: isArabic ? 'إلغاء مجاني' : 'Free Cancellation',
                        color: AppColors.success,
                      ),
                    if (item.breakfastIncluded)
                      _buildMiniBadge(
                        icon: Icons.free_breakfast_outlined,
                        text: isArabic ? 'شامل الإفطار' : 'Breakfast',
                        color: isDark ? AppColors.secondaryLight : AppColors.primary,
                      ),
                  ],
                ),
                const Divider(height: 20),

                // Price & Clear Loyalty Points Action CTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  AppCurrencyFormatter.format(item.price, currency, locale: isArabic ? 'ar' : 'en'),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                    color: isDark ? AppColors.secondaryLight : AppColors.primary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                ' / night',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.stars_rounded, size: 12, color: AppColors.accentGold),
                              const SizedBox(width: 3),
                              Text(
                                '+${item.loyaltyPointsEarned} pts',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accentGold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // "احجز الآن / Book Now" Button
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.secondary : AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                      ),
                      child: Text(
                        isArabic ? 'احجز الآن' : 'Book Now',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildMiniBadge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
