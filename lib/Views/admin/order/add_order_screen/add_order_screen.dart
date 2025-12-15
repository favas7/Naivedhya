// // lib/Views/admin/order/add_order_screen/add_order_screen.dart
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:naivedhya/Views/admin/order/add_order_screen/widget/add_order_dialogs.dart';
// import 'package:naivedhya/Views/admin/order/add_order_screen/widget/additional_details_card.dart';
// import 'package:naivedhya/Views/admin/order/add_order_screen/widget/customer_section_card.dart';
// import 'package:naivedhya/Views/admin/order/add_order_screen/widget/order_items_section_card.dart';
// import 'package:naivedhya/Views/admin/order/add_order_screen/widget/order_summary_card.dart';
// import 'package:naivedhya/Views/admin/order/add_order_screen/widget/restaurant_selector_card.dart';
// import 'package:naivedhya/Views/admin/order/add_order_screen/widget/vendor_selector_card.dart';
// import 'package:naivedhya/models/address_model.dart';
// import 'package:naivedhya/models/customer_model.dart';
// import 'package:naivedhya/models/menu_model.dart';
// import 'package:naivedhya/models/order_item_model.dart';
// import 'package:naivedhya/models/restaurant_model.dart';
// import 'package:naivedhya/models/user_model.dart';
// import 'package:naivedhya/services/adress_service.dart';
// import 'package:naivedhya/services/customer_service.dart';
// import 'package:naivedhya/services/menu_service.dart';
// import 'package:naivedhya/services/order/order_service.dart';
// import 'package:naivedhya/services/order/order_validation_service.dart';
// import 'package:naivedhya/services/restaurant_service.dart';
// import 'package:naivedhya/services/ventor_service.dart';
// import 'package:naivedhya/utils/color_theme.dart';
// import 'package:uuid/uuid.dart';

// class AddOrderScreen extends StatefulWidget {
//   const AddOrderScreen({super.key});

//   @override
//   State<AddOrderScreen> createState() => _AddOrderScreenState();
// }

// class _AddOrderScreenState extends State<AddOrderScreen> {
//   // Services
//   final RestaurantService _restaurantService = RestaurantService();
//   final VendorService _vendorService = VendorService();
//   final CustomerService _customerService = CustomerService();
//   final MenuService _menuService = MenuService();
//   final AddressService _addressService = AddressService();
//   final OrderService _orderService = OrderService();

//   // Loading states
//   bool _isLoadingRestaurants = false;
//   bool _isLoadingVendors = false;
//   bool _isSubmitting = false;

//   // Data lists
//   List<Restaurant> _restaurants = [];
//   List<Map<String, dynamic>> _vendors = [];
//   List<UserModel> _customers = [];
//   List<MenuItem> _menuItems = [];
//   List<Address> _customerAddresses = [];

//   // Selected values
//   Restaurant? _selectedRestaurant;
//   Map<String, dynamic>? _selectedVendor;
//   UserModel? _selectedCustomer;
//   Address? _selectedAddress;
//   final List<OrderItem> _orderItems = [];

//   // Guest details
//   bool _isGuestOrder = false;
//   String? _guestName;
//   String? _guestMobile;
//   String? _guestAddress;

//   // Order details
//   String _paymentMethod = 'Cash';
//   String? _specialInstructions;
//   DateTime? _proposedDeliveryTime;

//   // Text controllers for dialogs
//   final _customerNameController = TextEditingController();
//   final _customerMobileController = TextEditingController();
//   final _customerEmailController = TextEditingController();
//   final _customerAddressController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadRestaurants();
//   }

//   @override
//   void dispose() {
//     _customerNameController.dispose();
//     _customerMobileController.dispose();
//     _customerEmailController.dispose();
//     _customerAddressController.dispose();
//     super.dispose();
//   }

//   /// Load restaurants filtered by current admin email
//   Future<void> _loadRestaurants() async {
//     setState(() => _isLoadingRestaurants = true);

//     try {
//       final currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser == null || currentUser.email == null) {
//         throw Exception('No authenticated user found');
//       }

//       print('🔍 Loading restaurants for email: ${currentUser.email}');
//       _restaurants =
//           await _restaurantService.getRestaurantsByAdminEmail(currentUser.email!);

//       print('✅ Loaded ${_restaurants.length} restaurants');

