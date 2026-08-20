class Product {
  final String id;
  final String name;
  final String? description;
  final String category;
  final String condition;
  final double price;
  final double quantity;
  final double minOrder;
  final String? imageBase64;
  final DateTime? harvestDate;
  final DateTime? availableUntil;
  final String location;
  final String deliveryMethod;
  final double deliveryFee;
  final String farmerId;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.condition,
    required this.price,
    required this.quantity,
    required this.minOrder,
    this.imageBase64,
    this.harvestDate,
    this.availableUntil,
    required this.location,
    required this.deliveryMethod,
    required this.deliveryFee,
    required this.farmerId,
    required this.isAvailable,
  });

  factory Product.fromJson(
    Map<String, dynamic> json,
  ) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'] ?? '',
      condition: json['condition'] ?? 'Fresh',

      price: double.tryParse(
            json['price']?.toString() ?? '0',
          ) ??
          0,

      quantity: double.tryParse(
            json['quantity']?.toString() ?? '0',
          ) ??
          0,

      minOrder: double.tryParse(
            json['minOrder']?.toString() ?? '0',
          ) ??
          0,

      imageBase64: json['imageBase64'],

      harvestDate:
          json['harvestDate'] != null
              ? DateTime.parse(
                  json['harvestDate'].toString(),
                )
              : null,

      availableUntil:
          json['availableUntil'] != null
              ? DateTime.parse(
                  json['availableUntil'].toString(),
                )
              : null,

      location: json['location'] ?? '',

      deliveryMethod:
          json['deliveryMethod'] ?? '',

      deliveryFee: double.tryParse(
            json['deliveryFee']?.toString() ?? '0',
          ) ??
          0,

      farmerId: json['farmerId'],

      isAvailable:
          json['isAvailable'] ?? true,
    );
  }
}