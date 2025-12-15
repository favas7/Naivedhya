import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:naivedhya/models/menu_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuService {
  final SupabaseClient _supabase = Supabase.instance.client;

    // Get from environment variables
    String get _petpoojaApiUrl => dotenv.env['PETPOOJA_API_URL'] ?? '';
    String get _restaurantId => dotenv.env['PETPOOJA_RESTAURANT_ID'] ?? '324347';
    // ignore: unused_element
    String get _apiToken => dotenv.env['PETPOOJA_API_TOKEN'] ?? '';
  
  /// Sync menu from Petpooja
  Future<Map<String, dynamic>> syncMenuFromPetpooja(String hotelId) async {
    final startTime = DateTime.now();
    int itemsSynced = 0;
    int categoriesSynced = 0;
    String status = 'success';
    String? errorMessage;

    try {
      print('🔄 [MenuService] Starting menu sync from Petpooja...');
      
      // Step 1: Fetch menu from Petpooja API
      final menuData = await _fetchMenuFromPetpooja();
      
      if (menuData == null) {
        throw Exception('Failed to fetch menu from Petpooja');
      }

      print('✅ [MenuService] Menu data received from Petpooja');
      
      // Step 2: Sync categories
      if (menuData['categories'] != null) {
        categoriesSynced = await _syncCategories(
          hotelId, 
          menuData['categories'] as List,
        );
        print('✅ [MenuService] Synced $categoriesSynced categories');
      }

      // Step 3: Sync menu items
      if (menuData['items'] != null) {
        itemsSynced = await _syncMenuItems(
          hotelId,
          menuData['items'] as List,
        );
        print('✅ [MenuService] Synced $itemsSynced items');
      }

    } catch (e) {
      print('❌ [MenuService] Error syncing menu: $e');
      status = 'failed';
      errorMessage = e.toString();
    }

    // Log sync result
    final duration = DateTime.now().difference(startTime).inMilliseconds;
    await _logMenuSync(
      hotelId: hotelId,
      status: status,
      itemsSynced: itemsSynced,
      categoriesSynced: categoriesSynced,
      errorMessage: errorMessage,
      durationMs: duration,
    );

    return {
      'success': status == 'success',
      'itemsSynced': itemsSynced,
      'categoriesSynced': categoriesSynced,
      'duration': duration,
      'error': errorMessage,
    };
  }

  /// Fetch menu from Petpooja API
  Future<Map<String, dynamic>?> _fetchMenuFromPetpooja() async {
    try {
      print('📡 [MenuService] Calling Petpooja Push Menu API...');
      
      final response = await http.post(
        Uri.parse(_petpoojaApiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'restaurantid': _restaurantId,
          // Add any other required parameters from Petpooja
        }),
      );

      print('📡 [MenuService] API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == '1') {
          print('✅ [MenuService] Successfully fetched menu from Petpooja');
          return data;
        } else {
          print('❌ [MenuService] Petpooja API returned success=0');
          return null;
        }
      } else {
        print('❌ [MenuService] HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ [MenuService] Exception fetching from Petpooja: $e');
      return null;
    }
  }

  /// Sync categories to database
  Future<int> _syncCategories(String hotelId, List categories) async {
    int synced = 0;

    try {
      for (var category in categories) {
        final categoryData = {
          'hotel_id': hotelId,
          'petpooja_category_id': category['categoryid'].toString(),
          'category_name': category['categoryname'],
          'category_rank': int.tryParse(category['categoryrank']?.toString() ?? '0') ?? 0,
          'parent_category_id': category['parent_category_id']?.toString(),
          'is_active': category['active'] == '1',
          'updated_at': DateTime.now().toIso8601String(),
        };

        // Upsert (insert or update)
        await _supabase
            .from('menu_categories')
            .upsert(categoryData, onConflict: 'hotel_id,petpooja_category_id');

        synced++;
      }
    } catch (e) {
      print('❌ [MenuService] Error syncing categories: $e');
    }

    return synced;
  }

  /// Sync menu items to database
  Future<int> _syncMenuItems(String hotelId, List items) async {
    int synced = 0;

    try {
      for (var item in items) {
        // Get item info
        final itemInfo = item['item_info'] as Map<String, dynamic>?;
        
        final itemData = {
          'hotel_id': hotelId,
          'petpooja_item_id': item['itemid'].toString(),
          'item_name': item['itemname'],
          'item_code': item['itemid'].toString(),
          'category_name': await _getCategoryName(hotelId, item['item_categoryid'].toString()),
          'description': item['itemdescription'] ?? '',
          'price': double.tryParse(item['price']?.toString() ?? '0') ?? 0.0,
          'image_url': item['item_image_url']?.toString().isNotEmpty == true 
              ? item['item_image_url'] 
              : null,
          'is_available': item['active'] == '1',
          'in_stock': int.tryParse(item['in_stock']?.toString() ?? '2') ?? 2,
          'item_attribute': _getAttributeName(item['item_attributeid']?.toString()),
          'spice_level': itemInfo?['spice_level']?.toString(),
          'is_from_petpooja': true,
          'petpooja_raw_data': jsonEncode(item),
          'last_synced_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        // Upsert (insert or update)
        await _supabase
            .from('menu_items')
            .upsert(itemData, onConflict: 'hotel_id,petpooja_item_id');

        synced++;
      }
    } catch (e) {
      print('❌ [MenuService] Error syncing menu items: $e');
      print('Stack trace: ${StackTrace.current}');
    }

    return synced;
  }

  /// Get category name by Petpooja category ID
  Future<String?> _getCategoryName(String hotelId, String categoryId) async {
    try {
      final response = await _supabase
          .from('menu_categories')
          .select('category_name')
          .eq('hotel_id', hotelId)
          .eq('petpooja_category_id', categoryId)
          .maybeSingle();

      return response?['category_name'];
    } catch (e) {
      return null;
    }
  }

  /// Map attribute ID to name
  String _getAttributeName(String? attributeId) {
    switch (attributeId) {
      case '1':
        return 'veg';
      case '2':
        return 'non-veg';
      case '24':
        return 'egg';
      default:
        return 'veg';
    }
  }

  /// Log menu sync operation
  Future<void> _logMenuSync({
    required String hotelId,
    required String status,
    required int itemsSynced,
    required int categoriesSynced,
    String? errorMessage,
    required int durationMs,
  }) async {
    try {
      await _supabase.from('menu_sync_logs').insert({
        'hotel_id': hotelId,
        'sync_status': status,
        'items_synced': itemsSynced,
        'categories_synced': categoriesSynced,
        'error_message': errorMessage,
        'sync_duration_ms': durationMs,
        'synced_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ [MenuService] Error logging sync: $e');
    }
  }

  /// Get all menu items for a restaurant
  Future<List<MenuItem>> getMenuItems(String hotelId) async {
    try {
      print('🔍 [MenuService] Fetching menu items for hotel: $hotelId');
      
      final response = await _supabase
          .from('menu_items')
          .select()
          .eq('hotel_id', hotelId)
          .order('category_name')
          .order('item_name');

      print('✅ [MenuService] Fetched ${response.length} menu items');

      return (response as List)
          .map((item) => MenuItem.fromJson(item))
          .toList();
    } catch (e) {
      print('❌ [MenuService] Error fetching menu items: $e');
      return [];
    }
  }

  /// Get single menu item
  Future<MenuItem?> getMenuItem(String itemId) async {
    try {
      final response = await _supabase
          .from('menu_items')
          .select()
          .eq('item_id', itemId)
          .single();

      return MenuItem.fromJson(response);
    } catch (e) {
      print('❌ [MenuService] Error fetching menu item: $e');
      return null;
    }
  }

  /// Create custom menu item (not from Petpooja)
  Future<MenuItem?> createMenuItem(Map<String, dynamic> itemData) async {
    try {
      print('➕ [MenuService] Creating custom menu item...');
      
      final data = {
        ...itemData,
        'is_from_petpooja': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('menu_items')
          .insert(data)
          .select()
          .single();

      print('✅ [MenuService] Menu item created successfully');
      return MenuItem.fromJson(response);
    } catch (e) {
      print('❌ [MenuService] Error creating menu item: $e');
      return null;
    }
  }

  /// Update menu item
  Future<bool> updateMenuItem(String itemId, Map<String, dynamic> updates) async {
    try {
      print('📝 [MenuService] Updating menu item: $itemId');
      
      final data = {
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('menu_items')
          .update(data)
          .eq('item_id', itemId);

      print('✅ [MenuService] Menu item updated successfully');
      return true;
    } catch (e) {
      print('❌ [MenuService] Error updating menu item: $e');
      return false;
    }
  }

  /// Delete menu item
  Future<bool> deleteMenuItem(String itemId) async {
    try {
      print('🗑️ [MenuService] Deleting menu item: $itemId');
      
      await _supabase
          .from('menu_items')
          .delete()
          .eq('item_id', itemId);

      print('✅ [MenuService] Menu item deleted successfully');
      return true;
    } catch (e) {
      print('❌ [MenuService] Error deleting menu item: $e');
      return false;
    }
  }

  /// Toggle item availability
  Future<bool> toggleItemAvailability(String itemId, bool isAvailable) async {
    try {
      print('🔄 [MenuService] Toggling availability for: $itemId to $isAvailable');
      
      await _supabase
          .from('menu_items')
          .update({
            'is_available': isAvailable,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('item_id', itemId);

      print('✅ [MenuService] Availability updated successfully');
      return true;
    } catch (e) {
      print('❌ [MenuService] Error updating availability: $e');
      return false;
    }
  }

  /// Get all categories for a restaurant
  Future<List<MenuCategory>> getCategories(String hotelId) async {
    try {
      final response = await _supabase
          .from('menu_categories')
          .select()
          .eq('hotel_id', hotelId)
          .order('category_rank');

      return (response as List)
          .map((cat) => MenuCategory.fromJson(cat))
          .toList();
    } catch (e) {
      print('❌ [MenuService] Error fetching categories: $e');
      return [];
    }
  }

  /// Get unique category names for a restaurant
  Future<List<String>> getCategoryNames(String hotelId) async {
    try {
      final items = await getMenuItems(hotelId);
      
      final categories = items
          .where((item) => item.categoryName != null)
          .map((item) => item.categoryName!)
          .toSet()
          .toList();

      categories.sort();
      return categories;
    } catch (e) {
      print('❌ [MenuService] Error fetching category names: $e');
      return [];
    }
  }

  /// Get last sync log
  Future<MenuSyncLog?> getLastSyncLog(String hotelId) async {
    try {
      final response = await _supabase
          .from('menu_sync_logs')
          .select()
          .eq('hotel_id', hotelId)
          .order('synced_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return MenuSyncLog.fromJson(response);
      }
      return null;
    } catch (e) {
      print('❌ [MenuService] Error fetching last sync log: $e');
      return null;
    }
  }

  /// Get sync history
  Future<List<MenuSyncLog>> getSyncHistory(String hotelId, {int limit = 10}) async {
    try {
      final response = await _supabase
          .from('menu_sync_logs')
          .select()
          .eq('hotel_id', hotelId)
          .order('synced_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((log) => MenuSyncLog.fromJson(log))
          .toList();
    } catch (e) {
      print('❌ [MenuService] Error fetching sync history: $e');
      return [];
    }
  }

  /// Search menu items
  Future<List<MenuItem>> searchMenuItems(String hotelId, String query) async {
    try {
      final items = await getMenuItems(hotelId);
      
      if (query.isEmpty) return items;

      final lowerQuery = query.toLowerCase();
      return items.where((item) {
        return item.itemName.toLowerCase().contains(lowerQuery) ||
               (item.description?.toLowerCase().contains(lowerQuery) ?? false) ||
               (item.categoryName?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } catch (e) {
      print('❌ [MenuService] Error searching menu items: $e');
      return [];
    }
  }

  /// Get menu statistics
  Future<Map<String, int>> getMenuStats(String hotelId) async {
    try {
      final items = await getMenuItems(hotelId);
      
      return {
        'total': items.length,
        'available': items.where((i) => i.isAvailable).length,
        'unavailable': items.where((i) => !i.isAvailable).length,
        'inStock': items.where((i) => i.isInStock).length,
        'outOfStock': items.where((i) => !i.isInStock).length,
        'fromPetpooja': items.where((i) => i.isFromPetpooja).length,
        'custom': items.where((i) => !i.isFromPetpooja).length,
      };
    } catch (e) {
      print('❌ [MenuService] Error fetching menu stats: $e');
      return {};
    }
  }
}