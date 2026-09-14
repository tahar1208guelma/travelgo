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
          // Airline Row & Channel Badge & Favorite
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: CachedNetworkImage(
                      imageUrl: flight.airlineLogo,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 32,
                        height: 32,
                        color: AppColors.primaryContainer,
                        child: const Icon(Icons.flight, size: 18, color: AppColors.primary),
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
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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
                      backgroundColor: AppColors.warningLight,
                      textColor: AppColors.warning,
                      fontSize: 11,
                    )
                  else
                    BadgeChip(
                      label: context.tr('direct_booking'),
                      icon: Icons.verified_rounded,
                      backgroundColor: AppColors.successLight,
                      textColor: AppColors.success,
                      fontSize: 11,
                    ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? AppColors.error : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                      size: 20,
                    ),
                    onPressed: () {
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
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Flight Schedule Timeline
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
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    flight.departureAirportCode,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                  Text(
                    flight.departureCity,
                    style: TextStyle(
                      fontSize: 12,
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
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1.5,
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          const Icon(Icons.flight, size: 16, color: AppColors.primary),
                          Expanded(
                            child: Container(
                              height: 1.5,
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        flight.stops == 0
                            ? context.tr('flight_stops_direct')
                            : '${flight.stops} ${context.tr('flight_stops_multiple')}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: flight.stops == 0 ? AppColors.success : AppColors.warning,
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
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    flight.arrivalAirportCode,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                  Text(
                    flight.arrivalCity,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),

          // Price and CTA row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppCurrencyFormatter.format(flight.totalUSD, currency, locale: isArabic ? 'ar' : 'en'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                  Text(
                    flight.baggageIncluded ? context.tr('flight_baggage_included') : '',
                    style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                ),
                child: Text(
                  context.tr('see_details'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
