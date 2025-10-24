// lib/Views/admin/order/add_order_screen/widgets/add_order_dialogs.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/models/customer_model.dart';
import 'package:naivedhya/models/menu_model.dart';
import 'package:naivedhya/models/order_item_model.dart';

class AddOrderDialogs {
  // Customer Selection Dialog with Guest Option
  static void showCustomerSelection({
    required BuildContext context,
    required List<Customer> customers,
    required Function(Customer) onCustomerSelected,
    required VoidCallback onAddNewCustomer,
    VoidCallback? onContinueAsGuest,
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
          if (onContinueAsGuest != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onContinueAsGuest();
              },
              child: const Text('Continue as Guest'),
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

  // Add Guest Details Dialog
  static void showAddGuestDetails({
    required BuildContext context,
    required TextEditingController nameController,
    required TextEditingController mobileController,
    required TextEditingController addressController,
    required VoidCallback onSubmit,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guest Order Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Guest Name *',
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
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[200]!),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'This guest will be converted to a customer after order completion.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
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
            child: const Text('Continue as Guest'),
          ),
        ],
      ),
    );
  }

  // Enhanced Menu Item Selection Dialog with Inventory
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
              
              return _buildMenuItemTile(
                item: item,
                isAdded: isAdded,
                onAddItem: onAddItem,
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

  static Widget _buildMenuItemTile({
    required MenuItem item,
    required bool isAdded,
    required Function(MenuItem) onAddItem,
  }) {
    final isOutOfStock = !item.isInStock;
    final isLowStock = item.isLowStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isOutOfStock ? Colors.red[200]! : Colors.grey[300]!,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
        color: isOutOfStock ? Colors.red[50] : Colors.white,
      ),
      child: ListTile(
        enabled: !isOutOfStock && !isAdded,
        title: Text(
          item.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isOutOfStock ? Colors.red[700] : Colors.black87,
            decoration: isOutOfStock ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '₹${item.price.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.blue[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isOutOfStock)
              const Text(
                'Out of Stock',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              )
            else if (isLowStock)
              Text(
                'Low Stock: ${item.stockQuantity} left',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              Text(
                'In Stock: ${item.stockQuantity}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 11,
                ),
              ),
          ],
        ),
        trailing: isAdded
            ? Icon(Icons.check_circle, color: Colors.green[600], size: 24)
            : isOutOfStock
                ? Icon(Icons.block, color: Colors.red[400], size: 24)
                : IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => onAddItem(item),
                  ),
      ),
    );
  }
}