import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../flights/presentation/screens/flight_search_screen.dart';
import '../../../hotels/domain/entities/hotel_search_params.dart';
import '../../../hotels/presentation/controllers/hotel_search_controller.dart';
import '../../../hotels/presentation/screens/hotel_details_screen.dart';
import '../../../hotels/presentation/screens/hotel_search_screen.dart';
import '../../../hotels/presentation/widgets/hotel_card.dart';
import '../widgets/popular_destinations_carousel.dart';
import '../widgets/recent_searches_widget.dart';
import '../widgets/special_offers_banner.dart';

class HomeScreen extends ConsumerWidget {
  final void Function(int tabIndex) onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return context.tr('home_greeting_morning');
    } else if (hour < 17) {
      return context.tr('home_greeting_afternoon');
    } else {
      return context.tr('home_greeting_evening');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final user = ref.watch(authStateProvider).value;
    final hotelState = ref.watch(hotelSearchControllerProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Top Header Bar: Greeting, Profile & Language Switcher
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primaryContainer,
                          backgroundImage: user?.profileImage != null ? NetworkImage(user!.profileImage!) : null,
                          child: user?.profileImage == null
                              ? const Icon(Icons.person, color: AppColors.primary)
                              : null,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(context),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                            Text(
                              user?.name ?? 'Traveler',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Language Switcher Badge
                    InkWell(
                      onTap: () => ref.read(languageProvider.notifier).toggleLanguage(),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.language_rounded, size: 16, color: isDark ? AppColors.primaryLight : AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              isArabic ? 'English' : 'العربية',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.primaryLight : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Headline / Where to go
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  context.tr('home_where_to'),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Main Search Feature Cards (Flights & Hotels)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    // Flight Card
                    Expanded(
                      child: CustomCard(
                        onTap: () => onNavigateTab(1), // Flights tab
                        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              ),
                              child: const Icon(Icons.flight_takeoff_rounded, color: AppColors.primary, size: 28),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              context.tr('home_tab_flights'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Search 500+ airlines',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Hotel Card
                    Expanded(
                      child: CustomCard(
                        onTap: () => onNavigateTab(2), // Hotels tab
                        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              ),
                              child: const Icon(Icons.hotel_rounded, color: AppColors.secondary, size: 28),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              context.tr('home_tab_hotels'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Luxury & Budget stays',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Recent Searches
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: SectionHeader(
                  title: context.tr('home_recent_searches'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const RecentSearchesWidget(),
              const SizedBox(height: AppSpacing.lg),

              // Special Offers Promotional Banner
              const SpecialOffersBanner(),
              const SizedBox(height: AppSpacing.lg),

              // Popular Destinations Carousel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: SectionHeader(
                  title: context.tr('home_popular_destinations'),
                  actionTitle: context.tr('view_all'),
                  onActionTap: () => onNavigateTab(1),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const PopularDestinationsCarousel(),
              const SizedBox(height: AppSpacing.lg),

              // Featured Hotels Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: SectionHeader(
                  title: context.tr('home_recommended_hotels'),
                  actionTitle: context.tr('view_all'),
                  onActionTap: () => onNavigateTab(2),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (hotelState.rawHotels.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Column(
                    children: hotelState.rawHotels.take(2).map((hotel) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: HotelCard(
                          hotel: hotel,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => HotelDetailsScreen(hotel: hotel)),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
