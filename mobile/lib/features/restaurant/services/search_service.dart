import 'package:mobile/features/product/services/product_service.dart';

class SearchService {
  Future<List<Map<String, dynamic>>> getProducts() async {
    final products = await ProductService.getAllProducts();
    return products
        .map((product) => Map<String, dynamic>.from(product))
        .toList();
  }

  List<Map<String, dynamic>> filterProducts({
    required List<Map<String, dynamic>> products,
    required String query,
    required String category,
    required int tabIndex,
  }) {
    final normalizedQuery = query.trim().toLowerCase();

    final filtered = products.where((product) {
      final productCategory = product['category']?.toString() ?? '';
      final publisher = product['publisher'];
      final publisherName = publisher is Map
          ? publisher['name']?.toString() ?? ''
          : '';
      final farmerName =
          product['farmerName']?.toString() ??
          product['farmName']?.toString() ??
          publisherName;

      final categoryMatches =
          category == 'All' ||
          productCategory.toLowerCase() == category.toLowerCase();
      if (!categoryMatches) return false;

      final queryMatches =
          normalizedQuery.isEmpty ||
          product['name']?.toString().toLowerCase().contains(normalizedQuery) ==
              true ||
          productCategory.toLowerCase().contains(normalizedQuery) ||
          product['description']?.toString().toLowerCase().contains(
                normalizedQuery,
              ) ==
              true ||
          farmerName.toLowerCase().contains(normalizedQuery);
      if (!queryMatches) return false;

      if (tabIndex == 1) return true;
      return true;
    }).toList();

    return filtered;
  }
}
