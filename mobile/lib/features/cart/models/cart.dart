// class Cart {
//   final String id;
//   final String restaurantId;
//   final List<CartItem> items;
//   final double total;
//   final int itemCount;
//   final int totalQuantity;

//   Cart({
//     required this.id,
//     required this.restaurantId,
//     required this.items,
//     required this.total,
//     required this.itemCount,
//     required this.totalQuantity,
//   });

//   factory Cart.fromJson(Map<String, dynamic> json) {
//     final itemsJson = json['items'] as List? ?? [];

//     final items = itemsJson
//         .map(
//           (item) => CartItem.fromJson(
//             Map<String, dynamic>.from(item),
//           ),
//         )
//         .toList();

//     return Cart(
//       id: json['id']?.toString() ?? '',
//       restaurantId: json['restaurantId']?.toString() ?? '',
//       items: items,
//       total: _toDouble(json['total']),
//       itemCount: json['itemCount'] ?? items.length,
//       totalQuantity: json['totalQuantity'] ??
//           items.fold(
//             0,
//             (sum, item) => sum + item.quantity,
//           ),
//     );
//   }

//   static double _toDouble(dynamic value) {
//     if (value is num) {
//       return value.toDouble();
//     }

//     return double.tryParse(
//           value?.toString() ?? '',
//         ) ??
//         0;
//   }
// }

// class CartItem {
//   final String id;
//   final String productId;
//   final String productName;
//   final List<String> imageUrls;
//   final double quantity;
//   final double unitPrice;
//   final double subtotal;

//   CartItem({
//     required this.id,
//     required this.productId,
//     required this.productName,
//     required this.imageUrls,
//     required this.quantity,
//     required this.unitPrice,
//     required this.subtotal,
//   });

//   factory CartItem.fromJson(Map<String, dynamic> json) {
//     final rawImages = json['imageUrl'];

//     List<String> images = [];

//     if (rawImages is List) {
//       images = rawImages
//           .map((image) => image.toString())
//           .where((image) => image.isNotEmpty)
//           .toList();
//     } else if (rawImages != null) {
//       final image = rawImages.toString();

//       if (image.isNotEmpty) {
//         images = [image];
//       }
//     }

//     return CartItem(
//       id: json['id']?.toString() ?? '',
//       productId: json['productId']?.toString() ?? '',
//       productName:
//           json['productName']?.toString() ?? 'Product',
//       imageUrls: images,
//       quantity: _toDouble(json['quantity']),
//       unitPrice: _toDouble(json['unitPrice']),
//       subtotal: _toDouble(json['subtotal']),
//     );
//   }

//   static double _toDouble(dynamic value) {
//     if (value is num) {
//       return value.toDouble();
//     }

//     return double.tryParse(
//           value?.toString() ?? '',
//         ) ??
//         0;
//   }
// }