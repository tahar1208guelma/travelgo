import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/currency.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/badge_chip.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../home/presentation/screens/main_navigation_screen.dart';
import '../../domain/entities/favorite_item_entity.dart';
import '../controllers/favorites_controller.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final currency = ref.watch(currencyProvider);
    final favorites = ref.watch(favoritesControllerProvider);

    final flights = favorites.where((f) => f.type == 'flight').toList();
    final hotels = favorites.where((f) => f.type == 'hotel').toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isArabic ? 'المفضلة وقائمة الرغبات' : 'My Wishlist & Favorites',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.secondaryLight : AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          indicatorColor: isDark ? AppColors.secondaryLight : AppColors.primary,
          tabs: [
            Tab(text: '${isArabic ? "الكل" : "All"} (${favorites.length})'),
            Tab(text: '${isArabic ? "فنادق" : "Hotels"} (${hotels.length})'),
            Tab(text: '${isArabic ? "طيران" : "Flights"} (${flights.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFavoritesList(favorites, currency, isArabic, isDark),
          _buildFavoritesList(hotels, currency, isArabic, isDark),
          _buildFavoritesList(flights, currency, isArabic, isDark),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(
    List<FavoriteItemEntity> items,
    Currency currency,
    bool isArabic,
    bool isDark,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: EmptyStateView(
            icon: Icons.favorite_border_rounded,
            title: isArabic ? 'قائمة المفضلة فارغة' : 'Your Wishlist is Empty',
            subtitle: isArabic
                ? 'انقر على رمز القلب في أي فندق أو رحلة لحفظها والرجوع إليها لاحقاً.'
                : 'Tap the heart icon on any hotel or flight to save it for your next adventure.',
            actionText: isArabic ? 'استكشف الوجهات' : 'Explore Destinations',
            onAction: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                (route) => false,
              );
            },
          ),
        ),
      );
    }

    return ResponsiveWrapper(
      maxWidth: 900,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final item = items[index];

          return CustomCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      color: isDark ? AppColors.cardDarkElevated : AppColors.primaryContainer,
                      child: Icon(
                        item.type == 'flight' ? Icons.flight_rounded : Icons.hotel_rounded,
                        color: isDark ? AppColors.secondaryLight : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite_rounded, color: AppColors.accentCoral, size: 20),
                            onPressed: () {
                              ref.read(favoritesControllerProvider.notifier).toggleFavorite(item);
                            },
                          ),
                        ],
                      ),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppCurrencyFormatter.format(item.priceUSD, currency, locale: isArabic ? 'ar' : 'en'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.secondaryLight : AppColors.primary,
                            ),
                          ),
                          BadgeChip(
                            label: item.type.toUpperCase(),
                            backgroundColor: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.12),
                            textColor: isDark ? AppColors.secondaryLight : AppColors.primary,
                            fontSize: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
