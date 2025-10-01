// models/order.dart
class Order {
  final String orderId;
  final String customerId;
  final String vendorId;
  final String restaurantId;
  final String orderNumber;
  final double totalAmount;
  final String status;
  final String? customerName;
  final String? deliveryStatus;
  final String? deliveryPersonId;
  final DateTime? proposedDeliveryTime;
  final DateTime? pickupTime;
  final DateTime? deliveryTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.orderId,
    required this.customerId,
    required this.vendorId,
    required this.restaurantId,
    required this.orderNumber,
    required this.totalAmount,
    required this.status,
    this.customerName,
    this.deliveryStatus,
    this.deliveryPersonId,
    this.proposedDeliveryTime,
    this.pickupTime,
    this.deliveryTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'],
      customerId: json['customer_id'],
      vendorId: json['vendor_id'],
      restaurantId: json['hotel_id'],
      orderNumber: json['order_number'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] ?? 'Pending',
      customerName: json['customer_name'],
      deliveryStatus: json['delivery_status'],
      deliveryPersonId: json['delivery_person_id'],
      proposedDeliveryTime: json['proposed_delivery_time'] != null
          ? DateTime.parse(json['proposed_delivery_time'])
          : null,
      pickupTime: json['pickup_time'] != null
          ? DateTime.parse(json['pickup_time'])
          : null,
      deliveryTime: json['delivery_time'] != null
          ? DateTime.parse(json['delivery_time'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'customer_id': customerId,
      'vendor_id': vendorId,
      'hotel_id': restaurantId,
      'order_number': orderNumber,
      'total_amount': totalAmount,
      'status': status,
      'customer_name': customerName,
      'delivery_status': deliveryStatus,
      'delivery_person_id': deliveryPersonId,
      'proposed_delivery_time': proposedDeliveryTime?.toIso8601String(),
      'pickup_time': pickupTime?.toIso8601String(),
      'delivery_time': deliveryTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Order copyWith({
    String? orderId,
    String? customerId,
    String? vendorId,
    String? restaurantId,
    String? orderNumber,
    double? totalAmount,
    String? status,
    String? customerName,
    String? deliveryStatus,
    String? deliveryPersonId,
    DateTime? proposedDeliveryTime,
    DateTime? pickupTime,
    DateTime? deliveryTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      vendorId: vendorId ?? this.vendorId,
      restaurantId: restaurantId ?? this.restaurantId,
      orderNumber: orderNumber ?? this.orderNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveryPersonId: deliveryPersonId ?? this.deliveryPersonId,
      proposedDeliveryTime: proposedDeliveryTime ?? this.proposedDeliveryTime,
      pickupTime: pickupTime ?? this.pickupTime,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}