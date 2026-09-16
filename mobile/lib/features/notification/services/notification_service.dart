import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../core/constants/api_constants.dart';
import '../models/notification_model.dart';

class NotificationService {
  static String get baseUrl => ApiConstants.baseUrl;

  // Global unread count notifier for instant badge updates across the entire app
  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  // Broadcast streams for real-time notification life-cycle events
  static final StreamController<NotificationModel> _notificationCreatedController =
      StreamController<NotificationModel>.broadcast();
  static Stream<NotificationModel> get onNotificationCreated =>
      _notificationCreatedController.stream;

  static final StreamController<String> _notificationReadController =
      StreamController<String>.broadcast();
  static Stream<String> get onNotificationRead =>
      _notificationReadController.stream;

  static final StreamController<void> _notificationReadAllController =
      StreamController<void>.broadcast();
  static Stream<void> get onNotificationReadAll =>
      _notificationReadAllController.stream;

  static final StreamController<String> _notificationDeletedController =
      StreamController<String>.broadcast();
  static Stream<String> get onNotificationDeleted =>
      _notificationDeletedController.stream;

  static final StreamController<void> _notificationDeletedAllController =
      StreamController<void>.broadcast();
  static Stream<void> get onNotificationDeletedAll =>
      _notificationDeletedAllController.stream;

  static final StreamController<Map<String, dynamic>> _rawNotificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get onRawNotification =>
      _rawNotificationController.stream;

  static io.Socket? _globalSocket;

  static void resetState() {
    unreadCountNotifier.value = 0;
    try {
      _globalSocket?.disconnect();
      _globalSocket?.dispose();
    } catch (_) {}
    _globalSocket = null;
  }

  Future<io.Socket> connectToNotifications([
    void Function(Map<String, dynamic>)? onNotification,
  ]) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    if (_globalSocket != null && _globalSocket!.connected) {
      if (onNotification != null) {
        _globalSocket!.on('notification_created', (data) {
          if (data is Map) {
            onNotification(Map<String, dynamic>.from(data));
          }
        });
      }
      return _globalSocket!;
    }

    // Cleanly close prior socket instance if disconnected
    if (_globalSocket != null) {
      try {
        _globalSocket!.disconnect();
        _globalSocket!.dispose();
      } catch (_) {}
      _globalSocket = null;
    }

    final socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    socket.onConnect((_) {
      debugPrint('Notification socket connected');
      socket.emit('join_notifications');
    });

    socket.on('reconnect', (_) {
      debugPrint('Notification socket reconnected');
      socket.emit('join_notifications');
    });

    socket.on('notification_created', (data) {
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final notification = NotificationModel.fromJson(map);
        if (!notification.isRead) {
          unreadCountNotifier.value = unreadCountNotifier.value + 1;
        }
        _notificationCreatedController.add(notification);
        _rawNotificationController.add(map);
        onNotification?.call(map);
      }
    });

    socket.on('notification_read', (data) {
      if (data is Map && data['notificationId'] != null) {
        final id = data['notificationId'].toString();
        _notificationReadController.add(id);
      }
    });

    socket.on('notification_read_all', (_) {
      unreadCountNotifier.value = 0;
      _notificationReadAllController.add(null);
    });

    socket.on('notification_deleted', (data) {
      if (data is Map && data['notificationId'] != null) {
        final id = data['notificationId'].toString();
        _notificationDeletedController.add(id);
      }
    });

    socket.on('notification_deleted_all', (_) {
      unreadCountNotifier.value = 0;
      _notificationDeletedAllController.add(null);
    });

    socket.on('notification_count_updated', (data) {
      if (data is Map && data['count'] != null) {
        final count = (data['count'] as num).toInt();
        unreadCountNotifier.value = count;
      }
    });

    socket.connect();
    _globalSocket = socket;
    return socket;
  }

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
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/unread-count'),
        headers: await _headers(),
      );

      if (response.statusCode != 200) {
        return unreadCountNotifier.value;
      }

      final data = jsonDecode(response.body);
      final count = (data['count'] as num?)?.toInt() ?? 0;
      unreadCountNotifier.value = count;
      return count;
    } catch (e) {
      debugPrint('Error loading unread count: $e');
      return unreadCountNotifier.value;
    }
  }

  // Mark one notification as read
  Future<void> markAsRead(String notificationId) async {
    if (unreadCountNotifier.value > 0) {
      unreadCountNotifier.value = unreadCountNotifier.value - 1;
    }
    _notificationReadController.add(notificationId);

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
    unreadCountNotifier.value = 0;
    _notificationReadAllController.add(null);

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
    _notificationDeletedController.add(notificationId);

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
    unreadCountNotifier.value = 0;
    _notificationDeletedAllController.add(null);

    final response = await http.delete(
      Uri.parse('$baseUrl/notifications'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notifications: ${response.body}');
    }
  }

  // Update / register FCM device token with backend
  Future<void> updateDeviceToken(String fcmToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/device-token'),
        headers: await _headers(),
        body: jsonEncode({
          'token': fcmToken,
          'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('FCM device token updated successfully on server');
      } else {
        debugPrint('Server responded with ${response.statusCode} for device token registration');
      }
    } catch (e) {
      debugPrint('Error updating device token with server: $e');
    }
  }
}
