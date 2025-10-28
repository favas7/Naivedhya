// services/address_service.dart
import 'package:naivedhya/models/address_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddressService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'addresses';

  /// Get all addresses for a user
  Future<List<Address>> getAddressesByUserId(String userId) async {
    try {
      print('🔍 [AddressService] Fetching addresses for user: $userId');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('isdefault', ascending: false)
          .order('created_at', ascending: false);

      print('✅ [AddressService] Found ${(response as List).length} addresses');

      return (response).map((json) => Address.fromJson(json)).toList();
    } catch (e) {
      print('❌ [AddressService] Error fetching addresses: $e');
      throw Exception('Failed to fetch addresses: $e');
    }
  }

  /// Get default address for a user
  Future<Address?> getDefaultAddress(String userId) async {
    try {
      print('🔍 [AddressService] Fetching default address for user: $userId');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('isdefault', true)
          .maybeSingle();

      if (response == null) {
        print('⚠️ [AddressService] No default address found');
        return null;
      }

      print('✅ [AddressService] Default address found');
      return Address.fromJson(response);
    } catch (e) {
      print('❌ [AddressService] Error fetching default address: $e');
      return null;
    }
  }

  /// Get address by ID
  Future<Address?> getAddressById(String addressId) async {
    try {
      print('🔍 [AddressService] Fetching address by ID: $addressId');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('addressid', addressId)
          .maybeSingle();

      if (response == null) {
        print('⚠️ [AddressService] Address not found');
        return null;
      }

      print('✅ [AddressService] Address found');
      return Address.fromJson(response);
    } catch (e) {
      print('❌ [AddressService] Error fetching address: $e');
      return null;
    }
  }

  /// Create new address
  Future<Address> createAddress(Address address) async {
    try {
      print('➕ [AddressService] Creating new address for user: ${address.userId}');

      // If this is being set as default, unset other defaults first
      if (address.isDefault) {
        await _unsetOtherDefaults(address.userId);
      }

      final response = await _supabase
          .from(_tableName)
          .insert(address.toJson())
          .select()
          .single();

      print('✅ [AddressService] Address created successfully');
      return Address.fromJson(response);
    } catch (e) {
      print('❌ [AddressService] Error creating address: $e');
      throw Exception('Failed to create address: $e');
    }
  }

  /// Update existing address
  Future<Address> updateAddress(String addressId, Address address) async {
    try {
      print('📝 [AddressService] Updating address: $addressId');

      // If this is being set as default, unset other defaults first
      if (address.isDefault) {
        await _unsetOtherDefaults(address.userId);
      }

      final response = await _supabase
          .from(_tableName)
          .update(address.toJson())
          .eq('addressid', addressId)
          .select()
          .single();

      print('✅ [AddressService] Address updated successfully');
      return Address.fromJson(response);
    } catch (e) {
      print('❌ [AddressService] Error updating address: $e');
      throw Exception('Failed to update address: $e');
    }
  }

  /// Delete address
  Future<bool> deleteAddress(String addressId) async {
    try {
      print('🗑️ [AddressService] Deleting address: $addressId');

      await _supabase.from(_tableName).delete().eq('addressid', addressId);

      print('✅ [AddressService] Address deleted successfully');
      return true;
    } catch (e) {
      print('❌ [AddressService] Error deleting address: $e');
      return false;
    }
  }

  /// Set address as default
  Future<bool> setDefaultAddress(String userId, String addressId) async {
    try {
      print('🔄 [AddressService] Setting address as default: $addressId');

      // First, unset all other defaults
      await _unsetOtherDefaults(userId);

      // Then set this one as default
      await _supabase
          .from(_tableName)
          .update({'isdefault': true})
          .eq('addressid', addressId);

      print('✅ [AddressService] Default address set successfully');
      return true;
    } catch (e) {
      print('❌ [AddressService] Error setting default address: $e');
      return false;
    }
  }

  /// Unset all other default addresses for a user (private helper)
  Future<void> _unsetOtherDefaults(String userId) async {
    try {
      await _supabase
          .from(_tableName)
          .update({'isdefault': false})
          .eq('user_id', userId)
          .eq('isdefault', true);
    } catch (e) {
      print('⚠️ [AddressService] Warning: Could not unset other defaults: $e');
    }
  }

  /// Search addresses by text
  Future<List<Address>> searchAddresses(String userId, String query) async {
    try {
      print('🔍 [AddressService] Searching addresses for: $query');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .or('label.ilike.%$query%,fulladdress.ilike.%$query%')
          .order('isdefault', ascending: false)
          .order('created_at', ascending: false);

      print('✅ [AddressService] Found ${(response as List).length} addresses');

      return (response).map((json) => Address.fromJson(json)).toList();
    } catch (e) {
      print('❌ [AddressService] Error searching addresses: $e');
      return [];
    }
  }

  /// Get address count for a user
  Future<int> getAddressCount(String userId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('addressid')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      print('❌ [AddressService] Error getting address count: $e');
      return 0;
    }
  }
}