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