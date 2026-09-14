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
import '../../../../core/utils/validators.dart';
import '../../../../providers_layer/travel_provider.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../domain/entities/booking_entity.dart';
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

    setState(() => _isProcessing = false);

    if (booking != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(booking: booking),
        ),
      );
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip / Hotel Overview Card
              CustomCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    if (widget.itemImageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        child: CachedNetworkImage(
                          imageUrl: widget.itemImageUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 56,
                            height: 56,
                            color: AppColors.primaryContainer,
                            child: Icon(
                              widget.bookingType == BookingType.flight ? Icons.flight : Icons.hotel,
                              color: AppColors.primary,
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
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (widget.itemSubtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.itemSubtitle!,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            AppDateFormatter.formatDate(widget.startDate, locale: isArabic ? 'ar' : 'en'),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.primaryLight : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Passenger / Guest Details Form
              CustomCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('booking_guest_details'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      label: context.tr('auth_full_name'),
                      controller: _nameController,
                      prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                      validator: (val) => AppValidators.validateRequired(val, context.tr('validation_required')),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      label: context.tr('auth_email'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      validator: (val) => AppValidators.validateEmail(val, requiredMsg: context.tr('validation_required')),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                      validator: (val) => AppValidators.validateRequired(val, context.tr('validation_required')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Payment Method Card
              CustomCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Method',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    RadioListTile<String>(
                      value: 'Credit / Debit Card',
                      groupValue: _paymentMethod,
                      title: const Text('Credit or Debit Card (Visa, Mastercard)'),
                      secondary: const Icon(Icons.credit_card_rounded, color: AppColors.primary),
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                    ),
                    RadioListTile<String>(
                      value: 'Google Pay',
                      groupValue: _paymentMethod,
                      title: const Text('Google Pay / Apple Pay (Instant)'),
                      secondary: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.secondary),
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Transparent Price Breakdown Card
              PriceBreakdownCard(
                basePriceUSD: widget.basePriceUSD,
                taxesUSD: widget.taxesUSD,
                isAffiliate: widget.isAffiliate,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Pay & Confirm CTA
              CustomButton(
                text: context.tr('booking_pay_and_confirm'),
                onPressed: _confirmBooking,
                isLoading: _isProcessing,
                icon: Icons.lock_outline_rounded,
                type: ButtonType.primary,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
