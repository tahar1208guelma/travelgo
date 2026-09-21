import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../flights/presentation/screens/flight_results_screen.dart';
import '../../../hotels/presentation/screens/hotel_results_screen.dart';
import '../controllers/ai_search_controller.dart';
import 'ai_missing_fields_modal.dart';

class AISearchEntryBar extends ConsumerStatefulWidget {
  final bool isHotel;

  const AISearchEntryBar({super.key, this.isHotel = false});

  @override
  ConsumerState<AISearchEntryBar> createState() => _AISearchEntryBarState();
}

class _AISearchEntryBarState extends ConsumerState<AISearchEntryBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _executeSearch(String query) async {
    if (query.trim().isEmpty) return;
    final isArabic = ref.read(languageProvider.notifier).isArabic;

    final intent = await ref
        .read(aiSearchControllerProvider.notifier)
        .processNaturalSearch(query, isArabic: isArabic);

    if (intent == null) return;

    if (!mounted) return;

    if (intent.isComplete) {
      if (intent.isFlightSearch) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FlightResultsScreen()),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HotelResultsScreen()),
        );
      }
    } else {
      // Incomplete -> Prompt user for missing fields via clarification sheet
      AIMissingFieldsModal.show(context, intent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final aiSearchState = ref.watch(aiSearchControllerProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: CustomCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        customBorder: BorderSide(
          color: AppColors.primary.withOpacity(0.4),
          width: 1.5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with AI Sparkle badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.isHotel
                        ? context.tr('ai_search_banner_hotel')
                        : context.tr('ai_search_banner_flight'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('ai_search_banner_desc'),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Search Input Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: _executeSearch,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: widget.isHotel
                            ? context.tr('ai_search_hotel_input_hint')
                            : context.tr('ai_search_input_hint'),
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ),
                  ),
                  if (aiSearchState.isParsing)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.primary, size: 20),
                      onPressed: () => _executeSearch(_controller.text),
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
