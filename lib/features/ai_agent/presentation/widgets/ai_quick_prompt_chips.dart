import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class AIQuickPromptChips extends StatefulWidget {
  final bool isArabic;
  final void Function(String prompt) onSelectPrompt;

  const AIQuickPromptChips({
    super.key,
    required this.isArabic,
    required this.onSelectPrompt,
  });

  @override
  State<AIQuickPromptChips> createState() => _AIQuickPromptChipsState();
}

class _AIQuickPromptChipsState extends State<AIQuickPromptChips> {
  String _selectedCategory = 'all';

  List<Map<String, dynamic>> _getCategories(bool isAr) {
    return [
      {'id': 'all', 'label': isAr ? '🌟 الكل' : '🌟 All', 'icon': Icons.auto_awesome},
      {'id': 'family', 'label': isAr ? '👨‍👩‍👧 عائلية' : '👨‍👩‍👧 Family', 'icon': Icons.family_restroom},
      {'id': 'honeymoon', 'label': isAr ? '💍 شهر عسل' : '💍 Honeymoon', 'icon': Icons.favorite_border},
      {'id': 'budget', 'label': isAr ? '🎒 اقتصادية' : '🎒 Budget', 'icon': Icons.savings_outlined},
      {'id': 'beaches', 'label': isAr ? '🏖️ شواطئ' : '🏖️ Beaches', 'icon': Icons.beach_access},
      {'id': 'cultural', 'label': isAr ? '🕌 ثقافة ومعالم' : '🕌 Culture', 'icon': Icons.account_balance},
      {'id': 'shopping', 'label': isAr ? '🛍️ تسوق' : '🛍️ Shopping', 'icon': Icons.shopping_bag_outlined},
      {'id': 'faqs', 'label': isAr ? '❓ استفسارات' : '❓ FAQs', 'icon': Icons.help_outline},
    ];
  }

  Map<String, List<Map<String, dynamic>>> _getPromptsByCat(bool isAr) {
    if (isAr) {
      return {
        'all': [
          {'icon': Icons.explore_outlined, 'text': 'خطط لرحلة 4 أيام في باريس بأقل من 900 دولار'},
          {'icon': Icons.flight_takeoff, 'text': 'أرخص الرحلات المباشرة من الجزائر إلى دبي'},
          {'icon': Icons.hotel_outlined, 'text': 'فنادق فاخرة في إسطنبول مع إفطار مجاني'},
          {'icon': Icons.savings_outlined, 'text': 'توزيع ميزانية 1200 دولار لرحلة 5 أيام'},
          {'icon': Icons.family_restroom, 'text': 'برنامج سياحي عائلي 5 أيام في دبي مع أطفال'},
          {'icon': Icons.beach_access, 'text': 'أفضل منتجعات شاطئية شاملة في أنطاليا'},
        ],
        'family': [
          {'icon': Icons.family_restroom, 'text': 'برنامج سياحي عائلي 5 أيام في دبي مع أطفال'},
          {'icon': Icons.attractions_outlined, 'text': 'رحلة عائلية 5 أيام إلى باريس وديزني لاند'},
          {'icon': Icons.hotel_outlined, 'text': 'منتجعات مناسبة للعائلات في أنطاليا شاملة كل الوجبات'},
          {'icon': Icons.pool_outlined, 'text': 'فنادق مجهزة بألعاب مائية وأنشطة للأطفال'},
        ],
        'honeymoon': [
          {'icon': Icons.favorite_border, 'text': 'وجهات رومانسية هادئة في بالي والمالديف بميزانية متوسطة'},
          {'icon': Icons.restaurant_outlined, 'text': 'عطلة شهر عسل 7 أيام في روما وساحل أمالفي'},
          {'icon': Icons.cabin_outlined, 'text': 'أجمل أكواخ فوق الماء في المالديف للأزواج'},
          {'icon': Icons.photo_camera_outlined, 'text': 'أجمل أماكن التصوير الرومانسي في باريس'},
        ],
        'budget': [
          {'icon': Icons.savings_outlined, 'text': 'خطة سفر أوروبية اقتصادية لمدة أسبوع بأقل من 600 دولار'},
          {'icon': Icons.bolt_outlined, 'text': 'كيف أسافر إلى إسطنبول بأرخص تكلفة ممكنة؟'},
          {'icon': Icons.hiking_outlined, 'text': 'جولة استكشافية للشباب في كوالالمبور وبانكوك'},
          {'icon': Icons.train_outlined, 'text': 'أرخص طرق التنقل بالقطارات والمواصلات في أوروبا'},
        ],
        'beaches': [
          {'icon': Icons.beach_access, 'text': 'أفضل شواطئ ومنتجعات الاستجمام في شرم الشيخ'},
          {'icon': Icons.surfing_outlined, 'text': 'عطلة صيفية 6 أيام في جزر تايلاند فوكيت وكرابي'},
          {'icon': Icons.water_outlined, 'text': 'فنادق بإطلالة بحرية مباشرة وأنشطة غوص'},
        ],
        'cultural': [
          {'icon': Icons.mosque_outlined, 'text': 'رحلة عمرة شاملة الطيران والإقامة قرب الحرم المكي'},
          {'icon': Icons.account_balance, 'text': 'أهم المتاحف والمعالم التاريخية في القاهرة والأقصر'},
          {'icon': Icons.castle_outlined, 'text': 'جولة أثرية ومعمارية في أزقة إسطنبول التاريخية'},
        ],
        'shopping': [
          {'icon': Icons.shopping_bag_outlined, 'text': 'أفضل مراكز التسوق والأسواق الشعبية في دبي'},
          {'icon': Icons.storefront_outlined, 'text': 'دليل التسوق للأزياء والموضة في ميلانو وباريس'},
          {'icon': Icons.local_offer_outlined, 'text': 'أشهر أسواق التوابل والحلويات في إسطنبول'},
        ],
        'faqs': [
          {'icon': Icons.schedule_outlined, 'text': 'ما هو أفضل وقت في السنة لزيارة باريس ودبي؟'},
          {'icon': Icons.assignment_outlined, 'text': 'ما هي متطلبات التأشيرة السياحية لأوروبا (شنغن)؟'},
          {'icon': Icons.luggage_outlined, 'text': 'نصائح لحزم الأمتعة وتوفير رسوم الوزن الزائد في الطيران'},
        ],
      };
    } else {
      return {
        'all': [
          {'icon': Icons.explore_outlined, 'text': 'Plan a 4-day trip to Paris under \$900'},
          {'icon': Icons.flight_takeoff, 'text': 'Cheapest direct flights from Algiers to Dubai'},
          {'icon': Icons.hotel_outlined, 'text': 'Top luxury hotels in Istanbul with free breakfast'},
          {'icon': Icons.savings_outlined, 'text': 'Optimize \$1200 budget for a 5-day trip'},
          {'icon': Icons.family_restroom, 'text': 'Best 5-day family itinerary in Dubai with kids'},
          {'icon': Icons.beach_access, 'text': 'Top all-inclusive beach resorts in Antalya'},
        ],
        'family': [
          {'icon': Icons.family_restroom, 'text': 'Best 5-day family itinerary in Dubai with kids'},
          {'icon': Icons.attractions_outlined, 'text': '5-day family vacation to Paris & Disneyland'},
          {'icon': Icons.hotel_outlined, 'text': 'Family-friendly all-inclusive resort in Antalya'},
          {'icon': Icons.pool_outlined, 'text': 'Top waterpark and kid-friendly resorts'},
        ],
        'honeymoon': [
          {'icon': Icons.favorite_border, 'text': 'Romantic honeymoon getaway in Bali on a moderate budget'},
          {'icon': Icons.restaurant_outlined, 'text': '7-day honeymoon in Rome & Amalfi Coast'},
          {'icon': Icons.cabin_outlined, 'text': 'Best overwater villas in Maldives for couples'},
          {'icon': Icons.photo_camera_outlined, 'text': 'Most photogenic romantic spots in Paris'},
        ],
        'budget': [
          {'icon': Icons.savings_outlined, 'text': 'Budget 7-day European trip under \$600'},
          {'icon': Icons.bolt_outlined, 'text': 'How to travel to Istanbul with minimum expenses?'},
          {'icon': Icons.hiking_outlined, 'text': 'Backpacking guide for Kuala Lumpur & Bangkok'},
          {'icon': Icons.train_outlined, 'text': 'Cheapest train and transport tips in Europe'},
        ],
        'beaches': [
          {'icon': Icons.beach_access, 'text': 'Top relaxing beach resorts in Sharm El Sheikh'},
          {'icon': Icons.surfing_outlined, 'text': '6-day island vacation in Phuket & Krabi'},
          {'icon': Icons.water_outlined, 'text': 'Direct beachfront hotels with scuba diving'},
        ],
        'cultural': [
          {'icon': Icons.mosque_outlined, 'text': 'Complete Umrah package with hotels near Haram'},
          {'icon': Icons.account_balance, 'text': 'Top historical landmarks & museums in Cairo & Luxor'},
          {'icon': Icons.castle_outlined, 'text': 'Historic walking & heritage tour in Istanbul'},
        ],
        'shopping': [
          {'icon': Icons.shopping_bag_outlined, 'text': 'Best luxury shopping malls & souks in Dubai'},
          {'icon': Icons.storefront_outlined, 'text': 'Fashion shopping guide for Milan & Paris'},
          {'icon': Icons.local_offer_outlined, 'text': 'Famous grand bazaar & spice market in Istanbul'},
        ],
        'faqs': [
          {'icon': Icons.schedule_outlined, 'text': 'What is the best time of year to visit Dubai or Paris?'},
          {'icon': Icons.assignment_outlined, 'text': 'What are the general visa requirements for Schengen?'},
          {'icon': Icons.luggage_outlined, 'text': 'Packing tips to avoid extra airline baggage fees'},
        ],
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = _getCategories(widget.isArabic);
    final promptsMap = _getPromptsByCat(widget.isArabic);
    final currentPrompts = promptsMap[_selectedCategory] ?? promptsMap['all']!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Tabs Bar
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = cat['id'] == _selectedCategory;
              return ChoiceChip(
                label: Text(
                  cat['label'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.dividerDark : Colors.transparent),
                ),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedCategory = cat['id'] as String);
                  }
                },
              );
            },
          ),
        ),
        const SizedBox(height: 6),

        // Prompts Horizontal List
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: currentPrompts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final p = currentPrompts[index];
              return ActionChip(
                avatar: Icon(p['icon'] as IconData, size: 15, color: AppColors.primary),
                label: Text(
                  p['text'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                side: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.primary.withOpacity(0.25),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                onPressed: () => widget.onSelectPrompt(p['text'] as String),
              );
            },
          ),
        ),
      ],
    );
  }
}
