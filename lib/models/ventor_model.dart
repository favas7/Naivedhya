class Vendor {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String serviceType;
  final String? RestaurantId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Vendor({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.serviceType,
    required this.RestaurantId,
    this.createdAt,
    this.updatedAt,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['vendor_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      serviceType: json['service_type'],
      RestaurantId: json['Restaurant_id'],
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
      'name': name,
      'email': email,
      'phone': phone,
      'service_type': serviceType,
      'Restaurant_id': RestaurantId,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}