class Restaurant {
  final String? id;
  final String name;
  final String address;
  final String? enterpriseId;
  final String? locationId;
  final String? managerId;
  final String? adminEmail;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Restaurant({
    this.id, 
    required this.name,
    required this.address,
    this.enterpriseId,
    this.locationId,
    this.managerId,
    this.adminEmail,
    this.createdAt,
    this.updatedAt,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['hotel_id'], // FIXED: Match database column name
      name: json['name'],
      address: json['address'],
      enterpriseId: json['enterprise_id'],
      locationId: json['location_id'],
      managerId: json['manager_id'],
      adminEmail: json['adminemail'],
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
      if (id != null) 'hotel_id': id, // Include ID for updates
      'name': name,
      'address': address,
      if (enterpriseId != null) 'enterprise_id': enterpriseId,
      if (locationId != null) 'location_id': locationId,
      if (managerId != null) 'manager_id': managerId,
      if (adminEmail != null) 'adminemail': adminEmail,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Restaurant copyWith({
    String? id,
    String? name,
    String? address,
    String? enterpriseId,
    String? locationId,
    String? managerId,
    String? adminEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      enterpriseId: enterpriseId ?? this.enterpriseId,
      locationId: locationId ?? this.locationId,
      managerId: managerId ?? this.managerId,
      adminEmail: adminEmail ?? this.adminEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}