import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../home/presentation/screens/main_navigation_screen.dart';
import '../../models/booking_model.dart';
import '../widgets/booking_ticket_widget.dart';
import 'booking_document_screen.dart';

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
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ResponsiveWrapper(
            maxWidth: 700,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.lg),

                // 1. Success Icon Circle with Glowing Accent
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 64,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // 2. Headline & Confirmation Text
                Text(
                  context.tr('booking_confirmation_title'),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Reservation confirmed! An official confirmation email and PDF e-ticket have been generated.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // 3. Airline / Voucher Boarding Pass Ticket
                BookingTicketWidget(booking: booking),
                const SizedBox(height: AppSpacing.xl),

                // 4. Official PDF Document & QR Action
                CustomButton(
                  text: 'View Official Document (PDF & QR)',
                  icon: Icons.picture_as_pdf_rounded,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookingDocumentScreen(booking: booking),
                      ),
                    );
                  },
                  type: ButtonType.gradient,
                ),
                const SizedBox(height: AppSpacing.md),

                // 5. Secondary Navigation Actions
                CustomButton(
                  text: context.tr('booking_view_my_bookings'),
                  icon: Icons.bookmark_added_rounded,
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
                const SizedBox(height: AppSpacing.sm),
                CustomButton(
                  text: context.tr('booking_back_home'),
                  icon: Icons.home_rounded,
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                      (route) => false,
                    );
                  },
                  type: ButtonType.text,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
