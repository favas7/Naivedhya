import 'package:flutter/material.dart';
import 'package:naivedhya/services/restaurant_service.dart';

class DashboardProvider extends ChangeNotifier {
  final _supabaseService = RestaurantService();
  
  // Dashboard stats
  int _totalUsers = 0;
  int _totalOrders = 0;
  int _activeRestaurants = 0;
  int _deliveryStaff = 0;
  int _totalVendors = 0;
  
  bool _isLoading = false;
  String? _error;

  // Getters
  int get totalUsers => _totalUsers;
  int get totalOrders => _totalOrders;
  int get activeRestaurants => _activeRestaurants;
  int get deliveryStaff => _deliveryStaff;
  int get totalVendors => _totalVendors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all dashboard statistics
  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch all data concurrently
      final results = await Future.wait([
        _fetchTotalUsers(),
        _fetchTotalOrders(),
        _fetchActiveRestaurants(),
        _fetchDeliveryStaff(),
        _fetchTotalVendors(),
      ]);

      _totalUsers = results[0];
      _totalOrders = results[1];
      _activeRestaurants = results[2];
      _deliveryStaff = results[3];
      _totalVendors = results[4];

    } catch (e) {
      _error = 'Failed to load dashboard data: ${e.toString()}';
      print('Dashboard error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch total users count
  Future<int> _fetchTotalUsers() async {
    try {
      final response = await _supabaseService.client
          .from('profiles')
          .select('id');
      return response.length;
    } catch (e) {
      print('Error fetching total users: $e');
      return 0;
    }
  }

  // Fetch total orders count
  Future<int> _fetchTotalOrders() async {
    try {
      final response = await _supabaseService.client
          .from('orders')
          .select('order_id');
      return response.length;
    } catch (e) {
      print('Error fetching total orders: $e');
      return 0;
    }
  }

  // Fetch active Restaurants count
  Future<int> _fetchActiveRestaurants() async {
    try {
      final response = await _supabaseService.client
          .from('restaurant')
          .select('hotel_id');
      return response.length;
    } catch (e) {
      print('Error fetching active Restaurants: $e');
      return 0;
    }
  }

  // Fetch delivery staff count
  Future<int> _fetchDeliveryStaff() async {
    try {
      final response = await _supabaseService.client
          .from('delivery_personnel')
          .select('user_id');
      return response.length;
    } catch (e) {
      print('Error fetching delivery staff: $e');
      return 0;
    }
  }

  // Fetch total vendors count
  Future<int> _fetchTotalVendors() async {
    try {
      final response = await _supabaseService.client
          .from('vendors')
          .select('vendor_id');
      return response.length;
    } catch (e) {
      print('Error fetching total vendors: $e');
      return 0;
    }
  }

  // Refresh dashboard data
  Future<void> refreshDashboard() async {
    await fetchDashboardStats();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}