// services/order_item_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:naivedhya/models/order_item_model.dart';

class OrderItemService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Create multiple order items
  Future<List<OrderItem>> createOrderItems(List<OrderItem> orderItems) async {
    try {
      final List<Map<String, dynamic>> itemsData = orderItems
          .map((item) => item.toJson())
          .toList();

      final response = await _supabase
          .from('order_items')
          .insert(itemsData)
          .select();

      return (response as List)
          .map((json) => OrderItem.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to create order items: $e');
    }
  }

  /// Get all order items for a specific order with menu item names
  Future<List<OrderItem>> getOrderItems(String orderId) async {
    try {
      final response = await _supabase
          .from('order_items')
          .select('''
            *,
            menu_items!fk_menu_item(name)
          ''')
          .eq('order_id', orderId);

      return (response as List).map((json) {
        // Add item name from the joined menu_items table
        final itemName = json['menu_items']?['name'];
        final orderItemJson = Map<String, dynamic>.from(json);
        orderItemJson['item_name'] = itemName;
        return OrderItem.fromJson(orderItemJson);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load order items: $e');
    }
  }

  /// Get a single order item
  Future<OrderItem?> getOrderItem(String orderId, String itemId) async {
    try {
      final response = await _supabase
          .from('order_items')
          .select('''
            *,
            menu_items!fk_menu_item(name)
          ''')
          .eq('order_id', orderId)
          .eq('item_id', itemId)
          .maybeSingle();

      if (response == null) return null;

      final itemName = response['menu_items']?['name'];
      final orderItemJson = Map<String, dynamic>.from(response);
      orderItemJson['item_name'] = itemName;
      return OrderItem.fromJson(orderItemJson);
    } catch (e) {
      throw Exception('Failed to load order item: $e');
    }
  }

  /// Update an order item
  Future<OrderItem?> updateOrderItem(OrderItem orderItem) async {
    try {
      final response = await _supabase
          .from('order_items')
          .update(orderItem.toJson())
          .eq('order_id', orderItem.orderId)
          .eq('item_id', orderItem.itemId)
          .select()
          .single();

      return OrderItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update order item: $e');
    }
  }

  /// Delete a specific order item
  Future<bool> deleteOrderItem(String orderId, String itemId) async {
    try {
      await _supabase
          .from('order_items')
          .delete()
          .eq('order_id', orderId)
          .eq('item_id', itemId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete order item: $e');
    }
  }

  /// Delete all order items for a specific order
  Future<bool> deleteOrderItems(String orderId) async {
    try {
      await _supabase
          .from('order_items')
          .delete()
          .eq('order_id', orderId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete order items: $e');
    }
  }

/// Calculate total amount for an order
Future<double> calculateOrderTotal(String orderId) async {
  try {
    final orderItems = await getOrderItems(orderId);
    return orderItems.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
  } catch (e) {
    throw Exception('Failed to calculate order total: $e');
  }
}
  /// Get order items count for a specific order
  Future<int> getOrderItemsCount(String orderId) async {
    try {
      final response = await _supabase
          .from('order_items')
          .select('order_id')
          .eq('order_id', orderId);
      
      return (response as List).length;
    } catch (e) {
      throw Exception('Failed to get order items count: $e');
    }
  }

  /// Bulk update order items
  Future<List<OrderItem>> updateOrderItems(List<OrderItem> orderItems) async {
    try {
      List<OrderItem> updatedItems = [];
      
      for (OrderItem item in orderItems) {
        final updatedItem = await updateOrderItem(item);
        if (updatedItem != null) {
          updatedItems.add(updatedItem);
        }
      }
      
      return updatedItems;
    } catch (e) {
      throw Exception('Failed to bulk update order items: $e');
    }
  }
}