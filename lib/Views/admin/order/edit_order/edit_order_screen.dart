// // lib/Views/admin/order/edit_order_screen/edit_order_screen.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:naivedhya/Views/admin/order/add_order_screen/widget/add_order_dialogs.dart';
// import 'package:naivedhya/models/address_model.dart';
// import 'package:naivedhya/models/delivery_person_model.dart';
// import 'package:naivedhya/models/menu_model.dart';
// import 'package:naivedhya/models/order_item_model.dart';
// import 'package:naivedhya/models/order_model.dart';
// import 'package:naivedhya/models/user_model.dart';
// import 'package:naivedhya/services/adress_service.dart';
// import 'package:naivedhya/services/customer_service.dart';
// import 'package:naivedhya/services/delivery_person_service.dart';
// import 'package:naivedhya/services/menu_service.dart';
// import 'package:naivedhya/services/order/order_item_service.dart';
// import 'package:naivedhya/services/order/order_service.dart';
// import 'package:naivedhya/utils/color_theme.dart';

// class EditOrderScreen extends StatefulWidget {
//   final String orderId;

//   const EditOrderScreen({
//     super.key,
//     required this.orderId,
//   });

//   @override
//   State<EditOrderScreen> createState() => _EditOrderScreenState();
// }

// class _EditOrderScreenState extends State<EditOrderScreen> {
//   // Services
//   final OrderService _orderService = OrderService();
//   final AddOrderItemService _orderItemService = AddOrderItemService();
//   final DeliveryPersonnelService _deliveryService = DeliveryPersonnelService();
//   final AddressService _addressService = AddressService();
//   final CustomerService _customerService = CustomerService();
//   final MenuService _menuService = MenuService();

//   // Loading states
//   bool _isLoading = true;
//   bool _isSaving = false;

//   // Original order data
//   Order? _originalOrder;
//   Map<String, dynamic>? _enrichedOrderData;

//   // Editable data
//   List<OrderItem> _orderItems = [];
//   List<OrderItem> _originalOrderItems = [];
//   String? _selectedStatus;
//   String? _selectedDeliveryStatus;
//   String? _selectedPaymentMethod;
//   String? _specialInstructions;
//   DateTime? _proposedDeliveryTime;
//   DeliveryPersonnel? _selectedDeliveryPerson;
//   Address? _selectedAddress;
//   UserModel? _customer;

//   // Available options
//   List<DeliveryPersonnel> _availableDeliveryPersonnel = [];
//   List<Address> _customerAddresses = [];
//   List<MenuItem> _availableMenuItems = [];

//   // Status options with workflow validation
//   final List<String> _allStatuses = [
//     'Pending',
//     'Confirmed',
//     'Preparing',
//     'Ready',
//     'Picked up',
//     'Delivering',
//     'Completed',
//     'Cancelled',
//   ];

//   final List<String> _deliveryStatuses = [
//     'Pending',
//     'Assigned',
//     'Picked up',
//     'In Transit',
//     'Delivered',
//     'Failed',
//   ];

//   final List<String> _paymentMethods = ['Cash', 'Card', 'UPI', 'Online'];

//   @override
//   void initState() {
//     super.initState();
//     _loadOrderData();
//   }

//   /// Load order data with all details
//   Future<void> _loadOrderData() async {
//     setState(() => _isLoading = true);

//     try {
//       print('🔍 [EditOrderScreen] Loading order: ${widget.orderId}');

//       // Fetch enriched order data
//       _enrichedOrderData =
//           await _orderService.fetchOrderByIdWithDetails(widget.orderId);

//       if (_enrichedOrderData == null) {
//         throw Exception('Order not found');
//       }

//       _originalOrder = _enrichedOrderData!['order'] as Order;

//       // Set editable fields
//       _selectedStatus = _originalOrder!.status;
//       _selectedDeliveryStatus = _originalOrder!.deliveryStatus;
//       _proposedDeliveryTime = _originalOrder!.proposedDeliveryTime;

//       // Load order items
//       _originalOrderItems = await _orderItemService.getOrderItems(widget.orderId);
//       _orderItems = List.from(_originalOrderItems);

