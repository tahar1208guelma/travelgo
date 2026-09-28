import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../bookings/domain/entities/booking_entity.dart';
import '../../../bookings/presentation/screens/booking_summary_screen.dart';
import '../../domain/entities/unified_search_result_entity.dart';
import '../controllers/unified_search_controller.dart';
import '../widgets/interactive_map_view.dart';
import '../widgets/search_filter_bottom_sheet.dart';
import '../widgets/unified_search_card.dart';

class UnifiedSearchScreen extends ConsumerStatefulWidget {
  const UnifiedSearchScreen({super.key});

  @override
  ConsumerState<UnifiedSearchScreen> createState() => _UnifiedSearchScreenState();
}

class _UnifiedSearchScreenState extends ConsumerState<UnifiedSearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  int _activeCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'labelEn': 'All', 'labelAr': 'الكل', 'type': AccommodationType.all, 'icon': Icons.explore_rounded},
    {'labelEn': 'Hotels', 'labelAr': 'فنادق', 'type': AccommodationType.hotel, 'icon': Icons.hotel_rounded},
    {'labelEn': 'Apartments', 'labelAr': 'شقق', 'type': AccommodationType.apartment, 'icon': Icons.apartment_rounded},
    {'labelEn': 'Desert Camps', 'labelAr': 'رحلات صحراوية', 'type': AccommodationType.desertCamp, 'icon': Icons.terrain_rounded},
    {'labelEn': 'Family Deals', 'labelAr': 'عروض عائلية', 'type': AccommodationType.all, 'icon': Icons.family_restroom_rounded},
    {'labelEn': 'Budget Friendly', 'labelAr': 'اقتصادي', 'type': AccommodationType.all, 'icon': Icons.savings_rounded},
  ];

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _onCategorySelected(int index) {
    setState(() => _activeCategoryIndex = index);
    final cat = _categories[index];
    if (index == 4) {
      // Family Deals: Filter breakfast & cancellation
      ref.read(unifiedSearchControllerProvider.notifier).toggleBreakfastIncluded(true);
      ref.read(unifiedSearchControllerProvider.notifier).toggleFreeCancellation(true);
    } else if (index == 5) {
      // Budget: Filter max price to $100
      ref.read(unifiedSearchControllerProvider.notifier).updatePriceRange(0, 100);
    } else {
      ref.read(unifiedSearchControllerProvider.notifier).updateCategory(cat['type'] as AccommodationType);
    }
  }

  void _handleBooking(UnifiedSearchResultEntity item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingSummaryScreen(
          bookingType: item.type == AccommodationType.flight ? BookingType.flight : BookingType.hotel,
          itemId: item.id,
          itemName: item.title,
          itemSubtitle: item.subtitle,
          itemImageUrl: item.imageUrl,
          startDate: DateTime.now().add(const Duration(days: 7)),
          endDate: DateTime.now().add(const Duration(days: 10)),
          basePriceUSD: item.price,
          taxesUSD: item.price * 0.12,
          isAffiliate: item.source.contains('affiliate'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final viewMode = ref.watch(searchDisplayModeProvider);
    final searchState = ref.watch(unifiedSearchControllerProvider);
    final filters = ref.watch(searchFiltersProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Skyscanner + Booking.com Top Search Bar & Controls Header
            Container(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                boxShadow: isDark ? null : AppColors.softCardShadow,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Main Input Row: Search Field, Filter Button & View Toggle
                  Row(
                    children: [
                      // Search Query Field
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          child: TextField(
                            controller: _queryController,
                            onChanged: (val) {
                              ref.read(unifiedSearchControllerProvider.notifier).updateQueryDebounced(val);
                            },
                            decoration: InputDecoration(
                              hintText: isArabic
                                  ? 'ابحث عن فندق، شقة، مخيم صحراوي، وجهة...'
                                  : 'Where to? (Hotels, desert camps, apartments...)',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: isDark ? AppColors.secondaryLight : AppColors.primary,
                                size: 22,
                              ),
                              suffixIcon: _queryController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 18),
                                      onPressed: () {
                                        _queryController.clear();
                                        ref.read(unifiedSearchControllerProvider.notifier).updateQueryDebounced('');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),

                      // Filter Button with Active Dot
                      Stack(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.tune_rounded,
                              color: isDark ? AppColors.secondaryLight : AppColors.primary,
                            ),
                            tooltip: 'Filter',
                            onPressed: () => SearchFilterBottomSheet.show(context),
                          ),
                          if (filters.minPrice > 0 || filters.maxPrice < 2000 || filters.minRating > 0 || filters.freeCancellationOnly)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Grid vs Map View Toggle Pill
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => ref.read(searchDisplayModeProvider.notifier).state = SearchDisplayMode.grid,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: viewMode == SearchDisplayMode.grid
                                      ? (isDark ? AppColors.secondary : AppColors.primary)
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.grid_view_rounded,
                                  size: 18,
                                  color: viewMode == SearchDisplayMode.grid
                                      ? Colors.white
                                      : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => ref.read(searchDisplayModeProvider.notifier).state = SearchDisplayMode.map,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: viewMode == SearchDisplayMode.map
                                      ? (isDark ? AppColors.secondary : AppColors.primary)
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.map_rounded,
                                  size: 18,
                                  color: viewMode == SearchDisplayMode.map
                                      ? Colors.white
                                      : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Category Filter Chips: [الكل, فنادق, شقق, رحلات صحراوية, عروض عائلية, اقتصادي]
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _activeCategoryIndex == index;

                        return GestureDetector(
                          onTap: () => _onCategorySelected(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? AppColors.secondary : AppColors.primary)
                                  : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  cat['icon'] as IconData,
                                  size: 15,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? AppColors.secondaryLight : AppColors.primary),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isArabic ? cat['labelAr'] : cat['labelEn'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 2. Main Content Area (Grid View vs Leaflet Map View)
            Expanded(
              child: searchState.when(
                loading: () => ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (_, __) => Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (e, _) => Center(
                  child: EmptyStateView(
                    icon: Icons.error_outline_rounded,
                    title: isArabic ? 'حدث خطأ في البحث' : 'Search Error',
                    subtitle: e.toString(),
                    actionText: isArabic ? 'إعادة المحاولة' : 'Try Again',
                    onAction: () => ref.read(unifiedSearchControllerProvider.notifier).executeSearch(),
                  ),
                ),
                data: (results) {
                  if (results.isEmpty) {
                    return Center(
                      child: EmptyStateView(
                        icon: Icons.search_off_rounded,
                        title: isArabic ? 'لم نجد أي نتائج مطابقة' : 'No Places Found',
                        subtitle: isArabic
                            ? 'جرب ضبط ميزانية السعر أو تغيير تصنيف مكان الإقامة.'
                            : 'Try adjusting your budget range, property type, or dates.',
                        actionText: isArabic ? 'إعادة ضبط الفلاتر' : 'Reset All Filters',
                        onAction: () {
                          _queryController.clear();
                          ref.read(unifiedSearchControllerProvider.notifier).resetFilters();
                        },
                      ),
                    );
                  }

                  // Render Map View
                  if (viewMode == SearchDisplayMode.map) {
                    return InteractiveMapView(
                      items: results,
                      onItemTap: _handleBooking,
                    );
                  }

                  // Render Responsive Grid View (Mobile: 1 Col, Tablet: 2 Col, Desktop: 3-4 Col)
                  return ResponsiveLayout(
                    mobile: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        return UnifiedSearchCard(
                          item: results[index],
                          onTap: () => _handleBooking(results[index]),
                        );
                      },
                    ),
                    tablet: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        return UnifiedSearchCard(
                          item: results[index],
                          onTap: () => _handleBooking(results[index]),
                        );
                      },
                    ),
                    desktop: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.88,
                      ),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        return UnifiedSearchCard(
                          item: results[index],
                          onTap: () => _handleBooking(results[index]),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
