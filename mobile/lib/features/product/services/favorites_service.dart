import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _cacheKey = 'favorite_product_ids';

  /// In-memory cache of favorited product IDs for synchronous instant UI checks
  static Set<String>? _cachedIds;

  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Get list of favorited product IDs (synced with backend + local cache)
  static Future<List<String>> getFavoriteIds({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedIds != null) {
      return _cachedIds!.toList();
    }

    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/favorites/ids'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          final ids = data.map((e) => e.toString()).toList();
          _cachedIds = ids.toSet();

          // Sync to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setStringList(_cacheKey, ids);
          return ids;
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch favorite IDs from API, using cache: $e');
    }

    // Fallback to local storage
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getStringList(_cacheKey) ?? [];
    _cachedIds = local.toSet();
    return local;
  }

  /// Fetch full list of favorited products directly from backend
  static Future<List<Map<String, dynamic>>> getFavoriteProducts() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/favorites'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          final products = data
              .map((p) => Map<String, dynamic>.from(p as Map))
              .toList();

          // Update cached IDs from the products
          final ids = products
              .map((p) => p['id']?.toString() ?? '')
              .where((id) => id.isNotEmpty)
              .toList();
          _cachedIds = ids.toSet();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setStringList(_cacheKey, ids);

          return products;
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch favorite products: $e');
      rethrow;
    }
    return [];
  }

  /// Check if a product is favorited
  static Future<bool> isFavorite(String productId) async {
    if (productId.isEmpty) return false;
    final ids = await getFavoriteIds();
    return ids.contains(productId);
  }

  /// Toggle favorite status of a product (optimistic update + backend sync)
  static Future<bool> toggleFavorite(String productId) async {
    if (productId.isEmpty) return false;

    final ids = (await getFavoriteIds()).toSet();
    final bool isNowFav = !ids.contains(productId);

    // 1. Optimistic update
    if (isNowFav) {
      ids.add(productId);
    } else {
      ids.remove(productId);
    }
    _cachedIds = ids;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_cacheKey, ids.toList());

    // 2. Sync to Backend
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/favorites/$productId/toggle'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data is Map && data['isFavorite'] != null) {
          final serverIsFav = data['isFavorite'] == true;
          if (serverIsFav != isNowFav) {
            if (serverIsFav) {
              ids.add(productId);
            } else {
              ids.remove(productId);
            }
            _cachedIds = ids;
            await prefs.setStringList(_cacheKey, ids.toList());
            return serverIsFav;
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to sync favorite toggle with backend: $e');
    }

    return isNowFav;
  }

  /// Get count of favorite products
  static Future<int> getFavoriteCount() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/favorites/count'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['count'] != null) {
          return int.tryParse(data['count'].toString()) ?? 0;
        }
      }
    } catch (e) {
      debugPrint('Failed to get favorite count from backend: $e');
    }

    final ids = await getFavoriteIds();
    return ids.length;
  }
}
