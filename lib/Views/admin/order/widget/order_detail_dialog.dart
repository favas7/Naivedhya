import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:intl/intl.dart';
import 'package:naivedhya/utils/color_theme.dart';

class OrderDetailDialogImproved extends StatelessWidget {
  final Order order;

  const OrderDetailDialogImproved({super.key, required this.order});

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }



  @override
  Widget build(BuildContext context) {
    final themeColors = AppTheme.of(context);
    final statusColor =
        AppTheme.getOrderStatusColor(order.status, themeColors.isDark);
    final statusBgColor =
        AppTheme.getOrderStatusBgColor(order.status, themeColors.isDark);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.all(16.w),
      child: Container(
        constraints: BoxConstraints(maxHeight: 0.85.sh),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: themeColors.surface,
        ),
        child: Column(
          children: [
            // Header with Status
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    statusBgColor,
                    statusBgColor.withAlpha(220),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${order.orderNumber}',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: themeColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(100),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                order.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: themeColors.textPrimary,
                          size: 24.sp,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Details Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Section
                    _buildDetailSection(
                      title: 'Customer Information',
                      icon: Icons.person_outline,
                      themeColors: themeColors,
                      children: [
                        _buildDetailItem(
                          label: 'Name',
                          value: order.customerName ?? 'Guest',
                          themeColors: themeColors,
                          icon: Icons.account_circle_outlined,
                        ),
                        SizedBox(height: 12.h),
                        _buildDetailItem(
                          label: 'Customer ID',
                          value: order.customerId,
                          themeColors: themeColors,
                          icon: Icons.badge_outlined,
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),

                    // Order Details Section
                    _buildDetailSection(
                      title: 'Order Details',
                      icon: Icons.receipt_outlined,
                      themeColors: themeColors,
                      children: [
                        _buildDetailItem(
                          label: 'Total Amount',
                          value: '₹${order.totalAmount.toStringAsFixed(2)}',
                          themeColors: themeColors,
                          icon: Icons.currency_rupee,
                          isHighlight: true,
                        ),
                        SizedBox(height: 12.h),
                        _buildDetailItem(
                          label: 'Restaurant ID',
                          value: order.restaurantId,
                          themeColors: themeColors,
                          icon: Icons.storefront_outlined,
                        ),
                        SizedBox(height: 12.h),
                        _buildDetailItem(
                          label: 'Vendor ID',
                          value: order.vendorId,
                          themeColors: themeColors,
                          icon: Icons.business_outlined,
                        ),
                        SizedBox(height: 12.h),
                        _buildDetailItem(
                          label: 'Payment Method',
                          value: 'Cash',
                          themeColors: themeColors,
                          icon: Icons.payment_outlined,
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),

                    // Delivery Section
                    _buildDetailSection(
                      title: 'Delivery Information',
                      icon: Icons.local_shipping_outlined,
                      themeColors: themeColors,
                      children: [
                        _buildDetailItem(
                          label: 'Delivery Status',
                          value: order.deliveryStatus ?? 'Pending',
                          themeColors: themeColors,
                          icon: Icons.info_outline,
                        ),
                        SizedBox(height: 12.h),
                        _buildDetailItem(
                          label: 'Proposed Delivery Time',
                          value: _formatDate(order.proposedDeliveryTime),
                          themeColors: themeColors,
                          icon: Icons.schedule_outlined,
                        ),
                        if (order.pickupTime != null) ...[
                          SizedBox(height: 12.h),
                          _buildDetailItem(
                            label: 'Pickup Time',
                            value: _formatDate(order.pickupTime),
                            themeColors: themeColors,
                            icon: Icons.location_on_outlined,
                          ),
                        ],
                        if (order.deliveryTime != null) ...[
                          SizedBox(height: 12.h),
                          _buildDetailItem(
                            label: 'Delivery Time',
                            value: _formatDate(order.deliveryTime),
                            themeColors: themeColors,
                            icon: Icons.check_circle_outline,
                          ),
                        ],
                        if (order.deliveryPersonId != null) ...[
                          SizedBox(height: 12.h),
                          _buildDetailItem(
                            label: 'Delivery Person ID',
                            value: order.deliveryPersonId!,
                            themeColors: themeColors,
                            icon: Icons.person_outline,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 18.h),

                    // Timestamps Section
                    _buildDetailSection(
                      title: 'Record Information',
                      icon: Icons.history_outlined,
                      themeColors: themeColors,
                      children: [
                        _buildDetailItem(
                          label: 'Created At',
                          value: _formatDate(order.createdAt),
                          themeColors: themeColors,
                          icon: Icons.add_circle_outline,
                        ),
                        SizedBox(height: 12.h),
                        _buildDetailItem(
                          label: 'Updated At',
                          value: _formatDate(order.updatedAt),
                          themeColors: themeColors,
                          icon: Icons.edit_calendar_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons Footer
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: themeColors.isDark
                        ? Colors.grey[700]!
                        : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Copy order details
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Order details copied to clipboard')),
                        );
                      },
                      icon: const Icon(Icons.content_copy),
                      label: const Text('Copy'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        backgroundColor: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required AppThemeColors themeColors,
    required List<Widget> children,
  }) {
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

  Widget _buildDetailItem({
    required String label,
    required String value,
    required AppThemeColors themeColors,
    required IconData icon,
    bool isHighlight = false,
  }) {
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
                  color: isHighlight ? AppTheme.primary : themeColors.textPrimary,
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