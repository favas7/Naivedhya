// providers/order_provider_enhanced.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/services/order/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  // State variables
  List<Order> _orders = [];
  List<Map<String, dynamic>> _ordersWithDetails = [];
  Map<String, dynamic>? _selectedOrderDetails;
  String? _selectedStatusFilter;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMorePages = true;
  String? _errorMessage;
  bool _useEnrichedData = true; // Toggle between basic and enriched data

  // Getters
  List<Order> get orders => _orders;
  List<Map<String, dynamic>> get ordersWithDetails => _ordersWithDetails;
  Map<String, dynamic>? get selectedOrderDetails => _selectedOrderDetails;
  String? get selectedStatusFilter => _selectedStatusFilter;
  int get currentPage => _currentPage;
  bool get isLoading => _isLoading;
  bool get hasMorePages => _hasMorePages;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _orders.isEmpty && !isLoading;

  /// Initialize - fetch first page of orders with enriched data
  Future<void> initialize({bool useEnrichedData = true}) async {
    _useEnrichedData = useEnrichedData;
    await fetchOrders(page: 0);
  }

  /// Fetch orders with optional filter and pagination
  Future<void> fetchOrders({int page = 0}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (_useEnrichedData) {
        await _fetchOrdersEnriched(page);
      } else {
        await _fetchOrdersBasic(page);
      }

      // Check if more pages are available
      _hasMorePages = (_useEnrichedData ? _ordersWithDetails : _orders).length > (page * 10);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch orders with enriched data (restaurant, vendor, delivery details)
  Future<void> _fetchOrdersEnriched(int page) async {
    try {
      final newOrdersWithDetails = await _orderService.fetchOrdersWithDetails(
        page: page,
        statusFilter: _selectedStatusFilter,
      );

      if (page == 0) {
        _ordersWithDetails = newOrdersWithDetails;
        _currentPage = 0;
      } else {
        _ordersWithDetails.addAll(newOrdersWithDetails);
        _currentPage = page;
      }

      _hasMorePages = newOrdersWithDetails.length == 10;
    } catch (e) {
      throw Exception('Failed to fetch enriched orders: $e');
    }
  }

  /// Fetch orders with basic data only
  Future<void> _fetchOrdersBasic(int page) async {
    try {
      final newOrders = await _orderService.fetchOrders(
        page: page,
        statusFilter: _selectedStatusFilter,
      );

      if (page == 0) {
        _orders = newOrders;
        _currentPage = 0;
      } else {
        _orders.addAll(newOrders);
        _currentPage = page;
      }

      _hasMorePages = newOrders.length == 10;
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
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

  /// Get single order with enriched details
  Future<Map<String, dynamic>?> getOrderByIdWithDetails(String orderId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _selectedOrderDetails = await _orderService.fetchOrderByIdWithDetails(orderId);
      
      _isLoading = false;
      notifyListeners();
      return _selectedOrderDetails;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
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
      _ordersWithDetails.removeWhere((od) => od['order'].orderId == orderId);

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

  /// Clear selected order details
  void clearSelectedOrderDetails() {
    _selectedOrderDetails = null;
    notifyListeners();
  }
}