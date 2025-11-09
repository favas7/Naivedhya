// lib/Views/admin/order/add_order_screen/widget/vendor_selector_card.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/order/add_order_screen/widget/section_card_wrapper.dart';
import 'package:naivedhya/utils/color_theme.dart';

class VendorSelectorCard extends StatelessWidget {
  final List<Map<String, dynamic>> vendors;
  final Map<String, dynamic>? selectedVendor;
  final ValueChanged<Map<String, dynamic>?> onVendorChanged;
  final bool isLoading;
  final bool hasSelectedRestaurant;

  const VendorSelectorCard({
    super.key,
    required this.vendors,
    required this.selectedVendor,
    required this.onVendorChanged,
    required this.isLoading,
    required this.hasSelectedRestaurant,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = AppTheme.of(context);

    return SectionCardWrapper(
      title: 'Vendor',
      icon: Icons.store,
      padding: const EdgeInsets.all(16),
      child: _buildContent(context, themeColors),
    );
  }

  Widget _buildContent(BuildContext context, AppThemeColors themeColors) {
    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Loading vendors...',
                style: TextStyle(
                  fontSize: 13,
                  color: themeColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!hasSelectedRestaurant) {
      return _buildEmptyState(
        icon: Icons.restaurant_outlined,
        message: 'Please select a restaurant first',
        themeColors: themeColors,
      );
    }

    if (vendors.isEmpty) {
      return _buildEmptyState(
        icon: Icons.store_outlined,
        message: 'No vendors available for this restaurant',
        themeColors: themeColors,
      );
    }

    return Column(
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
          child: DropdownButtonFormField<Map<String, dynamic>>(
            value: selectedVendor,
            decoration: InputDecoration(
              labelText: 'Select Vendor',
              labelStyle: TextStyle(
                color: themeColors.textSecondary,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.business,
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
            items: vendors.map((vendor) {
              return DropdownMenuItem(
                value: vendor,
                child: Row(
                  mainAxisSize: MainAxisSize.min, // ✅ CRITICAL FIX
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.info,
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
                            vendor['name'] ?? 'Unknown Vendor',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: themeColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          // if (vendor['email'] != null)
                          //   Text(
                          //     vendor['email'],
                          //     style: TextStyle(
                          //       fontSize: 12,
                          //       color: themeColors.textSecondary,
                          //     ),
                          //     overflow: TextOverflow.ellipsis,
                          //   ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: onVendorChanged,
          ),
        ),
        
        // Selected Vendor Info
        if (selectedVendor != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.info.withAlpha(13),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.info.withAlpha(51),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppTheme.info,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Vendor',
                        style: TextStyle(
                          fontSize: 11,
                          color: themeColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedVendor!['name'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: themeColors.textPrimary,
                        ),
                      ),
                      if (selectedVendor!['phone'] != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          selectedVendor!['phone'],
                          style: TextStyle(
                            fontSize: 12,
                            color: themeColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required AppThemeColors themeColors,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40,
              color: themeColors.textSecondary.withAlpha(128),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: themeColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}