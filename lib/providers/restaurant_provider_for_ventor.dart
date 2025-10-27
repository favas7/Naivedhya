import 'package:flutter/foundation.dart';
import 'package:naivedhya/models/restaurant_model.dart';
import 'package:naivedhya/services/restaurant_service.dart';


class VendorRestaurantProvider with ChangeNotifier {
  final RestaurantService _supabaseService = RestaurantService();
  
  List<Restaurant> _restaurants = [];
  Restaurant? _selectedRestaurant;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Restaurant> get restaurants => _restaurants;
  Restaurant? get selectedRestaurant => _selectedRestaurant;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load Restaurants for current user (where adminemail matches current user's email)
  Future<void> loadRestaurantsForCurrentUser() async {
    _setLoading(true);
    _clearError();
    
    try {
      _restaurants = await _supabaseService.getRestaurantsForCurrentUser();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load Restaurants: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load all Restaurants
  Future<void> loadAllRestaurants() async {
    _setLoading(true);
    _clearError();
    
    try {
      _restaurants = await _supabaseService.getRestaurants();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load Restaurants: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Create new Restaurant
  Future<bool> createRestaurant(String name, String address) async {
    _setLoading(true);
    _clearError();
    
    try {
      final Restaurant = await _supabaseService.createRestaurant(name, address);
      if (Restaurant != null) {
        _restaurants.insert(0, Restaurant); // Add to beginning of list
        notifyListeners();
        return true;
      } else {
        _setError('Failed to create Restaurant');
        return false;
      }
    } catch (e) {
      _setError('Failed to create Restaurant: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update Restaurant
  Future<bool> updateRestaurant(String restaurantId, String name, String address) async {
    _setLoading(true);
    _clearError();
    
    try {
      final updatedRestaurant = await _supabaseService.updateRestaurantBasicInfo(restaurantId, name, address);
      if (updatedRestaurant != null) {
        // Update the Restaurant in the list
        final index = _restaurants.indexWhere((h) => h.id == restaurantId);
        if (index != -1) {
          _restaurants[index] = updatedRestaurant;
          notifyListeners();
        }
        return true;
      } else {
        _setError('Failed to update Restaurant');
        return false;
      }
    } catch (e) {
      _setError('Failed to update Restaurant: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete Restaurant
  Future<bool> deleteRestaurant(String RestaurantId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _supabaseService.deleteRestaurant(RestaurantId);
      if (success) {
        _restaurants.removeWhere((h) => h.id == RestaurantId);
        if (_selectedRestaurant?.id == RestaurantId) {
          _selectedRestaurant = null;
        }
        notifyListeners();
        return true;
      } else {
        _setError('Failed to delete Restaurant');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete Restaurant: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if current user can edit Restaurant
  Future<bool> canEditRestaurant(String RestaurantId) async {
    try {
      return await _supabaseService.canEditRestaurant(RestaurantId);
    } catch (e) {
      return false;
    }
  }

  // Select a Restaurant
  void selectRestaurant(Restaurant Restaurant) {
    _selectedRestaurant = Restaurant;
    notifyListeners();
  }

  // Clear selected Restaurant
  void clearSelectedRestaurant() {
    _selectedRestaurant = null;
    notifyListeners();
  }

  // Get Restaurant by ID
  Restaurant? getRestaurantById(String RestaurantId) {
    try {
      return _restaurants.firstWhere((h) => h.id == RestaurantId);
    } catch (e) {
      return null;
    }
  }

  // Refresh Restaurants
  Future<void> refreshRestaurants() async {
    await loadRestaurantsForCurrentUser();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Clear all data (useful for logout)
  void clearData() {
    _restaurants.clear();
    _selectedRestaurant = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Get Restaurants count
  int get restaurantsCount => _restaurants.length;

  // Check if user has any Restaurants
  bool get hasRestaurants => _restaurants.isNotEmpty;

  // Get user's Restaurants summary
  Map<String, dynamic> get RestaurantsSummary {
    return {
      'total_Restaurants': _restaurants.length,
      'latest_Restaurant': _restaurants.isNotEmpty ? _restaurants.first : null,
      'has_Restaurants': _restaurants.isNotEmpty,
    };
  }
  // Add this method to your existing VendorRestaurantProvider class

// Update Restaurant location
Future<bool> updateRestaurantLocation(String restaurantId, String locationId) async {
  _setLoading(true);
  _clearError();
  
  try {
    final updatedRestaurant = await _supabaseService.updateRestaurantLocation(restaurantId, locationId);
    if (updatedRestaurant != null) {
      // Update the Restaurant in the list
      final index = _restaurants.indexWhere((h) => h.id == restaurantId);
      if (index != -1) {
        _restaurants[index] = updatedRestaurant;
        
        // Also update selected Restaurant if it's the same one
        if (_selectedRestaurant?.id == restaurantId) {
          _selectedRestaurant = updatedRestaurant;
        }
        
        notifyListeners();
      }
      return true;
    } else {
      _setError('Failed to update Restaurant location');
      return false;
    }
  } catch (e) {
    _setError('Failed to update Restaurant location: ${e.toString()}');
    return false;
  } finally {
    _setLoading(false);
  }
}
}