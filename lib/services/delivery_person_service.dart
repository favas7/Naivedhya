// services/delivery_personnel_service.dart
import 'package:naivedhya/models/delivery_person_model.dart';
import 'package:naivedhya/models/delivery_history_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeliveryPersonnelService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<DeliveryPersonnel>> fetchAvailableDeliveryPersonnel() async {
    try {
      final response = await _supabase
          .from('delivery_personnel')
          .select()
          .eq('is_available', true)
          .eq('is_verified', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => DeliveryPersonnel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch delivery personnel: ${e.toString()}');
    }
  }

  Future<List<DeliveryPersonnel>> fetchAllDeliveryPersonnel() async {
    try {
      final response = await _supabase
          .from('delivery_personnel')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => DeliveryPersonnel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch delivery personnel: ${e.toString()}');
    }
  }

  Future<DeliveryPersonnel?> fetchDeliveryPersonnelById(String userId) async {
    try {
      final response = await _supabase
          .from('delivery_personnel')
          .select()
          .eq('user_id', userId)
          .single();

      return DeliveryPersonnel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch delivery personnel: ${e.toString()}');
    }
  }

  // NEW: Fetch detailed delivery personnel information
  Future<DeliveryPersonnel?> fetchDetailedDeliveryPersonnel(String userId) async {
    try {
      final response = await _supabase
          .from('delivery_personnel')
          .select()
          .eq('user_id', userId)
          .single();

      return DeliveryPersonnel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch detailed delivery personnel: ${e.toString()}');
    }
  }

  // NEW: Fetch delivery history for a specific delivery person
  Future<List<DeliveryHistory>> fetchDeliveryHistory(
    String deliveryPersonId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('delivery_history')
          .select()
          .eq('delivery_person_id', deliveryPersonId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => DeliveryHistory.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch delivery history: ${e.toString()}');
    }
  }

  // NEW: Fetch delivery statistics for analytics
  Future<Map<String, dynamic>> fetchDeliveryStatistics(
    String deliveryPersonId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('delivery_history')
          .select()
          .eq('delivery_person_id', deliveryPersonId);

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      final deliveries = (response as List)
          .map((json) => DeliveryHistory.fromJson(json))
          .toList();

      // Calculate statistics
      int totalDeliveries = deliveries.length;
      int completedDeliveries = deliveries
          .where((d) => d.isCompleted)
          .length;
      double totalEarnings = deliveries
          .fold(0.0, (sum, d) => sum + d.totalEarnings);
      double totalDistance = deliveries
          .fold(0.0, (sum, d) => sum + d.distanceKm);

      // Group by date for daily statistics
      Map<String, int> deliveriesPerDay = {};
      for (var delivery in deliveries) {
        String dateKey = delivery.createdAt.toIso8601String().split('T')[0];
        deliveriesPerDay[dateKey] = (deliveriesPerDay[dateKey] ?? 0) + 1;
      }

      return {
        'total_deliveries': totalDeliveries,
        'completed_deliveries': completedDeliveries,
        'total_earnings': totalEarnings,
        'total_distance': totalDistance,
        'deliveries_per_day': deliveriesPerDay,
        'average_deliveries_per_day': totalDeliveries > 0 
            ? totalDeliveries / (deliveriesPerDay.length > 0 ? deliveriesPerDay.length : 1) 
            : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to fetch delivery statistics: ${e.toString()}');
    }
  }

  // NEW: Update delivery personnel information
  Future<DeliveryPersonnel> updateDeliveryPersonnel(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _supabase
          .from('delivery_personnel')
          .update(updates)
          .eq('user_id', userId)
          .select()
          .single();

      return DeliveryPersonnel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update delivery personnel: ${e.toString()}');
    }
  }

  // NEW: Update verification status
  Future<DeliveryPersonnel> updateVerificationStatus(
    String userId,
    bool isVerified,
    String verificationStatus,
  ) async {
    try {
      final response = await _supabase
          .from('delivery_personnel')
          .update({
            'is_verified': isVerified,
            'verification_status': verificationStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .select()
          .single();

      return DeliveryPersonnel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update verification status: ${e.toString()}');
    }
  }

  Future<bool> assignOrderToDeliveryPersonnel(String orderId, String deliveryPersonId) async {
    try {
      // Start a transaction-like operation
      // First, get the current delivery personnel data
      final deliveryPersonResponse = await _supabase
          .from('delivery_personnel')
          .select('assigned_orders')
          .eq('user_id', deliveryPersonId)
          .single();

      List<String> currentOrders = List<String>.from(
        deliveryPersonResponse['assigned_orders'] ?? []
      );
      
      // Add the new order if not already assigned
      if (!currentOrders.contains(orderId)) {
        currentOrders.add(orderId);
      }

      // Update delivery personnel with new assigned order
      await _supabase
          .from('delivery_personnel')
          .update({
            'assigned_orders': currentOrders,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', deliveryPersonId);

      // Update the order with delivery person assignment
      await _supabase
          .from('orders')
          .update({
            'delivery_person_id': deliveryPersonId,
            'delivery_status': 'Assigned',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('order_id', orderId);

      return true;
    } catch (e) {
      throw Exception('Failed to assign order to delivery personnel: ${e.toString()}');
    }
  }

  Future<bool> unassignOrderFromDeliveryPersonnel(String orderId, String? deliveryPersonId) async {
    try {
      if (deliveryPersonId != null) {
        // Get current delivery personnel data
        final deliveryPersonResponse = await _supabase
            .from('delivery_personnel')
            .select('assigned_orders')
            .eq('user_id', deliveryPersonId)
            .single();

        List<String> currentOrders = List<String>.from(
          deliveryPersonResponse['assigned_orders'] ?? []
        );
        
        // Remove the order
        currentOrders.remove(orderId);

        // Update delivery personnel
        await _supabase
            .from('delivery_personnel')
            .update({
              'assigned_orders': currentOrders,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', deliveryPersonId);
      }

      // Update the order to remove delivery person assignment
      await _supabase
          .from('orders')
          .update({
            'delivery_person_id': null,
            'delivery_status': 'Pending',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('order_id', orderId);

      return true;
    } catch (e) {
      throw Exception('Failed to unassign order from delivery personnel: ${e.toString()}');
    }
  }

  Future<List<DeliveryPersonnel>> searchDeliveryPersonnel({
    String? searchQuery,
    bool? isAvailable,
    bool? isVerified,
  }) async {
    try {
      var query = _supabase.from('delivery_personnel').select();

      if (isAvailable != null) {
        query = query.eq('is_available', isAvailable);
      }

      if (isVerified != null) {
        query = query.eq('is_verified', isVerified);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'name.ilike.%$searchQuery%,'
          'full_name.ilike.%$searchQuery%,'
          'email.ilike.%$searchQuery%,'
          'phone.ilike.%$searchQuery%,'
          'number_plate.ilike.%$searchQuery%'
        );
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => DeliveryPersonnel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search delivery personnel: ${e.toString()}');
    }
  }

  Future<DeliveryPersonnel> updateDeliveryPersonnelAvailability(
    String userId, 
    bool isAvailable
  ) async {
    try {
      final response = await _supabase
          .from('delivery_personnel')
          .update({
            'is_available': isAvailable,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .select()
          .single();

      return DeliveryPersonnel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update delivery personnel availability: ${e.toString()}');
    }
  }

  Stream<List<DeliveryPersonnel>> getDeliveryPersonnelStream() {
    return _supabase
        .from('delivery_personnel')
        .stream(primaryKey: ['user_id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => DeliveryPersonnel.fromJson(json)).toList());
  }




  
  // ============ NEW METHODS FOR MAP FUNCTIONALITY ============

  /// Fetch delivery personnel with location data for map display
  Future<List<DeliveryPersonnel>> fetchDeliveryPersonnelWithLocation() async {
    try {
      final response = await _supabase
          .from('delivery_personnel')
          .select('*')  // Get all fields including current_location
          .not('current_location', 'is', null)  // Only personnel with location
          .order('updated_at', ascending: false);

      return (response as List)
          .map((json) => DeliveryPersonnel.fromJson(json))
          .where((person) => person.hasLocation)  // Double-check location validity
          .toList();
    } catch (e) {
      print('Error fetching delivery personnel with location: $e');
      return [];
    }
  }

  /// Subscribe to real-time location updates
  RealtimeChannel subscribeToLocationUpdates(
    Function(DeliveryPersonnel) onInsert,
    Function(DeliveryPersonnel) onUpdate,
    Function(String) onDelete,
  ) {
    final channel = _supabase
        .channel('delivery_personnel_locations')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'delivery_personnel',
          callback: (payload) {
            try {
              final person = DeliveryPersonnel.fromJson(payload.newRecord);
              if (person.hasLocation) {
                onInsert(person);
              }
            } catch (e) {
              print('Error processing insert: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'delivery_personnel',
          callback: (payload) {
            try {
              final person = DeliveryPersonnel.fromJson(payload.newRecord);
              if (person.hasLocation) {
                onUpdate(person);
              }
            } catch (e) {
              print('Error processing update: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'delivery_personnel',
          callback: (payload) {
            try {
              final userId = payload.oldRecord['user_id'] as String;
              onDelete(userId);
            } catch (e) {
              print('Error processing delete: $e');
            }
          },
        )
        .subscribe();

    return channel;
  }

  /// Unsubscribe from real-time updates
  Future<void> unsubscribeFromLocationUpdates(RealtimeChannel channel) async {
    try {
      await _supabase.removeChannel(channel);
    } catch (e) {
      print('Error unsubscribing: $e');
    }
  }

  /// Update delivery personnel location (for testing or manual updates)
  Future<DeliveryPersonnel> updateLocation(
    String userId,
    double latitude,
    double longitude,
  ) async {
    try {
      // Supabase PostGIS expects POINT(longitude latitude) format
      final response = await _supabase
          .from('delivery_personnel')
          .update({
            'current_location': 'POINT($longitude $latitude)',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .select()
          .single();

      return DeliveryPersonnel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update location: ${e.toString()}');
    }
  }

  /// Fetch delivery personnel near a location (requires PostGIS functions)
  Future<List<DeliveryPersonnel>> fetchNearbyDeliveryPersonnel({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      // Using PostGIS ST_DWithin for proximity search
      // Note: 111.32 km ≈ 1 degree at equator
      final _ = radiusKm / 111.32;
      
      final response = await _supabase.rpc(
        'find_nearby_delivery_personnel',
        params: {
          'lat': latitude,
          'lng': longitude,
          'radius_km': radiusKm,
        },
      );

      return (response as List)
          .map((json) => DeliveryPersonnel.fromJson(json))
          .where((person) => person.hasLocation)
          .toList();
    } catch (e) {
      print('Error fetching nearby personnel (falling back to all): $e');
      // Fallback: return all personnel with location
      return fetchDeliveryPersonnelWithLocation();
    }
  }

}