// models/order_item_model.dart

/// Enhanced Order Item Model with customization support
class OrderItem {
  final String orderId;
  final String itemId;
  int quantity;
  final double price;
  final String? itemName; // For display purposes only - NOT stored in DB
  final List<SelectedCustomization> selectedCustomizations;
  final double customizationAdditionalPrice;

  OrderItem({
    required this.orderId,
    required this.itemId,
    required this.quantity,
    required this.price,
    this.itemName,
    this.selectedCustomizations = const [],
    this.customizationAdditionalPrice = 0,
  });

  /// Factory for reading FROM database (includes item_name from join)
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderId: json['order_id'],
      itemId: json['item_id'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      itemName: json['item_name'], // ✅ Read from join
      selectedCustomizations: (json['selected_customizations'] as List<dynamic>?)
              ?.map((c) => SelectedCustomization.fromJson(c))
              .toList() ??
          [],
      customizationAdditionalPrice:
          (json['customization_additional_price'] ?? 0).toDouble(),
    );
  }

  /// Convert to JSON for JSONB storage (includes item_name)
  /// ✅ NOW includes item_name since we're storing in JSONB, not separate table
  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'item_name': itemName,
      'quantity': quantity,
      'price': price,
      'selected_customizations':
          selectedCustomizations.map((c) => c.toJson()).toList(),
      'customization_additional_price': customizationAdditionalPrice,
    };
  }

  /// Convert to JSON including ALL fields (for complete representation)
  Map<String, dynamic> toJsonComplete() {
    return {
      'order_id': orderId,
      'item_id': itemId,
      'item_name': itemName,
      'quantity': quantity,
      'price': price,
      'selected_customizations':
          selectedCustomizations.map((c) => c.toJson()).toList(),
      'customization_additional_price': customizationAdditionalPrice,
    };
  }

  OrderItem copyWith({
    String? orderId,
    String? itemId,
    int? quantity,
    double? price,
    String? itemName,
    List<SelectedCustomization>? selectedCustomizations,
    double? customizationAdditionalPrice,
  }) {
    return OrderItem(
      orderId: orderId ?? this.orderId,
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      itemName: itemName ?? this.itemName,
      selectedCustomizations:
          selectedCustomizations ?? this.selectedCustomizations,
      customizationAdditionalPrice:
          customizationAdditionalPrice ?? this.customizationAdditionalPrice,
    );
  }

  // Calculate total price for this line item (including customizations)
  double get totalPrice =>
      (price + customizationAdditionalPrice) * quantity;

  // Get price per item including customizations
  double get pricePerItem => price + customizationAdditionalPrice;

  @override
  String toString() {
    return 'OrderItem(orderId: $orderId, itemId: $itemId, quantity: $quantity, price: $price, itemName: $itemName, customizations: ${selectedCustomizations.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItem &&
        other.orderId == orderId &&
        other.itemId == itemId &&
        other.quantity == quantity &&
        other.price == price &&
        other.itemName == itemName;
  }

  @override
  int get hashCode {
    return orderId.hashCode ^
        itemId.hashCode ^
        quantity.hashCode ^
        price.hashCode ^
        itemName.hashCode;
  }
}

/// Selected Customization Model (for tracking user selections)
class SelectedCustomization {
  final String customizationId;
  final String customizationName;
  final String customizationType; // 'SIZE', 'TOPPING', etc.
  final String? selectedOptionId;
  final String selectedOptionName;
  final double additionalPrice;

  SelectedCustomization({
    required this.customizationId,
    required this.customizationName,
    required this.customizationType,
    this.selectedOptionId,
    required this.selectedOptionName,
    this.additionalPrice = 0,
  });

  factory SelectedCustomization.fromJson(Map<String, dynamic> json) {
    return SelectedCustomization(
      customizationId: json['customization_id'] ?? '',
      customizationName: json['customization_name'] ?? '',
      customizationType: json['customization_type'] ?? '',
      selectedOptionId: json['selected_option_id'],
      selectedOptionName: json['selected_option_name'] ?? '',
      additionalPrice: (json['additional_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customization_id': customizationId,
      'customization_name': customizationName,
      'customization_type': customizationType,
      'selected_option_id': selectedOptionId,
      'selected_option_name': selectedOptionName,
      'additional_price': additionalPrice,
    };
  }

  @override
  String toString() =>
      '$customizationName: $selectedOptionName (+₹$additionalPrice)';
}