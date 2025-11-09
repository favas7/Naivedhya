// Views/admin/order/widgets/order_filter_chip.dart

import 'package:flutter/material.dart';
import 'package:naivedhya/utils/color_theme.dart';

class OrderFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final AppThemeColors themeColors;

  const OrderFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.themeColors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: themeColors.surface,
        selectedColor: AppTheme.primary.withAlpha(200),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : themeColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(
          color: isSelected ? AppTheme.primary : themeColors.background.withAlpha(50),
        ),
      ),
    );
  }
}