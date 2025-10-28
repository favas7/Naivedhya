// providers/order_provider_enhanced.dart - WITH DEBUG LOGGING
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
  bool _useEnrichedData = true;

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
    print('\n🚀 [OrderProvider] ========== INITIALIZATION ==========');
    print('📊 [OrderProvider] Use Enriched Data: $useEnrichedData');
    
    _useEnrichedData = useEnrichedData;
    await fetchOrders(page: 0);
    
    print('✅ [OrderProvider] ========== INITIALIZATION COMPLETE ==========\n');
  }

  /// Fetch orders with optional filter and pagination
  Future<void> fetchOrders({int page = 0}) async {
    try {
      print('\n📥 [OrderProvider] ========== FETCH ORDERS ==========');
      print('📄 [OrderProvider] Page: $page');
      print('🔄 [OrderProvider] Use Enriched Data: $_useEnrichedData');
      print('🏷️ [OrderProvider] Status Filter: $_selectedStatusFilter');
      
      _isLoading = true;
      _errorMessage = null;
      print('⏳ [OrderProvider] Setting isLoading = true, notifying listeners...');
      notifyListeners();

      if (_useEnrichedData) {
        print('📦 [OrderProvider] Fetching enriched data...');
        await _fetchOrdersEnriched(page);
      } else {
        print('📦 [OrderProvider] Fetching basic data...');
        await _fetchOrdersBasic(page);
      }

      // Check if more pages are available
      final itemCount = _useEnrichedData ? _ordersWithDetails.length : _orders.length;
      _hasMorePages = itemCount > (page * 10);
      
      print('📊 [OrderProvider] Results Summary:');
      print('   - Total Items: $itemCount');
      print('   - Has More Pages: $_hasMorePages');
      print('   - Enriched Data: ${_ordersWithDetails.length} items');
      print('   - Basic Data: ${_orders.length} items');
      
    } catch (e) {
      print('❌ [OrderProvider] ERROR in fetchOrders: $e');
      print('❌ [OrderProvider] Stack trace: ${StackTrace.current}');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      print('✅ [OrderProvider] Setting isLoading = false, notifying listeners...');
      notifyListeners();
      print('✅ [OrderProvider] ========== FETCH COMPLETE ==========\n');
    }
  }

  /// Fetch orders with enriched data (restaurant, vendor, delivery details)
  Future<void> _fetchOrdersEnriched(int page) async {
    try {
      print('\n🎯 [OrderProvider] _fetchOrdersEnriched called');
      print('📄 [OrderProvider] Page: $page');
      print('🏷️ [OrderProvider] Status Filter: $_selectedStatusFilter');
      
      final newOrdersWithDetails = await _orderService.fetchOrdersWithDetails(
        page: page,
        statusFilter: _selectedStatusFilter,
      );

      print('📦 [OrderProvider] Received ${newOrdersWithDetails.length} enriched orders from service');

      if (page == 0) {
        print('🔄 [OrderProvider] Page 0: Replacing all orders');
        _ordersWithDetails = newOrdersWithDetails;
        _currentPage = 0;
      } else {
        print('➕ [OrderProvider] Page $page: Adding to existing orders');
        print('   - Before: ${_ordersWithDetails.length} orders');
        _ordersWithDetails.addAll(newOrdersWithDetails);
        print('   - After: ${_ordersWithDetails.length} orders');
        _currentPage = page;
      }

      _hasMorePages = newOrdersWithDetails.length == 10;
      
      print('✅ [OrderProvider] Enriched data updated successfully!');
      print('📊 [OrderProvider] Current State:');
      print('   - Total Orders with Details: ${_ordersWithDetails.length}');
      print('   - Current Page: $_currentPage');
      print('   - Has More Pages: $_hasMorePages');
      
    } catch (e) {
      print('❌ [OrderProvider] ERROR in _fetchOrdersEnriched: $e');
      print('❌ [OrderProvider] Stack trace: ${StackTrace.current}');
      throw Exception('Failed to fetch enriched orders: $e');
    }
  }

  /// Fetch orders with basic data only
  Future<void> _fetchOrdersBasic(int page) async {
    try {
      print('\n🎯 [OrderProvider] _fetchOrdersBasic called');
      print('📄 [OrderProvider] Page: $page');
      
      final newOrders = await _orderService.fetchOrders(
        page: page,
        statusFilter: _selectedStatusFilter,
      );

      print('📦 [OrderProvider] Received ${newOrders.length} basic orders from service');

      if (page == 0) {
        print('🔄 [OrderProvider] Page 0: Replacing all orders');
        _orders = newOrders;
        _currentPage = 0;
      } else {
        print('➕ [OrderProvider] Page $page: Adding to existing orders');
        _orders.addAll(newOrders);
        _currentPage = page;
      }

      _hasMorePages = newOrders.length == 10;
      
      print('✅ [OrderProvider] Basic data updated successfully!');
      print('📊 [OrderProvider] Total Orders: ${_orders.length}');
      
    } catch (e) {
      print('❌ [OrderProvider] ERROR in _fetchOrdersBasic: $e');
      throw Exception('Failed to fetch orders: $e');
    }
  }

  /// Load next page of orders
  Future<void> loadNextPage() async {
    print('\n📄 [OrderProvider] loadNextPage called');
    print('📊 [OrderProvider] Current State: Page $_currentPage, Has More: $_hasMorePages, Loading: $_isLoading');
    
    if (!_hasMorePages || _isLoading) {
      print('⚠️ [OrderProvider] Skip loading: hasMorePages=$_hasMorePages, isLoading=$_isLoading');
      return;
    }
    
    print('➡️ [OrderProvider] Loading page ${_currentPage + 1}');
    await fetchOrders(page: _currentPage + 1);
  }

  /// Set status filter and reload orders
  Future<void> setStatusFilter(String? status) async {
    print('\n🏷️ [OrderProvider] setStatusFilter called: $status');
    
    if (_selectedStatusFilter == status) {
      print('ℹ️ [OrderProvider] Filter unchanged, skipping');
      return;
    }

    print('🔄 [OrderProvider] Changing filter from "$_selectedStatusFilter" to "$status"');
    _selectedStatusFilter = status;
    _currentPage = 0;
    _hasMorePages = true;
    
    await fetchOrders(page: 0);
  }

  /// Get single order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      print('\n🔍 [OrderProvider] getOrderById: $orderId');
      final order = await _orderService.fetchOrderById(orderId);
      
      if (order != null) {
        print('✅ [OrderProvider] Order found: ${order.orderNumber}');
      } else {
        print('⚠️ [OrderProvider] Order not found');
      }
      
      return order;
    } catch (e) {
      print('❌ [OrderProvider] ERROR in getOrderById: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Get single order with enriched details
  Future<Map<String, dynamic>?> getOrderByIdWithDetails(String orderId) async {
    try {
      print('\n🔍 [OrderProvider] getOrderByIdWithDetails: $orderId');
      
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _selectedOrderDetails = await _orderService.fetchOrderByIdWithDetails(orderId);
      
      _isLoading = false;
      notifyListeners();
      
      if (_selectedOrderDetails != null) {
        print('✅ [OrderProvider] Order details loaded successfully');
      } else {
        print('⚠️ [OrderProvider] No details found for order');
      }
      
      return _selectedOrderDetails;
    } catch (e) {
      print('❌ [OrderProvider] ERROR in getOrderByIdWithDetails: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Create new order
  Future<Order?> createOrder(Map<String, dynamic> orderData) async {
    try {
      print('\n➕ [OrderProvider] Creating new order...');
      
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final newOrder = await _orderService.createOrder(orderData);

      // Add to beginning of list
      _orders.insert(0, newOrder);

      _isLoading = false;
      notifyListeners();
      
      print('✅ [OrderProvider] Order created: ${newOrder.orderNumber}');
      return newOrder;
    } catch (e) {
      print('❌ [OrderProvider] ERROR creating order: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update order
  Future<Order?> updateOrder(String orderId, Map<String, dynamic> updates) async {
    try {
      print('\n📝 [OrderProvider] Updating order: $orderId');
      
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updatedOrder = await _orderService.updateOrder(orderId, updates);

      // Update in local list
      final index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index >= 0) {
        _orders[index] = updatedOrder;
        print('✅ [OrderProvider] Updated order in local list at index $index');
      }

      _isLoading = false;
      notifyListeners();
      
      print('✅ [OrderProvider] Order updated successfully');
      return updatedOrder;
    } catch (e) {
      print('❌ [OrderProvider] ERROR updating order: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update only order status
  Future<Order?> updateOrderStatus(String orderId, String newStatus) async {
    try {
      print('\n🔄 [OrderProvider] Updating order status: $orderId → $newStatus');
      
      final updatedOrder = await _orderService.updateOrderStatus(orderId, newStatus);

      // Update in local list
      final index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index >= 0) {
        _orders[index] = updatedOrder;
        notifyListeners();
        print('✅ [OrderProvider] Status updated in local list');
      }

      print('✅ [OrderProvider] Order status updated successfully');
      return updatedOrder;
    } catch (e) {
      print('❌ [OrderProvider] ERROR updating order status: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Delete order
  Future<bool> deleteOrder(String orderId) async {
    try {
      print('\n🗑️ [OrderProvider] Deleting order: $orderId');
      
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _orderService.deleteOrder(orderId);

      // Remove from local list
      _orders.removeWhere((o) => o.orderId == orderId);
      _ordersWithDetails.removeWhere((od) => od['order'].orderId == orderId);

      _isLoading = false;
      notifyListeners();
      
      print('✅ [OrderProvider] Order deleted successfully');
      return true;
    } catch (e) {
      print('❌ [OrderProvider] ERROR deleting order: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Refresh orders (reset pagination and reload)
  Future<void> refreshOrders() async {
    print('\n🔄 [OrderProvider] Refreshing orders...');
    _currentPage = 0;
    _hasMorePages = true;
    await fetchOrders(page: 0);
  }

  /// Clear error message
  void clearError() {
    print('🧹 [OrderProvider] Clearing error message');
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear selected order details
  void clearSelectedOrderDetails() {
    print('🧹 [OrderProvider] Clearing selected order details');
    _selectedOrderDetails = null;
    notifyListeners();
  }
}