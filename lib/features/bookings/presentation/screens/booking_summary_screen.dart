import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/search/domain/revalidation_result.dart';
import '../../../../core/services/commission_service.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/validators.dart';
import '../../../../providers_layer/travel_provider.dart';
import '../../../../shared/widgets/badge_chip.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../models/booking_model.dart';
import '../../models/customer_info.dart';
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
  ConsumerState<BookingSummaryScreen> createState() =>
      _BookingSummaryScreenState();
}

class _AdditionalPassengerData {
  final TextEditingController nameController;
  final TextEditingController passportController;
  PassengerType type;

  _AdditionalPassengerData({
    required String name,
    this.type = PassengerType.adult,
  })  : nameController = TextEditingController(text: name),
        passportController = TextEditingController();

  void dispose() {
    nameController.dispose();
    passportController.dispose();
  }
}

class _BookingSummaryScreenState extends ConsumerState<BookingSummaryScreen> {
  final _formKey = GlobalKey<FormState>();

  // Primary contact controllers
  final _nameController = TextEditingController(text: 'Sarah Connor');
  final _emailController =
      TextEditingController(text: 'sarah.connor@traveler.com');
  final _phoneController = TextEditingController(text: '+1 (555) 019-2834');
  final _passportController = TextEditingController(text: 'P98241092');
  final _nationalityController = TextEditingController(text: 'United States');
  final _specialRequestsController = TextEditingController();

  // Additional passengers list
  final List<_AdditionalPassengerData> _additionalPassengers = [];

  // Payment inputs
  String _paymentMethod = 'Credit / Debit Card';
  final _cardNumberController =
      TextEditingController(text: '4242 •••• •••• 4242');
  final _cardExpiryController = TextEditingController(text: '12/28');
  final _cardCvvController = TextEditingController(text: '883');
  final _cardHolderController = TextEditingController(text: 'Sarah Connor');

  bool _isProcessing = false;
  bool _isRevalidating = false;
  RevalidationResult? _revalidationResult;
  late double _currentBasePriceUSD;

  @override
  void initState() {
    super.initState();
    _currentBasePriceUSD = widget.basePriceUSD;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runRevalidation();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passportController.dispose();
    _nationalityController.dispose();
    _specialRequestsController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardHolderController.dispose();
    for (final p in _additionalPassengers) {
      p.dispose();
    }
    super.dispose();
  }

