import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _androidBaseUrl =
      'http://192.168.8.128:3000';

  static const String _defaultBaseUrl =
      'http://localhost:3000';

  static const String _overrideBaseUrl =
      String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) {
      return _overrideBaseUrl;
    }

    if (kIsWeb) {
      return _defaultBaseUrl;
    }

    return defaultTargetPlatform == TargetPlatform.android
        ? _androidBaseUrl
        : _defaultBaseUrl;
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