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
      {'from': 'ALG', 'to': 'DXB', 'fromCity': 'Algiers', 'toCity': 'Dubai', 'type': 'flight'},
      {'from': 'ALG', 'to': 'IST', 'fromCity': 'Algiers', 'toCity': 'Istanbul', 'type': 'flight'},
      {'from': 'DXB', 'to': 'CDG', 'fromCity': 'Dubai', 'toCity': 'Paris', 'type': 'flight'},
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: recentSearches.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = recentSearches[index];

          return ActionChip(
            avatar: const Icon(Icons.history_rounded, size: 16, color: AppColors.primary),
            label: Text('${item['from']} ➔ ${item['to']}'),
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.cardLight,
            onPressed: () {
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
          );
        },
      ),
    );
  }
}
