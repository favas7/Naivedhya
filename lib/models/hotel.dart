class Hotel {
  final String? id;
  final String name;
  final String address;
  final String? enterpriseId;
  final String? locationId;
  final String? managerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Hotel({
    this.id,
    required this.name,
    required this.address,
    this.enterpriseId,
    this.locationId,
    this.managerId,
    this.createdAt,
    this.updatedAt,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      enterpriseId: json['enterprise_id'],
      locationId: json['location_id'],
      managerId: json['manager_id'],
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
      'address': address,
      'enterprise_id': enterpriseId,
      'location_id': locationId,
      'manager_id': managerId,
    };
  }

  Hotel copyWith({
    String? id,
    String? name,
    String? address,
    String? enterpriseId,
    String? locationId,
    String? managerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Hotel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      enterpriseId: enterpriseId ?? this.enterpriseId,
      locationId: locationId ?? this.locationId,
      managerId: managerId ?? this.managerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}