// lib/Views/admin/order/add_order_screen/widgets/add_order_form_sections.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/models/restaurant_model.dart';
import 'package:naivedhya/models/ventor_model.dart';
import 'package:naivedhya/models/customer_model.dart';
import 'package:naivedhya/models/simple_delivery_person_model.dart';

class AddOrderFormSections {
  // Section Header
  static Widget buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  // Special Instructions Field (Order-wide, max 300 chars but displayed as 30 per requirements)
  static Widget buildSpecialInstructionsField({
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Special Instructions (Optional)',
        hintText: 'e.g., Extra spicy, No onions, etc.',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.notes),
        counterText: '${controller.text.length}/300',
        helperText: 'Add any special instructions for this order',
      ),
      maxLines: 3,
      maxLength: 300,
      onChanged: onChanged,
    );
  }

  // Payment Method Selection
  static Widget buildPaymentMethodField({
    required String selectedPaymentMethod,
    required Function(String?) onChanged,
  }) {
    final paymentMethods = ['Cash', 'UPI'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          segments: paymentMethods.map((method) {
            return ButtonSegment<String>(
              value: method,
              label: Text(method),
              icon: method == 'Cash'
                  ? const Icon(Icons.payments)
                  : const Icon(Icons.mobile_screen_share),
            );
          }).toList(),
          selected: {selectedPaymentMethod},
          onSelectionChanged: (Set<String> newSelection) {
            onChanged(newSelection.first);
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.blue[600];
              }
              return Colors.white;
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return Colors.black87;
            }),
          ),
        ),
      ],
    );
  }

  // Customer Info Display
  static Widget buildCustomerInfo({
    required Customer customer,
    required VoidCallback onClear,
  }) {
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
          Icon(
            Icons.check_circle,
            color: Colors.green[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer: ${customer.name}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (customer.phone != null && customer.phone!.isNotEmpty)
                  Text(
                    'Mobile: ${customer.phone}',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: onClear,
          ),
        ],
      ),
    );
  }

  // Order Summary
  static Widget buildOrderSummary({
    required Restaurant? selectedRestaurant,
    required Vendor? selectedVendor,
    required Customer? selectedCustomer,
    required int orderItemsCount,
    required double totalAmount,
  }) {
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (selectedRestaurant != null)
            _buildSummaryRow('Restaurant:', selectedRestaurant.name),
          if (selectedVendor != null)
            _buildSummaryRow('Vendor:', selectedVendor.name),
          if (selectedCustomer != null)
            _buildSummaryRow('Customer:', selectedCustomer.name),
          const SizedBox(height: 8),
          Divider(color: Colors.blue[200]),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Items:',
            '$orderItemsCount item${orderItemsCount != 1 ? 's' : ''}',
            isHighlight: true,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Total Amount:',
            '₹${totalAmount.toStringAsFixed(2)}',
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  static Widget _buildSummaryRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  // Restaurant Selection
  static Widget buildRestaurantSelection({
    required Restaurant? selectedRestaurant,
    required List<Restaurant> restaurants,
    required Function(Restaurant?) onChanged,
    required String? Function(Restaurant?)? validator,
  }) {
    return DropdownButtonFormField<Restaurant>(
      value: selectedRestaurant,
      decoration: const InputDecoration(
        labelText: 'Select Restaurant *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.store),
        helperText: 'Choose the Restaurant for this order',
      ),
      isExpanded: true,
      itemHeight: 60,
      items: restaurants.map((restaurant) {
        return DropdownMenuItem(
          value: restaurant,
          child: Text(
            '${restaurant.name} - ${restaurant.address}',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      menuMaxHeight: 300,
    );
  }

  // Vendor Selection
  static Widget buildVendorSelection({
    required Vendor? selectedVendor,
    required List<Vendor> vendors,
    required Function(Vendor?) onChanged,
    required String? Function(Vendor?)? validator,
  }) {
    if (vendors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[700]),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'No vendors available for this restaurant. Please add a vendor first.',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<Vendor>(
      value: selectedVendor,
      decoration: const InputDecoration(
        labelText: 'Select Vendor *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.business),
        helperText: 'Choose the vendor/supplier for this order',
      ),
      isExpanded: true,
      items: vendors.map((vendor) {
        return DropdownMenuItem(
          value: vendor,
          child: Text(
            '${vendor.name} - ${vendor.serviceType}',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  // Customer Search
  static Widget buildCustomerSearch({
    required TextEditingController controller,
    required Function(String) onChanged,
    required VoidCallback onAddNewCustomer,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Search Customer *',
        hintText: 'Enter name or mobile number',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.add),
          onPressed: onAddNewCustomer,
          tooltip: 'Add New Customer',
        ),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }

  // Delivery Status Dropdown
  static Widget buildDeliveryStatusDropdown({
    required String selectedStatus,
    required List<String> statusOptions,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: selectedStatus,
      decoration: const InputDecoration(
        labelText: 'Delivery Status',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.local_shipping),
      ),
      items: statusOptions.map((status) {
        return DropdownMenuItem(value: status, child: Text(status));
      }).toList(),
      onChanged: onChanged,
    );
  }

  // Delivery Person Dropdown
  static Widget buildDeliveryPersonDropdown({
    required String? selectedPersonId,
    required List<SimpleDeliveryPersonnel> deliveryPersons,
    required bool hasSelectedRestaurant,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: selectedPersonId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Delivery Partner',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.person),
        helperText: deliveryPersons.isEmpty && hasSelectedRestaurant
            ? 'No delivery partners available'
            : null,
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Select Delivery Partner (Optional)'),
        ),
        ...deliveryPersons.map((person) {
          return DropdownMenuItem(
            value: person.userId,
            child: SizedBox(
              height: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    person.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    '${person.city}, ${person.state}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
      onChanged: onChanged,
      menuMaxHeight: 300,
      itemHeight: 56,
    );
  }

  // Delivery Time Field
  static Widget buildDeliveryTimeField({
    required DateTime? proposedDeliveryTime,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
                proposedDeliveryTime != null
                    ? 'Delivery: ${proposedDeliveryTime.day}/${proposedDeliveryTime.month}/${proposedDeliveryTime.year} ${proposedDeliveryTime.hour}:${proposedDeliveryTime.minute.toString().padLeft(2, '0')}'
                    : 'Select proposed delivery time (Optional)',
                style: TextStyle(
                  color: proposedDeliveryTime != null
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
}