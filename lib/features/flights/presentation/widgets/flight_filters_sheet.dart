import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../controllers/flight_search_controller.dart';

class FlightFiltersSheet extends StatefulWidget {
  final FlightFilterState currentFilter;

  const FlightFiltersSheet({super.key, required this.currentFilter});

  static Future<FlightFilterState?> show(BuildContext context, {required FlightFilterState currentFilter}) {
    return showModalBottomSheet<FlightFilterState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FlightFiltersSheet(currentFilter: currentFilter),
    );
  }

  @override
  State<FlightFiltersSheet> createState() => _FlightFiltersSheetState();
}

class _FlightFiltersSheetState extends State<FlightFiltersSheet> {
  late FlightSortOption _sortOption;
  late int? _maxStops;
  late String? _airlineFilter;
  late double? _maxPriceUSD;

  @override
  void initState() {
    super.initState();
    _sortOption = widget.currentFilter.sortOption;
    _maxStops = widget.currentFilter.maxStops;
    _airlineFilter = widget.currentFilter.airlineFilter;
    _maxPriceUSD = widget.currentFilter.maxPriceUSD;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters & Sorting',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _sortOption = FlightSortOption.cheapest;
                        _maxStops = null;
                        _airlineFilter = null;
                        _maxPriceUSD = null;
                      });
                    },
                    child: Text(context.tr('reset')),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Sort Options
              Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(context.tr('flight_filter_cheapest')),
                    selected: _sortOption == FlightSortOption.cheapest,
                    onSelected: (val) => setState(() => _sortOption = FlightSortOption.cheapest),
                  ),
                  ChoiceChip(
                    label: Text(context.tr('flight_filter_fastest')),
                    selected: _sortOption == FlightSortOption.fastest,
                    onSelected: (val) => setState(() => _sortOption = FlightSortOption.fastest),
                  ),
                  ChoiceChip(
                    label: Text(context.tr('flight_filter_best')),
                    selected: _sortOption == FlightSortOption.bestValue,
                    onSelected: (val) => setState(() => _sortOption = FlightSortOption.bestValue),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Stops Filter
              Text(
                'Stops',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(context.tr('flight_filter_all')),
                    selected: _maxStops == null,
                    onSelected: (val) => setState(() => _maxStops = null),
                  ),
                  ChoiceChip(
                    label: Text(context.tr('flight_stops_direct')),
                    selected: _maxStops == 0,
                    onSelected: (val) => setState(() => _maxStops = 0),
                  ),
                  ChoiceChip(
                    label: Text('Max 1 Stop'),
                    selected: _maxStops == 1,
                    onSelected: (val) => setState(() => _maxStops = 1),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Preferred Airlines
              Text(
                'Airlines',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Emirates', 'Qatar Airways', 'Turkish Airlines', 'Air Algérie', 'Saudia', 'British Airways']
                    .map((airline) {
                  final isSelected = _airlineFilter == airline;
                  return FilterChip(
                    label: Text(airline),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _airlineFilter = selected ? airline : null);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Apply Button
              CustomButton(
                text: context.tr('apply'),
                onPressed: () {
                  Navigator.of(context).pop(
                    FlightFilterState(
                      sortOption: _sortOption,
                      maxStops: _maxStops,
                      airlineFilter: _airlineFilter,
                      maxPriceUSD: _maxPriceUSD,
                    ),
                  );
                },
                type: ButtonType.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
