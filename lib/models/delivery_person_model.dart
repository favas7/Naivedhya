// models/delivery_person_model.dart
class DeliveryPerson {
  final String id;
  final String name;
  final String? mobile;
  final String? email;
  final bool isAvailable;
  final String? vehicleType;
  final DateTime createdAt;

  DeliveryPerson({
    required this.id,
    required this.name,
    this.mobile,
    this.email,
    this.isAvailable = true,
    this.vehicleType,
    required this.createdAt,
  });

  factory DeliveryPerson.fromJson(Map<String, dynamic> json) {
    return DeliveryPerson(
      id: json['id'],
      name: json['name'],
      mobile: json['mobile'],
      email: json['email'],
      isAvailable: json['is_available'] ?? true,
      vehicleType: json['vehicle_type'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'is_available': isAvailable,
      'vehicle_type': vehicleType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DeliveryPerson copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    bool? isAvailable,
    String? vehicleType,
    DateTime? createdAt,
  }) {
    return DeliveryPerson(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      isAvailable: isAvailable ?? this.isAvailable,
      vehicleType: vehicleType ?? this.vehicleType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'DeliveryPerson(id: $id, name: $name, mobile: $mobile, email: $email, isAvailable: $isAvailable, vehicleType: $vehicleType, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryPerson &&
        other.id == id &&
        other.name == name &&
        other.mobile == mobile &&
        other.email == email &&
        other.isAvailable == isAvailable &&
        other.vehicleType == vehicleType &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        mobile.hashCode ^
        email.hashCode ^
        isAvailable.hashCode ^
        vehicleType.hashCode ^
        createdAt.hashCode;
  }
}