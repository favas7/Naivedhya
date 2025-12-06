// models/order_model.dart
import 'package:naivedhya/models/order_item_model.dart';

class Order {
  final String orderId;
  final String? customerId;
  final String? vendorId;  // ✅ Must be nullable
  final String restaurantId;  // ✅ This stays required
  final String orderNumber;
  final double totalAmount;
  final String status;
  final String? orderType; // ✅ NEW: "Dine In", "Delivery", "Takeaway"
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
  
  // ✅ Petpooja-specific fields
  final int? petpoojaOrderId;
  final String? petpoojaRestId;
  final String? tableNo;
  final double? discountTotal;
  final double? taxTotal;
  final double? packagingCharge;
  final double? serviceCharge;
  final String? biller;
  final String? assignee;
  final dynamic partPayments; // jsonb
  final DateTime? petpoojaCreatedAt;
  final dynamic petpoojaRawPayload; // jsonb
  
  // Order items array
  final List<OrderItem> orderItems;

  // Additional enriched data (not from DB)
  final Map<String, dynamic>? restaurant;
  final Map<String, dynamic>? vendor;
  final Map<String, dynamic>? deliveryPerson;

  Order({
    required this.orderId,
    this.customerId,
    this.vendorId,
    required this.restaurantId,  // Keep this required - we always have hotel_id
    required this.orderNumber,
    required this.totalAmount,
    required this.status,
    this.orderType,
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
    this.petpoojaOrderId,
    this.petpoojaRestId,
    this.tableNo,
    this.discountTotal,
    this.taxTotal,
    this.packagingCharge,
    this.serviceCharge,
    this.biller,
    this.assignee,
    this.partPayments,
    this.petpoojaCreatedAt,
    this.petpoojaRawPayload,
    this.orderItems = const [],
    this.restaurant,
    this.vendor,
    this.deliveryPerson,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Parse order items from JSONB array
    List<OrderItem> items = [];
    if (json['order_items'] != null && json['order_items'] is List) {
      try {
        items = (json['order_items'] as List)
            .map((item) => OrderItem.fromJson({
                  ...item,
                  'order_id': json['order_id'],
                }))
            .toList();
      } catch (e) {
        print('⚠️ Error parsing order items: $e');
        items = [];
      }
    }

    return Order(
      orderId: json['order_id'] as String,
      customerId: json['customer_id'] as String?,  // ✅ Explicitly cast as nullable
      vendorId: json['vendor_id'] as String?,      // ✅ Explicitly cast as nullable
      restaurantId: json['hotel_id'] as String,
      orderNumber: json['order_number'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] as String? ?? 'Pending',
      orderType: json['order_type'] as String?,     // ✅ Explicitly cast as nullable
      customerName: json['customer_name'] as String?,
      deliveryStatus: json['delivery_status'] as String?,
      deliveryPersonId: json['delivery_person_id'] as String?,
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
      deliveryAddress: json['delivery_address'] as String?,
      specialInstructions: json['special_instructions'] as String?,
      paymentMethod: json['payment_method'] as String?,
      petpoojaOrderId: json['petpooja_order_id'] as int?,
      petpoojaRestId: json['petpooja_rest_id'] as String?,
      tableNo: json['table_no'] as String?,
      discountTotal: json['discount_total'] != null 
          ? (json['discount_total'] as num).toDouble() 
          : null,
      taxTotal: json['tax_total'] != null 
          ? (json['tax_total'] as num).toDouble() 
          : null,
      packagingCharge: json['packaging_charge'] != null 
          ? (json['packaging_charge'] as num).toDouble() 
          : null,
      serviceCharge: json['service_charge'] != null 
          ? (json['service_charge'] as num).toDouble() 
          : null,
      biller: json['biller'] as String?,
      assignee: json['assignee'] as String?,
      partPayments: json['part_payments'],
      petpoojaCreatedAt: json['petpooja_created_at'] != null
          ? DateTime.parse(json['petpooja_created_at'])
          : null,
      petpoojaRawPayload: json['petpooja_raw_payload'],
      orderItems: items,
      restaurant: json['restaurant'] as Map<String, dynamic>?,
      vendor: json['vendor'] as Map<String, dynamic>?,
      deliveryPerson: json['delivery_person'] as Map<String, dynamic>?,
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
      'order_type': orderType,
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
      'petpooja_order_id': petpoojaOrderId,
      'petpooja_rest_id': petpoojaRestId,
      'table_no': tableNo,
      'discount_total': discountTotal,
      'tax_total': taxTotal,
      'packaging_charge': packagingCharge,
      'service_charge': serviceCharge,
      'biller': biller,
      'assignee': assignee,
      'part_payments': partPayments,
      'petpooja_created_at': petpoojaCreatedAt?.toIso8601String(),
      'petpooja_raw_payload': petpoojaRawPayload,
      'order_items': orderItems.map((item) => item.toJsonComplete()).toList(),
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    return {
      'customer_id': customerId,
      'vendor_id': vendorId,
      'hotel_id': restaurantId,
      'order_number': orderNumber,
      'total_amount': totalAmount,
      'status': status,
      'order_type': orderType,
      'customer_name': customerName,
      'delivery_status': deliveryStatus,
      'delivery_person_id': deliveryPersonId,
      'proposed_delivery_time': proposedDeliveryTime?.toIso8601String(),
      'pickup_time': pickupTime?.toIso8601String(),
      'delivery_time': deliveryTime?.toIso8601String(),
      'delivery_address': deliveryAddress,
      'special_instructions': specialInstructions,
      'payment_method': paymentMethod,
      'order_items': orderItems.map((item) => item.toJsonComplete()).toList(),
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
    String? orderType,
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
    int? petpoojaOrderId,
    String? petpoojaRestId,
    String? tableNo,
    double? discountTotal,
    double? taxTotal,
    double? packagingCharge,
    double? serviceCharge,
    String? biller,
    String? assignee,
    dynamic partPayments,
    DateTime? petpoojaCreatedAt,
    dynamic petpoojaRawPayload,
    List<OrderItem>? orderItems,
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
      orderType: orderType ?? this.orderType,
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
      petpoojaOrderId: petpoojaOrderId ?? this.petpoojaOrderId,
      petpoojaRestId: petpoojaRestId ?? this.petpoojaRestId,
      tableNo: tableNo ?? this.tableNo,
      discountTotal: discountTotal ?? this.discountTotal,
      taxTotal: taxTotal ?? this.taxTotal,
      packagingCharge: packagingCharge ?? this.packagingCharge,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      biller: biller ?? this.biller,
      assignee: assignee ?? this.assignee,
      partPayments: partPayments ?? this.partPayments,
      petpoojaCreatedAt: petpoojaCreatedAt ?? this.petpoojaCreatedAt,
      petpoojaRawPayload: petpoojaRawPayload ?? this.petpoojaRawPayload,
      orderItems: orderItems ?? this.orderItems,
      restaurant: restaurant ?? this.restaurant,
      vendor: vendor ?? this.vendor,
      deliveryPerson: deliveryPerson ?? this.deliveryPerson,
    );
  }

  // Helper: Calculate total from items
  double calculateTotalFromItems() {
    return orderItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Helper: Get item count
  int get itemCount => orderItems.length;

  // Helper: Get total quantity
  int get totalQuantity =>
      orderItems.fold(0, (sum, item) => sum + item.quantity);

  // Helper: Check if order is from Petpooja POS
  bool get isPetpoojaOrder => petpoojaOrderId != null;

  // Helper: Get order type icon
  String get orderTypeIcon {
    switch (orderType?.toLowerCase()) {
      case 'delivery':
        return '🚚';
      case 'dine in':
        return '🍽️';
      case 'takeaway':
        return '📦';
      default:
        return '📋';
    }
  }

  @override
  String toString() {
    return 'Order(orderId: $orderId, orderNumber: $orderNumber, orderType: $orderType, status: $status, items: ${orderItems.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.orderId == orderId;
  }

  @override
  int get hashCode => orderId.hashCode;
}