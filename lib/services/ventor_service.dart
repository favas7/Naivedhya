
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
          .eq('Hotel_id', restaurantId)
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
}