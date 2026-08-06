import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';

class AuthService {
  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.auth}/$path'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    final decodedBody = response.body.isEmpty ? {} : jsonDecode(response.body);

    return {
      'statusCode': response.statusCode,
      'data': decodedBody,
    };
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    return _post('login', {
      'phone': phone,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    required String role,
  }) async {
    return _post('register', {
      'name': name,
      'phone': phone,
      'password': password,
      'role': role,
    });
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String userId,
    required String otp,
  }) async {
    return _post('verify-otp', {
      'userId': userId,
      'otp': otp,
    });
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String phone,
  }) async {
    return _post('forgot-password', {
      'phone': phone,
    });
  }

  Future<Map<String, dynamic>> resetPassword({
    required String phone,
    required String otp,
    required String password,
  }) async {
    return _post('reset-password', {
      'phone': phone,
      'otp': otp,
      'password': password,
    });
  }
}