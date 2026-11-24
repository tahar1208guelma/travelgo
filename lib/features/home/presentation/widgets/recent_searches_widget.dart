import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../flights/domain/entities/flight_search_params.dart';
import '../../../flights/presentation/controllers/flight_search_controller.dart';
import '../../../flights/presentation/screens/flight_results_screen.dart';

class RecentSearchesWidget extends ConsumerWidget {
  const RecentSearchesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final isFrench = ref.watch(languageProvider.notifier).isFrench;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final recentSearches = [
      {
        'from': 'ALG',
        'to': 'DXB',
        'fromCity': isArabic ? 'الجزائر' : (isFrench ? 'Alger' : 'Algiers'),
        'toCity': isArabic ? 'دبي' : (isFrench ? 'Dubaï' : 'Dubai'),
        'fromCityEn': 'Algiers',
        'toCityEn': 'Dubai',
      },
      {
        'from': 'ALG',
        'to': 'IST',
        'fromCity': isArabic ? 'الجزائر' : (isFrench ? 'Alger' : 'Algiers'),
        'toCity': isArabic ? 'إسطنبول' : 'Istanbul',
        'fromCityEn': 'Algiers',
        'toCityEn': 'Istanbul',
      },
      {
        'from': 'DXB',
        'to': 'CDG',
        'fromCity': isArabic ? 'دبي' : (isFrench ? 'Dubaï' : 'Dubai'),
        'toCity': isArabic ? 'باريس' : 'Paris',
        'fromCityEn': 'Dubai',
        'toCityEn': 'Paris',
      },
      {
        'from': 'LHR',
        'to': 'JFK',
        'fromCity': isArabic ? 'لندن' : (isFrench ? 'Londres' : 'London'),
        'toCity': isArabic ? 'نيويورك' : 'New York',
        'fromCityEn': 'London',
        'toCityEn': 'New York',
      },
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
                    originCity: item['fromCityEn']!,
                    destinationCode: item['to']!,
                    destinationCity: item['toCityEn']!,
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
                        item['fromCity']!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Transform.scale(
                        scaleX: isRtl ? -1 : 1,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: isDark ? AppColors.secondaryLight : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['toCity']!,
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
