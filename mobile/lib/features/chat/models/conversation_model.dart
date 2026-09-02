class Conversation {
  final String name;
  final String message;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final String avatarUrl;

  const Conversation({
    required this.name,
    required this.message,
    required this.time,
    required this.unreadCount,
    required this.isOnline,
    required this.avatarUrl,
  });
}