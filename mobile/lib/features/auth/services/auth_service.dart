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

  static Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final expiry = prefs.getInt('tokenExpiry');

    if (token == null || token.isEmpty || expiry == null) {
      return false;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= expiry) {
      print('Token expired after 7 days. Clearing local auth.');
      await clearAuth();
      return false;
    }

    return true;
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('userId');
    await prefs.remove('userRole');
    await prefs.remove('tokenExpiry');
    print('Local authentication data cleared');
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

        final role = data['user']?['role'] ?? data['role'];
        if (role != null) {
          await prefs.setString(
            'userRole',
            role.toString(),
          );
        }

        // Set token expiration to 7 days from now
        final sevenDaysExpiry = DateTime.now()
            .add(const Duration(days: 7))
            .millisecondsSinceEpoch;
        await prefs.setInt('tokenExpiry', sevenDaysExpiry);

        final savedToken = prefs.getString('accessToken');
        final savedUserId = prefs.getString('userId');
        final savedRole = prefs.getString('userRole');

        print('========== AUTH DATA SAVED (7 DAYS) ==========');
        print('User ID: $savedUserId');
        print('User Role: $savedRole');
        print('Token exists: ${savedToken != null}');
        print('Token Expiry: ${DateTime.fromMillisecondsSinceEpoch(sevenDaysExpiry)}');
        print('=============================================');
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

      // Clear local credentials
      await clearAuth();

      print('============================');

      return {
        'statusCode': response.statusCode,
        'data': decodedBody,
      };
    } catch (e) {
      print('Logout error: $e');

      // Even if backend fails, remove local credentials
      await clearAuth();

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