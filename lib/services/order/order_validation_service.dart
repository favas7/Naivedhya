// lib/services/order/order_validation_service.dart
import 'package:naivedhya/models/address_model.dart';
import 'package:naivedhya/models/order_item_model.dart';
import 'package:naivedhya/models/restaurant_model.dart';
import 'package:naivedhya/models/user_model.dart';

class OrderValidationResult {
  final bool isValid;
  final String? errorMessage;

  OrderValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  factory OrderValidationResult.success() {
    return OrderValidationResult(isValid: true);
  }

  factory OrderValidationResult.error(String message) {
    return OrderValidationResult(isValid: false, errorMessage: message);
  }
}

class OrderValidationService {
  /// Validate add order screen data
  static OrderValidationResult validateAddOrder({
    required Restaurant? selectedRestaurant,
    required Map<String, dynamic>? selectedVendor,
    required bool isGuestOrder,
    required UserModel? selectedCustomer,
    required String? guestName,
    required String? guestMobile,
    required String? guestAddress,
    required List<OrderItem> orderItems,
    required Address? selectedAddress,
  }) {
    if (selectedRestaurant == null) {
      return OrderValidationResult.error('Please select a restaurant');
    }

    if (selectedVendor == null) {
      return OrderValidationResult.error('Please select a vendor');
    }

    if (!isGuestOrder && selectedCustomer == null) {
      return OrderValidationResult.error('Please select a customer');
    }

    if (isGuestOrder &&
        (guestName == null || guestMobile == null || guestAddress == null)) {
      return OrderValidationResult.error('Please provide guest details');
    }

    if (orderItems.isEmpty) {
      return OrderValidationResult.error('Please add at least one item');
    }

    if (!isGuestOrder && selectedAddress == null) {
      return OrderValidationResult.error('Please select a delivery address');
    }

    return OrderValidationResult.success();
  }

  /// Validate edit order screen data
  static OrderValidationResult validateEditOrder({
    required List<OrderItem> orderItems,
    required Address? selectedAddress,
  }) {
    if (orderItems.isEmpty) {
      return OrderValidationResult.error('Order must have at least one item');
    }

    if (selectedAddress == null) {
      return OrderValidationResult.error('Please select a delivery address');
    }

    return OrderValidationResult.success();
  }

  /// Validate customer form fields
  static OrderValidationResult validateCustomerForm({
    required String name,
    required String mobile,
    required String address,
  }) {
    if (name.trim().isEmpty) {
      return OrderValidationResult.error('Name is required');
    }

    if (mobile.trim().isEmpty) {
      return OrderValidationResult.error('Mobile number is required');
    }

    if (mobile.trim().length < 10) {
      return OrderValidationResult.error('Mobile number must be at least 10 digits');
    }

    if (address.trim().isEmpty) {
      return OrderValidationResult.error('Address is required');
    }

    return OrderValidationResult.success();
  }
}