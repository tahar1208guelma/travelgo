import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/services/commission_service.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/validators.dart';
import '../../../../providers_layer/travel_provider.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../models/booking_model.dart';
import '../controllers/booking_controller.dart';
import '../widgets/price_breakdown_card.dart';
import 'booking_confirmation_screen.dart';

class BookingSummaryScreen extends ConsumerStatefulWidget {
  final BookingType bookingType;
  final String itemId;
  final String itemName;
  final String? itemSubtitle;
  final String? itemImageUrl;
  final DateTime startDate;
  final DateTime? endDate;
  final double basePriceUSD;
  final double taxesUSD;
  final bool isAffiliate;

  const BookingSummaryScreen({
    super.key,
    required this.bookingType,
    required this.itemId,
    required this.itemName,
    this.itemSubtitle,
    this.itemImageUrl,
    required this.startDate,
    this.endDate,
    required this.basePriceUSD,
    required this.taxesUSD,
    this.isAffiliate = false,
  });

  @override
  ConsumerState<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends ConsumerState<BookingSummaryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Sarah Connor');
  final _emailController = TextEditingController(text: 'sarah.connor@traveler.com');
  final _phoneController = TextEditingController(text: '+1 (555) 019-2834');
  String _paymentMethod = 'Credit / Debit Card';
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _confirmBooking() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isProcessing = true);

    final user = ref.read(authStateProvider).value;
    final userId = user?.id ?? 'guest_traveler';
    final commissionService = ref.read(commissionServiceProvider.notifier);

    final pricing = commissionService.calculatePricing(
      basePriceUSD: widget.basePriceUSD,
      isAffiliate: widget.isAffiliate,
    );

    final request = DirectBookingRequest(
      userId: userId,
      itemId: widget.itemId,
      bookingType: widget.bookingType,
      itemName: widget.itemName,
      itemSubtitle: widget.itemSubtitle,
      itemImageUrl: widget.itemImageUrl,
      startDate: widget.startDate,
      endDate: widget.endDate,
      basePriceUSD: pricing.basePriceUSD,
      taxesUSD: widget.taxesUSD,
      serviceFeeUSD: pricing.serviceFeeUSD, // $1.00 USD
      totalAmountUSD: pricing.totalAmountUSD + widget.taxesUSD,
      passengerOrGuestName: _nameController.text.trim(),
      contactEmail: _emailController.text.trim(),
      contactPhone: _phoneController.text.trim(),
      paymentMethod: _paymentMethod,
    );

    final booking = await ref.read(bookingControllerProvider.notifier).processDirectBooking(request);

    if (mounted) {
      setState(() => _isProcessing = false);
      if (booking != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => BookingConfirmationScreen(booking: booking),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('error_occurred')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          context.tr('booking_summary_title'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ResponsiveWrapper(
            maxWidth: 800,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Trust Assurance Header Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          size: 20,
                          color: isDark ? AppColors.secondaryLight : AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '256-Bit SSL Encrypted Checkout',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                              Text(
                                'Price freeze guaranteed for 15 minutes. Instant confirmation.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 2. Itinerary / Hotel Summary Card
                  CustomCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        if (widget.itemImageUrl != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            child: CachedNetworkImage(
                              imageUrl: widget.itemImageUrl!,
                              width: 68,
                              height: 68,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                width: 68,
                                height: 68,
                                color: isDark ? AppColors.cardDarkElevated : AppColors.primaryContainer,
                                child: Icon(
                                  widget.bookingType == BookingType.flight
                                      ? Icons.flight_rounded
                                      : Icons.hotel_rounded,
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
                                widget.itemName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.itemSubtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.itemSubtitle!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 13,
                                    color: isDark ? AppColors.secondaryLight : AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    AppDateFormatter.formatDate(widget.startDate, locale: isArabic ? 'ar' : 'en'),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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

                  // 3. Passenger / Guest Contact Information
                  Text(
                    context.tr('booking_contact_info'),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  CustomCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _nameController,
                          label: context.tr('booking_passenger_name'),
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          validator: (v) => AppValidators.requiredField(v, 'Name'),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        CustomTextField(
                          controller: _emailController,
                          label: context.tr('email_label'),
                          prefixIcon: const Icon(Icons.email_outlined),
                          keyboardType: TextInputType.emailAddress,
                          validator: AppValidators.email,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        CustomTextField(
                          controller: _phoneController,
                          label: context.tr('phone_label'),
                          prefixIcon: const Icon(Icons.phone_outlined),
                          keyboardType: TextInputType.phone,
                          validator: (v) => AppValidators.requiredField(v, 'Phone'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 4. Payment Method Selector (Airbnb & Booking.com Luxury Style)
                  Text(
                    context.tr('booking_payment_method'),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  CustomCard(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: Row(
                            children: [
                              Icon(
                                Icons.credit_card_rounded,
                                size: 20,
                                color: isDark ? AppColors.secondaryLight : AppColors.primary,
                              ),
                              const SizedBox(width: 10),
                              const Text('Credit / Debit Card (Visa, Mastercard)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          value: 'Credit / Debit Card',
                          groupValue: _paymentMethod,
                          activeColor: isDark ? AppColors.secondary : AppColors.primary,
                          onChanged: (v) => setState(() => _paymentMethod = v!),
                        ),
                        const Divider(height: 1),
                        RadioListTile<String>(
                          title: Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet_rounded,
                                size: 20,
                                color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                              ),
                              const SizedBox(width: 10),
                              const Text('Apple Pay / Google Pay', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          value: 'Digital Wallet',
                          groupValue: _paymentMethod,
                          activeColor: isDark ? AppColors.secondary : AppColors.primary,
                          onChanged: (v) => setState(() => _paymentMethod = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 5. Transparent Price Breakdown Card
                  PriceBreakdownCard(
                    basePriceUSD: widget.basePriceUSD,
                    taxesUSD: widget.taxesUSD,
                    isAffiliate: widget.isAffiliate,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // 6. Confirm & Pay Button with Gradient Luxury Effect
                  CustomButton(
                    text: _isProcessing
                        ? context.tr('loading')
                        : '${context.tr('booking_confirm_and_pay')} • ${AppCurrencyFormatter.format(widget.basePriceUSD + widget.taxesUSD + 1.0, currency, locale: isArabic ? 'ar' : 'en')}',
                    onPressed: _isProcessing ? null : _confirmBooking,
                    isLoading: _isProcessing,
                    type: ButtonType.gradient,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
