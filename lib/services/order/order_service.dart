// services/order/order_service_enhanced.dart
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/services/delivery_person_service.dart';
import 'package:naivedhya/services/order/order_item_service.dart';
import 'package:naivedhya/services/restaurant_service.dart';
import 'package:naivedhya/services/ventor_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final _supabase = Supabase.instance.client;
  static const String _tableName = 'orders';
  static const int _pageSize = 10;

  final _restaurantService = RestaurantService();
  final VendorService _vendorService = VendorService();
  final DeliveryPersonnelService _deliveryService = DeliveryPersonnelService();
  final AddOrderItemService _orderItemService = AddOrderItemService();

  /// Fetch paginated orders with optional status filter
  /// Returns list of orders sorted by created_at (newest first)
  Future<List<Order>> fetchOrders({
    int page = 0,
    String? statusFilter,
  }) async {
    try {
      int offset = page * _pageSize;

      dynamic query = _supabase.from(_tableName).select();

      // Apply status filter first
      if (statusFilter != null && statusFilter.isNotEmpty) {
        query = query.eq('status', statusFilter);
      }

      // Apply ordering and pagination after filtering
      query = query
          .order('created_at', ascending: false)
          .range(offset, offset + _pageSize - 1);

      final response = await query;
      return (response as List)
          .map((order) => Order.fromJson(order))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  /// Fetch orders with enriched data (restaurant, vendor, delivery details)
  Future<List<Map<String, dynamic>>> fetchOrdersWithDetails({
    int page = 0,
    String? statusFilter,
  }) async {
    try {
      final orders = await fetchOrders(page: page, statusFilter: statusFilter);
      
      List<Map<String, dynamic>> enrichedOrders = [];

      for (final order in orders) {
        final enriched = await enrichOrderData(order);
        enrichedOrders.add(enriched);
      }

      return enrichedOrders;
    } catch (e) {
      throw Exception('Failed to fetch orders with details: $e');
    }
  }

  /// Enrich single order with restaurant, vendor, and delivery details
  Future<Map<String, dynamic>> enrichOrderData(Order order) async {
    try {
      // Fetch restaurant details
      final restaurantDetails = await _restaurantService.getRestaurantDetails(order.restaurantId);
      
      // Fetch vendor details
      final vendorDetails = await _vendorService.getVendorDetails(order.vendorId);
      
      // Fetch order items
      final orderItems = await _orderItemService.getOrderItems(order.orderId);
      
      // Fetch delivery personnel details if assigned
      Map<String, dynamic>? deliveryDetails;
      if (order.deliveryPersonId != null) {
        try {
          final deliveryPersonnel = await _deliveryService.fetchDeliveryPersonnelById(order.deliveryPersonId!);
          if (deliveryPersonnel != null) {
            deliveryDetails = {
              'id': deliveryPersonnel.userId,
              'name': deliveryPersonnel.fullName,
              'phone': deliveryPersonnel.phone,
              'email': deliveryPersonnel.email,
              'vehicleType': deliveryPersonnel.vehicleType,
              'numberPlate': deliveryPersonnel.numberPlate,
            };
          }
        } catch (e) {
          print('Error fetching delivery details: $e');
        }
      }

      return {
        'order': order,
        'restaurant': restaurantDetails,
        'vendor': vendorDetails,
        'deliveryPersonnel': deliveryDetails,
        'orderItems': orderItems,
      };
    } catch (e) {
      throw Exception('Failed to enrich order data: $e');
    }
  }

  /// Get total count of orders (with optional status filter)
  Future<PostgrestResponse<PostgrestList>> getOrdersCount({String? statusFilter}) async {
    try {
      final query = _supabase.from(_tableName).select('id');

      if (statusFilter != null && statusFilter.isNotEmpty) {
        final response = await query.eq('status', statusFilter).count();
        return response;
      }

      final response = await query.count();
      return response;
    } catch (e) {
      throw Exception('Failed to get orders count: $e');
    }
  }

  /// Fetch single order by ID
  Future<Order?> fetchOrderById(String orderId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('order_id', orderId)
          .single();

      return Order.fromJson(response);
    } catch (e) {
      if (e.toString().contains('no rows')) {
        return null;
      }
      throw Exception('Failed to fetch order: $e');
    }
  }

  /// Fetch single order with enriched data
  Future<Map<String, dynamic>?> fetchOrderByIdWithDetails(String orderId) async {
    try {
      final order = await fetchOrderById(orderId);
      if (order == null) return null;

      return await enrichOrderData(order);
    } catch (e) {
      throw Exception('Failed to fetch order details: $e');
    }
  }

  /// Create new order
  Future<Order> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert(orderData)
          .select()
          .single();

      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Update order
  Future<Order> updateOrder(String orderId, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update(updates)
          .eq('order_id', orderId)
          .select()
          .single();

      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  /// Update only order status
  Future<Order> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update({'status': newStatus})
          .eq('order_id', orderId)
          .select()
          .single();

      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Delete order
  Future<void> deleteOrder(String orderId) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('order_id', orderId);
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  /// Get all available order statuses
  static const List<String> orderStatuses = [
    'pending',
    'confirmed',
    'preparing',
    'ready',
    'picked up',
    'delivering',
    'completed',
    'cancelled',
  ];

  /// Get display name for status
  static String getStatusDisplayName(String status) {
    return status.split('_').join(' ').toUpperCase();
  }

  /// Get status badge type for UI
  static String getStatusBadgeType(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'pending') return 'Urgent';
    if (lowerStatus == 'delivering' || lowerStatus == 'picked up') return 'Active';
    if (lowerStatus == 'completed') return 'Completed';
    if (lowerStatus == 'cancelled') return 'Cancelled';
    return 'Active';
  }
}