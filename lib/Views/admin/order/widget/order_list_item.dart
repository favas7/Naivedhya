import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:intl/intl.dart';
import 'package:naivedhya/utils/color_theme.dart';

class OrderListItemImproved extends StatefulWidget {
  final Order order;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(String) onStatusUpdate;

  const OrderListItemImproved({
    super.key,
    required this.order,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusUpdate,
  });

  @override
  State<OrderListItemImproved> createState() => _OrderListItemImprovedState();
}

class _OrderListItemImprovedState extends State<OrderListItemImproved>
    with SingleTickerProviderStateMixin {
  bool _showActions = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('hh:mm a').format(date);
  }

  void _toggleActions() {
    if (_showActions) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() => _showActions = !_showActions);
  }

  void _showStatusUpdateDialog() {
    final statusOptions = [
      'pending',
      'confirmed',
      'preparing',
      'ready',
      'picked up',
      'delivering',
      'completed',
      'cancelled',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: statusOptions
                .map(
                  (status) => RadioListTile<String>(
                    title: Text(status.toUpperCase()),
                    value: status,
                    groupValue: widget.order.status.toLowerCase(),
                    activeColor: AppTheme.primary,
                    onChanged: (value) {
                      if (value != null) {
                        widget.onStatusUpdate(value);
                        Navigator.pop(context);
                        setState(() => _showActions = false);
                      }
                    },
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = AppTheme.of(context);
    final statusColor =
        AppTheme.getOrderStatusColor(widget.order.status, themeColors.isDark);
    final statusBgColor =
        AppTheme.getOrderStatusBgColor(widget.order.status, themeColors.isDark);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: themeColors.isDark
                  ? Colors.grey[700]!
                  : Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Main Order Card
              InkWell(
                onTap: widget.onTap,
                onLongPress: _toggleActions,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(_showActions ? 0 : 14.r),
                  bottom: Radius.circular(_showActions ? 0 : 14.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Order Number and Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Order #${widget.order.orderNumber}',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                        color: themeColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 3.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusBgColor,
                                        borderRadius:
                                            BorderRadius.circular(6.r),
                                      ),
                                      child: Text(
                                        widget.order.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w700,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  widget.order.customerName ?? 'Guest',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: themeColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Tap indicator
                          if (!_showActions)
                            Icon(
                              Icons.more_vert,
                              color: themeColors.textSecondary,
                              size: 20.sp,
                            ),
                        ],
                      ),
                      SizedBox(height: 14.h),

                      // Middle Row: Amount and Delivery Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Amount',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: themeColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '₹${widget.order.totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: themeColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Delivery',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: themeColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _formatDate(
                                    widget.order.proposedDeliveryTime),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: themeColors.textPrimary,
                                ),
                              ),
                              Text(
                                _formatTime(
                                    widget.order.proposedDeliveryTime),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: themeColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Bottom Row: Additional Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.order.deliveryStatus != null)
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_shipping_outlined,
                                    size: 14.sp,
                                    color: themeColors.textSecondary,
                                  ),
                                  SizedBox(width: 4.w),
                                  Flexible(
                                    child: Text(
                                      widget.order.deliveryStatus ?? 'Pending',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: themeColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.storefront_outlined,
                                  size: 14.sp,
                                  color: themeColors.textSecondary,
                                ),
                                SizedBox(width: 4.w),
                                Flexible(
                                  child: Text(
                                    widget.order.restaurantId,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: themeColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons (appears on long press)
              if (_showActions)
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: themeColors.isDark
                            ? Colors.grey[700]!
                            : Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(14.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.visibility_outlined,
                        label: 'View',
                        color: AppTheme.info,
                        onTap: widget.onTap,
                      ),
                      _buildActionButton(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        color: Colors.orange,
                        onTap: widget.onEdit,
                      ),
                      _buildActionButton(
                        icon: Icons.update_outlined,
                        label: 'Status',
                        color: AppTheme.warning,
                        onTap: _showStatusUpdateDialog,
                      ),
                      _buildActionButton(
                        icon: Icons.delete_outline,
                        label: 'Delete',
                        color: AppTheme.error,
                        onTap: widget.onDelete,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18.sp, color: color),
                SizedBox(height: 4.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}