  /// Step 6: Live Pre-booking Revalidation with OfferRevalidationService
  Future<void> _runRevalidation() async {
    setState(() => _isRevalidating = true);

    try {
      final result = await ref
          .read(bookingControllerProvider.notifier)
          .revalidateOffer(
            itemId: widget.itemId,
            bookingType: widget.bookingType,
            expectedPriceUSD: _currentBasePriceUSD,
          );

      if (mounted) {
        setState(() {
          _isRevalidating = false;
          _revalidationResult = result;
        });

        if (result.status == RevalidationStatus.priceChanged &&
            result.previousPriceUSD != null) {
          _showPriceChangeDialog(result);
        } else if (result.status == RevalidationStatus.soldOut) {
          _showSoldOutDialog();
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isRevalidating = false;
          _revalidationResult = RevalidationResult(
            status: RevalidationStatus.confirmed,
            itemId: widget.itemId,
            currentPriceUSD: _currentBasePriceUSD,
            verifiedAt: DateTime.now(),
          );
        });
      }
    }
  }

  void _showPriceChangeDialog(RevalidationResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Price Update Notice'),
          ],
        ),
        content: Text(
          'The provider has adjusted the fare for this itinerary from \$${result.previousPriceUSD!.toStringAsFixed(2)} to \$${result.currentPriceUSD.toStringAsFixed(2)} USD.\n\nWould you like to accept the new fare and continue to checkout?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel & Return'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentBasePriceUSD = result.currentPriceUSD;
              });
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept Updated Price'),
          ),
        ],
      ),
    );
  }

  void _showSoldOutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            SizedBox(width: 8),
            Text('Offer No Longer Available'),
          ],
        ),
        content: const Text(
          'Unfortunately, the selected offer has just sold out with the provider inventory. Please select an alternative flight or hotel room.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back to Search Results'),
          ),
        ],
      ),
    );
  }

  void _addPassenger() {
    if (_additionalPassengers.length >= 4) return;
    setState(() {
      _additionalPassengers.add(_AdditionalPassengerData(
        name: 'Passenger ${_additionalPassengers.length + 2}',
      ));
    });
  }

  void _removePassenger(int index) {
    setState(() {
      final p = _additionalPassengers.removeAt(index);
      p.dispose();
    });
  }

  /// Step 7: Payment Execution
  void _confirmBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_revalidationResult?.status == RevalidationStatus.soldOut) {
      _showSoldOutDialog();
      return;
    }

    setState(() => _isProcessing = true);

    final user = ref.read(authStateProvider).value;
    final userId = user?.id ?? 'guest_traveler';
    final commissionService = ref.read(commissionServiceProvider.notifier);

    // Deterministic price calculation ($1.00 USD standard platform fee)
    final pricing = commissionService.calculatePricing(
      basePriceUSD: _currentBasePriceUSD,
      isAffiliate: widget.isAffiliate,
    );

    // Build passenger list
    final List<PassengerInfo> allPassengers = [
      PassengerInfo(
        fullName: _nameController.text.trim(),
        passengerType: PassengerType.adult,
        passportOrIdNumber: _passportController.text.trim().isNotEmpty
            ? _passportController.text.trim()
            : null,
        nationality: _nationalityController.text.trim().isNotEmpty
            ? _nationalityController.text.trim()
            : null,
        specialRequests: _specialRequestsController.text.trim().isNotEmpty
            ? _specialRequestsController.text.trim()
            : null,
      ),
      ..._additionalPassengers.map((p) => PassengerInfo(
            fullName: p.nameController.text.trim(),
            passengerType: p.type,
            passportOrIdNumber: p.passportController.text.trim().isNotEmpty
                ? p.passportController.text.trim()
                : null,
          )),
    ];

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
      serviceFeeUSD: pricing.serviceFeeUSD, // $1.00 USD standard platform fee
      totalAmountUSD: pricing.totalAmountUSD + widget.taxesUSD,
      passengerOrGuestName: _nameController.text.trim(),
      contactEmail: _emailController.text.trim(),
      contactPhone: _phoneController.text.trim(),
      paymentMethod: _paymentMethod,
      passengers: allPassengers,
      specialRequests: _specialRequestsController.text.trim().isNotEmpty
          ? _specialRequestsController.text.trim()
          : null,
    );

    // Simulate secure payment gateway execution delay
    await Future.delayed(const Duration(milliseconds: 700));

    final booking = await ref
        .read(bookingControllerProvider.notifier)
        .processDirectBooking(request);

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
    final commissionService = ref.read(commissionServiceProvider.notifier);
    final pricing = commissionService.calculatePricing(
      basePriceUSD: _currentBasePriceUSD,
      isAffiliate: widget.isAffiliate,
    );
    final totalCalculatedUSD = pricing.totalAmountUSD + widget.taxesUSD;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          context.tr('booking_summary_title'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
                  // 1. Step Progress Breadcrumb
                  _buildLifecycleProgressHeader(isDark),
                  const SizedBox(height: AppSpacing.md),

                  // 2. Pre-booking Revalidation Status Banner
                  _buildRevalidationBanner(isDark),
                  const SizedBox(height: AppSpacing.md),

                  // 3. Offer Summary Card
                  _buildOfferSummaryCard(isDark, isArabic),
                  const SizedBox(height: AppSpacing.lg),

                  // 4. Passenger & Guest Entry (Step 4)
                  _buildPassengerEntrySection(isDark),
                  const SizedBox(height: AppSpacing.lg),

                  // 5. Payment Execution Form (Step 7)
                  _buildPaymentMethodSection(isDark),
                  const SizedBox(height: AppSpacing.lg),

                  // 6. Transparent Price Breakdown (Step 5)
                  PriceBreakdownCard(
                    basePriceUSD: _currentBasePriceUSD,
                    taxesUSD: widget.taxesUSD,
                    isAffiliate: widget.isAffiliate,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // 7. Confirm & Pay Button
                  CustomButton(
                    text: _isProcessing
                        ? 'Executing Secure Payment...'
                        : '${context.tr('booking_confirm_and_pay')} • ${AppCurrencyFormatter.format(totalCalculatedUSD, currency, locale: isArabic ? 'ar' : 'en')}',
                    onPressed: (_isProcessing ||
                            _isRevalidating ||
                            _revalidationResult?.status ==
                                RevalidationStatus.soldOut)
                        ? null
                        : _confirmBooking,
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

  Widget _buildLifecycleProgressHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDarkElevated : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepIndicator(
            step: '1',
            label: 'Travelers',
            isActive: true,
            isDone: true,
            isDark: isDark,
          ),
          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
          _buildStepIndicator(
            step: '2',
            label: 'Revalidate',
            isActive: true,
            isDone: _revalidationResult?.isBookable == true,
            isDark: isDark,
          ),
          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
          _buildStepIndicator(
            step: '3',
            label: 'Payment',
            isActive: true,
            isDone: false,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({
    required String step,
    required String label,
    required bool isActive,
    required bool isDone,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.success
                : (isActive ? AppColors.primary : Colors.grey.shade400),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  step,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildRevalidationBanner(bool isDark) {
    if (_isRevalidating) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.primary.withOpacity(0.25)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Connecting to provider... Verifying live seat & fare availability.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (_revalidationResult != null && _revalidationResult!.isBookable) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_rounded, color: AppColors.success, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _revalidationResult!.statusMessage ??
                    'Inventory & live fare verified. Locked for 15 minutes.',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ),
            TextButton(
              onPressed: _runRevalidation,
              child: const Text('Re-check', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildOfferSummaryCard(bool isDark, bool isArabic) {
    return CustomCard(
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
                  color: isDark
                      ? AppColors.cardDarkElevated
                      : AppColors.primaryContainer,
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
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color:
                          isDark ? AppColors.secondaryLight : AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppDateFormatter.formatDate(widget.startDate,
                          locale: isArabic ? 'ar' : 'en'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

  Widget _buildPassengerEntrySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Traveler & Guest Information',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            TextButton.icon(
              onPressed: _addPassenger,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
              label: const Text('Add Traveler', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Lead Passenger (Passenger 1)
        CustomCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.person_rounded, size: 18, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Lead Passenger / Primary Contact',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _nameController,
                label: context.tr('booking_passenger_name'),
                prefixIcon: const Icon(Icons.person_outline_rounded),
                validator: (v) => AppValidators.requiredField(v, 'Name'),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _emailController,
                      label: context.tr('email_label'),
                      prefixIcon: const Icon(Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      validator: AppValidators.email,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: CustomTextField(
                      controller: _phoneController,
                      label: context.tr('phone_label'),
                      prefixIcon: const Icon(Icons.phone_outlined),
                      keyboardType: TextInputType.phone,
                      validator: (v) => AppValidators.requiredField(v, 'Phone'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _passportController,
                      label: 'Passport / National ID',
                      prefixIcon: const Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: CustomTextField(
                      controller: _nationalityController,
                      label: 'Nationality',
                      prefixIcon: const Icon(Icons.flag_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                controller: _specialRequestsController,
                label: widget.bookingType == BookingType.hotel
                    ? 'Hotel Requests (Quiet room, late check-in, high floor...)'
                    : 'Flight Requests (Meal preference, wheelchair, assistance...)',
                prefixIcon: const Icon(Icons.note_alt_outlined),
              ),
            ],
          ),
        ),

        // Dynamic Additional Passengers
        if (_additionalPassengers.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          ..._additionalPassengers.asMap().entries.map((entry) {
            final idx = entry.key;
            final p = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: CustomCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Passenger ${idx + 2}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AppColors.error,
                          ),
                          onPressed: () => _removePassenger(idx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: p.nameController,
                      label: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (v) =>
                          AppValidators.requiredField(v, 'Full Name'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CustomTextField(
                      controller: p.passportController,
                      label: 'Passport or ID Number (Optional)',
                      prefixIcon: const Icon(Icons.badge_outlined),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildPaymentMethodSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('booking_payment_method'),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CustomCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Row(
                  children: [
                    Icon(Icons.credit_card_rounded,
                        size: 20, color: AppColors.primary),
                    SizedBox(width: 10),
                    Text(
                      'Credit / Debit Card (Visa, Mastercard, Amex)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                value: 'Credit / Debit Card',
                groupValue: _paymentMethod,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _paymentMethod = v!),
              ),
              if (_paymentMethod == 'Credit / Debit Card') ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _cardNumberController,
                        label: 'Card Number',
                        prefixIcon: const Icon(Icons.payment_rounded),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _cardExpiryController,
                              label: 'Expiry (MM/YY)',
                              keyboardType: TextInputType.datetime,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: CustomTextField(
                              controller: _cardCvvController,
                              label: 'CVV',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      CustomTextField(
                        controller: _cardHolderController,
                        label: 'Cardholder Name',
                        prefixIcon: const Icon(Icons.badge_outlined),
                      ),
                    ],
                  ),
                ),
              ],
              const Divider(height: 1),
              RadioListTile<String>(
                title: const Row(
                  children: [
                    Icon(Icons.account_balance_wallet_rounded,
                        size: 20, color: AppColors.secondary),
                    SizedBox(width: 10),
                    Text(
                      'Apple Pay / Google Pay',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                value: 'Digital Wallet',
                groupValue: _paymentMethod,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _paymentMethod = v!),
              ),
              const Divider(height: 1),
              RadioListTile<String>(
                title: const Row(
                  children: [
                    Icon(Icons.speed_rounded,
                        size: 20, color: AppColors.success),
                    SizedBox(width: 10),
                    Text(
                      'TRAVELGO Sandbox 1-Click Pay (Test Mode)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                value: 'Sandbox 1-Click Pay',
                groupValue: _paymentMethod,
                activeColor: AppColors.success,
                onChanged: (v) => setState(() => _paymentMethod = v!),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
