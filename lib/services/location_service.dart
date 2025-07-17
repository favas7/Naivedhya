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

  Future<String> addLocation(Location location) async {
    try {
      final response = await _supabase
          .from('locations')
          .insert(location.toJson())
          .select()
          .single();
      
      return response['location_id'] as String;
    } catch (e) {
      throw Exception('Failed to add location: $e');
    }
  }

  Future<void> updateLocation(Location location) async {
    try {
      await _supabase
          .from('locations')
          .update(location.toJson())
          .eq('location_id', location.id!);
    } catch (e) {
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

  Future<Location?> getLocationByHotelId(String hotelId) async {
    try {
      final response = await _supabase
          .from('locations')
          .select()
          .eq('hotel_id', hotelId)
          .maybeSingle();
      
      if (response != null) {
        return Location.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get location by hotel ID: $e');
    }
  }
}