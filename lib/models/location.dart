class Location {
  final String? id;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String? Restaurantid;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Location({
    this.id,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.Restaurantid,
    this.createdAt,
    this.updatedAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['location_id'], // ✅ Maps from 'location_id' UUID column
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postal_code'],
      Restaurantid: json['Restaurant_id'], // ✅ Maps from 'Restaurant_id' UUID column
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
      'Restaurant_id': Restaurantid, // ✅ Maps to 'Restaurant_id' UUID column
    };
  }

  // ✅ Separate method for updates (doesn't include auto-generated fields)
  Map<String, dynamic> toUpdateJson() {
    return {
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'Restaurant_id': Restaurantid, // ✅ Maps to 'Restaurant_id' UUID column
    };
  }

  Location copyWith({
    String? id,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? Restaurantid,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Location(
      id: id ?? this.id,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      Restaurantid: Restaurantid ?? this.Restaurantid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullAddress => '$city, $state, $country - $postalCode';
}