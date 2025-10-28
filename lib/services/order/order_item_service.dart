// lib/services/order_item_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:naivedhya/models/order_item_model.dart';

class AddOrderItemService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================================
  // EXISTING METHODS (Keep all your current functionality)
  // ============================================================================

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

}