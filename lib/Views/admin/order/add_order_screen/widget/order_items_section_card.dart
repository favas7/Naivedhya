// lib/Views/admin/order/add_order_screen/widget/order_items_section_card.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/order/add_order_screen/widget/order_item_tile.dart';
import 'package:naivedhya/Views/admin/order/add_order_screen/widget/section_card_wrapper.dart';
import 'package:naivedhya/models/order_item_model.dart';
import 'package:naivedhya/utils/color_theme.dart';

class OrderItemsSectionCard extends StatelessWidget {
  final List<OrderItem> orderItems;
  final VoidCallback onAddItems;
  final Function(int index) onRemoveItem;
  final Function(int index, int newQuantity) onUpdateQuantity;
  final bool canAddItems;

  const OrderItemsSectionCard({
    super.key,
    required this.orderItems,
    required this.onAddItems,
    required this.onRemoveItem,
    required this.onUpdateQuantity,
    this.canAddItems = true, 
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = AppTheme.of(context);

    return SectionCardWrapper(
      title: 'Order Items',
      icon: Icons.shopping_bag,
      trailing: ElevatedButton.icon(
        onPressed: canAddItems ? onAddItems : null,
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Add Items'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      padding: orderItems.isEmpty ? const EdgeInsets.all(16) : EdgeInsets.zero,
      child: orderItems.isEmpty
          ? _buildEmptyState(themeColors)
          : _buildItemsList(themeColors),
    );
  }

  Widget _buildEmptyState(AppThemeColors themeColors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: themeColors.textSecondary.withAlpha(128),
            ),
            const SizedBox(height: 12),
            Text(
              'No items added yet',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: themeColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap "Add Items" to get started',
              style: TextStyle(
                fontSize: 12,
                color: themeColors.textSecondary.withAlpha(179),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(AppThemeColors themeColors) {
    return Column(
      children: [
        // Header with count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: themeColors.background.withAlpha(128),
            border: Border(
              bottom: BorderSide(
                color: themeColors.background.withAlpha(50),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${orderItems.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${orderItems.length == 1 ? 'Item' : 'Items'} Added',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: themeColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        
        // Items list using OrderItemTile widget
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: orderItems.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = orderItems[index];
            return OrderItemTile(
              item: item,
              onRemove: () => onRemoveItem(index),
              onIncrement: () => onUpdateQuantity(index, item.quantity + 1),
              onDecrement: () => onUpdateQuantity(index, item.quantity - 1),
            );
          },
        ),
      ],
    );
  }
}