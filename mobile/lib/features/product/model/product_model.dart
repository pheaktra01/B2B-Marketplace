class Product {
  final String id;
  final String name;
  final String? description;
  final String category;
  final String condition;
  final double price;
  final double quantity;
  final double minOrder;

  final List<String> imagePaths;

  final DateTime? harvestDate;
  final DateTime? availableUntil;
  final String location;
  final String deliveryMethod;
  final double deliveryFee;
  final String farmerId;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.condition,
    required this.price,
    required this.quantity,
    required this.minOrder,
    required this.imagePaths,
    this.harvestDate,
    this.availableUntil,
    required this.location,
    required this.deliveryMethod,
    required this.deliveryFee,
    required this.farmerId,
    required this.isAvailable,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),

      category: json['category']?.toString() ?? '',
      condition: json['condition']?.toString() ?? 'Fresh',

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

      imagePaths: _parseImages(json),

      harvestDate: _parseDate(
        json['harvestDate'],
      ),

      availableUntil: _parseDate(
        json['availableUntil'],
      ),

      location: json['location']?.toString() ?? '',

      deliveryMethod:
          json['deliveryMethod']?.toString() ?? '',

      deliveryFee: double.tryParse(
            json['deliveryFee']?.toString() ?? '0',
          ) ??
          0,

      farmerId:
          json['farmerId']?.toString() ?? '',

      isAvailable:
          json['isAvailable'] == true,

      createdAt: _parseDate(
        json['createdAt'],
      ),

      updatedAt: _parseDate(
        json['updatedAt'],
      ),
    );
  }

  static List<String> _parseImages(
    Map<String, dynamic> json,
  ) {
    final images = json['imageUrls'];

    if (images is List) {
      return images
          .map(
            (image) => image.toString(),
          )
          .where(
            (image) => image.isNotEmpty,
          )
          .toList();
    }

    return [];
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}