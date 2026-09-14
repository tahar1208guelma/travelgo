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
import '../pages/booking_details_screen.dart';
import '../pages/booking_document_screen.dart';

class BookingCard extends ConsumerWidget {
  final Booking booking;

  const BookingCard({super.key, required this.booking});

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return AppColors.success;
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.cancelled:
      case BookingStatus.failed:
        return AppColors.error;
    }
  }

  IconData _getTypeIcon(BookingType type) {
    switch (type) {
      case BookingType.flight:
        return Icons.flight_takeoff_rounded;
      case BookingType.hotel:
        return Icons.hotel_rounded;
      case BookingType.flightAndHotel:
        return Icons.travel_explore_rounded;
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
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BookingDetailsScreen(booking: booking),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Column(
          children: [
            // Top Header: Type & Reference & Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.primaryContainer.withOpacity(0.35),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getTypeIcon(booking.bookingType),
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        booking.typeLabel,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${booking.bookingReference}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                  BadgeChip(
                    label: booking.statusLabel.toUpperCase(),
                    backgroundColor: statusColor.withOpacity(0.15),
                    textColor: statusColor,
                    fontSize: 11,
                  ),
                ],
              ),
            ),

            // Card Body: Route / Hotel Name, Date & Price
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.itemName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (booking.itemSubtitle != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                booking.itemSubtitle!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppCurrencyFormatter.format(
                              booking.totalAmountUSD,
                              currency,
                              locale: isArabic ? 'ar' : 'en',
                            ),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.primaryLight : AppColors.primary,
                            ),
                          ),
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Dates & Passenger Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            AppDateFormatter.formatDate(booking.startDate, locale: isArabic ? 'ar' : 'en'),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 15,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking.passengerOrGuestName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Divider(height: 20),

                  // Action Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BookingDetailsScreen(booking: booking),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline_rounded, size: 16),
                        label: const Text('Trip Details', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BookingDocumentScreen(booking: booking),
                            ),
                          );
                        },
                        icon: const Icon(Icons.description_outlined, size: 16),
                        label: const Text('View Document', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          elevation: 0,
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
    );
  }
}
