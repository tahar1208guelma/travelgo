import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/unified_search_result_entity.dart';
import '../controllers/unified_search_controller.dart';

class SearchFilterBottomSheet extends ConsumerStatefulWidget {
  const SearchFilterBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SearchFilterBottomSheet(),
    );
  }

  @override
  ConsumerState<SearchFilterBottomSheet> createState() => _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends ConsumerState<SearchFilterBottomSheet> {
  late RangeValues _priceRange;
  late double _minRating;
  late AccommodationType _selectedType;
  late bool _freeCancellationOnly;
  late bool _breakfastIncludedOnly;
  late SearchSortBy _sortBy;
  late List<String> _selectedAmenities;

  final List<String> _availableAmenities = [
    'WiFi',
    'Pool',
    'Breakfast',
    'Spa',
    'Sea View',
    'Free Parking',
    'Kitchen',
    'Air Conditioning',
  ];

  @override
  void initState() {
    super.initState();
    final filters = ref.read(searchFiltersProvider);
    _priceRange = RangeValues(filters.minPrice, filters.maxPrice.clamp(50, 2000));
    _minRating = filters.minRating;
    _selectedType = filters.accommodationType;
    _freeCancellationOnly = filters.freeCancellationOnly;
    _breakfastIncludedOnly = filters.breakfastIncludedOnly;
    _sortBy = filters.sortBy;
    _selectedAmenities = List.from(filters.requiredAmenities);
  }

  void _apply() {
    ref.read(searchFiltersProvider.notifier).state = ref.read(searchFiltersProvider).copyWith(
          minPrice: _priceRange.start,
          maxPrice: _priceRange.end,
          minRating: _minRating,
          accommodationType: _selectedType,
          freeCancellationOnly: _freeCancellationOnly,
          breakfastIncludedOnly: _breakfastIncludedOnly,
          sortBy: _sortBy,
          requiredAmenities: _selectedAmenities,
        );
    ref.read(unifiedSearchControllerProvider.notifier).executeSearch();
    Navigator.of(context).pop();
  }

  void _reset() {
    setState(() {
      _priceRange = const RangeValues(0, 2000);
      _minRating = 0;
      _selectedType = AccommodationType.all;
      _freeCancellationOnly = false;
      _breakfastIncludedOnly = false;
      _sortBy = SearchSortBy.relevance;
      _selectedAmenities = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final currency = ref.watch(currencyProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _reset,
                  child: Text(
                    isArabic ? 'إعادة ضبط' : 'Reset All',
                    style: TextStyle(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  isArabic ? 'تصفية النتائج' : 'Search Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Filter Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // 1. Budget Price Range Slider
                Text(
                  isArabic ? 'ميزانية الليلة (السعر)' : 'Price Per Night (Budget)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppCurrencyFormatter.format(_priceRange.start, currency, locale: isArabic ? 'ar' : 'en'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.secondaryLight : AppColors.primary,
                      ),
                    ),
                    Text(
                      _priceRange.end >= 2000
                          ? '${AppCurrencyFormatter.format(2000, currency, locale: isArabic ? 'ar' : 'en')}+'
                          : AppCurrencyFormatter.format(_priceRange.end, currency, locale: isArabic ? 'ar' : 'en'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.secondaryLight : AppColors.primary,
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 2000,
                  divisions: 40,
                  activeColor: isDark ? AppColors.secondary : AppColors.primary,
                  onChanged: (vals) => setState(() => _priceRange = vals),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 2. Accommodation Type
                Text(
                  isArabic ? 'نوع مكان الإقامة' : 'Property Type',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTypeChip('الكل / All', AccommodationType.all),
                    _buildTypeChip('فنادق / Hotels', AccommodationType.hotel),
                    _buildTypeChip('شقق / Apartments', AccommodationType.apartment),
                    _buildTypeChip('مخيمات صحراوية / Desert Camps', AccommodationType.desertCamp),
                    _buildTypeChip('نزل / Hostels', AccommodationType.hostel),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // 3. Minimum Star Rating
                Text(
                  isArabic ? 'الحد الأدنى للتقييم' : 'Minimum Rating',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildRatingChip('Any', 0),
                    _buildRatingChip('★ 3.5+', 3.5),
                    _buildRatingChip('★ 4.0+', 4.0),
                    _buildRatingChip('★ 4.5+', 4.5),
                    _buildRatingChip('★ 4.8+', 4.8),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // 4. Amenities Multi-select
                Text(
                  isArabic ? 'المرافق والخدمات' : 'Amenities & Perks',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableAmenities.map((amenity) {
                    final isSelected = _selectedAmenities.contains(amenity);
                    return FilterChip(
                      label: Text(amenity),
                      selected: isSelected,
                      selectedColor: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.2),
                      checkmarkColor: isDark ? AppColors.secondaryLight : AppColors.primary,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedAmenities.add(amenity);
                          } else {
                            _selectedAmenities.remove(amenity);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 5. Policies & Flexibility Toggles
                SwitchListTile.adaptive(
                  title: Text(isArabic ? 'إلغاء مجاني فقط' : 'Free Cancellation Only'),
                  value: _freeCancellationOnly,
                  activeColor: AppColors.secondary,
                  onChanged: (v) => setState(() => _freeCancellationOnly = v),
                ),
                SwitchListTile.adaptive(
                  title: Text(isArabic ? 'شامل الإفطار فقط' : 'Breakfast Included'),
                  value: _breakfastIncludedOnly,
                  activeColor: AppColors.secondary,
                  onChanged: (v) => setState(() => _breakfastIncludedOnly = v),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 6. Sort By
                Text(
                  isArabic ? 'ترتيب حسب' : 'Sort Results By',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<SearchSortBy>(
                  value: _sortBy,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: [
                    DropdownMenuItem(value: SearchSortBy.relevance, child: Text(isArabic ? 'الأكثر ملائمة' : 'Most Relevant')),
                    DropdownMenuItem(value: SearchSortBy.priceLowToHigh, child: Text(isArabic ? 'السعر: من الأقل إلى الأعلى' : 'Price: Low to High')),
                    DropdownMenuItem(value: SearchSortBy.priceHighToLow, child: Text(isArabic ? 'السعر: من الأعلى إلى الأقل' : 'Price: High to Low')),
                    DropdownMenuItem(value: SearchSortBy.rating, child: Text(isArabic ? 'أعلى تقييم' : 'Highest Rating')),
                  ],
                  onChanged: (val) => setState(() => _sortBy = val!),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),

          // Bottom Apply Action Button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.secondary : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                ),
                child: Text(
                  isArabic ? 'تطبيق الفلاتر والبحث' : 'Apply Filters & Search',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, AccommodationType type) {
    final isSelected = _selectedType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.2),
      onSelected: (selected) {
        if (selected) setState(() => _selectedType = type);
      },
    );
  }

  Widget _buildRatingChip(String label, double rating) {
    final isSelected = _minRating == rating;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.2),
      onSelected: (selected) {
        if (selected) setState(() => _minRating = rating);
      },
    );
  }
}
