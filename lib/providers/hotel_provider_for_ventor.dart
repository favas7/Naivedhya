import 'package:flutter/foundation.dart';
import 'package:naivedhya/models/hotel.dart';
import 'package:naivedhya/services/hotel_service.dart';


class VendorRestaurantProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  List<Restaurant> _Restaurants = [];
  Restaurant? _selectedRestaurant;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Restaurant> get Restaurants => _Restaurants;
  Restaurant? get selectedRestaurant => _selectedRestaurant;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load Restaurants for current user (where adminemail matches current user's email)
  Future<void> loadRestaurantsForCurrentUser() async {
    _setLoading(true);
    _clearError();
    
    try {
      _Restaurants = await _supabaseService.getRestaurantsForCurrentUser();
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
      _Restaurants = await _supabaseService.getRestaurants();
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
        _Restaurants.insert(0, Restaurant); // Add to beginning of list
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
  Future<bool> updateRestaurant(String RestaurantId, String name, String address) async {
    _setLoading(true);
    _clearError();
    
    try {
      final updatedRestaurant = await _supabaseService.updateRestaurantBasicInfo(RestaurantId, name, address);
      if (updatedRestaurant != null) {
        // Update the Restaurant in the list
        final index = _Restaurants.indexWhere((h) => h.id == RestaurantId);
        if (index != -1) {
          _Restaurants[index] = updatedRestaurant;
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
        _Restaurants.removeWhere((h) => h.id == RestaurantId);
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
      return _Restaurants.firstWhere((h) => h.id == RestaurantId);
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
    _Restaurants.clear();
    _selectedRestaurant = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Get Restaurants count
  int get RestaurantsCount => _Restaurants.length;

  // Check if user has any Restaurants
  bool get hasRestaurants => _Restaurants.isNotEmpty;

  // Get user's Restaurants summary
  Map<String, dynamic> get RestaurantsSummary {
    return {
      'total_Restaurants': _Restaurants.length,
      'latest_Restaurant': _Restaurants.isNotEmpty ? _Restaurants.first : null,
      'has_Restaurants': _Restaurants.isNotEmpty,
    };
  }
  // Add this method to your existing VendorRestaurantProvider class

// Update Restaurant location
Future<bool> updateRestaurantLocation(String RestaurantId, String locationId) async {
  _setLoading(true);
  _clearError();
  
  try {
    final updatedRestaurant = await _supabaseService.updateRestaurantLocation(RestaurantId, locationId);
    if (updatedRestaurant != null) {
      // Update the Restaurant in the list
      final index = _Restaurants.indexWhere((h) => h.id == RestaurantId);
      if (index != -1) {
        _Restaurants[index] = updatedRestaurant;
        
        // Also update selected Restaurant if it's the same one
        if (_selectedRestaurant?.id == RestaurantId) {
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