// ignore_for_file: avoid_print
import 'package:naivedhya/models/restaurant_model.dart';
import 'package:naivedhya/models/ventor_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/location.dart';
import '../models/manager.dart';

class RestaurantService {
  final SupabaseClient _client = Supabase.instance.client;
  final SupabaseClient client = Supabase.instance.client;

  Future<String?> getCurrentUserEmail() async {
    return _client.auth.currentUser?.email;
  }
  // Get enterprise ID
  Future<String?> getEnterpriseId() async {
    try {
      final response = await _client
          .from('enterprises')
          .select('enterprise_id')
          .limit(1)
          .single();
      
      return response['enterprise_id'];
    } catch (e) {
      print('Error getting enterprise ID: $e');
      return null;
    }
  }

  // FIXED: Get all Restaurants - corrected table name
  Future<List<Restaurant>> getRestaurants() async {
    try {
      final response = await _client
          .from('restaurant')  // FIXED: Correct table name
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Restaurant.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting Restaurants: $e');
      return [];
    }
  }

  // Create location for Restaurant
  Future<Location?> createLocation(Location location) async {
    try {
      final response = await _client
          .from('locations')
          .insert(location.toJson())
          .select()
          .single();

      return Location.fromJson(response);
    } catch (e) {
      print('Error creating location: $e');
      return null;
    }
  }

  // Create manager for Restaurant
  Future<Manager?> createManager(Manager manager) async {
    try {
      final response = await _client
          .from('managers')
          .insert(manager.toJson())
          .select()
          .single();

      return Manager.fromJson(response);
    } catch (e) {
      print('Error creating manager: $e');
      return null;
    }
  }

