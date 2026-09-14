import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../controllers/hotel_search_controller.dart';

class HotelFiltersSheet extends StatefulWidget {
  final HotelFilterState currentFilter;

  const HotelFiltersSheet({super.key, required this.currentFilter});

  static Future<HotelFilterState?> show(BuildContext context, {required HotelFilterState currentFilter}) {
    return showModalBottomSheet<HotelFilterState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HotelFiltersSheet(currentFilter: currentFilter),
    );
  }

  @override
  State<HotelFiltersSheet> createState() => _HotelFiltersSheetState();
}

class _HotelFiltersSheetState extends State<HotelFiltersSheet> {
  late HotelSortOption _sortOption;
  late int? _minStarRating;
  late bool _freeCancellationOnly;
  late bool _breakfastIncludedOnly;

  @override
  void initState() {
    super.initState();
    _sortOption = widget.currentFilter.sortOption;
    _minStarRating = widget.currentFilter.minStarRating;
    _freeCancellationOnly = widget.currentFilter.freeCancellationOnly;
    _breakfastIncludedOnly = widget.currentFilter.breakfastIncludedOnly;
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
                    'Filter & Sort Hotels',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _sortOption = HotelSortOption.popular;
                        _minStarRating = null;
                        _freeCancellationOnly = false;
                        _breakfastIncludedOnly = false;
                      });
                    },
                    child: Text(context.tr('reset')),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Sort
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
                    label: const Text('Most Popular'),
                    selected: _sortOption == HotelSortOption.popular,
                    onSelected: (_) => setState(() => _sortOption = HotelSortOption.popular),
                  ),
                  ChoiceChip(
                    label: const Text('Highest Rating'),
                    selected: _sortOption == HotelSortOption.ratingHighToLow,
                    onSelected: (_) => setState(() => _sortOption = HotelSortOption.ratingHighToLow),
                  ),
                  ChoiceChip(
                    label: const Text('Lowest Price'),
                    selected: _sortOption == HotelSortOption.priceLowToHigh,
                    onSelected: (_) => setState(() => _sortOption = HotelSortOption.priceLowToHigh),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Star Rating
              Text(
                'Star Rating',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                children: [5, 4, 3].map((stars) {
                  final isSelected = _minStarRating == stars;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$stars '),
                        const Icon(Icons.star, size: 14, color: AppColors.secondary),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _minStarRating = selected ? stars : null);
                    },
                  );
                }).toList(),
              ),
              const Divider(height: 24),

              // Checkbox Preferences
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr('hotel_free_cancellation')),
                value: _freeCancellationOnly,
                onChanged: (val) => setState(() => _freeCancellationOnly = val ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr('hotel_breakfast_included')),
                value: _breakfastIncludedOnly,
                onChanged: (val) => setState(() => _breakfastIncludedOnly = val ?? false),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Apply Button
              CustomButton(
                text: context.tr('apply'),
                onPressed: () {
                  Navigator.of(context).pop(
                    HotelFilterState(
                      sortOption: _sortOption,
                      minStarRating: _minStarRating,
                      freeCancellationOnly: _freeCancellationOnly,
                      breakfastIncludedOnly: _breakfastIncludedOnly,
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
