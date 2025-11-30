// import 'package:flutter/material.dart';
// import 'package:naivedhya/models/restaurant_model.dart';

// class RestaurantCardBasicInfo extends StatelessWidget {
//   final Restaurant restaurant;

//   const RestaurantCardBasicInfo({
//     super.key,
//     required this.restaurant,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (restaurant.adminEmail == null) return const SizedBox.shrink();
    
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.blue.withAlpha(30),
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.admin_panel_settings,
//             size: 14,
//             color: Colors.blue[700],
//           ),
//           const SizedBox(width: 4),
//           Text(
//             'Admin: ${restaurant.adminEmail}',
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.blue[700],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }