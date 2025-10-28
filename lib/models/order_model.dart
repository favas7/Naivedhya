// models/order_model.dart
import 'package:naivedhya/models/order_item_model.dart';

class Order {
  final String orderId;
  final String? customerId;
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
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? deliveryAddress;
  final String? specialInstructions;
  final String? paymentMethod;
  
  // ✅ NEW: Order items array
  final List<OrderItem> orderItems;

  // Additional enriched data (not from DB)
  final Map<String, dynamic>? restaurant;
  final Map<String, dynamic>? vendor;
  final Map<String, dynamic>? deliveryPerson;

  Order({
    required this.orderId,
    this.customerId,
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
    this.createdAt,
    this.updatedAt,
    this.deliveryAddress,
    this.specialInstructions,
    this.paymentMethod,
    this.orderItems = const [], // ✅ Default empty array
    this.restaurant,
    this.vendor,
    this.deliveryPerson,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Parse order items from JSONB array
    List<OrderItem> items = [];
    if (json['order_items'] != null && json['order_items'] is List) {
      items = (json['order_items'] as List)
          .map((item) => OrderItem.fromJson({
                ...item,
                'order_id': json['order_id'], // Ensure order_id is set
              }))
          .toList();
    }

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
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      deliveryAddress: json['delivery_address'],
      specialInstructions: json['special_instructions'],
      paymentMethod: json['payment_method'],
      orderItems: items, // ✅ Parse items
      restaurant: json['restaurant'],
      vendor: json['vendor'],
      deliveryPerson: json['delivery_person'],
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'delivery_address': deliveryAddress,
      'special_instructions': specialInstructions,
      'payment_method': paymentMethod,
      'order_items': orderItems.map((item) => item.toJsonComplete()).toList(), // ✅ Include items with item_name
    };
  }

  /// Convert to JSON for database updates (without read-only fields)
  Map<String, dynamic> toJsonForUpdate() {
    return {
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
      'delivery_address': deliveryAddress,
      'special_instructions': specialInstructions,
      'payment_method': paymentMethod,
      'order_items': orderItems.map((item) => item.toJsonComplete()).toList(), // ✅ Include full items
      'updated_at': DateTime.now().toIso8601String(),
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
    String? deliveryAddress,
    String? specialInstructions,
    String? paymentMethod,
    List<OrderItem>? orderItems, // ✅ Can update items
    Map<String, dynamic>? restaurant,
    Map<String, dynamic>? vendor,
    Map<String, dynamic>? deliveryPerson,
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
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderItems: orderItems ?? this.orderItems, // ✅ Update items
      restaurant: restaurant ?? this.restaurant,
      vendor: vendor ?? this.vendor,
      deliveryPerson: deliveryPerson ?? this.deliveryPerson,
    );
  }

  // ✅ Helper: Calculate total from items
  double calculateTotalFromItems() {
    return orderItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // ✅ Helper: Get item count
  int get itemCount => orderItems.length;

  // ✅ Helper: Get total quantity
  int get totalQuantity =>
      orderItems.fold(0, (sum, item) => sum + item.quantity);

  @override
  String toString() {
    return 'Order(orderId: $orderId, orderNumber: $orderNumber, status: $status, items: ${orderItems.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.orderId == orderId;
  }

  @override
  int get hashCode => orderId.hashCode;
}