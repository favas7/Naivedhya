import 'package:flutter/material.dart';
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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final _ = _getStatusColor();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: themeColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: themeColors.textSecondary.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Order Type Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getOrderTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    order.orderTypeIcon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Order Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#${order.orderNumber}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: themeColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(),
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
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            order.customerName ?? 'Walk-in',
                            style: TextStyle(
                              fontSize: 13,
                              color: themeColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (order.orderType != null) ...[
                          Text(
                            order.orderType!,
                            style: TextStyle(
                              fontSize: 12,
                              color: themeColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: themeColors.textSecondary,
                            ),
                          ),
                        ],
                        Text(
                          '₹${order.totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: themeColors.textPrimary,
                          ),
                        ),
                        if (order.createdAt != null) ...[
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: themeColors.textSecondary,
                            ),
                          ),
                          Text(
                            _formatTime(order.createdAt!),
                            style: TextStyle(
                              fontSize: 12,
                              color: themeColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: themeColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => onShowMenu(context, order, themeColors),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final color = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        order.status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (order.status.toLowerCase()) {
      case 'pending':
        return AppTheme.warning;
      case 'confirmed':
      case 'preparing':
        return AppTheme.info;
      case 'delivered':
      case 'completed':
        return AppTheme.success;
      case 'cancelled':
        return AppTheme.error;
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _getOrderTypeColor() {
    switch (order.orderType?.toLowerCase()) {
      case 'delivery':
        return AppTheme.warning;
      case 'dine in':
        return AppTheme.info;
      case 'takeaway':
        return AppTheme.primary;
      default:
        return AppTheme.textSecondary;
    }
  }
}