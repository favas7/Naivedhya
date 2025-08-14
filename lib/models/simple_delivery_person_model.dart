// models/delivery_personnel_model.dart
class SimpleDeliveryPersonnel {
  final String userId;
  final String name;
  final String email;
  final String fullName;
  final String phone;
  final String state;
  final String city;
  final String aadhaarNumber;
  final DateTime dateOfBirth;
  final String vehicleType;
  final String vehicleModel;
  final String numberPlate;
  final String? licenseImageUrl;
  final String? aadhaarImageUrl;
  final bool isAvailable;
  final List<String> assignedOrders;
  final double earnings;
  final bool isVerified;
  final String verificationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  SimpleDeliveryPersonnel({
    required this.userId,
    required this.name,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.state,
    required this.city,
    required this.aadhaarNumber,
    required this.dateOfBirth,
    required this.vehicleType,
    required this.vehicleModel,
    required this.numberPlate,
    this.licenseImageUrl,
    this.aadhaarImageUrl,
    required this.isAvailable,
    required this.assignedOrders,
    required this.earnings,
    required this.isVerified,
    required this.verificationStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SimpleDeliveryPersonnel.fromJson(Map<String, dynamic> json) {
    return SimpleDeliveryPersonnel(
      userId: json['user_id'],
      name: json['name'],
      email: json['email'],
      fullName: json['full_name'],
      phone: json['phone'],
      state: json['state'],
      city: json['city'],
      aadhaarNumber: json['aadhaar_number'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      vehicleType: json['vehicle_type'],
      vehicleModel: json['vehicle_model'],
      numberPlate: json['number_plate'],
      licenseImageUrl: json['license_image_url'],
      aadhaarImageUrl: json['aadhaar_image_url'],
      isAvailable: json['is_available'] ?? true,
      assignedOrders: List<String>.from(json['assigned_orders'] ?? []),
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['is_verified'] ?? false,
      verificationStatus: json['verification_status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'state': state,
      'city': city,
      'aadhaar_number': aadhaarNumber,
      'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
      'vehicle_type': vehicleType,
      'vehicle_model': vehicleModel,
      'number_plate': numberPlate,
      'license_image_url': licenseImageUrl,
      'aadhaar_image_url': aadhaarImageUrl,
      'is_available': isAvailable,
      'assigned_orders': assignedOrders,
      'earnings': earnings,
      'is_verified': isVerified,
      'verification_status': verificationStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SimpleDeliveryPersonnel copyWith({
    String? userId,
    String? name,
    String? email,
    String? fullName,
    String? phone,
    String? state,
    String? city,
    String? aadhaarNumber,
    DateTime? dateOfBirth,
    String? vehicleType,
    String? vehicleModel,
    String? numberPlate,
    String? licenseImageUrl,
    String? aadhaarImageUrl,
    bool? isAvailable,
    List<String>? assignedOrders,
    double? earnings,
    bool? isVerified,
    String? verificationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SimpleDeliveryPersonnel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      state: state ?? this.state,
      city: city ?? this.city,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      numberPlate: numberPlate ?? this.numberPlate,
      licenseImageUrl: licenseImageUrl ?? this.licenseImageUrl,
      aadhaarImageUrl: aadhaarImageUrl ?? this.aadhaarImageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      assignedOrders: assignedOrders ?? this.assignedOrders,
      earnings: earnings ?? this.earnings,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayName => fullName.isNotEmpty ? fullName : name;
  String get vehicleInfo => '$vehicleType - $vehicleModel ($numberPlate)';
  int get activeOrdersCount => assignedOrders.length;
}