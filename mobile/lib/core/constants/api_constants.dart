import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _androidBaseUrl = 'http://10.151.80.126:3000';
  static const String _defaultBaseUrl = 'http://localhost:3000';
  static const String _overrideBaseUrl = String.fromEnvironment(
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
}