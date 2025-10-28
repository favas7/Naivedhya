// // widgets/customer_table_widget.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // Add this import for clipboard
// import 'package:naivedhya/models/user_model.dart';

// class CustomerTableWidget extends StatelessWidget {
//   final List<UserModel> customers;
//   final Function(UserModel) onEdit;
//   final Function(UserModel) onDelete;
//   final bool isDesktop;

//   const CustomerTableWidget({
//     super.key,
//     required this.customers,
//     required this.onEdit,
//     required this.onDelete,
//     required this.isDesktop,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.vertical,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             minWidth: MediaQuery.of(context).size.width - (isDesktop ? 80 : 48),
//           ),
//           child: DataTable(
//             columns: const [
//               DataColumn(label: Text('Customer ID')),
//               DataColumn(label: Text('Name')),
//               DataColumn(label: Text('Email')),
//               DataColumn(label: Text('Phone')),
//               DataColumn(label: Text('Orders')),
//               DataColumn(label: Text('Pending')),
//               DataColumn(label: Text('Actions')),
//             ],
//             rows: customers.map((customer) {
//               return DataRow(
//                 cells: [
//                   DataCell(_buildCustomerIdChip(context, customer)),
//                   DataCell(_buildNameCell(customer)),
//                   DataCell(Text(customer.email)),
//                   DataCell(Text(customer.phone)),
//                   DataCell(_buildOrdersChip(customer)),
//                   DataCell(_buildPendingPaymentsChip(customer)),
//                   DataCell(_buildActionButtons(customer)),
//                 ],
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCustomerIdChip(BuildContext context, UserModel customer) {
//     return GestureDetector(
//       onTap: () => _copyToClipboard(context, customer.id ?? 'N/A'),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         decoration: BoxDecoration(
//           color: Colors.blue.shade50,
//           borderRadius: BorderRadius.circular(4),
//           border: Border.all(color: Colors.blue.shade200, width: 1),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               customer.id ?? 'N/A',
//               style: TextStyle(
//                 fontFamily: 'monospace',
//                 color: Colors.blue.shade700,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(width: 4),
//             Icon(
//               Icons.copy,
//               size: 14,
//               color: Colors.blue.shade600,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _copyToClipboard(BuildContext context, String text) async {
//     try {
//       await Clipboard.setData(ClipboardData(text: text));
      
//       // Show success feedback
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.check_circle, color: Colors.white, size: 20),
//                 const SizedBox(width: 8),
//                 Text('Customer ID "$text" copied to clipboard'),
//               ],
//             ),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 2),
//             behavior: SnackBarBehavior.floating,
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//       }
//     } catch (e) {
//       // Show error feedback
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.error, color: Colors.white, size: 20),
//                 const SizedBox(width: 8),
//                 const Text('Failed to copy to clipboard'),
//               ],
//             ),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 2),
//             behavior: SnackBarBehavior.floating,
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//       }
//     }
//   }

//   Widget _buildNameCell(UserModel customer) {
//     return Text(
//       customer.name,
//       style: const TextStyle(fontWeight: FontWeight.w500),
//     );
//   }

//   Widget _buildOrdersChip(UserModel customer) {
//     final orderCount = customer.orderhistory?.length ?? 0;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//       decoration: BoxDecoration(
//         color: Colors.green.shade50,
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Text(
//         '$orderCount',
//         style: TextStyle(
//           color: Colors.green.shade700,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }

//   Widget _buildPendingPaymentsChip(UserModel customer) {
//     final pendingAmount = customer.pendingpayments ?? 0;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//       decoration: BoxDecoration(
//         color: pendingAmount > 0 
//             ? Colors.red.shade50 
//             : Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Text(
//         '₹${pendingAmount.toStringAsFixed(2)}',
//         style: TextStyle(
//           color: pendingAmount > 0 
//               ? Colors.red.shade700 
//               : Colors.grey.shade600,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButtons(UserModel customer) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         IconButton(
//           icon: const Icon(Icons.edit, size: 20),
//           tooltip: 'Edit Customer',
//           onPressed: () => onEdit(customer),
//         ),
//         IconButton(
//           icon: const Icon(Icons.delete, size: 20, color: Colors.red),
//           tooltip: 'Delete Customer',
//           onPressed: () => onDelete(customer),
//         ),
//       ],
//     );
//   }
// }