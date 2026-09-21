import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../notification/services/push_notification_service.dart';

class AuthService {
  static SharedPreferences? _cachedPrefs;
  static String? _cachedRole;
  static String? _cachedToken;

  /// Fast cached access to SharedPreferences to prevent repeated disk I/O
  static Future<SharedPreferences> _getPrefs() async {
    return _cachedPrefs ??= await SharedPreferences.getInstance();
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.auth}/$path'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      final decodedBody =
          response.body.isEmpty ? {} : jsonDecode(response.body);

      return {
        'statusCode': response.statusCode,
        'data': decodedBody,
      };
    } on TimeoutException {
      return {
        'statusCode': 408,
        'data': {
          'message': 'Connection timed out. Please check your network and try again.',
        },
      };
    } on SocketException {
      return {
        'statusCode': 503,
        'data': {
          'message': 'Unable to connect to server. Please check your internet connection.',
        },
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'data': {
          'message': 'An unexpected error occurred: $e',
        },
      };
    }
  }

  static Future<bool> isTokenValid() async {
    final prefs = await _getPrefs();
    final token = _cachedToken ?? prefs.getString('accessToken');
    final expiry = prefs.getInt('tokenExpiry');

    if (token == null || token.isEmpty || expiry == null) {
      return false;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= expiry) {
      debugPrint('Token expired after 7 days. Clearing local auth.');
      await clearAuth();
      return false;
    }

    _cachedToken = token;
    return true;
  }

  static Future<String?> getUserRole() async {
    if (_cachedRole != null && _cachedRole!.isNotEmpty) {
      return _cachedRole;
    }
    final prefs = await _getPrefs();
    _cachedRole = prefs.getString('userRole');
    return _cachedRole;
  }

  static Future<void> clearAuth() async {
    _cachedToken = null;
    _cachedRole = null;
    final prefs = await _getPrefs();
    await prefs.remove('accessToken');
    await prefs.remove('userId');
    await prefs.remove('userRole');
    await prefs.remove('tokenExpiry');
    await PushNotificationService.clearToken();
    debugPrint('Local authentication data cleared');
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final result = await _post('login', {
      'phone': phone,
      'password': password,
    });

    debugPrint('========== LOGIN RESPONSE ==========');
    debugPrint('Status: ${result['statusCode']}');
    debugPrint('Data: ${result['data']}');

    if (result['statusCode'] >= 200 &&
        result['statusCode'] < 300) {
      final data = result['data'] as Map<String, dynamic>;

      final token = data['accessToken'] ?? data['token'];

      debugPrint('Token exists: ${token != null}');
      debugPrint('Token length: ${token?.toString().length ?? 0}');

      if (token != null && token.toString().isNotEmpty) {
        final prefs = await _getPrefs();

        _cachedToken = token.toString();
        await prefs.setString(
          'accessToken',
          _cachedToken!,
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
          _cachedRole = role.toString();
          await prefs.setString(
            'userRole',
            _cachedRole!,
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

        debugPrint('========== AUTH DATA SAVED (7 DAYS) ==========');
        debugPrint('User ID: $savedUserId');
        debugPrint('User Role: $savedRole');
        debugPrint('Token exists: ${savedToken != null}');
        debugPrint('Token Expiry: ${DateTime.fromMillisecondsSinceEpoch(sevenDaysExpiry)}');
        debugPrint('=============================================');

        // Sync FCM device token with backend asynchronously
        unawaited(PushNotificationService.syncTokenWithBackend().catchError((e) {
          debugPrint('Error syncing push token: $e');
        }));

        // Start listening to realtime notifications
        unawaited(PushNotificationService.startRealtimeNotificationListener().catchError((e) {
          debugPrint('Error starting notification listener: $e');
        }));
      }
    }

    debugPrint('====================================');

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
    final prefs = await _getPrefs();
    final token = _cachedToken ?? prefs.getString('accessToken');

    debugPrint('========== LOGOUT ==========');
    debugPrint('Token exists: ${token != null}');
    debugPrint('Token length: ${token?.length ?? 0}');

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.auth}/logout'),
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      final decodedBody =
          response.body.isEmpty ? {} : jsonDecode(response.body);

      debugPrint('Logout status: ${response.statusCode}');
      debugPrint('Logout response: $decodedBody');

      // Clear local credentials
      await clearAuth();

      debugPrint('============================');

      return {
        'statusCode': response.statusCode,
        'data': decodedBody,
      };
    } catch (e) {
      debugPrint('Logout error: $e');

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