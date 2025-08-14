import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:naivedhya/models/manager.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

class ManagerService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Storage bucket name - make sure this exists in Supabase
  static const String _bucketName = 'manager-images';

  Future<List<Manager>> getAllManagers() async {
    try {
      final response = await _supabase
          .from('managers')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Manager.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load managers: $e');
    }
  }

  Future<String> addManager(Manager manager) async {
    try {
      final response = await _supabase
          .from('managers')
          .insert(manager.toJson())
          .select()
          .single();
      
      return response['manager_id'] as String;
    } catch (e) {
      throw Exception('Failed to add manager: $e');
    }
  }

  Future<String?> addManagerAndUpdateHotel(Manager manager, String hotelId) async {
    try {
      final managerData = manager.toJson();
      managerData.remove('hotel_id');
      
      final managerResponse = await _supabase
          .from('managers')
          .insert(managerData)
          .select()
          .single();

      final managerId = managerResponse['manager_id'] as String;

      await _supabase
          .from('hotels')
          .update({
            'manager_id': managerId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('hotel_id', hotelId);

      await _supabase
          .from('managers')
          .update({
            'hotel_id': hotelId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('manager_id', managerId);

      return managerId;
    } catch (e) {
      throw Exception('Failed to add manager and update hotel: $e');
    }
  }

  Future<void> updateManager(Manager manager) async {
    try {
      if (manager.id == null || manager.id!.isEmpty) {
        throw Exception('Manager ID is required for update operation');
      }

      final updateData = manager.toUpdateJson();
      
      final response = await _supabase
          .from('managers')
          .update(updateData)
          .eq('manager_id', manager.id!)
          .select();
      
      if (response.isEmpty) {
        throw Exception('No manager found with ID: ${manager.id}');
      }
      
    } catch (e) {
      throw Exception('Failed to update manager: $e');
    }
  }

  Future<void> deleteManager(String managerId) async {
    try {
      // First get the manager to check if they have an image
      final manager = await getManagerById(managerId);
      
      // Delete the image if it exists
      if (manager?.imageUrl != null && manager!.imageUrl!.isNotEmpty) {
        await deleteManagerImage(manager.imageUrl!);
      }
      
      // Then delete the manager record
      await _supabase
          .from('managers')
          .delete()
          .eq('manager_id', managerId);
    } catch (e) {
      throw Exception('Failed to delete manager: $e');
    }
  }

  Future<Manager?> getManagerById(String managerId) async {
    try {
      final response = await _supabase
          .from('managers')
          .select()
          .eq('manager_id', managerId)  // Fixed: Use manager_id consistently
          .maybeSingle();
      
      if (response != null) {
        return Manager.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get manager: $e');
    }
  }

  Future<Manager?> getManagerByHotelId(String hotelId) async {
    try {
      final response = await _supabase
          .from('managers')
          .select()
          .eq('hotel_id', hotelId)
          .maybeSingle();
      
      if (response != null) {
        return Manager.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get manager by hotel ID: $e');
    }
  }

  // Image upload functionality
  Future<String> uploadManagerImage(File imageFile, String managerId) async {
    try {
      print('Starting image upload for manager: $managerId');
      
      // First, ensure the bucket exists
      await _ensureBucketExists();
      
      // Compress the image before upload
      final compressedImage = await _compressImage(imageFile);
      print('Image compressed, size: ${compressedImage.length} bytes');
      
      // Generate unique filename
      final fileExtension = path.extension(imageFile.path).toLowerCase();
      final fileName = '${managerId}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final filePath = 'managers/$fileName';
      print('Uploading to path: $filePath');

      // Upload to Supabase Storage
      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(filePath, compressedImage,
              fileOptions: FileOptions(
                cacheControl: '3600',
                upsert: true, // This allows overwriting existing files
              ));
      
      print('Upload successful');

      // Get public URL
      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);
      print('Generated URL: $publicUrl');

      return publicUrl;
    } catch (e) {
      print('Upload failed: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String> uploadManagerImageFromBytes(Uint8List imageBytes, String managerId, String fileName) async {
    try {
      print('Starting image upload from bytes for manager: $managerId');
      
      // First, ensure the bucket exists
      await _ensureBucketExists();
      
      // Compress the image before upload
      final compressedImage = await _compressImageFromBytes(imageBytes);
      print('Image compressed, size: ${compressedImage.length} bytes');
      
      // Generate unique filename
      final fileExtension = path.extension(fileName).toLowerCase();
      final uniqueFileName = '${managerId}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final filePath = 'managers/$uniqueFileName';
      print('Uploading to path: $filePath');

      // Upload to Supabase Storage
      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(filePath, compressedImage,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ));

      print('Upload successful');

      // Get public URL
      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);
      print('Generated URL: $publicUrl');

      return publicUrl;
    } catch (e) {
      print('Upload from bytes failed: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteManagerImage(String imageUrl) async {
    try {
      print('Attempting to delete image: $imageUrl');
      
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      // Find the path after the bucket name in the URL
      // URL format: https://xxx.supabase.co/storage/v1/object/public/manager-images/managers/filename
      int startIndex = -1;
      for (int i = 0; i < pathSegments.length; i++) {
        if (pathSegments[i] == _bucketName && i < pathSegments.length - 1) {
          startIndex = i + 1;
          break;
        }
      }
      
      if (startIndex != -1) {
        final filePath = pathSegments.sublist(startIndex).join('/');
        print('Deleting file path: $filePath');
        
        await _supabase.storage
            .from(_bucketName)
            .remove([filePath]);
        
        print('Image deleted successfully');
      } else {
        print('Could not extract file path from URL');
      }
    } catch (e) {
      // Don't throw error for image deletion failure - just log it
      print('Warning: Failed to delete image: $e');
    }
  }

  Future<String> updateManagerImage(String managerId, File newImageFile, String? oldImageUrl) async {
    try {
      print('Updating manager image for: $managerId');
      
      // Upload new image first
      final newImageUrl = await uploadManagerImage(newImageFile, managerId);
      
      // Delete old image if exists (do this after successful upload)
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        await deleteManagerImage(oldImageUrl);
      }
      
      return newImageUrl;
    } catch (e) {
      print('Failed to update image: $e');
      throw Exception('Failed to update image: $e');
    }
  }

  // Helper method to ensure bucket exists
  Future<void> _ensureBucketExists() async {
    try {
      // Try to get bucket info
      await _supabase.storage.getBucket(_bucketName);
      print('Bucket $_bucketName exists');
    } catch (e) {
      print('Bucket $_bucketName might not exist or is not accessible: $e');
      // You can create bucket programmatically if it doesn't exist
      // But usually it's better to create it manually in Supabase dashboard
      throw Exception('Storage bucket "$_bucketName" is not accessible. Please ensure it exists and has proper permissions.');
    }
  }

  // Image compression helper
  Future<Uint8List> _compressImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return await _compressImageFromBytes(bytes);
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }

  Future<Uint8List> _compressImageFromBytes(Uint8List bytes) async {
    try {
      // Decode image
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if too large (max width/height: 800px)
      if (image.width > 800 || image.height > 800) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? 800 : null,
          height: image.height > image.width ? 800 : null,
        );
      }

      // Compress as JPEG with 85% quality
      final compressedBytes = img.encodeJpg(image, quality: 85);
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }

  // Helper method to update manager with new image URL
  Future<void> updateManagerImageUrl(String managerId, String imageUrl) async {
    try {
      print('Updating manager image URL in database: $managerId -> $imageUrl');
      
      final response = await _supabase
          .from('managers')
          .update({
            'image_url': imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('manager_id', managerId)
          .select();
      
      if (response.isEmpty) {
        throw Exception('No manager found with ID: $managerId');
      }
      
      print('Manager image URL updated successfully');
    } catch (e) {
      print('Failed to update manager image URL: $e');
      throw Exception('Failed to update manager image URL: $e');
    }
  }
}