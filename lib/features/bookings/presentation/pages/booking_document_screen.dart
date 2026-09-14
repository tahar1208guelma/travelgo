import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/badge_chip.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../models/booking_model.dart';
import '../widgets/document_action_bar.dart';
import '../widgets/qr_code_widget.dart';

class BookingDocumentScreen extends ConsumerWidget {
  final Booking booking;

  const BookingDocumentScreen({super.key, required this.booking});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final currency = ref.watch(currencyProvider);
    final statusColor = _getStatusColor(booking.status);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Booking Document',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Document',
            onPressed: () {
              // Quick trigger share via notifier
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: ResponsiveWrapper(
          maxWidth: 800,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // 1. Demo Notice Banner if applicable
            if (booking.document.isDemo) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.error, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DEMO / TEST BOOKING',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'This document is for testing purposes and is not a valid carrier reservation.',
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // 2. Main Voucher Card
            CustomCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header Logo & Document Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'TRAVELGO',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      BadgeChip(
                        label: booking.statusLabel.toUpperCase(),
                        backgroundColor: statusColor.withOpacity(0.15),
                        textColor: statusColor,
                        fontSize: 12,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    booking.document.documentTitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                  const Divider(height: 24),

                  // Booking Reference Highlight
                  Text(
                    'BOOKING REFERENCE',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.1,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    booking.bookingReference,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Visual Safe QR Code
                  SafeQrCodeWidget(
                    qrData: booking.document.qrData,
                    size: 130,
                    caption: 'Scan to verify booking reference',
                  ),
                  const SizedBox(height: 20),

                  const Divider(height: 20),

                  // Customer / Passenger Info
                  _buildDetailRow(
                    context,
                    label: 'Passenger / Lead Guest',
                    value: booking.customer.fullName,
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    context,
                    label: 'Email',
                    value: booking.customer.email,
                    icon: Icons.email_outlined,
                  ),
                  if (booking.customer.phone.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      context,
                      label: 'Phone',
                      value: booking.customer.phone,
                      icon: Icons.phone_outlined,
                    ),
                  ],

                  const Divider(height: 24),

                  // Flight / Hotel Details
                  if (booking.bookingType == BookingType.flight && booking.flightDetails != null) ...[
                    _buildFlightSummary(context, booking.flightDetails!),
                  ] else if (booking.bookingType == BookingType.hotel && booking.hotelDetails != null) ...[
                    _buildHotelSummary(context, booking.hotelDetails!),
                  ] else if (booking.bookingType == BookingType.flightAndHotel) ...[
                    if (booking.flightDetails != null) _buildFlightSummary(context, booking.flightDetails!),
                    const SizedBox(height: 12),
                    if (booking.hotelDetails != null) _buildHotelSummary(context, booking.hotelDetails!),
                  ],

                  const Divider(height: 24),

                  // Price Breakdown Summary
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Column(
                      children: [
                        _buildPriceLine(
                          context,
                          'Base Fare / Rate',
                          AppCurrencyFormatter.format(booking.priceBreakdown.basePrice, currency, locale: isArabic ? 'ar' : 'en'),
                        ),
                        if (booking.priceBreakdown.taxes > 0)
                          _buildPriceLine(
                            context,
                            'Taxes & Fees',
                            AppCurrencyFormatter.format(booking.priceBreakdown.taxes, currency, locale: isArabic ? 'ar' : 'en'),
                          ),
                        if (booking.priceBreakdown.isServiceFeeLegallySupported && booking.priceBreakdown.serviceFee > 0)
                          _buildPriceLine(
                            context,
                            'Platform Service Fee',
                            AppCurrencyFormatter.format(booking.priceBreakdown.serviceFee, currency, locale: isArabic ? 'ar' : 'en'),
                          ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount Paid',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              AppCurrencyFormatter.format(booking.priceBreakdown.totalAmount, currency, locale: isArabic ? 'ar' : 'en'),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
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
            ),
            const SizedBox(height: AppSpacing.lg),

            // 3. Document Action Bar (View PDF, Save PDF, Print, Share)
            DocumentActionBar(booking: booking, isVertical: true),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildFlightSummary(BuildContext context, dynamic flightDetails) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = flightDetails.primarySegment;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${primary.airline} • ${primary.flightNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              BadgeChip(
                label: primary.cabinClass,
                backgroundColor: AppColors.primaryContainer,
                textColor: AppColors.primary,
                fontSize: 10,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${primary.departureAirportCode} (${primary.departureCity ?? primary.departureAirport})',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
              Text(
                '${primary.arrivalAirportCode} (${primary.arrivalCity ?? primary.arrivalAirport})',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ],
          ),
          if (flightDetails.baggageAllowance != null) ...[
            const SizedBox(height: 4),
            Text(
              'Baggage: ${flightDetails.baggageAllowance}',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHotelSummary(BuildContext context, dynamic hotelDetails) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hotelDetails.hotelName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            hotelDetails.hotelAddress,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${hotelDetails.numberOfNights} Nights • ${hotelDetails.numberOfGuests} Guests',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text(
                hotelDetails.mealPlan,
                style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceLine(BuildContext context, String label, String amount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          Text(
            amount,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
