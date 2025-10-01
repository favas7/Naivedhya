class MenuItem {
  final String? itemId;
  final String RestaurantId;
  final String name;
  final String? description;
  final double price;
  final bool isAvailable;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MenuItem({
    this.itemId,
    required this.RestaurantId,
    required this.name,
    this.description,
    required this.price,
    this.isAvailable = true,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create MenuItem from JSON
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      itemId: json['item_id'],
      RestaurantId: json['Restaurant_id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] ?? 0.0).toDouble(),
      isAvailable: json['is_available'] ?? true,
      category: json['category'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  // Convert MenuItem to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'Restaurant_id': RestaurantId,
      'name': name,
      'description': description,
      'price': price,
      'is_available': isAvailable,
      'category': category,
    };
    
    // Only include item_id if it's not null (for updates)
    if (itemId != null) {
      data['item_id'] = itemId;
    }
    
    return data;
  }

  // Copy with method for easy updates
  MenuItem copyWith({
    String? itemId,
    String? RestaurantId,
    String? name,
    String? description,
    double? price,
    bool? isAvailable,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItem(
      itemId: itemId ?? this.itemId,
      RestaurantId: RestaurantId ?? this.RestaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MenuItem{itemId: $itemId, RestaurantId: $RestaurantId, name: $name, description: $description, price: $price, isAvailable: $isAvailable, category: $category}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is MenuItem &&
        other.itemId == itemId &&
        other.RestaurantId == RestaurantId &&
        other.name == name &&
        other.description == description &&
        other.price == price &&
        other.isAvailable == isAvailable &&
        other.category == category;
  }

  @override
  int get hashCode {
    return itemId.hashCode ^
        RestaurantId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        price.hashCode ^
        isAvailable.hashCode ^
        category.hashCode;
  }
}