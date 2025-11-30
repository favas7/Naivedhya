// import 'package:flutter/material.dart';
// import 'package:naivedhya/Views/admin/restaurant/menu/menu_managment_screen.dart';
// import 'package:naivedhya/models/restaurant_model.dart';
// import 'package:naivedhya/utils/color_theme.dart';

// class RestaurantActionButtons extends StatelessWidget {
//   final Restaurant restaurant;
//   final bool canEdit;
//   final VoidCallback onManageMenu;
//   final VoidCallback onAddMenuItem;
//   final VoidCallback onViewDetails;

//   const RestaurantActionButtons({
//     super.key,
//     required this.restaurant,
//     required this.canEdit,
//     required this.onManageMenu,
//     required this.onAddMenuItem,
//     required this.onViewDetails,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colors = AppTheme.of(context);

//     return Row(
//       children: [
//         Expanded(
//           child: _ActionButton(
//             icon: Icons.menu_book,
//             label: 'Manage Menu',
//             onPressed: canEdit
//                 ? () {
//                     // Show menu management as a modal dialog
//                     showDialog(
//                       context: context,
//                       builder: (context) => Dialog(
//                         backgroundColor: Colors.transparent,
//                         insetPadding: const EdgeInsets.all(24),
//                         child: Container(
//                           constraints: const BoxConstraints(
//                             maxWidth: 1200,
//                             maxHeight: 800,
//                           ),
//                           decoration: BoxDecoration(
//                             color: colors.surface,
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: MenuManagementScreen(
//                             restaurant: restaurant,
//                             onMenuUpdated: () async {
//                               // Refresh restaurant data
//                               onManageMenu();
//                               return;
//                             },
//                           ),
//                         ),
//                       ),
//                     );
//                   }
//                 : null,
//             isPrimary: true,
//             colors: colors,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _ActionButton(
//             icon: Icons.add_circle_outline,
//             label: 'Add Item',
//             onPressed: canEdit ? onAddMenuItem : null,
//             isPrimary: false,
//             colors: colors,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _ActionButton extends StatefulWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback? onPressed;
//   final bool isPrimary;
//   final AppThemeColors colors;

//   const _ActionButton({
//     required this.icon,
//     required this.label,
//     required this.onPressed,
//     required this.isPrimary,
//     required this.colors,
//   });

//   @override
//   State<_ActionButton> createState() => _ActionButtonState();
// }

// class _ActionButtonState extends State<_ActionButton> {
//   bool _isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     final isDisabled = widget.onPressed == null;

//     return MouseRegion(
//       onEnter: (_) => setState(() => _isHovered = true),
//       onExit: (_) => setState(() => _isHovered = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         child: ElevatedButton(
//           onPressed: widget.onPressed,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: widget.isPrimary
//                 ? (isDisabled
//                     ? widget.colors.textSecondary.withOpacity(0.3)
//                     : widget.colors.primary)
//                 : (isDisabled
//                     ? widget.colors.textSecondary.withOpacity(0.1)
//                     : widget.colors.surface),
//             foregroundColor: widget.isPrimary
//                 ? Colors.white
//                 : (isDisabled
//                     ? widget.colors.textSecondary
//                     : widget.colors.textPrimary),
//             elevation: _isHovered && !isDisabled ? 4 : 0,
//             shadowColor: widget.isPrimary
//                 ? widget.colors.primary.withOpacity(0.3)
//                 : Colors.transparent,
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//               side: widget.isPrimary
//                   ? BorderSide.none
//                   : BorderSide(
//                       color: isDisabled
//                           ? widget.colors.textSecondary.withOpacity(0.2)
//                           : widget.colors.textSecondary.withOpacity(0.2),
//                       width: 1,
//                     ),
//             ),
//           ),
//           // FIXED: Button content with proper overflow handling
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 widget.icon,
//                 size: 16,
//               ),
//               const SizedBox(width: 6),
//               Flexible(
//                 child: Text(
//                   widget.label,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }  
// }