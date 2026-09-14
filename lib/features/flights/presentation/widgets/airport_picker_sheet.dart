import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../shared/models/airport.dart';

class AirportPickerSheet extends StatefulWidget {
  final Airport? selectedAirport;
  final String title;

  const AirportPickerSheet({
    super.key,
    this.selectedAirport,
    required this.title,
  });

  static Future<Airport?> show(BuildContext context, {Airport? selectedAirport, required String title}) {
    return showModalBottomSheet<Airport>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AirportPickerSheet(selectedAirport: selectedAirport, title: title),
    );
  }

  @override
  State<AirportPickerSheet> createState() => _AirportPickerSheetState();
}

class _AirportPickerSheetState extends State<AirportPickerSheet> {
  final _searchController = TextEditingController();
  List<Airport> _filtered = Airport.majorAirports;

  void _filter(String query) {
    if (query.trim().isEmpty) {
      setState(() => _filtered = Airport.majorAirports);
      return;
    }
    final q = query.toLowerCase();
    setState(() {
      _filtered = Airport.majorAirports.where((a) {
        return a.code.toLowerCase().contains(q) ||
            a.cityEn.toLowerCase().contains(q) ||
            a.cityAr.contains(q) ||
            a.nameEn.toLowerCase().contains(q) ||
            a.nameAr.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = AppLocalizations.of(context)?.isRTL ?? false;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Sheet Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: TextField(
              controller: _searchController,
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: isArabic ? 'ابحث عن مطار أو مدينة...' : 'Search airport or city...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Airport List
          Expanded(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => Divider(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final airport = _filtered[index];
                final isSelected = widget.selectedAirport?.code == airport.code;

                return ListTile(
                  onTap: () => Navigator.of(context).pop(airport),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.cardDark : AppColors.primaryContainer),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      airport.code,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  title: Text(
                    '${airport.getCity(isArabic: isArabic)} (${airport.code})',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  subtitle: Text(
                    '${airport.getName(isArabic: isArabic)}, ${airport.getCountry(isArabic: isArabic)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
