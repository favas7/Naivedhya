// models/address_model.dart
class Address {
  final String? addressId;
  final String userId;
  final String? label;
  final String fullAddress;
  final dynamic location; // Geography type - can be stored as GeoJSON
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Address({
    this.addressId,
    required this.userId,
    this.label,
    required this.fullAddress,
    this.location,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressId: json['addressid'],
      userId: json['user_id'],
      label: json['label'],
      fullAddress: json['fulladdress'],
      location: json['location'],
      isDefault: json['isdefault'] ?? false,
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
      if (addressId != null) 'addressid': addressId,
      'user_id': userId,
      if (label != null) 'label': label,
      'fulladdress': fullAddress,
      if (location != null) 'location': location,
      'isdefault': isDefault,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Address copyWith({
    String? addressId,
    String? userId,
    String? label,
    String? fullAddress,
    dynamic location,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      addressId: addressId ?? this.addressId,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      location: location ?? this.location,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Address(id: $addressId, userId: $userId, label: $label, address: $fullAddress, isDefault: $isDefault)';
  }
}