// // lib/Views/admin/order/add_order_screen/widget/add_order_dialogs.dart
// import 'package:flutter/material.dart';
// import 'package:naivedhya/models/customer_model.dart';
// import 'package:naivedhya/models/menu_model.dart';
// import 'package:naivedhya/models/order_item_model.dart';
// import 'package:naivedhya/utils/color_theme.dart';

// class AddOrderDialogs {
//   // Customer Selection Dialog with Guest Option
//   static void showCustomerSelection({
//     required BuildContext context,
//     required List<Customer> customers,
//     required Function(Customer) onCustomerSelected,
//     required VoidCallback onAddNewCustomer,
//     VoidCallback? onContinueAsGuest,
//   }) {
//     final themeColors = AppTheme.of(context);

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: themeColors.surface,
//         title: Text(
//           'Select Customer',
//           style: TextStyle(
//             color: themeColors.textPrimary,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: customers.isEmpty
//               ? Padding(
//                   padding: const EdgeInsets.all(32),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.person_off_outlined,
//                         size: 48,
//                         color: themeColors.textSecondary.withAlpha(128),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'No customers found',
//                         style: TextStyle(
//                           color: themeColors.textSecondary,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: customers.length,
//                   itemBuilder: (context, index) {
//                     final customer = customers[index];
//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 8),
//                       decoration: BoxDecoration(
//                         color: themeColors.background,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color: themeColors.background.withAlpha(50),
//                         ),
//                       ),
//                       child: ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor: AppTheme.primary.withAlpha(25),
//                           child: Icon(
//                             Icons.person,
//                             color: AppTheme.primary,
//                             size: 20,
//                           ),
//                         ),
//                         title: Text(
//                           customer.name,
//                           style: TextStyle(
//                             color: themeColors.textPrimary,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                           ),
//                         ),
//                         subtitle: Text(
//                           customer.phone ?? 'No mobile',
//                           style: TextStyle(
//                             color: themeColors.textSecondary,
//                             fontSize: 12,
//                           ),
//                         ),
//                         trailing: Icon(
//                           Icons.arrow_forward_ios,
//                           size: 16,
//                           color: themeColors.textSecondary,
//                         ),
//                         onTap: () {
//                           onCustomerSelected(customer);
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     );
//                   },
//                 ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text(
//               'Cancel',
//               style: TextStyle(color: themeColors.textSecondary),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               onAddNewCustomer();
//             },
//             child: Text(
//               'Add New Customer',
//               style: TextStyle(color: AppTheme.primary),
//             ),
//           ),
//           if (onContinueAsGuest != null)
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 onContinueAsGuest();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppTheme.warning,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Continue as Guest'),
//             ),
//         ],
//       ),
//     );
//   }

