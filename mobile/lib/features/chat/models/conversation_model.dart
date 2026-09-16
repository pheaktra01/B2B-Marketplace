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
      final msgType = lastMessage['messageType']?.toString() ?? 'text';
      if (msgType == 'image') {
        previewMessage = '📷 Photo';
      } else {
        previewMessage = lastMessage['content']?.toString() ?? '';
      }
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
