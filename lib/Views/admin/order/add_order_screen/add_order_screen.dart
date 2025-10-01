// lib/screens/admin/order/add_order_screen.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/models/hotel.dart';
import 'package:naivedhya/models/simple_delivery_person_model.dart';
import 'package:naivedhya/models/menu_model.dart';
import 'package:naivedhya/providers/order_provider.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/models/customer_model.dart';
import 'package:naivedhya/models/order_item_model.dart';
import 'package:naivedhya/services/customer_service.dart';
import 'package:naivedhya/services/hotel_service.dart' as RestaurantService;
import 'package:naivedhya/services/menu_service.dart';
import 'package:naivedhya/services/delivery_person_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  // Services
  final CustomerService _customerService = CustomerService();
  final MenuService _menuService = MenuService();
  final DeliveryPersonnelService _deliveryService = DeliveryPersonnelService();
  final RestaurantService.SupabaseService _restaurantService = RestaurantService.SupabaseService();

  // Form controllers
  final _customerSearchController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerMobileController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _deliveryAddressController = TextEditingController();

  // Form state
  List<Restaurant> _availableRestaurants = [];
  Restaurant? _selectedRestaurant;
  Customer? _selectedCustomer;
  String? _restaurantId;
  String? _vendorId;
  List<MenuItem> _menuItems = [];
  final List<OrderItem> _orderItems = [];
  List<SimpleDeliveryPersonnel> _deliveryPersons = [];
  String? _selectedDeliveryPersonId;
  final String _selectedStatus = 'Pending';
  String _selectedDeliveryStatus = 'Pending';
  DateTime? _proposedDeliveryTime;
  bool _isLoading = false;
  bool _isLoadingData = true;
  bool _isLoadingRestaurantData = false;

  double get _totalAmount => _orderItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

  final List<String> _deliveryStatusOptions = [
    'Pending',
    'Assigned',
    'In Transit',
    'Delivered'
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _customerSearchController.dispose();
    _customerNameController.dispose();
    _customerMobileController.dispose();
    _customerEmailController.dispose();
    _deliveryAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingData = true);
    
    try {
      // Load all Restaurants for current admin user (filtered by admin email)
      _availableRestaurants = await _restaurantService.getRestaurantsForCurrentUser();
      
      // If only one Restaurant, auto-select it and load its data
      if (_availableRestaurants.length == 1) {
        _selectedRestaurant = _availableRestaurants.first;
        _restaurantId = _selectedRestaurant!.id;
        _vendorId = _selectedRestaurant!.id;
        await _loadRestaurantData();
      }
      
    } catch (e) {
      _showError('Failed to load Restaurants: $e');
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _loadRestaurantData() async {
    if (_restaurantId == null) return;
    
    setState(() => _isLoadingRestaurantData = true);
    
    try {
      // Load menu items for selected Restaurant (only available items)
      _menuItems = await _menuService.getAvailableMenuItems(_restaurantId!);
      
      // Load verified and available delivery personnel
      _deliveryPersons = await _deliveryService.fetchAvailableDeliveryPersonnel();
      
      // Clear previous order items when Restaurant changes
      _orderItems.clear();
      
    } catch (e) {
      _showError('Failed to load Restaurant data: $e');
    } finally {
      setState(() => _isLoadingRestaurantData = false);
    }
  }

  void _onRestaurantChanged(Restaurant? Restaurant) async {
    setState(() {
      _selectedRestaurant = Restaurant;
      _restaurantId = Restaurant?.id;
      _vendorId = Restaurant?.id;
      _menuItems = [];
      _deliveryPersons = [];
      _orderItems.clear();
      _selectedDeliveryPersonId = null;
    });
    
    if (Restaurant != null) {
      await _loadRestaurantData();
    }
  }

  Future<void> _searchCustomers(String query) async {
    if (query.isEmpty) {
      setState(() => _selectedCustomer = null);
      return;
    }

    try {
      final userModels = await _customerService.searchCustomers(query);
      final customers = _customerService.convertToCustomers(userModels);
      
      if (customers.isNotEmpty) {
        _showCustomerSelectionDialog(customers);
      } else {
        _showAddNewCustomerDialog();
      }
    } catch (e) {
      _showError('Failed to search customers: $e');
    }
  }

  void _showCustomerSelectionDialog(List<Customer> customers) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Customer'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return ListTile(
                title: Text(customer.name),
                subtitle: Text(customer.phone ?? 'No mobile'),
                onTap: () {
                  setState(() {
                    _selectedCustomer = customer;
                    _customerSearchController.text = customer.name;
                  });
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showAddNewCustomerDialog();
            },
            child: const Text('Add New Customer'),
          ),
        ],
      ),
    );
  }

  void _showAddNewCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _customerMobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _customerEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _deliveryAddressController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _createNewCustomer,
            child: const Text('Create Customer'),
          ),
        ],
      ),
    );
  }

  Future<void> _createNewCustomer() async {
    if (_customerNameController.text.isEmpty || 
        _customerMobileController.text.isEmpty ||
        _deliveryAddressController.text.isEmpty) {
      _showError('Please fill all required customer details');
      return;
    }

    try {
      final newUserModel = await _customerService.createCustomer(
        name: _customerNameController.text.trim(),
        mobile: _customerMobileController.text.trim(),
        address: _deliveryAddressController.text.trim(),
        email: _customerEmailController.text.trim().isEmpty 
            ? null 
            : _customerEmailController.text.trim(),
      );

      final newCustomer = Customer.fromUserModel(newUserModel);

      setState(() {
        _selectedCustomer = newCustomer;
        _customerSearchController.text = newCustomer.name;
      });

      Navigator.of(context).pop();
      _customerNameController.clear();
      _customerMobileController.clear();
      _customerEmailController.clear();
      _deliveryAddressController.clear();
      
      _showSuccess('Customer created successfully!');
    } catch (e) {
      _showError('Failed to create customer: $e');
    }
  }

  void _showMenuItemSelectionDialog() {
    if (_selectedRestaurant == null) {
      _showError('Please select a Restaurant first');
      return;
    }
    
    if (_menuItems.isEmpty) {
      _showError('No menu items available for this Restaurant');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Menu Items - ${_selectedRestaurant!.name}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              final isAdded = _orderItems.any((orderItem) => orderItem.itemId == item.itemId);
              
              return ListTile(
                title: Text(item.name),
                subtitle: Text('₹${item.price.toStringAsFixed(2)}'),
                trailing: isAdded 
                  ? const Icon(Icons.check, color: Colors.green)
                  : IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _addMenuItem(item),
                    ),
                enabled: item.isAvailable && !isAdded,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _addMenuItem(MenuItem item) {
    final orderItem = OrderItem(
      orderId: '', // Will be set when order is created
      itemId: item.itemId!,
      quantity: 1,
      price: item.price,
      itemName: item.name,
    );
    
    setState(() {
      _orderItems.add(orderItem);
    });
  }

  void _removeOrderItem(int index) {
    setState(() {
      _orderItems.removeAt(index);
    });
  }

  void _updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      _removeOrderItem(index);
      return;
    }
    
    setState(() {
      _orderItems[index] = _orderItems[index].copyWith(quantity: quantity);
    });
  }

  Future<void> _selectDeliveryTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
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
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedRestaurant == null) {
      _showError('Please select a Restaurant');
      return;
    }
    
    if (_selectedCustomer == null) {
      _showError('Please select a customer');
      return;
    }
    
    if (_orderItems.isEmpty) {
      _showError('Please add at least one menu item');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final orderId = _uuid.v4();
      final orderNumber = 'ORD${DateTime.now().millisecondsSinceEpoch}';

      // Create the order
      final newOrder = Order(
        orderId: orderId,
        customerId: _selectedCustomer!.id,
        vendorId: _vendorId!,
        RestaurantId: _restaurantId!,
        orderNumber: orderNumber,
        totalAmount: _totalAmount,
        status: _selectedStatus,
        customerName: _selectedCustomer!.name,
        deliveryStatus: _selectedDeliveryStatus,
        deliveryPersonId: _selectedDeliveryPersonId,
        proposedDeliveryTime: _proposedDeliveryTime,
        pickupTime: null,
        deliveryTime: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Update order items with the order ID
      final updatedOrderItems = _orderItems.map((item) => 
        item.copyWith(orderId: orderId)
      ).toList();

      // Create order with items using the provider
      await context.read<OrderProvider>().createOrderWithItems(newOrder, updatedOrderItems);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order $orderNumber created successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'View Orders',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        );
        
        // Pop with success result
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to create order: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    if (_isLoadingData) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading Restaurants...'),
            ],
          ),
        ),
      );
    }

    if (_availableRestaurants.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Add New Order'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.store_mall_directory_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Restaurants found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please create a Restaurant first to add orders',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Add New Order'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Order Information',
                        style: TextStyle(
                          fontSize: isDesktop ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Restaurant Selection Section
                      _buildSectionHeader('Restaurant Selection'),
                      const SizedBox(height: 16),
                      _buildRestaurantSelection(),
                      
                      if (_isLoadingRestaurantData) ...[
                        const SizedBox(height: 16),
                        const Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8),
                              Text('Loading Restaurant data...'),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Customer Section
                      _buildSectionHeader('Customer Information'),
                      const SizedBox(height: 16),
                      _buildCustomerSearch(),
                      if (_selectedCustomer != null) _buildCustomerInfo(),

                      const SizedBox(height: 24),

                      // Menu Items Section
                      _buildSectionHeader('Order Items'),
                      const SizedBox(height: 16),
                      _buildMenuItemsSection(),

                      const SizedBox(height: 24),

                      // Delivery Section
                      _buildSectionHeader('Delivery Information'),
                      const SizedBox(height: 16),
                      _buildDeliverySection(isDesktop),

                      const SizedBox(height: 24),

                      // Order Summary
                      _buildOrderSummary(),

                      const SizedBox(height: 32),

                      // Buttons
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildRestaurantSelection() {
    return DropdownButtonFormField<Restaurant>(
      value: _selectedRestaurant,
      decoration: const InputDecoration(
        labelText: 'Select Restaurant *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.store),
        helperText: 'Choose the Restaurant for this order',
      ),
      items: _availableRestaurants.map((Restaurant) {
        return DropdownMenuItem(
          value: Restaurant,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Restaurant.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                Restaurant.address,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: _onRestaurantChanged,
      validator: (value) {
        if (value == null) return 'Please select a Restaurant';
        return null;
      },
    );
  }

  Widget _buildCustomerSearch() {
    return Column(
      children: [
        TextFormField(
          controller: _customerSearchController,
          decoration: InputDecoration(
            labelText: 'Search Customer *',
            hintText: 'Enter name or mobile number',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddNewCustomerDialog,
              tooltip: 'Add New Customer',
            ),
          ),
          onChanged: (value) {
            if (value.length >= 2) {
              _searchCustomers(value);
            }
          },
          validator: (value) {
            if (_selectedCustomer == null) {
              return 'Please select or add a customer';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer: ${_selectedCustomer!.name}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (_selectedCustomer!.phone != null)
                  Text('Mobile: ${_selectedCustomer!.phone}'),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _selectedCustomer = null;
                _customerSearchController.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _selectedRestaurant == null || _isLoadingRestaurantData
                    ? null
                    : _showMenuItemSelectionDialog,
                icon: const Icon(Icons.add),
                label: Text(
                  _selectedRestaurant == null
                      ? 'Select a Restaurant first'
                      : _isLoadingRestaurantData
                          ? 'Loading menu...'
                          : 'Add Menu Items',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_orderItems.isNotEmpty) _buildOrderItemsList(),
      ],
    );
  }

  Widget _buildOrderItemsList() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Item',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Price',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Quantity',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 48), // Space for delete button
              ],
            ),
          ),
          // Order Items
          ..._orderItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.itemName ?? 'Unknown Item',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: Text('₹${item.price.toStringAsFixed(2)}'),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _updateQuantity(index, item.quantity - 1),
                          icon: const Icon(Icons.remove_circle_outline),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          iconSize: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _updateQuantity(index, item.quantity + 1),
                          icon: const Icon(Icons.add_circle_outline),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeOrderItem(index),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDeliverySection(bool isDesktop) {
    return Column(
      children: [
        if (isDesktop)
          Row(
            children: [
              Expanded(child: _buildDeliveryStatusDropdown()),
              const SizedBox(width: 16),
              Expanded(child: _buildDeliveryPersonDropdown()),
            ],
          )
        else ...[
          _buildDeliveryStatusDropdown(),
          const SizedBox(height: 16),
          _buildDeliveryPersonDropdown(),
        ],
        const SizedBox(height: 16),
        _buildDeliveryTimeField(),
      ],
    );
  }

  Widget _buildDeliveryStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDeliveryStatus,
      decoration: const InputDecoration(
        labelText: 'Delivery Status',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.local_shipping),
      ),
      items: _deliveryStatusOptions.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedDeliveryStatus = value);
        }
      },
    );
  }

  Widget _buildDeliveryPersonDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDeliveryPersonId,
      decoration: InputDecoration(
        labelText: 'Delivery Partner',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.person),
        helperText: _deliveryPersons.isEmpty && _selectedRestaurant != null
            ? 'No delivery partners available'
            : null,
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Select Delivery Partner (Optional)'),
        ),
        ..._deliveryPersons.map((person) {
          return DropdownMenuItem(
            value: person.userId,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  person.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${person.city}, ${person.state}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }),
      ],
      onChanged: (value) {
        setState(() => _selectedDeliveryPersonId =value);
      },
    );
  }

  Widget _buildDeliveryTimeField() {
    return InkWell(
      onTap: _selectDeliveryTime,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _proposedDeliveryTime != null
                    ? 'Delivery: ${_proposedDeliveryTime!.day}/${_proposedDeliveryTime!.month}/${_proposedDeliveryTime!.year} ${_proposedDeliveryTime!.hour}:${_proposedDeliveryTime!.minute.toString().padLeft(2, '0')}'
                    : 'Select proposed delivery time (Optional)',
                style: TextStyle(
                  color: _proposedDeliveryTime != null
                      ? Colors.black87
                      : Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle( 
              fontSize: 18,
              fontWeight: FontWeight.w600, 
            ),
          ),
          const SizedBox(height: 12),
          if (_selectedRestaurant != null)
            _buildSummaryRow('Restaurant:', _selectedRestaurant!.name),
          if (_selectedCustomer != null)
            _buildSummaryRow('Customer:', _selectedCustomer!.name),
          if (_orderItems.isNotEmpty) ...[
            const Divider(height: 20),
            _buildSummaryRow('Total Items:', '${_orderItems.length}'),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey[400]!),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Create Order'),
          ),
        ),
      ],
    );
  }
}