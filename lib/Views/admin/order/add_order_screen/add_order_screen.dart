// lib/Views/admin/order/add_order_screen/add_order_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naivedhya/Views/admin/order/add_order_screen/widget/add_order_dialogs.dart';
import 'package:naivedhya/models/address_model.dart';
import 'package:naivedhya/models/customer_model.dart';
import 'package:naivedhya/models/menu_model.dart';
import 'package:naivedhya/models/order_item_model.dart';
import 'package:naivedhya/models/restaurant_model.dart';
import 'package:naivedhya/models/user_model.dart';
import 'package:naivedhya/services/adress_service.dart';
import 'package:naivedhya/services/customer_service.dart';
import 'package:naivedhya/services/menu_service.dart';
import 'package:naivedhya/services/order/order_service.dart';
import 'package:naivedhya/services/restaurant_service.dart';
import 'package:naivedhya/services/ventor_service.dart';
import 'package:uuid/uuid.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  // Services
  final RestaurantService _restaurantService = RestaurantService();
  final VendorService _vendorService = VendorService();
  final CustomerService _customerService = CustomerService();
  final MenuService _menuService = MenuService();
  final AddressService _addressService = AddressService();
  final OrderService _orderService = OrderService();

  // Loading states
  bool _isLoadingRestaurants = false;
  bool _isLoadingVendors = false;
  bool _isSubmitting = false;

  // Data lists
  List<Restaurant> _restaurants = [];
  List<Map<String, dynamic>> _vendors = [];
  List<UserModel> _customers = [];
  List<MenuItem> _menuItems = [];
  List<Address> _customerAddresses = [];

  // Selected values
  Restaurant? _selectedRestaurant;
  Map<String, dynamic>? _selectedVendor;
  UserModel? _selectedCustomer;
  Address? _selectedAddress;
  final List<OrderItem> _orderItems = [];

  // Guest details
  bool _isGuestOrder = false;
  String? _guestName;
  String? _guestMobile;
  String? _guestAddress;

  // Order details
  String _paymentMethod = 'Cash';
  String? _specialInstructions;
  DateTime? _proposedDeliveryTime;

  // Text controllers for dialogs
  final _customerNameController = TextEditingController();
  final _customerMobileController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerMobileController.dispose();
    _customerEmailController.dispose();
    _customerAddressController.dispose();
    super.dispose();
  }

  /// Load restaurants filtered by current admin email
  Future<void> _loadRestaurants() async {
    setState(() => _isLoadingRestaurants = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.email == null) {
        throw Exception('No authenticated user found');
      }

      print('🔍 Loading restaurants for email: ${currentUser.email}');
      _restaurants =
          await _restaurantService.getRestaurantsByAdminEmail(currentUser.email!);

      print('✅ Loaded ${_restaurants.length} restaurants');

      // Auto-select if only one restaurant
      if (_restaurants.length == 1) {
        _selectedRestaurant = _restaurants.first;
        await _loadVendors();
        await _loadMenuItems();
      }
    } catch (e) {
      print('❌ Error loading restaurants: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading restaurants: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingRestaurants = false);
    }
  }

  /// Load vendors for selected restaurant
  Future<void> _loadVendors() async {
    if (_selectedRestaurant == null) return;

    setState(() => _isLoadingVendors = true);

    try {
      print('🔍 Loading vendors for restaurant: ${_selectedRestaurant!.id}');
      _vendors = await _vendorService
          .fetchVendorsByRestaurant(_selectedRestaurant!.id!);

      print('✅ Loaded ${_vendors.length} vendors');

      // Auto-select if only one vendor
      if (_vendors.length == 1) {
        _selectedVendor = _vendors.first;
      }
    } catch (e) {
      print('❌ Error loading vendors: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading vendors: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingVendors = false);
    }
  }

  /// Load menu items for selected restaurant
  Future<void> _loadMenuItems() async {
    if (_selectedRestaurant == null) return;


    try {
      print('🔍 Loading menu items for restaurant: ${_selectedRestaurant!.id}');
      _menuItems = await _menuService.getMenuItems(_selectedRestaurant!.id!);

      print('✅ Loaded ${_menuItems.length} menu items');
    } catch (e) {
      print('❌ Error loading menu items: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading menu items: $e')),
        );
      }
    } finally {
      if (mounted) setState(() {
        // just to refresh UI
      });

    }
  }

  /// Load customers for selection
  Future<void> _loadCustomers() async {

    try {
      print('🔍 Loading customers...');
      _customers = await _customerService.getAllCustomers();
      print('✅ Loaded ${_customers.length} customers');
    } catch (e) {
      print('❌ Error loading customers: $e');
    } finally {
      if (mounted) {
        setState(() {
        // just to refresh UI
      });
      }
    }
  }

  /// Load addresses for selected customer
  Future<void> _loadCustomerAddresses() async {
    if (_selectedCustomer == null) return;

    try {
      print('🔍 Loading addresses for customer: ${_selectedCustomer!.id}');
      _customerAddresses =
          await _addressService.getAddressesByUserId(_selectedCustomer!.id!);

      print('✅ Loaded ${_customerAddresses.length} addresses');

      // Auto-select default address
      final defaultAddress = _customerAddresses.firstWhere(
        (addr) => addr.isDefault,
        orElse: () => _customerAddresses.isNotEmpty
            ? _customerAddresses.first
            : Address(userId: _selectedCustomer!.id!, fullAddress: ''),
      );

      setState(() => _selectedAddress = defaultAddress);
    } catch (e) {
      print('❌ Error loading addresses: $e');
    }
  }

  /// Show customer selection dialog
  void _showCustomerSelection() async {
    await _loadCustomers();

    if (!mounted) return;

    final customers = _customers
        .map((user) => Customer.fromUserModel(user))
        .toList();

    AddOrderDialogs.showCustomerSelection(
      context: context,
      customers: customers,
      onCustomerSelected: (customer) {
        setState(() {
          _selectedCustomer =
              _customers.firstWhere((user) => user.id == customer.id);
          _isGuestOrder = false;
        });
        _loadCustomerAddresses();
      },
      onAddNewCustomer: _showAddNewCustomer,
      onContinueAsGuest: _showGuestDetails,
    );
  }

  /// Show add new customer dialog
  void _showAddNewCustomer() {
    _customerNameController.clear();
    _customerMobileController.clear();
    _customerEmailController.clear();
    _customerAddressController.clear();

    AddOrderDialogs.showAddNewCustomer(
      context: context,
      nameController: _customerNameController,
      mobileController: _customerMobileController,
      emailController: _customerEmailController,
      addressController: _customerAddressController,
      onSubmit: _createNewCustomer,
    );
  }

  /// Create new customer
  Future<void> _createNewCustomer() async {
    if (_customerNameController.text.trim().isEmpty ||
        _customerMobileController.text.trim().isEmpty ||
        _customerAddressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      final newCustomer = await _customerService.createCustomer(
        name: _customerNameController.text.trim(),
        mobile: _customerMobileController.text.trim(),
        address: _customerAddressController.text.trim(),
        email: _customerEmailController.text.trim().isEmpty
            ? null
            : _customerEmailController.text.trim(),
      );

      // Create address for the new customer
      await _addressService.createAddress(Address(
        userId: newCustomer.id!,
        fullAddress: _customerAddressController.text.trim(),
        label: 'Home',
        isDefault: true,
      ));

      setState(() {
        _selectedCustomer = newCustomer;
        _isGuestOrder = false;
      });

      await _loadCustomerAddresses();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer created successfully')),
        );
      }
    } catch (e) {
      print('❌ Error creating customer: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating customer: $e')),
        );
      }
    }
  }

  /// Show guest details dialog
  void _showGuestDetails() {
    _customerNameController.clear();
    _customerMobileController.clear();
    _customerAddressController.clear();

    AddOrderDialogs.showAddGuestDetails(
      context: context,
      nameController: _customerNameController,
      mobileController: _customerMobileController,
      addressController: _customerAddressController,
      onSubmit: _continueAsGuest,
    );
  }

  /// Continue as guest
  void _continueAsGuest() {
    if (_customerNameController.text.trim().isEmpty ||
        _customerMobileController.text.trim().isEmpty ||
        _customerAddressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() {
      _isGuestOrder = true;
      _guestName = _customerNameController.text.trim();
      _guestMobile = _customerMobileController.text.trim();
      _guestAddress = _customerAddressController.text.trim();
      _selectedCustomer = null;
      _selectedAddress = null;
    });

    Navigator.of(context).pop();
  }

  /// Show menu item selection dialog
  void _showMenuItemSelection() {
    if (_selectedRestaurant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a restaurant first')),
      );
      return;
    }

    AddOrderDialogs.showMenuItemSelection(
      context: context,
      restaurantName: _selectedRestaurant!.name,
      menuItems: _menuItems,
      currentOrderItems: _orderItems,
      onAddItem: _addMenuItem,
    );
  }

  /// Add menu item to order
  void _addMenuItem(MenuItem item) {
    final orderItem = OrderItem(
      itemId: item.itemId!,
      itemName: item.name,
      quantity: 1,
       orderId: '', 
       price: item.price,


    );

    setState(() {
      _orderItems.add(orderItem);
    });
  }

  /// Remove item from order
  void _removeOrderItem(int index) {
    setState(() {
      _orderItems.removeAt(index);
    });
  }

  /// Update item quantity
  void _updateItemQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeOrderItem(index);
      return;
    }

    setState(() {
      final item = _orderItems[index];
      _orderItems[index] = item.copyWith(
        quantity: newQuantity,
      );
    });
  }

  /// Calculate total amount
  double get _totalAmount {
    return _orderItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Generate order number (ORD-YYYYMMDD-NNN)
  String _generateOrderNumber() {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final randomNum = (DateTime.now().millisecondsSinceEpoch % 1000)
        .toString()
        .padLeft(3, '0');
    return 'ORD-$dateStr-$randomNum';
  }

  /// Submit order
  Future<void> _submitOrder() async {
    // Validation
    if (_selectedRestaurant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a restaurant')),
      );
      return;
    }

    if (_selectedVendor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vendor')),
      );
      return;
    }

    if (!_isGuestOrder && _selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
      );
      return;
    }

    if (_isGuestOrder &&
        (_guestName == null || _guestMobile == null || _guestAddress == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide guest details')),
      );
      return;
    }

    if (_orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    if (!_isGuestOrder && _selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? customerId;
      String? addressId;

      // Handle guest order - create customer first
      if (_isGuestOrder) {
        final guestCustomer = await _customerService.createCustomer(
          name: _guestName!,
          mobile: _guestMobile!,
          address: _guestAddress!,
        );

        customerId = guestCustomer.id;

        // Create address for guest
        final guestAddressObj = await _addressService.createAddress(Address(
          userId: customerId!,
          fullAddress: _guestAddress!,
          label: 'Guest Address',
          isDefault: true,
        ));

        addressId = guestAddressObj.addressId;
      } else {
        customerId = _selectedCustomer!.id;
        addressId = _selectedAddress!.addressId;
      }

      // Generate order number
      final orderNumber = _generateOrderNumber();

      // Prepare order data
      final orderData = {
        'order_id': const Uuid().v4(),
        'customer_id': customerId,
        'vendor_id': _selectedVendor!['vendor_id'],
        'hotel_id': _selectedRestaurant!.id,
        'order_number': orderNumber,
        'total_amount': _totalAmount,
        'status': 'Pending',
        'customer_name': _isGuestOrder ? _guestName : _selectedCustomer!.name,
        'delivery_address': addressId,
        'payment_method': _paymentMethod,
        'special_instructions': _specialInstructions,
        'proposed_delivery_time': _proposedDeliveryTime?.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('📦 Creating order with data: $orderData');

      // Create order
      final newOrder = await _orderService.createOrder(orderData);

      print('✅ Order created: ${newOrder.orderNumber}');

      // TODO: Create order items in order_items table
      // This would require an order items service

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order ${newOrder.orderNumber} created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('❌ Error creating order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Order'),
        elevation: 0,
      ),
      body: _isLoadingRestaurants
          ? const Center(child: CircularProgressIndicator())
          : _restaurants.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.restaurant, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No restaurants found for your account',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadRestaurants,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRestaurantSection(),
                      const SizedBox(height: 20),
                      _buildVendorSection(),
                      const SizedBox(height: 20),
                      _buildCustomerSection(),
                      const SizedBox(height: 20),
                      _buildMenuItemsSection(),
                      const SizedBox(height: 20),
                      _buildOrderSummary(),
                      const SizedBox(height: 20),
                      _buildAdditionalDetails(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildRestaurantSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Restaurant',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Restaurant>(
              value: _selectedRestaurant,
              decoration: const InputDecoration(
                labelText: 'Select Restaurant',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant),
              ),
              items: _restaurants.map((restaurant) {
                return DropdownMenuItem(
                  value: restaurant,
                  child: Text(restaurant.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRestaurant = value;
                  _selectedVendor = null;
                  _vendors.clear();
                  _menuItems.clear();
                  _orderItems.clear();
                });
                if (value != null) {
                  _loadVendors();
                  _loadMenuItems();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vendor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_isLoadingVendors)
              const Center(child: CircularProgressIndicator())
            else if (_vendors.isEmpty && _selectedRestaurant != null)
              const Text(
                'No vendors available for this restaurant',
                style: TextStyle(color: Colors.grey),
              )
            else
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedVendor,
                decoration: const InputDecoration(
                  labelText: 'Select Vendor',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                items: _vendors.map((vendor) {
                  return DropdownMenuItem(
                    value: vendor,
                    child: Text(vendor['name'] ?? 'Unknown Vendor'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedVendor = value);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Customer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _showCustomerSelection,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Select Customer'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_selectedCustomer != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedCustomer!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedCustomer!.phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Phone: ${_selectedCustomer!.phone}'),
                    ],
                    if (_selectedCustomer!.email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Email: ${_selectedCustomer!.email}'),
                    ],
                  ],
                ),
              )
            else if (_isGuestOrder)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          'Guest Order',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Name: $_guestName'),
                    Text('Phone: $_guestMobile'),
                    Text('Address: $_guestAddress'),
                  ],
                ),
              )
            else
              const Text(
                'No customer selected',
                style: TextStyle(color: Colors.grey),
              ),
            if (_selectedCustomer != null && _customerAddresses.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Delivery Address',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Address>(
                value: _selectedAddress,
                decoration: const InputDecoration(
                  labelText: 'Select Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),

                items: _customerAddresses.map((address) {
                  return DropdownMenuItem(
                    value: address,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (address.label != null)
                          Text(
                            address.label!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        Text(
                          address.fullAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedAddress = value);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _selectedRestaurant == null
                      ? null
                      : _showMenuItemSelection,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Items'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_orderItems.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No items added yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _orderItems.length,
                itemBuilder: (context, index) {
                  final item = _orderItems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(item.itemName ?? 'Unknown Item'),
                      subtitle: Text(
                        '₹${item.price.toStringAsFixed(2)} × ${item.quantity}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () =>
                                _updateItemQuantity(index, item.quantity - 1),
                          ),
                          Text(
                            item.quantity.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () =>
                                _updateItemQuantity(index, item.quantity + 1),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeOrderItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Items:', style: TextStyle(fontSize: 16)),
                Text(
                  _orderItems.length.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount:', style: TextStyle(fontSize: 18)),
                Text(
                  '₹${_totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payment),
              ),
              items: ['Cash', 'Card', 'UPI', 'Online']
                  .map((method) => DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _paymentMethod = value ?? 'Cash');
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Special Instructions (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
              onChanged: (value) => _specialInstructions = value,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: const Text('Proposed Delivery Time (Optional)'),
              subtitle: _proposedDeliveryTime != null
                  ? Text(DateFormat('MMM dd, yyyy - hh:mm a')
                      .format(_proposedDeliveryTime!))
                  : const Text('Not set'),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );

                  if (date != null && mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (time != null && mounted) {
                      setState(() {
                        _proposedDeliveryTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Create Order',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}