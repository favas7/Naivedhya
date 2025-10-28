// // lib/Views/admin/order/add_order_screen/widgets/add_order_form_sections.dart
// import 'package:flutter/material.dart';
// import 'package:naivedhya/models/restaurant_model.dart';
// import 'package:naivedhya/models/ventor_model.dart';
// import 'package:naivedhya/models/customer_model.dart';
// import 'package:naivedhya/models/delivery_person_model.dart';

// class AddOrderFormSections {
//   // Section Header
//   static Widget buildSectionHeader(String title) {
//     print('🔍 [DEBUG] buildSectionHeader called with title: $title');
//     return Text(
//       title,
//       style: const TextStyle(
//         fontSize: 18,
//         fontWeight: FontWeight.w600,
//         color: Colors.black87,
//       ),
//     );
//   }

//   // Special Instructions Field (Order-wide, max 300 chars but displayed as 30 per requirements)
//   static Widget buildSpecialInstructionsField({
//     required TextEditingController controller,
//     required Function(String) onChanged,
//   }) {
//     print('🔍 [DEBUG] buildSpecialInstructionsField called');
//     print('🔍 [DEBUG] Current text: "${controller.text}"');
//     print('🔍 [DEBUG] Text length: ${controller.text.length}');
    
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: 'Special Instructions (Optional)',
//         hintText: 'e.g., Extra spicy, No onions, etc.',
//         border: const OutlineInputBorder(),
//         prefixIcon: const Icon(Icons.notes),
//         counterText: '${controller.text.length}/300',
//         helperText: 'Add any special instructions for this order',
//       ),
//       maxLines: 3,
//       maxLength: 300,
//       onChanged: (value) {
//         print('✏️ [DEBUG] Special instructions changed: "$value"');
//         print('✏️ [DEBUG] Length: ${value.length}');
//         onChanged(value);
//       },
//     );
//   }

//   // Payment Method Selection
//   static Widget buildPaymentMethodField({
//     required String selectedPaymentMethod,
//     required Function(String?) onChanged,
//   }) {
//     print('🔍 [DEBUG] buildPaymentMethodField called');
//     print('🔍 [DEBUG] Selected payment method: $selectedPaymentMethod');
    
//     final paymentMethods = ['Cash', 'UPI'];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Payment Method',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 12),
//         SegmentedButton<String>(
//           segments: paymentMethods.map((method) {
//             return ButtonSegment<String>(
//               value: method,
//               label: Text(method),
//               icon: method == 'Cash'
//                   ? const Icon(Icons.payments)
//                   : const Icon(Icons.mobile_screen_share),
//             );
//           }).toList(),
//           selected: {selectedPaymentMethod},
//           onSelectionChanged: (Set<String> newSelection) {
//             print('💳 [DEBUG] Payment method selected: ${newSelection.first}');
//             onChanged(newSelection.first);
//           },
//           style: ButtonStyle(
//             backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
//               if (states.contains(WidgetState.selected)) {
//                 return Colors.blue[600];
//               }
//               return Colors.white;
//             }),
//             foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
//               if (states.contains(WidgetState.selected)) {
//                 return Colors.white;
//               }
//               return Colors.black87;
//             }),
//           ),
//         ),
//       ],
//     );
//   }

//   // Customer Info Display
//   static Widget buildCustomerInfo({
//     required Customer customer,
//     required VoidCallback onClear,
//   }) {
//     print('🔍 [DEBUG] buildCustomerInfo called');
//     print('🔍 [DEBUG] Customer: ${customer.name}, Phone: ${customer.phone}');
    
//     return Container(
//       margin: const EdgeInsets.only(top: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.green[50],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.green[200]!),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             Icons.check_circle,
//             color: Colors.green[600],
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Customer: ${customer.name}',
//                   style: const TextStyle(fontWeight: FontWeight.w500),
//                 ),
//                 if (customer.phone != null && customer.phone!.isNotEmpty)
//                   Text(
//                     'Mobile: ${customer.phone}',
//                     style: const TextStyle(fontSize: 12),
//                   ),
//               ],
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.clear),
//             onPressed: () {
//               print('🗑️ [DEBUG] Customer cleared');
//               onClear();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // Order Summary
//   static Widget buildOrderSummary({
//     required Restaurant? selectedRestaurant,
//     required Vendor? selectedVendor,
//     required Customer? selectedCustomer,
//     required int orderItemsCount,
//     required double totalAmount,
//   }) {
//     print('🔍 [DEBUG] buildOrderSummary called');
//     print('🔍 [DEBUG] Restaurant: ${selectedRestaurant?.name}');
//     print('🔍 [DEBUG] Vendor: ${selectedVendor?.name}');
//     print('🔍 [DEBUG] Customer: ${selectedCustomer?.name}');
//     print('🔍 [DEBUG] Items count: $orderItemsCount');
//     print('🔍 [DEBUG] Total amount: $totalAmount');
    
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.blue[50],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.blue[200]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Order Summary',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 12),
//           if (selectedRestaurant != null)
//             _buildSummaryRow('Restaurant:', selectedRestaurant.name),
//           if (selectedVendor != null)
//             _buildSummaryRow('Vendor:', selectedVendor.name),
//           if (selectedCustomer != null)
//             _buildSummaryRow('Customer:', selectedCustomer.name),
//           const SizedBox(height: 8),
//           Divider(color: Colors.blue[200]),
//           const SizedBox(height: 8),
//           _buildSummaryRow(
//             'Items:',
//             '$orderItemsCount item${orderItemsCount != 1 ? 's' : ''}',
//             isHighlight: true,
//           ),
//           const SizedBox(height: 8),
//           _buildSummaryRow(
//             'Total Amount:',
//             '₹${totalAmount.toStringAsFixed(2)}',
//             isHighlight: true,
//           ),
//         ],
//       ),
//     );
//   }

