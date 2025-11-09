// Views/admin/order/widgets/order_detail_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:naivedhya/utils/color_theme.dart';

class OrderDetailItem extends StatelessWidget {
  final String label;
  final String value;
  final AppThemeColors themeColors;
  final IconData icon;
  final bool isHighlight;

  const OrderDetailItem({
    super.key,
    required this.label,
    required this.value,
    required this.themeColors,
    required this.icon,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: isHighlight ? AppTheme.primary : themeColors.textSecondary,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: themeColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
                  color:
                      isHighlight ? AppTheme.primary : themeColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}