//       // Load customer data
//       if (_originalOrder!.customerId != null) {
//         _customer = await _customerService.getCustomerById(_originalOrder!.customerId!);
//         if (_customer != null) {
//           _customerAddresses = await _addressService.getAddressesByUserId(_customer!.id!);
          
//           // Find selected address
//           if (_originalOrder!.deliveryAddress != null) {
//             _selectedAddress = _customerAddresses.firstWhere(
//               (addr) => addr.addressId == _originalOrder!.deliveryAddress,
//               orElse: () => _customerAddresses.isNotEmpty
//                   ? _customerAddresses.first
//                   : Address(userId: _customer!.id!, fullAddress: ''),
//             );
//           }
//         }
//       }

//       // Load delivery personnel
//       if (_originalOrder!.deliveryPersonId != null) {
//         _selectedDeliveryPerson = await _deliveryService
//             .fetchDeliveryPersonnelById(_originalOrder!.deliveryPersonId!);
//       }

//       // Load available delivery personnel
//       _availableDeliveryPersonnel =
//           await _deliveryService.fetchAvailableDeliveryPersonnel();

//       // Load available menu items for adding more
//       _availableMenuItems =
//           await _menuService.getMenuItems(_originalOrder!.restaurantId);

//       print('✅ [EditOrderScreen] Order data loaded successfully');
//     } catch (e) {
//       print('❌ [EditOrderScreen] Error loading order: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading order: $e')),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   /// Check if status change is valid based on workflow
//   bool _isValidStatusChange(String currentStatus, String newStatus) {
//     final currentIndex = _allStatuses.indexOf(currentStatus);
//     final newIndex = _allStatuses.indexOf(newStatus);

//     // Allow cancellation from any status except completed
//     if (newStatus == 'Cancelled' && currentStatus != 'Completed') {
//       return true;
//     }

//     // Can't change from completed or cancelled
//     if (currentStatus == 'Completed' || currentStatus == 'Cancelled') {
//       return false;
//     }

//     // Can only move forward or stay same
//     return newIndex >= currentIndex;
//   }

//   /// Get available statuses based on current status
//   List<String> _getAvailableStatuses() {
//     if (_selectedStatus == null) return _allStatuses;

//     return _allStatuses.where((status) {
//       return _isValidStatusChange(_selectedStatus!, status);
//     }).toList();
//   }

//   /// Add menu item to order
//   void _addMenuItem(MenuItem item) {
//     final orderItem = OrderItem(
//       orderId: widget.orderId,
//       itemId: item.itemId!,
//       itemName: item.name,
//       quantity: 1,
//        price: item.price,
//     );

//     setState(() {
//       _orderItems.add(orderItem);
//     });
//   }

//   /// Remove item from order
//   void _removeOrderItem(int index) {
//     setState(() {
//       _orderItems.removeAt(index);
//     });
//   }

//   /// Update item quantity
//   void _updateItemQuantity(int index, int newQuantity) {
//     if (newQuantity <= 0) {
//       _removeOrderItem(index);
//       return;
//     }

//     setState(() {
//       final item = _orderItems[index];
//       _orderItems[index] = item.copyWith(
//         quantity: newQuantity,
//       );
//     });
//   }

//   /// Calculate total amount
//   double get _totalAmount {
//     return _orderItems.fold(0.0, (sum, item) => sum + item.totalPrice);
//   }

//   /// Check if order has been modified
//   bool get _hasChanges {
//     if (_originalOrder == null) return false;

//     // Check basic fields
//     if (_selectedStatus != _originalOrder!.status) return true;
//     if (_selectedDeliveryStatus != _originalOrder!.deliveryStatus) return true;
//     if (_selectedPaymentMethod != _originalOrder!.paymentMethod) return true;
//     if (_specialInstructions != _originalOrder!.specialInstructions) return true;
//     if (_proposedDeliveryTime != _originalOrder!.proposedDeliveryTime) return true;
//     if (_selectedDeliveryPerson?.userId != _originalOrder!.deliveryPersonId) return true;
//     if (_selectedAddress?.addressId != _originalOrder!.deliveryAddress) return true;

