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
import '../../domain/entities/booking_entity.dart';

class BookingTicketWidget extends ConsumerWidget {
  final BookingEntity booking;

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
          // Top Header (Provider & Status)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.primaryContainer.withOpacity(0.4),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      booking.bookingType == BookingType.flight ? Icons.flight_rounded : Icons.hotel_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      booking.provider,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                BadgeChip(
                  label: booking.status.name.toUpperCase(),
                  backgroundColor: statusColor.withOpacity(0.15),
                  textColor: statusColor,
                  fontSize: 11,
                ),
              ],
            ),
          ),

          // Main Body
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
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 44,
                            height: 44,
                            color: AppColors.primaryContainer,
                            child: const Icon(Icons.flight, color: AppColors.primary),
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
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            maxLines: 1,
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
                        Text(
                          booking.externalBookingReference,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
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
                        Text(
                          booking.passengerOrGuestName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                    Text(
                      AppDateFormatter.formatDate(booking.startDate, locale: isArabic ? 'ar' : 'en'),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      AppCurrencyFormatter.format(booking.totalAmountUSD, currency, locale: isArabic ? 'ar' : 'en'),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
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
