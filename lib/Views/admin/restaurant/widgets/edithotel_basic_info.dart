// import 'package:flutter/material.dart';
// import 'package:naivedhya/models/restaurant_model.dart';
// import 'package:naivedhya/services/restaurant_service.dart';
// import 'package:naivedhya/utils/color_theme.dart';

// class EditRestaurantBasicInfoDialog extends StatefulWidget {
//   final Restaurant restaurant;
//   final VoidCallback? onSuccess;

//   const EditRestaurantBasicInfoDialog({
//     super.key,
//     required this.restaurant,
//     this.onSuccess,
//   });

//   @override
//   State<EditRestaurantBasicInfoDialog> createState() => _EditRestaurantBasicInfoDialogState();
// }

// class _EditRestaurantBasicInfoDialogState extends State<EditRestaurantBasicInfoDialog> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _addressController = TextEditingController();
//   final RestaurantService _supabaseService = RestaurantService();
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _nameController.text = widget.restaurant.name;
//     _addressController.text = widget.restaurant.address;
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = AppTheme.of(context);

//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       backgroundColor: colors.surface,
//       child: Container(
//         padding: const EdgeInsets.all(24),
//         constraints: const BoxConstraints(maxWidth: 500),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Header
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: colors.primary.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Icon(
//                       Icons.edit,
//                       color: colors.primary,
//                       size: 24,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Edit Restaurant',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: colors.textPrimary,
//                             letterSpacing: -0.5,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           'Update restaurant information',
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: colors.textSecondary,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
//                     icon: Icon(Icons.close, color: colors.textSecondary),
//                     tooltip: 'Close',
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
              
//               // Restaurant Name Field
//               TextFormField(
//                 controller: _nameController,
//                 enabled: !_isLoading,
//                 style: TextStyle(color: colors.textPrimary),
//                 decoration: InputDecoration(
//                   labelText: 'Restaurant Name',
//                   labelStyle: TextStyle(color: colors.textSecondary),
//                   hintText: 'Enter restaurant name',
//                   hintStyle: TextStyle(color: colors.textSecondary.withOpacity(0.5)),
//                   prefixIcon: Icon(Icons.restaurant, color: colors.primary),
//                   filled: true,
//                   fillColor: colors.background,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(
//                       color: colors.textSecondary.withOpacity(0.1),
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: colors.primary, width: 2),
//                   ),
//                   errorBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: colors.error),
//                   ),
//                   focusedErrorBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: colors.error, width: 2),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 16,
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter restaurant name';
//                   }
//                   if (value.trim().length < 3) {
//                     return 'Restaurant name must be at least 3 characters';
//                   }
//                   return null;
//                 },
//               ),
              
//               const SizedBox(height: 16),
              
//               // Restaurant Address Field
//               TextFormField(
//                 controller: _addressController,
//                 enabled: !_isLoading,
//                 maxLines: 3,
//                 style: TextStyle(color: colors.textPrimary),
//                 decoration: InputDecoration(
//                   labelText: 'Restaurant Address',
//                   labelStyle: TextStyle(color: colors.textSecondary),
//                   hintText: 'Enter complete restaurant address',
//                   hintStyle: TextStyle(color: colors.textSecondary.withOpacity(0.5)),
//                   prefixIcon: Padding(
//                     padding: const EdgeInsets.only(bottom: 48),
//                     child: Icon(Icons.location_on, color: colors.primary),
//                   ),
//                   filled: true,
//                   fillColor: colors.background,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(
//                       color: colors.textSecondary.withOpacity(0.1),
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: colors.primary, width: 2),
//                   ),
//                   errorBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: colors.error),
//                   ),
//                   focusedErrorBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: colors.error, width: 2),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 16,
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter restaurant address';
//                   }
//                   if (value.trim().length < 10) {
//                     return 'Please enter a complete address';
//                   }
//                   return null;
//                 },
//               ),
              
//               const SizedBox(height: 24),
              
//               // Action Buttons
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
//                       style: OutlinedButton.styleFrom(
//                         side: BorderSide(color: colors.textSecondary.withOpacity(0.3)),
//                         foregroundColor: colors.textPrimary,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                       ),
//                       child: Text(
//                         'Cancel',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 15,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _updateRestaurant,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: colors.primary,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         elevation: 0,
//                       ),
//                       child: _isLoading
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                               ),
//                             )
//                           : Text(
//                               'Update Restaurant',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 15,
//                               ),
//                             ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _updateRestaurant() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final updatedRestaurant = await _supabaseService.updateRestaurantBasicInfo(
//         widget.restaurant.id!,
//         _nameController.text.trim(),
//         _addressController.text.trim(),
//       );

//       if (updatedRestaurant != null) {
//         if (mounted) {
//           final colors = AppTheme.of(context);
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Row(
//                 children: [
//                   Icon(Icons.check_circle, color: Colors.white),
//                   const SizedBox(width: 12),
//                   const Text('Restaurant updated successfully'),
//                 ],
//               ),
//               backgroundColor: colors.success,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               margin: const EdgeInsets.all(16),
//             ),
//           );
//           Navigator.of(context).pop();
//           widget.onSuccess?.call();
//         }
//       } else {
//         throw Exception('Failed to update restaurant');
//       }
//     } catch (e) {
//       if (mounted) {
//         final colors = AppTheme.of(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(Icons.error_outline, color: Colors.white),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     e.toString().replaceAll('Exception: ', ''),
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: colors.error,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
// }