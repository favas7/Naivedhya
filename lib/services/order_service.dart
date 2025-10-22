// lib/services/order_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:naivedhya/models/order_item_model.dart';

class OrderService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  /// Create a new order with customizations and guest support
  Future<String?> createOrder({
    required String restaurantId,
    required String vendorId,
    required String? customerId, // Null for guest orders
    required String? guestName,
    required String? guestPhone,
    required String? deliveryAddress,
    required List<OrderItem> orderItems,
    required double totalAmount,
    required String? proposedDeliveryTime,
    required String deliveryStatus,
    required String? deliveryPersonId,
    required String specialInstructions,
    required String paymentMethod,
  }) async {
    try {
      final orderId = _uuid.v4();

      // 1. Create order record
      final orderData = {
        'order_id': orderId,
        'customer_id': customerId,
        'vendor_id': vendorId,
        'hotel_id': restaurantId,
        'order_number': await _generateOrderNumber(),
        'total_amount': totalAmount,
        'status': 'Pending',
        'customer_name': guestName ?? 'Customer',
        'delivery_address': deliveryAddress,
        'proposed_delivery_time': proposedDeliveryTime,
        'delivery_status': deliveryStatus,
        'delivery_person_id': deliveryPersonId,
        'special_instructions': specialInstructions,
        'payment_method': paymentMethod,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('orders').insert(orderData);

      // 2. Create order items with customizations
      for (final orderItem in orderItems) {
        await _createOrderItem(
          orderId: orderId,
          orderItem: orderItem,
        );
      }

      return orderId;
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  /// Create individual order item with customizations
  Future<void> _createOrderItem({
    required String orderId,
    required OrderItem orderItem,
  }) async {
    try {
      // Create order_items record
      final orderItemData = {
        'order_id': orderId,
        'item_id': orderItem.itemId,
        'quantity': orderItem.quantity,
        'price': orderItem.price,
      };

      await _supabase.from('order_items').insert(orderItemData);

      // Create customization records for this item
      for (final customization in orderItem.selectedCustomizations) {
        final customizationData = {
          'order_customization_id': _uuid.v4(),
          'order_id': orderId,
          'item_id': orderItem.itemId,
          'customization_id': customization.customizationId,
          'selected_option_id': customization.selectedOptionId,
          'additional_price': customization.additionalPrice,
          'created_at': DateTime.now().toIso8601String(),
        };

        await _supabase
            .from('order_item_customizations')
            .insert(customizationData);
      }
    } catch (e) {
      print('Error creating order item: $e');
      rethrow;
    }
  }

  /// Generate unique order number
  Future<String> _generateOrderNumber() async {
    try {
      final count = await _supabase.from('orders').count(CountOption.exact);

      final orderNumber =
          'ORD-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${(count + 1).toString().padLeft(5, '0')}';
      return orderNumber;
    } catch (e) {
      print('Error generating order number: $e');
      return 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Get order with all customizations
  Future<Map<String, dynamic>?> getOrderWithDetails(String orderId) async {
    try {
      // Get order details
      final orderResponse = await _supabase
          .from('orders')
          .select()
          .eq('order_id', orderId)
          .single();

      // Get order items
      final itemsResponse = await _supabase
          .from('order_items')
          .select()
          .eq('order_id', orderId);

      // Get customizations for each item
      List<Map<String, dynamic>> itemsWithCustomizations = [];

      for (final item in itemsResponse) {
        final customizationsResponse = await _supabase
            .from('order_item_customizations')
            .select()
            .eq('order_id', orderId)
            .eq('item_id', item['item_id']);

        itemsWithCustomizations.add({
          ...item,
          'customizations': customizationsResponse,
        });
      }

      return {
        ...orderResponse,
        'items': itemsWithCustomizations,
      };
    } catch (e) {
      print('Error fetching order details: $e');
      return null;
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(
    String orderId,
    String newStatus,
  ) async {
    try {
      await _supabase
          .from('orders')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('order_id', orderId);

      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  /// Update delivery status
  Future<bool> updateDeliveryStatus(
    String orderId,
    String newStatus,
  ) async {
    try {
      await _supabase
          .from('orders')
          .update({
            'delivery_status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('order_id', orderId);

      return true;
    } catch (e) {
      print('Error updating delivery status: $e');
      return false;
    }
  }

  /// Get orders by customer
  Future<List<Map<String, dynamic>>> getOrdersByCustomer(
      String customerId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching customer orders: $e');
      return [];
    }
  }

  /// Get orders by restaurant
  Future<List<Map<String, dynamic>>> getOrdersByRestaurant(
    String restaurantId, {
    String? status,
  }) async {
    try {
      var query = _supabase
          .from('orders')
          .select()
          .eq('hotel_id', restaurantId);

      if (status != null) {
        query = query.eq('status', status);
      }

      final response =
          await query.order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching restaurant orders: $e');
      return [];
    }
  }

  /// Search orders by order number
  Future<Map<String, dynamic>?> searchOrderByNumber(String orderNumber) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('order_number', orderNumber)
          .single();

      return response;
    } catch (e) {
      print('Error searching order: $e');
      return null;
    }
  }

  /// Get today's orders
  Future<List<Map<String, dynamic>>> getTodayOrders(
      String restaurantId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('orders')
          .select()
          .eq('hotel_id', restaurantId)
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String())
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching today orders: $e');
      return [];
    }
  }

  /// Calculate order statistics
  Future<Map<String, dynamic>> getOrderStatistics(String restaurantId) async {
    try {
      final allOrders = await _supabase
          .from('orders')
          .select()
          .eq('hotel_id', restaurantId);

      final totalOrders = allOrders.length;
      final totalRevenue = (allOrders as List).fold<double>(
          0, (sum, order) => sum + (order['total_amount'] ?? 0));

      final deliveredCount = (allOrders as List)
          .where((o) => o['delivery_status'] == 'Delivered')
          .length;

      return {
        'total_orders': totalOrders,
        'total_revenue': totalRevenue,
        'delivered_orders': deliveredCount,
        'pending_orders': totalOrders - deliveredCount,
        'average_order_value': totalOrders > 0 ? totalRevenue / totalOrders : 0,
      };
    } catch (e) {
      print('Error calculating statistics: $e');
      return {
        'total_orders': 0,
        'total_revenue': 0,
        'delivered_orders': 0,
        'pending_orders': 0,
        'average_order_value': 0,
      };
    }
  }

  /// Get order by ID (simple)
  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('order_id', orderId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error fetching order: $e');
      return null;
    }
  }

  /// Update order
  Future<bool> updateOrder(String orderId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('orders')
          .update(data)
          .eq('order_id', orderId);

      return true;
    } catch (e) {
      print('Error updating order: $e');
      return false;
    }
  }

  /// Delete order
  Future<bool> deleteOrder(String orderId) async {
    try {
      // Delete order items customizations first
      await _supabase
          .from('order_item_customizations')
          .delete()
          .eq('order_id', orderId);

      // Delete order items
      await _supabase
          .from('order_items')
          .delete()
          .eq('order_id', orderId);

      // Delete order
      await _supabase
          .from('orders')
          .delete()
          .eq('order_id', orderId);

      return true;
    } catch (e) {
      print('Error deleting order: $e');
      return false;
    }
  }

  /// Filter orders by status
  Future<List<Map<String, dynamic>>> getOrdersByStatus(
    String restaurantId,
    String status,
  ) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('hotel_id', restaurantId)
          .eq('status', status)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching orders by status: $e');
      return [];
    }
  }

  /// Filter orders by delivery status
  Future<List<Map<String, dynamic>>> getOrdersByDeliveryStatus(
    String restaurantId,
    String deliveryStatus,
  ) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('hotel_id', restaurantId)
          .eq('delivery_status', deliveryStatus)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching orders by delivery status: $e');
      return [];
    }
  }

  /// Assign delivery person to order
  Future<bool> assignDeliveryPerson(
      String orderId, String deliveryPersonId) async {
    try {
      await _supabase
          .from('orders')
          .update({
            'delivery_person_id': deliveryPersonId,
            'delivery_status': 'Assigned',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('order_id', orderId);

      return true;
    } catch (e) {
      print('Error assigning delivery person: $e');
      return false;
    }
  }

  /// Mark order as ready
  Future<bool> markOrderReady(String orderId) async {
    try {
      await _supabase
          .from('orders')
          .update({
            'status': 'Ready',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('order_id', orderId);

      return true;
    } catch (e) {
      print('Error marking order ready: $e');
      return false;
    }
  }

  /// Mark order as delivered
  Future<bool> markOrderDelivered(String orderId) async {
    try {
      await _supabase
          .from('orders')
          .update({
            'delivery_status': 'Delivered',
            'delivery_time': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('order_id', orderId);

      return true;
    } catch (e) {
      print('Error marking order delivered: $e');
      return false;
    }
  }

  /// Calculate total for order with customizations
  Future<double> calculateOrderTotal(String orderId) async {
    try {
      final itemsResponse = await _supabase
          .from('order_items')
          .select()
          .eq('order_id', orderId);

      double total = 0;

      for (final item in itemsResponse) {
        final customizationsResponse = await _supabase
            .from('order_item_customizations')
            .select()
            .eq('order_id', orderId)
            .eq('item_id', item['item_id']);

        double customizationTotal = 0;
        for (final custom in customizationsResponse) {
          customizationTotal += custom['additional_price'] ?? 0;
        }

        final itemTotal =
            (item['price'] + customizationTotal) * item['quantity'];
        total += itemTotal;
      }

      return total;
    } catch (e) {
      print('Error calculating order total: $e');
      return 0;
    }
  }
}