//   // Add New Customer Dialog
//   static void showAddNewCustomer({
//     required BuildContext context,
//     required TextEditingController nameController,
//     required TextEditingController mobileController,
//     required TextEditingController emailController,
//     required TextEditingController addressController,
//     required VoidCallback onSubmit,
//   }) {
//     final themeColors = AppTheme.of(context);

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: themeColors.surface,
//         title: Text(
//           'Add New Customer',
//           style: TextStyle(
//             color: themeColors.textPrimary,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 style: TextStyle(color: themeColors.textPrimary),
//                 decoration: InputDecoration(
//                   labelText: 'Customer Name *',
//                   labelStyle: TextStyle(color: themeColors.textSecondary),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: Icon(
//                     Icons.person,
//                     color: AppTheme.primary,
//                     size: 20,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: mobileController,
//                 style: TextStyle(color: themeColors.textPrimary),
//                 decoration: InputDecoration(
//                   labelText: 'Mobile Number *',
//                   labelStyle: TextStyle(color: themeColors.textSecondary),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: Icon(
//                     Icons.phone,
//                     color: AppTheme.primary,
//                     size: 20,
//                   ),
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: emailController,
//                 style: TextStyle(color: themeColors.textPrimary),
//                 decoration: InputDecoration(
//                   labelText: 'Email (Optional)',
//                   labelStyle: TextStyle(color: themeColors.textSecondary),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: Icon(
//                     Icons.email,
//                     color: AppTheme.primary,
//                     size: 20,
//                   ),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: addressController,
//                 style: TextStyle(color: themeColors.textPrimary),
//                 decoration: InputDecoration(
//                   labelText: 'Delivery Address *',
//                   labelStyle: TextStyle(color: themeColors.textSecondary),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: Icon(
//                     Icons.location_on,
//                     color: AppTheme.primary,
//                     size: 20,
//                   ),
//                 ),
//                 maxLines: 2,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text(
//               'Cancel',
//               style: TextStyle(color: themeColors.textSecondary),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: onSubmit,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Create Customer'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Add Guest Details Dialog
//   static void showAddGuestDetails({
//     required BuildContext context,
//     required TextEditingController nameController,
//     required TextEditingController mobileController,
//     required TextEditingController addressController,
//     required VoidCallback onSubmit,
//   }) {
//     final themeColors = AppTheme.of(context);

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: themeColors.surface,
//         title: Text(
//           'Guest Order Details',
//           style: TextStyle(
//             color: themeColors.textPrimary,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 style: TextStyle(color: themeColors.textPrimary),
//                 decoration: InputDecoration(
//                   labelText: 'Guest Name *',
//                   labelStyle: TextStyle(color: themeColors.textSecondary),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: Icon(
//                     Icons.person_outline,
//                     color: AppTheme.warning,
//                     size: 20,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: mobileController,
//                 style: TextStyle(color: themeColors.textPrimary),
//                 decoration: InputDecoration(
//                   labelText: 'Mobile Number *',
//                   labelStyle: TextStyle(color: themeColors.textSecondary),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: Icon(
//                     Icons.phone,
//                     color: AppTheme.warning,
//                     size: 20,
//                   ),
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: addressController,
//                 style: TextStyle(color: themeColors.textPrimary),
//                 decoration: InputDecoration(
//                   labelText: 'Delivery Address *',
//                   labelStyle: TextStyle(color: themeColors.textSecondary),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: Icon(
//                     Icons.location_on,
//                     color: AppTheme.warning,
//                     size: 20,
//                   ),
//                 ),
//                 maxLines: 2,
//               ),
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: AppTheme.info.withAlpha(13),
//                   border: Border.all(
//                     color: AppTheme.info.withAlpha(51),
//                   ),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.info_outline,
//                       color: AppTheme.info,
//                       size: 20,
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'This guest will be converted to a customer after order completion.',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: themeColors.textPrimary,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text(
//               'Cancel',
//               style: TextStyle(color: themeColors.textSecondary),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: onSubmit,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.warning,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Continue as Guest'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Enhanced Menu Item Selection Dialog with Inventory
//   static void showMenuItemSelection({
//     required BuildContext context,
//     required String restaurantName,
//     required List<MenuItem> menuItems,
//     required List<OrderItem> currentOrderItems,
//     required Function(MenuItem) onAddItem,
//   }) {
//     final themeColors = AppTheme.of(context);

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: themeColors.surface,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Add Menu Items',
//               style: TextStyle(
//                 color: themeColors.textPrimary,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 18,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Icon(
//                   Icons.restaurant,
//                   size: 14,
//                   color: AppTheme.primary,
//                 ),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: Text(
//                     restaurantName,
//                     style: TextStyle(
//                       color: themeColors.textSecondary,
//                       fontSize: 13,
//                       fontWeight: FontWeight.normal,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         content: SizedBox(
//           width: double.maxFinite,
//           height: 400,
//           child: menuItems.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.restaurant_menu_outlined,
//                         size: 48,
//                         color: themeColors.textSecondary.withAlpha(128),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'No menu items available',
//                         style: TextStyle(
//                           color: themeColors.textSecondary,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : ListView.builder(
//                   itemCount: menuItems.length,
//                   itemBuilder: (context, index) {
//                     final item = menuItems[index];
//                     final isAdded = currentOrderItems.any(
//                       (orderItem) => orderItem.itemId == item.itemId,
//                     );

//                     return _buildMenuItemTile(
//                       item: item,
//                       isAdded: isAdded,
//                       onAddItem: onAddItem,
//                       themeColors: themeColors,
//                     );
//                   },
//                 ),
//         ),
//         actions: [
//           ElevatedButton(
//             onPressed: () => Navigator.of(context).pop(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Done'),
//           ),
//         ],
//       ),
//     );
//   }

//   static Widget _buildMenuItemTile({
//     required MenuItem item,
//     required bool isAdded,
//     required Function(MenuItem) onAddItem,
//     required AppThemeColors themeColors,
//   }) {
//     final isOutOfStock = !item.isInStock;
//     final isLowStock = item.isLowStock;

//     // Determine colors based on stock status
//     Color borderColor;
//     Color backgroundColor;
//     Color textColor;

//     if (isOutOfStock) {
//       borderColor = AppTheme.error.withAlpha(51);
//       backgroundColor = AppTheme.error.withAlpha(13);
//       textColor = AppTheme.error;
//     } else if (isAdded) {
//       borderColor = AppTheme.success.withAlpha(51);
//       backgroundColor = AppTheme.success.withAlpha(13);
//       textColor = themeColors.textPrimary;
//     } else {
//       borderColor = themeColors.background.withAlpha(50);
//       backgroundColor = themeColors.background;
//       textColor = themeColors.textPrimary;
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         border: Border.all(color: borderColor, width: 1),
//         borderRadius: BorderRadius.circular(8),
//         color: backgroundColor,
//       ),
//       child: ListTile(
//         enabled: !isOutOfStock && !isAdded,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         leading: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: isOutOfStock
//                 ? AppTheme.error.withAlpha(25)
//                 : AppTheme.primary.withAlpha(25),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             Icons.fastfood,
//             size: 20,
//             color: isOutOfStock ? AppTheme.error : AppTheme.primary,
//           ),
//         ),
//         title: Text(
//           item.name,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: isOutOfStock ? AppTheme.error : textColor,
//             decoration: isOutOfStock ? TextDecoration.lineThrough : null,
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const SizedBox(height: 4),
//             Text(
//               '₹${item.price.toStringAsFixed(2)}',
//               style: TextStyle(
//                 color: AppTheme.primary,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 4),
//             _buildStockBadge(
//               isOutOfStock: isOutOfStock,
//               isLowStock: isLowStock,
//               stockQuantity: item.stockQuantity,
//             ),
//           ],
//         ),
//         trailing: _buildTrailingWidget(
//           isAdded: isAdded,
//           isOutOfStock: isOutOfStock,
//           onAddItem: () => onAddItem(item),
//         ),
//       ),
//     );
//   }

//   static Widget _buildStockBadge({
//     required bool isOutOfStock,
//     required bool isLowStock,
//     required int stockQuantity,
//   }) {
//     Color badgeColor;
//     String badgeText;
//     IconData badgeIcon;

//     if (isOutOfStock) {
//       badgeColor = AppTheme.error;
//       badgeText = 'Out of Stock';
//       badgeIcon = Icons.block;
//     } else if (isLowStock) {
//       badgeColor = AppTheme.warning;
//       badgeText = 'Low Stock: $stockQuantity left';
//       badgeIcon = Icons.warning_amber;
//     } else {
//       badgeColor = AppTheme.success;
//       badgeText = 'In Stock: $stockQuantity';
//       badgeIcon = Icons.check_circle;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: badgeColor.withAlpha(25),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             badgeIcon,
//             size: 12,
//             color: badgeColor,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             badgeText,
//             style: TextStyle(
//               color: badgeColor,
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   static Widget _buildTrailingWidget({
//     required bool isAdded,
//     required bool isOutOfStock,
//     required VoidCallback onAddItem,
//   }) {
//     if (isAdded) {
//       return Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: AppTheme.success.withAlpha(25),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(
//           Icons.check,
//           color: AppTheme.success,
//           size: 20,
//         ),
//       );
//     }

//     if (isOutOfStock) {
//       return Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: AppTheme.error.withAlpha(25),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(
//           Icons.block,
//           color: AppTheme.error,
//           size: 20,
//         ),
//       );
//     }

//     return IconButton(
//       icon: Icon(
//         Icons.add_circle,
//         color: AppTheme.primary,
//         size: 28,
//       ),
//       onPressed: onAddItem,
//       tooltip: 'Add to order',
//     );
//   }
// }