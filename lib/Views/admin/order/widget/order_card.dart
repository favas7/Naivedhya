// Views/admin/order/widgets/order_card.dart

import 'package:flutter/material.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/utils/color_theme.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final Map<String, dynamic>? restaurant;
  final Map<String, dynamic>? vendor;
  final List orderItems;
  final AppThemeColors themeColors;
  final VoidCallback onTap;
  final Function(BuildContext, Order, AppThemeColors) onShowMenu;

  const OrderCard({
    super.key,
    required this.order,
    required this.restaurant,
    required this.vendor,
    required this.orderItems,
    required this.themeColors,
    required this.onTap,
    required this.onShowMenu,
  });

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = themeColors.getOrderStatusColor(order.status);
    final statusBgColor = themeColors.getOrderStatusBgColor(order.status);
    final itemsDisplay = orderItems.isNotEmpty
        ? (orderItems).map((item) => item.itemName ?? 'Item').join(', ')
        : 'No items';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: themeColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeColors.background.withAlpha(50)),
        ),
        child: Column(
          children: [
            // Header Row with Order ID, Amount, Status
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: themeColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: themeColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onPressed: () => onShowMenu(context, order, themeColors),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: themeColors.background.withAlpha(30)),

            // Customer Info Row
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: themeColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName ?? 'Unknown Customer',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: themeColors.textPrimary,
                          ),
                        ),
                        Text(
                          '+91 XXXXXX XXXX',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.schedule, size: 16, color: themeColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(order.createdAt ?? DateTime.now()),
                    style: TextStyle(
                      fontSize: 12,
                      color: themeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Restaurant and Location Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.restaurant, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      restaurant?['name'] ?? 'Unknown Restaurant',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: themeColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.location_on, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      restaurant?['city'] ?? 'Location',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Vendor Info
            if (vendor != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.store, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        vendor!['name'] ?? 'Unknown Vendor',
                        style: TextStyle(
                          fontSize: 13,
                          color: themeColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            // Items Display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 16, color: themeColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Items: $itemsDisplay',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Delivery Info and ETA
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.delivery_dining, size: 16, color: AppTheme.success),
                      const SizedBox(width: 4),
                      Text(
                        'Delivery Agent: TBD',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.timer, size: 16, color: themeColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'ETA: 15 mins',
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
          ],
        ),
      ),
    );
  }
}