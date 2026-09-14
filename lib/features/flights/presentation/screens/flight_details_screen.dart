import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/services/commission_service.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/badge_chip.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../booking/domain/entities/booking_entity.dart';
import '../../../booking/presentation/controllers/booking_controller.dart';
import '../../../booking/presentation/screens/booking_summary_screen.dart';
import '../../domain/entities/flight_entity.dart';

class FlightDetailsScreen extends ConsumerWidget {
  final FlightEntity flight;

  const FlightDetailsScreen({super.key, required this.flight});

  void _handleBooking(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authStateProvider).value;
    final userId = user?.id ?? 'guest_usr';

    if (flight.isAffiliate) {
      // Affiliate Redirection Flow
      final targetUrl = flight.affiliateUrl ?? 'https://www.qatarairways.com/';
      await ref.read(bookingControllerProvider.notifier).trackAffiliateRedirect(
        userId: userId,
        productType: 'flight',
        productId: flight.id,
        rawTargetUrl: targetUrl,
      );

      // Show redirection dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(context.tr('booking_redirecting_partner')),
            content: Text(context.tr('booking_redirecting_desc')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(context.tr('cancel')),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final uri = Uri.parse(targetUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(context.tr('booking_open_partner_site')),
              ),
            ],
          ),
        );
      }
    } else {
      // Direct Booking Flow -> Navigate to Booking Summary Screen with Commission Calculation
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BookingSummaryScreen(
            bookingType: BookingType.flight,
            itemId: flight.id,
            itemName: '${flight.airlineName} Flight (${flight.departureAirportCode} → ${flight.arrivalAirportCode})',
            itemSubtitle: '${flight.stops == 0 ? "Direct" : "${flight.stops} Stop"} • Flight ${flight.airlineCode}',
            itemImageUrl: flight.airlineLogo,
            startDate: flight.departureTime,
            endDate: flight.arrivalTime,
            basePriceUSD: flight.basePriceUSD,
            taxesUSD: flight.taxesUSD,
            isAffiliate: false,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final currency = ref.watch(currencyProvider);
    final commission = ref.watch(commissionServiceProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Flight Itinerary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Airline Banner Card
                  CustomCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          child: CachedNetworkImage(
                            imageUrl: flight.airlineLogo,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                flight.airlineName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                              Text(
                                '${flight.airlineCode} • ${flight.providerName}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (flight.isAffiliate)
                          BadgeChip(
                            label: context.tr('affiliate_booking'),
                            backgroundColor: AppColors.warningLight,
                            textColor: AppColors.warning,
                          )
                        else
                          BadgeChip(
                            label: context.tr('direct_booking'),
                            backgroundColor: AppColors.successLight,
                            textColor: AppColors.success,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Flight Timeline Card
                  CustomCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Departure Point
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                const Icon(Icons.radio_button_checked, size: 18, color: AppColors.primary),
                                Container(
                                  width: 2,
                                  height: 60,
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ],
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppDateFormatter.formatTime(flight.departureTime),
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        flight.departureAirportCode,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${flight.departureCity} International Airport',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                  Text(
                                    AppDateFormatter.formatDate(flight.departureTime, locale: isArabic ? 'ar' : 'en'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Midpoint Layover / Duration
                        Padding(
                          padding: const EdgeInsets.only(left: 32, right: 16, bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : AppColors.primaryContainer.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Flight Duration: ${AppDateFormatter.formatDuration(flight.totalDuration, isArabic: isArabic)}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Arrival Point
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_rounded, size: 20, color: AppColors.secondary),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppDateFormatter.formatTime(flight.arrivalTime),
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        flight.arrivalAirportCode,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.secondary),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${flight.arrivalCity} International Airport',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                  Text(
                                    AppDateFormatter.formatDate(flight.arrivalTime, locale: isArabic ? 'ar' : 'en'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Included Perks & Amenities
                  CustomCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Baggage & In-flight Services',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            const Icon(Icons.luggage_rounded, size: 20, color: AppColors.success),
                            const SizedBox(width: 8),
                            Text(
                              flight.baggageIncluded ? '1 Cabin Bag (7kg) + 1 Checked Bag (23kg)' : 'Cabin Bag only',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.restaurant_rounded, size: 20, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('Complimentary Meal & Drinks Included', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.wifi_rounded, size: 20, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('In-flight Entertainment & Wi-Fi available', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Booking Action Bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Price',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                      Text(
                        AppCurrencyFormatter.format(flight.totalUSD, currency, locale: isArabic ? 'ar' : 'en'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: CustomButton(
                      text: flight.isAffiliate ? context.tr('affiliate_booking') : context.tr('book_now'),
                      icon: flight.isAffiliate ? Icons.open_in_new_rounded : Icons.check_circle_outline_rounded,
                      onPressed: () => _handleBooking(context, ref),
                      type: flight.isAffiliate ? ButtonType.secondary : ButtonType.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
