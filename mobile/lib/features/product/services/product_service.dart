import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/constants/api_constants.dart';

class ProductService {
  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null || token.isEmpty) {
      throw Exception('You are not logged in. Please login again.');
    }

    return token;
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ================= CREATE =================

  static Future<Map<String, dynamic>> createProduct({
    required String name,
    String? description,
    required String category,
    required String condition,
    required double price,
    required double quantity,
    required double minOrder,
    DateTime? harvestDate,
    DateTime? availableUntil,
    required String location,
    required String deliveryMethod,
    required double deliveryFee,
    String? imageBase64,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/products'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'description': description,
        'category': category,
        'condition': condition,
        'price': price,
        'quantity': quantity,
        'minOrder': minOrder,
        'harvestDate': harvestDate?.toIso8601String(),
        'availableUntil': availableUntil?.toIso8601String(),
        'location': location,
        'deliveryMethod': deliveryMethod,
        'deliveryFee': deliveryFee,
        'imageBase64': imageBase64,
      }),
    );

    final data = response.body.isEmpty
        ? {}
        : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        data is Map
            ? data['message']?.toString() ??
                'Failed to create product'
            : 'Failed to create product',
      );
    }

    return Map<String, dynamic>.from(data);
  }

  // ================= MY PRODUCTS =================

  static Future<List<Map<String, dynamic>>> getMyProducts() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/products/my'),
      headers: await _headers(),
    );

    final data = response.body.isEmpty
        ? []
        : jsonDecode(response.body);

    print('========== MY PRODUCTS ==========');
    print('Status: ${response.statusCode}');
    print('Data: $data');
    print('==================================');

    if (response.statusCode != 200) {
      throw Exception(
        data is Map
            ? data['message']?.toString() ??
                'Failed to load products'
            : 'Failed to load products',
      );
    }

    if (data is! List) {
      throw Exception('Invalid products response');
    }

    return data
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // ================= GET ALL PRODUCTS =================

  static Future<List<dynamic>> getAllProducts() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/products'),
    );

    final data = response.body.isEmpty
        ? []
        : jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception('Failed to load products');
    }

    return data;
  }

  // ================= GET ONE =================

  static Future<Map<String, dynamic>> getProduct(
    String productId,
  ) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/products/$productId'),
    );

    final data = response.body.isEmpty
        ? {}
        : jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data['message']?.toString() ?? 'Product not found',
      );
    }

    return Map<String, dynamic>.from(data);
  }

  // ================= UPDATE =================

  static Future<Map<String, dynamic>> updateProduct({
    required String productId,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.patch(
      Uri.parse(
        '${ApiConstants.baseUrl}/products/$productId',
      ),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    final responseData = response.body.isEmpty
        ? {}
        : jsonDecode(response.body);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        responseData is Map
            ? responseData['message']?.toString() ??
                'Failed to update product'
            : 'Failed to update product',
      );
    }

    return Map<String, dynamic>.from(responseData);
  }

  // ================= DELETE =================

  static Future<void> deleteProduct({
    required String productId,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '${ApiConstants.baseUrl}/products/$productId',
      ),
      headers: await _headers(),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      final data = response.body.isEmpty
          ? {}
          : jsonDecode(response.body);

      throw Exception(
        data is Map
            ? data['message']?.toString() ??
                'Failed to delete product'
            : 'Failed to delete product',
      );
    }
  }
}