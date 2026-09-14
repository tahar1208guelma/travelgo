import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/destination.dart';
import '../../../flights/domain/entities/flight_search_params.dart';
import '../../../flights/presentation/controllers/flight_search_controller.dart';
import '../../../flights/presentation/screens/flight_results_screen.dart';

class PopularDestinationsCarousel extends ConsumerWidget {
  const PopularDestinationsCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final currency = ref.watch(currencyProvider);
    final destinations = Destination.popularDestinations;

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: destinations.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final dest = destinations[index];

          return InkWell(
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
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Container(
              width: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: dest.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.primaryContainer,
                        child: const Icon(Icons.flight, color: AppColors.primary),
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                            ),
                            child: Text(
                              dest.popularTag,
                              style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dest.getCity(isArabic: isArabic),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                dest.getCountry(isArabic: isArabic),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'from ${AppCurrencyFormatter.format(dest.startingPriceUSD, currency, locale: isArabic ? 'ar' : 'en')}',
                                style: const TextStyle(
                                  color: AppColors.secondaryLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
