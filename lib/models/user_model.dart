class UserModel {
  final String? id; // Supabase auth user ID
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String dob;
  final String address;
  final double pendingPayments;
  final List<String> orderHistory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userType;

  UserModel({
    this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.dob,
    required this.address,
    this.pendingPayments = 0.0,
    this.orderHistory = const [],
    required this.createdAt,
    required this.updatedAt,
    this.userType = 'user',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      dob: json['dob'] ?? '',
      address: json['address'] ?? '',
      pendingPayments: (json['pending_payments'] ?? json['pendingPayments'])?.toDouble() ?? 0.0,
      orderHistory: List<String>.from(json['order_history'] ?? json['orderHistory'] ?? []),
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt']),
      userType: json['user_type'] ?? json['userType'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'dob': dob,
      'address': address,
      'pending_payments': pendingPayments,
      'order_history': orderHistory,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_type': userType,
    };
  }

  UserModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? dob,
    String? address,
    double? pendingPayments,
    List<String>? orderHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userType,
  }) {
    return UserModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      address: address ?? this.address,
      pendingPayments: pendingPayments ?? this.pendingPayments,
      orderHistory: orderHistory ?? this.orderHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userType: userType ?? this.userType,
    );
  }
}