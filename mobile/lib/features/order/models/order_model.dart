class OrderModel {
  final String id;
  final String farmerId;
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

  OrderModel({
    required this.id,
    required this.farmerId,
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
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      farmerId: json['farmerId']?.toString() ?? '',
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
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }
}