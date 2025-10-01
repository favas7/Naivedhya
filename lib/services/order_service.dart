// services/order_service.dart (Updated with createOrder method)
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/services/delivery_person_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final DeliveryPersonnelService _deliveryService = DeliveryPersonnelService();
  static const int ordersPerPage = 20;

  Future<List<Order>> fetchOrders({
    int page = 0,
    int limit = ordersPerPage,
  }) async {
    try {
      final from = page * limit;
      final to = from + limit - 1;

      final response = await _supabase
          .from('orders')
          .select()
          .order('created_at', ascending: false)
          .range(from, to);

      return (response as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: ${e.toString()}');
    }
  }

  Future<Order> fetchOrderById(String orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('order_id', orderId)
          .single();

      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch order: ${e.toString()}');
    }
  }

  // New method for creating orders
  Future<Order> createOrder(Order order) async {
    try {
      final orderData = {
        'order_id': order.orderId,
        'customer_id': order.customerId,
        'vendor_id': order.vendorId,
        'hotel_id': order.hotelId,
        'order_number': order.orderNumber,
        'total_amount': order.totalAmount,
        'status': order.status,
        'customer_name': order.customerName,
        'delivery_status': order.deliveryStatus,
        'delivery_person_id': order.deliveryPersonId,
        'proposed_delivery_time': order.proposedDeliveryTime?.toIso8601String(),
        'pickup_time': order.pickupTime?.toIso8601String(),
        'delivery_time': order.deliveryTime?.toIso8601String(),
        'created_at': order.createdAt.toIso8601String(),
        'updated_at': order.updatedAt.toIso8601String(),
      };

      final response = await _supabase
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }

  Future<Order> updateOrder(Order order) async {
    try {
      final response = await _supabase
          .from('orders')
          .update({
            'status': order.status,
            'delivery_status': order.deliveryStatus,
            'delivery_person_id': order.deliveryPersonId,
            'proposed_delivery_time': order.proposedDeliveryTime?.toIso8601String(),
            'pickup_time': order.pickupTime?.toIso8601String(),
            'delivery_time': order.deliveryTime?.toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('order_id', order.orderId)
          .select()
          .single();

      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update order: ${e.toString()}');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _supabase
          .from('orders')
          .delete()
          .eq('order_id', orderId);
    } catch (e) {
      throw Exception('Failed to delete order: ${e.toString()}');
    }
  }

  // New method for assigning delivery personnel
  Future<bool> assignDeliveryPersonnel(String orderId, String deliveryPersonId) async {
    try {
      final success = await _deliveryService.assignOrderToDeliveryPersonnel(
        orderId,
        deliveryPersonId,
      );
      return success;
    } catch (e) {
      throw Exception('Failed to assign delivery personnel: ${e.toString()}');
    }
  }

  // New method for unassigning delivery personnel
  Future<bool> unassignDeliveryPersonnel(String orderId, String? currentDeliveryPersonId) async {
    try {
      final success = await _deliveryService.unassignOrderFromDeliveryPersonnel(
        orderId,
        currentDeliveryPersonId,
      );
      return success;
    } catch (e) {
      throw Exception('Failed to unassign delivery personnel: ${e.toString()}');
    }
  }

  // New method to update order status with delivery tracking
  Future<Order> updateOrderStatus(String orderId, String status, {
    String? deliveryStatus,
    DateTime? proposedDeliveryTime,
    DateTime? pickupTime,
    DateTime? deliveryTime,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (deliveryStatus != null) {
        updateData['delivery_status'] = deliveryStatus;
      }

      if (proposedDeliveryTime != null) {
        updateData['proposed_delivery_time'] = proposedDeliveryTime.toIso8601String();
      }

      if (pickupTime != null) {
        updateData['pickup_time'] = pickupTime.toIso8601String();
      }

      if (deliveryTime != null) {
        updateData['delivery_time'] = deliveryTime.toIso8601String();
      }

      final response = await _supabase
          .from('orders')
          .update(updateData)
          .eq('order_id', orderId)
          .select()
          .single();

      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }

  Future<List<Order>> searchOrders({
    String? searchQuery,
    String? statusFilter,
    int page = 0,
    int limit = ordersPerPage,
  }) async {
    try {
      final from = page * limit;
      final to = from + limit - 1;

      // Build the base query
      var query = _supabase
          .from('orders')
          .select();

      // Apply status filter first if provided
      if (statusFilter != null && statusFilter != 'All') {
        query = query.eq('status', statusFilter);
      }

      // Apply search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'order_number.ilike.%$searchQuery%,'
          'customer_name.ilike.%$searchQuery%,'
          'status.ilike.%$searchQuery%'
        );
      }

      // Apply ordering and pagination
      final response = await query
          .order('created_at', ascending: false)
          .range(from, to);

      return (response as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search orders: ${e.toString()}');
    }
  }

  // Alternative search method if the above doesn't work
  Future<List<Order>> searchOrdersAlternative({
    String? searchQuery,
    String? statusFilter,
    int page = 0,
    int limit = ordersPerPage,
  }) async {
    try {
      final from = page * limit;
      final to = from + limit - 1;

      // If no filters, just fetch normally
      if ((searchQuery == null || searchQuery.isEmpty) && 
          (statusFilter == null || statusFilter == 'All')) {
        return await fetchOrders(page: page, limit: limit);
      }

      // Build query with filters
      PostgrestFilterBuilder query = _supabase
          .from('orders')
          .select();

      // Apply status filter
      if (statusFilter != null && statusFilter != 'All') {
        query = query.eq('status', statusFilter);
      }

      // Apply search filter using textSearch or ilike
      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Try different approaches based on your Supabase version
        query = query.or('order_number.ilike.%$searchQuery%,customer_name.ilike.%$searchQuery%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(from, to);

      return (response as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search orders: ${e.toString()}');
    }
  }

  // Simplified search method for older Supabase versions
  Future<List<Order>> searchOrdersSimple({
    String? searchQuery,
    String? statusFilter,
    int page = 0,
    int limit = ordersPerPage,
  }) async {
    try {
      final from = page * limit;
      final _ = from + limit - 1;

      // Fetch all orders first, then filter locally
      // This is less efficient but more compatible
      List<Order> allOrders = await fetchOrders(page: page, limit: limit * 2); // Fetch more to account for filtering

      // Apply filters locally
      List<Order> filteredOrders = allOrders.where((order) {
        bool matchesSearch = searchQuery == null || 
            searchQuery.isEmpty ||
            order.orderNumber.toLowerCase().contains(searchQuery.toLowerCase()) ||
            (order.customerName?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
            order.status.toLowerCase().contains(searchQuery.toLowerCase());

        bool matchesStatus = statusFilter == null || 
            statusFilter == 'All' || 
            order.status == statusFilter;

        return matchesSearch && matchesStatus;
      }).toList();

      // Apply pagination locally
      final startIndex = page * limit;
      final endIndex = (startIndex + limit).clamp(0, filteredOrders.length);
      
      if (startIndex >= filteredOrders.length) {
        return [];
      }

      return filteredOrders.sublist(startIndex, endIndex);
    } catch (e) {
      throw Exception('Failed to search orders: ${e.toString()}');
    }
  }

  Stream<List<Order>> getOrdersStream() {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['order_id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Order.fromJson(json)).toList());
  }
}