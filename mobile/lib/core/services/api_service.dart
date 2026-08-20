import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken');

    print('========== API AUTH ==========');
    print('Token exists: ${token != null}');
    print('Token length: ${token?.length ?? 0}');
    print('==============================');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String url) async {
    final headers = await _headers();

    print('GET: $url');
    print('Authorization attached: ${headers.containsKey('Authorization')}');

    return http.get(
      Uri.parse(url),
      headers: headers,
    );
  }

  static Future<http.Response> post(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _headers();

    return http.post(
      Uri.parse(url),
      headers: headers,
      body: body == null ? null : jsonEncode(body),
    );
  }

  static Future<http.Response> put(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _headers();

    return http.put(
      Uri.parse(url),
      headers: headers,
      body: body == null ? null : jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String url) async {
    final headers = await _headers();

    return http.delete(
      Uri.parse(url),
      headers: headers,
    );
  }
}