import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/destination.dart';
import '../../../favorites/domain/entities/favorite_item_entity.dart';
import '../../../favorites/presentation/controllers/favorites_controller.dart';
import '../../../flights/domain/entities/flight_search_params.dart';
import '../../../flights/presentation/controllers/flight_search_controller.dart';
import '../../../flights/presentation/screens/flight_results_screen.dart';

/// World-Class Destination Cards inspired by Airbnb Experiences & Booking.com Luxury Picks
class PopularDestinationsCarousel extends ConsumerWidget {
  const PopularDestinationsCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final currency = ref.watch(currencyProvider);
    final favorites = ref.watch(favoritesControllerProvider);
    final destinations = Destination.popularDestinations;

    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
        itemCount: destinations.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final dest = destinations[index];
          final isFav = favorites.any((f) => f.id == 'dest_${dest.cityEn}');

          return Container(
            width: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: isDark ? AppColors.darkCardShadow : AppColors.softCardShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: Material(
                color: isDark ? AppColors.cardDark : Colors.white,
                child: InkWell(
                  onTap: () {
                    final params = FlightSearchParams(
                      originCode: 'ALG',
                      originCity: 'Algiers',
                      destinationCode: dest.cityEn.substring(0, 3).toUpperCase(),
                      destinationCity: dest.cityEn,
                      departureDate: DateTime.now().add(const Duration(days: 10)),
                    );
                    ref.read(flightSearchControllerProvider.notifier).updateSearchParams(params);
                    ref.read(flightSearchControllerProvider.notifier).searchFlights();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FlightResultsScreen()),
                    );
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Luxury Destination Image
                      CachedNetworkImage(
                        imageUrl: dest.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: isDark ? AppColors.cardDarkElevated : AppColors.primaryContainer,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.primaryContainer,
                          child: const Icon(Icons.flight, color: AppColors.primary),
                        ),
                      ),

                      // Gradient Scrim
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.85),
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),

                      // Top Row: Popular Tag & Wishlist Heart Button
                      Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                              ),
                              child: Text(
                                dest.popularTag.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            // Wishlist Heart Button (Airbnb Signature)
                            GestureDetector(
                              onTap: () {
                                ref.read(favoritesControllerProvider.notifier).toggleFavorite(
                                      FavoriteItemEntity(
                                        id: 'dest_${dest.cityEn}',
                                        title: dest.getCity(isArabic: isArabic),
                                        subtitle: dest.getCountry(isArabic: isArabic),
                                        type: 'flight',
                                        priceUSD: dest.startingPriceUSD,
                                        imageUrl: dest.imageUrl,
                                        rating: 4.8,
                                        createdAt: DateTime.now(),
                                      ),
                                    );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  size: 16,
                                  color: isFav ? AppColors.accentCoral : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom Content: City, Country, Rating & Price Pill
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 14, color: AppColors.accentGold),
                                const SizedBox(width: 3),
                                const Text(
                                  '4.9',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '• ${dest.getCountry(isArabic: isArabic)}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              dest.getCity(isArabic: isArabic),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              ),
                              child: Text(
                                'from ${AppCurrencyFormatter.format(dest.startingPriceUSD, currency, locale: isArabic ? 'ar' : 'en')}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
