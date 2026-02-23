// ignore_for_file: non_constant_identifier_names

class UserModel {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String dob;
  final String? address;
  final double? pendingpayments;
  List<String>? orderhistory;
  final DateTime created_at;
  final DateTime updated_at;
  final String? usertype;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.dob,
    required this.address,
    this.pendingpayments = 0.0,
    this.orderhistory = const [],
    required this.created_at,
    required this.updated_at,
    this.usertype = 'user',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dob: json['dob'] ?? '',
      address: json['address'] ?? '',
      pendingpayments: (json['pendingpayments'])?.toDouble() ?? 0.0,
      orderhistory: List<String>.from(json['orderhistory'] ?? []),
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updated_at: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      usertype: json['usertype'] ?? 'user',
    );
  }

  get fullName => null;

  get phoneNumber => phone;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'dob': dob,
      'address': address,
      'pendingpayments': pendingpayments,
      'orderhistory': orderhistory,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
      'usertype': usertype,
    };
  }

  UserModel copyWith({
    String? id,
    String? userid,
    String? name,
    String? email,
    String? phone,
    String? dob,
    String? address,
    double? pendingpayments,
    List<String>? orderhistory,
    DateTime? created_at,
    DateTime? updated_at,
    String? usertype,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      address: address ?? this.address,
      pendingpayments: pendingpayments ?? this.pendingpayments,
      orderhistory: orderhistory ?? this.orderhistory,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
      usertype: usertype ?? this.usertype,
    );
  }
}