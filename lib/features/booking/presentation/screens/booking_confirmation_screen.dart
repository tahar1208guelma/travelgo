import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../bookings/models/booking_model.dart';
import '../../../bookings/presentation/pages/booking_document_screen.dart';
import '../../../bookings/presentation/pages/pdf_preview_screen.dart';
import '../../../home/presentation/screens/main_navigation_screen.dart';
import '../widgets/booking_ticket_widget.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationScreen({super.key, required this.booking});

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
                context.tr('booking_confirmation_subtitle'),
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
                      builder: (_) => BookingDocumentScreen(booking: booking),
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
                      builder: (_) => const MainNavigationScreen(initialTabIndex: 3), // Bookings tab
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
