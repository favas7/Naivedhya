import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:naivedhya/utils/color_theme.dart';

class EmptyOrdersState extends StatelessWidget {
  final String searchQuery;
  final String? selectedStatus;

  const EmptyOrdersState({
    super.key,
    required this.searchQuery,
    required this.selectedStatus,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = AppTheme.of(context);
    
    bool hasFilter = searchQuery.isNotEmpty || selectedStatus != null;
    
    String title = hasFilter ? 'No Orders Found' : 'No Orders Yet';
    String subtitle = hasFilter
        ? 'Try adjusting your search or filter criteria'
        : 'Start by creating your first order';

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration / Icon
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withAlpha(30),
              ),
              child: Icon(
                hasFilter
                    ? Icons.search_off_outlined
                    : Icons.shopping_bag_outlined,
                size: 50.sp,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(height: 24.h),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: themeColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),

            // Subtitle
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14.sp,
                color: themeColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),

            // Action Button
            if (hasFilter)
              OutlinedButton.icon(
                onPressed: () {
                  // This will be handled by parent widget
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Clear Filters'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  side: BorderSide(
                    color: AppTheme.primary,
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}