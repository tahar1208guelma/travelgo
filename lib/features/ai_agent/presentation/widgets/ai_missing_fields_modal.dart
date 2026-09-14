import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/models/airport.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../flights/presentation/screens/flight_results_screen.dart';
import '../../../flights/presentation/widgets/airport_picker_sheet.dart';
import '../../../hotels/presentation/screens/hotel_results_screen.dart';
import '../../domain/entities/ai_search_intent.dart';
import '../controllers/ai_search_controller.dart';

class AIMissingFieldsModal extends ConsumerStatefulWidget {
  final AISearchIntent initialIntent;

  const AIMissingFieldsModal({super.key, required this.initialIntent});

  static Future<void> show(BuildContext context, AISearchIntent intent) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AIMissingFieldsModal(initialIntent: intent),
    );
  }

  @override
  ConsumerState<AIMissingFieldsModal> createState() => _AIMissingFieldsModalState();
}

class _AIMissingFieldsModalState extends ConsumerState<AIMissingFieldsModal> {
  late AISearchIntent _currentIntent;
  Airport? _selectedOrigin;
  DateTime? _selectedDepartureDate;
  DateTime? _selectedReturnDate;

  @override
  void initState() {
    super.initState();
    _currentIntent = widget.initialIntent;
    if (_currentIntent.originCode != null) {
      _selectedOrigin = Airport.majorAirports.firstWhere(
        (a) => a.code == _currentIntent.originCode,
        orElse: () => Airport.majorAirports[0],
      );
    } else {
      _selectedOrigin = Airport.majorAirports[0]; // default to Algiers (ALG)
    }

    _selectedDepartureDate = _currentIntent.departureDate ?? DateTime.now().add(const Duration(days: 7));
    _selectedReturnDate = _currentIntent.returnDate ?? _selectedDepartureDate!.add(const Duration(days: 7));
  }

  void _onConfirm() {
    final updated = _currentIntent.copyWith(
      originCode: _selectedOrigin?.code ?? 'ALG',
      originCity: _selectedOrigin?.cityEn ?? 'Algiers',
      departureDate: _selectedDepartureDate,
      returnDate: _selectedReturnDate,
      missingFields: [],
    );

    ref.read(aiSearchControllerProvider.notifier).updateIntent(updated);
    Navigator.of(context).pop();

    if (updated.isFlightSearch) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const FlightResultsScreen()),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const HotelResultsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;

    return Container(
      padding: EdgeInsets.only(
        top: AppSpacing.md,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('ai_search_missing_fields_title'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      context.tr('ai_search_missing_fields_desc'),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Recognized Details Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('ai_search_recognized_details'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 6),
                Text(
                  '• Destination: ${_currentIntent.destinationCity ?? _currentIntent.destinationCode ?? "Unknown"}',
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  '• Travelers: ${_currentIntent.adults} Adults${_currentIntent.children > 0 ? ", ${_currentIntent.children} Children" : ""}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Missing Origin Field
          if (_currentIntent.originCode == null) ...[
            Text(
              context.tr('flight_from'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            CustomCard(
              onTap: () async {
                final picked = await AirportPickerSheet.show(
                  context,
                  selectedAirport: _selectedOrigin ?? Airport.majorAirports[0],
                  title: context.tr('flight_from'),
                );
                if (picked != null) {
                  setState(() => _selectedOrigin = picked);
                }
              },
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flight_takeoff, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedOrigin?.getCity(isArabic: isArabic)} (${_selectedOrigin?.code})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Missing Departure Date Field
          if (_currentIntent.departureDate == null) ...[
            Text(
              context.tr('flight_departure_date'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            CustomCard(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDepartureDate ?? DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => _selectedDepartureDate = picked);
                }
              },
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.secondary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        AppDateFormatter.formatShortDate(_selectedDepartureDate ?? DateTime.now(), locale: isArabic ? 'ar' : 'en'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Icon(Icons.edit_calendar_rounded, size: 18),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Continue CTA
          CustomButton(
            text: context.tr('ai_search_continue_action'),
            onPressed: _onConfirm,
            icon: Icons.search,
            type: ButtonType.primary,
          ),
        ],
      ),
    );
  }
}
