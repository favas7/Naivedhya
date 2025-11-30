
class DeliveryPersonnel {
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
  final double? latitude;
  final double? longitude;
  final bool isAvailable;
  final List<String> assignedOrders;
  final double earnings;
  final bool isVerified;
  final String verificationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double rating;
  final int totalDeliveries;

  DeliveryPersonnel({
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
    this.latitude,
    this.longitude,
    required this.isAvailable,
    required this.assignedOrders,
    required this.earnings,
    required this.isVerified,
    required this.verificationStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.rating,
    required this.totalDeliveries,
  });


  
  factory DeliveryPersonnel.fromJson(Map<String, dynamic> json) {
    // Handle PostGIS geography type for current_location
    double? lat;
    double? lng;
    
    if (json['current_location'] != null) {
      final location = json['current_location'];
      
      if (location is Map && location['coordinates'] != null) {
        // GeoJSON format: {"type": "Point", "coordinates": [lng, lat]}
        final coords = location['coordinates'] as List;
        lng = (coords[0] as num).toDouble();
        lat = (coords[1] as num).toDouble();
      } else if (location is String) {
        // WKT format: "POINT(lng lat)" or "(lng,lat)"
        final pointRegex = RegExp(r'POINT\s*\(\s*([-\d.]+)\s+([-\d.]+)\s*\)');
        final match = pointRegex.firstMatch(location);
        if (match != null) {
          lng = double.tryParse(match.group(1)!);
          lat = double.tryParse(match.group(2)!);
        } else {
          // Try coordinate format: "(lng,lat)"
          final coordRegex = RegExp(r'\(\s*([-\d.]+)\s*,\s*([-\d.]+)\s*\)');
          final coordMatch = coordRegex.firstMatch(location);
          if (coordMatch != null) {
            lng = double.tryParse(coordMatch.group(1)!);
            lat = double.tryParse(coordMatch.group(2)!);
          }
        }
      }
    }

    return DeliveryPersonnel(
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
      latitude: lat,
      longitude: lng,
      isAvailable: json['is_available'] ?? true,
      assignedOrders: List<String>.from(json['assigned_orders'] ?? []),
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['is_verified'] ?? false,
      verificationStatus: json['verification_status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalDeliveries: (json['total_deliveries'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
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
      'rating': rating,
      'total_deliveries': totalDeliveries,
    };

    // Add location if available (as GeoJSON for Supabase)
    if (latitude != null && longitude != null) {
      json['current_location'] = 'POINT($longitude $latitude)';
    }

    return json;
  }

  DeliveryPersonnel copyWith({
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
    double? latitude,
    double? longitude,
    bool? isAvailable,
    List<String>? assignedOrders,
    double? earnings,
    bool? isVerified,
    String? verificationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    int? totalDeliveries,
  }) {
    return DeliveryPersonnel(
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
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isAvailable: isAvailable ?? this.isAvailable,
      assignedOrders: assignedOrders ?? this.assignedOrders,
      earnings: earnings ?? this.earnings,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
    );
  }

  // Existing getters
  String get displayName => fullName.isNotEmpty ? fullName : name;
  String get vehicleInfo => '$vehicleType - $vehicleModel ($numberPlate)';
  int get activeOrdersCount => assignedOrders.length;
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // Location functionality getters
  bool get hasLocation => latitude != null && longitude != null;
  
  String get status {
    if (!isAvailable) return 'Inactive';
    if (assignedOrders.isNotEmpty) return 'Delivering';
    return 'Active';
  }

  bool matchesFilter(String filter) {
    switch (filter) {
      case 'All':
        return true;
      case 'Active':
        return isAvailable && assignedOrders.isEmpty;
      case 'Inactive':
        return !isAvailable;
      case 'Delivering':
        return assignedOrders.isNotEmpty;
      default:
        return true;
    }
  }
}