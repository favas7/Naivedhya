import 'package:flutter/material.dart';
import 'package:naivedhya/models/location.dart';
import 'package:naivedhya/services/location_service.dart';
import 'package:naivedhya/services/hotel_service.dart'; // Import your SupabaseService

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final SupabaseService _supabaseService = SupabaseService(); // Add this
  
  List<Location> _locations = [];
  bool _isLoading = false;
  String? _error;

  List<Location> get locations => _locations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadLocations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _locations = await _locationService.getAllLocations();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Updated addLocation method to also update hotel table
  Future<String?> addLocation(Location location) async {
    try {
      _error = null;
      final locationId = await _locationService.addLocation(location);
      
      // Update hotel table with the new location_id
      if (location.hotelid != null) {
        final updatedHotel = await _supabaseService.updateHotelLocation(
          location.hotelid!, 
          locationId!
        );
        
        if (updatedHotel == null) {
          // Log warning but don't fail the entire operation
          print('Warning: Location created but hotel update failed');
        }
      }
      
      await loadLocations(); // Refresh the list
      return locationId;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> updateLocation(Location location) async {
    try {
      _error = null;
      await _locationService.updateLocation(location);
      await loadLocations(); // Refresh the list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteLocation(String locationId) async {
    try {
      _error = null;
      await _locationService.deleteLocation(locationId);
      await loadLocations(); // Refresh the list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Location?> getLocationById(String locationId) async {
    try {
      return await _locationService.getLocationById(locationId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Location?> getLocationByHotelId(String hotelId) async {
    try {
      return await _locationService.getLocationByHotelId(hotelId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}