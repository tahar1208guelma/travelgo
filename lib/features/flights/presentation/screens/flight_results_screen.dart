import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../controllers/flight_search_controller.dart';
import '../widgets/flight_card.dart';
import '../widgets/flight_filters_sheet.dart';
import 'flight_details_screen.dart';

class FlightResultsScreen extends ConsumerWidget {
  const FlightResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final searchState = ref.watch(flightSearchControllerProvider);
    final flights = searchState.filteredFlights;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              '${searchState.params.originCode} ➔ ${searchState.params.destinationCode}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            Text(
              '${flights.length} ${context.tr('flight_found_count')}',
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
                if (searchState.filterState.maxStops != null || searchState.filterState.airlineFilter != null)
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
              final newFilter = await FlightFiltersSheet.show(
                context,
                currentFilter: searchState.filterState,
              );
              if (newFilter != null) {
                ref.read(flightSearchControllerProvider.notifier).updateFilter(newFilter);
              }
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (searchState.isLoading) {
            return const LoadingIndicator(message: 'Searching live flight routes...');
          }

          if (searchState.errorMessage != null) {
            return ErrorView(
              message: searchState.errorMessage!,
              onRetry: () => ref.read(flightSearchControllerProvider.notifier).searchFlights(),
            );
          }

          if (flights.isEmpty) {
            return EmptyStateView(
              title: 'No Flights Found',
              description: 'Try adjusting your dates, removing filters, or selecting nearby airports.',
              actionText: 'Adjust Search',
              onActionTap: () => Navigator.of(context).pop(),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: flights.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final flight = flights[index];
              return FlightCard(
                flight: flight,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FlightDetailsScreen(flight: flight),
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
