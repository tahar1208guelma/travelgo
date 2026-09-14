import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/models/airport.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../domain/entities/flight_search_params.dart';
import '../controllers/flight_search_controller.dart';
import '../widgets/airport_picker_sheet.dart';
import '../widgets/passenger_picker_sheet.dart';
import 'flight_results_screen.dart';

class FlightSearchScreen extends ConsumerStatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  ConsumerState<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends ConsumerState<FlightSearchScreen> {
  TripType _tripType = TripType.roundTrip;
  Airport _originAirport = Airport.majorAirports[0]; // ALG
  Airport _destAirport = Airport.majorAirports[1]; // DXB
  DateTime _departureDate = DateTime.now().add(const Duration(days: 7));
  DateTime _returnDate = DateTime.now().add(const Duration(days: 14));
  int _adults = 1;
  int _children = 0;
  int _infants = 0;
  CabinClass _cabinClass = CabinClass.economy;
  bool _directOnly = false;
  String? _validationError;

  void _swapAirports() {
    setState(() {
      final temp = _originAirport;
      _originAirport = _destAirport;
      _destAirport = temp;
      _validationError = null;
    });
  }

  void _selectDepartureDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _departureDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _departureDate = picked;
        if (_returnDate.isBefore(_departureDate)) {
          _returnDate = _departureDate.add(const Duration(days: 7));
        }
      });
    }
  }

  void _selectReturnDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _returnDate.isAfter(_departureDate) ? _returnDate : _departureDate,
      firstDate: _departureDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _returnDate = picked);
    }
  }

  void _openPassengerPicker() async {
    final res = await PassengerPickerSheet.show(
      context,
      adults: _adults,
      children: _children,
      infants: _infants,
      cabinClass: _cabinClass,
    );
    if (res != null) {
      setState(() {
        _adults = res.adults;
        _children = res.children;
        _infants = res.infants;
        _cabinClass = res.cabinClass;
      });
    }
  }

  void _performSearch() {
    setState(() => _validationError = null);

    // Validation 1: Airports different
    if (!AppValidators.validateAirportsDifferent(_originAirport.code, _destAirport.code)) {
      setState(() => _validationError = context.tr('validation_same_airport'));
      return;
    }

    // Validation 2: Return date >= departure date
    if (_tripType == TripType.roundTrip && !AppValidators.validateDateRange(_departureDate, _returnDate)) {
      setState(() => _validationError = context.tr('validation_invalid_date_range'));
      return;
    }

    // Validation 3: Passenger count
    if (!AppValidators.validatePassengerCount(_adults, _children, _infants)) {
      setState(() => _validationError = context.tr('validation_at_least_one_passenger'));
      return;
    }

    final params = FlightSearchParams(
      tripType: _tripType,
      originCode: _originAirport.code,
      originCity: _originAirport.cityEn,
      destinationCode: _destAirport.code,
      destinationCity: _destAirport.cityEn,
      departureDate: _departureDate,
      returnDate: _tripType == TripType.roundTrip ? _returnDate : null,
      adults: _adults,
      children: _children,
      infants: _infants,
      cabinClass: _cabinClass,
      directOnly: _directOnly,
    );

    ref.read(flightSearchControllerProvider.notifier).updateSearchParams(params);
    ref.read(flightSearchControllerProvider.notifier).searchFlights();

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FlightResultsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          context.tr('flight_search_title'),
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
            // Trip Type Selector (Round-Trip / One-Way)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _tripType = TripType.roundTrip),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _tripType == TripType.roundTrip ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          context.tr('flight_trip_type_round'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _tripType == TripType.roundTrip ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _tripType = TripType.oneWay),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _tripType == TripType.oneWay ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          context.tr('flight_trip_type_one'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _tripType == TripType.oneWay ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Route Card (From & To with Swap Button)
            CustomCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  Column(
                    children: [
                      // Origin Airport
                      InkWell(
                        onTap: () async {
                          final picked = await AirportPickerSheet.show(
                            context,
                            selectedAirport: _originAirport,
                            title: context.tr('flight_from'),
                          );
                          if (picked != null) {
                            setState(() {
                              _originAirport = picked;
                              _validationError = null;
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                ),
                                child: const Icon(Icons.flight_takeoff_rounded, color: AppColors.primary, size: 22),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr('flight_from'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                      ),
                                    ),
                                    Text(
                                      '${_originAirport.getCity(isArabic: isArabic)} (${_originAirport.code})',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 16),

                      // Destination Airport
                      InkWell(
                        onTap: () async {
                          final picked = await AirportPickerSheet.show(
                            context,
                            selectedAirport: _destAirport,
                            title: context.tr('flight_to'),
                          );
                          if (picked != null) {
                            setState(() {
                              _destAirport = picked;
                              _validationError = null;
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                ),
                                child: const Icon(Icons.flight_land_rounded, color: AppColors.secondary, size: 22),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr('flight_to'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                      ),
                                    ),
                                    Text(
                                      '${_destAirport.getCity(isArabic: isArabic)} (${_destAirport.code})',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Swap Floating Action Button
                  Positioned(
                    right: isArabic ? null : 8,
                    left: isArabic ? 8 : null,
                    child: Material(
                      color: AppColors.primary,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: InkWell(
                        onTap: _swapAirports,
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.swap_vert_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Dates Row
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    onTap: _selectDepartureDate,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              context.tr('flight_departure_date'),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppDateFormatter.formatShortDate(_departureDate, locale: isArabic ? 'ar' : 'en'),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_tripType == TripType.roundTrip) ...[
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: CustomCard(
                      onTap: _selectReturnDate,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.secondary),
                              const SizedBox(width: 6),
                              Text(
                                context.tr('flight_return_date'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppDateFormatter.formatShortDate(_returnDate, locale: isArabic ? 'ar' : 'en'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Passengers & Cabin Class
            CustomCard(
              onTap: _openPassengerPicker,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(Icons.people_outline_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${context.tr('flight_passengers')} & ${context.tr('flight_cabin_class')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_adults + _children + _infants} ${context.tr('flight_passengers')} • ${_cabinClass.name.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Direct Flights Only Switch
            Row(
              children: [
                Checkbox(
                  value: _directOnly,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _directOnly = val ?? false),
                ),
                GestureDetector(
                  onTap: () => setState(() => _directOnly = !_directOnly),
                  child: Text(
                    context.tr('flight_direct_only'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ],
            ),

            // Validation error message if any
            if (_validationError != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _validationError!,
                        style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),

            // Search CTA
            CustomButton(
              text: context.tr('flight_search_action'),
              onPressed: _performSearch,
              icon: Icons.search_rounded,
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
