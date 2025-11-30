// import 'package:flutter/material.dart';
// import 'package:naivedhya/utils/color_theme.dart';

// class RestaurantQuickStats extends StatelessWidget {
//   final int managerCount;
//   final int locationCount;
//   final int menuItemCount;
//   final int availableMenuItemCount;

//   const RestaurantQuickStats({
//     super.key,
//     required this.managerCount,
//     required this.locationCount,
//     required this.menuItemCount,
//     required this.availableMenuItemCount,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colors = AppTheme.of(context);

//     return Row(
//       children: [
//         Expanded(
//           child: _StatCard(
//             icon: Icons.people_outline,
//             label: 'Managers',
//             value: managerCount.toString(),
//             color: colors.info,
//             colors: colors,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _StatCard(
//             icon: Icons.location_on_outlined,
//             label: 'Locations',
//             value: locationCount.toString(),
//             color: colors.warning,
//             colors: colors,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _StatCard(
//             icon: Icons.restaurant_menu,
//             label: 'Menu Items',
//             value: menuItemCount.toString(),
//             subtitle: '$availableMenuItemCount available',
//             color: colors.success,
//             colors: colors,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _StatCard extends StatefulWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final String? subtitle;
//   final Color color;
//   final AppThemeColors colors;

//   const _StatCard({
//     required this.icon,
//     required this.label,
//     required this.value,
//     this.subtitle,
//     required this.color,
//     required this.colors,
//   });

//   @override
//   State<_StatCard> createState() => _StatCardState();
// }

// class _StatCardState extends State<_StatCard> {
//   bool _isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => _isHovered = true),
//       onExit: (_) => setState(() => _isHovered = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: _isHovered
//               ? widget.color.withOpacity(0.08)
//               : widget.color.withOpacity(0.05),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: _isHovered
//                 ? widget.color.withOpacity(0.3)
//                 : widget.color.withOpacity(0.15),
//             width: 1,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // FIXED: Icon and Value Row
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                     color: widget.color.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     widget.icon,
//                     size: 16,
//                     color: widget.color,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     widget.value,
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: widget.colors.textPrimary,
//                       letterSpacing: -0.5,
//                     ),
//                     textAlign: TextAlign.right,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             // FIXED: Label with overflow handling
//             Text(
//               widget.label,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//                 color: widget.colors.textSecondary,
//               ),
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//             ),
//             if (widget.subtitle != null) ...[
//               const SizedBox(height: 2),
//               Row(
//                 children: [
//                   Container(
//                     width: 5,
//                     height: 5,
//                     decoration: BoxDecoration(
//                       color: widget.color,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: Text(
//                       widget.subtitle!,
//                       style: TextStyle(
//                         fontSize: 10,
//                         color: widget.colors.textSecondary,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }