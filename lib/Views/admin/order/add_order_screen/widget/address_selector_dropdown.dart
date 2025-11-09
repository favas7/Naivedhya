// lib/Views/admin/order/add_order_screen/widget/address_selector_dropdown.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/models/address_model.dart';
import 'package:naivedhya/utils/color_theme.dart';

class AddressSelectorDropdown extends StatelessWidget {
  final List<Address> addresses;
  final Address? selectedAddress;
  final ValueChanged<Address?> onAddressChanged;

  const AddressSelectorDropdown({
    super.key,
    required this.addresses,
    required this.selectedAddress,
    required this.onAddressChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = AppTheme.of(context);

    if (addresses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: AppTheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'Delivery Address',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: themeColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: themeColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeColors.background.withAlpha(50),
            ),
          ),
          child: DropdownButtonFormField<Address>(
            value: selectedAddress,
            decoration: InputDecoration(
              labelText: 'Select Address',
              labelStyle: TextStyle(
                color: themeColors.textSecondary,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.location_on,
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
            isExpanded: true,
            items: addresses.map((address) {
              return DropdownMenuItem(
                value: address,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
                    Flexible(
                      child: Text(
                        address.label ?? 'Address ${addresses.indexOf(address) + 1}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: themeColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: onAddressChanged,
          ),
        ),
        if (selectedAddress != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.success.withAlpha(13),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.success.withAlpha(51),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppTheme.success,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedAddress!.label ?? 'Selected Address',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: themeColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 12,
                            color: AppTheme.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: Text(
                    selectedAddress!.fullAddress,
                    style: TextStyle(
                      fontSize: 13,
                      color: themeColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ), 
          ),
        ],
      ],
    );
  }
}