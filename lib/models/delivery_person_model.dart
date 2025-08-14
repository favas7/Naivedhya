class DeliveryPersonnel {
  final String userId;
  final String name;
  final String? phone;
  final Map<String, dynamic>? currentLocation; // Geography stored as JSON
  final bool isAvailable;
  final List<String> assignedOrders;
  final double earnings;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DeliveryPersonnel({
    required this.userId,
    required this.name,
    this.phone,
    this.currentLocation,
    this.isAvailable = true,
    this.assignedOrders = const [],
    this.earnings = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory DeliveryPersonnel.fromJson(Map<String, dynamic> json) {
    return DeliveryPersonnel(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      currentLocation: json['current_location'],
      isAvailable: json['is_available'] ?? true,
      assignedOrders: json['assigned_orders'] != null 
          ? List<String>.from(json['assigned_orders']) 
          : [],
      earnings: (json['earnings'] ?? 0.0).toDouble(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'phone': phone,
      'current_location': currentLocation,
      'is_available': isAvailable,
      'assigned_orders': assignedOrders,
      'earnings': earnings,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  DeliveryPersonnel copyWith({
    String? userId,
    String? name,
    String? phone,
    Map<String, dynamic>? currentLocation,
    bool? isAvailable,
    List<String>? assignedOrders,
    double? earnings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryPersonnel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      currentLocation: currentLocation ?? this.currentLocation,
      isAvailable: isAvailable ?? this.isAvailable,
      assignedOrders: assignedOrders ?? this.assignedOrders,
      earnings: earnings ?? this.earnings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DeliveryPersonnel(userId: $userId, name: $name, phone: $phone, isAvailable: $isAvailable, earnings: $earnings)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryPersonnel && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}