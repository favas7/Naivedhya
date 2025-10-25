// // lib/providers/order_provider.dart
// import 'package:flutter/material.dart';
// import 'package:naivedhya/models/order_item_model.dart';
// import 'package:naivedhya/models/order_model.dart';
// import 'package:naivedhya/services/order/order_service.dart';
// import 'package:naivedhya/services/order/order_item_service.dart';

// class OrderProvider extends ChangeNotifier {
//   final OrderService _orderService = OrderService();
//   final OrderItemService _orderItemService = OrderItemService();

//   // State management
//   List<Order> _orders = [];
//   List<Order> _filteredOrders = [];
//   Map<String, List<OrderItem>> _orderItemsCache = {}; // Cache order items
//   bool _isLoading = true;
//   bool _isLoadingMore = false;
//   String? _error;
//   String _selectedStatus = 'All';
//   String _searchQuery = '';

//   // Pagination
//   int _currentPage = 0;
//   static const int ordersPerPage = 20;
//   bool _hasMore = true;

//   // Context filters
//   String? _restaurantId;
//   String? _customerId;

//   // Getters
//   List<Order> get orders => _orders;
//   List<Order> get filteredOrders => _filteredOrders;
//   bool get isLoading => _isLoading;
//   bool get isLoadingMore => _isLoadingMore;
//   String? get error => _error;
//   String get selectedStatus => _selectedStatus;
//   String get searchQuery => _searchQuery;
//   bool get hasMore => _hasMore;

//   final List<String> statusOptions = [
//     'All',
//     'Pending',
//     'Confirmed',
//     'Preparing',
//     'Ready',
//     'Out for Delivery',
//     'Delivered',
//     'Cancelled'
//   ];

//   /// Initialize provider with restaurant context
//   void setRestaurantId(String restaurantId) {
//     _restaurantId = restaurantId;
//   }

//   /// Initialize provider with customer context
//   void setCustomerId(String customerId) {
//     _customerId = customerId;
//   }

//   /// Load orders based on context (restaurant or customer)
//   Future<void> loadOrders({bool loadMore = false}) async {
//     if (loadMore && (_isLoadingMore || !_hasMore)) return;

//     if (loadMore) {
//       _isLoadingMore = true;
//     } else {
//       _isLoading = true;
//       _currentPage = 0;
//       _hasMore = true;
//       _error = null;
//     }
//     notifyListeners();

//     try {
//       List<Map<String, dynamic>> ordersData = [];

//       // Fetch orders based on context
//       if (_restaurantId != null) {
//         ordersData = await _orderService.getOrdersByRestaurant(_restaurantId!);
//       } else if (_customerId != null) {
//         ordersData = await _orderService.getOrdersByCustomer(_customerId!);
//       } else {
//         throw Exception('No restaurant or customer context set');
//       }

//       // Convert to Order models
//       final newOrders = ordersData
//           .map((json) => Order.fromJson(json))
//           .toList();

//       // Apply pagination
//       final startIndex = _currentPage * ordersPerPage;
//       final endIndex = startIndex + ordersPerPage;
//       final paginatedOrders = newOrders.length > startIndex
//           ? newOrders.sublist(
//               startIndex,
//               endIndex > newOrders.length ? newOrders.length : endIndex,
//             )
//           : [];

//       if (loadMore) {
//         _orders.addAll(paginatedOrders.cast<Order>());
//         _isLoadingMore = false;
//       } else {
//         _orders = newOrders;
//         _isLoading = false;
//       }

//       _hasMore = paginatedOrders.length == ordersPerPage;
//       if (loadMore) _currentPage++;

//       _applyFilters();
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       _isLoadingMore = false;
//       notifyListeners();
//     }
//   }

//   /// Search orders by number, customer name, or status
//   Future<void> searchOrders() async {
//     _isLoading = true;
//     _error = null;
//     _currentPage = 0;
//     _hasMore = true;
//     notifyListeners();

//     try {
//       List<Map<String, dynamic>> ordersData = [];

//       if (_restaurantId != null) {
//         ordersData =
//             await _orderService.getOrdersByRestaurant(_restaurantId!);
//       } else if (_customerId != null) {
//         ordersData = await _orderService.getOrdersByCustomer(_customerId!);
//       }

//       final orders = ordersData
//           .map((json) => Order.fromJson(json))
//           .toList();

