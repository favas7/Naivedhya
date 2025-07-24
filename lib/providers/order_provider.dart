// providers/order_provider.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refreshOrders() async {
    await loadOrders();
  }
}