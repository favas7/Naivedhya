// lib/Views/admin/order/add_order_screen/widgets/add_order_dialogs.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/models/customer_model.dart';
import 'package:naivedhya/models/menu_model.dart';
import 'package:naivedhya/models/order_item_model.dart';

class AddOrderDialogs {
  // Customer Selection Dialog
  static void showCustomerSelection({
    required BuildContext context,
    required List<Customer> customers,
    required Function(Customer) onCustomerSelected,
    required VoidCallback onAddNewCustomer,
  }) {
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
                  onCustomerSelected(customer);
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
              onAddNewCustomer();
            },
            child: const Text('Add New Customer'),
          ),
        ],
      ),
    );
  }

  // Add New Customer Dialog
  static void showAddNewCustomer({
    required BuildContext context,
    required TextEditingController nameController,
    required TextEditingController mobileController,
    required TextEditingController emailController,
    required TextEditingController addressController,
    required VoidCallback onSubmit,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
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
            onPressed: onSubmit,
            child: const Text('Create Customer'),
          ),
        ],
      ),
    );
  }

  // Menu Item Selection Dialog
  static void showMenuItemSelection({
    required BuildContext context,
    required String restaurantName,
    required List<MenuItem> menuItems,
    required List<OrderItem> currentOrderItems,
    required Function(MenuItem) onAddItem,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Menu Items - $restaurantName'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              final isAdded = currentOrderItems.any(
                (orderItem) => orderItem.itemId == item.itemId,
              );
              
              return ListTile(
                title: Text(item.name),
                subtitle: Text('₹${item.price.toStringAsFixed(2)}'),
                trailing: isAdded 
                  ? const Icon(Icons.check, color: Colors.green)
                  : IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => onAddItem(item),
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
}