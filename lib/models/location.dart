class Location {
  final String? id;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Location({
    this.id,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.createdAt,
    this.updatedAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postal_code'],
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
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
    };
  }

  Location copyWith({
    String? id,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Location(
      id: id ?? this.id,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullAddress => '$city, $state, $country - $postalCode';
}