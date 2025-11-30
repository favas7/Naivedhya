// import 'package:flutter/material.dart';
// import 'package:naivedhya/Views/admin/restaurant/location/add_location_dialogue.dart';
// import 'package:naivedhya/Views/admin/restaurant/manager/add_manager_dialogue.dart';
// import 'package:naivedhya/Views/admin/restaurant/restaurant_detail_screen/restaurant_detail_screen.dart';
// import 'package:naivedhya/Views/admin/restaurant/widgets/edithotel_basic_info.dart';
// import 'package:naivedhya/Views/admin/restaurant/widgets/restaurant_action_button.dart';
// import 'package:naivedhya/models/restaurant_model.dart';
// import 'package:naivedhya/utils/color_theme.dart';
// import 'package:naivedhya/Views/admin/restaurant/widgets/restaurant_quick_stats.dart';

// class EnhancedRestaurantCard extends StatefulWidget {
//   final Restaurant restaurant;
//   final VoidCallback? onRestaurantUpdated;
//   final int managerCount;
//   final int locationCount;
//   final int menuItemCount;
//   final int availableMenuItemCount;
//   final bool canEdit;
//   final Function(String) onMenuAction;
//   final VoidCallback onNavigateToMenuManagement;

//   const EnhancedRestaurantCard({
//     super.key, 
//     required this.restaurant,
//     this.onRestaurantUpdated,
//     required this.managerCount,
//     required this.locationCount,
//     required this.menuItemCount,
//     required this.availableMenuItemCount,
//     required this.canEdit,
//     required this.onMenuAction,
//     required this.onNavigateToMenuManagement,
//   });

//   @override
//   State<EnhancedRestaurantCard> createState() => _EnhancedRestaurantCardState();
// }

// class _EnhancedRestaurantCardState extends State<EnhancedRestaurantCard> {
//   bool _isHovered = false;

//   void _navigateToDetail() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => RestaurantDetailScreen(
//           restaurant: widget.restaurant,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = AppTheme.of(context);
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return MouseRegion(
//       onEnter: (_) => setState(() => _isHovered = true),
//       onExit: (_) => setState(() => _isHovered = false),
//       child: GestureDetector(
//         onTap: _navigateToDetail,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
//           child: Container(
//             decoration: BoxDecoration(
//               color: colors.surface,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: _isHovered
//                     ? colors.primary.withOpacity(0.3)
//                     : colors.textSecondary.withOpacity(0.1),
//                 width: 1,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: _isHovered
//                       ? colors.primary.withOpacity(0.1)
//                       : Colors.black.withOpacity(isDark ? 0.3 : 0.05),
//                   blurRadius: _isHovered ? 20 : 10,
//                   offset: Offset(0, _isHovered ? 8 : 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Header Section with Gradient
//                 Container(
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         colors.primary.withOpacity(0.1),
//                         colors.primary.withOpacity(0.05),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(16),
//                       topRight: Radius.circular(16),
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Restaurant Name and Actions Row
//                       Row(
//                         children: [
//                           // Restaurant Icon
//                           Container(
//                             width: 56,
//                             height: 56,
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [
//                                   colors.primary,
//                                   colors.primary.withOpacity(0.8),
//                                 ],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: colors.primary.withOpacity(0.3),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 4),
//                                 ),
//                               ],
//                             ),
//                             child: const Icon(
//                               Icons.restaurant_menu,
//                               color: Colors.white,
//                               size: 28,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
                          
//                           // Restaurant Name and Status
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Flexible(
//                                       child: Text(
//                                         widget.restaurant.name,
//                                         style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold,
//                                           color: colors.textPrimary,
//                                           letterSpacing: -0.5,
//                                         ),
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     // Active Status Badge
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 10,
//                                         vertical: 4,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: colors.success.withOpacity(0.15),
//                                         borderRadius: BorderRadius.circular(12),
//                                         border: Border.all(
//                                           color: colors.success.withOpacity(0.3),
//                                           width: 1,
//                                         ),
//                                       ),
//                                       child: Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           Container(
//                                             width: 6,
//                                             height: 6,
//                                             decoration: BoxDecoration(
//                                               color: colors.success,
//                                               shape: BoxShape.circle,
//                                             ),
//                                           ),
//                                           const SizedBox(width: 6),
//                                           Text(
//                                             'Active',
//                                             style: TextStyle(
//                                               fontSize: 11,
//                                               fontWeight: FontWeight.w600,
//                                               color: colors.success,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       Icons.location_on,
//                                       size: 14,
//                                       color: colors.textSecondary,
//                                     ),
//                                     const SizedBox(width: 4),
//                                     Flexible(
//                                       child: Text(
//                                         widget.restaurant.address,
//                                         style: TextStyle(
//                                           fontSize: 13,
//                                           color: colors.textSecondary,
//                                         ),
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
                          
//                           // More Menu - Prevent navigation when tapped
//                           GestureDetector(
//                             onTap: () {}, // Prevents parent GestureDetector from triggering
//                             child: PopupMenuButton<String>(
//                               onSelected: (value) => widget.onMenuAction(value),
//                               tooltip: 'More options',
//                               icon: Icon(
//                                 Icons.more_vert,
//                                 color: colors.textSecondary,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               itemBuilder: (context) => [
//                               PopupMenuItem(
//                                 value: 'edit_basic',
//                                 onTap: () {
//                                   // Use Future.delayed to avoid popup menu closing conflict
//                                   Future.delayed(Duration.zero, () {
//                                     showDialog(
//                                       context: context,
//                                       builder: (context) => EditRestaurantBasicInfoDialog(
//                                         restaurant: widget.restaurant,
//                                         onSuccess: widget.onRestaurantUpdated,
//                                       ),
//                                     );
//                                   });
//                                 },
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.edit, size: 18, color: colors.textSecondary),
//                                     const SizedBox(width: 12),
//                                     const Text('Edit Details'),
//                                   ],
//                                 ),
//                               ),
//                                 PopupMenuItem(
//                                   onTap: () {
//                                   // Use Future.delayed to avoid popup menu closing conflict
//                                   Future.delayed(Duration.zero, () {
//                                     showDialog(
//                                       context: context,
//                                       builder: (context) => AddManagerDialog(
//                                         restaurant: widget.restaurant,
//                                       ),
//                                     );
//                                   });                                  
//                                   },
//                                   value: 'add_manager',
//                                   child: Row(
//                                     children: [
//                                       Icon(Icons.person_add, size: 18, color: colors.textSecondary),
//                                       const SizedBox(width: 12),
//                                       const Text('Add Manager'),
//                                     ],
//                                   ),
//                                 ),
//                                 PopupMenuItem(
//                                   value: 'add_location',
//                                   onTap: () {
//                                                                       // Use Future.delayed to avoid popup menu closing conflict
//                                   Future.delayed(Duration.zero, () {
//                                     showDialog(
//                                       context: context,
//                                       builder: (context) => AddLocationDialog(
//                                         restaurant: widget.restaurant,
//                                       ), 
//                                     );
//                                   });  
//                                   },
//                                   child: Row(
//                                     children: [
//                                       Icon(Icons.add_location, size: 18, color: colors.textSecondary),
//                                       const SizedBox(width: 12),
//                                       const Text('Add Location'),
//                                     ],
//                                   ),
//                                 ),
//                                 const PopupMenuDivider(),
//                                 PopupMenuItem(
//                                   value: 'delete',
//                                   child: Row(
//                                     children: [
//                                       Icon(Icons.delete_outline, size: 18, color: colors.error),
//                                       const SizedBox(width: 12),
//                                       Text('Delete', style: TextStyle(color: colors.error)),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Stats Section
//                 Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: RestaurantQuickStats(
//                     managerCount: widget.managerCount,
//                     locationCount: widget.locationCount,
//                     menuItemCount: widget.menuItemCount,
//                     availableMenuItemCount: widget.availableMenuItemCount,
//                   ),
//                 ),

//                 // Action Buttons Section - Prevent navigation when tapped
//                 GestureDetector(
//                   onTap: () {}, // Prevents parent GestureDetector from triggering
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
//                     child: RestaurantActionButtons(
//                       canEdit: widget.canEdit,
//                       onManageMenu: widget.onNavigateToMenuManagement,
//                       onAddMenuItem: () => widget.onMenuAction('add_menu_item'),
//                       onViewDetails: _navigateToDetail,
//                       restaurant: widget.restaurant,
//                     ),
//                   ),
//                 ),

//                 // Footer with metadata
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//                   decoration: BoxDecoration(
//                     color: colors.textSecondary.withOpacity(0.05),
//                     borderRadius: const BorderRadius.only(
//                       bottomLeft: Radius.circular(16),
//                       bottomRight: Radius.circular(16),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       // Admin Email Section (if available)
//                       if (widget.restaurant.adminEmail != null) ...[
//                         Icon(
//                           Icons.admin_panel_settings,
//                           size: 14,
//                           color: colors.textSecondary,
//                         ),
//                         const SizedBox(width: 6),
//                         Flexible(
//                           child: Text(
//                             widget.restaurant.adminEmail!,
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: colors.textSecondary,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Container(
//                           width: 1,
//                           height: 12,
//                           color: colors.textSecondary.withOpacity(0.2),
//                         ),
//                         const SizedBox(width: 16),
//                       ],
                      
//                       // Created Date Section
//                       Icon(
//                         Icons.access_time,
//                         size: 14,
//                         color: colors.textSecondary,
//                       ),
//                       const SizedBox(width: 6),
//                       Flexible(
//                         child: Text(
//                           _formatDate(widget.restaurant.createdAt),
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: colors.textSecondary,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
                      
//                       const SizedBox(width: 8),
                      
//                       // Restaurant ID Section
//                       Flexible(
//                         child: Text(
//                           'ID: ${widget.restaurant.id?.substring(0, 8) ?? 'N/A'}...',
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: colors.textSecondary.withOpacity(0.7),
//                             fontFamily: 'monospace',
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                           textAlign: TextAlign.right,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime? date) {
//     if (date == null) return 'Unknown';
//     final now = DateTime.now();
//     final difference = now.difference(date);

//     if (difference.inDays == 0) {
//       return 'Today';
//     } else if (difference.inDays == 1) {
//       return 'Yesterday';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays} days ago';
//     } else if (difference.inDays < 30) {
//       final weeks = (difference.inDays / 7).floor();
//       return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
//     } else if (difference.inDays < 365) {
//       final months = (difference.inDays / 30).floor();
//       return '$months ${months == 1 ? 'month' : 'months'} ago';
//     } else {
//       final years = (difference.inDays / 365).floor();
//       return '$years ${years == 1 ? 'year' : 'years'} ago';
//     }
//   }
// }