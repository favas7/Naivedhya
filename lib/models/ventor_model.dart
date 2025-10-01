// lib/models/ventor_model.dart
class Vendor {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String serviceType;
  final String? restaurantId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Vendor({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.serviceType,
    this.restaurantId,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['vendor_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      serviceType: json['service_type'] ?? 'General',
      restaurantId: json['hotel_id'],
      isActive: json['is_active'] ?? true,
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
      if (id != null) 'vendor_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'service_type': serviceType,
      if (restaurantId != null) 'hotel_id': restaurantId,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  Vendor copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? serviceType,
    String? restaurantId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vendor(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      serviceType: serviceType ?? this.serviceType,
      restaurantId: restaurantId ?? this.restaurantId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Vendor(id: $id, name: $name, serviceType: $serviceType, restaurantId: $restaurantId)';
  }
}