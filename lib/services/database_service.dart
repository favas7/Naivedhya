import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  SupabaseClient get client => _supabase;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get current enterprise ID
  Future<String> getCurrentEnterpriseId() async {
    try {
      final user = currentUser;
      if (user != null) {
        final userProfile = await _supabase
            .from('enterprises')
            .select('enterprise_id')
            .eq('user_id', user.id)
            .single();
        return userProfile['enterprise_id'] as String;
      }

      // Fallback if no user (get first enterprise)
      final enterprises = await _supabase
          .from('enterprises')
          .select('enterprise_id')
          .limit(1)
          .single();
      
      return enterprises['enterprise_id'] as String;
    } catch (e) {
      throw Exception('Unable to get enterprise ID: $e');
    }
  }

  // Generic insert method
  Future<Map<String, dynamic>> insertData(String table, Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from(table)
          .insert(data)
          .select()
          .single();
      return response;
    } catch (e) {
      throw Exception('Error inserting data into $table: $e');
    }
  }

  // Generic select method
  Future<List<Map<String, dynamic>>> selectData(
    String table, {
    String? columns,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      // Use `var` to allow type inference
      PostgrestTransformBuilder<PostgrestList> query = _supabase.from(table).select(columns ?? '*');

      // if (filters != null) {
      //   for (var entry in filters.entries) {
      //     query = query.eq(entry.key, entry.value);
      //   }
      // }

      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending); // Line 75: Now safe
      }

      if (limit != null) {
        query = query.limit(limit); // Line 79: Now safe
      }

      final response = await query;
      // ignore: unnecessary_cast
      return response as List<Map<String, dynamic>>;
    } catch (e) {
      throw Exception('Error selecting data from $table: $e');
    }
  }

  // Generic update method
  Future<Map<String, dynamic>> updateData(
    String table,
    Map<String, dynamic> data,
    Map<String, dynamic> filters,
  ) async {
    try {
      var query = _supabase.from(table).update(data);

      for (var entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }

      final response = await query.select().single();
      return response;
    } catch (e) {
      throw Exception('Error updating data in $table: $e');
    }
  }

  // Generic delete method
  Future<void> deleteData(String table, Map<String, dynamic> filters) async {
    try {
      var query = _supabase.from(table).delete();

      for (var entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }

      await query;
    } catch (e) {
      throw Exception('Error deleting data from $table: $e');
    }
  }
}