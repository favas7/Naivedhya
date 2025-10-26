
import 'package:naivedhya/models/ventor_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VendorService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'vendors';

  Future<Vendor> createVendor(Vendor vendor) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert(vendor.toJson())
          .select()
          .single();

      return Vendor.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create vendor: $e');
    }
  }

  Future<List<Vendor>> getVendorsByRestaurant(String restaurantId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('hotel_id', restaurantId)
          .eq('is_active', true);

      return (response as List<dynamic>)
          .map((json) => Vendor.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch vendors: $e');
    }
  }

  Future<Vendor> updateVendor(Vendor vendor) async {
    try {
      if (vendor.id == null) {
        throw Exception('Vendor ID is required for update');
      }

      final response = await _supabase
          .from(_tableName)
          .update(vendor.toJson())
          .eq('vendor_id', vendor.id!)
          .select()
          .single();

      return Vendor.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update vendor: $e');
    }
  }

  Future<void> deleteVendor(String vendorId) async {
    try {
      await _supabase
          .from(_tableName)
          .update({'is_active': false})
          .eq('vendor_id', vendorId);
    } catch (e) {
      throw Exception('Failed to delete vendor: $e');
    }
  }

 /// Fetch vendor by ID with full details
  Future<Map<String, dynamic>?> fetchVendorById(String vendorId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            vendor_id,
            name,
            email,
            phone,
            service_type,
            hotel_id,
            is_active
          ''')
          .eq('vendor_id', vendorId)
          .maybeSingle();

      if (response == null) return null;

      return {
        'id': response['vendor_id'],
        'name': response['name'] ?? 'Unknown Vendor',
        'email': response['email'],
        'phone': response['phone'],
        'serviceType': response['service_type'],
        'hotelId': response['hotel_id'],
        'isActive': response['is_active'] ?? true,
      };
    } catch (e) {
      print('Error fetching vendor: $e');
      return null;
    }
  }

  /// Get vendor name only by ID
  Future<String> getVendorNameById(String vendorId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('name')
          .eq('vendor_id', vendorId)
          .maybeSingle();

      return response?['name'] ?? 'Unknown Vendor';
    } catch (e) {
      print('Error fetching vendor name: $e');
      return 'Unknown Vendor';
    }
  }

  /// Fetch vendors by restaurant/hotel ID
  Future<List<Map<String, dynamic>>> fetchVendorsByRestaurant(
      String restaurantId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            vendor_id,
            name,
            email,
            phone,
            service_type,
            is_active
          ''')
          .eq('hotel_id', restaurantId)
          .eq('is_active', true);

      return List<Map<String, dynamic>>.from(response );
    } catch (e) {
      print('Error fetching vendors: $e');
      return [];
    }
  }

  /// Fetch all active vendors
  Future<List<Map<String, dynamic>>> fetchAllActiveVendors() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            vendor_id,
            name,
            email,
            phone,
            service_type,
            hotel_id
          ''')
          .eq('is_active', true)
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching all vendors: $e');
      return [];
    }
  }

  /// Search vendors by name
  Future<List<Map<String, dynamic>>> searchVendors(String query) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            vendor_id,
            name,
            email,
            phone,
            service_type
          ''')
          .ilike('name', '%$query%')
          .eq('is_active', true)
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error searching vendors: $e');
      return [];
    }
  }

  /// Fetch vendor with contact info
  Future<Map<String, dynamic>?> getVendorContactInfo(String vendorId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('name, email, phone, service_type')
          .eq('vendor_id', vendorId)
          .maybeSingle();

      if (response == null) return null;

      return {
        'name': response['name'],
        'email': response['email'],
        'phone': response['phone'],
        'serviceType': response['service_type'],
      };
    } catch (e) {
      print('Error fetching vendor contact info: $e');
      return null;
    }
  }

  // /// Create new vendor (admin only)
  // Future<Map<String, dynamic>?> createVendor({
  //   required String hotelId,
  //   required String name,
  //   required String serviceType,
  //   String? email,
  //   String? phone,
  // }) async {
  //   try {
  //     final response = await _supabase
  //         .from(_tableName)
  //         .insert({
  //           'hotel_id': hotelId,
  //           'name': name,
  //           'service_type': serviceType,
  //           'email': email,
  //           'phone': phone,
  //           'is_active': true,
  //         })
  //         .select()
  //         .single();

  //     return {
  //       'id': response['vendor_id'],
  //       'name': response['name'],
  //       'email': response['email'],
  //       'phone': response['phone'],
  //       'serviceType': response['service_type'],
  //     };
  //   } catch (e) {
  //     print('Error creating vendor: $e');
  //     return null;
  //   }
  // }

  // /// Update vendor
  // Future<bool> updateVendor(
  //   String vendorId, {
  //   String? name,
  //   String? email,
  //   String? phone,
  //   String? serviceType,
  //   bool? isActive,
  // }) async {
  //   try {
  //     final updates = <String, dynamic>{};
  //     if (name != null) updates['name'] = name;
  //     if (email != null) updates['email'] = email;
  //     if (phone != null) updates['phone'] = phone;
  //     if (serviceType != null) updates['service_type'] = serviceType;
  //     if (isActive != null) updates['is_active'] = isActive;

  //     await _supabase.from(_tableName).update(updates).eq('vendor_id', vendorId);
  //     return true;
  //   } catch (e) {
  //     print('Error updating vendor: $e');
  //     return false;
  //   }
  // }

  /// Deactivate vendor
  Future<bool> deactivateVendor(String vendorId) async {
    try {
      await _supabase
          .from(_tableName)
          .update({'is_active': false}).eq('vendor_id', vendorId);
      return true;
    } catch (e) {
      print('Error deactivating vendor: $e');
      return false;
    }
  }

  /// Stream vendor data for real-time updates
  Stream<Map<String, dynamic>?> streamVendor(String vendorId) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['vendor_id'])
        .eq('vendor_id', vendorId)
        .map((data) {
          if (data.isEmpty) return null;
          final vendor = data[0];
          return {
            'id': vendor['vendor_id'],
            'name': vendor['name'] ?? 'Unknown',
            'email': vendor['email'],
            'phone': vendor['phone'],
            'serviceType': vendor['service_type'],
          };
        });
  }

    getVendorDetails(String vendorId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('vendor_id', vendorId)
          .single();

      return Vendor.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch vendor details: $e');
    }
  
}
}