//     // Check if order items changed
//     if (_orderItems.length != _originalOrderItems.length) return true;

//     for (int i = 0; i < _orderItems.length; i++) {
//       if (_orderItems[i].quantity != _originalOrderItems[i].quantity) return true;
//       if (_orderItems[i].itemId != _originalOrderItems[i].itemId) return true;
//     }

//     return false;
//   }

//   /// Save order changes
//   Future<void> _saveChanges() async {
//     if (!_hasChanges) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No changes to save')),
//       );
//       return;
//     }

//     setState(() => _isSaving = true);

//     try {
//       print('💾 [EditOrderScreen] Saving order changes...');

//       // Prepare order updates
//       final orderUpdates = {
//         'status': _selectedStatus,
//         'delivery_status': _selectedDeliveryStatus,
//         'payment_method': _selectedPaymentMethod,
//         'special_instructions': _specialInstructions,
//         'proposed_delivery_time': _proposedDeliveryTime?.toIso8601String(),
//         'delivery_person_id': _selectedDeliveryPerson?.userId,
//         'delivery_address': _selectedAddress?.addressId,
//         'total_amount': _totalAmount,
//         'updated_at': DateTime.now().toIso8601String(),
//       };

//       // Update order
//       await _orderService.updateOrder(widget.orderId, orderUpdates);

//       // Update order items if changed
//       final itemsChanged = _orderItems.length != _originalOrderItems.length ||
//           _orderItems.any((item) {
//             final original = _originalOrderItems.firstWhere(
//               (orig) => orig.itemId == item.itemId,
//               orElse: () => OrderItem(
//                 itemId: '',
//                 itemName: '',
//                 quantity: 0,
//                  orderId: '', 
//                  price: 0.0,

//               ),
//             );
//             return item.quantity != original.quantity;
//           });

//       if (itemsChanged) {
//         print('📦 [EditOrderScreen] Updating order items...');
        
//         // Prepare order items with proper order_id
//         final itemsToSave = _orderItems.map((item) {
//           return item.copyWith(orderId: widget.orderId);
//         }).toList();

//         await _orderItemService.replaceOrderItems(widget.orderId, itemsToSave);
//       }

//       print('✅ [EditOrderScreen] Order updated successfully');

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Order updated successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );

//         // Navigate back with result
//         Navigator.of(context).pop(true);
//       }
//     } catch (e) {
//       print('❌ [EditOrderScreen] Error saving changes: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error saving changes: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }

//   /// Show menu item selection dialog
//   void _showMenuItemSelection() {
//     AddOrderDialogs.showMenuItemSelection(
//       context: context,
//       restaurantName: _enrichedOrderData?['restaurant']?['name'] ?? 'Restaurant',
//       menuItems: _availableMenuItems,
//       currentOrderItems: _orderItems,
//       onAddItem: _addMenuItem,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Order ${_originalOrder?.orderNumber ?? ''}'),
//         elevation: 0,
//         actions: [
//           if (_hasChanges)
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: _loadOrderData,
//               tooltip: 'Reset Changes',
//             ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _originalOrder == null
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.error, size: 64, color: Colors.red),
//                       const SizedBox(height: 16),
//                       const Text('Order not found'),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: () => Navigator.of(context).pop(),
//                         child: const Text('Go Back'),
//                       ),
//                     ],
//                   ),
//                 )
//               : SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       if (_hasChanges) _buildChangesIndicator(),
//                       const SizedBox(height: 16),
//                       _buildOrderInfoSection(),
//                       const SizedBox(height: 20),
//                       _buildCustomerSection(),
//                       const SizedBox(height: 20),
//                       _buildStatusSection(),
//                       const SizedBox(height: 20),
//                       _buildDeliverySection(),
//                       const SizedBox(height: 20),
//                       _buildOrderItemsSection(),
//                       const SizedBox(height: 20),
//                       _buildOrderSummary(context),
//                       const SizedBox(height: 20),
//                       _buildAdditionalDetailsSection(),
//                       const SizedBox(height: 32),
//                       _buildActionButtons(),
//                     ], 
//                   ),
//                 ),
//     );
//   }

