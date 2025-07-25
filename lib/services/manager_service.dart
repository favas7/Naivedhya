import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:naivedhya/models/manager.dart';

class ManagerService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Manager>> getAllManagers() async {
    try {
      final response = await _supabase
          .from('managers')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Manager.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load managers: $e');
    }
  }

  Future<String> addManager(Manager manager) async {
    try {
      final response = await _supabase
          .from('managers')
          .insert(manager.toJson())
          .select()
          .single();
      
      return response['manager_id'] as String;
    } catch (e) {
      throw Exception('Failed to add manager: $e');
    }
  }

  // Updated method to handle both manager and hotel updates
  Future<String?> addManagerAndUpdateHotel(Manager manager, String hotelId) async {
    try {
      // Step 1: Create manager without hotel_id first
      final managerData = manager.toJson();
      managerData.remove('hotel_id'); // Remove hotel_id for initial creation
      
      final managerResponse = await _supabase
          .from('managers')
          .insert(managerData)
          .select()
          .single();

      final managerId = managerResponse['manager_id'] as String;

      // Step 2: Update hotel with manager_id
      await _supabase
          .from('hotels')
          .update({
            'manager_id': managerId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('hotel_id', hotelId);

      // Step 3: Update manager with hotel_id to complete the relationship
      await _supabase
          .from('managers')
          .update({
            'hotel_id': hotelId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('manager_id', managerId);

      return managerId;
    } catch (e) {
      throw Exception('Failed to add manager and update hotel: $e');
    }
  }

  Future<void> updateManager(Manager manager) async {
    try {
      await _supabase
          .from('managers')
          .update(manager.toJson())
          .eq('manager_id', manager.id!);
    } catch (e) {
      throw Exception('Failed to update manager: $e');
    }
  }

  Future<void> deleteManager(String managerId) async {
    try {
      await _supabase
          .from('managers')
          .delete()
          .eq('manager_id', managerId);
    } catch (e) {
      throw Exception('Failed to delete manager: $e');
    }
  }

  Future<Manager?> getManagerById(String managerId) async {
    try {
      final response = await _supabase
          .from('managers')
          .select()
          .eq('manager_id', managerId)
          .maybeSingle();
      
      if (response != null) {
        return Manager.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get manager: $e');
    }
  }

  Future<Manager?> getManagerByHotelId(String hotelId) async {
    try {
      final response = await _supabase
          .from('managers')
          .select()
          .eq('hotel_id', hotelId)
          .maybeSingle();
      
      if (response != null) {
        return Manager.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get manager by hotel ID: $e');
    }
  }
}