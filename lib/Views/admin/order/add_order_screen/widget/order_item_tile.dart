// lib/Views/admin/order/add_order_screen/widget/order_item_tile.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/models/order_item_model.dart';
import 'package:naivedhya/utils/color_theme.dart';

class OrderItemTile extends StatelessWidget {
  final OrderItem item;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const OrderItemTile({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = AppTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: themeColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: themeColors.background.withAlpha(50),
        ),
      ),
      child: Column(
        children: [
          // Item info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Item icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.fastfood,
                    size: 20,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Item details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName ?? 'Item',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: themeColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${item.price.toStringAsFixed(2)} each',
                        style: TextStyle(
                          fontSize: 12,
                          color: themeColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${item.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Qty: ${item.quantity}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: themeColors.background.withAlpha(50),
          ),
          
          // Quantity controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Delete button
                TextButton.icon(
                  onPressed: onRemove,
                  icon: Icon(Icons.delete_outline, size: 16, color: AppTheme.error),
                  label: Text(
                    'Remove',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                
                // Quantity controls
                Container(
                  decoration: BoxDecoration(
                    color: themeColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: themeColors.background.withAlpha(50),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: onDecrement,
                        icon: const Icon(Icons.remove, size: 16),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        color: themeColors.textSecondary,
                        tooltip: 'Decrease quantity',
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.quantity}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: themeColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onIncrement,
                        icon: const Icon(Icons.add, size: 16),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        color: AppTheme.primary,
                        tooltip: 'Increase quantity',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}