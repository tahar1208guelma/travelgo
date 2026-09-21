import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../bookings/models/booking_document.dart';
import '../../../bookings/models/booking_model.dart' as models;
import '../../../bookings/models/customer_info.dart';
import '../../../bookings/models/price_breakdown.dart';
import '../../../bookings/presentation/pages/booking_document_screen.dart';
import '../../../home/presentation/screens/main_navigation_screen.dart';
import '../../domain/entities/booking_entity.dart';
import '../widgets/booking_ticket_widget.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final BookingEntity booking;

  const BookingConfirmationScreen({super.key, required this.booking});

  models.Booking _toBookingModel() {
    return models.Booking(
      bookingId: booking.id,
      bookingReference: booking.externalBookingReference,
      bookingType: booking.bookingType == BookingType.flight
          ? models.BookingType.flight
          : models.BookingType.hotel,
      status: models.BookingStatus.confirmed,
      customer: CustomerInfo(
        id: booking.userId,
        fullName: booking.passengerOrGuestName,
        email: booking.contactEmail,
        phone: booking.contactPhone,
      ),
      provider: booking.provider,
      priceBreakdown: PriceBreakdown(
        basePrice: booking.basePriceUSD,
        taxes: booking.taxesUSD,
        serviceFee: booking.serviceFeeUSD,
        totalAmount: booking.totalAmountUSD,
        currency: booking.currency,
      ),
      createdAt: booking.createdAt,
      document: BookingDocument(
        documentId: 'DOC-${booking.externalBookingReference}',
        bookingReference: booking.externalBookingReference,
        issuedAt: booking.createdAt,
        qrData: booking.externalBookingReference,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Success Icon Circle
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 64,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Header
              Text(
                context.tr('booking_confirmation_title'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.tr('booking_service_fee_note'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Ticket Widget
              BookingTicketWidget(booking: booking),
              const SizedBox(height: AppSpacing.xl),

              // Document & PDF Button
              CustomButton(
                text: 'View Official Document (PDF & QR)',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookingDocumentScreen(booking: _toBookingModel()),
                    ),
                  );
                },
                type: ButtonType.primary,
              ),
              const SizedBox(height: AppSpacing.md),

              // Action Buttons
              CustomButton(
                text: context.tr('booking_view_my_bookings'),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationScreen(initialTabIndex: 3),
                    ),
                    (route) => false,
                  );
                },
                type: ButtonType.outline,
              ),
              const SizedBox(height: AppSpacing.md),
              CustomButton(
                text: context.tr('booking_back_home'),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                    (route) => false,
                  );
                },
                type: ButtonType.outline,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
