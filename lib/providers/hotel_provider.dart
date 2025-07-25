import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../services/hotel_service.dart';

class HotelProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  List<Hotel> _hotels = [];
  bool _isLoading = false;
  String? _error;

  List<Hotel> get hotels => _hotels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load hotels from Supabase
  Future<void> loadHotels() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _hotels = await _supabaseService.getHotels();
      _error = null;
    } catch (e) {
      _error = 'Failed to load hotels: $e';
      _hotels = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new hotel
  Future<bool> addHotel(String name, String address) async {
    if (name.trim().isEmpty || address.trim().isEmpty) {
      _error = 'Hotel name and address cannot be empty';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final hotel = await _supabaseService.createHotel(name.trim(), address.trim());
      if (hotel != null) {
        _hotels.insert(0, hotel);
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to create hotel';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to add hotel: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update hotel basic info (name and address only)
  Future<bool> updateHotelBasicInfo(String hotelId, String name, String address) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedHotel = await _supabaseService.updateHotelBasicInfo(hotelId, name, address);
      if (updatedHotel != null) {
        final index = _hotels.indexWhere((h) => h.id == hotelId);
        if (index != -1) {
          _hotels[index] = updatedHotel;
          notifyListeners();
          return true;
        }
      }
      _error = 'Failed to update hotel';
      return false;
    } catch (e) {
      _error = 'Failed to update hotel: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete hotel
  Future<bool> deleteHotel(String hotelId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _supabaseService.deleteHotel(hotelId);
      if (success) {
        _hotels.removeWhere((h) => h.id == hotelId);
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to delete hotel';
        return false;
      }
    } catch (e) {
      _error = 'Failed to delete hotel: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update hotel with manager ID (Fixed method)
  Future<bool> updateHotelManager(String hotelId, String managerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedHotel = await _supabaseService.updateHotelManager(hotelId, managerId);
      if (updatedHotel != null) {
        final hotelIndex = _hotels.indexWhere((h) => h.id == hotelId);
        if (hotelIndex != -1) {
          _hotels[hotelIndex] = updatedHotel;
          notifyListeners();
          return true;
        }
        return true; // Hotel updated successfully but not in local list
      } else {
        _error = 'Failed to update hotel manager';
        return false;
      }
    } catch (e) {
      _error = 'Failed to update hotel manager: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update hotel with location ID
  Future<bool> updateHotelLocation(String hotelId, String locationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Find the hotel to update
      final hotelIndex = _hotels.indexWhere((h) => h.id == hotelId);
      if (hotelIndex == -1) {
        _error = 'Hotel not found';
        return false;
      }

      final currentHotel = _hotels[hotelIndex];
      final updatedHotel = currentHotel.copyWith(locationId: locationId);
      
      final success = await _supabaseService.updateHotel(hotelId, updatedHotel);
      if (success != null) {
        _hotels[hotelIndex] = updatedHotel;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to update hotel location';
        return false;
      }
    } catch (e) {
      _error = 'Failed to update hotel location: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get hotel by ID
  Hotel? getHotelById(String hotelId) {
    try {
      return _hotels.firstWhere((hotel) => hotel.id == hotelId);
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