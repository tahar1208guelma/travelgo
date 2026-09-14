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
import 'booking_document_screen.dart';
import 'pdf_preview_screen.dart';

class BookingDetailsScreen extends ConsumerWidget {
  final Booking booking;

  const BookingDetailsScreen({super.key, required this.booking});

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
        title: Text(
          'Booking #${booking.bookingReference}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'View PDF Document',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PdfPreviewScreen(booking: booking)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: ResponsiveWrapper(
          maxWidth: 900,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Status & Overview Card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            booking.typeLabel,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      BadgeChip(
                        label: booking.statusLabel.toUpperCase(),
                        backgroundColor: statusColor.withOpacity(0.15),
                        textColor: statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    booking.itemName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (booking.itemSubtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      booking.itemSubtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoColumn(
                        isDark,
                        'Booking Reference',
                        booking.bookingReference,
                        isBold: true,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                      ),
                      if (booking.providerBookingReference != null)
                        _buildInfoColumn(
                          isDark,
                          'Provider PNR',
                          booking.providerBookingReference!,
                        ),
                      _buildInfoColumn(
                        isDark,
                        'Provider',
                        booking.provider,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Flight Itinerary (if applicable)
            if (booking.flightDetails != null) ...[
              _buildFlightDetailsCard(context, booking.flightDetails!, isDark),
              const SizedBox(height: AppSpacing.md),
            ],

            // Hotel Stay Details (if applicable)
            if (booking.hotelDetails != null) ...[
              _buildHotelDetailsCard(context, booking.hotelDetails!, isDark),
              const SizedBox(height: AppSpacing.md),
            ],

            // Passenger / Guest List Card
            _buildPassengerListCard(context, booking, isDark),
            const SizedBox(height: AppSpacing.md),

            // Price Breakdown Card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price Breakdown',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildPriceItem(
                    isDark,
                    'Base Fare / Rate',
                    AppCurrencyFormatter.format(booking.priceBreakdown.basePrice, currency, locale: isArabic ? 'ar' : 'en'),
                  ),
                  if (booking.priceBreakdown.taxes > 0)
                    _buildPriceItem(
                      isDark,
                      'Taxes & Airport / Local Fees',
                      AppCurrencyFormatter.format(booking.priceBreakdown.taxes, currency, locale: isArabic ? 'ar' : 'en'),
                    ),
                  if (booking.priceBreakdown.isServiceFeeLegallySupported && booking.priceBreakdown.serviceFee > 0)
                    _buildPriceItem(
                      isDark,
                      'TRAVELGO Service Fee (Standard)',
                      AppCurrencyFormatter.format(booking.priceBreakdown.serviceFee, currency, locale: isArabic ? 'ar' : 'en'),
                    ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Paid',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        AppCurrencyFormatter.format(booking.priceBreakdown.totalAmount, currency, locale: isArabic ? 'ar' : 'en'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Action Buttons
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => BookingDocumentScreen(booking: booking)),
                );
              },
              icon: const Icon(Icons.description_rounded),
              label: const Text('Open Official Document & QR Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            DocumentActionBar(booking: booking),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildFlightDetailsCard(BuildContext context, dynamic flightDetails, bool isDark) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Flight Itinerary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (flightDetails.baggageAllowance != null)
                Text(
                  '🧳 ${flightDetails.baggageAllowance}',
                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...flightDetails.segments.map<Widget>((seg) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${seg.airline} (${seg.flightNumber})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      BadgeChip(label: seg.cabinClass, backgroundColor: AppColors.primaryContainer, textColor: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(seg.departureAirportCode, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(seg.departureAirport, style: const TextStyle(fontSize: 11)),
                          Text(AppDateFormatter.formatDateTime(seg.departureDateTime),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(seg.arrivalAirportCode, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(seg.arrivalAirport, style: const TextStyle(fontSize: 11)),
                          Text(AppDateFormatter.formatDateTime(seg.arrivalDateTime),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHotelDetailsCard(BuildContext context, dynamic hotelDetails, bool isDark) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hotel Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(hotelDetails.hotelName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          Text(hotelDetails.hotelAddress,
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn(isDark, 'Check-In', AppDateFormatter.formatDate(hotelDetails.checkInDate)),
              _buildInfoColumn(isDark, 'Check-Out', AppDateFormatter.formatDate(hotelDetails.checkOutDate)),
              _buildInfoColumn(isDark, 'Duration', '${hotelDetails.numberOfNights} Nights'),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.green.shade50,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_outlined, size: 16, color: AppColors.success),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hotelDetails.cancellationPolicy,
                    style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerListCard(BuildContext context, Booking booking, bool isDark) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Guests / Passengers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: AppColors.primaryContainer,
              child: Icon(Icons.person, color: AppColors.primary),
            ),
            title: Text(booking.customer.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${booking.customer.email} • ${booking.customer.phone}'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(bool isDark, String label, String value, {bool isBold = false, Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceItem(bool isDark, String label, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
