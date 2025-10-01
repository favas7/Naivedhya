// lib/Views/admin/order/add_order_screen/add_order_screen.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/models/restaurant_model.dart';
import 'package:naivedhya/models/ventor_model.dart';
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

// Import widget files
import 'widget/add_order_dialogs.dart';
import 'widget/add_order_form_sections.dart';
import 'widget/add_order_list_items.dart';
import 'widget/add_order_validators.dart';

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
  List<Vendor> _availableVendors = [];
  Vendor? _selectedVendor;
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

  // Data Loading Methods
  Future<void> _loadInitialData() async {
    setState(() => _isLoadingData = true);
    
    try {
      _availableRestaurants = await _restaurantService.getRestaurantsForCurrentUser();
      
      if (_availableRestaurants.length == 1) {
        _selectedRestaurant = _availableRestaurants.first;
        _restaurantId = _selectedRestaurant!.id;
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
      _menuItems = await _menuService.getAvailableMenuItems(_restaurantId!);
      _deliveryPersons = await _deliveryService.fetchAvailableDeliveryPersonnel();
      _availableVendors = await _restaurantService.getVendorsByrestaurantId(_restaurantId!);
      
      if (_availableVendors.length == 1) {
        _selectedVendor = _availableVendors.first;
        _vendorId = _selectedVendor!.id;
      } else {
        _selectedVendor = null;
        _vendorId = null;
      }
      
      _orderItems.clear();
    } catch (e) {
      _showError('Failed to load Restaurant data: $e');
    } finally {
      setState(() => _isLoadingRestaurantData = false);
    }
  }

  // Event Handlers
  void _onRestaurantChanged(Restaurant? restaurant) async {
    setState(() {
      _selectedRestaurant = restaurant;
      _restaurantId = restaurant?.id;
      _vendorId = null;
      _selectedVendor = null;
      _menuItems = [];
      _deliveryPersons = [];
      _availableVendors = [];
      _orderItems.clear();
      _selectedDeliveryPersonId = null;
    });
    
    if (restaurant != null) {
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
        AddOrderDialogs.showCustomerSelection(
          context: context,
          customers: customers,
          onCustomerSelected: (customer) {
            setState(() {
              _selectedCustomer = customer;
              _customerSearchController.text = customer.name;
            });
          },
          onAddNewCustomer: _showAddNewCustomerDialog,
        );
      } else {
        _showAddNewCustomerDialog();
      }
    } catch (e) {
      _showError('Failed to search customers: $e');
    }
  }

  void _showAddNewCustomerDialog() {
    AddOrderDialogs.showAddNewCustomer(
      context: context,
      nameController: _customerNameController,
      mobileController: _customerMobileController,
      emailController: _customerEmailController,
      addressController: _deliveryAddressController,
      onSubmit: _createNewCustomer,
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
    if (_selectedRestaurant == null || _menuItems.isEmpty) {
      _showError('No menu items available');
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

  void _addMenuItem(MenuItem item) {
    final orderItem = OrderItem(
      orderId: '',
      itemId: item.itemId!,
      quantity: 1,
      price: item.price,
      itemName: item.name,
    );
    
    setState(() => _orderItems.add(orderItem));
  }

  void _removeOrderItem(int index) {
    setState(() => _orderItems.removeAt(index));
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
    
    final error = AddOrderValidators.getOrderCreationError(
      selectedRestaurant: _selectedRestaurant,
      selectedVendor: _selectedVendor,
      selectedCustomer: _selectedCustomer,
      orderItems: _orderItems,
    );
    
    if (error != null) {
      _showError(error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final orderId = _uuid.v4();
      final orderNumber = 'ORD${DateTime.now().millisecondsSinceEpoch}';

      final newOrder = Order(
        orderId: orderId,
        customerId: _selectedCustomer!.id,
        vendorId: _vendorId!,
        restaurantId: _restaurantId!,
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

      final updatedOrderItems = _orderItems.map((item) => 
        item.copyWith(orderId: orderId)
      ).toList();

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
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) _showError('Failed to create order: $e');
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
                const Icon(Icons.store_mall_directory_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No Restaurants found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                const Text('Please create a Restaurant first to add orders', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
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
                      Text('Order Information', style: TextStyle(fontSize: isDesktop ? 24 : 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 24),

                      // Restaurant Selection
                      AddOrderFormSections.buildSectionHeader('Restaurant Selection'),
                      const SizedBox(height: 16),
                      AddOrderFormSections.buildRestaurantSelection(
                        selectedRestaurant: _selectedRestaurant,
                        restaurants: _availableRestaurants,
                        onChanged: _onRestaurantChanged,
                        validator: AddOrderValidators.validateRestaurant,
                      ),
                      
                      if (_isLoadingRestaurantData) ...[
                        const SizedBox(height: 16),
                        const Center(child: Column(children: [CircularProgressIndicator(), SizedBox(height: 8), Text('Loading Restaurant data...')])),
                      ],

                      // Vendor Selection
                      if (_selectedRestaurant != null && !_isLoadingRestaurantData) ...[
                        const SizedBox(height: 24),
                        AddOrderFormSections.buildSectionHeader('Vendor Selection'),
                        const SizedBox(height: 16),
                        AddOrderFormSections.buildVendorSelection(
                          selectedVendor: _selectedVendor,
                          vendors: _availableVendors,
                          onChanged: (vendor) => setState(() {
                            _selectedVendor = vendor;
                            _vendorId = vendor?.id;
                          }),
                          validator: AddOrderValidators.validateVendor,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Customer Section
                      AddOrderFormSections.buildSectionHeader('Customer Information'),
                      const SizedBox(height: 16),
                      AddOrderFormSections.buildCustomerSearch(
                        controller: _customerSearchController,
                        onChanged: (value) {
                          if (value.length >= 2) _searchCustomers(value);
                        },
                        onAddNewCustomer: _showAddNewCustomerDialog,
                        validator: (value) => AddOrderValidators.validateCustomer(value, _selectedCustomer != null),
                      ),
                      if (_selectedCustomer != null)
                        AddOrderFormSections.buildCustomerInfo(
                          customer: _selectedCustomer!,
                          onClear: () => setState(() {
                            _selectedCustomer = null;
                            _customerSearchController.clear();
                          }),
                        ),

                      const SizedBox(height: 24),

                      // Menu Items
                      AddOrderFormSections.buildSectionHeader('Order Items'),
                      const SizedBox(height: 16),
                      AddOrderListItems.buildMenuItemsSection(
                        hasSelectedRestaurant: _selectedRestaurant != null,
                        hasSelectedVendor: _selectedVendor != null,
                        isLoadingRestaurantData: _isLoadingRestaurantData,
                        onAddMenuItems: _showMenuItemSelectionDialog,
                        orderItems: _orderItems,
                        onRemoveItem: _removeOrderItem,
                        onUpdateQuantity: _updateQuantity,
                      ),

                      const SizedBox(height: 24),

                      // Delivery Section
                      AddOrderFormSections.buildSectionHeader('Delivery Information'),
                      const SizedBox(height: 16),
                      if (isDesktop)
                        Row(
                          children: [
                            Expanded(child: AddOrderFormSections.buildDeliveryStatusDropdown(
                              selectedStatus: _selectedDeliveryStatus,
                              statusOptions: _deliveryStatusOptions,
                              onChanged: (value) => setState(() => _selectedDeliveryStatus = value!),
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: AddOrderFormSections.buildDeliveryPersonDropdown(
                              selectedPersonId: _selectedDeliveryPersonId,
                              deliveryPersons: _deliveryPersons,
                              hasSelectedRestaurant: _selectedRestaurant != null,
                              onChanged: (value) => setState(() => _selectedDeliveryPersonId = value),
                            )),
                          ],
                        )
                      else ...[
                        AddOrderFormSections.buildDeliveryStatusDropdown(
                          selectedStatus: _selectedDeliveryStatus,
                          statusOptions: _deliveryStatusOptions,
                          onChanged: (value) => setState(() => _selectedDeliveryStatus = value!),
                        ),
                        const SizedBox(height: 16),
                        AddOrderFormSections.buildDeliveryPersonDropdown(
                          selectedPersonId: _selectedDeliveryPersonId,
                          deliveryPersons: _deliveryPersons,
                          hasSelectedRestaurant: _selectedRestaurant != null,
                          onChanged: (value) => setState(() => _selectedDeliveryPersonId = value),
                        ),
                      ],
                      const SizedBox(height: 16),
                      AddOrderFormSections.buildDeliveryTimeField(
                        proposedDeliveryTime: _proposedDeliveryTime,
                        onTap: _selectDeliveryTime,
                      ),

                      const SizedBox(height: 24),

                      // Order Summary
                      AddOrderFormSections.buildOrderSummary(
                        selectedRestaurant: _selectedRestaurant,
                        selectedVendor: _selectedVendor,
                        selectedCustomer: _selectedCustomer,
                        orderItemsCount: _orderItems.length,
                        totalAmount: _totalAmount,
                      ),

                      const SizedBox(height: 32),

                      // Action Buttons
                      AddOrderListItems.buildActionButtons(
                        isLoading: _isLoading,
                        onCancel: () => Navigator.of(context).pop(),
                        onCreate: _createOrder,
                      ),
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
}