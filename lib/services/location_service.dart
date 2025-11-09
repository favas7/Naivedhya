import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:naivedhya/models/location.dart';

class LocationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Location>> getAllLocations() async {
    try {
      final response = await _supabase
          .from('locations')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Location.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load locations: $e');
    }
  }

  // Updated to return String? to match the provider expectation
  Future<String?> addLocation(Location location) async {
    try {
      final response = await _supabase
          .from('locations')
          .insert(location.toJson())
          .select()
          .single();
      
      // Return the location_id as String, matching your database schema
      return response['location_id'] as String?;
    } catch (e) {
      throw Exception('Failed to add location: $e');
    }
  }

Future<void> updateLocation(Location location) async {
  try {
    // ✅ Check if location has an ID (UUID)
    if (location.id == null || location.id!.isEmpty) {
      throw Exception('Location ID is required for update');
    }

    await _supabase
        .from('locations')
        .update(location.toUpdateJson()) // ✅ Use dedicated update method
        .eq('location_id', location.id!); // ✅ Match the exact column name
    
    // Note: Supabase will automatically handle updated_at if you have triggers set up
    
  } catch (e) {
    // ✅ More detailed error information
    print('LocationService Error: $e'); // For debugging
    throw Exception('Failed to update location: $e');
  }
}
  Future<void> deleteLocation(String locationId) async {
    try {
      await _supabase
          .from('locations')
          .delete()
          .eq('location_id', locationId);
    } catch (e) {
      throw Exception('Failed to delete location: $e');
    }
  }

  Future<Location?> getLocationById(String locationId) async {
    try {
      final response = await _supabase
          .from('locations')
          .select()
          .eq('location_id', locationId)
          .maybeSingle();
      
      if (response != null) {
        return Location.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }
  Future<List<Location>> getLocationsByRestaurantId(String restaurantId) async {
    try {
      final response = await _supabase
          .from('locations')
          .select()
          .eq('hotel_id', restaurantId)
          .order('created_at', ascending: false);  // Sort by newest first (optional but consistent)
      
      return (response as List)
          .map((json) => Location.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get locations by Restaurant ID: $e');
    }
  }

  Future<Location?> getLocationByrestaurantId(String restaurantId) async {
    try {
      final response = await _supabase
          .from('locations')
          .select()
          .eq('hotel_id', restaurantId)
          .maybeSingle();
      
      if (response != null) {
        return Location.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get location by Restaurant ID: $e');
    }
  }
}