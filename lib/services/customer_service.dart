// services/customer_service.dart
import 'package:naivedhya/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all customers
  Future<List<UserModel>> getAllCustomers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch customers: $e');
    }
  }

  // Search customers by name or email
  Future<List<UserModel>> searchCustomers(String query) async {
    if (query.isEmpty) return getAllCustomers();

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .or('name.ilike.%$query%,email.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search customers: $e');
    }
  }

  // Get customer by ID
  Future<UserModel?> getCustomerById(String id) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch customer: $e');
    }
  }

  // Update customer
  Future<UserModel> updateCustomer(String id, Map<String, dynamic> updates) async {
    try {
      // Add updated_at timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  // Delete customer
  Future<void> deleteCustomer(String id) async {
    try {
      await _supabase
          .from('profiles')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }

  // Get customers with pending payments
  Future<List<UserModel>> getCustomersWithPendingPayments() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .gt('pending_payments', 0)
          .order('pending_payments', ascending: false);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch customers with pending payments: $e');
    }
  }

  // Get customer statistics
  Future<Map<String, dynamic>> getCustomerStats() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('pending_payments, orderhistory');

      int totalCustomers = response.length;
      double totalPendingPayments = 0;
      int totalOrders = 0;

      for (var customer in response) {
        totalPendingPayments += (customer['pending_payments'] ?? 0).toDouble();
        if (customer['orderhistory'] != null) {
          totalOrders += (customer['orderhistory'] as List).length;
        }
      }

      return {
        'totalCustomers': totalCustomers,
        'totalPendingPayments': totalPendingPayments,
        'totalOrders': totalOrders,
        'averageOrdersPerCustomer': totalCustomers > 0 ? totalOrders / totalCustomers : 0,
      };
    } catch (e) {
      throw Exception('Failed to fetch customer statistics: $e');
    }
  }
}