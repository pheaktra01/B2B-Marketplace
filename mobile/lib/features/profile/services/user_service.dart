import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/constants/api_constants.dart';

class UserService {
  /// Get JWT token from local storage
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken');

    if (token == null || token.isEmpty) {
      throw Exception(
        'Authentication token not found. Please login again.',
      );
    }

    return token;
  }

  /// Headers for authenticated requests
  Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();

    return {
      'Authorization': 'Bearer $token',
    };
  }

  /// Get current logged-in user's profile
  Future<Map<String, dynamic>> getProfile() async {
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}/users/profile',
      ),
      headers: headers,
    );

    return _parseResponse(response);
  }

  /// Update current logged-in user's profile
  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    final headers = await _authHeaders();

    final response = await http.patch(
      Uri.parse(
        '${ApiConstants.baseUrl}/users/profile',
      ),
      headers: {
        ...headers,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    return _parseResponse(response);
  }

  // ============================================================
  // MULTIPART IMAGE UPLOAD
  // ============================================================

  /// Upload profile/avatar image
  Future<Map<String, dynamic>> uploadAvatar(
    String imagePath,
  ) async {
    return _uploadImage(
      endpoint: '/users/profile/avatar',
      imagePath: imagePath,
    );
  }

  /// Upload cover image
  Future<Map<String, dynamic>> uploadCover(
    String imagePath,
  ) async {
    return _uploadImage(
      endpoint: '/users/profile/cover',
      imagePath: imagePath,
    );
  }

  /// Generic multipart image upload
  Future<Map<String, dynamic>> _uploadImage({
    required String endpoint,
    required String imagePath,
  }) async {
    try {
      final headers = await _authHeaders();

      final file = File(imagePath);

      if (!await file.exists()) {
        throw Exception(
          'Image file does not exist: $imagePath',
        );
      }

      final int fileLength = await file.length();

      if (fileLength == 0) {
        throw Exception(
          'Image file is empty.',
        );
      }

      // Detect image type
      final extension = imagePath
          .split('.')
          .last
          .toLowerCase();

      String mimeType;

      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;

        case 'png':
          mimeType = 'image/png';
          break;

        case 'webp':
          mimeType = 'image/webp';
          break;

        case 'gif':
          mimeType = 'image/gif';
          break;

        default:
          mimeType = 'image/jpeg';
      }

      debugPrint('================================');
      debugPrint('MULTIPART IMAGE UPLOAD');
      debugPrint('================================');
      debugPrint('Endpoint: $endpoint');
      debugPrint('Image path: $imagePath');
      debugPrint('Image size: $fileLength bytes');
      debugPrint('Image type: $mimeType');
      debugPrint('================================');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      );

      request.headers.addAll(headers);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imagePath,
          contentType: MediaType.parse(mimeType),
          filename: imagePath.split(Platform.pathSeparator).last,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('================================');
      debugPrint('UPLOAD RESPONSE');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('================================');

      return _parseResponse(response);
    } catch (e) {
      debugPrint(
        'Multipart image upload error: $e',
      );

      rethrow;
    }
  }

  /// Parse HTTP response
  Map<String, dynamic> _parseResponse(
    http.Response response,
  ) {
    dynamic responseData;

    try {
      if (response.body.isNotEmpty) {
        responseData = jsonDecode(
          response.body,
        );
      } else {
        responseData = null;
      }
    } catch (_) {
      responseData = response.body;
    }

    // Success
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return {
        'statusCode': response.statusCode,
        'data': responseData,
      };
    }

    // Error
    String errorMessage;

    if (responseData is Map<String, dynamic>) {
      final message =
          responseData['message'];

      if (message is List) {
        errorMessage =
            message.join(', ');
      } else {
        errorMessage =
            message?.toString() ??
                response.body;
      }
    } else {
      errorMessage = response.body;
    }

    throw Exception(
      'Request failed '
      '(${response.statusCode}): '
      '$errorMessage',
    );
  }
}