// lib/Views/admin/order/add_order_screen/widgets/add_order_validators.dart

class AddOrderValidators {
  static String? validateRestaurant(dynamic value) {
    if (value == null) return 'Please select a Restaurant';
    return null;
  }

  static String? validateVendor(dynamic value) {
    if (value == null) return 'Please select a vendor';
    return null;
  }

  static String? validateCustomer(dynamic value, bool hasSelectedCustomer) {
    if (!hasSelectedCustomer) {
      return 'Please select or add a customer';
    }
    return null;
  }

  static bool canCreateOrder({
    required dynamic selectedRestaurant,
    required dynamic selectedVendor,
    required dynamic selectedCustomer,
    required List orderItems,
  }) {
    return selectedRestaurant != null &&
        selectedVendor != null &&
        selectedCustomer != null &&
        orderItems.isNotEmpty;
  }

  static String? getOrderCreationError({
    required dynamic selectedRestaurant,
    required dynamic selectedVendor,
    required dynamic selectedCustomer,
    required List orderItems,
  }) {
    if (selectedRestaurant == null) return 'Please select a Restaurant';
    if (selectedVendor == null) return 'Please select a vendor';
    if (selectedCustomer == null) return 'Please select a customer';
    if (orderItems.isEmpty) return 'Please add at least one menu item';
    return null;
  }
}