// models/delivery_history_model.dart
class DeliveryHistory {
  final String id;
  final String orderId;
  final String deliveryPersonId;
  final String? customerId;
  final DateTime? pickupTime;
  final DateTime? deliveryTime;
  final String deliveryStatus;
  final String? deliveryAddress;
  final String? deliveryNotes;
  final double distanceKm;
  final double deliveryFee;
  final double tipAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeliveryHistory({
    required this.id,
    required this.orderId,
    required this.deliveryPersonId,
    this.customerId,
    this.pickupTime,
    this.deliveryTime,
    required this.deliveryStatus,
    this.deliveryAddress,
    this.deliveryNotes,
    required this.distanceKm,
    required this.deliveryFee,
    required this.tipAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryHistory.fromJson(Map<String, dynamic> json) {
    return DeliveryHistory(
      id: json['id'],
      orderId: json['order_id'],
      deliveryPersonId: json['delivery_person_id'],
      customerId: json['customer_id'],
      pickupTime: json['pickup_time'] != null 
          ? DateTime.parse(json['pickup_time']) 
          : null,
      deliveryTime: json['delivery_time'] != null 
          ? DateTime.parse(json['delivery_time']) 
          : null,
      deliveryStatus: json['delivery_status'] ?? 'pending',
      deliveryAddress: json['delivery_address'],
      deliveryNotes: json['delivery_notes'],
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      tipAmount: (json['tip_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'delivery_person_id': deliveryPersonId,
      'customer_id': customerId,
      'pickup_time': pickupTime?.toIso8601String(),
      'delivery_time': deliveryTime?.toIso8601String(),
      'delivery_status': deliveryStatus,
      'delivery_address': deliveryAddress,
      'delivery_notes': deliveryNotes,
      'distance_km': distanceKm,
      'delivery_fee': deliveryFee,
      'tip_amount': tipAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Duration? get deliveryDuration {
    if (pickupTime != null && deliveryTime != null) {
      return deliveryTime!.difference(pickupTime!);
    }
    return null;
  }

  double get totalEarnings => deliveryFee + tipAmount;

  bool get isCompleted => deliveryStatus.toLowerCase() == 'completed' || 
                          deliveryStatus.toLowerCase() == 'delivered';
}