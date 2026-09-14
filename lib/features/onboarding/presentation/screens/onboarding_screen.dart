import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../authentication/presentation/screens/login_screen.dart';
import '../../../favorites/presentation/controllers/favorites_controller.dart';
import '../../../home/presentation/screens/main_navigation_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _finishOnboarding() async {
    final storage = ref.read(storageServiceProvider);
    await storage.setOnboardingSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, String>> pages = [
      {
        'title': context.tr('onboarding_title_1'),
        'desc': context.tr('onboarding_desc_1'),
        'image': AppAssets.onboarding1,
      },
      {
        'title': context.tr('onboarding_title_2'),
        'desc': context.tr('onboarding_desc_2'),
        'image': AppAssets.onboarding2,
      },
      {
        'title': context.tr('onboarding_title_3'),
        'desc': context.tr('onboarding_desc_3'),
        'image': AppAssets.onboarding3,
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Language Selector & Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                          Icon(
                            Icons.language_rounded,
                            size: 18,
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isArabic ? 'English' : 'العربية',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.primaryLight : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_currentPage < 2)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        context.tr('skip'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                            child: CachedNetworkImage(
                              imageUrl: page['image']!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) => Container(
                                color: isDark ? AppColors.surfaceDark : AppColors.primaryContainer,
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: isDark ? AppColors.surfaceDark : AppColors.primaryContainer,
                                child: const Icon(Icons.flight, size: 64, color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          page['desc']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicator and Bottom Controls
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: isDark ? AppColors.cardDark : AppColors.dividerLight,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3.5,
                      spacing: 6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_currentPage == 2)
                    CustomButton(
                      text: context.tr('get_started'),
                      onPressed: _finishOnboarding,
                      type: ButtonType.primary,
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: context.tr('next'),
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                              );
                            },
                            type: ButtonType.primary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
