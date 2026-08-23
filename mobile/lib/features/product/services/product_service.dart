import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/constants/api_constants.dart';

class ProductService {
  // ============================================================
  // AUTH
  // ============================================================

  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken');

    if (token == null || token.isEmpty) {
      throw Exception(
        'You are not logged in. Please login again.',
      );
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

  // ============================================================
  // CREATE PRODUCT
  // ============================================================

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
    required List<XFile> images,
  }) async {
    final token = await _getToken();

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/products',
    );

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    request.headers['Authorization'] =
        'Bearer $token';

    // ==========================================================
    // PRODUCT FIELDS
    // ==========================================================

    request.fields['name'] = name;

    request.fields['description'] =
        description ?? '';

    request.fields['category'] =
        category;

    request.fields['condition'] =
        condition;

    request.fields['price'] =
        price.toString();

    request.fields['quantity'] =
        quantity.toString();

    request.fields['minOrder'] =
        minOrder.toString();

    if (harvestDate != null) {
      request.fields['harvestDate'] =
          harvestDate.toIso8601String();
    }

    if (availableUntil != null) {
      request.fields['availableUntil'] =
          availableUntil.toIso8601String();
    }

    request.fields['location'] =
        location;

    request.fields['deliveryMethod'] =
        deliveryMethod;

    request.fields['deliveryFee'] =
        deliveryFee.toString();

    // ==========================================================
    // IMAGES
    // ==========================================================

    for (final image in images) {
      final mimeType =
          lookupMimeType(image.name) ?? 'image/jpeg';

      final mimeParts =
          mimeType.split('/');

      final bytes =
          await image.readAsBytes();

      final multipartFile =
          http.MultipartFile.fromBytes(
        'images',
        bytes,
        filename: image.name,
        contentType: MediaType(
          mimeParts[0],
          mimeParts[1],
        ),
      );

      request.files.add(
        multipartFile,
      );

      print(
        'Image: ${image.name}',
      );

      print(
        'MIME: $mimeType',
      );

      print(
        'Size: ${bytes.length} bytes',
      );
    }

    // ==========================================================
    // DEBUG
    // ==========================================================

    print(
      '========== CREATE PRODUCT =========',
    );

    print(
      'URL: $uri',
    );

    print(
      'Images: ${images.length}',
    );

    print(
      'Fields: ${request.fields}',
    );

    print(
      '===================================',
    );

    // ==========================================================
    // SEND REQUEST
    // ==========================================================

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    final data =
        response.body.isEmpty
            ? <String, dynamic>{}
            : jsonDecode(response.body);

    print(
      'Status: ${response.statusCode}',
    );

    print(
      'Response: $data',
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        data is Map
            ? data['message']?.toString() ??
                'Failed to create product'
            : 'Failed to create product',
      );
    }

    return Map<String, dynamic>.from(
      data,
    );
  }

  // ============================================================
  // GET MY PRODUCTS
  // ============================================================

  static Future<List<Map<String, dynamic>>>
      getMyProducts() async {
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}/products/my',
      ),
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
      throw Exception(
        'Invalid products response',
      );
    }

    return data
        .map(
          (item) =>
              Map<String, dynamic>.from(item),
        )
        .toList();
  }

  // ============================================================
  // GET ALL PRODUCTS
  // ============================================================

  static Future<List<dynamic>> getAllProducts() async {
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}/products',
      ),
    );

    final data = response.body.isEmpty
        ? []
        : jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data is Map
            ? data['message']?.toString() ??
                'Failed to load products'
            : 'Failed to load products',
      );
    }

    return data;
  }

  // ============================================================
  // GET ONE PRODUCT
  // ============================================================

  static Future<Map<String, dynamic>> getProduct(
    String productId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}/products/$productId',
      ),
    );

    final data = response.body.isEmpty
        ? {}
        : jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data is Map
            ? data['message']?.toString() ??
                'Product not found'
            : 'Product not found',
      );
    }

    return Map<String, dynamic>.from(data);
  }

  // ============================================================
  // UPDATE PRODUCT
  // ============================================================

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

    return Map<String, dynamic>.from(
      responseData,
    );
  }

  // ============================================================
  // DELETE PRODUCT
  // ============================================================

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