  // Get locations for Restaurant
  Future<List<Location>> getLocations(String restaurantId) async {
    try {
      final response = await _client
          .from('locations')
          .select()
          .eq('hotel_id', restaurantId);

      return (response as List)
          .map((json) => Location.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting locations: $e');
      return [];
    }
  }

  // Get managers for Restaurant
  Future<List<Manager>> getManagers(String restaurantId) async {
    try {
      final response = await _client
          .from('managers')
          .select()
          .eq('hotel_id', restaurantId);

      return (response as List)
          .map((json) => Manager.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting managers: $e');
      return [];
    }
  }

  // Get manager by ID
  Future<Manager?> getManagerById(String managerId) async {
    try {
      final response = await _client
          .from('managers')
          .select()
          .eq('id', managerId)
          .maybeSingle();

      if (response != null) {
        return Manager.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting manager by ID: $e');
      return null;
    }
  }

  // Get location by ID
  Future<Location?> getLocationById(String locationId) async {
    try {
      final response = await _client
          .from('locations')
          .select()
          .eq('id', locationId)
          .maybeSingle();

      if (response != null) {
        return Location.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting location by ID: $e');
      return null;
    }
  }

  // Get manager by Restaurant ID
  Future<Manager?> getManagerByrestaurantId(String restaurantId) async {
    try {
      final response = await _client
          .from('managers')
          .select()
          .eq('hotel_id', restaurantId)
          .maybeSingle();

      if (response != null) {
        return Manager.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting manager by Restaurant ID: $e');
      return null;
    }
  }

  // // Get location by Restaurant ID
  // Future<Location?> getLocationByrestaurantId(String restaurantId) async {
  //   try {
  //     final response = await _client
  //         .from('locations')
  //         .select()
  //         .eq('hotel_id', restaurantId)
  //         .maybeSingle();

  //     if (response != null) {
  //       return Location.fromJson(response);
  //     }
  //     return null;
  //   } catch (e) {
  //     print('Error getting location by Restaurant ID: $e');
  //     return null;
  //   }
  // }

  // FIXED: Update Restaurant - only allow name and address updates for basic info
  Future<Restaurant?> updateRestaurantBasicInfo(String restaurantId, String name, String address) async {
    try {
      // FIXED: Use Firebase Auth instead of Supabase auth
      final canEdit = await canEditRestaurant(restaurantId);
      if (!canEdit) {
        throw Exception('Permission denied: You can only edit Restaurants you created');
      }

      final response = await _client
          .from('restaurant')  // FIXED: Correct table name
          .update({
            'name': name,
            'address': address,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('hotel_id', restaurantId)  // FIXED: Lowercase column name
          .select()
          .single();

      return Restaurant.fromJson(response);
    } catch (e) {
      print('Error updating Restaurant: $e');
      return null;
    }
  }

  // Create vendor
  Future<Vendor?> createVendor(Vendor vendor) async {
    try {
      final response = await _client
          .from('vendors')
          .insert(vendor.toJson())
          .select()
          .single();

      return Vendor.fromJson(response);
    } catch (e) {
      print('Error creating vendor: $e');
      return null;
    }
  }

  // Get vendors by Restaurant ID
  Future<List<Vendor>> getVendorsByrestaurantId(String restaurantId) async {
    try {
      final response = await _client
          .from('vendors')
          .select()
          .eq('hotel_id', restaurantId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Vendor.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting vendors: $e');
      return [];
    }
  }

  // Update delivery personnel location
  Future<bool> updateDeliveryPersonnelLocation(String userId, Map<String, dynamic> location) async {
    try {
      await _client
          .from('delivery_personnel')
          .update({
            'current_location': location,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      return true;
    } catch (e) {
      print('Error updating delivery personnel location: $e');
      return false;
    }
  }

  // FIXED: Update Restaurant with manager ID
  Future<Restaurant?> updateRestaurantManager(String restaurantId, String managerId) async {
    try {
      final response = await _client
          .from('restaurant')  // FIXED: Correct table name
          .update({
            'manager_id': managerId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('hotel_id', restaurantId)  // FIXED: Lowercase column name
          .select()
          .single();

      return Restaurant.fromJson(response);
    } catch (e) {
      print('Error updating Restaurant manager: $e');
      return null;
    }
  }

  // Update manager with Restaurant ID
  Future<Manager?> updateManagerRestaurant(String managerId, String restaurantId) async {
    try {
      final response = await _client
          .from('managers')
          .update({
            'hotel_id': restaurantId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('manager_id', managerId)
          .select()
          .single();

      return Manager.fromJson(response);
    } catch (e) {
      print('Error updating manager Restaurant: $e');
      return null;
    }
  }

  // Create manager and update Restaurant (transactional approach)
  Future<String?> createManagerAndUpdateRestaurant(Manager manager, String restaurantId) async {
    try {
      final managerData = manager.toJson();
      managerData.remove('hotel_id');
      
      final managerResponse = await _client
          .from('managers')
          .insert(managerData)
          .select()
          .single();

      final managerId = managerResponse['manager_id'] as String;

      await _client
          .from('restaurant')  // FIXED: Correct table name
          .update({
            'manager_id': managerId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('hotel_id', restaurantId)  // FIXED: Lowercase column name
          .select()
          .single();

      await _client
          .from('managers')
          .update({
            'hotel_id': restaurantId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('manager_id', managerId);

      return managerId;
    } catch (e) {
      print('Error creating manager and updating Restaurant: $e');
      return null;
    }
  }

  // FIXED: Update Restaurant location
  Future<Restaurant?> updateRestaurantLocation(String restaurantId, String locationId) async {
    try {
      final response = await _client
          .from('restaurant')  // FIXED: Correct table name
          .update({
            'location_id': locationId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('hotel_id', restaurantId)  // FIXED: Lowercase column name
          .select()
          .single();

      return Restaurant.fromJson(response);
    } catch (e) {
      print('Error updating Restaurant location: $e');
      return null;
    }
  }

  // Get manager count for a Restaurant
  Future<int> getManagerCount(String restaurantId) async {
    try {
      final response = await _client
          .from('managers')
          .select('manager_id')
          .eq('hotel_id', restaurantId);
      
      return (response as List).length;
    } catch (e) {
      print('Error getting manager count: $e');
      return 0;
    }
  }

  // Get location count for a Restaurant
  Future<int> getLocationCount(String restaurantId) async {
    try {
      final response = await _client
          .from('locations')
          .select('location_id')
          .eq('hotel_id', restaurantId);
      
      return (response as List).length;
    } catch (e) {
      print('Error getting location count: $e');
      return 0;
    }
  }

  // Get both manager and location counts in a single call
  Future<Map<String, int>> getRestaurantCounts(String restaurantId) async {
    try {
      final results = await Future.wait([
        getManagerCount(restaurantId),
        getLocationCount(restaurantId),
      ]);
      
      return {
        'managers': results[0],
        'locations': results[1],
      };
    } catch (e) {
      print('Error getting Restaurant counts: $e');
      return {
        'managers': 0,
        'locations': 0,
      };
    }
  }

  // Check if Restaurant has manager
  Future<bool> hasManager(String restaurantId) async {
    final count = await getManagerCount(restaurantId);
    return count > 0;
  }

  // Check if Restaurant has location
  Future<bool> hasLocation(String restaurantId) async {
    final count = await getLocationCount(restaurantId);
    return count > 0;
  }

  // Get Restaurant status
  Future<Map<String, dynamic>> getRestaurantStatus(String restaurantId) async {
    final counts = await getRestaurantCounts(restaurantId);
    
    return {
      'managerCount': counts['managers'],
      'locationCount': counts['locations'],
      'hasManager': counts['managers']! > 0,
      'hasLocation': counts['locations']! > 0,
      'isComplete': counts['managers']! > 0 && counts['locations']! > 0,
    };
  }

  // FIXED: Get the current user's Restaurant (using Firebase Auth)
  Future<Restaurant?> getCurrentUserRestaurant() async {
    try {
      final email = _client.auth.currentUser?.email;
      if (email == null) return null;

      final response = await _client
          .from('restaurant')
          .select()
          .eq('adminemail', email)
          .maybeSingle();

      if (response == null) return null;
      return Restaurant.fromJson(response);
    } catch (e) {
      return null;
    }
  }


  // FIXED: Get all Restaurants for current user (using Firebase Auth)
  Future<List<Restaurant>> getRestaurantsForCurrentUser() async {
    try {
      final email = _client.auth.currentUser?.email;
      if (email == null) return [];

      final response = await _client
          .from('restaurant')
          .select()
          .eq('adminemail', email)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Restaurant.fromJson(json)).toList();
    } catch (e) {
      print('Error getting restaurants for current user: $e');
      return [];
    }
  }
  
  // FIXED: Create Restaurant with current user as admin (using Firebase Auth)
  Future<Restaurant?> createRestaurant(String name, String address) async {
    try {
      final email = _client.auth.currentUser?.email;
      if (email == null) throw Exception('User not authenticated');

      final restaurant = Restaurant(
        name: name,
        address: address,
        adminEmail: email,
      );

      final response = await _client
          .from('restaurant')
          .insert(restaurant.toJson())
          .select()
          .single();

      return Restaurant.fromJson(response);
    } catch (e) {
      print('Error creating restaurant: $e');
      rethrow;
    }
  }
  
  // FIXED: Update Restaurant basic information
  Future<Restaurant?> updateRestaurant(String restaurantId, String name, String address) async {
    try {
      final response = await _client
          .from('restaurant')  // FIXED: Correct table name
          .update({
            'name': name,
            'address': address,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('hotel_id', restaurantId)  // FIXED: Lowercase column name
          .select()
          .single();

      return Restaurant.fromJson(response);
    } catch (e) {
      print('Error updating Restaurant: $e');
      return null;
    }
  }

  // FIXED: Delete Restaurant
  Future<bool> deleteRestaurant(String restaurantId) async {
    try {
      await _client
          .from('restaurant')  // FIXED: Correct table name
          .delete()
          .eq('hotel_id', restaurantId);  // FIXED: Lowercase column name
      return true;
    } catch (e) {
      print('Error deleting Restaurant: $e');
      return false;
    }
  }

  // FIXED: Check if current user can edit Restaurant (using Firebase Auth)
  Future<bool> canEditRestaurant(String restaurantId) async {
    try {
      final email = _client.auth.currentUser?.email;
      if (email == null) return false;

      final response = await _client
          .from('restaurant')
          .select('adminemail')
          .eq('hotel_id', restaurantId)
          .single();

      return response['adminemail'] == email;
    } catch (e) {
      return false;
    }
  }

  
  /// Get order by ID
Future<Map<String, dynamic>?> getOrderById(String orderId) async {
  try {
    final response = await _client
        .from('orders')
        .select()
        .eq('order_id', orderId)
        .maybeSingle();

    if (response == null) {
      print('Order not found with ID: $orderId');
      return null;
    }

    return response;
  } catch (e) {
    print('Error getting order by ID: $e');
    return null;
  }
}

/// Get all orders for a restaurant
Future<List<Map<String, dynamic>>> getOrdersByRestaurant(String restaurantId) async {
  try {
    final response = await _client
        .from('orders')
        .select()
        .eq('hotel_id', restaurantId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print('Error getting orders by restaurant: $e');
    return [];
  }
}

/// Get all orders for a vendor
Future<List<Map<String, dynamic>>> getOrdersByVendor(String vendorId) async {
  try {
    final response = await _client
        .from('orders')
        .select()
        .eq('vendor_id', vendorId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print('Error getting orders by vendor: $e');
    return [];
  }
}

/// Get orders with pagination
Future<List<Map<String, dynamic>>> getOrdersPaginated({
  int limit = 20,
  int offset = 0,
  String? status,
  String? restaurantId,
}) async {
  try {
    var query = _client.from('orders').select();

    if (status != null) {
      query = query.eq('status', status);
    }

    if (restaurantId != null) {
      query = query.eq('hotel_id', restaurantId);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print('Error getting paginated orders: $e');
    return [];
  }
}

/// Get order with related restaurant and vendor details
Future<Map<String, dynamic>?> getOrderWithDetails(String orderId) async {
  try {
    final orderResponse = await _client
        .from('orders')
        .select()
        .eq('order_id', orderId)
        .maybeSingle();

    if (orderResponse == null) return null;

    final order = orderResponse;
    
    // Fetch restaurant details
    final restaurant = await getRestaurantById(order['hotel_id']);
    
    // Vendor details are already in the VendorService
    
    return {
      ...order,
      'restaurant': restaurant?.toJson(),
    };
  } catch (e) {
    print('Error getting order with details: $e');
    return null;
  }
}

/// Update order status
Future<bool> updateOrderStatus(String orderId, String status) async {
  try {
    await _client
        .from('orders')
        .update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('order_id', orderId);

    return true;
  } catch (e) {
    print('Error updating order status: $e');
    return false;
  }
}

/// Update delivery status
Future<bool> updateDeliveryStatus(String orderId, String deliveryStatus) async {
  try {
    await _client
        .from('orders')
        .update({
          'delivery_status': deliveryStatus,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('order_id', orderId);

    return true;
  } catch (e) {
    print('Error updating delivery status: $e');
    return false;
  }
}

/// Get orders by status
Future<List<Map<String, dynamic>>> getOrdersByStatus(String status) async {
  try {
    final response = await _client
        .from('orders')
        .select()
        .eq('status', status)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print('Error getting orders by status: $e');
    return [];
  }
}

// ============= FIX FOR RESTAURANT LOCATION QUERY =============

// /// FIXED: Get location by Restaurant ID - returns first location or null
// Future<Location?> getLocationByRestaurantIdFixed(String restaurantId) async {
//   try {
//     final response = await _client
//         .from('locations')
//         .select()
//         .eq('hotel_id', restaurantId)
//         .limit(1);  // Only get the first location

//     if ((response as List).isEmpty) return null;

//     return Location.fromJson(response[0]);
//   } catch (e) {
//     print('Error getting location by Restaurant ID: $e');
//     return null;
//   }
// }

/// Alternative: Get all locations for a Restaurant
Future<List<Location>> getLocationsByRestaurantId(String restaurantId) async {
  try {
    final response = await _client
        .from('locations')
        .select()
        .eq('hotel_id', restaurantId);

    return (response as List)
        .map((json) => Location.fromJson(json))
        .toList();
  } catch (e) {
    print('Error getting locations by Restaurant ID: $e');
    return [];
  }
}

// ============= REPLACE THIS EXISTING METHOD =============
// Replace your existing getLocationByrestaurantId (line 186) with this:

Future<Location?> getLocationByrestaurantId(String restaurantId) async {
  try {
    final response = await _client
        .from('locations')
        .select()
        .eq('hotel_id', restaurantId)
        .limit(1);  // Add this to only get first location

    if ((response as List).isEmpty) return null;

    return Location.fromJson(response[0]);
  } catch (e) {
    print('Error getting location by Restaurant ID: $e');
    return null;
  }
}


// // ✅ ADD THIS METHOD if it doesn't exist, or REPLACE if it exists
// Future<Restaurant?> getRestaurantById(String restaurantId) async {
//   try {
//     final response = await _client
//         .from('restaurant')
//         .select()
//         .eq('hotel_id', restaurantId)
//         .maybeSingle();

//     if (response == null) {
//       print('Restaurant not found with ID: $restaurantId');
//       return null;
//     }

//     return Restaurant.fromJson(response);
//   } catch (e) {
//     print('Error getting restaurant by ID: $e');
//     return null;
//   }
// }

// ✅ KEEP THIS METHOD (already exists in your file at line 594)
// This method is used by OrderDetailScreen but not by OrderService
Future<Map<String, dynamic>?> getRestaurantDetails(String restaurantId) async {
  try {
    final restaurant = await getRestaurantById(restaurantId);
    if (restaurant == null) return null;

    final manager = await getManagerByrestaurantId(restaurantId);
    final location = await getLocationByrestaurantId(restaurantId);

    return {
      'restaurant': restaurant,
      'manager': manager,
      'location': location,
    };
  } catch (e) {
    print('Error getting Restaurant details: $e');
    return null;
  }
}

/// Fetch restaurants by admin email - ADD THIS METHOD
Future<List<Restaurant>> getRestaurantsByAdminEmail(String email) async {
  try {
    print('🔍 [RestaurantService] Fetching restaurants for admin email: $email');
    
    final response = await client
        .from('restaurant')
        .select()
        .eq('adminemail', email)
        .order('created_at', ascending: false);

    print('✅ [RestaurantService] Found ${(response as List).length} restaurants');
    
    return (response)
        .map((json) => Restaurant.fromJson(json))
        .toList();
  } catch (e) {
    print('❌ [RestaurantService] Error fetching restaurants by admin email: $e');
    throw Exception('Failed to fetch restaurants: $e');
  }
}

/// Fetch single restaurant by ID - ADD THIS METHOD IF NOT EXISTS
Future<Restaurant?> getRestaurantById(String restaurantId) async {
  try {
    print('🔍 [RestaurantService] Fetching restaurant by ID: $restaurantId');
    
    final response = await client
        .from('restaurant')
        .select()
        .eq('hotel_id', restaurantId)
        .maybeSingle();

    if (response == null) {
      print('⚠️ [RestaurantService] Restaurant not found with ID: $restaurantId');
      return null;
    }

    print('✅ [RestaurantService] Restaurant found: ${response['name']}');
    return Restaurant.fromJson(response);
  } catch (e) {
    print('❌ [RestaurantService] Error fetching restaurant by ID: $e');
    throw Exception('Failed to fetch restaurant: $e');
  }
}


















}