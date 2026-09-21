import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/cart/models/cart_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  static SharedPreferences? _prefs;
  static String? _cachedToken;
  static DateTime? _lastTokenFetch;

  static const Duration _timeout = Duration(seconds: 15);

  Future<String?> _getToken() async {
    if (_cachedToken != null &&
        _lastTokenFetch != null &&
        DateTime.now().difference(_lastTokenFetch!) < const Duration(minutes: 5)) {
      return _cachedToken;
    }

    _prefs ??= await SharedPreferences.getInstance();
    _cachedToken = _prefs?.getString('accessToken');
    _lastTokenFetch = DateTime.now();

    return _cachedToken;
  }

  /// Invalidate token cache when switching accounts or logging out
  static void invalidateTokenCache() {
    _cachedToken = null;
    _lastTokenFetch = null;
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
    try {
      final headers = await _headers();

      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}/cart'),
            headers: headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Cart.fromJson(data);
      }

      throw Exception(
        'Failed to load cart (${response.statusCode}): ${response.body}',
      );
    } on TimeoutException {
      throw Exception('Connection timed out. Please check your internet connection.');
    } on SocketException {
      throw Exception('Unable to connect to server. Please check your network.');
    }
  }

  // ==========================================================
  // ADD TO CART
  // ==========================================================

  Future<Cart> addToCart({
    required String productId,
    required double quantity,
  }) async {
    try {
      final headers = await _headers();

      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/cart/items'),
            headers: headers,
            body: jsonEncode({
              'productId': productId,
              'quantity': quantity,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Cart.fromJson(data);
      }

      throw Exception(
        'Failed to add product to cart: ${response.body}',
      );
    } on TimeoutException {
      throw Exception('Connection timed out. Please check your internet connection.');
    } on SocketException {
      throw Exception('Unable to connect to server. Please check your network.');
    }
  }

  // ==========================================================
  // UPDATE CART ITEM
  // ==========================================================

  Future<Cart> updateCartItem({
    required String productId,
    required double quantity,
  }) async {
    try {
      final headers = await _headers();

      final response = await http
          .patch(
            Uri.parse('${ApiConstants.baseUrl}/cart/items/$productId'),
            headers: headers,
            body: jsonEncode({
              'quantity': quantity,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Cart.fromJson(data);
      }

      throw Exception(
        'Failed to update cart: ${response.body}',
      );
    } on TimeoutException {
      throw Exception('Connection timed out. Please check your internet connection.');
    } on SocketException {
      throw Exception('Unable to connect to server. Please check your network.');
    }
  }

  // ==========================================================
  // REMOVE ITEM
  // ==========================================================

  Future<Cart> removeFromCart({
    required String productId,
  }) async {
    try {
      final headers = await _headers();

      final response = await http
          .delete(
            Uri.parse('${ApiConstants.baseUrl}/cart/items/$productId'),
            headers: headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Cart.fromJson(data);
      }

      throw Exception(
        'Failed to remove cart item: ${response.body}',
      );
    } on TimeoutException {
      throw Exception('Connection timed out. Please check your internet connection.');
    } on SocketException {
      throw Exception('Unable to connect to server. Please check your network.');
    }
  }

  // ==========================================================
  // CLEAR CART
  // ==========================================================

  Future<void> clearCart() async {
    try {
      final headers = await _headers();

      final response = await http
          .delete(
            Uri.parse('${ApiConstants.baseUrl}/cart'),
            headers: headers,
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to clear cart: ${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('Connection timed out. Please check your internet connection.');
    } on SocketException {
      throw Exception('Unable to connect to server. Please check your network.');
    }
  }
}