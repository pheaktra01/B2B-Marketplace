import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/order/models/order_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
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