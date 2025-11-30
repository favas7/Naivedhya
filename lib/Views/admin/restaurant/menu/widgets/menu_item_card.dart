// import 'package:flutter/material.dart';
// import 'package:naivedhya/utils/color_theme.dart';
// import 'package:naivedhya/models/menu_model.dart';

// class MenuItemCard extends StatefulWidget {
//   final MenuItem menuItem;
//   final VoidCallback? onEdit;
//   final VoidCallback? onDelete;
//   final VoidCallback? onToggleAvailability;

//   const MenuItemCard({
//     super.key,
//     required this.menuItem,
//     this.onEdit,
//     this.onDelete,
//     this.onToggleAvailability,
//   });

//   @override
//   State<MenuItemCard> createState() => _MenuItemCardState();
// }

// class _MenuItemCardState extends State<MenuItemCard> {
//   bool _isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     final colors = AppTheme.of(context);
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return MouseRegion(
//       onEnter: (_) => setState(() => _isHovered = true),
//       onExit: (_) => setState(() => _isHovered = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
//         margin: const EdgeInsets.only(bottom: 12),
//         decoration: BoxDecoration(
//           color: colors.surface,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: widget.menuItem.isAvailable
//                 ? (_isHovered
//                     ? colors.primary.withOpacity(0.3)
//                     : colors.textSecondary.withOpacity(0.1))
//                 : colors.error.withOpacity(0.3),
//             width: 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: _isHovered
//                   ? (widget.menuItem.isAvailable
//                       ? colors.primary.withOpacity(0.1)
//                       : colors.error.withOpacity(0.1))
//                   : Colors.black.withOpacity(isDark ? 0.3 : 0.05),
//               blurRadius: _isHovered ? 12 : 6,
//               offset: Offset(0, _isHovered ? 4 : 2),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header Row
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Item Icon
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: widget.menuItem.isAvailable
//                             ? [
//                                 colors.primary,
//                                 colors.primary.withOpacity(0.8),
//                               ]
//                             : [
//                                 Colors.grey,
//                                 Colors.grey.withOpacity(0.8),
//                               ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(10),
//                       boxShadow: [
//                         BoxShadow(
//                           color: widget.menuItem.isAvailable
//                               ? colors.primary.withOpacity(0.3)
//                               : Colors.grey.withOpacity(0.3),
//                           blurRadius: 6,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Icon(
//                       Icons.restaurant_menu,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),

//                   // Item Details
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Name and Price Row
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 widget.menuItem.name,
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: widget.menuItem.isAvailable
//                                       ? colors.textPrimary
//                                       : colors.textSecondary,
//                                   decoration: widget.menuItem.isAvailable
//                                       ? null
//                                       : TextDecoration.lineThrough,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   colors: widget.menuItem.isAvailable
//                                       ? [
//                                           colors.primary.withOpacity(0.15),
//                                           colors.primary.withOpacity(0.1),
//                                         ]
//                                       : [
//                                           Colors.grey.withOpacity(0.15),
//                                           Colors.grey.withOpacity(0.1),
//                                         ],
//                                 ),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Text(
//                                 '₹${widget.menuItem.price.toStringAsFixed(2)}',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: widget.menuItem.isAvailable
//                                       ? colors.primary
//                                       : colors.textSecondary,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                         // Description
//                         if (widget.menuItem.description != null &&
//                             widget.menuItem.description!.isNotEmpty) ...[
//                           const SizedBox(height: 6),
//                           Text(
//                             widget.menuItem.description!,
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: colors.textSecondary,
//                               height: 1.3,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],

//                         const SizedBox(height: 10),

//                         // Tags Row
//                         Wrap(
//                           spacing: 8,
//                           runSpacing: 6,
//                           children: [
//                             // Category Chip
//                             if (widget.menuItem.category != null &&
//                                 widget.menuItem.category!.isNotEmpty)
//                               _buildChip(
//                                 icon: Icons.category,
//                                 label: widget.menuItem.category!,
//                                 color: colors.info,
//                               ),

//                             // Stock Status
//                             if (widget.menuItem.stockQuantity > 0)
//                               _buildChip(
//                                 icon: widget.menuItem.isLowStock
//                                     ? Icons.inventory_2
//                                     : Icons.inventory,
//                                 label: 'Stock: ${widget.menuItem.stockQuantity}',
//                                 color: widget.menuItem.isLowStock
//                                     ? colors.warning
//                                     : colors.success,
//                               ),

//                             // Availability Status
//                             _buildChip(
//                               icon: widget.menuItem.isAvailable
//                                   ? Icons.check_circle
//                                   : Icons.cancel,
//                               label: widget.menuItem.isAvailable
//                                   ? 'Available'
//                                   : 'Unavailable',
//                               color: widget.menuItem.isAvailable
//                                   ? colors.success
//                                   : colors.error,
//                             ),

//                             // Customizations
//                             if (widget.menuItem.customizations.isNotEmpty)
//                               _buildChip(
//                                 icon: Icons.tune,
//                                 label:
//                                     '${widget.menuItem.customizations.length} options',
//                                 color: colors.primary,
//                               ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Actions Menu
//                   PopupMenuButton<String>(
//                     onSelected: _handleMenuAction,
//                     icon: Icon(
//                       Icons.more_vert,
//                       color: colors.textSecondary,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     itemBuilder: (context) => [
//                       PopupMenuItem(
//                         value: 'edit',
//                         child: Row(
//                           children: [
//                             Icon(Icons.edit, size: 18, color: colors.textSecondary),
//                             const SizedBox(width: 12),
//                             const Text('Edit'),
//                           ],
//                         ),
//                       ),
//                       PopupMenuItem(
//                         value: 'toggle_availability',
//                         child: Row(
//                           children: [
//                             Icon(
//                               widget.menuItem.isAvailable
//                                   ? Icons.visibility_off
//                                   : Icons.visibility,
//                               size: 18,
//                               color: colors.textSecondary,
//                             ),
//                             const SizedBox(width: 12),
//                             Text(widget.menuItem.isAvailable
//                                 ? 'Mark Unavailable'
//                                 : 'Mark Available'),
//                           ],
//                         ),
//                       ),
//                       const PopupMenuDivider(),
//                       PopupMenuItem(
//                         value: 'delete',
//                         child: Row(
//                           children: [
//                             Icon(Icons.delete_outline,
//                                 size: 18, color: colors.error),
//                             const SizedBox(width: 12),
//                             Text('Delete',
//                                 style: TextStyle(color: colors.error)),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),

//               // Footer with timestamps
//               if (widget.menuItem.createdAt != null) ...[
//                 const SizedBox(height: 12),
//                 Container(
//                   padding: const EdgeInsets.only(top: 12),
//                   decoration: BoxDecoration(
//                     border: Border(
//                       top: BorderSide(
//                         color: colors.textSecondary.withOpacity(0.1),
//                         width: 1,
//                       ),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.access_time,
//                         size: 12,
//                         color: colors.textSecondary,
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           'Created: ${_formatDateTime(widget.menuItem.createdAt!)}',
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: colors.textSecondary,
//                           ),
//                         ),
//                       ),
//                       if (widget.menuItem.updatedAt != null &&
//                           widget.menuItem.updatedAt != widget.menuItem.createdAt) ...[
//                         Text(
//                           ' • ',
//                           style: TextStyle(color: colors.textSecondary),
//                         ),
//                         Flexible(
//                           child: Text(
//                             'Updated: ${_formatDateTime(widget.menuItem.updatedAt!)}',
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: colors.textSecondary,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildChip({
//     required IconData icon,
//     required String label,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: color.withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 13,
//             color: color,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 11,
//               color: color,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _handleMenuAction(String action) {
//     switch (action) {
//       case 'edit':
//         widget.onEdit?.call();
//         break;
//       case 'toggle_availability':
//         widget.onToggleAvailability?.call();
//         break;
//       case 'delete':
//         widget.onDelete?.call();
//         break;
//     }
//   }

//   String _formatDateTime(DateTime dateTime) {
//     return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
//   }
// }