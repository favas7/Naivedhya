// lib/Views/admin/order/add_order_screen/widget/restaurant_selector_card.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/order/add_order_screen/widget/section_card_wrapper.dart';
import 'package:naivedhya/models/restaurant_model.dart';
import 'package:naivedhya/utils/color_theme.dart';

class RestaurantSelectorCard extends StatelessWidget {
  final List<Restaurant> restaurants;
  final Restaurant? selectedRestaurant;
  final ValueChanged<Restaurant?> onRestaurantChanged;

  const RestaurantSelectorCard({
    super.key,
    required this.restaurants,
    required this.selectedRestaurant,
    required this.onRestaurantChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = AppTheme.of(context);

    return SectionCardWrapper(
      title: 'Restaurant',
      icon: Icons.restaurant,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: themeColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeColors.background.withAlpha(50),
              ),
            ),
            child: DropdownButtonFormField<Restaurant>(
              value: selectedRestaurant,
              decoration: InputDecoration(
                labelText: 'Select Restaurant',
                labelStyle: TextStyle(
                  color: themeColors.textSecondary,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.restaurant_menu,
                  color: AppTheme.primary,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
              dropdownColor: themeColors.surface,
              icon: Icon(
                Icons.arrow_drop_down,
                color: themeColors.textSecondary,
              ),
              isExpanded: true, // ✅ CRITICAL FIX
              items: restaurants.map((restaurant) {
                return DropdownMenuItem(
                  value: restaurant,
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // ✅ CRITICAL FIX
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // ✅ REMOVED Expanded - Using Flexible instead
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              restaurant.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: themeColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onRestaurantChanged,
            ),
          ),
          
          // Selected Restaurant Info
          if (selectedRestaurant != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(13),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primary.withAlpha(51),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Restaurant',
                          style: TextStyle(
                            fontSize: 11,
                            color: themeColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedRestaurant!.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: themeColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}