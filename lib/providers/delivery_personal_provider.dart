import 'package:flutter/foundation.dart';
import 'package:naivedhya/models/deliver_person_model.dart';
import '../services/supabase_service.dart';

class DeliveryPersonnelProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  List<DeliveryPersonnel> _deliveryPersonnel = [];
  bool _isLoading = false;
  String? _error;

  List<DeliveryPersonnel> get deliveryPersonnel => _deliveryPersonnel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get all delivery personnel
  Future<void> fetchDeliveryPersonnel() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _deliveryPersonnel = await _supabaseService.getDeliveryPersonnel();
    } catch (e) {
      _error = 'Failed to fetch delivery personnel: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new delivery personnel
  Future<bool> addDeliveryPersonnel(DeliveryPersonnel personnel) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPersonnel = await _supabaseService.createDeliveryPersonnel(personnel);
      if (newPersonnel != null) {
        _deliveryPersonnel.insert(0, newPersonnel);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to add delivery personnel: $e';
      print(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update delivery personnel
  Future<bool> updateDeliveryPersonnel(String userId, DeliveryPersonnel personnel) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedPersonnel = await _supabaseService.updateDeliveryPersonnel(userId, personnel);
      if (updatedPersonnel != null) {
        final index = _deliveryPersonnel.indexWhere((p) => p.userId == userId);
        if (index != -1) {
          _deliveryPersonnel[index] = updatedPersonnel;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update delivery personnel: $e';
      print(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete delivery personnel
  Future<bool> deleteDeliveryPersonnel(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _supabaseService.deleteDeliveryPersonnel(userId);
      if (success) {
        _deliveryPersonnel.removeWhere((p) => p.userId == userId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to delete delivery personnel: $e';
      print(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle availability
  Future<bool> toggleAvailability(String userId) async {
    final personnel = _deliveryPersonnel.firstWhere((p) => p.userId == userId);
    final updatedPersonnel = personnel.copyWith(isAvailable: !personnel.isAvailable);
    return await updateDeliveryPersonnel(userId, updatedPersonnel);
  }

  // Update location
  Future<bool> updateLocation(String userId, Map<String, dynamic> location) async {
    final personnel = _deliveryPersonnel.firstWhere((p) => p.userId == userId);
    final updatedPersonnel = personnel.copyWith(currentLocation: location);
    return await updateDeliveryPersonnel(userId, updatedPersonnel);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get personnel by ID
  DeliveryPersonnel? getPersonnelById(String userId) {
    try {
      return _deliveryPersonnel.firstWhere((p) => p.userId == userId);
    } catch (e) {
      return null;
    }
  }

  // Get available personnel
  List<DeliveryPersonnel> get availablePersonnel {
    return _deliveryPersonnel.where((p) => p.isAvailable).toList();
  }

  // Get busy personnel
  List<DeliveryPersonnel> get busyPersonnel {
    return _deliveryPersonnel.where((p) => !p.isAvailable).toList();
  }
}