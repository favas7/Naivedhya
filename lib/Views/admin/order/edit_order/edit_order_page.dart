import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'edit_order_form.dart';

/// Full-screen Edit Order Page as an alternative to dialog
/// Can be used with: Navigator.push(context, MaterialPageRoute(builder: (_) => EditOrderPage(order: order)))
class EditOrderPage extends StatefulWidget {
  final Order order;
  final Function(Order)? onOrderUpdated;

  const EditOrderPage({
    super.key,
    required this.order,
    this.onOrderUpdated,
  });

  @override
  State<EditOrderPage> createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  late Order currentOrder;

  @override
  void initState() {
    super.initState();
    currentOrder = widget.order;
  }

  void _handleOrderUpdated(Order updatedOrder) {
    setState(() => currentOrder = updatedOrder);
    widget.onOrderUpdated?.call(updatedOrder);
    Navigator.pop(context, updatedOrder);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final themeColors = AppTheme.of(context);

    if (isMobile) {
      // Mobile layout - single column
      return Scaffold(
        appBar: AppBar(
          title: Text('Edit Order #${widget.order.orderNumber}'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: EditOrderForm(
          order: widget.order,
          onOrderUpdated: _handleOrderUpdated,
          isMobile: true,
        ),
      );
    } else {
      // Web layout - side-by-side
      return Scaffold(
        appBar: AppBar(
          title: Text('Edit Order #${widget.order.orderNumber}'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Row(
          children: [
            // Form Section (Left)
            Expanded(
              flex: 1,
              child: EditOrderForm(
                order: widget.order,
                onOrderUpdated: _handleOrderUpdated,
                isMobile: false,
              ),
            ),
            // Preview Section (Right)
            Container(
              width: 1.sw * 0.35,
              constraints: BoxConstraints(
                maxWidth: 450.w,
              ),
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
              child: _buildOrderPreview(currentOrder, themeColors),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildOrderPreview(Order order, AppThemeColors themeColors) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Order Preview',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: themeColors.textPrimary,
            ),
          ),
          SizedBox(height: 20.h),

          // Order Header Card
          _buildPreviewCard(
            title: 'Order Details',
            children: [
              _buildPreviewRow('Order ID', order.orderNumber, themeColors),
              SizedBox(height: 12.h),
              _buildPreviewRow('Status', order.status.toUpperCase(), themeColors),
              SizedBox(height: 12.h),
              _buildPreviewRow('Customer', order.customerName ?? 'Guest', themeColors),
            ],
            themeColors: themeColors,
          ),
          SizedBox(height: 16.h),

          // Amount Card
          _buildPreviewCard(
            title: 'Amount',
            children: [
              _buildPreviewRow(
                'Total Amount',
                '₹${order.totalAmount.toStringAsFixed(2)}',
                themeColors,
                isAmount: true,
              ),
              SizedBox(height: 12.h),
              _buildPreviewRow(
                'Payment Method',
                'Cash',
                themeColors,
              ),
            ],
            themeColors: themeColors,
          ),
          SizedBox(height: 16.h),

          // Delivery Card
          _buildPreviewCard(
            title: 'Delivery Information',
            children: [
              _buildPreviewRow(
                'Delivery Status',
                order.deliveryStatus ?? 'Pending',
                themeColors,
              ),
              SizedBox(height: 12.h),
              _buildPreviewRow(
                'Proposed Delivery',
                _formatDate(order.proposedDeliveryTime),
                themeColors,
              ),
              if (order.deliveryPersonId != null) ...[
                SizedBox(height: 12.h),
                _buildPreviewRow(
                  'Delivery Personnel',
                  order.deliveryPersonId ?? 'N/A',
                  themeColors,
                ),
              ],
            ],
            themeColors: themeColors,
          ),
          SizedBox(height: 16.h),

          // Restaurant & Vendor Card
          _buildPreviewCard(
            title: 'Restaurant Info',
            children: [
              _buildPreviewRow(
                'Restaurant ID',
                order.restaurantId,
                themeColors,
              ),
              SizedBox(height: 12.h),
              _buildPreviewRow(
                'Vendor ID',
                order.vendorId,
                themeColors,
              ),
            ],
            themeColors: themeColors,
          ),
          SizedBox(height: 16.h),

          // Timestamps Card
          _buildPreviewCard(
            title: 'Timestamps',
            children: [
              _buildPreviewRow(
                'Created',
                _formatDate(order.createdAt),
                themeColors,
              ),
              SizedBox(height: 12.h),
              _buildPreviewRow(
                'Updated',
                _formatDate(order.updatedAt),
                themeColors,
              ),
            ],
            themeColors: themeColors,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard({
    required String title,
    required List<Widget> children,
    required AppThemeColors themeColors,
  }) {
    return Container(
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
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: themeColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          ...children,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: themeColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12.sp,
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
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}