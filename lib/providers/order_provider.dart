import 'package:flutter/material.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/services/order/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  // State variables
  List<Order> _orders = [];
  String? _selectedStatusFilter;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMorePages = true;
  String? _errorMessage;

  // Getters
  List<Order> get orders => _orders;
  String? get selectedStatusFilter => _selectedStatusFilter;
  int get currentPage => _currentPage;
  bool get isLoading => _isLoading;
  bool get hasMorePages => _hasMorePages;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _orders.isEmpty && !isLoading;

  /// Initialize - fetch first page of orders
  Future<void> initialize() async {
    await fetchOrders(page: 0);
  }

  /// Fetch orders with optional filter and pagination
  Future<void> fetchOrders({int page = 0}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final newOrders = await _orderService.fetchOrders(
        page: page,
        statusFilter: _selectedStatusFilter,
      );

      if (page == 0) {
        // Replace list for first page
        _orders = newOrders;
        _currentPage = 0;
      } else {
        // Append for subsequent pages
        _orders.addAll(newOrders);
        _currentPage = page;
      }

      // Check if more pages are available
      _hasMorePages = newOrders.length == 10;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load next page of orders
  Future<void> loadNextPage() async {
    if (!_hasMorePages || _isLoading) return;
    await fetchOrders(page: _currentPage + 1);
  }

  /// Set status filter and reload orders
  Future<void> setStatusFilter(String? status) async {
    if (_selectedStatusFilter == status) return;

    _selectedStatusFilter = status;
    _currentPage = 0;
    _hasMorePages = true;
    await fetchOrders(page: 0);
  }

  /// Get single order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final order = await _orderService.fetchOrderById(orderId);
      return order;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Create new order
  Future<Order?> createOrder(Map<String, dynamic> orderData) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final newOrder = await _orderService.createOrder(orderData);

      // Add to beginning of list
      _orders.insert(0, newOrder);

      _isLoading = false;
      notifyListeners();
      return newOrder;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update order
  Future<Order?> updateOrder(String orderId, Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updatedOrder = await _orderService.updateOrder(orderId, updates);

      // Update in local list
      final index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index >= 0) {
        _orders[index] = updatedOrder;
      }

      _isLoading = false;
      notifyListeners();
      return updatedOrder;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update only order status
  Future<Order?> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final updatedOrder = await _orderService.updateOrderStatus(orderId, newStatus);

      // Update in local list
      final index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index >= 0) {
        _orders[index] = updatedOrder;
        notifyListeners();
      }

      return updatedOrder;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Delete order
  Future<bool> deleteOrder(String orderId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _orderService.deleteOrder(orderId);

      // Remove from local list
      _orders.removeWhere((o) => o.orderId == orderId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Refresh orders (reset pagination and reload)
  Future<void> refreshOrders() async {
    _currentPage = 0;
    _hasMorePages = true;
    await fetchOrders(page: 0);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}