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
    final updatedAt = DateTime.tryParse(json['updatedAt']?.toString() ?? '');

    return Conversation(
      id: json['id'].toString(),
      participantId: participant['id']?.toString() ?? '',
      name: participant['name']?.toString() ?? 'Unknown user',
      role: participant['role']?.toString() ?? '',
      message: lastMessage?['content']?.toString() ?? 'No messages yet',
      time: _formatTime(updatedAt),
      updatedAt: updatedAt,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isOnline: participant['isOnline'] == true,
      avatarUrl:
          participant['avatarUrl'] == null ||
              participant['avatarUrl'].toString().isEmpty
          ? 'assets/mokoto.jpg'
          : ApiConstants.imageUrl(participant['avatarUrl'].toString()),
    );
  }

  static String _formatTime(DateTime? value) {
    if (value == null) return '';
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${local.hour >= 12 ? 'PM' : 'AM'}';
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final String messageType;
  final DateTime? createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'].toString(),
      senderId: json['senderId'].toString(),
      content: json['content']?.toString() ?? '',
      messageType: json['messageType']?.toString() ?? 'text',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
