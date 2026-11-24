import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/badge_chip.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../controllers/booking_controller.dart';
import '../widgets/document_action_bar.dart';
import 'booking_document_screen.dart';
import 'pdf_preview_screen.dart';

class BookingDetailsScreen extends ConsumerWidget {
  final Booking booking;

  const BookingDetailsScreen({super.key, required this.booking});

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.initiated:
        return AppColors.primary;
      case BookingStatus.confirmed:
        return AppColors.success;
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.cancelled:
      case BookingStatus.failed:
        return AppColors.error;
    }
  }

  void _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    Booking activeBooking,
  ) {
    final reasons = [
      'Change of travel plans',
      'Found a better alternative deal',
      'Personal / Medical emergency',
      'Flight schedule conflict',
      'Other reason',
    ];
    String selectedReason = reasons[0];
    final refundAmount = activeBooking.priceBreakdown.totalAmount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final isDark = Theme.of(modalCtx).brightness == Brightness.dark;

          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.cancel_outlined,
                              color: AppColors.error,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Cancel Booking & Refund',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(modalCtx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Please select a reason for cancelling reservation #${activeBooking.bookingReference}:',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...reasons.map(
                    (r) => RadioListTile<String>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(r, style: const TextStyle(fontSize: 13)),
                      value: r,
                      groupValue: selectedReason,
                      activeColor: AppColors.error,
                      onChanged: (v) {
                        if (v != null) {
                          setModalState(() => selectedReason = v);
                        }
                      },
                    ),
                  ),
                  const Divider(height: 24),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.08),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Eligible for 100% Refund',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.success,
                                ),
                              ),
                              Text(
                                'Estimated refund: \$${refundAmount.toStringAsFixed(2)} USD (to ${activeBooking.paymentMethod ?? "card"}).',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(modalCtx).pop(),
                          child: const Text('Keep Booking'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(modalCtx).pop();
                            final success = await ref
                                .read(bookingControllerProvider.notifier)
                                .cancelBookingAndRequestRefund(
                                  bookingId: activeBooking.bookingReference,
                                  reason: selectedReason,
                                  refundAmount: refundAmount,
                                );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Booking #${activeBooking.bookingReference} cancelled. Refund initiated.'
                                        : 'Failed to cancel booking. Please try again.',
                                  ),
                                  backgroundColor: success
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Confirm Cancellation'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final currency = ref.watch(currencyProvider);

    // Watch active list so updates (cancellations/refunds) reflect reactively
    final allBookings = ref.watch(bookingListProvider);
    final activeBooking = allBookings.firstWhere(
      (b) =>
          b.bookingReference == booking.bookingReference ||
          b.bookingId == booking.bookingId,
      orElse: () => booking,
    );

    final statusColor = _getStatusColor(activeBooking.status);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Booking #${activeBooking.bookingReference}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'View PDF Document',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PdfPreviewScreen(booking: activeBooking),
                ),
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
              // Cancellation / Refund Banner if cancelled
              if (activeBooking.isCancelled) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.error,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'BOOKING CANCELLED',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              activeBooking.cancellationReason ??
                                  'Cancelled by customer request.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Step 10: Refund Tracking Card
                _buildRefundTrackingCard(context, activeBooking, isDark),
                const SizedBox(height: AppSpacing.md),
              ],

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
                              activeBooking.bookingType == BookingType.flight
                                  ? Icons.flight_rounded
                                  : (activeBooking.bookingType == BookingType.hotel
                                      ? Icons.hotel_rounded
                                      : Icons.travel_explore_rounded),
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              activeBooking.typeLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            BadgeChip(
                              label: activeBooking.statusLabel.toUpperCase(),
                              backgroundColor: statusColor.withOpacity(0.15),
                              textColor: statusColor,
                            ),
                            const SizedBox(width: 6),
                            BadgeChip(
                              label: activeBooking.paymentStatusLabel.toUpperCase(),
                              backgroundColor: (activeBooking.paymentStatus ==
                                          PaymentStatus.paid
                                      ? AppColors.success
                                      : AppColors.warning)
                                  .withOpacity(0.15),
                              textColor: activeBooking.paymentStatus ==
                                      PaymentStatus.paid
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontSize: 10,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      activeBooking.itemName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (activeBooking.itemSubtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        activeBooking.itemSubtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
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
                          activeBooking.bookingReference,
                          isBold: true,
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                        ),
                        if (activeBooking.providerBookingReference != null)
                          _buildInfoColumn(
                            isDark,
                            'Provider PNR',
                            activeBooking.providerBookingReference!,
                          ),
                        _buildInfoColumn(
                          isDark,
                          'Provider',
                          activeBooking.provider,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Flight Itinerary (if applicable)
              if (activeBooking.flightDetails != null) ...[
                _buildFlightDetailsCard(
                  context,
                  activeBooking.flightDetails!,
                  isDark,
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Hotel Stay Details (if applicable)
              if (activeBooking.hotelDetails != null) ...[
                _buildHotelDetailsCard(
                  context,
                  activeBooking.hotelDetails!,
                  isDark,
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Passenger / Guest List Card
              _buildPassengerListCard(context, activeBooking, isDark),
              const SizedBox(height: AppSpacing.md),

              // Payment Details Card
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Execution Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoColumn(
                          isDark,
                          'Payment Method',
                          activeBooking.paymentMethod ?? 'Credit Card (Visa)',
                        ),
                        _buildInfoColumn(
                          isDark,
                          'Payment Status',
                          activeBooking.paymentStatusLabel,
                          color: activeBooking.paymentStatus == PaymentStatus.paid
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        if (activeBooking.paymentTransactionId != null)
                          _buildInfoColumn(
                            isDark,
                            'Transaction Ref',
                            activeBooking.paymentTransactionId!,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
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
                      AppCurrencyFormatter.format(
                        activeBooking.priceBreakdown.basePrice,
                        currency,
                        locale: isArabic ? 'ar' : 'en',
                      ),
                    ),
                    if (activeBooking.priceBreakdown.taxes > 0)
                      _buildPriceItem(
                        isDark,
                        'Taxes & Airport / Local Fees',
                        AppCurrencyFormatter.format(
                          activeBooking.priceBreakdown.taxes,
                          currency,
                          locale: isArabic ? 'ar' : 'en',
                        ),
                      ),
                    if (activeBooking
                            .priceBreakdown.isServiceFeeLegallySupported &&
                        activeBooking.priceBreakdown.serviceFee > 0)
                      _buildPriceItem(
                        isDark,
                        'TRAVELGO Service Fee (Standard)',
                        AppCurrencyFormatter.format(
                          activeBooking.priceBreakdown.serviceFee,
                          currency,
                          locale: isArabic ? 'ar' : 'en',
                        ),
                      ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Paid',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          AppCurrencyFormatter.format(
                            activeBooking.priceBreakdown.totalAmount,
                            currency,
                            locale: isArabic ? 'ar' : 'en',
                          ),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Document & Print Actions
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          BookingDocumentScreen(booking: activeBooking),
                    ),
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
              DocumentActionBar(booking: activeBooking),
              const SizedBox(height: AppSpacing.md),

              // Cancel Booking Button (if not already cancelled)
              if (!activeBooking.isCancelled) ...[
                OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(context, ref, activeBooking),
                  icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                  label: const Text(
                    'Cancel Booking & Request Refund',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefundTrackingCard(
    BuildContext context,
    Booking activeBooking,
    bool isDark,
  ) {
    final refund = activeBooking.refundDetails ??
        RefundDetails(
          status: RefundStatus.refunded,
          refundAmount: activeBooking.priceBreakdown.totalAmount,
          currency: activeBooking.priceBreakdown.currency,
          refundTransactionId: 'RFND-TRV-${activeBooking.bookingReference}',
          reason: activeBooking.cancellationReason ?? 'Cancelled by customer',
          requestedAt: activeBooking.createdAt,
          processedAt: activeBooking.createdAt,
          notes: '100% of eligible fare refunded.',
        );

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.assignment_return_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Refund Lifecycle Tracking',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              BadgeChip(
                label: refund.statusLabel.toUpperCase(),
                backgroundColor: AppColors.success.withOpacity(0.15),
                textColor: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn(
                isDark,
                'Refund Amount',
                '\$${refund.refundAmount.toStringAsFixed(2)} ${refund.currency}',
                isBold: true,
                color: AppColors.success,
              ),
              if (refund.refundTransactionId != null)
                _buildInfoColumn(
                  isDark,
                  'Refund Transaction ID',
                  refund.refundTransactionId!,
                ),
            ],
          ),
          const Divider(height: 24),

          // Visual Stepper for refund tracking
          _buildRefundStep(
            title: '1. Cancellation Request Submitted',
            subtitle: refund.requestedAt != null
                ? AppDateFormatter.formatDateTime(refund.requestedAt!)
                : 'Confirmed',
            isDone: true,
            isDark: isDark,
          ),
          _buildRefundStep(
            title: '2. TRAVELGO Refund Approved',
            subtitle:
                'Platform fee & full fare authorized for return (\$${refund.refundAmount.toStringAsFixed(2)})',
            isDone: true,
            isDark: isDark,
          ),
          _buildRefundStep(
            title: '3. Transferred to Original Payment Method',
            subtitle:
                'Credited back to ${activeBooking.paymentMethod ?? "card"}. Usually arrives in 3–5 business days.',
            isDone: refund.status == RefundStatus.refunded,
            isDark: isDark,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRefundStep({
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isDark,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDone ? AppColors.success : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone ? Icons.check : Icons.more_horiz,
                size: 14,
                color: Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isDone ? AppColors.success : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              if (!isLast) const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlightDetailsCard(
    BuildContext context,
    dynamic flightDetails,
    bool isDark,
  ) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Flight Itinerary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (flightDetails.baggageAllowance != null)
                Text(
                  '🧳 ${flightDetails.baggageAllowance}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
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
                border: Border.all(
                  color:
                      isDark ? AppColors.dividerDark : AppColors.dividerLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${seg.airline} (${seg.flightNumber})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      BadgeChip(
                        label: seg.cabinClass,
                        backgroundColor: AppColors.primaryContainer,
                        textColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            seg.departureAirportCode,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            seg.departureAirport,
                            style: const TextStyle(fontSize: 11),
                          ),
                          Text(
                            AppDateFormatter.formatDateTime(
                              seg.departureDateTime,
                            ),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primary,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            seg.arrivalAirportCode,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            seg.arrivalAirport,
                            style: const TextStyle(fontSize: 11),
                          ),
                          Text(
                            AppDateFormatter.formatDateTime(
                              seg.arrivalDateTime,
                            ),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
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

  Widget _buildHotelDetailsCard(
    BuildContext context,
    dynamic hotelDetails,
    bool isDark,
  ) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hotel Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            hotelDetails.hotelName,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Text(
            hotelDetails.hotelAddress,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn(
                isDark,
                'Check-In',
                AppDateFormatter.formatDate(hotelDetails.checkInDate),
              ),
              _buildInfoColumn(
                isDark,
                'Check-Out',
                AppDateFormatter.formatDate(hotelDetails.checkOutDate),
              ),
              _buildInfoColumn(
                isDark,
                'Duration',
                '${hotelDetails.numberOfNights} Nights',
              ),
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
                const Icon(
                  Icons.verified_outlined,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hotelDetails.cancellationPolicy,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerListCard(
    BuildContext context,
    Booking activeBooking,
    bool isDark,
  ) {
    final passengers = activeBooking.customer.passengers.isNotEmpty
        ? activeBooking.customer.passengers
        : [
            PassengerInfo(
              fullName: activeBooking.customer.fullName,
              passengerType: PassengerType.adult,
            ),
          ];

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Guests / Passengers',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              BadgeChip(
                label: '${passengers.length} Traveler(s)',
                backgroundColor: AppColors.primaryContainer,
                textColor: AppColors.primary,
                fontSize: 11,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...passengers.asMap().entries.map((entry) {
            final idx = entry.key;
            final p = entry.value;

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  '${idx + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              title: Text(
                p.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${p.typeLabel}${p.passportOrIdNumber != null ? " • ID: ${p.passportOrIdNumber}" : ""}${p.seatNumber != null ? " • Seat ${p.seatNumber}" : ""}${p.specialRequests != null ? "\nRequests: ${p.specialRequests}" : ""}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(
    bool isDark,
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
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
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          Text(
            amount,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
