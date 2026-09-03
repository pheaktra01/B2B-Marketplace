import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../core/constants/api_constants.dart';

class ChatService {
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

  Future<io.Socket> connectToConversation(
    String conversationId,
    void Function(Map<String, dynamic>) onMessage,
  ) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    final socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      socket.emit('join_conversation', {'conversationId': conversationId});
    });
    socket.on('message_created', (data) {
      if (data is Map) {
        onMessage(Map<String, dynamic>.from(data));
      }
    });
    socket.connect();
    return socket;
  }

  // Get all conversations
  Future<List<dynamic>> getConversations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/conversations'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load conversations: ${response.body}');
    }

    final data = jsonDecode(response.body);

    if (data is List) {
      return data;
    }

    return data['conversations'] ?? [];
  }

  // Create or get conversation
  Future<Map<String, dynamic>> createConversation(String participantId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/conversations'),
      headers: await _headers(),
      body: jsonEncode({'participantId': participantId}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create conversation: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  // Get conversation messages
  Future<List<dynamic>> getMessages(
    String conversationId, {
    int limit = 30,
    String? before,
  }) async {
    final queryParameters = <String, String>{'limit': limit.toString()};
    if (before != null) {
      queryParameters['before'] = before;
    }

    final uri = Uri.parse(
      '$baseUrl/chat/conversations/$conversationId/messages',
    ).replace(queryParameters: queryParameters);

    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Failed to load messages: ${response.body}');
    }

    final data = jsonDecode(response.body);

    if (data is List) {
      return data;
    }

    return data['messages'] ?? [];
  }

  // Send message
  Future<Map<String, dynamic>> sendMessage(
    String conversationId,
    String content, {
    String messageType = 'text',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/conversations/$conversationId/messages'),
      headers: await _headers(),
      body: jsonEncode({'content': content, 'messageType': messageType}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to send message: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  // Mark conversation as read
  Future<void> markAsRead(String conversationId, String messageId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/chat/conversations/$conversationId/read'),
      headers: await _headers(),
      body: jsonEncode({'messageId': messageId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark conversation as read: ${response.body}');
    }
  }

  // Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/chat/conversations/$conversationId'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete conversation: ${response.body}');
    }
  }
}
