// lib/services/menu_service.dart
// ignore_for_file: avoid_print

import 'package:naivedhya/models/menu_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuService {
  final SupabaseClient _client = Supabase.instance.client;

  // ============================================================================
  // EXISTING METHODS (Keep all your current functionality)
  // ============================================================================

  // Create a new menu item
  Future<MenuItem?> createMenuItem(MenuItem menuItem) async {
    try {
      final response = await _client
          .from('menu_items')
          .insert(menuItem.toJson())
          .select()
          .single();

      return MenuItem.fromJson(response);
    } catch (e) {
      print('Error creating menu item: $e');
      return null;
    }
  }

  // Get all menu items for a specific Restaurant (compatibility method)
  Future<List<MenuItem>> getMenuItemsByRestaurant(String restaurantId) async {
    return getAvailableMenuItems(restaurantId);
  }

  // Get all menu items for a specific Restaurant
  Future<List<MenuItem>> getMenuItems(String restaurantId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select()
          .eq('hotel_id', restaurantId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => MenuItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting menu items: $e');
      return [];
    }
  }

  // Get menu items by category for a Restaurant
  Future<List<MenuItem>> getMenuItemsByCategory(
      String restaurantId, String category) async {
    try {
      final response = await _client
          .from('menu_items')
          .select()
          .eq('hotel_id', restaurantId)
          .eq('category', category)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => MenuItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting menu items by category: $e');
      return [];
    }
  }

  // Get available menu items for a Restaurant
  Future<List<MenuItem>> getAvailableMenuItems(String restaurantId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select()
          .eq('hotel_id', restaurantId)
          .eq('is_available', true)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => MenuItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting available menu items: $e');
      return [];
    }
  }

  // Get menu item by ID
  Future<MenuItem?> getMenuItemById(String itemId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select()
          .eq('item_id', itemId)
          .maybeSingle();

      if (response != null) {
        return MenuItem.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting menu item by ID: $e');
      return null;
    }
  }

  // Search menu items by name or description
  Future<List<MenuItem>> searchMenuItems(
      String restaurantId, String query) async {
    try {
      final response = await _client
          .from('menu_items')
          .select()
          .eq('hotel_id', restaurantId)
          .eq('is_available', true)
          .ilike('name', '%$query%')
          .order('name', ascending: true);

      return (response as List)
          .map((json) => MenuItem.fromJson(json))
          .toList();
    } catch (e) {
      try {
        // Fallback: search by name OR description
        final response = await _client
            .from('menu_items')
            .select()
            .eq('hotel_id', restaurantId)
            .eq('is_available', true)
            .or('name.ilike.%$query%,description.ilike.%$query%')
            .order('name', ascending: true);

        return (response as List)
            .map((json) => MenuItem.fromJson(json))
            .toList();
      } catch (e2) {
        print('Error searching menu items: $e2');
        return [];
      }
    }
  }

  // Update menu item
  Future<MenuItem?> updateMenuItem(String itemId, MenuItem menuItem) async {
    try {
      final updateData = menuItem.toJson();
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('menu_items')
          .update(updateData)
          .eq('item_id', itemId)
          .select()
          .single();

      return MenuItem.fromJson(response);
    } catch (e) {
      print('Error updating menu item: $e');
      return null;
    }
  }

  // Delete menu item
  Future<bool> deleteMenuItem(String itemId) async {
    try {
      await _client.from('menu_items').delete().eq('item_id', itemId);
      return true;
    } catch (e) {
      print('Error deleting menu item: $e');
      return false;
    }
  }

  // Update menu item availability
  Future<bool> updateMenuItemAvailability(
      String itemId, bool isAvailable) async {
    try {
      await _client
          .from('menu_items')
          .update({
            'is_available': isAvailable,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('item_id', itemId);
      return true;
    } catch (e) {
      print('Error updating menu item availability: $e');
      return false;
    }
  }

  // Get menu item count for a Restaurant
  Future<int> getMenuItemCount(String restaurantId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select('item_id')
          .eq('hotel_id', restaurantId);

      return (response as List).length;
    } catch (e) {
      print('Error getting menu item count: $e');
      return 0;
    }
  }

  // Get available menu item count for a Restaurant
  Future<int> getAvailableMenuItemCount(String restaurantId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select('item_id')
          .eq('hotel_id', restaurantId)
          .eq('is_available', true);

      return (response as List).length;
    } catch (e) {
      print('Error getting available menu item count: $e');
      return 0;
    }
  }

  // Get distinct categories for a Restaurant
  Future<List<String>> getMenuCategories(String restaurantId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select('category')
          .eq('hotel_id', restaurantId)
          .not('category', 'is', null);

      final categories = (response as List)
          .map((item) => item['category'] as String)
          .toSet() // Remove duplicates
          .toList();

      categories.sort(); // Sort alphabetically
      return categories;
    } catch (e) {
      print('Error getting menu categories: $e');
      return [];
    }
  }

  // Bulk update menu item availability
  Future<bool> bulkUpdateAvailability(
      List<String> itemIds, bool isAvailable) async {
    try {
      await _client
          .from('menu_items')
          .update({
            'is_available': isAvailable,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .inFilter('item_id', itemIds);
      return true;
    } catch (e) {
      print('Error bulk updating menu item availability: $e');
      return false;
    }
  }

  // Get menu statistics for a Restaurant
  Future<Map<String, dynamic>> getMenuStatistics(String restaurantId) async {
    try {
      final allItems = await getMenuItems(restaurantId);
      final availableItems =
          allItems.where((item) => item.isAvailable).toList();
      final categories = await getMenuCategories(restaurantId);

      double averagePrice = 0.0;
      if (allItems.isNotEmpty) {
        averagePrice = allItems
                .map((item) => item.price)
                .reduce((a, b) => a + b) /
            allItems.length;
      }

      return {
        'totalItems': allItems.length,
        'availableItems': availableItems.length,
        'unavailableItems': allItems.length - availableItems.length,
        'totalCategories': categories.length,
        'averagePrice': averagePrice,
        'categories': categories,
      };
    } catch (e) {
      print('Error getting menu statistics: $e');
      return {
        'totalItems': 0,
        'availableItems': 0,
        'unavailableItems': 0,
        'totalCategories': 0,
        'averagePrice': 0.0,
        'categories': <String>[],
      };
    }
  }

  // ============================================================================
  // NEW METHODS - CUSTOMIZATION & INVENTORY SUPPORT
  // ============================================================================

  /// Get menu items WITH customizations and inventory
  Future<List<MenuItem>> getAvailableMenuItemsWithCustomizations(
      String restaurantId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select()
          .eq('hotel_id', restaurantId)
          .eq('is_available', true)
          .order('name', ascending: true);

      List<MenuItem> menuItems = [];

      for (final itemData in response) {
        final itemId = itemData['item_id'];
        final customizations = await _getCustomizationsForItem(itemId);

        menuItems.add(
          MenuItem.fromJson({
            ...itemData,
            'customizations': customizations,
          }),
        );
      }

      return menuItems;
    } catch (e) {
      print('Error fetching menu items with customizations: $e');
      return [];
    }
  }

  /// Get customizations for a specific menu item
  Future<List<Map<String, dynamic>>> _getCustomizationsForItem(
      String itemId) async {
    try {
      final customizationsResponse = await _client
          .from('menu_item_customizations')
          .select()
          .eq('item_id', itemId)
          .order('display_order', ascending: true);

      List<Map<String, dynamic>> customizations = [];

      for (final customData in customizationsResponse) {
        final customizationId = customData['customization_id'];

        // Fetch options for this customization
        final optionsResponse = await _client
            .from('customization_options')
            .select()
            .eq('customization_id', customizationId)
            .order('display_order', ascending: true);

        customizations.add({
          ...customData,
          'options': optionsResponse,
        });
      }

      return customizations;
    } catch (e) {
      print('Error fetching customizations: $e');
      return [];
    }
  }

  /// Get single menu item with full customization details
  Future<MenuItem?> getMenuItemWithCustomizations(String itemId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select()
          .eq('item_id', itemId)
          .single();

      final customizations = await _getCustomizationsForItem(itemId);

      return MenuItem.fromJson({
        ...response,
        'customizations': customizations,
      });
    } catch (e) {
      print('Error fetching menu item with customizations: $e');
      return null;
    }
  }

  /// Update item stock after order
  Future<bool> updateItemStock(String itemId, int quantityOrdered) async {
    try {
      // Get current stock
      final item = await _client
          .from('menu_items')
          .select('stock_quantity')
          .eq('item_id', itemId)
          .single();

      final currentStock = item['stock_quantity'] as int;
      final newStock =
          (currentStock - quantityOrdered).clamp(0, double.infinity).toInt();

      // Update stock
      await _client
          .from('menu_items')
          .update({'stock_quantity': newStock})
          .eq('item_id', itemId);

      return true;
    } catch (e) {
      print('Error updating stock: $e');
      return false;
    }
  }

  /// Check if item is in stock
  Future<bool> isItemInStock(String itemId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select('stock_quantity, is_available')
          .eq('item_id', itemId)
          .single();

      final stockQuantity = response['stock_quantity'] as int;
      final isAvailable = response['is_available'] as bool;

      return isAvailable && stockQuantity > 0;
    } catch (e) {
      print('Error checking stock: $e');
      return false;
    }
  }

  /// Get items by category with stock info
  Future<Map<String, List<MenuItem>>> getMenuItemsByCategoryWithStock(
      String restaurantId) async {
    try {
      final items = await getAvailableMenuItemsWithCustomizations(restaurantId);

      Map<String, List<MenuItem>> itemsByCategory = {};
      for (final item in items) {
        final category = item.category ?? 'Uncategorized';
        if (!itemsByCategory.containsKey(category)) {
          itemsByCategory[category] = [];
        }
        itemsByCategory[category]!.add(item);
      }

      return itemsByCategory;
    } catch (e) {
      print('Error grouping items by category: $e');
      return {};
    }
  }

  /// Get low stock items for a restaurant
  Future<List<MenuItem>> getLowStockItems(String restaurantId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select()
          .eq('hotel_id', restaurantId)
          .lte('stock_quantity', 5)
          .gt('stock_quantity', 0);

      List<MenuItem> menuItems = [];

      for (final itemData in response) {
        final itemId = itemData['item_id'];
        final customizations = await _getCustomizationsForItem(itemId);

        menuItems.add(
          MenuItem.fromJson({
            ...itemData,
            'customizations': customizations,
          }),
        );
      }

      return menuItems;
    } catch (e) {
      print('Error fetching low stock items: $e');
      return [];
    }
  }

  /// Get out of stock items
  Future<List<MenuItem>> getOutOfStockItems(String restaurantId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select()
          .eq('hotel_id', restaurantId)
          .eq('stock_quantity', 0);

      List<MenuItem> menuItems = [];

      for (final itemData in response) {
        final itemId = itemData['item_id'];
        final customizations = await _getCustomizationsForItem(itemId);

        menuItems.add(
          MenuItem.fromJson({
            ...itemData,
            'customizations': customizations,
          }),
        );
      }

      return menuItems;
    } catch (e) {
      print('Error fetching out of stock items: $e');
      return [];
    }
  }

  /// Bulk update stock for multiple items
  Future<bool> bulkUpdateStock(
      Map<String, int> itemQuantityMap) async {
    try {
      for (final entry in itemQuantityMap.entries) {
        await updateItemStock(entry.key, entry.value);
      }
      return true;
    } catch (e) {
      print('Error bulk updating stock: $e');
      return false;
    }
  }

  /// Get inventory statistics
  Future<Map<String, dynamic>> getInventoryStatistics(
      String restaurantId) async {
    try {
      final allItems = await getMenuItems(restaurantId);

      int inStock = 0;
      int lowStock = 0;
      int outOfStock = 0;
      int totalQuantity = 0;

      for (final item in allItems) {
        if (item.stockQuantity > 0 && item.stockQuantity <= item.lowStockThreshold) {
          lowStock++;
        } else if (item.stockQuantity <= 0) {
          outOfStock++;
        } else {
          inStock++;
        }
        totalQuantity += item.stockQuantity;
      }

      return {
        'inStock': inStock,
        'lowStock': lowStock,
        'outOfStock': outOfStock,
        'totalItems': allItems.length,
        'totalQuantity': totalQuantity,
      };
    } catch (e) {
      print('Error getting inventory statistics: $e');
      return {
        'inStock': 0,
        'lowStock': 0,
        'outOfStock': 0,
        'totalItems': 0,
        'totalQuantity': 0,
      };
    }
  }

  /// Update stock threshold for item
  Future<bool> updateStockThreshold(
      String itemId, int newThreshold) async {
    try {
      await _client
          .from('menu_items')
          .update({
            'low_stock_threshold': newThreshold,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('item_id', itemId);

      return true;
    } catch (e) {
      print('Error updating stock threshold: $e');
      return false;
    }
  }
}