//   Widget _buildChangesIndicator() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.orange[100],
//         border: Border.all(color: Colors.orange[300]!),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.info, color: Colors.orange[700]),
//           const SizedBox(width: 12),
//           const Expanded(
//             child: Text(
//               'You have unsaved changes',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOrderInfoSection() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Order Information',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const Divider(),
//             _buildInfoRow('Order Number', _originalOrder!.orderNumber),
//             _buildInfoRow('Restaurant',
//                 _enrichedOrderData?['restaurant']?['name'] ?? 'N/A'),
//             _buildInfoRow('Vendor',
//                 _enrichedOrderData?['vendor']?['name'] ?? 'N/A'),
//             _buildInfoRow(
//               'Created At',
//               DateFormat('MMM dd, yyyy - hh:mm a')
//                   .format(_originalOrder!.createdAt!),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// Widget _buildCustomerSection() {
//   return Card(
//     child: Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Customer Details',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const Divider(),
//           if (_customer != null) ...[
//             _buildInfoRow('Name', _customer!.name),
//             if (_customer!.phone.isNotEmpty)
//               _buildInfoRow('Phone', _customer!.phone),
//             if (_customer!.email.isNotEmpty)
//               _buildInfoRow('Email', _customer!.email),
//             const SizedBox(height: 12),
//             if (_customerAddresses.isNotEmpty) ...[
//               const Text(
//                 'Delivery Address',
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(height: 8),
//               DropdownButtonFormField<Address>(
//                 value: _selectedAddress,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.location_on),
//                   hintText: 'Select an address',
//                 ),
//                 items: _customerAddresses.map((address) {
//                   return DropdownMenuItem(
//                     value: address,
//                     child: Text(
//                       address.label ?? 'Address',
//                       style: const TextStyle(fontWeight: FontWeight.w500),
//                     ),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() => _selectedAddress = value);
//                 },
//               ),
//               const SizedBox(height: 12),
//               // Address details box
//               if (_selectedAddress != null)
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).brightness == Brightness.dark
//                         ? Colors.grey.shade800
//                         : Colors.grey.shade100,
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           const Icon(Icons.location_on, 
//                             size: 16, 
//                             color: Colors.grey,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             _selectedAddress!.label ?? 'Selected Address',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         _selectedAddress!.fullAddress,
//                         style: TextStyle(
//                           color: Colors.grey.shade700,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ] else
//             const Text(
//               'Customer information not available',
//               style: TextStyle(color: Colors.grey),
//             ),
//         ],
//       ),
//     ),
//   );
// } 

//   Widget _buildStatusSection() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Status Management',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const Divider(),
//             DropdownButtonFormField<String>(
//               value: _selectedStatus,
//               decoration: const InputDecoration(
//                 labelText: 'Order Status',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.assignment),
//               ),
//               items: _getAvailableStatuses().map((status) {
//                 return DropdownMenuItem(
//                   value: status,
//                   child: Row(
//                     children: [
//                       _buildStatusIndicator(status),
//                       const SizedBox(width: 8),
//                       Text(status),
//                     ],
//                   ),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() => _selectedStatus = value);
//               },
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: _selectedDeliveryStatus,
//               decoration: const InputDecoration(
//                 labelText: 'Delivery Status',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.local_shipping),
//               ),
//               items: _deliveryStatuses.map((status) {
//                 return DropdownMenuItem(
//                   value: status,
//                   child: Text(status),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() => _selectedDeliveryStatus = value);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDeliverySection() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Delivery Assignment',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const Divider(),
//             DropdownButtonFormField<DeliveryPersonnel>(
//               value: _selectedDeliveryPerson,
//               decoration: const InputDecoration(
//                 labelText: 'Assign Delivery Person',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.delivery_dining),
//               ),
//               hint: const Text('Not Assigned'),
//               items: [
//                 const DropdownMenuItem<DeliveryPersonnel>(
//                   value: null,
//                   child: Text('Not Assigned'),
//                 ),
//                 ..._availableDeliveryPersonnel.map((person) {
//                   return DropdownMenuItem(
//                     value: person,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           person.fullName,
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           '${person.vehicleType} - ${person.numberPlate}',
//                           style: const TextStyle(fontSize: 12),
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ],
//               onChanged: (value) {
//                 setState(() => _selectedDeliveryPerson = value);
//               },
//             ),
//             if (_selectedDeliveryPerson != null) ...[
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.blue[200]!),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(Icons.person, size: 20, color: Colors.blue),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             _selectedDeliveryPerson!.fullName,
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Text('Phone: ${_selectedDeliveryPerson!.phone}'),
//                     Text('Vehicle: ${_selectedDeliveryPerson!.vehicleInfo}'),
//                     Text(
//                       'Active Orders: ${_selectedDeliveryPerson!.activeOrdersCount}',
//                     ),
//                     if (_selectedDeliveryPerson!.rating > 0)
//                       Row(
//                         children: [
//                           const Icon(Icons.star, size: 16, color: Colors.amber),
//                           const SizedBox(width: 4),
//                           Text(
//                             _selectedDeliveryPerson!.rating.toStringAsFixed(1),
//                             style: const TextStyle(fontWeight: FontWeight.w600),
//                           ),
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOrderItemsSection() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Order Items',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: _showMenuItemSelection,
//                   icon: const Icon(Icons.add, size: 20),
//                   label: const Text('Add Item'),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(),
//             if (_orderItems.isEmpty)
//               const Center(
//                 child: Padding(
//                   padding: EdgeInsets.all(20),
//                   child: Text(
//                     'No items in order',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//               )
//             else
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: _orderItems.length,
//                 itemBuilder: (context, index) {
//                   final item = _orderItems[index];
//                   return Card(
//                     margin: const EdgeInsets.only(bottom: 8),
//                     child: ListTile(
//                      title: Text(item.itemName ?? 'Unnamed Item'),
//                       subtitle: Text(
//                         '₹${item.price.toStringAsFixed(2)} × ${item.quantity} = ₹${item.totalPrice.toStringAsFixed(2)}',
//                       ),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.remove_circle_outline),
//                             onPressed: () =>
//                                 _updateItemQuantity(index, item.quantity - 1),
//                           ),
//                           Text(
//                             item.quantity.toString(),
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.add_circle_outline),
//                             onPressed: () =>
//                                 _updateItemQuantity(index, item.quantity + 1),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.delete, color: Colors.red),
//                             onPressed: () => _removeOrderItem(index),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }

