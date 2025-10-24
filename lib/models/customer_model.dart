// models/customer_model.dart
import 'package:naivedhya/models/user_model.dart';

/// Customer class for EditCustomerDialog compatibility
class Customer { 
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final double? pendingPayments;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.pendingPayments,
  });

  /// Convert from UserModel to Customer
  static Customer fromUserModel(UserModel userModel) {
    return Customer(
      id: userModel.id ?? '',
      name: userModel.name,
      email: userModel.email,
      phone: userModel.phone,
      address: userModel.address,
      pendingPayments: userModel.pendingpayments,
    );
  }

  /// Convert Customer back to UserModel (requires original UserModel for other fields)
  UserModel toUserModel(UserModel originalUserModel) {
    return originalUserModel.copyWith(
      name: name,
      email: email,
      phone: phone,
      address: address,
      pendingpayments: pendingPayments,
    );
  }
}