//       // Auto-select if only one restaurant
//       if (_restaurants.length == 1) {
//         _selectedRestaurant = _restaurants.first;
//         await _loadVendors();
//         await _loadMenuItems();
//       }
//     } catch (e) {
//       print('❌ Error loading restaurants: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading restaurants: $e')),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoadingRestaurants = false);
//     }
//   }

//   /// Load vendors for selected restaurant
//   Future<void> _loadVendors() async {
//     if (_selectedRestaurant == null) return;

//     setState(() => _isLoadingVendors = true);

//     try {
//       print('🔍 Loading vendors for restaurant: ${_selectedRestaurant!.id}');
//       _vendors = await _vendorService
//           .fetchVendorsByRestaurant(_selectedRestaurant!.id!);

//       print('✅ Loaded ${_vendors.length} vendors');

//       // Auto-select if only one vendor
//       if (_vendors.length == 1) {
//         _selectedVendor = _vendors.first;
//       }
//     } catch (e) {
//       print('❌ Error loading vendors: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading vendors: $e')),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoadingVendors = false);
//     }
//   }

//   /// Load menu items for selected restaurant
//   Future<void> _loadMenuItems() async {
//     if (_selectedRestaurant == null) return;

//     try {
//       print('🔍 Loading menu items for restaurant: ${_selectedRestaurant!.id}');
//       _menuItems = await _menuService.getMenuItems(_selectedRestaurant!.id!);
//       print('✅ Loaded ${_menuItems.length} menu items');
//     } catch (e) {
//       print('❌ Error loading menu items: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading menu items: $e')),
//         );
//       }
//     } finally {
//       if (mounted) setState(() {});
//     }
//   }

//   /// Load customers for selection
//   Future<void> _loadCustomers() async {
//     try {
//       print('🔍 Loading customers...');
//       _customers = await _customerService.getAllCustomers();
//       print('✅ Loaded ${_customers.length} customers');
//     } catch (e) {
//       print('❌ Error loading customers: $e');
//     } finally {
//       if (mounted) setState(() {});
//     }
//   }

//   /// Load addresses for selected customer
//   Future<void> _loadCustomerAddresses() async {
//     if (_selectedCustomer == null) return;

//     try {
//       print('🔍 Loading addresses for customer: ${_selectedCustomer!.id}');
//       _customerAddresses =
//           await _addressService.getAddressesByUserId(_selectedCustomer!.id!);

//       print('✅ Loaded ${_customerAddresses.length} addresses');

//       // Auto-select default address
//       final defaultAddress = _customerAddresses.firstWhere(
//         (addr) => addr.isDefault,
//         orElse: () => _customerAddresses.isNotEmpty
//             ? _customerAddresses.first
//             : Address(userId: _selectedCustomer!.id!, fullAddress: ''),
//       );

//       setState(() => _selectedAddress = defaultAddress);
//     } catch (e) {
//       print('❌ Error loading addresses: $e');
//     }
//   }

//   /// Show customer selection dialog
//   void _showCustomerSelection() async {
//     await _loadCustomers();

//     if (!mounted) return;

//     final customers = _customers
//         .map((user) => Customer.fromUserModel(user))
//         .toList();

//     AddOrderDialogs.showCustomerSelection(
//       context: context,
//       customers: customers,
//       onCustomerSelected: (customer) {
//         setState(() {
//           _selectedCustomer =
//               _customers.firstWhere((user) => user.id == customer.id);
//           _isGuestOrder = false;
//         });
//         _loadCustomerAddresses();
//       },
//       onAddNewCustomer: _showAddNewCustomer,
//       onContinueAsGuest: _showGuestDetails,
//     );
//   }

//   /// Show add new customer dialog
//   void _showAddNewCustomer() {
//     _customerNameController.clear();
//     _customerMobileController.clear();
//     _customerEmailController.clear();
//     _customerAddressController.clear();

//     AddOrderDialogs.showAddNewCustomer(
//       context: context,
//       nameController: _customerNameController,
//       mobileController: _customerMobileController,
//       emailController: _customerEmailController,
//       addressController: _customerAddressController,
//       onSubmit: _createNewCustomer,
//     );
//   }

//   /// Create new customer
//   Future<void> _createNewCustomer() async {
//     final validation = OrderValidationService.validateCustomerForm(
//       name: _customerNameController.text,
//       mobile: _customerMobileController.text,
//       address: _customerAddressController.text,
//     );

