// lib/models/menu_model.dart



/// Customization Option Model (e.g., Small, Medium, Large for size)
class CustomizationOption {
  final String optionId;
  final String customizationId;
  final String name;
  final double additionalPrice;
  final int displayOrder;
  final DateTime createdAt;

  CustomizationOption({
    required this.optionId,
    required this.customizationId,
    required this.name,
    this.additionalPrice = 0,
    this.displayOrder = 0,
    required this.createdAt,
  });

  factory CustomizationOption.fromJson(Map<String, dynamic> json) {
    return CustomizationOption(
      optionId: json['option_id'] ?? '',
      customizationId: json['customization_id'] ?? '',
      name: json['name'] ?? '',
      additionalPrice: (json['additional_price'] ?? 0).toDouble(),
      displayOrder: json['display_order'] ?? 0,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'option_id': optionId,
      'customization_id': customizationId,
      'name': name,
      'additional_price': additionalPrice,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Option($name, +₹$additionalPrice)';
}

/// Menu Item Customization Model (e.g., Size, Toppings)
class MenuItemCustomization {
  final String customizationId;
  final String itemId;
  final String name;
  final String type; // 'SIZE', 'TOPPING', 'ADDON', etc.
  final double basePrice;
  final bool isRequired;
  final int displayOrder;
  final List<CustomizationOption> options;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuItemCustomization({
    required this.customizationId,
    required this.itemId,
    required this.name,
    required this.type,
    this.basePrice = 0,
    this.isRequired = false,
    this.displayOrder = 0,
    this.options = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItemCustomization.fromJson(Map<String, dynamic> json) {
    return MenuItemCustomization(
      customizationId: json['customization_id'] ?? '',
      itemId: json['item_id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'ADDON',
      basePrice: (json['base_price'] ?? 0).toDouble(),
      isRequired: json['is_required'] ?? false,
      displayOrder: json['display_order'] ?? 0,
      options: (json['options'] as List<dynamic>?)
              ?.map((o) => CustomizationOption.fromJson(o))
              .toList() ??
          [],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customization_id': customizationId,
      'item_id': itemId,
      'name': name,
      'type': type,
      'base_price': basePrice,
      'is_required': isRequired,
      'display_order': displayOrder,
      'options': options.map((o) => o.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Customization($name, $type, required: $isRequired)';
}


/// Enhanced Menu Item Model
class MenuItem {
  final String? itemId; 
  final String restaurantId;
  final String name;
  final String? description;
  final double price;
  final bool isAvailable;
  final String? category;
  final int stockQuantity; // NEW: Inventory tracking
  final int lowStockThreshold; // NEW: Low stock alert threshold
  final List<MenuItemCustomization> customizations; // NEW: Customizations
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MenuItem({
    this.itemId,
    required this.restaurantId,
    required this.name,
    this.description,
    required this.price,
    this.isAvailable = true,
    this.category,
    this.stockQuantity = 0,
    this.lowStockThreshold = 5,
    this.customizations = const [],
    this.createdAt,
    this.updatedAt,
  });

  // Check if item is in stock
  bool get isInStock => stockQuantity > 0;
  bool get isLowStock =>
      stockQuantity > 0 && stockQuantity <= lowStockThreshold;

  // Factory constructor to create MenuItem from JSON
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      itemId: json['item_id'],
      restaurantId: json['hotel_id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] ?? 0.0).toDouble(),
      isAvailable: json['is_available'] ?? true,
      category: json['category'],
      stockQuantity: json['stock_quantity'] ?? 0,
      lowStockThreshold: json['low_stock_threshold'] ?? 5,
      customizations: (json['customizations'] as List<dynamic>?)
              ?.map((c) => MenuItemCustomization.fromJson(c))
              .toList() ??
          [],
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
      'hotel_id': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'is_available': isAvailable,
      'category': category,
      'stock_quantity': stockQuantity,
      'low_stock_threshold': lowStockThreshold,
      'customizations': customizations.map((c) => c.toJson()).toList(),
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
    String? restaurantId,
    String? name,
    String? description,
    double? price,
    bool? isAvailable,
    String? category,
    int? stockQuantity,
    int? lowStockThreshold,
    List<MenuItemCustomization>? customizations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItem(
      itemId: itemId ?? this.itemId,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      category: category ?? this.category,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      customizations: customizations ?? this.customizations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MenuItem{itemId: $itemId, RestaurantId: $restaurantId, name: $name, price: $price, stock: $stockQuantity, customizations: ${customizations.length}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MenuItem &&
        other.itemId == itemId &&
        other.restaurantId == restaurantId &&
        other.name == name &&
        other.description == description &&
        other.price == price &&
        other.isAvailable == isAvailable &&
        other.category == category &&
        other.stockQuantity == stockQuantity;
  }

  @override
  int get hashCode {
    return itemId.hashCode ^
        restaurantId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        price.hashCode ^
        isAvailable.hashCode ^
        category.hashCode ^
        stockQuantity.hashCode;
  }
}