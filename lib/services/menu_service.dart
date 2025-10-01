// ignore_for_file: avoid_print

import 'package:naivedhya/models/menu_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuService {
  final SupabaseClient _client = Supabase.instance.client;

  // Create a new menu item
  // Future<MenuItem?> createMenuItem(MenuItem menuItem) async {
  //   try {
  //     final response = await _client
  //         .from('menu_items')
  //         .insert(menuItem.toJson())
  //         .select()
  //         .single();

  //     return MenuItem.fromJson(response);
  //   } catch (e) {
  //     print('Error creating menu item: $e');
  //     return null;
  //   }
  // }

  // Get all menu items for a specific hotel
  // Future<List<MenuItem>> getMenuItems(String hotelId) async {
  //   try {
  //     final response = await _client
  //         .from('menu_items')
  //         .select()
  //         .eq('hotel_id', hotelId)
  //         .order('created_at', ascending: false);

  //     return (response as List)
  //         .map((json) => MenuItem.fromJson(json))
  //         .toList();
  //   } catch (e) {
  //     print('Error getting menu items: $e');
  //     return [];
  //   }
  // }

  // // Get menu items by category for a hotel
  // Future<List<MenuItem>> getMenuItemsByCategory(String hotelId, String category) async {
  //   try {
  //     final response = await _client
  //         .from('menu_items')
  //         .select()
  //         .eq('hotel_id', hotelId)
  //         .eq('category', category)
  //         .order('name', ascending: true);

  //     return (response as List)
  //         .map((json) => MenuItem.fromJson(json))
  //         .toList();
  //   } catch (e) {
  //     print('Error getting menu items by category: $e');
  //     return [];
  //   }
  // }

  // // Get available menu items for a hotel
  // Future<List<MenuItem>> getAvailableMenuItems(String hotelId) async {
  //   try {
  //     final response = await _client
  //         .from('menu_items')
  //         .select()
  //         .eq('hotel_id', hotelId)
  //         .eq('is_available', true)
  //         .order('category', ascending: true);

  //     return (response as List)
  //         .map((json) => MenuItem.fromJson(json))
  //         .toList();
  //   } catch (e) {
  //     print('Error getting available menu items: $e');
  //     return [];
  //   }
  // }

  // // Get menu item by ID
  // Future<MenuItem?> getMenuItemById(String itemId) async {
  //   try {
  //     final response = await _client
  //         .from('menu_items')
  //         .select()
  //         .eq('item_id', itemId)
  //         .maybeSingle();

  //     if (response != null) {
  //       return MenuItem.fromJson(response);
  //     }
  //     return null;
  //   } catch (e) {
  //     print('Error getting menu item by ID: $e');
  //     return null;
  //   }
  // }

  // // Update menu item
  // Future<MenuItem?> updateMenuItem(String itemId, MenuItem menuItem) async {
  //   try {
  //     final updateData = menuItem.toJson();
  //     updateData['updated_at'] = DateTime.now().toIso8601String();
      
  //     final response = await _client
  //         .from('menu_items')
  //         .update(updateData)
  //         .eq('item_id', itemId)
  //         .select()
  //         .single();

  //     return MenuItem.fromJson(response);
  //   } catch (e) {
  //     print('Error updating menu item: $e');
  //     return null;
  //   }
  // }

  // // Delete menu item
  // Future<bool> deleteMenuItem(String itemId) async {
  //   try {
  //     await _client
  //         .from('menu_items')
  //         .delete()
  //         .eq('item_id', itemId);
  //     return true;
  //   } catch (e) {
  //     print('Error deleting menu item: $e');
  //     return false;
  //   }
  // }

  // // Update menu item availability
  // Future<bool> updateMenuItemAvailability(String itemId, bool isAvailable) async {
  //   try {
  //     await _client
  //         .from('menu_items')
  //         .update({
  //           'is_available': isAvailable,
  //           'updated_at': DateTime.now().toIso8601String(),
  //         })
  //         .eq('item_id', itemId);
  //     return true;
  //   } catch (e) {
  //     print('Error updating menu item availability: $e');
  //     return false;
  //   }
  // }

  // // Get menu item count for a hotel
  // Future<int> getMenuItemCount(String hotelId) async {
  //   try {
  //     final response = await _client
  //         .from('menu_items')
  //         .select('item_id')
  //         .eq('hotel_id', hotelId);
      
  //     return (response as List).length;
  //   } catch (e) {
  //     print('Error getting menu item count: $e');
  //     return 0;
  //   }
  // }

  // // Get available menu item count for a hotel
  // Future<int> getAvailableMenuItemCount(String hotelId) async {
  //   try {
  //     final response = await _client
  //         .from('menu_items')
  //         .select('item_id')
  //         .eq('hotel_id', hotelId)
  //         .eq('is_available', true);
      
  //     return (response as List).length;
  //   } catch (e) {
  //     print('Error getting available menu item count: $e');
  //     return 0;
  //   }
  // }

  // // Get distinct categories for a hotel
  // Future<List<String>> getMenuCategories(String hotelId) async {
  //   try {
  //     final response = await _client
  //         .from('menu_items')
  //         .select('category')
  //         .eq('hotel_id', hotelId)
  //         .not('category', 'is', null);

  //     final categories = (response as List)
  //         .map((item) => item['category'] as String)
  //         .toSet() // Remove duplicates
  //         .toList();
      
  //     categories.sort(); // Sort alphabetically
  //     return categories;
  //   } catch (e) {
  //     print('Error getting menu categories: $e');
  //     return [];
  //   }
  // }

  // // Search menu items by name or description
  // Future<List<MenuItem>> searchMenuItems(String hotelId, String searchTerm) async {
  //   try {
  //     final response = await _client
  //         .from('menu_items')
  //         .select()
  //         .eq('hotel_id', hotelId)
  //         .or('name.ilike.%$searchTerm%,description.ilike.%$searchTerm%')
  //         .order('name', ascending: true);

  //     return (response as List)
  //         .map((json) => MenuItem.fromJson(json))
  //         .toList();
  //   } catch (e) {
  //     print('Error searching menu items: $e');
  //     return [];
  //   }
  // }

  // // Bulk update menu item availability
  // Future<bool> bulkUpdateAvailability(List<String> itemIds, bool isAvailable) async {
  //   try {
  //       await _client
  //           .from('menu_items')
  //           .update({
  //             'is_available': isAvailable,
  //             'updated_at': DateTime.now().toIso8601String(),
  //           })
  //           .inFilter('item_id', itemIds); // Use inFilter instead of in_
  //     return true;
  //   } catch (e) {
  //     print('Error bulk updating menu item availability: $e');
  //     return false;
  //   }
  // }

  // // Get menu statistics for a hotel
  // Future<Map<String, dynamic>> getMenuStatistics(String hotelId) async {
  //   try {
  //     final allItems = await getMenuItems(hotelId);
  //     final availableItems = allItems.where((item) => item.isAvailable).toList();
  //     final categories = await getMenuCategories(hotelId);
      
  //     double averagePrice = 0.0;
  //     if (allItems.isNotEmpty) {
  //       averagePrice = allItems.map((item) => item.price).reduce((a, b) => a + b) / allItems.length;
  //     }

  //     return {
  //       'totalItems': allItems.length,
  //       'availableItems': availableItems.length,
  //       'unavailableItems': allItems.length - availableItems.length,
  //       'totalCategories': categories.length,
  //       'averagePrice': averagePrice,
  //       'categories': categories,
  //     };
  //   } catch (e) {
  //     print('Error getting menu statistics: $e');
  //     return {
  //       'totalItems': 0,
  //       'availableItems': 0,
  //       'unavailableItems': 0,
  //       'totalCategories': 0,
  //       'averagePrice': 0.0,
  //       'categories': <String>[],
  //     };
  //   }
  // }


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

  // Get all menu items for a specific hotel (compatibility method)
  Future<List<MenuItem>> getMenuItemsByHotel(String hotelId) async {
    return getAvailableMenuItems(hotelId);
  }

  // Get all menu items for a specific hotel
  Future<List<MenuItem>> getMenuItems(String hotelId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select()
          .eq('hotel_id', hotelId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => MenuItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting menu items: $e');
      return [];
    }
  }

  // Get menu items by category for a hotel
  Future<List<MenuItem>> getMenuItemsByCategory(String hotelId, String category) async {
    try {
      final response = await _client
          .from('menu_items')
          .select()
          .eq('hotel_id', hotelId)
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

  // Get available menu items for a hotel
  Future<List<MenuItem>> getAvailableMenuItems(String hotelId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select()
          .eq('hotel_id', hotelId)
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

  // Search menu items by name or description (compatibility method)
  Future<List<MenuItem>> searchMenuItems(String hotelId, String query) async {
    try {
      final response = await _client
          .from('menu_items')
          .select()
          .eq('hotel_id', hotelId)
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
            .eq('hotel_id', hotelId)
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
      await _client
          .from('menu_items')
          .delete()
          .eq('item_id', itemId);
      return true;
    } catch (e) {
      print('Error deleting menu item: $e');
      return false;
    }
  }

  // Update menu item availability
  Future<bool> updateMenuItemAvailability(String itemId, bool isAvailable) async {
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

  // Get menu item count for a hotel
  Future<int> getMenuItemCount(String hotelId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select('item_id')
          .eq('hotel_id', hotelId);
      
      return (response as List).length;
    } catch (e) {
      print('Error getting menu item count: $e');
      return 0;
    }
  }

  // Get available menu item count for a hotel
  Future<int> getAvailableMenuItemCount(String hotelId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select('item_id')
          .eq('hotel_id', hotelId)
          .eq('is_available', true);
      
      return (response as List).length;
    } catch (e) {
      print('Error getting available menu item count: $e');
      return 0;
    }
  }

  // Get distinct categories for a hotel
  Future<List<String>> getMenuCategories(String hotelId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select('category')
          .eq('hotel_id', hotelId)
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
  Future<bool> bulkUpdateAvailability(List<String> itemIds, bool isAvailable) async {
    try {
        await _client
            .from('menu_items')
            .update({
              'is_available': isAvailable,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .inFilter('item_id', itemIds); // Use inFilter instead of in_
      return true;
    } catch (e) {
      print('Error bulk updating menu item availability: $e');
      return false;
    }
  }

  // Get menu statistics for a hotel
  Future<Map<String, dynamic>> getMenuStatistics(String hotelId) async {
    try {
      final allItems = await getMenuItems(hotelId);
      final availableItems = allItems.where((item) => item.isAvailable).toList();
      final categories = await getMenuCategories(hotelId);
      
      double averagePrice = 0.0;
      if (allItems.isNotEmpty) {
        averagePrice = allItems.map((item) => item.price).reduce((a, b) => a + b) / allItems.length;
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

}