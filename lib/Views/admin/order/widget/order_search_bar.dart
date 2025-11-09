// Views/admin/order/widgets/order_search_bar.dart

import 'package:flutter/material.dart';
import 'package:naivedhya/utils/color_theme.dart';

class OrderSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final AppThemeColors themeColors;

  const OrderSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.themeColors,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search by order ID, customer name, hotel...',
        prefixIcon: Icon(Icons.search, color: themeColors.textSecondary),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: onChanged,
    );
  }
}