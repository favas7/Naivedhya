// lib/screens/admin/order/add_order_screen.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/models/simple_delivery_person_model.dart';
import 'package:naivedhya/models/menu_model.dart';
import 'package:naivedhya/providers/order_provider.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/models/customer_model.dart';
import 'package:naivedhya/models/order_item_model.dart';
import 'package:naivedhya/services/customer_service.dart';
import 'package:naivedhya/services/hotel_service.dart' as HotelService;
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
  final DeliveryPersonnelService _deliveryService = DeliveryPersonnelService(); // Updated service name
  final HotelService.SupabaseService _hotelService = HotelService.SupabaseService(); // Updated service name

  // Form controllers
  final _customerSearchController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerMobileController = TextEditingController();
  final _deliveryAddressController = TextEditingController();

  // Form state
  Customer? _selectedCustomer;
  String? _hotelId;
  String? _vendorId;
  List<MenuItem> _menuItems = [];
  final List<OrderItem> _orderItems = [];
  List<SimpleDeliveryPersonnel> _deliveryPersons = []; // Updated type
  String? _selectedDeliveryPersonId;
  final String _selectedStatus = 'Pending';
  String _selectedDeliveryStatus = 'Pending';
  DateTime? _proposedDeliveryTime;
  bool _isLoading = false;
  bool _isLoadingData = true;

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
    _deliveryAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingData = true);
    
    try {
      // Get current user's hotel
      final hotel = await _hotelService.getCurrentUserHotel();
      _hotelId = hotel?.id;
      _vendorId = hotel?.id;
      
      // Load menu items for this hotel
      if (_hotelId != null) {
        _menuItems = await _menuService.getMenuItemsByHotel(_hotelId!);
      }
      
      // Load available delivery persons
      _deliveryPersons = await _deliveryService.fetchAvailableDeliveryPersonnel(); // Updated method name
      
    } catch (e) {
      _showError('Failed to load initial data: $e');
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _searchCustomers(String query) async {
    if (query.isEmpty) {
      setState(() => _selectedCustomer = null);
      return;
    }

    try {
      final userModels = await _customerService.searchCustomers(query); // Returns List<UserModel>
      final customers = _customerService.convertToCustomers(userModels); // Convert to List<Customer>
      
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
                subtitle: Text(customer.phone ?? 'No mobile'), // Updated field name
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
            onPressed: _showAddNewCustomerDialog,
            child: const Text('Add New Customer'),
          ),
        ],
      ),
    );
  }

  void _showAddNewCustomerDialog() {
    Navigator.of(context).pop(); // Close previous dialog if open
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Customer'),
        content: Column(
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
              controller: _deliveryAddressController,
              decoration: const InputDecoration(
                labelText: 'Delivery Address *',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
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
      _showError('Please fill all customer details');
      return;
    }

    try {
      final newUserModel = await _customerService.createCustomer(
        name: _customerNameController.text.trim(),
        mobile: _customerMobileController.text.trim(),
        address: _deliveryAddressController.text.trim(),
      );

      final newCustomer = Customer.fromUserModel(newUserModel); // Convert to Customer

      setState(() {
        _selectedCustomer = newCustomer;
        _customerSearchController.text = newCustomer.name;
      });

      Navigator.of(context).pop();
      _customerNameController.clear();
      _customerMobileController.clear();
      _deliveryAddressController.clear();
    } catch (e) {
      _showError('Failed to create customer: $e');
    }
  }

  void _showMenuItemSelectionDialog() {
    if (_menuItems.isEmpty) {
      _showError('No menu items available for this hotel');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Menu Items'),
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
      itemName: item.name, // For display purposes
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
    if (_selectedCustomer == null) {
      _showError('Please select a customer');
      return;
    }
    if (_orderItems.isEmpty) {
      _showError('Please add at least one menu item');
      return;
    }
    if (_hotelId == null) {
      _showError('Hotel information not found');
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
        hotelId: _hotelId!,
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

      await context.read<OrderProvider>().createOrderWithItems(newOrder, updatedOrderItems);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order $orderNumber created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    if (_isLoadingData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
                if (_selectedCustomer!.phone != null) // Updated field name
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
                onPressed: _showMenuItemSelectionDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Menu Items'),
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
        children: _orderItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: index > 0 ? Border(top: BorderSide(color: Colors.grey[300]!)) : null,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _updateQuantity(index, item.quantity - 1),
                        icon: const Icon(Icons.remove),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        onPressed: () => _updateQuantity(index, item.quantity + 1),
                        icon: const Icon(Icons.add),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text('₹${(item.price * item.quantity).toStringAsFixed(2)}'),
                ),
                IconButton(
                  onPressed: () => _removeOrderItem(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          );
        }).toList(),
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
      decoration: const InputDecoration(
        labelText: 'Delivery Partner',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Select Delivery Partner'),
        ),
        ..._deliveryPersons.map((person) {
          return DropdownMenuItem(
            value: person.userId, // Updated field name
            child: Text(person.name), // Updated field access
          );
        }).toList(),
      ],
      onChanged: (value) {
        setState(() => _selectedDeliveryPersonId = value);
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
                    : 'Select proposed delivery time',
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Items: ${_orderItems.length}'),
              Text(
                'Total Amount: ₹${_totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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