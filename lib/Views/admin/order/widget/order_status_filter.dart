import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:naivedhya/utils/color_theme.dart';

class OrderStatusFilter extends StatelessWidget {
  final String? selectedStatus;
  final Function(String?) onStatusChanged;

  const OrderStatusFilter({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = AppTheme.of(context);
    final statusOptions = [
      'All',
      'pending',
      'confirmed',
      'preparing',
      'ready',
      'picked up',
      'delivering',
      'completed',
      'cancelled',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statusOptions
            .map((status) {
              final isSelected = status == 'All'
                  ? selectedStatus == null || selectedStatus!.isEmpty
                  : status == selectedStatus;

              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: FilterChip(
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      onStatusChanged(status == 'All' ? null : status);
                    }
                  },
                  label: Text(
                    status.toUpperCase(),
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                  ),
                  backgroundColor: themeColors.surface,
                  selectedColor: AppTheme.primary.withAlpha(200),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : themeColors.textPrimary,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppTheme.primary
                        : (themeColors.surface == AppTheme.white
                            ? Colors.grey[300]!
                            : Colors.grey[700]!),
                    width: 1.5,
                  ),
                ),
              );
            })
            .toList(),
      ),
    );
  }
}