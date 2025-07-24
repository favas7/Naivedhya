// ignore_for_file: avoid_print

import 'package:naivedhya/models/deliver_person_model.dart';
import 'package:naivedhya/models/ventor_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/hotel.dart';
import '../models/location.dart';
import '../models/manager.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Get current user's email from profiles table
  Future<String?> getCurrentUserEmail() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        print('No authenticated user found');
        return null;
      }

      final response = await _client
          .from('profiles')
          .select('email')
          .eq('userid', currentUser.uid)
          .single();

      return response['email'];
    } catch (e) {
      print('Error getting current user email: $e');
      return null;
    }
  }

  // Get enterprise ID (you might want to pass this from auth or context)
  Future<String?> getEnterpriseId() async {
    try {
      // Replace this with your actual logic to get enterprise_id
      // This could be from user session, auth context, or passed as parameter
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

  // Create hotel with current user's email as admin
  Future<Hotel?> createHotel(String name, String address) async {
    try {
      final enterpriseId = await getEnterpriseId();
      if (enterpriseId == null) {
        throw Exception('Enterprise ID not found');
      }

      // Get current user's email
      final adminEmail = await getCurrentUserEmail();
      if (adminEmail == null) {
        throw Exception('User email not found');
      }

      final hotel = Hotel(
        name: name,
        address: address,
        enterpriseId: enterpriseId,
        locationId: null, // Will be added later
        managerId: null,  // Will be added later
        adminEmail: adminEmail, // Set current user's email
      );

      final response = await _client
          .from('hotels')
          .insert(hotel.toJson())
          .select()
          .single();

      return Hotel.fromJson(response);
    } catch (e) {
      print('Error creating hotel: $e');
      return null;
    }
  }

  // Get all hotels
  Future<List<Hotel>> getHotels() async {
    try {
      final response = await _client
          .from('hotels')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Hotel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting hotels: $e');
      return [];
    }
  }

  // Get hotels for current user (only hotels created by current user)
  Future<List<Hotel>> getHotelsForCurrentUser() async {
    try {
      final adminEmail = await getCurrentUserEmail();
      if (adminEmail == null) {
        print('No authenticated user found');
        return [];
      }

      final response = await _client
          .from('hotels')
          .select()
          .eq('adminemail', adminEmail)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Hotel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting hotels for current user: $e');
      return [];
    }
  }



  // Update hotel
  Future<Hotel?> updateHotel(String id, Hotel hotel) async {
    try {
      final response = await _client
          .from('hotels')
          .update(hotel.toJson())
          .eq('id', id)
          .select()
          .single();

      return Hotel.fromJson(response);
    } catch (e) {
      print('Error updating hotel: $e');
      return null;
    }
  }


  // Create location for hotel
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

  // Create manager for hotel
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

  // Get locations for hotel
  Future<List<Location>> getLocations(String hotelId) async {
    try {
      final response = await _client
          .from('locations')
          .select()
          .eq('hotel_id', hotelId);

      return (response as List)
          .map((json) => Location.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting locations: $e');
      return [];
    }
  }

  // Get managers for hotel
  Future<List<Manager>> getManagers(String hotelId) async {
    try {
      final response = await _client
          .from('managers')
          .select()
          .eq('hotel_id', hotelId);

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

  // Get manager by hotel ID
  Future<Manager?> getManagerByHotelId(String hotelId) async {
    try {
      final response = await _client
          .from('managers')
          .select()
          .eq('hotel_id', hotelId)
          .maybeSingle();

      if (response != null) {
        return Manager.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting manager by hotel ID: $e');
      return null;
    }
  }

  // Get location by hotel ID
  Future<Location?> getLocationByHotelId(String hotelId) async {
    try {
      final response = await _client
          .from('locations')
          .select()
          .eq('hotel_id', hotelId)
          .maybeSingle();

      if (response != null) {
        return Location.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting location by hotel ID: $e');
      return null;
    }
  }
  // Add these updated methods to your existing SupabaseService class

// Check if current user can edit hotel (is the hotel owner)
Future<bool> canEditHotel(String hotelId) async {
  try {
    final adminEmail = await getCurrentUserEmail();
    if (adminEmail == null) {
      return false;
    }

    final response = await _client
        .from('hotels')
        .select('adminemail')
        .eq('hotel_id', hotelId) // Use hotel_id instead of id
        .single();

    return response['adminemail'] == adminEmail;
  } catch (e) {
    print('Error checking hotel edit permission: $e');
    return false;
  }
}

// Update hotel - only allow name and address updates for basic info
Future<Hotel?> updateHotelBasicInfo(String hotelId, String name, String address) async {
  try {
    // First check if user can edit this hotel
    final canEdit = await canEditHotel(hotelId);
    if (!canEdit) {
      throw Exception('Permission denied: You can only edit hotels you created');
    }

    final response = await _client
        .from('hotels')
        .update({
          'name': name,
          'address': address,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('hotel_id', hotelId) // Use hotel_id instead of id
        .select()
        .single();

    return Hotel.fromJson(response);
  } catch (e) {
    print('Error updating hotel: $e');
    return null;
  }
}

// Delete hotel
Future<bool> deleteHotel(String hotelId) async {
  try {
    // First check if user can edit this hotel
    final canEdit = await canEditHotel(hotelId);
    if (!canEdit) {
      print('Permission denied: You can only delete hotels you created');
      return false;
    }

    await _client
        .from('hotels')
        .delete()
        .eq('hotel_id', hotelId); // Use hotel_id instead of id
    return true;
  } catch (e) {
    print('Error deleting hotel: $e');
    return false;
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

// Get vendors by hotel ID
Future<List<Vendor>> getVendorsByHotelId(String hotelId) async {
  try {
    final response = await _client
        .from('vendors')
        .select()
        .eq('hotel_id', hotelId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Vendor.fromJson(json))
        .toList();
  } catch (e) {
    print('Error getting vendors: $e');
    return [];
  }
}
// Add these methods to your existing SupabaseService class


// Get all delivery personnel
Future<List<DeliveryPersonnel>> getDeliveryPersonnel() async {
  try {
    final response = await _client
        .from('delivery_personnel')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => DeliveryPersonnel.fromJson(json))
        .toList();
  } catch (e) {
    print('Error getting delivery personnel: $e');
    return [];
  }
}

// Create delivery personnel
Future<DeliveryPersonnel?> createDeliveryPersonnel(DeliveryPersonnel personnel) async {
  try {
    final response = await _client
        .from('delivery_personnel')
        .insert(personnel.toJson())
        .select()
        .single();

    return DeliveryPersonnel.fromJson(response);
  } catch (e) {
    print('Error creating delivery personnel: $e');
    return null;
  }
}

// Update delivery personnel
Future<DeliveryPersonnel?> updateDeliveryPersonnel(String userId, DeliveryPersonnel personnel) async {
  try {
    final response = await _client
        .from('delivery_personnel')
        .update(personnel.toJson())
        .eq('user_id', userId)
        .select()
        .single();

    return DeliveryPersonnel.fromJson(response);
  } catch (e) {
    print('Error updating delivery personnel: $e');
    return null;
  }
}

// Delete delivery personnel
Future<bool> deleteDeliveryPersonnel(String userId) async {
  try {
    await _client
        .from('delivery_personnel')
        .delete()
        .eq('user_id', userId);
    return true;
  } catch (e) {
    print('Error deleting delivery personnel: $e');
    return false;
  }
}

// Get delivery personnel by user ID
Future<DeliveryPersonnel?> getDeliveryPersonnelById(String userId) async {
  try {
    final response = await _client
        .from('delivery_personnel')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response != null) {
      return DeliveryPersonnel.fromJson(response);
    }
    return null;
  } catch (e) {
    print('Error getting delivery personnel by ID: $e');
    return null;
  }
}

// Get available delivery personnel
Future<List<DeliveryPersonnel>> getAvailableDeliveryPersonnel() async {
  try {
    final response = await _client
        .from('delivery_personnel')
        .select()
        .eq('is_available', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => DeliveryPersonnel.fromJson(json))
        .toList();
  } catch (e) {
    print('Error getting available delivery personnel: $e');
    return [];
  }
}

// Update delivery personnel availability
Future<bool> updateDeliveryPersonnelAvailability(String userId, bool isAvailable) async {
  try {
    await _client
        .from('delivery_personnel')
        .update({
          'is_available': isAvailable,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId);
    return true;
  } catch (e) {
    print('Error updating delivery personnel availability: $e');
    return false;
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
}