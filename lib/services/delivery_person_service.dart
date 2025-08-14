// services/delivery_personnel_service.dart (Fixed)
import 'package:naivedhya/models/simple_delivery_person_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeliveryPersonnelService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<SimpleDeliveryPersonnel>> fetchAvailableDeliveryPersonnel() async {
    try {
      final response = await _supabase
          .from('delivery_personnel')
          .select()
          .eq('is_available', true)
          .eq('is_verified', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => SimpleDeliveryPersonnel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch delivery personnel: ${e.toString()}');
    }
  }

  Future<List<SimpleDeliveryPersonnel>> fetchAllDeliveryPersonnel() async {
    try {
      final response = await _supabase
          .from('delivery_personnel')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => SimpleDeliveryPersonnel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch delivery personnel: ${e.toString()}');
    }
  }

  Future<SimpleDeliveryPersonnel?> fetchDeliveryPersonnelById(String userId) async {
    try {
      final response = await _supabase
          .from('delivery_personnel')
          .select()
          .eq('user_id', userId)
          .single();

      return SimpleDeliveryPersonnel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch delivery personnel: ${e.toString()}');
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

  Future<List<SimpleDeliveryPersonnel>> searchDeliveryPersonnel({
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
          .map((json) => SimpleDeliveryPersonnel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search delivery personnel: ${e.toString()}');
    }
  }

  Future<SimpleDeliveryPersonnel> updateDeliveryPersonnelAvailability(
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

      return SimpleDeliveryPersonnel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update delivery personnel availability: ${e.toString()}');
    }
  }

  Stream<List<SimpleDeliveryPersonnel>> getDeliveryPersonnelStream() {
    return _supabase
        .from('delivery_personnel')
        .stream(primaryKey: ['user_id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => SimpleDeliveryPersonnel.fromJson(json)).toList());
  }
}