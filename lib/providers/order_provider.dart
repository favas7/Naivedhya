// lib/providers/order_provider.dart (Updated with createOrderWithItems method)
import 'package:flutter/material.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/models/order_item_model.dart';
import 'package:naivedhya/services/order_item_service.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  final OrderItemService _orderItemService = OrderItemService();

  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  String _selectedStatus = 'All';
  String _searchQuery = '';
  
  // Pagination
  int _currentPage = 0;
  bool _hasMore = true;

  // Getters
  List<Order> get orders => _orders;
  List<Order> get filteredOrders => _filteredOrders;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;
  bool get hasMore => _hasMore;

  final List<String> statusOptions = [
    'All',
    'Pending',
    'Confirmed',
    'Preparing',
    'Ready',
    'Out for Delivery',
    'Delivered',
    'Cancelled'
  ];

  Future<void> loadOrders({bool loadMore = false}) async {
    if (loadMore && (_isLoadingMore || !_hasMore)) return;

    if (loadMore) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      _currentPage = 0;
      _hasMore = true;
      _error = null;
    }
    notifyListeners();

    try {
      final newOrders = await _orderService.fetchOrders(
        page: loadMore ? _currentPage : 0,
      );

      if (loadMore) {
        _orders.addAll(newOrders);
        _isLoadingMore = false;
      } else {
        _orders = newOrders;
        _isLoading = false;
      }

      _hasMore = newOrders.length == OrderService.ordersPerPage;
      if (loadMore) _currentPage++;

      _applyFilters();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> searchOrders() async {
    _isLoading = true;
    _error = null;
    _currentPage = 0;
    _hasMore = true;
    notifyListeners();

    try {
      final orders = await _orderService.searchOrders(
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        statusFilter: _selectedStatus,
        page: 0,
      );

      _orders = orders;
      _isLoading = false;
      _applyFilters();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredOrders = _orders.where((order) {
      bool matchesSearch = _searchQuery.isEmpty ||
          order.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (order.customerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          order.status.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesStatus = _selectedStatus == 'All' || 
          order.status == _selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();
    
    notifyListeners();
  }

  // Original method for creating orders without items
  Future<void> createOrder(Order order) async {
    try {
      final createdOrder = await _orderService.createOrder(order);
      
      // Add the new order to the beginning of the list
      _orders.insert(0, createdOrder);
      _applyFilters();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }


  // Method to get order items for a specific order
  Future<List<OrderItem>> getOrderItems(String orderId) async {
    try {
      return await _orderItemService.getOrderItems(orderId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateOrder(Order order) async {
    try {
      final updatedOrder = await _orderService.updateOrder(order);
      
      // Update the order in the lists
      final index = _orders.indexWhere((o) => o.orderId == updatedOrder.orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
        _applyFilters();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _orderService.deleteOrder(orderId);
      
      // Remove the order from the lists
      _orders.removeWhere((order) => order.orderId == orderId);
      _applyFilters();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> assignDeliveryPersonnel(String orderId, String deliveryPersonId) async {
    try {
      final success = await _orderService.assignDeliveryPersonnel(orderId, deliveryPersonId);
      
      if (success) {
        // Update the order in the local list
        final index = _orders.indexWhere((order) => order.orderId == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].copyWith(
            deliveryPersonId: deliveryPersonId,
            deliveryStatus: 'Assigned',
            updatedAt: DateTime.now(),
          );
          _applyFilters();
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> unassignDeliveryPersonnel(String orderId) async {
    try {
      final order = _orders.firstWhere((o) => o.orderId == orderId);
      final success = await _orderService.unassignDeliveryPersonnel(
        orderId, 
        order.deliveryPersonId,
      );
      
      if (success) {
        // Update the order in the local list
        final index = _orders.indexWhere((order) => order.orderId == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].copyWith(
            deliveryPersonId: null,
            deliveryStatus: 'Pending',
            updatedAt: DateTime.now(),
          );
          _applyFilters();
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateOrderStatus(
    String orderId, 
    String status, {
    String? deliveryStatus,
    DateTime? proposedDeliveryTime,
    DateTime? pickupTime,
    DateTime? deliveryTime,
  }) async {
    try {
      final updatedOrder = await _orderService.updateOrderStatus(
        orderId,
        status,
        deliveryStatus: deliveryStatus,
        proposedDeliveryTime: proposedDeliveryTime,
        pickupTime: pickupTime,
        deliveryTime: deliveryTime,
      );
      
      // Update the order in the lists
      final index = _orders.indexWhere((o) => o.orderId == updatedOrder.orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
        _applyFilters();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refreshOrders() async {
    await loadOrders();
  }

  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.orderId == orderId);
    } catch (e) {
      return null;
    }
  }

  bool hasDeliveryPersonAssigned(String orderId) {
    final order = getOrderById(orderId);
    return order?.deliveryPersonId != null;
  }

  /// Enhanced method for creating orders with items (replaces the existing one)
Future<void> createOrderWithItems(Order order, List<OrderItem> orderItems) async {
  try {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Create the order first
    final createdOrder = await _orderService.createOrder(order);
    
    // Create order items if any
    if (orderItems.isNotEmpty) {
      // Update order items with the actual order ID from database
      final updatedOrderItems = orderItems.map((item) => 
        item.copyWith(orderId: createdOrder.orderId)
      ).toList();
      
      await _orderItemService.createOrderItems(updatedOrderItems);
    }
    
    // Add the new order to the beginning of the list
    _orders.insert(0, createdOrder);
    _applyFilters();
    
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
    rethrow;
  }
}

/// Get order items with detailed information
Future<List<OrderItem>> getOrderItemsDetailed(String orderId) async {
  try {
    return await _orderItemService.getOrderItems(orderId);
  } catch (e) {
    _error = e.toString();
    notifyListeners();
    rethrow;
  }
}

/// Calculate total for order items
Future<double> calculateOrderItemsTotal(String orderId) async {
  try {
    return await _orderItemService.calculateOrderTotal(orderId);
  } catch (e) {
    _error = e.toString();
    notifyListeners();
    return 0.0;
  }
}

/// Update order items for an existing order
Future<void> updateOrderItems(String orderId, List<OrderItem> orderItems) async {
  try {
    _isLoading = true;
    notifyListeners();

    // First delete existing order items
    await _orderItemService.deleteOrderItems(orderId);
    
    // Then create new order items
    if (orderItems.isNotEmpty) {
      final updatedOrderItems = orderItems.map((item) => 
        item.copyWith(orderId: orderId)
      ).toList();
      
      await _orderItemService.createOrderItems(updatedOrderItems);
    }

    // Recalculate order total if needed
    final newTotal = await _orderItemService.calculateOrderTotal(orderId);
    
    // Update the order in local list with new total
    final orderIndex = _orders.indexWhere((order) => order.orderId == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex] = _orders[orderIndex].copyWith(
        totalAmount: newTotal,
        updatedAt: DateTime.now(),
      );
      _applyFilters();
    }

    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
    rethrow;
  }
}

/// Delete order with its items
Future<void> deleteOrderWithItems(String orderId) async {
  try {
    // Delete order items first (due to foreign key constraint)
    await _orderItemService.deleteOrderItems(orderId);
    
    // Then delete the order
    await _orderService.deleteOrder(orderId);
    
    // Remove from local lists
    _orders.removeWhere((order) => order.orderId == orderId);
    _applyFilters();
  } catch (e) {
    _error = e.toString();
    notifyListeners();
    rethrow;
  }
}

}