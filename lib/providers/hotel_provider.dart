import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../services/supabase_service.dart';

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

  // Update hotel
  Future<bool> updateHotel(String id, Hotel hotel) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedHotel = await _supabaseService.updateHotel(id, hotel);
      if (updatedHotel != null) {
        final index = _hotels.indexWhere((h) => h.id == id);
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
  Future<bool> deleteHotel(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _supabaseService.deleteHotel(id);
      if (success) {
        _hotels.removeWhere((h) => h.id == id);
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

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}