// Widget _buildOrderSummary(BuildContext context) {
//   final theme = AppTheme.of(context);
//   final textTheme = Theme.of(context).textTheme;
//   final originalTotal = _originalOrder!.totalAmount;
//   final hasAmountChanged = (_totalAmount - originalTotal).abs() > 0.01;

//   // Define dynamic colors
//   final cardColor = hasAmountChanged
//       ? theme.warning.withOpacity(0.08)
//       : theme.info.withOpacity(0.08);
//   final amountColor = hasAmountChanged ? theme.warning : theme.info;
//   final textPrimary = theme.textPrimary;
//   final textSecondary = theme.textSecondary;

//   return Card(
//     color: cardColor,
//     surfaceTintColor: Colors.transparent,
//     elevation: 0,
//     child: Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Order Summary',
//             style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           const Divider(),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text('Items:', style: textTheme.bodyLarge),
//               Text(
//                 _orderItems.length.toString(),
//                 style: textTheme.bodyLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: textPrimary,
//                 ),
//               ),
//             ],
//           ),
//           if (hasAmountChanged) ...[
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Original Amount:', style: textTheme.bodyLarge),
//                 Text(
//                   '₹${originalTotal.toStringAsFixed(2)}',
//                   style: textTheme.bodyLarge?.copyWith(
//                     decoration: TextDecoration.lineThrough,
//                     color: textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 hasAmountChanged ? 'New Total Amount:' : 'Total Amount:',
//                 style: textTheme.titleMedium,
//               ),
//               Text(
//                 '₹${_totalAmount.toStringAsFixed(2)}',
//                 style: textTheme.headlineMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: amountColor,
//                 ),
//               ),
//             ],
//           ),
//           if (hasAmountChanged) ...[
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: theme.warning.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.info, size: 16, color: theme.warning),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Amount changed by ₹${(_totalAmount - originalTotal).abs().toStringAsFixed(2)}',
//                     style: textTheme.bodySmall?.copyWith(
//                       color: theme.warning,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     ),
//   );
// }


