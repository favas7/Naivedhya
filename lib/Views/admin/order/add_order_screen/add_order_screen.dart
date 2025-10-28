// lib/Views/admin/order/add_order_screen/add_order_screen.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/order/add_order_screen/widget/add_order_dialogs.dart';
import 'package:naivedhya/Views/admin/order/add_order_screen/widget/add_order_form_sections.dart';
import 'package:naivedhya/Views/admin/order/add_order_screen/widget/add_order_list_items.dart';
import 'package:naivedhya/Views/admin/order/add_order_screen/widget/add_order_validators.dart';
import 'package:naivedhya/models/customer_model.dart';
import 'package:naivedhya/models/menu_model.dart';
import 'package:naivedhya/models/order_item_model.dart';
import 'package:naivedhya/models/restaurant_model.dart';
import 'package:naivedhya/models/ventor_model.dart';
import 'package:naivedhya/models/simple_delivery_person_model.dart';


class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Selected items
  Restaurant? selectedRestaurant;
  Vendor? selectedVendor;
  Customer? selectedCustomer;
  String selectedPaymentMethod = 'Cash';
  String selectedDeliveryStatus = 'Pending';
  String? selectedDeliveryPersonId;
  DateTime? proposedDeliveryTime;

  // Text controllers
  final customerSearchController = TextEditingController();
  final newCustomerNameController = TextEditingController();
  final newCustomerMobileController = TextEditingController();
  final newCustomerEmailController = TextEditingController();
  final newCustomerAddressController = TextEditingController();
  final guestNameController = TextEditingController();
  final guestMobileController = TextEditingController();
  final guestAddressController = TextEditingController();
  final specialInstructionsController = TextEditingController();

  // Order items list
  List<OrderItem> orderItems = [];

  // Loading states
  bool isLoadingRestaurantData = false;
  bool isCreatingOrder = false;

  // Sample data (replace with actual API calls)
  List<Restaurant> restaurants = [];
  List<Vendor> vendors = [];
  List<Customer> customers = [];
  List<MenuItem> menuItems = [];
  List<DeliveryPersonnel> deliveryPersons = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Load initial data from backend
  Future<void> _loadInitialData() async {
    // TODO: Replace with actual API calls
    // await _loadRestaurants();
    // await _loadCustomers();
  }

  // MARK: - Restaurant Selection
  void _onRestaurantSelected(Restaurant? restaurant) {
    setState(() {
      selectedRestaurant = restaurant;
      selectedVendor = null;
      orderItems.clear();
      menuItems.clear();
    });

    if (restaurant != null) {
      _loadVendorsForRestaurant(restaurant);
    }
  }

  Future<void> _loadVendorsForRestaurant(Restaurant restaurant) async {
    setState(() => isLoadingRestaurantData = true);
    try {
      // TODO: Replace with actual API call
      // vendors = await vendorRepository.getVendorsByRestaurant(restaurant.id);
      setState(() {});
    } catch (e) {
      _showErrorSnackBar('Failed to load vendors: $e');
    } finally {
      setState(() => isLoadingRestaurantData = false);
    }
  }

  // MARK: - Vendor Selection
  void _onVendorSelected(Vendor? vendor) {
    setState(() {
      selectedVendor = vendor;
      orderItems.clear();
    });

    if (vendor != null) {
      _loadMenuItemsForVendor(vendor);
    }
  }

  Future<void> _loadMenuItemsForVendor(Vendor vendor) async {
    setState(() => isLoadingRestaurantData = true);
    try {
      // TODO: Replace with actual API call
      // menuItems = await menuRepository.getMenuItemsByVendor(vendor.id);
      setState(() {});
    } catch (e) {
      _showErrorSnackBar('Failed to load menu items: $e');
    } finally {
      setState(() => isLoadingRestaurantData = false);
    }
  }

  // MARK: - Customer Selection
  void _showCustomerSelectionDialog() {
    AddOrderDialogs.showCustomerSelection(
      context: context,
      customers: customers,
      onCustomerSelected: (customer) {
        setState(() {
          selectedCustomer = customer;
          customerSearchController.clear();
        });
      },
      onAddNewCustomer: _showAddNewCustomerDialog,
      onContinueAsGuest: _showAddGuestDetailsDialog,
    );
  }

  void _showAddNewCustomerDialog() {
    // Clear controllers
    newCustomerNameController.clear();
    newCustomerMobileController.clear();
    newCustomerEmailController.clear();
    newCustomerAddressController.clear();

    AddOrderDialogs.showAddNewCustomer(
      context: context,
      nameController: newCustomerNameController,
      mobileController: newCustomerMobileController,
      emailController: newCustomerEmailController,
      addressController: newCustomerAddressController,
      onSubmit: _submitNewCustomer,
    );
  }

  Future<void> _submitNewCustomer() async {
    // Validate inputs
    if (newCustomerNameController.text.isEmpty ||
        newCustomerMobileController.text.isEmpty ||
        newCustomerAddressController.text.isEmpty) {
      _showErrorSnackBar('Please fill all required fields');
      return;
    }

    try {
      // TODO: Replace with actual API call to create customer
      // final newCustomer = await customerRepository.createCustomer(
      //   name: newCustomerNameController.text,
      //   phone: newCustomerMobileController.text,
      //   email: newCustomerEmailController.text,
      //   address: newCustomerAddressController.text,
      // );

      // For now, create a local customer object
      final newCustomer = Customer(
        name: newCustomerNameController.text,
        phone: newCustomerMobileController.text,
        email: newCustomerEmailController.text,
        address: newCustomerAddressController.text, 
        id: '',
      );

      setState(() {
        selectedCustomer = newCustomer;
        customers.add(newCustomer);
      });

      Navigator.pop(context);
      _showSuccessSnackBar('Customer created successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to create customer: $e');
    }
  }

  void _showAddGuestDetailsDialog() {
    guestNameController.clear();
    guestMobileController.clear();
    guestAddressController.clear();

    AddOrderDialogs.showAddGuestDetails(
      context: context,
      nameController: guestNameController,
      mobileController: guestMobileController,
      addressController: guestAddressController,
      onSubmit: _submitGuestDetails,
    );
  }

  void _submitGuestDetails() {
    // Validate guest inputs
    final nameError = AddOrderValidators.validateGuestName(guestNameController.text);
    final phoneError = AddOrderValidators.validateGuestPhone(guestMobileController.text);
    final addressError = AddOrderValidators.validateDeliveryAddress(guestAddressController.text);

    if (nameError != null || phoneError != null || addressError != null) {
      _showErrorSnackBar(nameError ?? phoneError ?? addressError ?? 'Validation error');
      return;
    }

    // Create guest customer
    final guestCustomer = Customer(
      name: guestNameController.text,
      phone: guestMobileController.text,
      address: guestAddressController.text,
       id: '', email: '',
    );

    setState(() => selectedCustomer = guestCustomer);
    Navigator.pop(context);
    _showSuccessSnackBar('Proceeding as guest');
  }

  // MARK: - Menu Items
  void _showMenuSelectionDialog() {
    if (selectedRestaurant == null || selectedVendor == null) {
      _showErrorSnackBar('Please select restaurant and vendor first');
      return;
    }

    AddOrderDialogs.showMenuItemSelection(
      context: context,
      restaurantName: selectedRestaurant!.name,
      menuItems: menuItems,
      currentOrderItems: orderItems,
      onAddItem: _addMenuItemToOrder,
    );
  }

  void _addMenuItemToOrder(MenuItem menuItem) {
    final existingIndex = orderItems.indexWhere(
      (item) => item.itemId == menuItem.itemId,
    );

    if (existingIndex >= 0) {
      // Item already exists, show customization dialog if needed
      _showItemCustomizationDialog(menuItem, existingIndex);
    } else {
      // Add new item
      setState(() {
        orderItems.add(
          OrderItem(
            itemId: menuItem.itemId ?? '',
            itemName: menuItem.name,
            price: menuItem.price,
            quantity: 1,
            selectedCustomizations: [], orderId: '',
          ),
        );
      });
      Navigator.pop(context);
      _showSuccessSnackBar('${menuItem.name} added to order');
    }
  }

  void _showItemCustomizationDialog(MenuItem menuItem, int itemIndex) {
    // TODO: Implement customization dialog if your app supports it
    // This would show customization options for the menu item
    Navigator.pop(context);
    _showInfoSnackBar('Item already added to order');
  }

  // MARK: - Order Items Management
  void _removeOrderItem(int index) {
    setState(() => orderItems.removeAt(index));
    _showInfoSnackBar('Item removed from order');
  }

  void _updateItemQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeOrderItem(index);
      return;
    }

    setState(() {
      final item = orderItems[index];
      item.quantity = newQuantity;
      orderItems[index] = item;
    });
  }

  // MARK: - Delivery Time Selection
  Future<void> _selectDeliveryTime() async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: tomorrow,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (selectedDate != null) {
      if (!mounted) return;
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 12, minute: 0),
      );

      if (selectedTime != null) {
        setState(() {
          proposedDeliveryTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  // // MARK: - Delivery Person Selection
  // Future<void> _loadDeliveryPersons() async {
  //   if (selectedRestaurant == null) return;

  //   try {
  //     // TODO: Replace with actual API call
  //     // deliveryPersons = await deliveryRepository.getDeliveryPersonsByRestaurant(
  //     //   selectedRestaurant!.id,
  //     // );
  //     setState(() {});
  //   } catch (e) {
  //     _showErrorSnackBar('Failed to load delivery partners: $e');
  //   }
  // }

  // MARK: - Order Creation
  Future<void> _createOrder() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please fill all required fields');
      return;
    }

    // Validate order
    final validationError = AddOrderValidators.getOrderCreationError(
      selectedRestaurant: selectedRestaurant,
      selectedVendor: selectedVendor,
      selectedCustomer: selectedCustomer,
      orderItems: orderItems,
    );

    if (validationError != null) {
      _showErrorSnackBar(validationError);
      return;
    }

    setState(() => isCreatingOrder = true);

    try {
      // TODO: Replace with actual API call to create order
      // final order = Order(
      //   restaurantId: selectedRestaurant!.id,
      //   vendorId: selectedVendor!.id,
      //   customerId: selectedCustomer!.customerId,
      //   items: orderItems,
      //   totalAmount: _calculateTotalAmount(),
      //   paymentMethod: selectedPaymentMethod,
      //   deliveryStatus: selectedDeliveryStatus,
      //   deliveryPersonId: selectedDeliveryPersonId,
      //   proposedDeliveryTime: proposedDeliveryTime,
      //   specialInstructions: specialInstructionsController.text,
      // );
      //
      // await orderRepository.createOrder(order);

      _showSuccessSnackBar('Order created successfully');
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to create order: $e');
    } finally {
      if (mounted) {
        setState(() => isCreatingOrder = false);
      }
    }
  }

  // MARK: - Helper Methods
  double _calculateTotalAmount() {
    return orderItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  void _clearCustomer() {
    setState(() {
      selectedCustomer = null;
      customerSearchController.clear();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    customerSearchController.dispose();
    newCustomerNameController.dispose();
    newCustomerMobileController.dispose();
    newCustomerEmailController.dispose();
    newCustomerAddressController.dispose();
    guestNameController.dispose();
    guestMobileController.dispose();
    guestAddressController.dispose();
    specialInstructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _calculateTotalAmount();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Order'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant Selection
              AddOrderFormSections.buildSectionHeader('Restaurant & Vendor'),
              const SizedBox(height: 16),
              AddOrderFormSections.buildRestaurantSelection(
                selectedRestaurant: selectedRestaurant,
                restaurants: restaurants,
                onChanged: _onRestaurantSelected,
                validator: AddOrderValidators.validateRestaurant,
              ),
              const SizedBox(height: 16),

              // Vendor Selection
              if (selectedRestaurant != null)
                AddOrderFormSections.buildVendorSelection(
                  selectedVendor: selectedVendor,
                  vendors: vendors,
                  onChanged: _onVendorSelected,
                  validator: AddOrderValidators.validateVendor,
                ),
              const SizedBox(height: 24),

              // Customer Selection
              AddOrderFormSections.buildSectionHeader('Customer Information'),
              const SizedBox(height: 16),
              AddOrderFormSections.buildCustomerSearch(
                controller: customerSearchController,
                onChanged: (value) {
                  // TODO: Implement customer search filtering
                },
                onAddNewCustomer: _showCustomerSelectionDialog,
                validator: (value) => AddOrderValidators.validateCustomer(
                  selectedCustomer,
                  selectedCustomer != null,
                ),
              ),
              if (selectedCustomer != null)
                AddOrderFormSections.buildCustomerInfo(
                  customer: selectedCustomer!,
                  onClear: _clearCustomer,
                ),
              const SizedBox(height: 24),

              // Menu Items
              AddOrderFormSections.buildSectionHeader('Order Items'),
              const SizedBox(height: 16),
              AddOrderListItems.buildMenuItemsSection(
                hasSelectedRestaurant: selectedRestaurant != null,
                hasSelectedVendor: selectedVendor != null,
                isLoadingRestaurantData: isLoadingRestaurantData,
                onAddMenuItems: _showMenuSelectionDialog,
                orderItems: orderItems,
                onRemoveItem: _removeOrderItem,
                onUpdateQuantity: _updateItemQuantity,
              ),
              const SizedBox(height: 24),

              // Special Instructions
              AddOrderFormSections.buildSectionHeader('Additional Details'),
              const SizedBox(height: 16),
              AddOrderFormSections.buildSpecialInstructionsField(
                controller: specialInstructionsController,
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Payment Method
              AddOrderFormSections.buildPaymentMethodField(
                selectedPaymentMethod: selectedPaymentMethod,
                onChanged: (method) {
                  if (method != null) {
                    setState(() => selectedPaymentMethod = method);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Delivery Status
              AddOrderFormSections.buildDeliveryStatusDropdown(
                selectedStatus: selectedDeliveryStatus,
                statusOptions: ['Pending', 'Confirmed', 'Preparing', 'Ready', 'Delivering', 'Delivered'],
                onChanged: (status) {
                  if (status != null) {
                    setState(() => selectedDeliveryStatus = status);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Delivery Person
              AddOrderFormSections.buildDeliveryPersonDropdown(
                selectedPersonId: selectedDeliveryPersonId,
                deliveryPersons: deliveryPersons,
                hasSelectedRestaurant: selectedRestaurant != null,
                onChanged: (personId) {
                  setState(() => selectedDeliveryPersonId = personId);
                },
              ),
              const SizedBox(height: 16),

              // Delivery Time
              AddOrderFormSections.buildDeliveryTimeField(
                proposedDeliveryTime: proposedDeliveryTime,
                onTap: _selectDeliveryTime,
              ),
              const SizedBox(height: 24),

              // Order Summary
              AddOrderFormSections.buildOrderSummary(
                selectedRestaurant: selectedRestaurant,
                selectedVendor: selectedVendor,
                selectedCustomer: selectedCustomer,
                orderItemsCount: orderItems.length,
                totalAmount: totalAmount,
              ),
              const SizedBox(height: 24),

              // Action Buttons
              AddOrderListItems.buildActionButtons(
                isLoading: isCreatingOrder,
                onCancel: () => Navigator.pop(context),
                onCreate: _createOrder,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}