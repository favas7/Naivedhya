import 'package:flutter/foundation.dart';
import '../models/hotel.dart';
import '../services/hotel_service.dart';

class VendorHotelProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  List<Hotel> _hotels = [];
  Hotel? _selectedHotel;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Hotel> get hotels => _hotels;
  Hotel? get selectedHotel => _selectedHotel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load hotels for current user (where adminemail matches current user's email)
  Future<void> loadHotelsForCurrentUser() async {
    _setLoading(true);
    _clearError();
    
    try {
      _hotels = await _supabaseService.getHotelsForCurrentUser();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load hotels: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load all hotels
  Future<void> loadAllHotels() async {
    _setLoading(true);
    _clearError();
    
    try {
      _hotels = await _supabaseService.getHotels();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load hotels: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Create new hotel
  Future<bool> createHotel(String name, String address) async {
    _setLoading(true);
    _clearError();
    
    try {
      final hotel = await _supabaseService.createHotel(name, address);
      if (hotel != null) {
        _hotels.insert(0, hotel); // Add to beginning of list
        notifyListeners();
        return true;
      } else {
        _setError('Failed to create hotel');
        return false;
      }
    } catch (e) {
      _setError('Failed to create hotel: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update hotel
  Future<bool> updateHotel(String hotelId, String name, String address) async {
    _setLoading(true);
    _clearError();
    
    try {
      final updatedHotel = await _supabaseService.updateHotelBasicInfo(hotelId, name, address);
      if (updatedHotel != null) {
        // Update the hotel in the list
        final index = _hotels.indexWhere((h) => h.id == hotelId);
        if (index != -1) {
          _hotels[index] = updatedHotel;
          notifyListeners();
        }
        return true;
      } else {
        _setError('Failed to update hotel');
        return false;
      }
    } catch (e) {
      _setError('Failed to update hotel: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete hotel
  Future<bool> deleteHotel(String hotelId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _supabaseService.deleteHotel(hotelId);
      if (success) {
        _hotels.removeWhere((h) => h.id == hotelId);
        if (_selectedHotel?.id == hotelId) {
          _selectedHotel = null;
        }
        notifyListeners();
        return true;
      } else {
        _setError('Failed to delete hotel');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete hotel: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if current user can edit hotel
  Future<bool> canEditHotel(String hotelId) async {
    try {
      return await _supabaseService.canEditHotel(hotelId);
    } catch (e) {
      return false;
    }
  }

  // Select a hotel
  void selectHotel(Hotel hotel) {
    _selectedHotel = hotel;
    notifyListeners();
  }

  // Clear selected hotel
  void clearSelectedHotel() {
    _selectedHotel = null;
    notifyListeners();
  }

  // Get hotel by ID
  Hotel? getHotelById(String hotelId) {
    try {
      return _hotels.firstWhere((h) => h.id == hotelId);
    } catch (e) {
      return null;
    }
  }

  // Refresh hotels
  Future<void> refreshHotels() async {
    await loadHotelsForCurrentUser();
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
    _hotels.clear();
    _selectedHotel = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Get hotels count
  int get hotelsCount => _hotels.length;

  // Check if user has any hotels
  bool get hasHotels => _hotels.isNotEmpty;

  // Get user's hotels summary
  Map<String, dynamic> get hotelsSummary {
    return {
      'total_hotels': _hotels.length,
      'latest_hotel': _hotels.isNotEmpty ? _hotels.first : null,
      'has_hotels': _hotels.isNotEmpty,
    };
  }
  // Add this method to your existing VendorHotelProvider class

// Update hotel location
Future<bool> updateHotelLocation(String hotelId, String locationId) async {
  _setLoading(true);
  _clearError();
  
  try {
    final updatedHotel = await _supabaseService.updateHotelLocation(hotelId, locationId);
    if (updatedHotel != null) {
      // Update the hotel in the list
      final index = _hotels.indexWhere((h) => h.id == hotelId);
      if (index != -1) {
        _hotels[index] = updatedHotel;
        
        // Also update selected hotel if it's the same one
        if (_selectedHotel?.id == hotelId) {
          _selectedHotel = updatedHotel;
        }
        
        notifyListeners();
      }
      return true;
    } else {
      _setError('Failed to update hotel location');
      return false;
    }
  } catch (e) {
    _setError('Failed to update hotel location: ${e.toString()}');
    return false;
  } finally {
    _setLoading(false);
  }
}
}