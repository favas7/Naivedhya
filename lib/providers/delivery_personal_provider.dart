import 'package:flutter/foundation.dart';
import 'package:naivedhya/models/delivery_person_model.dart';
import 'package:naivedhya/services/delivery_person_service.dart';

class DeliveryPersonnelProvider extends ChangeNotifier {
  final DeliveryPersonnelService _deliveryService = DeliveryPersonnelService();
  
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
      _deliveryPersonnel = await _deliveryService.fetchAllDeliveryPersonnel();
    } catch (e) {
      _error = 'Failed to fetch delivery personnel: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get available delivery personnel only
  Future<void> fetchAvailableDeliveryPersonnel() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _deliveryPersonnel = await _deliveryService.fetchAvailableDeliveryPersonnel();
    } catch (e) {
      _error = 'Failed to fetch available delivery personnel: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search delivery personnel
  Future<void> searchDeliveryPersonnel({
    String? searchQuery,
    bool? isAvailable,
    bool? isVerified,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _deliveryPersonnel = await _deliveryService.searchDeliveryPersonnel(
        searchQuery: searchQuery,
        isAvailable: isAvailable,
        isVerified: isVerified,
      );
    } catch (e) {
      _error = 'Failed to search delivery personnel: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle availability
  Future<bool> toggleAvailability(String userId) async {
    try {
      final personnel = _deliveryPersonnel.firstWhere((p) => p.userId == userId);
      final updatedPersonnel = await _deliveryService.updateDeliveryPersonnelAvailability(
        userId, 
        !personnel.isAvailable
      );
      
      final index = _deliveryPersonnel.indexWhere((p) => p.userId == userId);
      if (index != -1) {
        _deliveryPersonnel[index] = updatedPersonnel;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update availability: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  // Assign order to delivery personnel
  Future<bool> assignOrder(String orderId, String deliveryPersonId) async {
    try {
      final success = await _deliveryService.assignOrderToDeliveryPersonnel(
        orderId, 
        deliveryPersonId
      );
      if (success) {
        // Refresh the list to get updated assigned orders
        await fetchDeliveryPersonnel();
      }
      return success;
    } catch (e) {
      _error = 'Failed to assign order: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  // Unassign order from delivery personnel
  Future<bool> unassignOrder(String orderId, String? deliveryPersonId) async {
    try {
      final success = await _deliveryService.unassignOrderFromDeliveryPersonnel(
        orderId, 
        deliveryPersonId
      );
      if (success) {
        // Refresh the list to get updated assigned orders
        await fetchDeliveryPersonnel();
      }
      return success;
    } catch (e) {
      _error = 'Failed to unassign order: $e';
      print(_error);
      notifyListeners();
      return false;
    }
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

  // Get verified personnel
  List<DeliveryPersonnel> get verifiedPersonnel {
    return _deliveryPersonnel.where((p) => p.isVerified).toList();
  }

  // Get personnel by verification status
  List<DeliveryPersonnel> getPersonnelByVerificationStatus(String status) {
    return _deliveryPersonnel.where((p) => p.verificationStatus == status).toList();
  }

  // Stream for real-time updates
  Stream<List<DeliveryPersonnel>> getDeliveryPersonnelStream() {
    return _deliveryService.getDeliveryPersonnelStream();
  }

  // Listen to real-time updates
  void startListeningToUpdates() {
    getDeliveryPersonnelStream().listen(
      (personnel) {
        _deliveryPersonnel = personnel;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Real-time update error: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}