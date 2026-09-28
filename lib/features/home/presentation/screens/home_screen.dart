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
import '../../../ai_agent/presentation/screens/ai_travel_agent_screen.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../hotels/presentation/controllers/hotel_search_controller.dart';
import '../../../hotels/presentation/screens/hotel_details_screen.dart';
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
          physics: const BouncingScrollPhysics(),
          child: ResponsiveWrapper(
            maxWidth: 1200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Luxury Header Bar (Greeting, Profile, Theme Toggle, Language Switcher)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: isDark ? AppColors.cardDarkElevated : AppColors.primaryContainer,
                              backgroundImage: user?.profileImage != null ? NetworkImage(user!.profileImage!) : null,
                              child: user?.profileImage == null
                                  ? Icon(Icons.person_rounded, color: isDark ? AppColors.secondaryLight : AppColors.primary)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(context),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                              Text(
                                user?.name ?? 'Traveler',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Quick Header Action Controls (Dark Mode Toggle & Language Toggle)
                      Row(
                        children: [
                          // Theme Switcher Button
                          IconButton(
                            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                            icon: Icon(
                              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                              color: isDark ? AppColors.accentGold : AppColors.primary,
                              size: 22,
                            ),
                            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                          ),

                          // Language Switcher Pill
                          InkWell(
                            onTap: () => ref.read(languageProvider.notifier).toggleLanguage(),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.cardDark : AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                border: Border.all(
                                  color: (isDark ? AppColors.borderDark : AppColors.primaryLight).withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.language_rounded,
                                    size: 15,
                                    color: isDark ? AppColors.secondaryLight : AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isArabic ? 'English' : 'العربية',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.secondaryLight : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // 2. Airbnb-Style Floating Search Bar ("Where to?", "Any destination • Any week")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      boxShadow: isDark ? AppColors.darkCardShadow : AppColors.softCardShadow,
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onNavigateTab(1), // Open Flight/Hotel search
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr('home_where_to'),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Anywhere • Any week • Add guests',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                  ),
                                ),
                                child: Icon(
                                  Icons.tune_rounded,
                                  size: 18,
                                  color: isDark ? AppColors.secondaryLight : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // 3. AI Travel Concierge Luxury Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      boxShadow: isDark ? AppColors.darkCardShadow : AppColors.softCardShadow,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AITravelAgentScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          context.tr('ai_assistant_title'),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary,
                                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                          ),
                                          child: const Text(
                                            'AI 2.0',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      context.tr('ai_assistant_subtitle'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withValues(alpha: 0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // 4. Quick Category Navigation Grid (Flights & Hotels)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      // Flights Pill
                      Expanded(
                        child: CustomCard(
                          onTap: () => onNavigateTab(1),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                ),
                                child: Icon(
                                  Icons.flight_takeoff_rounded,
                                  color: isDark ? AppColors.secondaryLight : AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr('home_tab_flights'),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    Text(
                                      '500+ Airlines',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Hotels Pill
                      Expanded(
                        child: CustomCard(
                          onTap: () => onNavigateTab(2),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                ),
                                child: const Icon(
                                  Icons.hotel_rounded,
                                  color: AppColors.secondary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr('home_tab_hotels'),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    Text(
                                      'Luxury Stays',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                      ),
                                    ),
                                  ],
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

                // 5. Recent Searches
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(
                    context.tr('home_recent_searches'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const RecentSearchesWidget(),
                const SizedBox(height: AppSpacing.lg),

                // 6. Popular Destinations Carousel
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: SectionHeader(
                    title: context.tr('home_popular_destinations'),
                    actionTitle: 'Explore All',
                    onActionTap: () => onNavigateTab(1),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const PopularDestinationsCarousel(),
                const SizedBox(height: AppSpacing.lg),

                // 7. Booking Genius Special Offers Banner
                const SpecialOffersBanner(),
                const SizedBox(height: AppSpacing.lg),

                // 8. Featured Luxury Hotels Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: SectionHeader(
                    title: context.tr('home_featured_hotels'),
                    actionTitle: 'View All',
                    onActionTap: () => onNavigateTab(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (hotelState.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (hotelState.errorMessage != null)
                  Center(child: Text('Error: ${hotelState.errorMessage}'))
                else ...[
                  Builder(
                    builder: (context) {
                      final hotels = hotelState.filteredHotels;
                      if (hotels.isEmpty) return const SizedBox.shrink();
                      final topHotels = hotels.take(3).toList();
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        itemCount: topHotels.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final hotel = topHotels[index];
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
                ],
                const SizedBox(height: AppSpacing.xl),

                // 9. Trust & Security Assurance Footer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTrustItem(
                              icon: Icons.lock_outline_rounded,
                              title: '256-Bit SSL',
                              subtitle: 'Secure Payments',
                              isDark: isDark,
                            ),
                            _buildTrustItem(
                              icon: Icons.verified_user_outlined,
                              title: '100% Verified',
                              subtitle: 'Real Reviews',
                              isDark: isDark,
                            ),
                            _buildTrustItem(
                              icon: Icons.support_agent_rounded,
                              title: '24/7 Support',
                              subtitle: 'Instant Help',
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrustItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isDark ? AppColors.secondaryLight : AppColors.primary, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      ],
    );
  }
}
