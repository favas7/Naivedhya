// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:naivedhya/Views/admin/restaurant/manager/add_manager_dialogue.dart';
// import 'package:naivedhya/Views/admin/restaurant/manager/edit_manager.dart';
// import 'package:naivedhya/models/restaurant_model.dart';
// import 'package:naivedhya/services/restaurant_service.dart';
// import 'package:naivedhya/utils/color_theme.dart';
// import 'package:naivedhya/models/manager.dart';
// import 'package:naivedhya/services/manager_service.dart';

// class ManagerDetailScreen extends StatefulWidget {
//   final Restaurant restaurant;
//   final VoidCallback? onManagersUpdated;

//   const ManagerDetailScreen({
//     super.key,
//     required this.restaurant,
//     this.onManagersUpdated,
//   });

//   @override
//   State<ManagerDetailScreen> createState() => _ManagerDetailScreenState();
// }

// class _ManagerDetailScreenState extends State<ManagerDetailScreen> {
//   final RestaurantService _supabaseService = RestaurantService();
//   final ManagerService _managerService = ManagerService();
//   final ImagePicker _imagePicker = ImagePicker();
  
//   List<Manager> _managers = [];
//   bool _isLoading = true;
//   String? _error;
//   final Map<String, bool> _uploadingImages = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadManagers();
//   }

//   Future<void> _loadManagers() async {
//     if (widget.restaurant.id == null) return;

//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final managers = await _supabaseService.getManagers(widget.restaurant.id!);
//       if (mounted) {
//         setState(() {
//           _managers = managers;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _error = e.toString();
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _refreshManagers() async {
//     await _loadManagers();
//     widget.onManagersUpdated?.call();
//   }

//   void _showAddManagerDialog() async {
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) => AddManagerDialog(restaurant: widget.restaurant),
//     );
    
//     if (result == true) {
//       _refreshManagers();
//     }
//   }

