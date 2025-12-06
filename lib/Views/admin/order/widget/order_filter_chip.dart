// Views/admin/order/widgets/order_filter_chip.dart

import 'package:flutter/material.dart';
import 'package:naivedhya/utils/color_theme.dart';

class OrderFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final AppThemeColors themeColors;
  final Color? color; // ✅ ADD THIS LINE

  const OrderFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.themeColors,
    this.color, // ✅ ADD THIS LINE
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? themeColors.primary; // ✅ USE CUSTOM COLOR IF PROVIDED
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: themeColors.surface,
        selectedColor: chipColor.withOpacity(0.15), // ✅ USE chipColor
        checkmarkColor: chipColor, // ✅ USE chipColor
        labelStyle: TextStyle(
          color: isSelected ? chipColor : themeColors.textPrimary, // ✅ USE chipColor
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 13,
        ),
        side: BorderSide(
          color: isSelected 
              ? chipColor.withOpacity(0.5) // ✅ USE chipColor
              : themeColors.textSecondary.withOpacity(0.2),
        ),
      ),
    );
  }
}