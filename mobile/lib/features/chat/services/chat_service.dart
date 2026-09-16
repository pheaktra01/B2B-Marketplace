import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    String conversationId, {
    required void Function(Map<String, dynamic> message) onMessage,
    void Function(Map<String, dynamic> payload)? onMessagesRead,
    void Function(String userId)? onTyping,
    void Function(String userId)? onStopTyping,
    void Function(String userId, bool isOnline)? onUserStatusChanged,
  }) async {
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
      socket.emit('join_notifications');
    });

    socket.on('reconnect', (_) {
      socket.emit('join_conversation', {'conversationId': conversationId});
      socket.emit('join_notifications');
    });

    socket.on('message_created', (data) {
      if (data is Map) {
        onMessage(Map<String, dynamic>.from(data));
      }
    });

    if (onMessagesRead != null) {
      socket.on('messages_read', (data) {
        if (data is Map) {
          onMessagesRead(Map<String, dynamic>.from(data));
        }
      });
    }

    if (onTyping != null) {
      socket.on('user_typing', (data) {
        if (data is Map && data['userId'] != null) {
          onTyping(data['userId'].toString());
        }
      });
    }

    if (onStopTyping != null) {
      socket.on('user_stop_typing', (data) {
        if (data is Map && data['userId'] != null) {
          onStopTyping(data['userId'].toString());
        }
      });
    }

    if (onUserStatusChanged != null) {
      socket.on('user_status_changed', (data) {
        if (data is Map && data['userId'] != null) {
          final userId = data['userId'].toString();
          final isOnline = data['isOnline'] == true;
          onUserStatusChanged(userId, isOnline);
        }
      });
    }

    socket.connect();
    return socket;
  }

  void emitTyping(io.Socket? socket, String conversationId) {
    socket?.emit('typing', {'conversationId': conversationId});
  }

  void emitStopTyping(io.Socket? socket, String conversationId) {
    socket?.emit('stop_typing', {'conversationId': conversationId});
  }

  Future<io.Socket> connectToConversationList({
    required void Function(Map<String, dynamic>? data) onConversationUpdated,
    void Function(String userId, bool isOnline)? onUserStatusChanged,
  }) async {
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
      debugPrint('Chat list socket connected');
      socket.emit('join_notifications');
    });

    socket.on('reconnect', (_) {
      debugPrint('Chat list socket reconnected');
      socket.emit('join_notifications');
      onConversationUpdated(null);
    });

    socket.on('conversation_updated', (data) {
      debugPrint('Socket event conversation_updated: $data');
      if (data is Map) {
        onConversationUpdated(Map<String, dynamic>.from(data));
      } else {
        onConversationUpdated(null);
      }
    });

    socket.on('message_created', (data) {
      debugPrint('Socket event message_created: $data');
      if (data is Map) {
        onConversationUpdated(Map<String, dynamic>.from(data));
      } else {
        onConversationUpdated(null);
      }
    });

    socket.on('messages_read', (data) {
      debugPrint('Socket event messages_read: $data');
      if (data is Map) {
        onConversationUpdated(Map<String, dynamic>.from(data));
      } else {
        onConversationUpdated(null);
      }
    });

    socket.on('notification_created', (data) {
      if (data is Map) {
        final type = data['type']?.toString().toLowerCase() ?? '';
        if (type.contains('message') || type.contains('chat')) {
          onConversationUpdated(Map<String, dynamic>.from(data));
        }
      }
    });

    if (onUserStatusChanged != null) {
      socket.on('user_status_changed', (data) {
        if (data is Map && data['userId'] != null) {
          final userId = data['userId'].toString();
          final isOnline = data['isOnline'] == true;
          onUserStatusChanged(userId, isOnline);
        }
      });
    }

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

  // Get single conversation by ID
  Future<Map<String, dynamic>> getConversation(String conversationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/conversations/$conversationId'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load conversation: ${response.body}');
    }

    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic>) {
      return data;
    }
    return Map<String, dynamic>.from(data as Map);
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
