class Manager {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String? Restaurantid;
  final String? imageUrl; // New field for profile image
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Manager({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.Restaurantid,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['manager_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      Restaurantid: json['Restaurant_id'],
      imageUrl: json['image_url'], // Map from database
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
      'Restaurant_id': Restaurantid,
      'image_url': imageUrl, // Include image URL
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'Restaurant_id': Restaurantid,
      'image_url': imageUrl, // Include image URL
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Manager copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? Restaurantid,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Manager(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      Restaurantid: Restaurantid ?? this.Restaurantid,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}