//   Widget _buildAdditionalDetailsSection() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Additional Details',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const Divider(),
//             DropdownButtonFormField<String>(
//               value: _selectedPaymentMethod,
//               decoration: const InputDecoration(
//                 labelText: 'Payment Method',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.payment),
//               ),
//               items: _paymentMethods
//                   .map((method) => DropdownMenuItem(
//                         value: method,
//                         child: Text(method),
//                       ))
//                   .toList(),
//               onChanged: (value) {
//                 setState(() => _selectedPaymentMethod = value);
//               },
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               decoration: const InputDecoration(
//                 labelText: 'Special Instructions (Optional)',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.note),
//               ),
//               maxLines: 3,
//               controller: TextEditingController(text: _specialInstructions),
//               onChanged: (value) => _specialInstructions = value,
//             ),
//             const SizedBox(height: 16),
//             ListTile(
//               contentPadding: EdgeInsets.zero,
//               leading: const Icon(Icons.access_time),
//               title: const Text('Proposed Delivery Time (Optional)'),
//               subtitle: _proposedDeliveryTime != null
//                   ? Text(DateFormat('MMM dd, yyyy - hh:mm a')
//                       .format(_proposedDeliveryTime!))
//                   : const Text('Not set'),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (_proposedDeliveryTime != null)
//                     IconButton(
//                       icon: const Icon(Icons.clear),
//                       onPressed: () {
//                         setState(() => _proposedDeliveryTime = null);
//                       },
//                     ),
//                   IconButton(
//                     icon: const Icon(Icons.calendar_today),
//                     onPressed: () async {
//                       final date = await showDatePicker(
//                         context: context,
//                         initialDate: _proposedDeliveryTime ?? DateTime.now(),
//                         firstDate: DateTime.now(),
//                         lastDate: DateTime.now().add(const Duration(days: 30)),
//                       );

//                       if (date != null && mounted) {
//                         final time = await showTimePicker(
//                           context: context,
//                           initialTime: TimeOfDay.fromDateTime(
//                             _proposedDeliveryTime ?? DateTime.now(),
//                           ),
//                         );

//                         if (time != null && mounted) {
//                           setState(() {
//                             _proposedDeliveryTime = DateTime(
//                               date.year,
//                               date.month,
//                               date.day,
//                               time.hour,
//                               time.minute,
//                             );
//                           });
//                         }
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: OutlinedButton(
//             onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
//             style: OutlinedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//             ),
//             child: const Text('Cancel', style: TextStyle(fontSize: 16)),
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           flex: 2,
//           child: ElevatedButton(
//             onPressed: _isSaving || !_hasChanges ? null : _saveChanges,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//             ),
//             child: _isSaving
//                 ? const SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2,
//                     ),
//                   )
//                 : const Text(
//                     'Save Changes',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               '$label:',
//               style: const TextStyle(
//                 color: Colors.grey,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusIndicator(String status) {
//     Color color;
//     switch (status.toLowerCase()) {
//       case 'pending':
//         color = Colors.orange;
//         break;
//       case 'confirmed':
//         color = Colors.blue;
//         break;
//       case 'preparing':
//         color = Colors.purple;
//         break;
//       case 'ready':
//         color = Colors.teal;
//         break;
//       case 'picked up':
//         color = Colors.indigo;
//         break;
//       case 'delivering':
//         color = Colors.cyan;
//         break;
//       case 'completed':
//         color = Colors.green;
//         break;
//       case 'cancelled':
//         color = Colors.red;
//         break;
//       default:
//         color = Colors.grey;
//     }
 
//     return Container(
//       width: 12,
//       height: 12,
//       decoration: BoxDecoration(
//         color: color,
//         shape: BoxShape.circle,
//       ),
//     );
//   }
// }