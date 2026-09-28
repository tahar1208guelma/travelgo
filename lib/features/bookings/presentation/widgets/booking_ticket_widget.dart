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
import '../../models/booking_model.dart';

/// Boarding-pass luxury ticket widget with perforated cutouts & PNR code
class BookingTicketWidget extends ConsumerWidget {
  final Booking booking;

  const BookingTicketWidget({super.key, required this.booking});

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return AppColors.success;
      case BookingStatus.pending:
      case BookingStatus.initiated:
        return AppColors.warning;
      case BookingStatus.cancelled:
      case BookingStatus.failed:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final currency = ref.watch(currencyProvider);
    final statusColor = _getStatusColor(booking.status);

    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // 1. Top Header Banner (Provider & Confirmed Status Pill)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDarkElevated : (AppColors.primary).withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      booking.bookingType == BookingType.flight
                          ? Icons.flight_rounded
                          : (booking.bookingType == BookingType.hotel
                              ? Icons.hotel_rounded
                              : Icons.travel_explore_rounded),
                      size: 20,
                      color: isDark ? AppColors.secondaryLight : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      booking.provider,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                BadgeChip(
                  label: booking.status.name.toUpperCase(),
                  icon: Icons.check_circle_rounded,
                  backgroundColor: statusColor.withValues(alpha: 0.15),
                  textColor: statusColor,
                  fontSize: 11,
                ),
              ],
            ),
          ),

          // 2. Main Ticket Body
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (booking.itemImageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        child: CachedNetworkImage(
                          imageUrl: booking.itemImageUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 48,
                            height: 48,
                            color: isDark ? AppColors.cardDarkElevated : AppColors.primaryContainer,
                            child: Icon(
                              Icons.flight_rounded,
                              color: isDark ? AppColors.secondaryLight : AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.itemName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (booking.itemSubtitle != null)
                            Text(
                              booking.itemSubtitle!,
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
                const SizedBox(height: AppSpacing.md),

                // Perforated Divider simulation
                Row(
                  children: List.generate(
                    24,
                    (index) => Expanded(
                      child: Container(
                        height: 1.5,
                        color: index % 2 == 0
                            ? (isDark ? AppColors.borderDark : AppColors.dividerLight)
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // PNR & Passenger info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('booking_reference_number'),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          booking.externalBookingReference,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                            color: isDark ? AppColors.secondaryLight : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Passenger / Guest',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          booking.passengerOrGuestName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Date & Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: isDark ? AppColors.secondaryLight : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppDateFormatter.formatDate(booking.startDate, locale: isArabic ? 'ar' : 'en'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      AppCurrencyFormatter.format(booking.totalAmountUSD, currency, locale: isArabic ? 'ar' : 'en'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        color: isDark ? AppColors.secondaryLight : AppColors.primary,
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
