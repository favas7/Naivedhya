class MenuItem {
  final String itemId;
  final String hotelId;
  final String? petpoojaItemId;
  final String itemName;
  final String? itemCode;
  final String? categoryName;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final int inStock; // 1=out of stock, 2=in stock
  final String? itemAttribute; // veg, non-veg, egg
  final String? spiceLevel;
  final bool isFromPetpooja;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSyncedAt;

  MenuItem({
    required this.itemId,
    required this.hotelId,
    this.petpoojaItemId,
    required this.itemName,
    this.itemCode,
    this.categoryName,
    this.description,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    this.inStock = 2,
    this.itemAttribute,
    this.spiceLevel,
    this.isFromPetpooja = false,
    this.createdAt,
    this.updatedAt,
    this.lastSyncedAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      itemId: json['item_id'],
      hotelId: json['hotel_id'],
      petpoojaItemId: json['petpooja_item_id'],
      itemName: json['item_name'],
      itemCode: json['item_code'],
      categoryName: json['category_name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] ?? true,
      inStock: json['in_stock'] ?? 2,
      itemAttribute: json['item_attribute'],
      spiceLevel: json['spice_level'],
      isFromPetpooja: json['is_from_petpooja'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      lastSyncedAt: json['last_synced_at'] != null 
          ? DateTime.parse(json['last_synced_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'hotel_id': hotelId,
      'petpooja_item_id': petpoojaItemId,
      'item_name': itemName,
      'item_code': itemCode,
      'category_name': categoryName,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'in_stock': inStock,
      'item_attribute': itemAttribute,
      'spice_level': spiceLevel,
      'is_from_petpooja': isFromPetpooja,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_synced_at': lastSyncedAt?.toIso8601String(),
    };
  }

  MenuItem copyWith({
    String? itemId,
    String? hotelId,
    String? petpoojaItemId,
    String? itemName,
    String? itemCode,
    String? categoryName,
    String? description,
    double? price,
    String? imageUrl,
    bool? isAvailable,
    int? inStock,
    String? itemAttribute,
    String? spiceLevel,
    bool? isFromPetpooja,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
  }) {
    return MenuItem(
      itemId: itemId ?? this.itemId,
      hotelId: hotelId ?? this.hotelId,
      petpoojaItemId: petpoojaItemId ?? this.petpoojaItemId,
      itemName: itemName ?? this.itemName,
      itemCode: itemCode ?? this.itemCode,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      inStock: inStock ?? this.inStock,
      itemAttribute: itemAttribute ?? this.itemAttribute,
      spiceLevel: spiceLevel ?? this.spiceLevel,
      isFromPetpooja: isFromPetpooja ?? this.isFromPetpooja,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  // Helper: Get attribute icon
  String get attributeIcon {
    switch (itemAttribute?.toLowerCase()) {
      case 'veg':
        return '🟢';
      case 'non-veg':
        return '🔴';
      case 'egg':
        return '🟡';
      default:
        return '⚪';
    }
  }

  // Helper: Check if in stock
  bool get isInStock => inStock == 2;

  @override
  String toString() {
    return 'MenuItem(itemName: $itemName, category: $categoryName, price: $price)';
  }
}

// Menu Category Model
class MenuCategory {
  final String categoryId;
  final String hotelId;
  final String? petpoojaCategoryId;
  final String categoryName;
  final int categoryRank;
  final String? parentCategoryId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MenuCategory({
    required this.categoryId,
    required this.hotelId,
    this.petpoojaCategoryId,
    required this.categoryName,
    this.categoryRank = 0,
    this.parentCategoryId,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      categoryId: json['category_id'],
      hotelId: json['hotel_id'],
      petpoojaCategoryId: json['petpooja_category_id'],
      categoryName: json['category_name'],
      categoryRank: json['category_rank'] ?? 0,
      parentCategoryId: json['parent_category_id'],
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
      'category_id': categoryId,
      'hotel_id': hotelId,
      'petpooja_category_id': petpoojaCategoryId,
      'category_name': categoryName,
      'category_rank': categoryRank,
      'parent_category_id': parentCategoryId,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// Menu Sync Log Model
class MenuSyncLog {
  final String logId;
  final String hotelId;
  final String syncStatus;
  final int itemsSynced;
  final int categoriesSynced;
  final String? errorMessage;
  final int? syncDurationMs;
  final DateTime syncedAt;

  MenuSyncLog({
    required this.logId,
    required this.hotelId,
    required this.syncStatus,
    required this.itemsSynced,
    required this.categoriesSynced,
    this.errorMessage,
    this.syncDurationMs,
    required this.syncedAt,
  });

  factory MenuSyncLog.fromJson(Map<String, dynamic> json) {
    return MenuSyncLog(
      logId: json['log_id'],
      hotelId: json['hotel_id'],
      syncStatus: json['sync_status'],
      itemsSynced: json['items_synced'] ?? 0,
      categoriesSynced: json['categories_synced'] ?? 0,
      errorMessage: json['error_message'],
      syncDurationMs: json['sync_duration_ms'],
      syncedAt: DateTime.parse(json['synced_at']),
    );
  }
}