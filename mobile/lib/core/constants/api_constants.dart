import 'package:flutter/foundation.dart';

class ApiConstants {
  // Configured via build flag:
  // flutter build apk --release --dart-define=API_BASE_URL=https://your-domain.com
  static const String _overrideBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  // Host port matching docker-compose.yml (3001:3000)
  static const int port = 3000;

  // Local development IP (used as fallback when no API_BASE_URL is injected)
  static const String _lanIp = '192.168.100.237';

  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) {
      // Strip trailing slash if present to avoid double slashes
      return _overrideBaseUrl.endsWith('/')
          ? _overrideBaseUrl.substring(0, _overrideBaseUrl.length - 1)
          : _overrideBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:$port';
    }

    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://$_lanIp:$port'
        : 'http://localhost:$port';
  }

  static String get auth => '$baseUrl/auth';

  // ============================================================
  // IMAGE URL
  // ============================================================

  static String imageUrl(String path) {
    if (path.isEmpty) {
      return '';
    }

    // Already a complete URL
    if (path.startsWith('http://') ||
        path.startsWith('https://')) {
      return path;
    }

    // Backend returns:
    // /uploads/products/example.jpg

    if (path.startsWith('/')) {
      return '$baseUrl$path';
    }

    return '$baseUrl/$path';
  }
}