//     if (!validation.isValid) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(validation.errorMessage!)),
//       );
//       return;
//     }

//     try {
//       final newCustomer = await _customerService.createCustomer(
//         name: _customerNameController.text.trim(),
//         mobile: _customerMobileController.text.trim(),
//         address: _customerAddressController.text.trim(),
//         email: _customerEmailController.text.trim().isEmpty
//             ? null
//             : _customerEmailController.text.trim(),
//       );

//       // Create address for the new customer
//       await _addressService.createAddress(Address(
//         userId: newCustomer.id!,
//         fullAddress: _customerAddressController.text.trim(),
//         label: 'Home',
//         isDefault: true,
//       ));

//       setState(() {
//         _selectedCustomer = newCustomer;
//         _isGuestOrder = false;
//       });

//       await _loadCustomerAddresses();

//       if (mounted) {
//         Navigator.of(context).pop();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Customer created successfully')),
//         );
//       }
//     } catch (e) {
//       print('❌ Error creating customer: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error creating customer: $e')),
//         );
//       }
//     }
//   }

//   /// Show guest details dialog
//   void _showGuestDetails() {
//     _customerNameController.clear();
//     _customerMobileController.clear();
//     _customerAddressController.clear();

//     AddOrderDialogs.showAddGuestDetails(
//       context: context,
//       nameController: _customerNameController,
//       mobileController: _customerMobileController,
//       addressController: _customerAddressController,
//       onSubmit: _continueAsGuest,
//     );
//   }

//   /// Continue as guest
//   void _continueAsGuest() {
//     final validation = OrderValidationService.validateCustomerForm(
//       name: _customerNameController.text,
//       mobile: _customerMobileController.text,
//       address: _customerAddressController.text,
//     );

//     if (!validation.isValid) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(validation.errorMessage!)),
//       );
//       return;
//     }

//     setState(() {
//       _isGuestOrder = true;
//       _guestName = _customerNameController.text.trim();
//       _guestMobile = _customerMobileController.text.trim();
//       _guestAddress = _customerAddressController.text.trim();
//       _selectedCustomer = null;
//       _selectedAddress = null;
//     });

//     Navigator.of(context).pop();
//   }

//   /// Show menu item selection dialog
//   void _showMenuItemSelection() {
//     if (_selectedRestaurant == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a restaurant first')),
//       );
//       return;
//     }

//     AddOrderDialogs.showMenuItemSelection(
//       context: context,
//       restaurantName: _selectedRestaurant!.name,
//       menuItems: _menuItems,
//       currentOrderItems: _orderItems,
//       onAddItem: _addMenuItem,
//     );
//   }

//   /// Add menu item to order
//   void _addMenuItem(MenuItem item) {
//     final orderItem = OrderItem(
//       itemId: item.itemId!,
//       itemName: item.name,
//       quantity: 1,
//       orderId: '',
//       price: item.price,
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
//       _orderItems[index] = item.copyWith(quantity: newQuantity);
//     });
//   }

//   /// Calculate total amount
//   double get _totalAmount {
//     return _orderItems.fold(0.0, (sum, item) => sum + item.totalPrice);
//   }

//   /// Generate order number (ORD-YYYYMMDD-NNN)
//   String _generateOrderNumber() {
//     final now = DateTime.now();
//     final dateStr = DateFormat('yyyyMMdd').format(now);
//     final randomNum = (DateTime.now().millisecondsSinceEpoch % 1000)
//         .toString()
//         .padLeft(3, '0');
//     return 'ORD-$dateStr-$randomNum';
//   }

//   /// Submit order
//   Future<void> _submitOrder() async {
//     // Validation
//     final validation = OrderValidationService.validateAddOrder(
//       selectedRestaurant: _selectedRestaurant,
//       selectedVendor: _selectedVendor,
//       isGuestOrder: _isGuestOrder,
//       selectedCustomer: _selectedCustomer,
//       guestName: _guestName,
//       guestMobile: _guestMobile,
//       guestAddress: _guestAddress,
//       orderItems: _orderItems,
//       selectedAddress: _selectedAddress,
//     );

