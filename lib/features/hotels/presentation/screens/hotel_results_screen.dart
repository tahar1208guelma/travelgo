import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../controllers/hotel_search_controller.dart';
import '../widgets/hotel_card.dart';
import '../widgets/hotel_filters_sheet.dart';
import 'hotel_details_screen.dart';

class HotelResultsScreen extends ConsumerWidget {
  const HotelResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchState = ref.watch(hotelSearchControllerProvider);
    final hotels = searchState.filteredHotels;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              searchState.params.destination,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            Text(
              '${hotels.length} ${context.tr('hotel_found_count')}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.tune_rounded),
                if (searchState.filterState.minStarRating != null ||
                    searchState.filterState.freeCancellationOnly ||
                    searchState.filterState.breakfastIncludedOnly)
                  Positioned(
                    right: 0,
                    top: 0,
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
            onPressed: () async {
              final newFilter = await HotelFiltersSheet.show(
                context,
                currentFilter: searchState.filterState,
              );
              if (newFilter != null) {
                ref.read(hotelSearchControllerProvider.notifier).updateFilter(newFilter);
              }
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (searchState.isLoading) {
            return const LoadingIndicator(message: 'Finding best hotel rates...');
          }

          if (searchState.errorMessage != null) {
            return ErrorView(
              message: searchState.errorMessage!,
              onRetry: () => ref.read(hotelSearchControllerProvider.notifier).searchHotels(),
            );
          }

          if (hotels.isEmpty) {
            return EmptyStateView(
              title: 'No Hotels Found',
              description: 'Try adjusting your destination or filters to find available properties.',
              actionText: 'Adjust Search',
              onActionTap: () => Navigator.of(context).pop(),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: hotels.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final hotel = hotels[index];
              return HotelCard(
                hotel: hotel,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HotelDetailsScreen(hotel: hotel),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
