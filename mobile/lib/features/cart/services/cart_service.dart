import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/cart/models/cart_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('accessToken');
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  // ==========================================================
  // GET CART
  // ==========================================================

  Future<Cart> getCart() async {
    final headers = await _headers();

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/cart'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data =
          jsonDecode(response.body) as Map<String, dynamic>;

      return Cart.fromJson(data);
    }

    throw Exception(
      'Failed to load cart: ${response.body}',
    );
  }

  // ==========================================================
  // ADD TO CART
  // ==========================================================

  Future<Cart> addToCart({
    required String productId,
    required double quantity,
  }) async {
    final headers = await _headers();

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/cart/items'),
      headers: headers,
      body: jsonEncode({
        'productId': productId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      final data =
          jsonDecode(response.body) as Map<String, dynamic>;

      return Cart.fromJson(data);
    }

    throw Exception(
      'Failed to add product to cart: ${response.body}',
    );
  }

  // ==========================================================
  // UPDATE CART ITEM
  // ==========================================================

  Future<Cart> updateCartItem({
    required String productId,
    required double quantity,
  }) async {
    final headers = await _headers();

    final response = await http.patch(
      Uri.parse(
        '${ApiConstants.baseUrl}/cart/items/$productId',
      ),
      headers: headers,
      body: jsonEncode({
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 200) {
      final data =
          jsonDecode(response.body) as Map<String, dynamic>;

      return Cart.fromJson(data);
    }

    throw Exception(
      'Failed to update cart: ${response.body}',
    );
  }

  // ==========================================================
  // REMOVE ITEM
  // ==========================================================

  Future<Cart> removeFromCart({
    required String productId,
  }) async {
    final headers = await _headers();

    final response = await http.delete(
      Uri.parse(
        '${ApiConstants.baseUrl}/cart/items/$productId',
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data =
          jsonDecode(response.body) as Map<String, dynamic>;

      return Cart.fromJson(data);
    }

    throw Exception(
      'Failed to remove cart item: ${response.body}',
    );
  }

  // ==========================================================
  // CLEAR CART
  // ==========================================================

  Future<void> clearCart() async {
    final headers = await _headers();

    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/cart'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to clear cart: ${response.body}',
      );
    }
  }
}