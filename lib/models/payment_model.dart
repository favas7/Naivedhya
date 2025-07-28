import 'package:intl/intl.dart';

enum PaymentMode {
  upi('UPI'),
  cashOnDelivery('CashOnDelivery'),
  wallet('Wallet');

  const PaymentMode(this.value);
  final String value;

  static PaymentMode fromString(String value) {
    return PaymentMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => PaymentMode.upi,
    );
  }
}

enum PaymentStatus {
  pending('Pending'),
  completed('Completed'),
  failed('Failed');

  const PaymentStatus(this.value);
  final String value;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

class Payment {
  final String paymentId;
  final String orderId;
  final String customerId;
  final String customerName; // Changed from customerName to match variable naming
  final double amount;
  final PaymentMode paymentMode;
  final PaymentStatus status;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.paymentId,
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.paymentMode,
    required this.status,
    this.transactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['paymentid'] ?? '',
      orderId: json['orderid'] ?? '',
      customerId: json['customerid'] ?? '',
      customerName: json['profiles']?['name'] ?? 'Unknown Customer', // Changed from full_name to name
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      paymentMode: PaymentMode.fromString(json['paymentmode'] ?? 'UPI'),
      status: PaymentStatus.fromString(json['status'] ?? 'Pending'),
      transactionId: json['transactionid'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentid': paymentId,
      'orderid': orderId,
      'customerid': customerId,
      'amount': amount,
      'paymentmode': paymentMode.value,
      'status': status.value,
      'transactionid': transactionId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedDate {
    return DateFormat('dd-MM-yyyy').format(createdAt);
  }

  String get formattedAmount {
    return '₹${amount.toStringAsFixed(2)}';
  }

  Payment copyWith({
    String? paymentId,
    String? orderId,
    String? customerId,
    String? customerName,
    double? amount,
    PaymentMode? paymentMode,
    PaymentStatus? status,
    String? transactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      paymentId: paymentId ?? this.paymentId,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}