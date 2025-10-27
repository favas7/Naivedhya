// lib/models/worker_model.dart
class Worker {
  final String? id;
  final String vendorId;
  final String name;
  final String phone;
  final String? email;
  final String? photoUrl;
  final String role;
  final String employmentStatus; // Active, Inactive, On Leave
  final String? idProofType; // Aadhar, PAN, Driving License, etc.
  final String shiftType; // Morning, Evening, Night, Rotating
  final String? workingHours; // e.g., "9 AM - 5 PM"
  final String? address;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Worker({
    this.id,
    required this.vendorId,
    required this.name,
    required this.phone,
    this.email,
    this.photoUrl,
    required this.role,
    this.employmentStatus = 'Active',
    this.idProofType,
    required this.shiftType,
    this.workingHours,
    this.address,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['worker_id'],
      vendorId: json['vendor_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      photoUrl: json['photo_url'],
      role: json['role'] ?? 'General',
      employmentStatus: json['employment_status'] ?? 'Active',
      idProofType: json['id_proof_type'],
      shiftType: json['shift_type'] ?? 'Morning',
      workingHours: json['working_hours'],
      address: json['address'],
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
      if (id != null) 'worker_id': id,
      'vendor_id': vendorId,
      'name': name,
      'phone': phone,
      if (email != null) 'email': email,
      if (photoUrl != null) 'photo_url': photoUrl,
      'role': role,
      'employment_status': employmentStatus,
      if (idProofType != null) 'id_proof_type': idProofType,
      'shift_type': shiftType,
      if (workingHours != null) 'working_hours': workingHours,
      if (address != null) 'address': address,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  Worker copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    String? role,
    String? employmentStatus,
    String? idProofType,
    String? shiftType,
    String? workingHours,
    String? address,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Worker(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      idProofType: idProofType ?? this.idProofType,
      shiftType: shiftType ?? this.shiftType,
      workingHours: workingHours ?? this.workingHours,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Worker(id: $id, name: $name, role: $role, vendorId: $vendorId, employmentStatus: $employmentStatus)';
  }
}