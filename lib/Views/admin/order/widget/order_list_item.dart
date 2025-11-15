// Views/admin/order/widget/order_list_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/utils/color_theme.dart';

class OrderListItem extends StatelessWidget {
  final Order order;
  final Map<String, dynamic>? restaurant;
  final Map<String, dynamic>? vendor;
  final AppThemeColors themeColors;
  final VoidCallback onTap;
  final Function(BuildContext, Order, AppThemeColors) onShowMenu;

  const OrderListItem({
    super.key,
    required this.order,
    this.restaurant,
    this.vendor,
    required this.themeColors,
    required this.onTap,
    required this.onShowMenu,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('hh:mm a').format(date);
    } else if (difference.inDays < 7) {
      return DateFormat('EEE, hh:mm a').format(date);
    }
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = themeColors.getOrderStatusColor(order.status);
    final statusBgColor = themeColors.getOrderStatusBgColor(order.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: themeColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeColors.isDark
                ? Colors.grey[800]!
                : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Section: Order Number & Customer
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_outlined,
                        size: 16,
                        color: themeColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '#${order.orderNumber}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: themeColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: themeColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.customerName ?? 'Guest',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Middle Section: Delivery Info
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: themeColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          order.deliveryAddress ?? 'No address',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 14,
                        color: themeColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(order.proposedDeliveryTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: themeColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right Section: Status, Amount, Date
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.currency_rupee,
                        size: 14,
                        color: themeColors.primary,
                      ),
                      Text(
                        order.totalAmount.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: themeColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Created Date
                  Text(
                    _formatDate(order.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: themeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // More Menu Button
            IconButton(
              icon: Icon(
                Icons.more_vert,
                size: 20,
                color: themeColors.textSecondary,
              ),
              onPressed: () => onShowMenu(context, order, themeColors),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}