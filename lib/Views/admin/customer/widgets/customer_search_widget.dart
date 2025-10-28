// // widgets/customer_search_widget.dart
// import 'package:flutter/material.dart';

// class CustomerSearchWidget extends StatelessWidget {
//   final TextEditingController controller;
//   final Function(String) onChanged;
//   final VoidCallback onClear;
//   final bool isDesktop;

//   const CustomerSearchWidget({
//     super.key,
//     required this.controller,
//     required this.onChanged,
//     required this.onClear,
//     required this.isDesktop,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       onChanged: onChanged,
//       decoration: InputDecoration(
//         hintText: 'Search customers by name, email, or ID...',
//         prefixIcon: const Icon(Icons.search),
//         suffixIcon: controller.text.isNotEmpty
//             ? IconButton(
//                 onPressed: onClear,
//                 icon: const Icon(Icons.clear),
//               )
//             : null,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         filled: true,
//         fillColor: Colors.white,
//       ),
//     );
//   }
// }