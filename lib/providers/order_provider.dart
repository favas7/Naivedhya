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
    ///('\n🚀 [OrderProvider] ========== INITIALIZATION ==========');
    ///('📊 [OrderProvider] Use Enriched Data: $useEnrichedData');
    
    _useEnrichedData = useEnrichedData;
    await fetchOrders(page: 0);
    
    ///('✅ [OrderProvider] ========== INITIALIZATION COMPLETE ==========\n');
  }

  /// Fetch orders with optional filter and pagination
  Future<void> fetchOrders({int page = 0}) async {
    try {
      ///('\n📥 [OrderProvider] ========== FETCH ORDERS ==========');
      ///('📄 [OrderProvider] Page: $page');
      ///('🔄 [OrderProvider] Use Enriched Data: $_useEnrichedData');
      ///('🏷️ [OrderProvider] Status Filter: $_selectedStatusFilter');
      
      _isLoading = true;
      _errorMessage = null;
      ///('⏳ [OrderProvider] Setting isLoading = true, notifying listeners...');
      notifyListeners();

      if (_useEnrichedData) {
        ///('📦 [OrderProvider] Fetching enriched data...');
        await _fetchOrdersEnriched(page);
      } else {
        ///('📦 [OrderProvider] Fetching basic data...');
        await _fetchOrdersBasic(page);
      }

      // Check if more pages are available
      final itemCount = _useEnrichedData ? _ordersWithDetails.length : _orders.length;
      _hasMorePages = itemCount > (page * 10);
      
      ///('📊 [OrderProvider] Results Summary:');
      ///('   - Total Items: $itemCount');
      ///('   - Has More Pages: $_hasMorePages');
      ///('   - Enriched Data: ${_ordersWithDetails.length} items');
      ///('   - Basic Data: ${_orders.length} items');
      
    } catch (e) {
      ///('❌ [OrderProvider] ERROR in fetchOrders: $e');
      ///('❌ [OrderProvider] Stack trace: ${StackTrace.current}');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      ///('✅ [OrderProvider] Setting isLoading = false, notifying listeners...');
      notifyListeners();
      ///('✅ [OrderProvider] ========== FETCH COMPLETE ==========\n');
    }
  }

  /// Fetch orders with enriched data (restaurant, vendor, delivery details)
  Future<void> _fetchOrdersEnriched(int page) async {
    try {
      ///('\n🎯 [OrderProvider] _fetchOrdersEnriched called');
      ///('📄 [OrderProvider] Page: $page');
      ///('🏷️ [OrderProvider] Status Filter: $_selectedStatusFilter');
      
      final newOrdersWithDetails = await _orderService.fetchOrdersWithDetails(
        page: page,
        statusFilter: _selectedStatusFilter,
      );

      ///('📦 [OrderProvider] Received ${newOrdersWithDetails.length} enriched orders from service');

      if (page == 0) {
        ///('🔄 [OrderProvider] Page 0: Replacing all orders');
        _ordersWithDetails = newOrdersWithDetails;
        _currentPage = 0;
      } else {
        ///('➕ [OrderProvider] Page $page: Adding to existing orders');
        ///('   - Before: ${_ordersWithDetails.length} orders');
        _ordersWithDetails.addAll(newOrdersWithDetails);
        ///('   - After: ${_ordersWithDetails.length} orders');
        _currentPage = page;
      }

      _hasMorePages = newOrdersWithDetails.length == 10;
      
      ///('✅ [OrderProvider] Enriched data updated successfully!');
      ///('📊 [OrderProvider] Current State:');
      ///('   - Total Orders with Details: ${_ordersWithDetails.length}');
      ///('   - Current Page: $_currentPage');
      ///('   - Has More Pages: $_hasMorePages');
      
    } catch (e) {
      ///('❌ [OrderProvider] ERROR in _fetchOrdersEnriched: $e');
      ///('❌ [OrderProvider] Stack trace: ${StackTrace.current}');
      throw Exception('Failed to fetch enriched orders: $e');
    }
  }

  /// Fetch orders with basic data only
  Future<void> _fetchOrdersBasic(int page) async {
    try {
      ///('\n🎯 [OrderProvider] _fetchOrdersBasic called');
      ///('📄 [OrderProvider] Page: $page');
      
      final newOrders = await _orderService.fetchOrders(
        page: page,
        statusFilter: _selectedStatusFilter,
      );

      ///('📦 [OrderProvider] Received ${newOrders.length} basic orders from service');

      if (page == 0) {
        ///('🔄 [OrderProvider] Page 0: Replacing all orders');
        _orders = newOrders;
        _currentPage = 0;
      } else {
        ///('➕ [OrderProvider] Page $page: Adding to existing orders');
        _orders.addAll(newOrders);
        _currentPage = page;
      }

      _hasMorePages = newOrders.length == 10;
      
      ///('✅ [OrderProvider] Basic data updated successfully!');
      ///('📊 [OrderProvider] Total Orders: ${_orders.length}');
      
    } catch (e) {
      ///('❌ [OrderProvider] ERROR in _fetchOrdersBasic: $e');
      throw Exception('Failed to fetch orders: $e');
    }
  }

  /// Load next page of orders
  Future<void> loadNextPage() async {
    ///('\n📄 [OrderProvider] loadNextPage called');
    ///('📊 [OrderProvider] Current State: Page $_currentPage, Has More: $_hasMorePages, Loading: $_isLoading');
    
    if (!_hasMorePages || _isLoading) {
      ///('⚠️ [OrderProvider] Skip loading: hasMorePages=$_hasMorePages, isLoading=$_isLoading');
      return;
    }
    
    ///('➡️ [OrderProvider] Loading page ${_currentPage + 1}');
    await fetchOrders(page: _currentPage + 1);
  }

  /// Set status filter and reload orders
  Future<void> setStatusFilter(String? status) async {
    ///('\n🏷️ [OrderProvider] setStatusFilter called: $status');
    
    if (_selectedStatusFilter == status) {
      ///('ℹ️ [OrderProvider] Filter unchanged, skipping');
      return;
    }

    ///('🔄 [OrderProvider] Changing filter from "$_selectedStatusFilter" to "$status"');
    _selectedStatusFilter = status;
    _currentPage = 0;
    _hasMorePages = true;
    
    await fetchOrders(page: 0);
  }

  /// Get single order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      ///('\n🔍 [OrderProvider] getOrderById: $orderId');
      final order = await _orderService.fetchOrderById(orderId);
      
      if (order != null) {
        ///('✅ [OrderProvider] Order found: ${order.orderNumber}');
      } else {
        ///('⚠️ [OrderProvider] Order not found');
      }
      
      return order;
    } catch (e) {
      ///('❌ [OrderProvider] ERROR in getOrderById: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Get single order with enriched details
  Future<Map<String, dynamic>?> getOrderByIdWithDetails(String orderId) async {
    try {
      ///('\n🔍 [OrderProvider] getOrderByIdWithDetails: $orderId');
      
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _selectedOrderDetails = await _orderService.fetchOrderByIdWithDetails(orderId);
      
      _isLoading = false;
      notifyListeners();
      
      if (_selectedOrderDetails != null) {
        ///('✅ [OrderProvider] Order details loaded successfully');
      } else {
        ///('⚠️ [OrderProvider] No details found for order');
      }
      
      return _selectedOrderDetails;
    } catch (e) {
      ///('❌ [OrderProvider] ERROR in getOrderByIdWithDetails: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Create new order
  Future<Order?> createOrder(Map<String, dynamic> orderData) async {
    try {
      ///('\n➕ [OrderProvider] Creating new order...');
      
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final newOrder = await _orderService.createOrder(orderData);

      // Add to beginning of list
      _orders.insert(0, newOrder);

      _isLoading = false;
      notifyListeners();
      
      ///('✅ [OrderProvider] Order created: ${newOrder.orderNumber}');
      return newOrder;
    } catch (e) {
      ///('❌ [OrderProvider] ERROR creating order: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update order
  Future<Order?> updateOrder(String orderId, Map<String, dynamic> updates) async {
    try {
      ///('\n📝 [OrderProvider] Updating order: $orderId');
      
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updatedOrder = await _orderService.updateOrder(orderId, updates);

      // Update in local list
      final index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index >= 0) {
        _orders[index] = updatedOrder;
        ///('✅ [OrderProvider] Updated order in local list at index $index');
      }

      _isLoading = false;
      notifyListeners();
      
      ///('✅ [OrderProvider] Order updated successfully');
      return updatedOrder;
    } catch (e) {
      ///('❌ [OrderProvider] ERROR updating order: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update only order status
  Future<Order?> updateOrderStatus(String orderId, String newStatus) async {
    try {
      ///('\n🔄 [OrderProvider] Updating order status: $orderId → $newStatus');
      
      final updatedOrder = await _orderService.updateOrderStatus(orderId, newStatus);

      // Update in local list
      final index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index >= 0) {
        _orders[index] = updatedOrder;
        notifyListeners();
        ///('✅ [OrderProvider] Status updated in local list');
      }

      ///('✅ [OrderProvider] Order status updated successfully');
      return updatedOrder;
    } catch (e) {
      ///('❌ [OrderProvider] ERROR updating order status: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Delete order
  Future<bool> deleteOrder(String orderId) async {
    try {
      ///('\n🗑️ [OrderProvider] Deleting order: $orderId');
      
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _orderService.deleteOrder(orderId);

      // Remove from local list
      _orders.removeWhere((o) => o.orderId == orderId);
      _ordersWithDetails.removeWhere((od) => od['order'].orderId == orderId);

      _isLoading = false;
      notifyListeners();
      
      ///('✅ [OrderProvider] Order deleted successfully');
      return true;
    } catch (e) {
      ///('❌ [OrderProvider] ERROR deleting order: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Refresh orders (reset pagination and reload)
  Future<void> refreshOrders() async {
    ///('\n🔄 [OrderProvider] Refreshing orders...');
    _currentPage = 0;
    _hasMorePages = true;
    await fetchOrders(page: 0);
  }

  /// Clear error message
  void clearError() {
    ///('🧹 [OrderProvider] Clearing error message');
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear selected order details
  void clearSelectedOrderDetails() {
    ///('🧹 [OrderProvider] Clearing selected order details');
    _selectedOrderDetails = null;
    notifyListeners();
  }
}