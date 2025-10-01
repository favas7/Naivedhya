import 'package:flutter/material.dart';
import 'package:naivedhya/models/manager.dart';
import 'package:naivedhya/services/manager_service.dart';

class ManagerProvider extends ChangeNotifier {
  final ManagerService _managerService = ManagerService();
  
  List<Manager> _managers = [];
  bool _isLoading = false;
  String? _error;

  List<Manager> get managers => _managers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadManagers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _managers = await _managerService.getAllManagers();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> addManager(Manager manager) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final managerId = await _managerService.addManager(manager);
      await loadManagers(); // Refresh the list
      return managerId;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // New method to handle both manager creation and Restaurant update
  Future<String?> addManagerAndUpdateRestaurant(Manager manager, String RestaurantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final managerId = await _managerService.addManagerAndUpdateRestaurant(manager, RestaurantId);
      await loadManagers(); // Refresh the list
      return managerId;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateManager(Manager manager) async {
    try {
      _error = null;
      await _managerService.updateManager(manager);
      await loadManagers(); // Refresh the list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteManager(String managerId) async {
    try {
      _error = null;
      await _managerService.deleteManager(managerId);
      await loadManagers(); // Refresh the list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Manager?> getManagerById(String managerId) async {
    try {
      return await _managerService.getManagerById(managerId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Manager?> getManagerByRestaurantId(String RestaurantId) async {
    try {
      return await _managerService.getManagerByrestaurantId(RestaurantId);
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