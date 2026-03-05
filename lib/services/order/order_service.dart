// services/order/order_service_enhanced.dart - WITH DEBUG LOGGING
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/services/delivery_person_service.dart';
import 'package:naivedhya/services/order/order_item_service.dart';
import 'package:naivedhya/services/restaurant_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final _supabase = Supabase.instance.client;
  static const String _tableName = 'orders';
  static const int _pageSize = 10;

  

  final _restaurantService = RestaurantService();
  final DeliveryPersonnelService _deliveryService = DeliveryPersonnelService();
  final AddOrderItemService _orderItemService = AddOrderItemService();




  Future<bool> assignDeliveryPartner({
    required String orderId,
    required String deliveryPersonId,
  }) async {
    try {
      print('🚚 [OrderService] Assigning delivery partner...');
      print('   - Order ID: $orderId');
      print('   - Delivery Person ID: $deliveryPersonId');

      // Update order with delivery person and status
      await _supabase.from(_tableName).update({
        'delivery_person_id': deliveryPersonId,
        'delivery_status': 'Assigned',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('order_id', orderId);

      print('✅ [OrderService] Order updated with delivery partner');

      // Get current assigned orders for the delivery person
      final deliveryPerson = await _supabase
          .from('delivery_personnel')
          .select('assigned_orders')
          .eq('user_id', deliveryPersonId)
          .single();

      print('📦 [OrderService] Current assigned orders: ${deliveryPerson['assigned_orders']}');

      // Handle both NULL and existing arrays
      List<String> currentOrders = [];
      if (deliveryPerson['assigned_orders'] != null) {
        // It's a text[] in PostgreSQL, comes as List in Dart
        currentOrders = List<String>.from(deliveryPerson['assigned_orders']);
      }

      // Add new order if not already present
      if (!currentOrders.contains(orderId)) {
        currentOrders.add(orderId);
      }

      print('📦 [OrderService] Updated assigned orders: $currentOrders');

      // Update delivery personnel
      await _supabase.from('delivery_personnel').update({
        'assigned_orders': currentOrders,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', deliveryPersonId);

      print('✅ [OrderService] Delivery partner assigned_orders updated');
      print('✅ [OrderService] Assignment completed successfully!');

      return true;
    } catch (e) {
      print('❌ [OrderService] ERROR assigning delivery partner: $e');
      print('❌ [OrderService] Stack trace: ${StackTrace.current}');
      throw Exception('Failed to assign delivery partner: $e');
    }
  }

    Future<List<Order>> fetchOrders({
      int page = 0,
      String? statusFilter,
      String? orderTypeFilter, // ✅ ADD THIS PARAMETER
    }) async {
      try {
        print('🔍 [OrderService] Fetching orders - Page: $page, Status: $statusFilter, OrderType: $orderTypeFilter');
        
        int offset = page * _pageSize;

        dynamic query = _supabase.from(_tableName).select();

        // Apply status filter
        if (statusFilter != null && statusFilter.isNotEmpty) {
          query = query.eq('status', statusFilter);
          print('📊 [OrderService] Applied status filter: $statusFilter');
        }

        // ✅ ADD ORDER TYPE FILTER
        if (orderTypeFilter != null && orderTypeFilter.isNotEmpty) {
          query = query.eq('order_type', orderTypeFilter);
          print('📊 [OrderService] Applied order_type filter: $orderTypeFilter');
        }

        // Apply ordering and pagination after filtering
        query = query
            .order('created_at', ascending: false)
            .range(offset, offset + _pageSize - 1);

        print('⏳ [OrderService] Executing query...');
        final response = await query;
        
        print('✅ [OrderService] Query successful! Received ${(response as List).length} orders');
        
        final orders = (response)
            .map((order) => Order.fromJson(order))
            .toList();
        
        print('✅ [OrderService] Successfully parsed ${orders.length} Order objects');
        return orders;
      } catch (e) {
        print('❌ [OrderService] ERROR in fetchOrders: $e');
        print('❌ [OrderService] Stack trace: ${StackTrace.current}');
        throw Exception('Failed to fetch orders: $e');
      }
    }



    
  /// Fetch orders with enriched data (restaurant, vendor, delivery details)
  Future<List<Map<String, dynamic>>> fetchOrdersWithDetails({
    int page = 0,
    String? statusFilter,
    String? orderTypeFilter, // ✅ ADD THIS PARAMETER
  }) async {
    try {
      print('\n🚀 [OrderService] ========== FETCH ORDERS WITH DETAILS ==========');
      print('📄 [OrderService] Page: $page, Status Filter: $statusFilter, OrderType Filter: $orderTypeFilter');
      
      final orders = await fetchOrders(
        page: page, 
        statusFilter: statusFilter,
        orderTypeFilter: orderTypeFilter, // ✅ PASS IT HERE
      );
      print('📦 [OrderService] Fetched ${orders.length} orders, now enriching...');
      
        List<Map<String, dynamic>> enrichedOrders = [];

        for (int i = 0; i < orders.length; i++) {
          final order = orders[i];
          print('\n--- Enriching Order ${i + 1}/${orders.length} ---');
          print('🆔 [OrderService] Order ID: ${order.orderId}');
          print('📝 [OrderService] Order Number: ${order.orderNumber}');
          
          try {
            final enriched = await enrichOrderData(order);
            enrichedOrders.add(enriched);
            print('✅ [OrderService] Successfully enriched order ${order.orderNumber}');
          } catch (e) {
            print('⚠️ [OrderService] Failed to enrich order ${order.orderNumber}: $e');
            // Add order with null details instead of failing completely
            enrichedOrders.add({
              'order': order,
              'restaurant': null,
              'vendor': null,
              'deliveryPersonnel': null,
              'orderItems': [],
            });
          }
        }

        print('\n✅ [OrderService] ========== ENRICHMENT COMPLETE ==========');
        print('📊 [OrderService] Total enriched orders: ${enrichedOrders.length}');
        return enrichedOrders;
      } catch (e) {
        print('❌ [OrderService] ERROR in fetchOrdersWithDetails: $e');
        print('❌ [OrderService] Stack trace: ${StackTrace.current}');
        throw Exception('Failed to fetch orders with details: $e');
      }
    }

    

  /// Enrich single order with restaurant, vendor, and delivery details
  Future<Map<String, dynamic>> enrichOrderData(Order order) async {
    try {
      print('\n🔧 [OrderService] === Enriching Order Data ===');
      print('🆔 Order ID: ${order.orderId}');
      print('🏨 Restaurant ID: ${order.restaurantId}');
      print('🚚 Delivery Person ID: ${order.deliveryPersonId}');
      
      // Fetch restaurant details
      print('\n📍 [OrderService] Fetching restaurant details...');
      Map<String, dynamic>? restaurantMap;
      try {
        final restaurant = await _restaurantService.getRestaurantById(order.restaurantId);
        print('🏨 [OrderService] Restaurant service returned: ${restaurant != null ? "Restaurant object" : "null"}');
        
        if (restaurant != null) {
          print('✅ [OrderService] Restaurant found: ${restaurant.name}');
          restaurantMap = {
            'id': restaurant.id,
            'name': restaurant.name,
            'address': restaurant.address,
            'city': restaurant.address,
            'email': restaurant.adminEmail,
          };
          print('✅ [OrderService] Restaurant mapped successfully');
        } else {
          print('⚠️ [OrderService] Restaurant not found for ID: ${order.restaurantId}');
        }
      } catch (e) {
        print('❌ [OrderService] ERROR fetching restaurant: $e');
      }
       // Fetch customer profile
        print('\n👤 [OrderService] Fetching customer profile...');
        Map<String, dynamic>? customerProfile;
        if (order.customerId != null) {
          customerProfile = await _fetchCustomerProfile(order.customerId!);
          if (customerProfile != null) {
        print('✅ [OrderService] Customer found: ${customerProfile['name']}'); // ✅          }
        }
        } else {
          print('ℹ️ [OrderService] No customer_id (POS order)');
        }

        // Fetch delivery address
        print('\n📍 [OrderService] Fetching delivery address...');
        String? resolvedAddress;
        if (order.deliveryAddressId != null) {
          resolvedAddress = await _fetchAddressText(order.deliveryAddressId!);
          print('✅ [OrderService] Address resolved: $resolvedAddress');
        } else {
          print('ℹ️ [OrderService] No delivery_address UUID on this order');
        }
      

      // Fetch order items
      print('\n📦 [OrderService] Fetching order items...');
      List orderItems = [];
      try {
        orderItems = await _orderItemService.getOrderItems(order.orderId);
        print('✅ [OrderService] Found ${orderItems.length} order items');
      } catch (e) {
        print('❌ [OrderService] ERROR fetching order items: $e');
      }
      
      // Fetch delivery personnel details if assigned
      print('\n🚚 [OrderService] Fetching delivery personnel...');
      Map<String, dynamic>? deliveryDetails;
      if (order.deliveryPersonId != null) {
        try {
          final deliveryPersonnel = await _deliveryService.fetchDeliveryPersonnelById(order.deliveryPersonId!);
          if (deliveryPersonnel != null) {
            print('✅ [OrderService] Delivery personnel found: ${deliveryPersonnel.fullName}');
            deliveryDetails = {
              'id': deliveryPersonnel.userId,
              'name': deliveryPersonnel.fullName,
              'phone': deliveryPersonnel.phone,
              'email': deliveryPersonnel.email,
              'vehicleType': deliveryPersonnel.vehicleType,
              'numberPlate': deliveryPersonnel.numberPlate,
            };
          } else {
            print('⚠️ [OrderService] Delivery personnel not found');
          }
        } catch (e) {
          print('❌ [OrderService] ERROR fetching delivery personnel: $e');
        }
      } else {
        print('ℹ️ [OrderService] No delivery person assigned yet');
      }


      final enrichedData = {
        'order': order,
        'restaurant': restaurantMap,
        'customer': customerProfile,       // NEW
        'resolvedAddress': resolvedAddress, // NEW
        'deliveryPersonnel': deliveryDetails,
        'orderItems': orderItems,
      };

      print('\n✅ [OrderService] === Enrichment Complete ===');
      print('📊 Summary:');
      print('   - Restaurant: ${restaurantMap != null ? "✅" : "❌"}');
      print('   - Order Items: ${orderItems.length} items');
      print('   - Delivery Personnel: ${deliveryDetails != null ? "✅" : "ℹ️ Not assigned"}');
      
      return enrichedData;
    } catch (e) {
      print('❌ [OrderService] CRITICAL ERROR in enrichOrderData: $e');
      print('❌ [OrderService] Stack trace: ${StackTrace.current}');
      throw Exception('Failed to enrich order data: $e');
    }
  }

  /// Fetch single order by ID
  Future<Order?> fetchOrderById(String orderId) async {
    try {
      print('🔍 [OrderService] Fetching order by ID: $orderId');
      
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('order_id', orderId)
          .single();

      print('✅ [OrderService] Order found and parsed successfully');
      return Order.fromJson(response);
    } catch (e) {
      if (e.toString().contains('no rows')) {
        print('⚠️ [OrderService] No order found with ID: $orderId');
        return null;
      }
      print('❌ [OrderService] ERROR fetching order by ID: $e');
      throw Exception('Failed to fetch order: $e');
    }
  }

  /// Fetch single order with enriched data
  Future<Map<String, dynamic>?> fetchOrderByIdWithDetails(String orderId) async {
    try {
      print('🔍 [OrderService] Fetching order with details - ID: $orderId');
      
      final order = await fetchOrderById(orderId);
      if (order == null) {
        print('⚠️ [OrderService] Order not found, returning null');
        return null;
      }

      print('📦 [OrderService] Order found, enriching data...');
      return await enrichOrderData(order);
    } catch (e) {
      print('❌ [OrderService] ERROR in fetchOrderByIdWithDetails: $e');
      throw Exception('Failed to fetch order details: $e');
    }
  }

  /// Create new order
  Future<Order> createOrder(Map<String, dynamic> orderData) async {
    try {
      print('➕ [OrderService] Creating new order...');
      print('📝 [OrderService] Order data: $orderData');
      
      final response = await _supabase
          .from(_tableName)
          .insert(orderData)
          .select()
          .single();

      print('✅ [OrderService] Order created successfully!');
      return Order.fromJson(response);
    } catch (e) {
      print('❌ [OrderService] ERROR creating order: $e');
      throw Exception('Failed to create order: $e');
    }
  }

  /// Update order
  Future<Order> updateOrder(String orderId, Map<String, dynamic> updates) async {
    try {
      print('📝 [OrderService] Updating order: $orderId');
      print('🔄 [OrderService] Updates: $updates');
      
      final response = await _supabase
          .from(_tableName)
          .update(updates)
          .eq('order_id', orderId)
          .select()
          .single();

      print('✅ [OrderService] Order updated successfully!');
      return Order.fromJson(response);
    } catch (e) {
      print('❌ [OrderService] ERROR updating order: $e');
      throw Exception('Failed to update order: $e');
    }
  }

  /// Update only order status
  Future<Order> updateOrderStatus(String orderId, String newStatus) async {
    try {
      print('🔄 [OrderService] Updating order status: $orderId → $newStatus');
      
      final response = await _supabase
          .from(_tableName)
          .update({'status': newStatus})
          .eq('order_id', orderId)
          .select()
          .single();

      print('✅ [OrderService] Order status updated successfully!');
      return Order.fromJson(response);
    } catch (e) {
      print('❌ [OrderService] ERROR updating order status: $e');
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Delete order
  Future<void> deleteOrder(String orderId) async {
    try {
      print('🗑️ [OrderService] Deleting order: $orderId');
      
      await _supabase
          .from(_tableName)
          .delete()
          .eq('order_id', orderId);

      print('✅ [OrderService] Order deleted successfully!');
    } catch (e) {
      print('❌ [OrderService] ERROR deleting order: $e');
      throw Exception('Failed to delete order: $e');
    }
  }

  Future<List<Order>> fetchOrdersByCustomerId(String customerId) async {
    try {
      print('🔍 [OrderService] Fetching orders for customer: $customerId');
      
      final response = await Supabase.instance.client
          .from('orders')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      print('✅ [OrderService] Found ${(response as List).length} orders for customer');
      
      return (response).map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      print('❌ [OrderService] Error fetching customer orders: $e');
      throw Exception('Failed to fetch customer orders: $e');
    }
  }

  Future<String?> _fetchAddressText(String addressId) async {
  try {
    final response = await _supabase
        .from('addresses')
        .select('fulladdress, label')
        .eq('addressid', addressId)
        .single();
    final label = response['label'] as String?;
    final full = response['fulladdress'] as String;
    return label != null ? '$label: $full' : full;
  } catch (e) {
    print('⚠️ [OrderService] Could not fetch address $addressId: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> _fetchCustomerProfile(String customerId) async {
  try {
    final response = await _supabase
        .from('profiles')
        .select('id, name, phone, email')
        .eq('id', customerId)
        .maybeSingle();
    return response; // ✅ actually return it
  } catch (e) {
    print('⚠️ [OrderService] Could not fetch customer profile $customerId: $e');
    return null;
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
}