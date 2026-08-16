import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
    final result = await _post('login', {
      'phone': phone,
      'password': password,
    });

    if (result['statusCode'] == 200) {
      final data = result['data'];

      // Adjust this depending on your backend response.
      final token = data['accessToken'] ?? data['token'];

      if (token != null && token.toString().isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', token.toString());

        // If backend returns user id, save that too.
        if (data['user']?['id'] != null) {
          await prefs.setString(
            'userId',
            data['user']['id'].toString(),
          );
        } else if (data['id'] != null) {
          await prefs.setString(
            'userId',
            data['id'].toString(),
          );
        }
      }
    }

    return result;
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