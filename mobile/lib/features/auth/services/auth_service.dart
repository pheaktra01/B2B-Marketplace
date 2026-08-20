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

    print('========== LOGIN RESPONSE ==========');
    print('Status: ${result['statusCode']}');
    print('Data: ${result['data']}');

    if (result['statusCode'] >= 200 &&
        result['statusCode'] < 300) {
      final data = result['data'] as Map<String, dynamic>;

      final token = data['accessToken'] ?? data['token'];

      print('Token exists: ${token != null}');
      print('Token length: ${token?.toString().length ?? 0}');

      if (token != null && token.toString().isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(
          'accessToken',
          token.toString(),
        );

        final userId = data['user']?['id'] ?? data['id'];

        if (userId != null) {
          await prefs.setString(
            'userId',
            userId.toString(),
          );
        }

        final savedToken = prefs.getString('accessToken');
        final savedUserId = prefs.getString('userId');

        print('========== AUTH DATA SAVED ==========');
        print('User ID: $savedUserId');
        print('Token exists: ${savedToken != null}');
        print('Token length: ${savedToken?.length ?? 0}');
        print('=====================================');
      }
    }

    print('====================================');

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

  Future<Map<String, dynamic>> logout() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken');

    print('========== LOGOUT ==========');
    print('Token exists: ${token != null}');
    print('Token length: ${token?.length ?? 0}');

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.auth}/logout'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      final decodedBody =
          response.body.isEmpty ? {} : jsonDecode(response.body);

      print('Logout status: ${response.statusCode}');
      print('Logout response: $decodedBody');

      // Always clear local authentication
      await prefs.remove('accessToken');
      await prefs.remove('userId');

      print('Local authentication data cleared');
      print('============================');

      return {
        'statusCode': response.statusCode,
        'data': decodedBody,
      };
    } catch (e) {
      print('Logout error: $e');

      // Even if backend fails, remove local credentials
      await prefs.remove('accessToken');
      await prefs.remove('userId');

      return {
        'statusCode': 0,
        'data': {
          'message': 'Logout failed locally cleared',
          'error': e.toString(),
        },
      };
    }
  }
}