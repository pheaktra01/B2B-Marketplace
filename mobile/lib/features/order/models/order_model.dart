import 'package:mobile/l10n/app_localizations.dart';

class OrderModel {
  final String id;
  final String farmerId;
  final String? restaurantId;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final String deliveryMethod;
  final String deliveryAddress;
  final double subtotal;
  final double transactionFee;
  final double deliveryFee;
  final double total;
  final DateTime? createdAt;
  final List<OrderItemModel> items;

  // Enriched party profiles
  final String? buyerName;
  final String? buyerPhone;
  final String? buyerAvatarUrl;
  final String? farmerName;
  final String? farmerPhone;
  final String? farmerAvatarUrl;

  OrderModel({
    required this.id,
    required this.farmerId,
    this.restaurantId,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.deliveryMethod,
    required this.deliveryAddress,
    required this.subtotal,
    required this.transactionFee,
    required this.deliveryFee,
    required this.total,
    this.createdAt,
    this.items = const [],
    this.buyerName,
    this.buyerPhone,
    this.buyerAvatarUrl,
    this.farmerName,
    this.farmerPhone,
    this.farmerAvatarUrl,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final buyer = json['buyer'] as Map<String, dynamic>?;
    final farmer = json['farmer'] as Map<String, dynamic>?;

    final buyerName = json['buyerName']?.toString() ??
        buyer?['name']?.toString() ??
        json['customerName']?.toString();
    final buyerPhone = json['buyerPhone']?.toString() ??
        buyer?['phone']?.toString();
    final buyerAvatarUrl = json['buyerAvatarUrl']?.toString() ??
        buyer?['avatarUrl']?.toString();

    final farmerName = json['farmerName']?.toString() ??
        farmer?['name']?.toString();
    final farmerPhone = json['farmerPhone']?.toString() ??
        farmer?['phone']?.toString();
    final farmerAvatarUrl = json['farmerAvatarUrl']?.toString() ??
        farmer?['avatarUrl']?.toString();

    return OrderModel(
      id: json['id']?.toString() ?? '',
      farmerId: json['farmerId']?.toString() ?? '',
      restaurantId: json['restaurantId']?.toString() ?? buyer?['id']?.toString(),
      status: json['status']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      deliveryMethod: json['deliveryMethod']?.toString() ?? '',
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      subtotal: _toDouble(json['subtotal']),
      transactionFee: _toDouble(json['transactionFee']),
      deliveryFee: _toDouble(json['deliveryFee']),
      total: _toDouble(json['total']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItemModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
      buyerName: buyerName,
      buyerPhone: buyerPhone,
      buyerAvatarUrl: buyerAvatarUrl,
      farmerName: farmerName,
      farmerPhone: farmerPhone,
      farmerAvatarUrl: farmerAvatarUrl,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  String get displayId {
    if (id.length <= 8) return id.toUpperCase();
    return id.substring(0, 8).toUpperCase();
  }

  String get formattedDate {
    if (createdAt == null) return '';
    final dt = createdAt!.toLocal();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[dt.month - 1];
    final day = dt.day;
    final year = dt.year;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$month $day, $year • $hour:$minute $ampm';
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmed';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
      default:
        return 'Pending Confirmation';
    }
  }

  String getLocalizedStatus(AppLocalizations? l10n) {
    if (l10n == null) return statusLabel;
    switch (status.toLowerCase()) {
      case 'confirmed':
        return l10n.orderStatusConfirmed;
      case 'processing':
        return l10n.orderStatusProcessing;
      case 'shipped':
        return l10n.orderStatusShipped;
      case 'delivered':
        return l10n.orderStatusDelivered;
      case 'cancelled':
        return l10n.orderStatusCancelled;
      case 'pending':
      default:
        return l10n.orderStatusPending;
    }
  }

  int get progressStepIndex {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'confirmed':
        return 1;
      case 'processing':
        return 2;
      case 'shipped':
        return 3;
      case 'delivered':
        return 4;
      case 'cancelled':
      default:
        return -1;
    }
  }

  bool get isCompleted =>
      status.toLowerCase() == 'delivered' || status.toLowerCase() == 'cancelled';
}

class OrderItemModel {
  final String? productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double subtotal;
  final String? imageUrl;

  const OrderItemModel({
    this.productId,
    required this.productName,
    required this.quantity,
    this.unitPrice = 0,
    required this.subtotal,
    this.imageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    String? img = json['imageUrl']?.toString() ?? json['image_url']?.toString();
    if (img == null || img.isEmpty) {
      if (json['imageUrls'] is List && (json['imageUrls'] as List).isNotEmpty) {
        img = (json['imageUrls'] as List).first.toString();
      } else if (json['product'] is Map) {
        final p = json['product'] as Map<String, dynamic>;
        img = p['imageUrl']?.toString() ?? p['image_url']?.toString();
        if (img == null || img.isEmpty) {
          if (p['imageUrls'] is List && (p['imageUrls'] as List).isNotEmpty) {
            img = (p['imageUrls'] as List).first.toString();
          }
        }
      }
    }

    return OrderItemModel(
      productId: json['productId']?.toString(),
      productName: json['productName']?.toString() ?? 'Product',
      quantity: OrderModel._toDouble(json['quantity']),
      unitPrice: OrderModel._toDouble(json['unitPrice']),
      subtotal: OrderModel._toDouble(json['subtotal']),
      imageUrl: img,
    );
  }
}