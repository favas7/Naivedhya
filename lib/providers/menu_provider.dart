import 'package:flutter/material.dart';
import 'package:naivedhya/models/menu_model.dart';
import 'package:naivedhya/services/menu_service.dart';

class MenuProvider extends ChangeNotifier {
  final MenuService _menuService = MenuService();

  // State
  List<MenuItem> _menuItems = [];
  List<MenuCategory> _categories = [];
  MenuSyncLog? _lastSyncLog;
  Map<String, int> _stats = {};
  
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;
  String? _searchQuery;
  String? _selectedCategory;

  // Getters
  List<MenuItem> get menuItems => _filteredMenuItems;
  List<MenuCategory> get categories => _categories;
  MenuSyncLog? get lastSyncLog => _lastSyncLog;
  Map<String, int> get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get error => _error;
  String? get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  MenuService get menuService => _menuService;  // ← ADD THIS LINE


  // Filtered menu items based on search and category
  List<MenuItem> get _filteredMenuItems {
    var items = _menuItems;

    // Filter by category
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      items = items.where((item) => item.categoryName == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toLowerCase();
      items = items.where((item) {
        return item.itemName.toLowerCase().contains(query) ||
               (item.description?.toLowerCase().contains(query) ?? false) ||
               (item.categoryName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return items;
  }

  /// Initialize - load menu data
  Future<void> initialize(String hotelId) async {
    print('🚀 [MenuProvider] Initializing...');
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        fetchMenuItems(hotelId),
        fetchCategories(hotelId),
        fetchLastSyncLog(hotelId),
        fetchStats(hotelId),
      ]);

      print('✅ [MenuProvider] Initialization complete');
    } catch (e) {
      print('❌ [MenuProvider] Initialization error: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch menu items
  Future<void> fetchMenuItems(String hotelId) async {
    try {
      print('🔍 [MenuProvider] Fetching menu items...');
      
      _menuItems = await _menuService.getMenuItems(hotelId);
      
      print('✅ [MenuProvider] Fetched ${_menuItems.length} items');
      notifyListeners();
    } catch (e) {
      print('❌ [MenuProvider] Error fetching menu items: $e');
      throw Exception('Failed to fetch menu items');
    }
  }

  /// Fetch categories
  Future<void> fetchCategories(String hotelId) async {
    try {
      print('🔍 [MenuProvider] Fetching categories...');
      
      _categories = await _menuService.getCategories(hotelId);
      
      print('✅ [MenuProvider] Fetched ${_categories.length} categories');
    } catch (e) {
      print('❌ [MenuProvider] Error fetching categories: $e');
    }
  }

  /// Fetch last sync log
  Future<void> fetchLastSyncLog(String hotelId) async {
    try {
      print('🔍 [MenuProvider] Fetching last sync log...');
      
      _lastSyncLog = await _menuService.getLastSyncLog(hotelId);
      
      if (_lastSyncLog != null) {
        print('✅ [MenuProvider] Last sync: ${_lastSyncLog!.syncedAt}');
      }
    } catch (e) {
      print('❌ [MenuProvider] Error fetching sync log: $e');
    }
  }

  /// Fetch menu statistics
  Future<void> fetchStats(String hotelId) async {
    try {
      print('🔍 [MenuProvider] Fetching stats...');
      
      _stats = await _menuService.getMenuStats(hotelId);
      
      print('✅ [MenuProvider] Stats: $_stats');
    } catch (e) {
      print('❌ [MenuProvider] Error fetching stats: $e');
    }
  }

  /// Sync menu from Petpooja
  Future<bool> syncMenuFromPetpooja(String hotelId) async {
    print('🔄 [MenuProvider] Starting menu sync...');
    
    _isSyncing = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _menuService.syncMenuFromPetpooja(hotelId);

      if (result['success'] == true) {
        print('✅ [MenuProvider] Sync successful!');
        print('   - Items synced: ${result['itemsSynced']}');
        print('   - Categories synced: ${result['categoriesSynced']}');
        print('   - Duration: ${result['duration']}ms');

        // Refresh all data
        await initialize(hotelId);
        
        return true;
      } else {
        print('❌ [MenuProvider] Sync failed: ${result['error']}');
        _error = result['error'] ?? 'Sync failed';
        return false;
      }
    } catch (e) {
      print('❌ [MenuProvider] Sync error: $e');
      _error = e.toString();
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Toggle item availability
  Future<bool> toggleItemAvailability(String itemId, bool isAvailable) async {
    try {
      print('🔄 [MenuProvider] Toggling availability: $itemId');
      
      final success = await _menuService.toggleItemAvailability(itemId, isAvailable);

      if (success) {
        // Update local state
        final index = _menuItems.indexWhere((item) => item.itemId == itemId);
        if (index >= 0) {
          _menuItems[index] = _menuItems[index].copyWith(isAvailable: isAvailable);
          notifyListeners();
        }
        
        print('✅ [MenuProvider] Availability updated');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ [MenuProvider] Error toggling availability: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Create custom menu item
  Future<MenuItem?> createMenuItem(Map<String, dynamic> itemData) async {
    try {
      print('➕ [MenuProvider] Creating menu item...');
      
      final newItem = await _menuService.createMenuItem(itemData);

      if (newItem != null) {
        _menuItems.insert(0, newItem);
        notifyListeners();
        
        print('✅ [MenuProvider] Menu item created');
        return newItem;
      }
      
      return null;
    } catch (e) {
      print('❌ [MenuProvider] Error creating menu item: $e');
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Update menu item
  Future<bool> updateMenuItem(String itemId, Map<String, dynamic> updates) async {
    try {
      print('📝 [MenuProvider] Updating menu item: $itemId');
      
      final success = await _menuService.updateMenuItem(itemId, updates);

      if (success) {
        // Refresh item in list
        final updatedItem = await _menuService.getMenuItem(itemId);
        if (updatedItem != null) {
          final index = _menuItems.indexWhere((item) => item.itemId == itemId);
          if (index >= 0) {
            _menuItems[index] = updatedItem;
            notifyListeners();
          }
        }
        
        print('✅ [MenuProvider] Menu item updated');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ [MenuProvider] Error updating menu item: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete menu item
  Future<bool> deleteMenuItem(String itemId) async {
    try {
      print('🗑️ [MenuProvider] Deleting menu item: $itemId');
      
      final success = await _menuService.deleteMenuItem(itemId);

      if (success) {
        _menuItems.removeWhere((item) => item.itemId == itemId);
        notifyListeners();
        
        print('✅ [MenuProvider] Menu item deleted');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ [MenuProvider] Error deleting menu item: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Set search query
  void setSearchQuery(String? query) {
    print('🔍 [MenuProvider] Search query: $query');
    _searchQuery = query;
    notifyListeners();
  }

  /// Set selected category filter
  void setSelectedCategory(String? category) {
    print('🏷️ [MenuProvider] Selected category: $category');
    _selectedCategory = category;
    notifyListeners();
  }

  /// Clear filters
  void clearFilters() {
    print('🧹 [MenuProvider] Clearing filters');
    _searchQuery = null;
    _selectedCategory = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh(String hotelId) async {
    print('🔄 [MenuProvider] Refreshing...');
    await initialize(hotelId);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get category names for dropdown
  List<String> get categoryNames {
    return _menuItems
        .where((item) => item.categoryName != null)
        .map((item) => item.categoryName!)
        .toSet()
        .toList()
      ..sort();
  }
}