//   static Widget _buildSummaryRow(
//     String label,
//     String value, {
//     bool isHighlight = false,
//   }) {
//     print('🔍 [DEBUG] _buildSummaryRow: $label -> $value (highlight: $isHighlight)');
    
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             color: Colors.black87,
//             fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
//           ),
//           textAlign: TextAlign.right,
//         ),
//       ],
//     );
//   }

//   // Restaurant Selection
//   static Widget buildRestaurantSelection({
//     required Restaurant? selectedRestaurant,
//     required List<Restaurant> restaurants,
//     required Function(Restaurant?) onChanged,
//     required String? Function(Restaurant?)? validator,
//   }) {
//     print('🔍 [DEBUG] buildRestaurantSelection called');
//     print('🔍 [DEBUG] Selected restaurant: ${selectedRestaurant?.name}');
//     print('🔍 [DEBUG] Available restaurants count: ${restaurants.length}');
//     print('🔍 [DEBUG] Restaurants: ${restaurants.map((r) => r.name).toList()}');
    
//     return DropdownButtonFormField<Restaurant>(
//       value: selectedRestaurant,
//       decoration: const InputDecoration(
//         labelText: 'Select Restaurant *',
//         border: OutlineInputBorder(),
//         prefixIcon: Icon(Icons.store),
//         helperText: 'Choose the Restaurant for this order',
//       ),
//       isExpanded: true,
//       itemHeight: 60,
//       items: restaurants.map((restaurant) {
//         print('🔍 [DEBUG] Adding restaurant to dropdown: ${restaurant.name}');
//         return DropdownMenuItem(
//           value: restaurant,
//           child: Text(
//             '${restaurant.name} - ${restaurant.address}',
//             overflow: TextOverflow.ellipsis,
//             maxLines: 1,
//           ),
//         );
//       }).toList(),
//       onChanged: (value) {
//         print('🏪 [DEBUG] Restaurant selected: ${value?.name}');
//         onChanged(value);
//       },
//       validator: validator,
//       menuMaxHeight: 300,
//     );
//   }

//   // Vendor Selection
//   static Widget buildVendorSelection({
//     required Vendor? selectedVendor,
//     required List<Vendor> vendors,
//     required Function(Vendor?) onChanged,
//     required String? Function(Vendor?)? validator,
//   }) {
//     print('🔍 [DEBUG] buildVendorSelection called');
//     print('🔍 [DEBUG] Selected vendor: ${selectedVendor?.name}');
//     print('🔍 [DEBUG] Available vendors count: ${vendors.length}');
//     print('🔍 [DEBUG] Vendors: ${vendors.map((v) => v.name).toList()}');
    
//     if (vendors.isEmpty) {
//       print('⚠️ [DEBUG] No vendors available!');
//       return Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.orange[50],
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.orange[200]!),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.warning, color: Colors.orange[700]),
//             const SizedBox(width: 12),
//             const Expanded(
//               child: Text(
//                 'No vendors available for this restaurant. Please add a vendor first.',
//                 style: TextStyle(color: Colors.black87),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return DropdownButtonFormField<Vendor>(
//       value: selectedVendor,
//       decoration: const InputDecoration(
//         labelText: 'Select Vendor *',
//         border: OutlineInputBorder(),
//         prefixIcon: Icon(Icons.business),
//         helperText: 'Choose the vendor/supplier for this order',
//       ),
//       isExpanded: true,
//       items: vendors.map((vendor) {
//         print('🔍 [DEBUG] Adding vendor to dropdown: ${vendor.name}');
//         return DropdownMenuItem(
//           value: vendor,
//           child: Text(
//             '${vendor.name} - ${vendor.serviceType}',
//             overflow: TextOverflow.ellipsis,
//           ),
//         );
//       }).toList(),
//       onChanged: (value) {
//         print('🏢 [DEBUG] Vendor selected: ${value?.name}');
//         onChanged(value);
//       },
//       validator: validator,
//     );
//   }

