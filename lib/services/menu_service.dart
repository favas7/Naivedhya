import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:naivedhya/models/menu_model.dart';

class MenuService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all menu items for a restaurant with their customizations
  Future<List<MenuItem>> getMenuItems(String restaurantId) async {
    try {
      // First, get menu items
      final response = await _supabase
          .from('menu_items')
          .select()
          .eq('hotel_id', restaurantId)
          .order('name');

      if (response.isEmpty) {
        return [];
      }

      // Then, for each item, fetch its customizations separately
      List<MenuItem> menuItems = [];
      
      for (var itemData in response) {
        // Fetch customizations for this item
        final customizationsResponse = await _supabase
            .from('menu_item_customizations')
            .select()
            .eq('item_id', itemData['item_id'])
            .order('display_order');
        
        // For each customization, fetch its options
        List<Map<String, dynamic>> customizationsWithOptions = [];
        
        for (var customizationData in customizationsResponse) {
          final optionsResponse = await _supabase
              .from('customization_options')
              .select()
              .eq('customization_id', customizationData['customization_id'])
              .order('display_order');
          
          customizationData['options'] = optionsResponse;
          customizationsWithOptions.add(customizationData);
        }
              
        // Add customizations to the item data
        itemData['customizations'] = customizationsWithOptions;
        
        menuItems.add(MenuItem.fromJson(itemData));
      }

      return menuItems;
    } catch (e) {
      print('Error fetching menu items: $e');
      rethrow;
    }
  }

  /// Get a single menu item by ID with customizations
  Future<MenuItem?> getMenuItem(String itemId) async {
    try {
      // Get menu item
      final response = await _supabase
          .from('menu_items')
          .select()
          .eq('item_id', itemId)
          .single();

      // Fetch customizations
      final customizationsResponse = await _supabase
          .from('menu_item_customizations')
          .select()
          .eq('item_id', itemId)
          .order('display_order');
      
      // For each customization, fetch its options
      List<Map<String, dynamic>> customizationsWithOptions = [];
      
      for (var customizationData in customizationsResponse) {
        final optionsResponse = await _supabase
            .from('customization_options')
            .select()
            .eq('customization_id', customizationData['customization_id'])
            .order('display_order');
        
        customizationData['options'] = optionsResponse;
        customizationsWithOptions.add(customizationData);
      }
          
      response['customizations'] = customizationsWithOptions;
      
      return MenuItem.fromJson(response);
    } catch (e) {
      print('Error fetching menu item: $e');
      return null;
    }
  }

  /// Create a new menu item with customizations
  Future<bool> createMenuItem(MenuItem menuItem) async {
    try {
      // 1. First, insert the menu item WITHOUT customizations
      final itemData = menuItem.toJson();
      itemData.remove('customizations');
      itemData.remove('created_at');
      itemData.remove('updated_at');
      
      final response = await _supabase
          .from('menu_items')
          .insert(itemData)
          .select()
          .single();

      final String newItemId = response['item_id'];

      // 2. Then, insert customizations separately if any exist
      if (menuItem.customizations.isNotEmpty) {
        for (int i = 0; i < menuItem.customizations.length; i++) {
          final customization = menuItem.customizations[i];
          
          // Insert customization
          final customizationData = {
            'item_id': newItemId,
            'name': customization.name,
            'type': customization.type,
            'base_price': customization.basePrice,
            'is_required': customization.isRequired,
            'display_order': i,
          };
          
          final customizationResponse = await _supabase
              .from('menu_item_customizations')
              .insert(customizationData)
              .select()
              .single();
          
          final String customizationId = customizationResponse['customization_id'];
          
          // Insert options for this customization
          if (customization.options.isNotEmpty) {
            final optionsData = customization.options.asMap().entries.map((entry) {
              return {
                'customization_id': customizationId,
                'name': entry.value.name,
                'additional_price': entry.value.additionalPrice,
                'display_order': entry.key,
              };
            }).toList();
            
            await _supabase
                .from('customization_options')
                .insert(optionsData);
          }
        }
      }

      return true;
    } catch (e) {
      print('Error creating menu item: $e');
      return false;
    }
  }

  /// Update an existing menu item
  Future<bool> updateMenuItem(MenuItem menuItem) async {
    if (menuItem.itemId == null) return false;

    try {
      // 1. Update the menu item WITHOUT customizations
      final itemData = {
        'name': menuItem.name,
        'description': menuItem.description,
        'price': menuItem.price,
        'is_available': menuItem.isAvailable,
        'category': menuItem.category,
        'stock_quantity': menuItem.stockQuantity,
        'low_stock_threshold': menuItem.lowStockThreshold,
      };
      
      await _supabase
          .from('menu_items')
          .update(itemData)
          .eq('item_id', menuItem.itemId!);

      // 2. Delete old customizations (CASCADE will delete options too)
      await _supabase
          .from('menu_item_customizations')
          .delete()
          .eq('item_id', menuItem.itemId!);

      // 3. Insert new customizations (same as create method)
      if (menuItem.customizations.isNotEmpty) {
        for (int i = 0; i < menuItem.customizations.length; i++) {
          final customization = menuItem.customizations[i];
          
          final customizationData = {
            'item_id': menuItem.itemId!,
            'name': customization.name,
            'type': customization.type,
            'base_price': customization.basePrice,
            'is_required': customization.isRequired,
            'display_order': i,
          };
          
          final customizationResponse = await _supabase
              .from('menu_item_customizations')
              .insert(customizationData)
              .select()
              .single();
          
          final String customizationId = customizationResponse['customization_id'];
          
          if (customization.options.isNotEmpty) {
            final optionsData = customization.options.asMap().entries.map((entry) {
              return {
                'customization_id': customizationId,
                'name': entry.value.name,
                'additional_price': entry.value.additionalPrice,
                'display_order': entry.key,
              };
            }).toList();
            
            await _supabase
                .from('customization_options')
                .insert(optionsData);
          }
        }
      }

      return true;
    } catch (e) {
      print('Error updating menu item: $e');
      return false;
    }
  }

  /// Delete a menu item (CASCADE will delete customizations and options)
  Future<bool> deleteMenuItem(String itemId) async {
    try {
      await _supabase
          .from('menu_items')
          .delete()
          .eq('item_id', itemId);
      return true;
    } catch (e) {
      print('Error deleting menu item: $e');
      return false;
    }
  }

  /// Update menu item availability
  Future<bool> updateMenuItemAvailability(String itemId, bool isAvailable) async {
    try {
      await _supabase
          .from('menu_items')
          .update({'is_available': isAvailable})
          .eq('item_id', itemId);
      return true;
    } catch (e) {
      print('Error updating availability: $e');
      return false;
    }
  }

  /// Update stock quantity
  Future<bool> updateStockQuantity(String itemId, int quantity) async {
    try {
      await _supabase
          .from('menu_items')
          .update({'stock_quantity': quantity})
          .eq('item_id', itemId);
      return true;
    } catch (e) {
      print('Error updating stock: $e');
      return false;
    }
  }

  /// Get all unique categories for a restaurant
  Future<List<String?>> getMenuCategories(String restaurantId) async {
    try {
      final response = await _supabase
          .from('menu_items')
          .select('category')
          .eq('hotel_id', restaurantId)
          .not('category', 'is', null);

      if (response.isEmpty) {
        return [];
      }

      // Extract unique categories
      final categories = response
          .map((item) => item['category'] as String?)
          .where((category) => category != null && category.isNotEmpty)
          .toSet()
          .toList();

      categories.sort();
      return categories;
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  /// Get low stock items
  Future<List<MenuItem>> getLowStockItems(String restaurantId) async {
    try {
      final items = await getMenuItems(restaurantId);
      return items.where((item) => item.isLowStock).toList();
    } catch (e) {
      print('Error fetching low stock items: $e');
      return [];
    }
  }

  /// Get out of stock items
  Future<List<MenuItem>> getOutOfStockItems(String restaurantId) async {
    try {
      final items = await getMenuItems(restaurantId);
      return items.where((item) => !item.isInStock).toList();
    } catch (e) {
      print('Error fetching out of stock items: $e');
      return [];
    }
  }

  /// Bulk update availability
/// Bulk update availability
Future<bool> bulkUpdateAvailability(List<String> itemIds, bool isAvailable) async {
  try {
    await _supabase
        .from('menu_items')
        .update({'is_available': isAvailable})
        .inFilter('item_id', itemIds);
    return true;
  } catch (e) {
    print('Error bulk updating availability: $e');
    return false;
  }
}

  /// Search menu items
  Future<List<MenuItem>> searchMenuItems(String restaurantId, String query) async {
    try {
      final items = await getMenuItems(restaurantId);
      
      if (query.isEmpty) {
        return items;
      }

      final lowerQuery = query.toLowerCase();
      return items.where((item) {
        return item.name.toLowerCase().contains(lowerQuery) ||
               (item.description?.toLowerCase().contains(lowerQuery) ?? false) ||
               (item.category?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } catch (e) {
      print('Error searching menu items: $e');
      return [];
    }
  }

  
/// Get total count of menu items for a restaurant
Future<int> getMenuItemCount(String restaurantId) async {
  try {
    final response = await _supabase
        .from('menu_items')
        .select('item_id')
        .eq('hotel_id', restaurantId);

    return response.length;
  } catch (e) {
    print('Error fetching menu item count: $e');
    return 0;
  }
}

/// Get count of available menu items for a restaurant
Future<int> getAvailableMenuItemCount(String restaurantId) async {
  try {
    final response = await _supabase
        .from('menu_items')
        .select('item_id', )
        .eq('hotel_id', restaurantId)
        .eq('is_available', true);

    return response.length;
  } catch (e) {
    print('Error fetching available menu item count: $e');
    return 0;
  }
}
}