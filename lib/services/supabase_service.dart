import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hotel.dart';
import '../models/location.dart';
import '../models/manager.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

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

  // Create hotel with null location_id and manager_id
  Future<Hotel?> createHotel(String name, String address) async {
    try {
      final enterpriseId = await getEnterpriseId();
      if (enterpriseId == null) {
        throw Exception('Enterprise ID not found');
      }

      final hotel = Hotel(
        name: name,
        address: address,
        enterpriseId: enterpriseId,
        locationId: null, // Will be added later
        managerId: null,  // Will be added later
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

  // Delete hotel
  Future<bool> deleteHotel(String id) async {
    try {
      await _client
          .from('hotels')
          .delete()
          .eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting hotel: $e');
      return false;
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
}