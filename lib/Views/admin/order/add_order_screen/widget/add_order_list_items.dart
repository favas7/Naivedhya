// lib/Views/admin/order/add_order_screen/widgets/add_order_list_items.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/models/order_item_model.dart';

class AddOrderListItems {
  // Menu Items Section with Add Button
  static Widget buildMenuItemsSection({
    required bool hasSelectedRestaurant,
    required bool hasSelectedVendor,
    required bool isLoadingRestaurantData,
    required VoidCallback onAddMenuItems,
    required List<OrderItem> orderItems,
    required Function(int) onRemoveItem,
    required Function(int, int) onUpdateQuantity,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: !hasSelectedRestaurant ||
                        isLoadingRestaurantData ||
                        !hasSelectedVendor
                    ? null
                    : onAddMenuItems,
                icon: const Icon(Icons.add),
                label: Text(
                  !hasSelectedRestaurant
                      ? 'Select a Restaurant first'
                      : !hasSelectedVendor
                          ? 'Select a Vendor first'
                          : isLoadingRestaurantData
                              ? 'Loading menu...'
                              : 'Add Menu Items',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (orderItems.isNotEmpty)
          buildOrderItemsList(
            orderItems: orderItems,
            onRemoveItem: onRemoveItem,
            onUpdateQuantity: onUpdateQuantity,
          ),
      ],
    );
  }

  // Enhanced Order Items List with Customizations
  static Widget buildOrderItemsList({
    required List<OrderItem> orderItems,
    required Function(int) onRemoveItem,
    required Function(int, int) onUpdateQuantity,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Item',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Price',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Quantity',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 48),
              ],
            ),
          ),
          // Order Items Rows
          ...orderItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return _buildOrderItemRow(
              index: index,
              item: item,
              onRemoveItem: onRemoveItem,
              onUpdateQuantity: onUpdateQuantity,
            );
          }),
        ],
      ),
    );
  }

  static Widget _buildOrderItemRow({
    required int index,
    required OrderItem item,
    required Function(int) onRemoveItem,
    required Function(int, int) onUpdateQuantity,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName ?? 'Unknown Item',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    // Show customizations if any
                    if (item.selectedCustomizations.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      ...item.selectedCustomizations.map((custom) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '  • ${custom.customizationName}: ${custom.selectedOptionName}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('₹${item.price.toStringAsFixed(2)}'),
                    if (item.customizationAdditionalPrice > 0)
                      Text(
                        '+₹${item.customizationAdditionalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: _buildQuantityControls(
                  quantity: item.quantity,
                  onDecrement: () => onUpdateQuantity(index, item.quantity - 1),
                  onIncrement: () => onUpdateQuantity(index, item.quantity + 1),
                ),
              ),
              Expanded(
                child: Text(
                  '₹${item.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onRemoveItem(index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildQuantityControls({
    required int quantity,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onDecrement,
          icon: const Icon(Icons.remove_circle_outline),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          iconSize: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '$quantity',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        IconButton(
          onPressed: onIncrement,
          icon: const Icon(Icons.add_circle_outline),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          iconSize: 20,
        ),
      ],
    );
  }

  // Action Buttons (Cancel & Create Order)
  static Widget buildActionButtons({
    required bool isLoading,
    required VoidCallback onCancel,
    required VoidCallback onCreate,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey[400]!),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : onCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Create Order'),
          ),
        ),
      ],
    );
  }
}