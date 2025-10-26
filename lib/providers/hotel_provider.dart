import 'package:flutter/material.dart';
import 'package:naivedhya/models/restaurant_model.dart';
import 'package:naivedhya/services/restaurant_service.dart';


class RestaurantProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  String? _error;

  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load Restaurants from Supabase
  Future<void> loadRestaurants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _restaurants = await _supabaseService.getRestaurants();
      _error = null;
    } catch (e) {
      _error = 'Failed to load Restaurants: $e';
      _restaurants = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new Restaurant
  Future<bool> addRestaurant(String name, String address) async {
    if (name.trim().isEmpty || address.trim().isEmpty) {
      _error = 'Restaurant name and address cannot be empty';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final restaurant = await _supabaseService.createRestaurant(name.trim(), address.trim());
      _restaurants.insert(0, restaurant!);
      _error = null;
      notifyListeners();
      return true;
        } catch (e) {
      _error = 'Failed to add Restaurant: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update Restaurant basic info (name and address only)
  Future<bool> updateRestaurantBasicInfo(String restaurantId, String name, String address) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedRestaurant = await _supabaseService.updateRestaurantBasicInfo(restaurantId, name, address);
      if (updatedRestaurant != null) {
        final index = _restaurants.indexWhere((h) => h.id == restaurantId);
        if (index != -1) {
          _restaurants[index] = updatedRestaurant;
          notifyListeners();
          return true;
        }
      }
      _error = 'Failed to update Restaurant';
      return false;
    } catch (e) {
      _error = 'Failed to update Restaurant: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete Restaurant
  Future<bool> deleteRestaurant(String restaurantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _supabaseService.deleteRestaurant(restaurantId);
      if (success) {
        _restaurants.removeWhere((h) => h.id == restaurantId);
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to delete Restaurant';
        return false;
      }
    } catch (e) {
      _error = 'Failed to delete Restaurant: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update Restaurant with manager ID (Fixed method)
  Future<bool> updateRestaurantManager(String restaurantId, String managerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedRestaurant = await _supabaseService.updateRestaurantManager(restaurantId, managerId);
      if (updatedRestaurant != null) {
        final restaurantIndex = _restaurants.indexWhere((h) => h.id == restaurantId);
        if (restaurantIndex != -1) {
          _restaurants[restaurantIndex] = updatedRestaurant;
          notifyListeners();
          return true;
        }
        return true; // Restaurant updated successfully but not in local list
      } else {
        _error = 'Failed to update Restaurant manager';
        return false;
      }
    } catch (e) {
      _error = 'Failed to update Restaurant manager: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// Update Restaurant with location ID
Future<bool> updateRestaurantLocation(String restaurantId, String locationId) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final updatedRestaurant = await _supabaseService.updateRestaurantLocation(restaurantId, locationId);
    if (updatedRestaurant != null) {
      final restaurantIndex = _restaurants.indexWhere((h) => h.id == restaurantId);
      if (restaurantIndex != -1) {
        _restaurants[restaurantIndex] = updatedRestaurant;
        notifyListeners();
        return true;
      }
      return true; // Restaurant updated successfully but not in local list
    } else {
      _error = 'Failed to update Restaurant location';
      return false;
    }
  } catch (e) {
    _error = 'Failed to update Restaurant location: $e';
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  // Get Restaurant by ID
  Restaurant? getRestaurantById(String restaurantId) {
    try {
      return _restaurants.firstWhere((restaurant) => restaurant.id == restaurantId);
    } catch (e) {
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
}