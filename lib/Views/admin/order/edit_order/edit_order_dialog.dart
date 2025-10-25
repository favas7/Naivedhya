import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:intl/intl.dart';
import 'edit_order_form.dart';

class EditOrderDialog extends StatefulWidget {
  final Order order;
  final Function(Order) onOrderUpdated;

  const EditOrderDialog({
    super.key,
    required this.order,
    required this.onOrderUpdated,
  });

  @override
  State<EditOrderDialog> createState() => _EditOrderDialogState();
}

class _EditOrderDialogState extends State<EditOrderDialog> {
  late Order editingOrder;

  @override
  void initState() {
    super.initState();
    editingOrder = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final themeColors = AppTheme.of(context);

    if (isMobile) {
      // Full-screen modal for mobile
      return Scaffold(
        appBar: AppBar(
          title: Text('Edit Order #${widget.order.orderNumber}'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: EditOrderForm(
          order: widget.order,
          onOrderUpdated: (updatedOrder) {
            widget.onOrderUpdated(updatedOrder);
            Navigator.pop(context);
          },
          isMobile: true,
        ),
      );
    } else {
      // Dialog with side-by-side layout for web
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: 0.9.sh,
            maxWidth: 1200.w,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: themeColors.surface,
          ),
          child: Row(
            children: [
              // Form Section (Left)
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: themeColors.isDark
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Edit Order',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: themeColors.textPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    // Form
                    Expanded(
                      child: EditOrderForm(
                        order: widget.order,
                        onOrderUpdated: (updatedOrder) {
                          widget.onOrderUpdated(updatedOrder);
                          Navigator.pop(context);
                        },
                        isMobile: false,
                      ),
                    ),
                  ],
                ),
              ),
              // Preview Section (Right)
              Container(
                width: 1.sw * 0.35,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: themeColors.isDark
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  color: themeColors.isDark
                      ? AppTheme.darkSurfaceVariant
                      : AppTheme.lightBg,
                ),
                child: _buildPreviewSection(widget.order, themeColors),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildPreviewSection(Order order, AppThemeColors themeColors) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: themeColors.surface,
              border: Border.all(
                color: themeColors.isDark ? Colors.grey[700]! : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: themeColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                _buildPreviewRow('Customer', order.customerName ?? 'Guest', themeColors),
                SizedBox(height: 8.h),
                _buildPreviewRow('Status', order.status.toUpperCase(), themeColors),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Amount Section
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: themeColors.surface,
              border: Border.all(
                color: themeColors.isDark ? Colors.grey[700]! : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: themeColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                _buildPreviewRow(
                  'Total Amount',
                  '₹${order.totalAmount.toStringAsFixed(2)}',
                  themeColors,
                  isAmount: true,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Delivery Information
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: themeColors.surface,
              border: Border.all(
                color: themeColors.isDark ? Colors.grey[700]! : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Info',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: themeColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                _buildPreviewRow(
                  'Delivery Status',
                  order.deliveryStatus ?? 'Pending',
                  themeColors,
                ),
                SizedBox(height: 8.h),
                _buildPreviewRow(
                  'Proposed Time',
                  _formatDate(order.proposedDeliveryTime),
                  themeColors,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(
    String label,
    String value,
    AppThemeColors themeColors, {
    bool isAmount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: themeColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: isAmount ? FontWeight.w600 : FontWeight.w500,
              color: themeColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy hh:mm a').format(date);
  }
}