//   // Customer Search
//   static Widget buildCustomerSearch({
//     required TextEditingController controller,
//     required Function(String) onChanged,
//     required VoidCallback onAddNewCustomer,
//     required String? Function(String?)? validator,
//   }) {
//     print('🔍 [DEBUG] buildCustomerSearch called');
//     print('🔍 [DEBUG] Current search: "${controller.text}"');
    
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: 'Search Customer *',
//         hintText: 'Enter name or mobile number',
//         border: const OutlineInputBorder(),
//         prefixIcon: const Icon(Icons.search),
//         suffixIcon: IconButton(
//           icon: const Icon(Icons.add),
//           onPressed: () {
//             print('➕ [DEBUG] Add new customer button pressed');
//             onAddNewCustomer();
//           },
//           tooltip: 'Add New Customer',
//         ),
//       ),
//       onChanged: (value) {
//         print('🔍 [DEBUG] Customer search changed: "$value"');
//         onChanged(value);
//       },
//       validator: validator,
//     );
//   }

//   // Delivery Status Dropdown
//   static Widget buildDeliveryStatusDropdown({
//     required String selectedStatus,
//     required List<String> statusOptions,
//     required Function(String?) onChanged,
//   }) {
//     print('🔍 [DEBUG] buildDeliveryStatusDropdown called');
//     print('🔍 [DEBUG] Selected status: $selectedStatus');
//     print('🔍 [DEBUG] Status options: $statusOptions');
    
//     return DropdownButtonFormField<String>(
//       value: selectedStatus,
//       decoration: const InputDecoration(
//         labelText: 'Delivery Status',
//         border: OutlineInputBorder(),
//         prefixIcon: Icon(Icons.local_shipping),
//       ),
//       items: statusOptions.map((status) {
//         return DropdownMenuItem(value: status, child: Text(status));
//       }).toList(),
//       onChanged: (value) {
//         print('📦 [DEBUG] Delivery status changed: $value');
//         onChanged(value);
//       },
//     );
//   }

//   // Delivery Person Dropdown
//   static Widget buildDeliveryPersonDropdown({
//     required String? selectedPersonId,
//     required List<DeliveryPersonnel> deliveryPersons,
//     required bool hasSelectedRestaurant,
//     required Function(String?) onChanged,
//   }) {
//     print('🔍 [DEBUG] buildDeliveryPersonDropdown called');
//     print('🔍 [DEBUG] Selected person ID: $selectedPersonId');
//     print('🔍 [DEBUG] Available delivery persons count: ${deliveryPersons.length}');
//     print('🔍 [DEBUG] Has selected restaurant: $hasSelectedRestaurant');
//     print('🔍 [DEBUG] Delivery persons: ${deliveryPersons.map((p) => p.displayName).toList()}');
    
//     return DropdownButtonFormField<String>(
//       value: selectedPersonId,
//       isExpanded: true,
//       decoration: InputDecoration(
//         labelText: 'Delivery Partner',
//         border: const OutlineInputBorder(),
//         prefixIcon: const Icon(Icons.person),
//         helperText: deliveryPersons.isEmpty && hasSelectedRestaurant
//             ? 'No delivery partners available'
//             : null,
//       ),
//       items: [
//         const DropdownMenuItem<String>(
//           value: null,
//           child: Text('Select Delivery Partner (Optional)'),
//         ),
//         ...deliveryPersons.map((person) {
//           print('🔍 [DEBUG] Adding delivery person to dropdown: ${person.displayName} (${person.city}, ${person.state})');
//           return DropdownMenuItem(
//             value: person.userId,
//             child: SizedBox(
//               height: 40,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     person.displayName,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w500,
//                       fontSize: 13,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                   Text(
//                     '${person.city}, ${person.state}',
//                     style: const TextStyle(
//                       fontSize: 10,
//                       color: Colors.grey,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }),
//       ],
//       onChanged: (value) {
//         print('👤 [DEBUG] Delivery person selected: $value');
//         onChanged(value);
//       },
//       menuMaxHeight: 300,
//       itemHeight: 56,
//     );
//   }

//   // Delivery Time Field
//   static Widget buildDeliveryTimeField({
//     required DateTime? proposedDeliveryTime,
//     required VoidCallback onTap,
//   }) {
//     print('🔍 [DEBUG] buildDeliveryTimeField called');
//     print('🔍 [DEBUG] Proposed delivery time: $proposedDeliveryTime');
    
//     return InkWell(
//       onTap: () {
//         print('⏰ [DEBUG] Delivery time field tapped');
//         onTap();
//       },
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey[400]!),
//           borderRadius: BorderRadius.circular(4),
//         ),
//         child: Row(
//           children: [
//             const Icon(Icons.access_time, color: Colors.grey),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 proposedDeliveryTime != null
//                     ? 'Delivery: ${proposedDeliveryTime.day}/${proposedDeliveryTime.month}/${proposedDeliveryTime.year} ${proposedDeliveryTime.hour}:${proposedDeliveryTime.minute.toString().padLeft(2, '0')}'
//                     : 'Select proposed delivery time (Optional)',
//                 style: TextStyle(
//                   color: proposedDeliveryTime != null
//                       ? Colors.black87
//                       : Colors.grey[600],
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//             const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }