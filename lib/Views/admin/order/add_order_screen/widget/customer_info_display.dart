// lib/Views/admin/order/add_order_screen/widget/customer_info_display.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/models/user_model.dart';
import 'package:naivedhya/utils/color_theme.dart';

class CustomerInfoDisplay extends StatelessWidget {
  final UserModel? customer;
  final bool isGuestOrder;
  final String? guestName;
  final String? guestMobile;
  final String? guestAddress;

  const CustomerInfoDisplay({
    super.key,
    this.customer,
    required this.isGuestOrder,
    this.guestName,
    this.guestMobile,
    this.guestAddress,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = AppTheme.of(context);

    if (customer != null) {
      return _buildCustomerInfo(themeColors);
    } else if (isGuestOrder) {
      return _buildGuestInfo(themeColors);
    } else {
      return Text(
        'No customer selected',
        style: TextStyle(
          color: themeColors.textSecondary,
          fontSize: 14,
        ),
      );
    }
  }

  Widget _buildCustomerInfo(AppThemeColors themeColors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.info.withAlpha(13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.info.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: AppTheme.info,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  customer!.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: themeColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.info.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Customer',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.info,
                  ),
                ),
              ),
            ],
          ),
          if (customer!.phone.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.phone,
                  size: 14,
                  color: themeColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  customer!.phone,
                  style: TextStyle(
                    fontSize: 13,
                    color: themeColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
          if (customer!.email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.email,
                  size: 14,
                  color: themeColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    customer!.email,
                    style: TextStyle(
                      fontSize: 13,
                      color: themeColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGuestInfo(AppThemeColors themeColors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warning.withAlpha(13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.warning.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppTheme.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Guest Order',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: themeColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Guest',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Name',
            value: guestName ?? 'N/A',
            themeColors: themeColors,
          ),
          const SizedBox(height: 4),
          _buildInfoRow(
            icon: Icons.phone,
            label: 'Phone',
            value: guestMobile ?? 'N/A',
            themeColors: themeColors,
          ),
          const SizedBox(height: 4),
          _buildInfoRow(
            icon: Icons.location_on,
            label: 'Address',
            value: guestAddress ?? 'N/A',
            themeColors: themeColors,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required AppThemeColors themeColors,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 14,
          color: themeColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: themeColors.textPrimary,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: themeColors.textSecondary,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: themeColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}