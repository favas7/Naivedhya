// lib/services/order_item_service.dart - UPDATED FOR JSONB ARRAY
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:naivedhya/models/order_item_model.dart';

/// Service for managing order items stored as JSONB array in orders table
class AddOrderItemService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all order items for a specific order from the JSONB array
  Future<List<OrderItem>> getOrderItems(String orderId) async {
    try {
      print('🔍 [OrderItemService] Fetching order items for order: $orderId');
      
      final response = await _supabase
          .from('orders')
          .select('order_items')
          .eq('order_id', orderId)
          .single();

      if (response['order_items'] == null || response['order_items'] is! List) {
        print('ℹ️ [OrderItemService] No items found for order: $orderId');
        return [];
      }

      final items = (response['order_items'] as List)
          .map((json) => OrderItem.fromJson({
                ...json,
                'order_id': orderId,
              }))
          .toList();

      print('✅ [OrderItemService] Found ${items.length} order items');
      return items;
    } catch (e) {
      print('❌ [OrderItemService] Error fetching order items: $e');
      throw Exception('Failed to load order items: $e');
    }
  }

  /// Update order items for a specific order (replaces entire array)
  Future<List<OrderItem>> updateOrderItems(
    String orderId,
    List<OrderItem> orderItems,
  ) async {
    try {
      print('📝 [OrderItemService] Updating ${orderItems.length} items for order: $orderId');
      
      // Convert items to JSON (with item_name for display)
      final itemsJson = orderItems
          .map((item) => item.toJsonComplete())
          .toList();

      // Calculate new total
      final newTotal = orderItems.fold(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );

      // Update the order with new items and total
      await _supabase
          .from('orders')
          .update({
            'order_items': itemsJson,
            'total_amount': newTotal,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('order_id', orderId);

      print('✅ [OrderItemService] Order items updated successfully');
      print('💰 [OrderItemService] New total amount: ₹$newTotal');
      
      return orderItems;
    } catch (e) {
      print('❌ [OrderItemService] Error updating order items: $e');
      throw Exception('Failed to update order items: $e');
    }
  }

  /// Add a single item to an order
  Future<List<OrderItem>> addOrderItem(String orderId, OrderItem newItem) async {
    try {
      print('➕ [OrderItemService] Adding item to order: $orderId');
      
      // Get existing items
      final existingItems = await getOrderItems(orderId);
      
      // Add new item
      existingItems.add(newItem);
      
      // Update with new items array
      return await updateOrderItems(orderId, existingItems);
    } catch (e) {
      print('❌ [OrderItemService] Error adding order item: $e');
      throw Exception('Failed to add order item: $e');
    }
  }

  /// Remove an item from an order by item_id
  Future<List<OrderItem>> removeOrderItem(String orderId, String itemId) async {
    try {
      print('🗑️ [OrderItemService] Removing item $itemId from order: $orderId');
      
      // Get existing items
      final existingItems = await getOrderItems(orderId);
      
      // Remove the item
      existingItems.removeWhere((item) => item.itemId == itemId);
      
      // Update with remaining items
      return await updateOrderItems(orderId, existingItems);
    } catch (e) {
      print('❌ [OrderItemService] Error removing order item: $e');
      throw Exception('Failed to remove order item: $e');
    }
  }

  /// Update quantity of a specific item
  Future<List<OrderItem>> updateItemQuantity(
    String orderId,
    String itemId,
    int newQuantity,
  ) async {
    try {
      print('📝 [OrderItemService] Updating quantity for item $itemId to $newQuantity');
      
      if (newQuantity <= 0) {
        return await removeOrderItem(orderId, itemId);
      }
      
      // Get existing items
      final existingItems = await getOrderItems(orderId);
      
      // Find and update the item
      final itemIndex = existingItems.indexWhere((item) => item.itemId == itemId);
      if (itemIndex == -1) {
        throw Exception('Item not found in order');
      }
      
      existingItems[itemIndex] = existingItems[itemIndex].copyWith(
        quantity: newQuantity,
      );
      
      // Update with modified items
      return await updateOrderItems(orderId, existingItems);
    } catch (e) {
      print('❌ [OrderItemService] Error updating item quantity: $e');
      throw Exception('Failed to update item quantity: $e');
    }
  }

  /// Clear all items from an order
  Future<bool> clearOrderItems(String orderId) async {
    try {
      print('🗑️ [OrderItemService] Clearing all items for order: $orderId');
      
      await _supabase
          .from('orders')
          .update({
            'order_items': [],
            'total_amount': 0,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('order_id', orderId);

      print('✅ [OrderItemService] All order items cleared');
      return true;
    } catch (e) {
      print('❌ [OrderItemService] Error clearing order items: $e');
      return false;
    }
  }

  /// Replace all order items (useful for order editing)
  Future<List<OrderItem>> replaceOrderItems(
    String orderId,
    List<OrderItem> newOrderItems,
  ) async {
    try {
      print('🔄 [OrderItemService] Replacing order items for order: $orderId');
      return await updateOrderItems(orderId, newOrderItems);
    } catch (e) {
      print('❌ [OrderItemService] Error replacing order items: $e');
      throw Exception('Failed to replace order items: $e');
    }
  }

  /// Calculate total amount for order items
  double calculateTotalAmount(List<OrderItem> orderItems) {
    return orderItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Get order items count
  Future<int> getOrderItemsCount(String orderId) async {
    try {
      final items = await getOrderItems(orderId);
      return items.length;
    } catch (e) {
      print('❌ [OrderItemService] Error getting item count: $e');
      return 0;
    }
  }

  /// Get total quantity of items in an order
  Future<int> getTotalQuantity(String orderId) async {
    try {
      final items = await getOrderItems(orderId);
      return items.fold<int>(0, (sum, item) => sum + item.quantity);
    } catch (e) {
      print('❌ [OrderItemService] Error getting total quantity: $e');
      return 0;
    }
  }

  /// Validate order items before saving
  bool validateOrderItems(List<OrderItem> items) {
    if (items.isEmpty) {
      print('⚠️ [OrderItemService] Cannot create order with no items');
      return false;
    }

    for (var item in items) {
      if (item.quantity <= 0) {
        print('⚠️ [OrderItemService] Invalid quantity for item: ${item.itemName}');
        return false;
      }
      if (item.price < 0) {
        print('⚠️ [OrderItemService] Invalid price for item: ${item.itemName}');
        return false;
      }
    }

    return true;
  }

  /// Get items summary (for display)
  Future<String> getItemsSummary(String orderId) async {
    try {
      final items = await getOrderItems(orderId);
      if (items.isEmpty) return 'No items';
      
      if (items.length == 1) {
        return '${items[0].itemName} x${items[0].quantity}';
      }
      
      return '${items[0].itemName} +${items.length - 1} more';
    } catch (e) {
      return 'Error loading items';
    }
  }
}