//   void _showEditManagerDialog(Manager manager) async {
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) => EditManagerDialog(
//         manager: manager,
//         restaurant: widget.restaurant,
//       ),
//     );
    
//     if (result == true) {
//       _refreshManagers();
//     }
//   }

//   void _showDeleteConfirmation(Manager manager) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Manager'),
//         content: Text('Are you sure you want to delete "${manager.name}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _deleteManager(manager);
//             },
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _deleteManager(Manager manager) async {
//     if (manager.id == null) return;

//     try {
//       await _managerService.deleteManager(manager.id!);
//       _refreshManagers();
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${manager.name} deleted successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error deleting manager: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   void _showImageOptions(Manager manager) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'Select Profile Picture',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildImageOption(
//                       icon: Icons.camera_alt,
//                       label: 'Camera',
//                       onTap: () {
//                         Navigator.pop(context);
//                         _pickImage(ImageSource.camera, manager);
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: _buildImageOption(
//                       icon: Icons.photo_library,
//                       label: 'Gallery',
//                       onTap: () {
//                         Navigator.pop(context);
//                         _pickImage(ImageSource.gallery, manager);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               if (manager.imageUrl != null && manager.imageUrl!.isNotEmpty) ...[
//                 const SizedBox(height: 16),
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton.icon(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       _removeImage(manager);
//                     },
//                     icon: const Icon(Icons.delete, color: Colors.red),
//                     label: const Text(
//                       'Remove Picture',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(color: Colors.red),
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildImageOption({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 20),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey[300]!),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, size: 32, color: AppTheme.primary),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _pickImage(ImageSource source, Manager manager) async {
//     try {
//       final XFile? image = await _imagePicker.pickImage(
//         source: source,
//         maxWidth: 800,
//         maxHeight: 800,
//         imageQuality: 85,
//       );

//       if (image != null && manager.id != null) {
//         await _uploadImage(File(image.path), manager);
//       }
//     } catch (e) {
//       print('Error selecting image: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error selecting image: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _uploadImage(File imageFile, Manager manager) async {
//     if (manager.id == null) {
//       _showError('Manager ID is null - cannot upload image');
//       return;
//     }

//     setState(() {
//       _uploadingImages[manager.id!] = true;
//     });

//     try {
//       print('Starting image upload for manager: ${manager.id}');
//       print('Manager name: ${manager.name}');
//       print('Image file path: ${imageFile.path}');
      
//       // Check if file exists
//       if (!await imageFile.exists()) {
//         throw Exception('Selected image file does not exist');
//       }
      
//       // Check file size
//       final fileSize = await imageFile.length();
//       print('File size: $fileSize bytes');
      
//       if (fileSize > 10 * 1024 * 1024) { // 10MB limit
//         throw Exception('Image file is too large (max 10MB)');
//       }

//       // Upload image and get URL
//       final imageUrl = await _managerService.uploadManagerImage(imageFile, manager.id!);
//       print('Image uploaded successfully: $imageUrl');
      
//       // Update manager with new image URL
//       await _managerService.updateManagerImageUrl(manager.id!, imageUrl);
//       print('Manager image URL updated in database');

//       // Refresh the managers list
//       await _refreshManagers();

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Profile picture updated successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       print('Upload error: $e');
//       if (mounted) {
//         _showError('Error uploading image: ${e.toString()}');
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _uploadingImages.remove(manager.id!);
//         });
//       }
//     }
//   }

//   Future<void> _removeImage(Manager manager) async {
//     if (manager.id == null || manager.imageUrl == null) return;

//     try {
//       // Delete image from storage
//       await _managerService.deleteManagerImage(manager.imageUrl!);
      
//       // Update manager to remove image URL
//       await _managerService.updateManagerImageUrl(manager.id!, '');

//       // Refresh the managers list
//       await _refreshManagers();

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Profile picture removed successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         _showError('Error removing image: ${e.toString()}');
//       }
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 5),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${widget.restaurant.name} - Managers'),
//         backgroundColor: AppTheme.primary,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             onPressed: _refreshManagers,
//             icon: const Icon(Icons.refresh),
//             tooltip: 'Refresh',
//           ),
//         ],
//       ),
//       body: _buildBody(),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddManagerDialog,
//         backgroundColor: AppTheme.primary,
//         foregroundColor: Colors.white,
//         tooltip: 'Add Manager',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('Loading managers...'),
//           ],
//         ),
//       );
//     }

//     if (_error != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline,
//               size: 64,
//               color: Colors.red[300],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               _error!,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.red,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _refreshManagers,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppTheme.primary,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_managers.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.person_outline,
//               size: 64,
//               color: Colors.grey[400],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No managers found',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Add your first manager for ${widget.restaurant.name}',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[500],
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: _showAddManagerDialog,
//               icon: const Icon(Icons.add),
//               label: const Text('Add Manager'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppTheme.primary,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 12,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: _refreshManagers,
//       color: AppTheme.primary,
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: _managers.length,
//         itemBuilder: (context, index) {
//           final manager = _managers[index];
//           return _buildManagerCard(manager);
//         },
//       ),
//     );
//   }

//   Widget _buildManagerCard(Manager manager) {
//     final isUploadingImage = _uploadingImages[manager.id] ?? false;
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Stack(
//                   children: [
//                     GestureDetector(
//                       onTap: () => _showImageOptions(manager),
//                       child: manager.imageUrl != null && manager.imageUrl!.isNotEmpty
//                           ? CircleAvatar(
//                               radius: 30,
//                               backgroundColor: AppTheme.primary,
//                               foregroundColor: Colors.white,
//                               backgroundImage: NetworkImage(manager.imageUrl!),
//                               onBackgroundImageError: (exception, stackTrace) {
//                                 print('Error loading image: $exception');
//                               },
//                             )
//                           : CircleAvatar(
//                               radius: 30,
//                               backgroundColor: AppTheme.primary,
//                               foregroundColor: Colors.white,
//                               child: Text(
//                                 manager.name.isNotEmpty 
//                                     ? manager.name[0].toUpperCase() 
//                                     : 'M',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 20,
//                                 ),
//                               ),
//                             ),
//                     ),
//                     if (isUploadingImage)
//                       Positioned.fill(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.black54,
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           child: const Center(
//                             child: SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor: AlwaysStoppedAnimation<Color>(
//                                   Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: GestureDetector(
//                         onTap: () => _showImageOptions(manager),
//                         child: Container(
//                           padding: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: AppTheme.primary,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: Colors.white, width: 2),
//                           ),
//                           child: const Icon(
//                             Icons.camera_alt,
//                             size: 12,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         manager.name,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Manager ID: ${manager.id ?? 'N/A'}',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 PopupMenuButton<String>(
//                   onSelected: (value) {
//                     switch (value) {
//                       case 'edit':
//                         _showEditManagerDialog(manager);
//                         break;
//                       case 'delete':
//                         _showDeleteConfirmation(manager);
//                         break;
//                       case 'change_image':
//                         _showImageOptions(manager);
//                         break;
//                     }
//                   },
//                   itemBuilder: (context) => [
//                     const PopupMenuItem(
//                       value: 'edit',
//                       child: Row(
//                         children: [
//                           Icon(Icons.edit, size: 16),
//                           SizedBox(width: 8),
//                           Text('Edit'),
//                         ],
//                       ),
//                     ),
//                     const PopupMenuItem(
//                       value: 'change_image',
//                       child: Row(
//                         children: [
//                           Icon(Icons.photo_camera, size: 16),
//                           SizedBox(width: 8),
//                           Text('Change Photo'),
//                         ],
//                       ),
//                     ),
//                     const PopupMenuItem(
//                       value: 'delete',
//                       child: Row(
//                         children: [
//                           Icon(Icons.delete, size: 16, color: Colors.red),
//                           SizedBox(width: 8),
//                           Text('Delete', style: TextStyle(color: Colors.red)),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             _buildInfoRow(Icons.email, 'Email', manager.email),
//             const SizedBox(height: 8),
//             _buildInfoRow(Icons.phone, 'Phone', manager.phone),
//             if (manager.createdAt != null) ...[
//               const SizedBox(height: 8),
//               _buildInfoRow(
//                 Icons.calendar_today,
//                 'Added',
//                 _formatDateTime(manager.createdAt!),
//               ),
//             ],
//             if (manager.updatedAt != null && manager.updatedAt != manager.createdAt) ...[
//               const SizedBox(height: 8),
//               _buildInfoRow(
//                 Icons.update,
//                 'Updated',
//                 _formatDateTime(manager.updatedAt!),
//               ),
//             ],
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () => _showEditManagerDialog(manager),
//                     icon: const Icon(Icons.edit, size: 16),
//                     label: const Text('Edit'),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: AppTheme.primary,
//                       side: const BorderSide(color: AppTheme.primary),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () => _showDeleteConfirmation(manager),
//                     icon: const Icon(Icons.delete, size: 16),
//                     label: const Text('Delete'),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.red,
//                       side: const BorderSide(color: Colors.red),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(
//           icon,
//           size: 16,
//           color: Colors.grey[600],
//         ),
//         const SizedBox(width: 8),
//         SizedBox(
//           width: 80,
//           child: Text(
//             '$label:',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   String _formatDateTime(DateTime date) {
//     return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
//   }
// }