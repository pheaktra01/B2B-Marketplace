import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/order/models/order_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<OrderModel>> getFarmerOrders() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/orders/farmer'),
      headers: await _headers(),
    );
    final data = response.body.isEmpty ? [] : jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data is Map ? data['message'] : 'Failed to load orders');
    }
    return (data as List)
        .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final response = await http.patch(
      Uri.parse('${ApiConstants.baseUrl}/orders/$orderId/status'),
      headers: await _headers(),
      body: jsonEncode({'status': status}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data is Map ? data['message'] : 'Failed to update order');
    }
    return OrderModel.fromJson(Map<String, dynamic>.from(data as Map));
  }
  // =========================================================
  // CHECKOUT
  // =========================================================

  Future<List<OrderModel>> checkout({
    required String deliveryAddress,
    required String deliveryMethod,
    required String paymentMethod,
  }) async {
    final prefs =
        await SharedPreferences.getInstance();

    final accessToken =
        prefs.getString('accessToken');

    if (accessToken == null ||
        accessToken.isEmpty) {
      throw Exception(
        'Authentication token not found',
      );
    }

    // =========================================================
    // API REQUEST
    // =========================================================

    final response = await http.post(
      Uri.parse(
        '${ApiConstants.baseUrl}/orders/checkout',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer $accessToken',
      },
      body: jsonEncode({
        'deliveryAddress':
            deliveryAddress,

        'deliveryMethod':
            deliveryMethod,

        'paymentMethod':
            paymentMethod.toLowerCase(),
      }),
    );

    // =========================================================
    // RESPONSE
    // =========================================================

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final orders =
          data['orders'] as List<dynamic>? ?? [];

      return orders
          .map(
            (json) => OrderModel.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      data['message']?.toString() ??
          'Checkout failed',
    );
  }
}