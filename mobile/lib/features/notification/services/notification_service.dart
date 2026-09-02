import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';

class NotificationService {
  static String get baseUrl => ApiConstants.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // Get notifications
  Future<Map<String, dynamic>> getNotifications({
    int limit = 30,
    int offset = 0,
  }) async {
    final uri = Uri.parse('$baseUrl/notifications').replace(
      queryParameters: {'limit': limit.toString(), 'offset': offset.toString()},
    );

    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Failed to load notifications: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  // Get unread notification count
  Future<int> getUnreadCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/unread-count'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load unread count: ${response.body}');
    }

    final data = jsonDecode(response.body);

    return data['count'] ?? 0;
  }

  // Mark one notification as read
  Future<void> markAsRead(String notificationId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read: ${response.body}');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/read-all'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to mark all notifications as read: ${response.body}',
      );
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/$notificationId'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification: ${response.body}');
    }
  }

  // Delete all notifications
  Future<void> deleteAllNotifications() async {
    final response = await http.delete(
      Uri.parse('$baseUrl/notifications'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notifications: ${response.body}');
    }
  }
}
