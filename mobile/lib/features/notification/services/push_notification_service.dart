import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/core/routing/app_router.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/core/routing/route_args.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/features/notification/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Top-level background message handler for FCM.
/// Must be annotated with @pragma('vm:entry-point') so it can be called from background isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init error in background handler: $e');
  }
  debugPrint('Handling FCM background message: ${message.messageId}');

  // If this is a data-only message (or Android did not automatically display a notification)
  if (message.notification == null && message.data.isNotEmpty) {
    final localNotifications = FlutterLocalNotificationsPlugin();
    const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await localNotifications.initialize(
      settings: const InitializationSettings(android: androidInitSettings),
    );

    final title = message.data['title']?.toString() ?? 'New Notification';
    final body = message.data['message']?.toString() ??
        message.data['body']?.toString() ??
        '';

    final notifId = (message.messageId != null)
        ? (message.messageId.hashCode.abs() % 2147483647)
        : (DateTime.now().millisecondsSinceEpoch % 2147483647);

    await localNotifications.show(
      id: notifId,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'Used for important notifications like chat, orders, and system alerts.',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          visibility: NotificationVisibility.public,
          fullScreenIntent: false,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
          ticker: 'New notification',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }
}

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static StreamSubscription<Map<String, dynamic>>? _rawNotificationSub;
  static int _notificationCounter = 0;

  /// High importance notification channel for Android heads-up and lock screen alerts
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important notifications like chat, orders, and system alerts.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  /// Initialize Firebase Messaging & Local Notifications
  static Future<void> initialize() async {
    if (kIsWeb) return;
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase.initializeApp() note: $e');
      debugPrint(
        'If Firebase is not yet configured, please ensure google-services.json '
        '(Android) or GoogleService-Info.plist (iOS) is present.',
      );
      return;
    }

    // Register background messaging handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Setup local notifications for Android & iOS
    const androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInitSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );

    // Create the high importance channel on Android
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_channel);
    }

    // Request permissions (iOS and Android 13+)
    await requestPermissions();

    // Enable foreground notification heads-up presentation on iOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen to incoming foreground FCM messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Listen to notification clicks when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM onMessageOpenedApp: ${message.data}');
      _handleRouting(message.data);
    });

    // Check if app was opened from terminated state by a notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('FCM initialMessage: ${initialMessage.data}');
      // Delay slightly to let the router and initial route settle
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleRouting(initialMessage.data);
      });
    }

    // Retrieve and handle FCM device token
    await _setupToken();

    // Connect realtime notification listener to trigger lock-screen & banner alerts
    await startRealtimeNotificationListener();

    _isInitialized = true;
    debugPrint('PushNotificationService initialized successfully');
  }

  /// Request notification permissions (required on iOS and Android 13+)
  static Future<void> requestPermissions() async {
    // 1. Android 13+ (API 33+) native permission request
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      debugPrint('Android 13+ notification permission granted: $granted');
    }

    // 2. Firebase Messaging permission request (for iOS & APNs)
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
      'Push notification authorization status: ${settings.authorizationStatus}',
    );
  }

  /// Retrieve current FCM token and listen for token refresh
  static Future<void> _setupToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('====================================');
        debugPrint('FCM Device Token: $token');
        debugPrint('====================================');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcmToken', token);
        await syncTokenWithBackend(token);
      }
    } catch (e) {
      debugPrint('Failed to retrieve FCM token: $e');
    }

    // Listen for refreshed tokens
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM Device Token refreshed: $newToken');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcmToken', newToken);
      await syncTokenWithBackend(newToken);
    });
  }

  static int _generateNotificationId([String? key]) {
    if (key != null && key.isNotEmpty) {
      return key.hashCode.abs() % 2147483647;
    }
    _notificationCounter = (_notificationCounter + 1) % 100000;
    return (DateTime.now().millisecondsSinceEpoch % 1000000) * 1000 +
        _notificationCounter;
  }

  /// Handle incoming foreground messages and display local notifications
  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground FCM message received: ${message.messageId}');
    final notification = message.notification;
    final data = message.data;

    final title = notification?.title ?? data['title']?.toString() ?? 'Notification';
    final body = notification?.body ?? data['message']?.toString() ?? data['body']?.toString() ?? '';

    final notifId = message.messageId != null
        ? _generateNotificationId(message.messageId)
        : _generateNotificationId();

    showNotification(
      id: notifId,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Display a local heads-up and lock-screen notification
  static Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    int? id,
  }) async {
    if (kIsWeb) return;
    final payloadData = data ?? {'type': 'system', 'message': body};
    final notificationId = id ?? _generateNotificationId();

    await _localNotifications.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          visibility: NotificationVisibility.public,
          fullScreenIntent: false,
          ticker: title,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(payloadData),
    );
  }

  /// Manually trigger a test notification for lock screen and heads-up verification
  static Future<void> showTestNotification({
    String title = 'Test Notification',
    String body = 'This is a test notification. Check your lock screen & status bar!',
    Map<String, dynamic>? data,
  }) async {
    await showNotification(
      title: title,
      body: body,
      data: data ?? {'type': 'system', 'message': body},
    );
  }

  /// Handle user tap on local notification banner
  static void _onLocalNotificationTapped(NotificationResponse response) {
    if (response.payload == null || response.payload!.isEmpty) {
      AppRouter.router.push(AppRoutes.notifications);
      return;
    }

    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _handleRouting(data);
    } catch (e) {
      debugPrint('Error parsing notification payload: $e');
      AppRouter.router.push(AppRoutes.notifications);
    }
  }

  /// Centralized deep link routing based on notification payload data
  static Future<void> _handleRouting(Map<String, dynamic> data) async {
    final type = (data['type'] ?? data['referenceType'] ?? '').toString().toLowerCase();
    final referenceId = data['referenceId']?.toString() ?? data['conversationId']?.toString() ?? data['orderId']?.toString();

    debugPrint('Routing notification: type=$type, referenceId=$referenceId, data=$data');

    // 1. Chat / Messages
    if (type.contains('chat') || type.contains('message') || data.containsKey('conversationId')) {
      final conversationId = data['conversationId']?.toString() ?? referenceId;
      if (conversationId != null && conversationId.isNotEmpty) {
        String participantName = (data['senderName'] ?? data['title'] ?? '').toString().trim();
        if (participantName.startsWith('New Messages from ')) {
          participantName = participantName.replaceFirst('New Messages from ', '').trim();
        } else {
          final lower = participantName.toLowerCase();
          if (lower == 'new message' ||
              lower == 'new messages' ||
              lower == 'new photo message' ||
              lower == 'new order chat' ||
              lower == 'chat' ||
              lower == 'notification') {
            final body = (data['body'] ?? data['message'] ?? '').toString();
            final sentMatch = RegExp(r'^(.+?)\s+sent you', caseSensitive: false).firstMatch(body);
            if (sentMatch != null) {
              participantName = sentMatch.group(1)!.trim();
            } else {
              participantName = '';
            }
          }
        }

        final senderAvatar = data['senderAvatar']?.toString() ??
            data['senderAvatarUrl']?.toString() ??
            data['avatarUrl']?.toString();

        AppRouter.router.push(
          AppRoutes.chatConversation,
          extra: ChatConversationArgs(
            conversationId: conversationId,
            participantName: participantName,
            participantAvatarUrl: senderAvatar,
            isOnline: false,
          ),
        );
        return;
      }
    }

    // 2. Orders & Payments
    if (type.contains('order') || type.contains('payment')) {
      final userRole = (await AuthService.getUserRole())?.toLowerCase();
      if (userRole == 'farmer') {
        if (referenceId != null && referenceId.isNotEmpty) {
          AppRouter.router.push(
            AppRoutes.farmerOrderDetail,
            extra: OrderTrackingArgs(orderId: referenceId),
          );
        } else {
          AppRouter.router.go(AppRoutes.farmerOrders);
        }
      } else {
        if (referenceId != null && referenceId.isNotEmpty) {
          AppRouter.router.push(
            AppRoutes.restaurantOrderTracking,
            extra: OrderTrackingArgs(orderId: referenceId),
          );
        } else {
          AppRouter.router.push(AppRoutes.restaurantOrders);
        }
      }
      return;
    }

    // 3. Products & Stock
    if (type.contains('product') || type.contains('stock') || type.contains('inventory')) {
      final userRole = (await AuthService.getUserRole())?.toLowerCase();
      if (userRole == 'farmer') {
        AppRouter.router.go(AppRoutes.farmerInventory);
      } else {
        AppRouter.router.go(AppRoutes.restaurantHome);
      }
      return;
    }

    // 4. Account & Security
    if (type.contains('account') ||
        type.contains('profile') ||
        type.contains('login') ||
        type.contains('security')) {
      final userRole = (await AuthService.getUserRole())?.toLowerCase();
      if (userRole == 'farmer') {
        AppRouter.router.go(AppRoutes.farmerProfile);
      } else {
        AppRouter.router.go(AppRoutes.restaurantProfile);
      }
      return;
    }

    // Default to notifications screen
    AppRouter.router.push(AppRoutes.notifications);
  }

  /// Send FCM token to backend API if the user is authenticated
  static Future<void> syncTokenWithBackend([String? token]) async {
    if (kIsWeb) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentToken = token ?? prefs.getString('fcmToken');
      final authToken = prefs.getString('accessToken');

      if (currentToken == null || currentToken.isEmpty) return;
      if (authToken == null || authToken.isEmpty) {
        debugPrint('Skip syncing FCM token: User not authenticated yet');
        return;
      }

      await NotificationService().updateDeviceToken(currentToken);
    } catch (e) {
      debugPrint('Failed to sync FCM token with backend: $e');
    }
  }

  /// Clear token cache upon logout
  static Future<void> clearToken() async {
    try {
      stopRealtimeNotificationListener();
      NotificationService.resetState();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcmToken');
      if (!kIsWeb) {
        // Optionally delete instance token so no stale messages arrive
        await _messaging.deleteToken();
      }
    } catch (e) {
      debugPrint('Error clearing FCM token: $e');
    }
  }

  /// Start listening to backend Socket.IO notification events globally
  static Future<void> startRealtimeNotificationListener() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null || token.isEmpty) {
        debugPrint('Skip realtime notification listener: User not authenticated');
        return;
      }

      // Ensure notification socket is connected
      await NotificationService().connectToNotifications();

      // Cancel any previous stream subscription to prevent duplicates
      await _rawNotificationSub?.cancel();
      _rawNotificationSub = NotificationService.onRawNotification.listen((data) {
        debugPrint('Realtime notification received via Socket.IO: $data');
        final title = data['title']?.toString() ?? 'PsarKasekor Notification';
        final body = data['message']?.toString() ?? '';

        showNotification(
          title: title,
          body: body,
          data: Map<String, dynamic>.from(data),
        );
      });

      debugPrint('Global realtime notification listener connected successfully');
    } catch (e) {
      debugPrint('Could not connect global realtime notification listener: $e');
    }
  }

  /// Stop realtime listener on logout
  static void stopRealtimeNotificationListener() {
    _rawNotificationSub?.cancel();
    _rawNotificationSub = null;
  }
}
