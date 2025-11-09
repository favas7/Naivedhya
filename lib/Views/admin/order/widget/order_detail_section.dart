// Views/admin/order/widgets/order_detail_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:naivedhya/utils/color_theme.dart';

class OrderDetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final AppThemeColors themeColors;
  final List<Widget> children;

  const OrderDetailSection({
    super.key,
    required this.title,
    required this.icon,
    required this.themeColors,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: AppTheme.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: themeColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: themeColors.isDark
                ? Colors.grey[900]?.withAlpha(150)
                : Colors.grey[50],
            border: Border.all(
              color: themeColors.isDark
                  ? Colors.grey[800]!
                  : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}