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
}

class CartItem {
  final String id;
  final String productId;
  final String productName;
  final List<String> imageUrls;
  final double quantity;
  final double unitPrice;
  final double subtotal;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.imageUrls,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
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
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _parseImages(dynamic value) {
    if (value is List) {
      return value
          .map((image) => image.toString())
          .where((image) => image.isNotEmpty)
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
}