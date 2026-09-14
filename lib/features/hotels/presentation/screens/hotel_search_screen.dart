import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/models/destination.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../ai_agent/presentation/widgets/ai_search_entry_bar.dart';
import '../../domain/entities/hotel_search_params.dart';
import '../controllers/hotel_search_controller.dart';
import 'hotel_results_screen.dart';

class HotelSearchScreen extends ConsumerStatefulWidget {
  const HotelSearchScreen({super.key});

  @override
  ConsumerState<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends ConsumerState<HotelSearchScreen> {
  final _destController = TextEditingController(text: 'Dubai');
  DateTime _checkInDate = DateTime.now().add(const Duration(days: 5));
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 9));
  int _adults = 2;
  int _children = 0;
  int _rooms = 1;
  String? _validationError;

  @override
  void dispose() {
    _destController.dispose();
    super.dispose();
  }

  void _selectDates() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _checkInDate, end: _checkOutDate),
    );
    if (picked != null) {
      setState(() {
        _checkInDate = picked.start;
        _checkOutDate = picked.end;
      });
    }
  }

  void _performSearch() {
    setState(() => _validationError = null);

    if (_destController.text.trim().isEmpty) {
      setState(() => _validationError = context.tr('validation_required'));
      return;
    }

    if (!AppValidators.validateDateRange(_checkInDate, _checkOutDate)) {
      setState(() => _validationError = context.tr('validation_invalid_date_range'));
      return;
    }

    if (_adults < 1) {
      setState(() => _validationError = context.tr('validation_at_least_one_guest'));
      return;
    }

    final params = HotelSearchParams(
      destination: _destController.text.trim(),
      checkInDate: _checkInDate,
      checkOutDate: _checkOutDate,
      adults: _adults,
      children: _children,
      rooms: _rooms,
    );

    ref.read(hotelSearchControllerProvider.notifier).updateSearchParams(params);
    ref.read(hotelSearchControllerProvider.notifier).searchHotels();

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HotelResultsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final nights = AppDateFormatter.calculateNights(_checkInDate, _checkOutDate);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          context.tr('hotel_search_title'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: ResponsiveWrapper(
          maxWidth: 800,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Optional AI Natural Language Hotel Search Bar
            const AISearchEntryBar(isHotel: true),

            // Destination Search Field
            CustomCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(Icons.location_city_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('hotel_destination'),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                        TextField(
                          controller: _destController,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            hintText: isArabic ? 'أدخل اسم المدينة أو الفندق' : 'Enter city or hotel name',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Check-in / Check-out Dates
            CustomCard(
              onTap: _selectDates,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(Icons.date_range_rounded, color: AppColors.secondary, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${context.tr('hotel_check_in')} — ${context.tr('hotel_check_out')} ($nights ${context.tr('hotel_night_count')})',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppDateFormatter.formatShortDate(_checkInDate, locale: isArabic ? 'ar' : 'en')} - ${AppDateFormatter.formatShortDate(_checkOutDate, locale: isArabic ? 'ar' : 'en')}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_calendar_rounded, size: 18),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Guests & Rooms
            CustomCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_outline_rounded, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            context.tr('hotel_guests'),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _adults > 1 ? () => setState(() => _adults--) : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('$_adults', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            onPressed: () => setState(() => _adults++),
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bed_outlined, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            context.tr('hotel_rooms'),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _rooms > 1 ? () => setState(() => _rooms--) : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('$_rooms', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            onPressed: () => setState(() => _rooms++),
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_validationError != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  _validationError!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),

            // Search Button
            CustomButton(
              text: context.tr('hotel_search_action'),
              onPressed: _performSearch,
              icon: Icons.search_rounded,
              type: ButtonType.primary,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Popular Destinations Quick Selector
            Text(
              context.tr('home_popular_destinations'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Destination.popularDestinations.map((dest) {
                return ActionChip(
                  label: Text(dest.getCity(isArabic: isArabic)),
                  onPressed: () {
                    setState(() => _destController.text = dest.getCity(isArabic: isArabic));
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ),
  );
  }
}