//     if (!validation.isValid) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(validation.errorMessage!)),
//       );
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     try {
//       String? customerId;
//       String? addressId;

//       // Handle guest order - create customer first
//       if (_isGuestOrder) {
//         final guestCustomer = await _customerService.createCustomer(
//           name: _guestName!,
//           mobile: _guestMobile!,
//           address: _guestAddress!,
//         );

//         customerId = guestCustomer.id;

//         // Create address for guest
//         final guestAddressObj = await _addressService.createAddress(Address(
//           userId: customerId!,
//           fullAddress: _guestAddress!,
//           label: 'Guest Address',
//           isDefault: true,
//         ));

//         addressId = guestAddressObj.addressId;
//       } else {
//         customerId = _selectedCustomer!.id;
//         addressId = _selectedAddress!.addressId;
//       }

//       // Generate order number
//       final orderNumber = _generateOrderNumber();

//       // Prepare order data
//       final orderData = {
//         'order_id': const Uuid().v4(),
//         'customer_id': customerId,
//         'vendor_id': _selectedVendor!['vendor_id'],
//         'hotel_id': _selectedRestaurant!.id,
//         'order_number': orderNumber,
//         'total_amount': _totalAmount,
//         'status': 'Pending',
//         'customer_name': _isGuestOrder ? _guestName : _selectedCustomer!.name,
//         'delivery_address': addressId,
//         'payment_method': _paymentMethod,
//         'special_instructions': _specialInstructions,
//         'proposed_delivery_time': _proposedDeliveryTime?.toIso8601String(),
//         'created_at': DateTime.now().toIso8601String(),
//         'updated_at': DateTime.now().toIso8601String(),
//       };

//       print('📦 Creating order with data: $orderData');

//       // Create order
//       final newOrder = await _orderService.createOrder(orderData);

//       print('✅ Order created: ${newOrder.orderNumber}');

//       // TODO: Create order items in order_items table

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Order ${newOrder.orderNumber} created successfully!'),
//             backgroundColor: AppTheme.success,
//           ),
//         );

//         // Navigate back
//         Navigator.of(context).pop(true);
//       }
//     } catch (e) {
//       print('❌ Error creating order: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error creating order: $e'),
//             backgroundColor: AppTheme.error,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeColors = AppTheme.of(context);

//     return Scaffold(
//       backgroundColor: themeColors.background,
//       appBar: AppBar(
//         title: const Text('Create New Order'),
//         backgroundColor: themeColors.surface,
//         elevation: 1,
//       ),
//       body: _isLoadingRestaurants
//           ? const Center(child: CircularProgressIndicator())
//           : _restaurants.isEmpty
//               ? _buildEmptyState(themeColors)
//               : Column(
//                   children: [
//                     // Header Section
//                     _buildHeaderSection(themeColors),
                    
//                     // Scrollable Form Content
//                     Expanded(
//                       child: SingleChildScrollView(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _buildSectionHeader(
//                               'Restaurant & Vendor',
//                               Icons.restaurant_menu,
//                               themeColors,
//                             ),
//                             const SizedBox(height: 12),
//                             RestaurantSelectorCard(
//                               restaurants: _restaurants,
//                               selectedRestaurant: _selectedRestaurant,
//                               onRestaurantChanged: _onRestaurantChanged,
//                             ),
//                             const SizedBox(height: 12),
//                             VendorSelectorCard(
//                               vendors: _vendors,
//                               selectedVendor: _selectedVendor,
//                               onVendorChanged: (value) => setState(() => _selectedVendor = value),
//                               isLoading: _isLoadingVendors,
//                               hasSelectedRestaurant: _selectedRestaurant != null,
//                             ),
                            
//                             const SizedBox(height: 24),
//                             _buildSectionHeader(
//                               'Customer Information',
//                               Icons.person,
//                               themeColors,
//                             ),
//                             const SizedBox(height: 12),
//                             CustomerSectionCard(
//                               selectedCustomer: _selectedCustomer,
//                               isGuestOrder: _isGuestOrder,
//                               guestName: _guestName,
//                               guestMobile: _guestMobile,
//                               guestAddress: _guestAddress,
//                               customerAddresses: _customerAddresses,
//                               selectedAddress: _selectedAddress,
//                               onSelectCustomer: _showCustomerSelection,
//                               onAddressChanged: (value) => setState(() => _selectedAddress = value),
//                             ),
                            
//                             const SizedBox(height: 24),
//                             _buildSectionHeader(
//                               'Order Items',
//                               Icons.shopping_bag,
//                               themeColors,
//                             ),
//                             const SizedBox(height: 12),
//                             OrderItemsSectionCard(
//                               orderItems: _orderItems,
//                               onAddItems: _showMenuItemSelection,
//                               onRemoveItem: _removeOrderItem,
//                               onUpdateQuantity: _updateItemQuantity,
//                               canAddItems: _selectedRestaurant != null,
//                             ),
                            
//                             const SizedBox(height: 24),
//                             _buildSectionHeader(
//                               'Order Summary',
//                               Icons.receipt_long,
//                               themeColors,
//                             ),
//                             const SizedBox(height: 12),
//                             OrderSummaryCard(
//                               itemCount: _orderItems.length,
//                               totalAmount: _totalAmount,
//                             ),
                            
//                             const SizedBox(height: 24),
//                             _buildSectionHeader(
//                               'Additional Details',
//                               Icons.info_outline,
//                               themeColors,
//                             ),
//                             const SizedBox(height: 12),
//                             AdditionalDetailsCard(
//                               paymentMethod: _paymentMethod,
//                               onPaymentMethodChanged: (value) =>
//                                   setState(() => _paymentMethod = value ?? 'Cash'),
//                               onSpecialInstructionsChanged: (value) =>
//                                   _specialInstructions = value,
//                               proposedDeliveryTime: _proposedDeliveryTime,
//                               onDeliveryTimeChanged: (value) =>
//                                   setState(() => _proposedDeliveryTime = value),
//                               initialInstructions: _specialInstructions,
//                             ),
                            
//                             const SizedBox(height: 32),
//                           ],
//                         ),
//                       ),
//                     ),
                    
//                     // Bottom Submit Button
//                     _buildBottomSubmitBar(themeColors),
//                   ],
//                 ),
//     );
//   }

//   Widget _buildHeaderSection(AppThemeColors themeColors) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: themeColors.surface,
//         border: Border(
//           bottom: BorderSide(
//             color: themeColors.background.withAlpha(50),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: AppTheme.primary.withAlpha(25),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.add_shopping_cart,
//                   color: AppTheme.primary,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'New Order',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w600,
//                         color: themeColors.textPrimary,
//                       ),
//                     ),
//                     Text(
//                       'Fill in the details below to create a new order',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: themeColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionHeader(
//     String title,
//     IconData icon,
//     AppThemeColors themeColors,
//   ) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           size: 20,
//           color: AppTheme.primary,
//         ),
//         const SizedBox(width: 8),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: themeColors.textPrimary,
//             letterSpacing: -0.3,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Container(
//             height: 1,
//             color: themeColors.background.withAlpha(50),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildBottomSubmitBar(AppThemeColors themeColors) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: themeColors.surface,
//         border: Border(
//           top: BorderSide(
//             color: themeColors.background.withAlpha(50),
//             width: 1,
//           ),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha(13),
//             offset: const Offset(0, -2),
//             blurRadius: 8,
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             // Order Info Summary
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     '${_orderItems.length} ${_orderItems.length == 1 ? 'Item' : 'Items'}',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: themeColors.textSecondary,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Text(
//                     '₹${_totalAmount.toStringAsFixed(2)}',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: themeColors.textPrimary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 16),
//             // Submit Button
//             Expanded(
//               flex: 2,
//               child: SizedBox(
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _isSubmitting ? null : _submitOrder,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppTheme.primary,
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: _isSubmitting
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: const [
//                             Icon(Icons.check_circle_outline, size: 20),
//                             SizedBox(width: 8),
//                             Text(
//                               'Create Order',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _onRestaurantChanged(Restaurant? value) {
//     setState(() {
//       _selectedRestaurant = value;
//       _selectedVendor = null;
//       _vendors.clear();
//       _menuItems.clear();
//       _orderItems.clear();
//     });
//     if (value != null) {
//       _loadVendors();
//       _loadMenuItems();
//     }
//   }

//   Widget _buildEmptyState(AppThemeColors themeColors) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: themeColors.background,
//                 shape: BoxShape.circle,
//               ), 
//               child: Icon(
//                 Icons.restaurant_outlined,
//                 size: 64,
//                 color: themeColors.textSecondary,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'No Restaurants Found',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: themeColors.textPrimary,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'No restaurants are associated with your account.\nPlease contact support for assistance.',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: themeColors.textSecondary,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: _loadRestaurants,
//               icon: const Icon(Icons.refresh),
//               label: const Text('Retry'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppTheme.primary,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 12,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }