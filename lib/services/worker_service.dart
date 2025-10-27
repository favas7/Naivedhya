// lib/services/worker_service.dart
import 'package:naivedhya/models/worker_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkerService {
  
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'workers';
  

  /// Create new worker
  Future<Worker> createWorker(Worker worker) async {
    // At the start of createWorker method
final currentUser = _supabase.auth.currentUser;
print('🔐 [AUTH CHECK] Current user: ${currentUser?.id}');
print('🔐 [AUTH CHECK] User email: ${currentUser?.email}');
print('🔐 [AUTH CHECK] Is authenticated: ${currentUser != null}');
    print('🔷 [WORKER SERVICE] createWorker() called');
    print('🔷 [WORKER SERVICE] Table name: $_tableName');
    print('🔷 [WORKER SERVICE] Worker data: ${worker.toJson()}');
    
    try {
      print('📤 [WORKER SERVICE] Sending INSERT request to Supabase...');
      
      final response = await _supabase
          .from(_tableName)
          .insert(worker.toJson())
          .select()
          .single();

      print('✅ [WORKER SERVICE] Insert successful!');
      print('📥 [WORKER SERVICE] Response: $response');
      
      final createdWorker = Worker.fromJson(response);
      print('✅ [WORKER SERVICE] Worker object created from response');
      print('🆔 [WORKER SERVICE] New worker ID: ${createdWorker.id}');
      
      return createdWorker;
    } catch (e, stackTrace) {
      print('❌ [WORKER SERVICE] CREATE ERROR!');
      print('❌ [WORKER SERVICE] Error type: ${e.runtimeType}');
      print('❌ [WORKER SERVICE] Error message: $e');
      print('❌ [WORKER SERVICE] Stack trace: $stackTrace');
      
      // Additional debugging for Supabase errors
      if (e.toString().contains('violates')) {
        print('❌ [WORKER SERVICE] Database constraint violation detected');
      }
      if (e.toString().contains('null value')) {
        print('❌ [WORKER SERVICE] Null value constraint violation');
      }
      if (e.toString().contains('permission')) {
        print('❌ [WORKER SERVICE] Permission/RLS policy issue');
      }
      
      throw Exception('Failed to create worker: $e');
    }
  }

  /// Get all workers for a specific vendor
  Future<List<Worker>> getWorkersByVendor(String vendorId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('vendor_id', vendorId)
          .order('name', ascending: true);

      return (response as List<dynamic>)
          .map((json) => Worker.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch workers: $e');
    }
  }

  /// Get only active workers for a specific vendor
  Future<List<Worker>> getActiveWorkersByVendor(String vendorId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('vendor_id', vendorId)
          .eq('is_active', true)
          .order('name', ascending: true);

      return (response as List<dynamic>)
          .map((json) => Worker.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active workers: $e');
    }
  }

  /// Get worker by ID
  Future<Worker?> getWorkerById(String workerId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('worker_id', workerId)
          .maybeSingle();

      if (response == null) return null;
      return Worker.fromJson(response);
    } catch (e) {
      print('Error fetching worker: $e');
      return null;
    }
  }

  /// Update worker
  Future<Worker> updateWorker(Worker worker) async {
    try {
      if (worker.id == null) {
        throw Exception('Worker ID is required for update');
      }

      final response = await _supabase
          .from(_tableName)
          .update(worker.toJson())
          .eq('worker_id', worker.id!)
          .select()
          .single();

      return Worker.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update worker: $e');
    }
  }

  /// Soft delete worker (set is_active to false)
  Future<void> deactivateWorker(String workerId) async {
    try {
      await _supabase
          .from(_tableName)
          .update({'is_active': false, 'updated_at': DateTime.now().toIso8601String()})
          .eq('worker_id', workerId);
    } catch (e) {
      throw Exception('Failed to deactivate worker: $e');
    }
  }

  /// Hard delete worker (permanently remove from database)
  Future<void> deleteWorker(String workerId) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('worker_id', workerId);
    } catch (e) {
      throw Exception('Failed to delete worker: $e');
    }
  }

  /// Reactivate a deactivated worker
  Future<void> reactivateWorker(String workerId) async {
    try {
      await _supabase
          .from(_tableName)
          .update({'is_active': true, 'updated_at': DateTime.now().toIso8601String()})
          .eq('worker_id', workerId);
    } catch (e) {
      throw Exception('Failed to reactivate worker: $e');
    }
  }

  /// Search workers by name for a specific vendor
  Future<List<Worker>> searchWorkers(String vendorId, String query) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('vendor_id', vendorId)
          .ilike('name', '%$query%')
          .limit(10);

      return (response as List<dynamic>)
          .map((json) => Worker.fromJson(json))
          .toList();
    } catch (e) {
      print('Error searching workers: $e');
      return [];
    }
  }

  /// Get worker count by vendor
  Future<int> getWorkerCount(String vendorId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('worker_id')
          .eq('vendor_id', vendorId)
          .eq('is_active', true);

      return (response as List).length;
    } catch (e) {
      print('Error getting worker count: $e');
      return 0;
    }
  }

  /// Get workers by employment status
  Future<List<Worker>> getWorkersByStatus(String vendorId, String status) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('vendor_id', vendorId)
          .eq('employment_status', status)
          .order('name', ascending: true);

      return (response as List<dynamic>)
          .map((json) => Worker.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch workers by status: $e');
    }
  }

  /// Get workers by shift type
  Future<List<Worker>> getWorkersByShift(String vendorId, String shiftType) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('vendor_id', vendorId)
          .eq('shift_type', shiftType)
          .eq('is_active', true)
          .order('name', ascending: true);

      return (response as List<dynamic>)
          .map((json) => Worker.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch workers by shift: $e');
    }
  }

  /// Stream worker data for real-time updates
  Stream<List<Worker>> streamWorkersByVendor(String vendorId) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['worker_id'])
        .eq('vendor_id', vendorId)
        .order('name', ascending: true)
        .map((data) {
          return data.map((json) => Worker.fromJson(json)).toList();
        });
  }

  /// Get workers grouped by role
  Future<Map<String, List<Worker>>> getWorkersGroupedByRole(String vendorId) async {
    try {
      final workers = await getActiveWorkersByVendor(vendorId);
      final Map<String, List<Worker>> grouped = {};

      for (var worker in workers) {
        if (!grouped.containsKey(worker.role)) {
          grouped[worker.role] = [];
        }
        grouped[worker.role]!.add(worker);
      }

      return grouped;
    } catch (e) {
      throw Exception('Failed to group workers by role: $e');
    }
  }
}