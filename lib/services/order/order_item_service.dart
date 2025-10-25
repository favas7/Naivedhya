// lib/services/order_item_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:naivedhya/models/order_item_model.dart';
import 'package:uuid/uuid.dart';

class OrderItemService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

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
      return orderItems.fold<double>(
          0.0, (sum, item) => sum + item.totalPrice);
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
  Future<List<OrderItem>> updateOrderItems(
      List<OrderItem> orderItems) async {
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

  // ============================================================================
  // NEW METHODS - CUSTOMIZATION SUPPORT
  // ============================================================================

  /// Create order item with customizations
  Future<bool> createOrderItemWithCustomizations({
    required String orderId,
    required String itemId,
    required int quantity,
    required double price,
    required List<Map<String, dynamic>> customizations,
  }) async {
    try {
      // Create order item
      await _supabase.from('order_items').insert({
        'order_id': orderId,
        'item_id': itemId,
        'quantity': quantity,
        'price': price,
      });

      // Create customization records for this item
      for (final customization in customizations) {
        await _supabase.from('order_item_customizations').insert({
          'order_customization_id': _uuid.v4(),
          'order_id': orderId,
          'item_id': itemId,
          'customization_id': customization['customization_id'],
          'selected_option_id': customization['selected_option_id'],
          'additional_price': customization['additional_price'] ?? 0,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      return true;
    } catch (e) {
      throw Exception('Failed to create order item with customizations: $e');
    }
  }

  /// Get order items with customizations
  Future<List<Map<String, dynamic>>> getOrderItemsWithCustomizations(
      String orderId) async {
    try {
      final itemsResponse = await _supabase
          .from('order_items')
          .select('''
            *,
            menu_items!fk_menu_item(name)
          ''')
          .eq('order_id', orderId);

      List<Map<String, dynamic>> itemsWithCustomizations = [];

      for (final item in itemsResponse) {
        final customizationsResponse = await _supabase
            .from('order_item_customizations')
            .select()
            .eq('order_id', orderId)
            .eq('item_id', item['item_id']);

        itemsWithCustomizations.add({
          ...item,
          'item_name': item['menu_items']?['name'],
          'customizations': customizationsResponse,
        });
      }

      return itemsWithCustomizations;
    } catch (e) {
      throw Exception('Failed to fetch order items with customizations: $e');
    }
  }

  /// Get customizations for specific order item
  Future<List<Map<String, dynamic>>> getItemCustomizations(
      String orderId, String itemId) async {
    try {
      final response = await _supabase
          .from('order_item_customizations')
          .select()
          .eq('order_id', orderId)
          .eq('item_id', itemId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch item customizations: $e');
    }
  }

  /// Delete customizations for order item
  Future<bool> deleteItemCustomizations(
      String orderId, String itemId) async {
    try {
      await _supabase
          .from('order_item_customizations')
          .delete()
          .eq('order_id', orderId)
          .eq('item_id', itemId);

      return true;
    } catch (e) {
      throw Exception('Failed to delete item customizations: $e');
    }
  }

  /// Calculate line item total with customizations
  Future<double> calculateLineItemTotal({
    required String orderId,
    required String itemId,
    required double basePrice,
    required int quantity,
  }) async {
    try {
      final customizations = await getItemCustomizations(orderId, itemId);

      double customizationTotal = 0;
      for (final custom in customizations) {
        customizationTotal +=
            (custom['additional_price'] as num?)?.toDouble() ?? 0;
      }

      final pricePerItem = basePrice + customizationTotal;
      return pricePerItem * quantity;
    } catch (e) {
      throw Exception('Failed to calculate line item total: $e');
    }
  }

  /// Calculate order total with all customizations
  Future<double> calculateOrderTotalWithCustomizations(String orderId) async {
    try {
      final itemsResponse = await _supabase
          .from('order_items')
          .select()
          .eq('order_id', orderId);

      double total = 0;

      for (final item in itemsResponse) {
        final lineTotal = await calculateLineItemTotal(
          orderId: orderId,
          itemId: item['item_id'],
          basePrice: (item['price'] as num).toDouble(),
          quantity: item['quantity'] as int,
        );
        total += lineTotal;
      }

      return total;
    } catch (e) {
      throw Exception(
          'Failed to calculate order total with customizations: $e');
    }
  }

  /// Get order item details with all customization info
  Future<Map<String, dynamic>?> getOrderItemDetails(
      String orderId, String itemId) async {
    try {
      final itemResponse = await _supabase
          .from('order_items')
          .select('*, menu_items!fk_menu_item(name)')
          .eq('order_id', orderId)
          .eq('item_id', itemId)
          .maybeSingle();

      if (itemResponse == null) return null;

      final customizations = await getItemCustomizations(orderId, itemId);

      return {
        'order_id': itemResponse['order_id'],
        'item_id': itemResponse['item_id'],
        'item_name': itemResponse['menu_items']?['name'],
        'quantity': itemResponse['quantity'],
        'base_price': itemResponse['price'],
        'customizations': customizations,
        'total_price': await calculateLineItemTotal(
          orderId: orderId,
          itemId: itemId,
          basePrice: (itemResponse['price'] as num).toDouble(),
          quantity: itemResponse['quantity'] as int,
        ),
      };
    } catch (e) {
      throw Exception('Failed to get order item details: $e');
    }
  }

  /// Add customization to existing order item
  Future<bool> addCustomizationToItem({
    required String orderId,
    required String itemId,
    required String customizationId,
    required String? selectedOptionId,
    required double additionalPrice,
  }) async {
    try {
      await _supabase
          .from('order_item_customizations')
          .insert({
            'order_customization_id': _uuid.v4(),
            'order_id': orderId,
            'item_id': itemId,
            'customization_id': customizationId,
            'selected_option_id': selectedOptionId,
            'additional_price': additionalPrice,
            'created_at': DateTime.now().toIso8601String(),
          });

      return true;
    } catch (e) {
      throw Exception('Failed to add customization to item: $e');
    }
  }

  /// Remove customization from order item
  Future<bool> removeCustomizationFromItem(
      String orderId, String customizationId) async {
    try {
      await _supabase
          .from('order_item_customizations')
          .delete()
          .eq('order_id', orderId)
          .eq('customization_id', customizationId);

      return true;
    } catch (e) {
      throw Exception('Failed to remove customization from item: $e');
    }
  }

  /// Get summary of customizations for display
  Future<List<String>> getCustomizationSummary(
      String orderId, String itemId) async {
    try {
      final customizations = await getItemCustomizations(orderId, itemId);

      return customizations.map((custom) {
        final name = custom['customization_id'] ?? 'Unknown';
        final optionId = custom['selected_option_id'] ?? 'No option';
        return '$name: $optionId';
      }).toList();
    } catch (e) {
      print('Error getting customization summary: $e');
      return [];
    }
  }
}