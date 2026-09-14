import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../domain/entities/flight_search_params.dart';

class PassengerSelectionResult {
  final int adults;
  final int children;
  final int infants;
  final CabinClass cabinClass;

  const PassengerSelectionResult({
    required this.adults,
    required this.children,
    required this.infants,
    required this.cabinClass,
  });
}

class PassengerPickerSheet extends StatefulWidget {
  final int initialAdults;
  final int initialChildren;
  final int initialInfants;
  final CabinClass initialCabinClass;

  const PassengerPickerSheet({
    super.key,
    required this.initialAdults,
    required this.initialChildren,
    required this.initialInfants,
    required this.initialCabinClass,
  });

  static Future<PassengerSelectionResult?> show(
    BuildContext context, {
    int adults = 1,
    int children = 0,
    int infants = 0,
    CabinClass cabinClass = CabinClass.economy,
  }) {
    return showModalBottomSheet<PassengerSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PassengerPickerSheet(
        initialAdults: adults,
        initialChildren: children,
        initialInfants: infants,
        initialCabinClass: cabinClass,
      ),
    );
  }

  @override
  State<PassengerPickerSheet> createState() => _PassengerPickerSheetState();
}

class _PassengerPickerSheetState extends State<PassengerPickerSheet> {
  late int _adults;
  late int _children;
  late int _infants;
  late CabinClass _cabinClass;

  @override
  void initState() {
    super.initState();
    _adults = widget.initialAdults;
    _children = widget.initialChildren;
    _infants = widget.initialInfants;
    _cabinClass = widget.initialCabinClass;
  }

  Widget _buildCounterRow({
    required String title,
    required String subtitle,
    required int count,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    bool canDecrement = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: canDecrement ? onDecrement : null,
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: canDecrement ? AppColors.primary : AppColors.borderLight,
                  ),
                ),
                child: Icon(
                  Icons.remove,
                  size: 16,
                  color: canDecrement ? AppColors.primary : AppColors.textMutedLight,
                ),
              ),
            ),
            SizedBox(
              width: 32,
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ),
            IconButton(
              onPressed: onIncrement,
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(
                  Icons.add,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet Header
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.tr('flight_passengers'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Adults
            _buildCounterRow(
              title: context.tr('flight_adults'),
              subtitle: 'Age 12+',
              count: _adults,
              canDecrement: _adults > 1,
              onDecrement: () => setState(() => _adults--),
              onIncrement: () => setState(() => _adults++),
            ),
            const Divider(height: 24),

            // Children
            _buildCounterRow(
              title: context.tr('flight_children'),
              subtitle: 'Age 2-11',
              count: _children,
              canDecrement: _children > 0,
              onDecrement: () => setState(() => _children--),
              onIncrement: () => setState(() => _children++),
            ),
            const Divider(height: 24),

            // Infants
            _buildCounterRow(
              title: context.tr('flight_infants'),
              subtitle: 'Under 2',
              count: _infants,
              canDecrement: _infants > 0,
              onDecrement: () => setState(() => _infants--),
              onIncrement: () => setState(() => _infants++),
            ),
            const Divider(height: 24),

            // Cabin Class
            Text(
              context.tr('flight_cabin_class'),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CabinClass.values.map((cabin) {
                final isSelected = _cabinClass == cabin;
                String label;
                switch (cabin) {
                  case CabinClass.economy:
                    label = context.tr('flight_cabin_economy');
                    break;
                  case CabinClass.premiumEconomy:
                    label = context.tr('flight_cabin_premium_economy');
                    break;
                  case CabinClass.business:
                    label = context.tr('flight_cabin_business');
                    break;
                  case CabinClass.firstClass:
                    label = context.tr('flight_cabin_first');
                    break;
                }

                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _cabinClass = cabin);
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Apply Button
            CustomButton(
              text: context.tr('apply'),
              onPressed: () {
                Navigator.of(context).pop(
                  PassengerSelectionResult(
                    adults: _adults,
                    children: _children,
                    infants: _infants,
                    cabinClass: _cabinClass,
                  ),
                );
              },
              type: ButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }
}
