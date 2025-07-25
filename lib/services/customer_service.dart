// services/customer_service.dart
import 'package:naivedhya/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all customers (only users with usertype 'user')
  Future<List<UserModel>> getAllCustomers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('usertype', 'user') // Filter to only show users, not admins
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch customers: $e');
    }
  }

  // Search customers by name or email (only users with usertype 'user')
  Future<List<UserModel>> searchCustomers(String query) async {
    if (query.isEmpty) return getAllCustomers();

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('usertype', 'user') // Filter to only show users, not admins
          .or('name.ilike.%$query%,email.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search customers: $e');
    }
  }

  // Get customer by ID (only if usertype is 'user')
  Future<UserModel?> getCustomerById(String id) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', id)
          .eq('usertype', 'user') // Ensure we only get users, not admins
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch customer: $e');
    }
  }

  // Update customer (only if usertype is 'user')
  Future<UserModel> updateCustomer(String id, Map<String, dynamic> updates) async {
    try {
      // Add updated_at timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', id)
          .eq('usertype', 'user') // Ensure we only update users, not admins
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  // Delete customer (only if usertype is 'user')
  Future<void> deleteCustomer(String id) async {
    try {
      await _supabase
          .from('profiles')
          .delete()
          .eq('id', id)
          .eq('usertype', 'user'); // Ensure we only delete users, not admins
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }

  // Get customers with pending payments (only users with usertype 'user')
  Future<List<UserModel>> getCustomersWithPendingPayments() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('usertype', 'user') // Filter to only show users, not admins
          .gt('pending_payments', 0)
          .order('pending_payments', ascending: false);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch customers with pending payments: $e');
    }
  }

  // Get customer statistics (only for users with usertype 'user')
  Future<Map<String, dynamic>> getCustomerStats() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('pending_payments, orderhistory')
          .eq('usertype', 'user'); // Only calculate stats for users, not admins

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

  // Optional: Get all profiles including admins (if needed for admin management)
  Future<List<UserModel>> getAllProfiles() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all profiles: $e');
    }
  }

  // Optional: Get only admin profiles (if needed for admin management)
  Future<List<UserModel>> getAllAdmins() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('usertype', 'admin')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch admins: $e');
    }
  }
} 