// providers/order_provider.dart (Updated)
import 'package:flutter/material.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/services/delivery_person_service.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  // ignore: unused_field
  final DeliveryPersonnelService _deliveryService = DeliveryPersonnelService();

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

  // New method for assigning delivery personnel
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

  // New method for unassigning delivery personnel
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

  // New method for updating order status with delivery tracking
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

  // Helper method to get order by ID
  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.orderId == orderId);
    } catch (e) {
      return null;
    }
  }

  // Helper method to check if order has delivery person assigned
  bool hasDeliveryPersonAssigned(String orderId) {
    final order = getOrderById(orderId);
    return order?.deliveryPersonId != null;
  }
}