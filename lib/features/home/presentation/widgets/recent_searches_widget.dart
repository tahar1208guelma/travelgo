import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../flights/domain/entities/flight_search_params.dart';
import '../../../flights/presentation/controllers/flight_search_controller.dart';
import '../../../flights/presentation/screens/flight_results_screen.dart';

class RecentSearchesWidget extends ConsumerWidget {
  const RecentSearchesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final recentSearches = [
      {'from': 'ALG', 'to': 'DXB', 'fromCity': 'Algiers', 'toCity': 'Dubai'},
      {'from': 'ALG', 'to': 'IST', 'fromCity': 'Algiers', 'toCity': 'Istanbul'},
      {'from': 'DXB', 'to': 'CDG', 'fromCity': 'Dubai', 'toCity': 'Paris'},
      {'from': 'LHR', 'to': 'JFK', 'fromCity': 'London', 'toCity': 'New York'},
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: recentSearches.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final item = recentSearches[index];

          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              boxShadow: isDark ? null : AppColors.softCardShadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final params = FlightSearchParams(
                    originCode: item['from']!,
                    originCity: item['fromCity']!,
                    destinationCode: item['to']!,
                    destinationCity: item['toCity']!,
                    departureDate: DateTime.now().add(const Duration(days: 7)),
                  );
                  ref.read(flightSearchControllerProvider.notifier).updateSearchParams(params);
                  ref.read(flightSearchControllerProvider.notifier).searchFlights();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FlightResultsScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 16,
                        color: isDark ? AppColors.secondaryLight : AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${item['fromCity']} ➔ ${item['toCity']}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
