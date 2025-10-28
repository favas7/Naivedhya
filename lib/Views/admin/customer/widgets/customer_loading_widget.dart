// // widgets/customer_loading_widget.dart
// import 'package:flutter/material.dart';

// class CustomerLoadingWidget extends StatelessWidget {
//   const CustomerLoadingWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: CircularProgressIndicator(),
//     );
//   }
// }

// class CustomerErrorWidget extends StatelessWidget {
//   final String errorMessage;
//   final VoidCallback onRetry;

//   const CustomerErrorWidget({
//     super.key,
//     required this.errorMessage,
//     required this.onRetry,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.error_outline, size: 48, color: Colors.red),
//           const SizedBox(height: 16),
//           Text(
//             'Error: $errorMessage',
//             style: const TextStyle(color: Colors.red),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: onRetry,
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CustomerEmptyWidget extends StatelessWidget {
//   final String searchQuery;

//   const CustomerEmptyWidget({
//     super.key,
//     required this.searchQuery,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.people_outline, size: 48, color: Colors.grey),
//           const SizedBox(height: 16),
//           Text(
//             searchQuery.isNotEmpty 
//                 ? 'No customers found matching your search'
//                 : 'No customers found',
//             style: const TextStyle(color: Colors.grey, fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }
// }