//       _orders = orders;
//       _isLoading = false;
//       _applyFilters();
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   /// Set search query and apply filters
//   void setSearchQuery(String query) {
//     _searchQuery = query;
//     _applyFilters();
//   }

//   /// Set status filter and apply filters
//   void setSelectedStatus(String status) {
//     _selectedStatus = status;
//     _applyFilters();
//   }

//   /// Apply search and status filters to orders
//   void _applyFilters() {
//     _filteredOrders = _orders.where((order) {
//       bool matchesSearch = _searchQuery.isEmpty ||
//           order.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//           (order.customerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
//           order.status.toLowerCase().contains(_searchQuery.toLowerCase());

//       bool matchesStatus = _selectedStatus == 'All' ||
//           order.status == _selectedStatus;

//       return matchesSearch && matchesStatus;
//     }).toList();

//     notifyListeners();
//   }

//   /// Create order with items and customizations
//   Future<String?> createOrderWithItems({
//     required String restaurantId,
//     required String vendorId,
//     required String? customerId,
//     required String? guestName,
//     required String? guestPhone,
//     required String? deliveryAddress,
//     required List<OrderItem> orderItems,
//     required double totalAmount,
//     required String? proposedDeliveryTime,
//     required String deliveryStatus,
//     required String? deliveryPersonId,
//     required String specialInstructions,
//     required String paymentMethod,
//   }) async {
//     try {
//       _isLoading = true;
//       _error = null;
//       notifyListeners();

//       // Create order with items via service
//       final orderId = await _orderService.createOrder(
//         restaurantId: restaurantId,
//         vendorId: vendorId,
//         customerId: customerId,
//         guestName: guestName,
//         guestPhone: guestPhone,
//         deliveryAddress: deliveryAddress,
//         orderItems: orderItems,
//         totalAmount: totalAmount,
//         proposedDeliveryTime: proposedDeliveryTime,
//         deliveryStatus: deliveryStatus,
//         deliveryPersonId: deliveryPersonId,
//         specialInstructions: specialInstructions,
//         paymentMethod: paymentMethod,
//       );

//       if (orderId != null) {
//         // Fetch the created order
//         final orderData = await _orderService.getOrder(orderId);
//         if (orderData != null) {
//           final order = Order.fromJson(orderData);
//           _orders.insert(0, order);
          
//           // Cache the order items
//           _orderItemsCache[orderId] = orderItems;
          
//           _applyFilters();
//         }
//       }

//       _isLoading = false;
//       notifyListeners();
//       return orderId;
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       notifyListeners();
//       rethrow;
//     }
//   }

//   /// Load order items for a specific order
//   Future<List<OrderItem>> getOrderItems(String orderId) async {
//     try {
//       // Check cache first
//       if (_orderItemsCache.containsKey(orderId)) {
//         return _orderItemsCache[orderId]!;
//       }

//       // Fetch from service
//       final items = await _orderItemService.getOrderItems(orderId);
//       _orderItemsCache[orderId] = items;
//       return items;
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       rethrow;
//     }
//   }

//   /// Load order with all details and items
//   Future<Map<String, dynamic>?> getOrderDetails(String orderId) async {
//     try {
//       return await _orderService.getOrderWithDetails(orderId);
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       return null;
//     }
//   }

//   /// Get order items with customizations
//   Future<List<Map<String, dynamic>>> getOrderItemsWithCustomizations(
//       String orderId) async {
//     try {
//       return await _orderItemService.getOrderItemsWithCustomizations(orderId);
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       rethrow;
//     }
//   }

//   /// Update order status
//   Future<void> updateOrderStatus(String orderId, String newStatus) async {
//     try {
//       final success = await _orderService.updateOrderStatus(orderId, newStatus);

//       if (success) {
//         final index = _orders.indexWhere((o) => o.orderId == orderId);
//         if (index != -1) {
//           final updatedOrderData = await _orderService.getOrder(orderId);
//           if (updatedOrderData != null) {
//             _orders[index] = Order.fromJson(updatedOrderData);
//             _applyFilters();
//           }
//         }
//       }
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       rethrow;
//     }
//   }

//   /// Update delivery status
//   Future<void> updateDeliveryStatus(String orderId, String newStatus) async {
//     try {
//       final success = await _orderService.updateDeliveryStatus(orderId, newStatus);

//       if (success) {
//         final index = _orders.indexWhere((o) => o.orderId == orderId);
//         if (index != -1) {
//           final updatedOrderData = await _orderService.getOrder(orderId);
//           if (updatedOrderData != null) {
//             _orders[index] = Order.fromJson(updatedOrderData);
//             _applyFilters();
//           }
//         }
//       }
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       rethrow;
//     }
//   }

//   /// Assign delivery person to order
//   Future<void> assignDeliveryPerson(String orderId, String deliveryPersonId) async {
//     try {
//       final success = await _orderService.assignDeliveryPerson(orderId, deliveryPersonId);

//       if (success) {
//         final index = _orders.indexWhere((o) => o.orderId == orderId);
//         if (index != -1) {
//           final updatedOrderData = await _orderService.getOrder(orderId);
//           if (updatedOrderData != null) {
//             _orders[index] = Order.fromJson(updatedOrderData);
//             _applyFilters();
//           }
//         }
//       }
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       rethrow;
//     }
//   }

//   /// Assign delivery personnel to order (alias for compatibility with screens)
//   Future<void> assignDeliveryPersonnel(String orderId, String deliveryPersonId) async {
//     return assignDeliveryPerson(orderId, deliveryPersonId);
//   }

//   /// Unassign delivery personnel from order
//   Future<void> unassignDeliveryPersonnel(String orderId) async {
//     try {
//       final order = getOrderById(orderId);
//       if (order != null && order.deliveryPersonId != null) {
//         // Update delivery status to unassigned
//         await _orderService.updateDeliveryStatus(orderId, 'Pending');
        
//         // Update order data to remove delivery person
//         await _orderService.updateOrder(orderId, {
//           'delivery_person_id': null,
//           'delivery_status': 'Pending',
//         });

//         final index = _orders.indexWhere((o) => o.orderId == orderId);
//         if (index != -1) {
//           final updatedOrderData = await _orderService.getOrder(orderId);
//           if (updatedOrderData != null) {
//             _orders[index] = Order.fromJson(updatedOrderData);
//             _applyFilters();
//           }
//         }
//       }
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       rethrow;
//     }
//   }

//   /// Mark order as ready
//   Future<void> markOrderReady(String orderId) async {
//     try {
//       final success = await _orderService.markOrderReady(orderId);

//       if (success) {
//         await updateOrderStatus(orderId, 'Ready');
//       }
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       rethrow;
//     }
//   }

//   /// Mark order as delivered
//   Future<void> markOrderDelivered(String orderId) async {
//     try {
//       final success = await _orderService.markOrderDelivered(orderId);

//       if (success) {
//         final index = _orders.indexWhere((o) => o.orderId == orderId);
//         if (index != -1) {
//           final updatedOrderData = await _orderService.getOrder(orderId);
//           if (updatedOrderData != null) {
//             _orders[index] = Order.fromJson(updatedOrderData);
//             _applyFilters();
//           }
//         }
//       }
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       rethrow;
//     }
//   }

//   /// Update order items for an existing order
//   Future<void> updateOrderItems(
//       String orderId, List<OrderItem> orderItems) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       // Delete existing items
//       await _orderItemService.deleteOrderItems(orderId);

//       // Create new items
//       if (orderItems.isNotEmpty) {
//         final updatedItems = orderItems
//             .map((item) => item.copyWith(orderId: orderId))
//             .toList();
//         await _orderItemService.createOrderItems(updatedItems);
//       }

//       // Recalculate total
//       final newTotal = await _orderItemService.calculateOrderTotal(orderId);

//       // Update order total
//       await _orderService.updateOrder(
//         orderId,
//         {'total_amount': newTotal},
//       );

//       // Update in local list
//       final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
//       if (orderIndex != -1) {
//         final updatedOrderData = await _orderService.getOrder(orderId);
//         if (updatedOrderData != null) {
//           _orders[orderIndex] = Order.fromJson(updatedOrderData);
//           _orderItemsCache[orderId] = orderItems;
//           _applyFilters();
//         }
//       }

//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       notifyListeners();
//       rethrow;
//     }
//   }

//   /// Delete order with items and customizations
//   Future<void> deleteOrder(String orderId) async {
//     try {
//       final success = await _orderService.deleteOrder(orderId);

//       if (success) {
//         _orders.removeWhere((o) => o.orderId == orderId);
//         _orderItemsCache.remove(orderId);
//         _applyFilters();
//       }
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       rethrow;
//     }
//   }

//   /// Get orders by status
//   Future<List<Order>> getOrdersByStatus(String status) async {
//     try {
//       if (_restaurantId == null) {
//         throw Exception('Restaurant ID not set');
//       }

//       final ordersData = await _orderService.getOrdersByStatus(
//         _restaurantId!,
//         status,
//       );

//       return ordersData.map((json) => Order.fromJson(json)).toList();
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       return [];
//     }
//   }

//   /// Get orders by delivery status
//   Future<List<Order>> getOrdersByDeliveryStatus(String deliveryStatus) async {
//     try {
//       if (_restaurantId == null) {
//         throw Exception('Restaurant ID not set');
//       }

//       final ordersData =
//           await _orderService.getOrdersByDeliveryStatus(_restaurantId!, deliveryStatus);

//       return ordersData.map((json) => Order.fromJson(json)).toList();
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       return [];
//     }
//   }

//   /// Get today's orders
//   Future<List<Order>> getTodayOrders() async {
//     try {
//       if (_restaurantId == null) {
//         throw Exception('Restaurant ID not set');
//       }

//       final ordersData = await _orderService.getTodayOrders(_restaurantId!);
//       return ordersData.map((json) => Order.fromJson(json)).toList();
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       return [];
//     }
//   }

//   /// Get order statistics
//   Future<Map<String, dynamic>> getOrderStatistics() async {
//     try {
//       if (_restaurantId == null) {
//         throw Exception('Restaurant ID not set');
//       }

//       return await _orderService.getOrderStatistics(_restaurantId!);
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       return {
//         'total_orders': 0,
//         'total_revenue': 0,
//         'delivered_orders': 0,
//         'pending_orders': 0,
//         'average_order_value': 0,
//       };
//     }
//   }

//   /// Search order by number
//   Future<Order?> searchOrderByNumber(String orderNumber) async {
//     try {
//       final orderData = await _orderService.searchOrderByNumber(orderNumber);
//       return orderData != null ? Order.fromJson(orderData) : null;
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       return null;
//     }
//   }

//   /// Get single order by ID
//   Order? getOrderById(String orderId) {
//     try {
//       return _orders.firstWhere((order) => order.orderId == orderId);
//     } catch (e) {
//       return null;
//     }
//   }

//   /// Check if delivery person is assigned
//   bool hasDeliveryPersonAssigned(String orderId) {
//     final order = getOrderById(orderId);
//     return order?.deliveryPersonId != null;
//   }

//   /// Add customization to order item
//   Future<void> addCustomizationToItem({
//     required String orderId,
//     required String itemId,
//     required String customizationId,
//     required String? selectedOptionId,
//     required double additionalPrice,
//   }) async {
//     try {
//       final success = await _orderItemService.addCustomizationToItem(
//         orderId: orderId,
//         itemId: itemId,
//         customizationId: customizationId,
//         selectedOptionId: selectedOptionId,
//         additionalPrice: additionalPrice,
//       );

//       if (success) {
//         // Clear cache to force refresh
//         _orderItemsCache.remove(orderId);
//         notifyListeners();
//       }
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       rethrow;
//     }
//   }

//   /// Remove customization from order item
//   Future<void> removeCustomizationFromItem(
//       String orderId, String customizationId) async {
//     try {
//       final success =
//           await _orderItemService.removeCustomizationFromItem(orderId, customizationId);

//       if (success) {
//         // Clear cache to force refresh
//         _orderItemsCache.remove(orderId);
//         notifyListeners();
//       }
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       rethrow;
//     }
//   }

//   /// Get customization summary for display
//   Future<List<String>> getCustomizationSummary(
//       String orderId, String itemId) async {
//     try {
//       return await _orderItemService.getCustomizationSummary(orderId, itemId);
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       return [];
//     }
//   }

//   /// Refresh all orders
//   Future<void> refreshOrders() async {
//     await loadOrders();
//   }

//   /// Clear all state
//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }

//   /// Reset provider
//   void reset() {
//     _orders = [];
//     _filteredOrders = [];
//     _orderItemsCache.clear();
//     _isLoading = true;
//     _isLoadingMore = false;
//     _error = null;
//     _selectedStatus = 'All';
//     _searchQuery = '';
//     _currentPage = 0;
//     _hasMore = true;
//     _restaurantId = null;
//     _customerId = null;
//     notifyListeners();
//   }
// }