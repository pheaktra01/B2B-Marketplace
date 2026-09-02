import 'package:flutter/material.dart';
import 'package:mobile/features/chat/screens/chat_screen.dart';
// Import your ChatScreen file here:
// import 'path/to/chat_screen.dart';

class ConversationCard extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final String avatarUrl;
  final int unreadCount;
  final bool isOnline;
  final VoidCallback? onTap; // Optional callback if you want custom tap handling

  const ConversationCard({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    required this.avatarUrl,
    required this.unreadCount,
    required this.isOnline,
    this.onTap,
  });

  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color onlineDotGreen = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    final bool hasUnread = unreadCount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // --- ADDED MATERIAL & INKWELL FOR TAP & RIPPLE EFFECT ---
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ??
              () {
                // Navigate to ChatScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatScreen(), // Replace with your ChatScreen widget
                  ),
                );
              },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: avatarUrl.startsWith('http')
                          ? NetworkImage(avatarUrl)
                          : AssetImage(avatarUrl) as ImageProvider,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isOnline
                              ? onlineDotGreen
                              : Colors.grey.shade400,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 12,
                              color: hasUnread ? primaryGreen : Colors.grey,
                              fontWeight: hasUnread
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          if (hasUnread)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}