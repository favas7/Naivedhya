// // lib/Views/admin/order/add_order_screen/widgets/add_order_validators.dart

// class AddOrderValidators {
//   static String? validateRestaurant(dynamic value) {
//     if (value == null) return 'Please select a Restaurant';
//     return null;
//   }

//   static String? validateVendor(dynamic value) {
//     if (value == null) return 'Please select a vendor';
//     return null;
//   }

//   static String? validateCustomer(
//     dynamic value,
//     bool hasSelectedCustomer,
//   ) {
//     if (!hasSelectedCustomer) {
//       return 'Please select or add a customer';
//     }
//     return null;
//   }

//   static String? validateGuestName(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Guest name is required';
//     }
//     if (value.length < 2) {
//       return 'Name must be at least 2 characters';
//     }
//     return null;
//   }

//   static String? validateGuestPhone(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Phone number is required';
//     }
//     if (value.length < 10) {
//       return 'Phone must be at least 10 digits';
//     }
//     return null;
//   }

//   static String? validateDeliveryAddress(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Delivery address is required';
//     }
//     if (value.length < 5) {
//       return 'Address must be at least 5 characters';
//     }
//     return null;
//   }

//   static bool canCreateOrder({
//     required dynamic selectedRestaurant,
//     required dynamic selectedVendor,
//     required dynamic selectedCustomer,
//     required List orderItems,
//   }) {
//     // Check restaurant and vendor
//     if (selectedRestaurant == null || selectedVendor == null) {
//       return false;
//     }

//     // Check customer
//     if (selectedCustomer == null) {
//       return false;
//     }

//     // Check order items
//     if (orderItems.isEmpty) {
//       return false;
//     }

//     return true;
//   }

//   static String? getOrderCreationError({
//     required dynamic selectedRestaurant,
//     required dynamic selectedVendor,
//     required dynamic selectedCustomer,
//     required List orderItems,
//   }) {
//     if (selectedRestaurant == null) return 'Please select a Restaurant';
//     if (selectedVendor == null) return 'Please select a vendor';
//     if (selectedCustomer == null) return 'Please select a customer';
//     if (orderItems.isEmpty) return 'Please add at least one menu item';

//     return null;
//   }

//   // Customization validation
//   static bool validateCustomizationSelections({
//     required List customizations,
//     required Map<String, String?> selectedCustomizations,
//   }) {
//     for (var customization in customizations) {
//       if (customization.isRequired) {
//         if (selectedCustomizations[customization.customizationId] == null) {
//           return false;
//         }
//       }
//     }
//     return true;
//   }

//   static String? getCustomizationError({
//     required List customizations,
//     required Map<String, String?> selectedCustomizations,
//   }) {
//     for (var customization in customizations) {
//       if (customization.isRequired) {
//         if (selectedCustomizations[customization.customizationId] == null) {
//           return 'Please select a ${customization.name}';
//         }
//       }
//     }
//     return null;
//   }

//   // Special instructions validation
//   static String? validateSpecialInstructions(String? value) {
//     if (value != null && value.length > 300) {
//       return 'Special instructions must not exceed 300 characters';
//     }
//     return null;
//   }

//   // Payment method validation
//   static bool isValidPaymentMethod(String? value) {
//     return value != null && (value == 'Cash' || value == 'UPI');
//   }
// }