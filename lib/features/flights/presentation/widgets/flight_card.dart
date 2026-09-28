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
import '../../../favorites/domain/entities/favorite_item_entity.dart';
import '../../../favorites/presentation/controllers/favorites_controller.dart';
import '../../domain/entities/flight_entity.dart';

class FlightCard extends ConsumerWidget {
  final FlightEntity flight;
  final VoidCallback onTap;

  const FlightCard({
    super.key,
    required this.flight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final currency = ref.watch(currencyProvider);
    final isFav = ref.watch(favoritesControllerProvider.notifier).isFavorite(flight.id);

    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // 1. Airline Header Row, Partner Badge & Wishlist Heart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                        color: (isDark ? AppColors.borderDark : AppColors.borderLight),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: CachedNetworkImage(
                        imageUrl: flight.airlineLogo,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 36,
                          height: 36,
                          color: isDark ? AppColors.cardDarkElevated : AppColors.primaryContainer,
                          child: Icon(
                            Icons.flight_rounded,
                            size: 20,
                            color: isDark ? AppColors.secondaryLight : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flight.airlineName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        flight.providerName,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  if (flight.isAffiliate)
                    BadgeChip(
                      label: context.tr('affiliate_booking'),
                      icon: Icons.open_in_new_rounded,
                      backgroundColor: AppColors.warning.withValues(alpha: 0.15),
                      textColor: AppColors.warning,
                      fontSize: 11,
                    )
                  else
                    BadgeChip(
                      label: context.tr('direct_booking'),
                      icon: Icons.verified_rounded,
                      backgroundColor: AppColors.success.withValues(alpha: 0.15),
                      textColor: AppColors.success,
                      fontSize: 11,
                    ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      ref.read(favoritesControllerProvider.notifier).toggleFavorite(
                        FavoriteItemEntity(
                          id: flight.id,
                          title: '${flight.airlineName} (${flight.departureAirportCode} → ${flight.arrivalAirportCode})',
                          subtitle: '${flight.stops == 0 ? "Direct" : "${flight.stops} Stop"} • ${AppDateFormatter.formatDuration(flight.totalDuration, isArabic: isArabic)}',
                          imageUrl: flight.airlineLogo,
                          priceUSD: flight.totalUSD,
                          type: 'flight',
                          rating: 4.8,
                          createdAt: DateTime.now(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? AppColors.accentCoral : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 2. Flight Timeline (Departure -> Duration/Stops -> Arrival)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Departure
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppDateFormatter.formatTime(flight.departureTime),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    flight.departureAirportCode,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.secondaryLight : AppColors.primary,
                    ),
                  ),
                  Text(
                    flight.departureCity,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),

              // Duration & Route Visual
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Column(
                    children: [
                      Text(
                        AppDateFormatter.formatDuration(flight.totalDuration, isArabic: isArabic),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.secondaryLight : AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          Icon(
                            Icons.flight_takeoff_rounded,
                            size: 16,
                            color: isDark ? AppColors.secondaryLight : AppColors.primary,
                          ),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.secondaryLight : AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (flight.stops == 0 ? AppColors.success : AppColors.warning).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                        ),
                        child: Text(
                          flight.stops == 0
                              ? context.tr('flight_stops_direct')
                              : '${flight.stops} ${context.tr('flight_stops_multiple')}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: flight.stops == 0 ? AppColors.success : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Arrival
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppDateFormatter.formatTime(flight.arrivalTime),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    flight.arrivalAirportCode,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.secondaryLight : AppColors.primary,
                    ),
                  ),
                  Text(
                    flight.arrivalCity,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),

          // 3. Price & View Flight Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppCurrencyFormatter.format(flight.totalUSD, currency, locale: isArabic ? 'ar' : 'en'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                      color: isDark ? AppColors.secondaryLight : AppColors.primary,
                    ),
                  ),
                  Text(
                    flight.baggageIncluded ? '🧳 ${context.tr('flight_baggage_included')}' : 'Total price incl. taxes',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.secondary : AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                ),
                child: Text(
                  context.tr('see_details'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
