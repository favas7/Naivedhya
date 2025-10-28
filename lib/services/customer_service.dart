// services/customer_service.dart - FIXED VERSION
import 'package:naivedhya/models/customer_model.dart';
import 'package:naivedhya/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart'; // ✅ Import uuid package

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

  // Search customers by name, email, or mobile (only users with usertype 'user')
  Future<List<UserModel>> searchCustomers(String query) async {
    if (query.isEmpty) return getAllCustomers();

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('usertype', 'user') // Filter to only show users, not admins
          .or('name.ilike.%$query%,email.ilike.%$query%,phone.ilike.%$query%')
          .limit(10)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search customers: $e');
    }
  }

  // ✅ FIXED: Create a new customer profile with proper ID generation
  Future<UserModel> createCustomer({
    required String name,
    required String mobile,
    required String address,
    String? email,
  }) async {
    try {
      // ✅ Generate a unique ID for the customer
      final customerId = const Uuid().v4();
      
      print('🆔 [CustomerService] Generated customer ID: $customerId');
      
      final now = DateTime.now();
      
      final customerData = {
        'id': customerId,              // ✅ Must provide ID
        'name': name,
        'phone': mobile,
        'address': address,
        'email': email ?? '',          // Default to empty string if null
        'dob': '',                     // Default empty
        'usertype': 'user',            // Ensure it's marked as a user
        'pendingpayments': 0.0,
        'orderhistory': [],
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      
      print('📝 [CustomerService] Creating customer with data: $customerData');

      final response = await _supabase
          .from('profiles')
          .insert(customerData)
          .select()
          .single();

      print('✅ [CustomerService] Customer created successfully: $customerId');
      
      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ [CustomerService] Error creating customer: $e');
      throw Exception('Failed to create customer: $e');
    }
  }

  // Get customer by ID (only if usertype is 'user')
  Future<UserModel?> getCustomerById(String customerId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', customerId)
          .eq('usertype', 'user') // Ensure we only get users, not admins
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      return null;
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
          .gt('pendingpayments', 0)
          .order('pendingpayments', ascending: false);

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
          .select('pendingpayments, orderhistory')
          .eq('usertype', 'user'); // Only calculate stats for users, not admins

      int totalCustomers = response.length;
      double totalPendingPayments = 0;
      int totalOrders = 0;

      for (var customer in response) {
        totalPendingPayments += (customer['pendingpayments'] ?? 0).toDouble();
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

  // Convert UserModel to Customer (for compatibility)
  List<Customer> convertToCustomers(List<UserModel> userModels) {
    return userModels.map((userModel) => Customer.fromUserModel(userModel)).toList();
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