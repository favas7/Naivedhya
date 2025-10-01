// models/order_item_model.dart
class OrderItem {
  final String orderId;
  final String itemId;
  final int quantity;
  final double price;
  final String? itemName; // For display purposes, fetched from menu_items join

  OrderItem({
    required this.orderId,
    required this.itemId,
    required this.quantity,
    required this.price,
    this.itemName,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderId: json['order_id'],
      itemId: json['item_id'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      itemName: json['item_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'item_id': itemId,
      'quantity': quantity,
      'price': price,
    };
  }

  OrderItem copyWith({
    String? orderId,
    String? itemId,
    int? quantity,
    double? price,
    String? itemName,
  }) {
    return OrderItem(
      orderId: orderId ?? this.orderId,
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      itemName: itemName ?? this.itemName,
    );
  }

  // Calculate total price for this line item
  double get totalPrice => price * quantity;

  @override
  String toString() {
    return 'OrderItem(orderId: $orderId, itemId: $itemId, quantity: $quantity, price: $price, itemName: $itemName)';
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