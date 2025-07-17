class Manager {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String? hotelid;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Manager({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.hotelid,
    this.createdAt,
    this.updatedAt,
  });

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      hotelid: json['hotel_id'],
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
      'hotel_id': hotelid,
    };
  }

  Manager copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? hotelid,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Manager(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      hotelid: hotelid ?? this.hotelid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}