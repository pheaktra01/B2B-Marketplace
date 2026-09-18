import 'dart:convert';
import 'package:mobile/core/constants/api_constants.dart';

class Conversation {
  final String id;
  final String participantId;
  final String name;
  final String role;
  final String message;
  final String time;
  final DateTime? updatedAt;
  final int unreadCount;
  final bool isOnline;
  final String avatarUrl;

  const Conversation({
    required this.id,
    required this.participantId,
    required this.name,
    required this.role,
    required this.message,
    required this.time,
    required this.updatedAt,
    required this.unreadCount,
    required this.isOnline,
    required this.avatarUrl,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final participant = json['participant'] as Map<String, dynamic>? ?? {};
    final lastMessage = json['lastMessage'] as Map<String, dynamic>?;
    final messageDateStr = lastMessage?['createdAt']?.toString() ??
        json['updatedAt']?.toString() ??
        json['createdAt']?.toString();
    final updatedAt = DateTime.tryParse(messageDateStr ?? '');

    String previewMessage = 'No messages yet';
    if (lastMessage != null) {
      final msgType = lastMessage['messageType']?.toString();
      final content = lastMessage['content']?.toString();
      previewMessage = formatPreview(msgType, content);
    }

    return Conversation(
      id: json['id'].toString(),
      participantId: participant['id']?.toString() ?? '',
      name: participant['name']?.toString() ?? 'Unknown user',
      role: participant['role']?.toString() ?? '',
      message: previewMessage,
      time: formatTime(updatedAt),
      updatedAt: updatedAt,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isOnline: participant['isOnline'] == true,
      avatarUrl:
          participant['avatarUrl'] == null ||
              participant['avatarUrl'].toString().isEmpty
          ? 'assets/default_avatar.jpg'
          : ApiConstants.imageUrl(participant['avatarUrl'].toString()),
    );
  }

  static String formatPreview(String? msgType, String? rawContent) {
    if (rawContent == null || rawContent.trim().isEmpty) {
      if (msgType == 'image') return '📷 Photo';
      if (msgType == 'product') return '🛒 Shared a product';
      if (msgType == 'order') return '📄 Shared an order quote';
      if (msgType == 'attachment' || msgType == 'file') return '📎 Shared an attachment';
      return 'No messages yet';
    }

    final trimmed = rawContent.trim();

    // 1. Explicit messageType handling
    if (msgType == 'image') {
      return '📷 Photo';
    }

    if (msgType == 'product') {
      final title = _extractProductTitle(trimmed);
      if (title != null && title.isNotEmpty) {
        return '🛒 Shared a product: $title';
      }
      return '🛒 Shared a product';
    }

    if (msgType == 'order') {
      final orderRef = _extractOrderRef(trimmed);
      if (orderRef != null && orderRef.isNotEmpty) {
        return '📄 Shared an order quote ($orderRef)';
      }
      return '📄 Shared an order quote';
    }

    if (msgType == 'attachment' || msgType == 'file') {
      return '📎 Shared an attachment';
    }

    // 2. Safety Net for JSON/structured payloads (even if messageType was 'text' or null)
    if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
      // Check if it represents a product
      if (trimmed.contains('title') || trimmed.contains('price') || trimmed.contains('unit')) {
        final title = _extractProductTitle(trimmed);
        if (title != null && title.isNotEmpty) {
          return '🛒 Shared a product: $title';
        }
        return '🛒 Shared a product';
      }

      // Check if it represents an order
      if (trimmed.contains('displayId') ||
          trimmed.contains('itemCount') ||
          (trimmed.contains('status') && trimmed.contains('total'))) {
        final orderRef = _extractOrderRef(trimmed);
        if (orderRef != null && orderRef.isNotEmpty) {
          return '📄 Shared an order quote ($orderRef)';
        }
        return '📄 Shared an order quote';
      }

      // Check if it represents an image payload
      if (trimmed.contains('imageUrl') || trimmed.contains('imageUrls')) {
        return '📷 Photo';
      }

      // Fallback for any other structured payload
      return '📎 Shared an attachment';
    }

    // Check if raw text looks like a direct image URL or path
    final lower = trimmed.toLowerCase();
    if (lower.startsWith('/uploads/') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif')) {
      return '📷 Photo';
    }

    return trimmed;
  }

  static String? _extractProductTitle(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        final t = decoded['title']?.toString() ?? decoded['name']?.toString();
        if (t != null && t.trim().isNotEmpty) return t.trim();
      }
    } catch (_) {}

    final match = RegExp(r'''['"](?:title|name)['"]\s*:\s*['"]([^'"]+)['"]''').firstMatch(raw);
    if (match != null && match.group(1) != null) {
      return match.group(1)!.trim();
    }
    return null;
  }

  static String? _extractOrderRef(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        final displayId = decoded['displayId']?.toString();
        if (displayId != null && displayId.isNotEmpty) {
          return displayId.startsWith('#') ? displayId : '#$displayId';
        }
        final orderId = decoded['id']?.toString();
        if (orderId != null && orderId.isNotEmpty) {
          final shortId = orderId.length >= 8 ? orderId.substring(0, 8) : orderId;
          return '#$shortId';
        }
      }
    } catch (_) {}

    final match = RegExp(r'''['"](?:displayId|id)['"]\s*:\s*['"]([^'"]+)['"]''').firstMatch(raw);
    if (match != null && match.group(1) != null) {
      final id = match.group(1)!.trim();
      final shortId = id.length > 8 ? id.substring(0, 8) : id;
      return '#$shortId';
    }
    return null;
  }

  static String formatTime(DateTime? value) {
    if (value == null) return '';
    final now = DateTime.now();
    final local = value.toLocal();
    final diff = now.difference(local);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }

    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(local.year, local.month, local.day);

    if (messageDay == today) {
      final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
      final minute = local.minute.toString().padLeft(2, '0');
      return '$hour:$minute ${local.hour >= 12 ? 'PM' : 'AM'}';
    } else if (messageDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${local.month}/${local.day}/${local.year}';
    }
  }

  Conversation copyWith({
    String? id,
    String? participantId,
    String? name,
    String? role,
    String? message,
    String? time,
    DateTime? updatedAt,
    int? unreadCount,
    bool? isOnline,
    String? avatarUrl,
  }) {
    return Conversation(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      name: name ?? this.name,
      role: role ?? this.role,
      message: message ?? this.message,
      time: time ?? this.time,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final String messageType;
  final String status;
  final DateTime? createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.messageType,
    this.status = 'sent',
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'].toString(),
      senderId: json['senderId']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      messageType: json['messageType']?.toString() ?? 'text',
      status: json['status']?.toString() ?? 'sent',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? content,
    String? messageType,
    String? status,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
