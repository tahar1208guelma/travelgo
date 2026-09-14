import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../home/presentation/screens/main_navigation_screen.dart';
import '../../domain/entities/favorite_item_entity.dart';
import '../controllers/favorites_controller.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final currency = ref.watch(currencyProvider);
    final favorites = ref.watch(favoritesControllerProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          context.tr('favorites_title'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: favorites.isEmpty
          ? EmptyStateView(
              title: context.tr('favorites_empty_title'),
              description: context.tr('favorites_empty_desc'),
              actionText: 'Explore Trips',
              onActionTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                  (route) => false,
                );
              },
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final item = favorites[index];

                return CustomCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        child: CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 64,
                            height: 64,
                            color: AppColors.primaryContainer,
                            child: Icon(
                              item.type == 'flight' ? Icons.flight : Icons.hotel,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppCurrencyFormatter.format(item.priceUSD, currency, locale: isArabic ? 'ar' : 'en'),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: isDark ? AppColors.primaryLight : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_rounded, color: AppColors.error),
                        onPressed: () {
                          ref.read(favoritesControllerProvider.notifier).toggleFavorite(item);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
