class Cart {
  final String id;
  final String restaurantId;
  final List<CartItem> items;
  final double total;
  final int itemCount;

  Cart({
    required this.id,
    required this.restaurantId,
    required this.items,
    required this.total,
    required this.itemCount,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id']?.toString() ?? '',
      restaurantId: json['restaurantId']?.toString() ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map(
            (item) => CartItem.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      total: _toDouble(json['total']),
      itemCount: json['itemCount'] ?? 0,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  // ==========================================================
  // DELIVERY FEE
  // ==========================================================

  double get deliveryFee {
    return items.fold(
      0,
      (sum, item) => sum + item.deliveryFee,
    );
  }

  // ==========================================================
  // TAX - 3%
  // ==========================================================

  double get tax {
    return total * 0.03;
  }

  // ==========================================================
  // FINAL TOTAL
  // ==========================================================

  double get grandTotal {
    return total + deliveryFee + tax;
  }

  // ==========================================================
  // IMMUTABLE HELPERS FOR OPTIMISTIC UI
  // ==========================================================

  Cart copyWith({
    String? id,
    String? restaurantId,
    List<CartItem>? items,
    double? total,
    int? itemCount,
  }) {
    return Cart(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      items: items ?? this.items,
      total: total ?? this.total,
      itemCount: itemCount ?? this.itemCount,
    );
  }

  /// Optimistically updates the quantity of an item by productId or itemId.
  /// Recalculates item subtotal and cart total immediately.
  Cart updateItemQuantity({
    required String productId,
    required double newQuantity,
  }) {
    if (newQuantity <= 0) {
      return removeItem(productId: productId);
    }

    final updatedItems = items.map((item) {
      if (item.productId == productId || item.id == productId) {
        final newSubtotal = item.unitPrice * newQuantity;
        return item.copyWith(
          quantity: newQuantity,
          subtotal: newSubtotal,
        );
      }
      return item;
    }).toList();

    final newTotal = updatedItems.fold<double>(
      0.0,
      (sum, item) => sum + item.subtotal,
    );

    return copyWith(
      items: updatedItems,
      total: newTotal,
      itemCount: updatedItems.length,
    );
  }

  /// Optimistically removes an item by productId or itemId.
  /// Recalculates total immediately.
  Cart removeItem({
    required String productId,
  }) {
    final updatedItems = items.where((item) {
      return item.productId != productId && item.id != productId;
    }).toList();

    final newTotal = updatedItems.fold<double>(
      0.0,
      (sum, item) => sum + item.subtotal,
    );

    return copyWith(
      items: updatedItems,
      total: newTotal,
      itemCount: updatedItems.length,
    );
  }
}

class CartItem {
  final String id;
  final String productId;
  final String productName;
  final List<String> imageUrls;
  final double quantity;
  final double unitPrice;
  final double subtotal;

  // NEW
  final double deliveryFee;
  final String deliveryMethod;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.imageUrls,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.deliveryFee,
    required this.deliveryMethod,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? 'Product',
      imageUrls: _parseImages(json['imageUrl']),
      quantity: _toDouble(json['quantity']),
      unitPrice: _toDouble(json['unitPrice']),
      subtotal: _toDouble(json['subtotal']),

      // NEW
      deliveryFee: _toDouble(json['deliveryFee']),

      // NEW
      deliveryMethod:
          json['deliveryMethod']?.toString() ?? 'Local Delivery',
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static List<String> _parseImages(dynamic value) {
    if (value is List) {
      return value
          .map(
            (image) => image.toString(),
          )
          .where(
            (image) => image.isNotEmpty,
          )
          .toList();
    }

    if (value is String && value.isNotEmpty) {
      return [value];
    }

    return [];
  }

  String get imageUrl {
    if (imageUrls.isEmpty) {
      return '';
    }

    return imageUrls.first;
  }

  CartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    List<String>? imageUrls,
    double? quantity,
    double? unitPrice,
    double? subtotal,
    double? deliveryFee,
    String? deliveryMethod,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      imageUrls: imageUrls ?? this.imageUrls,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
    );
  }
}