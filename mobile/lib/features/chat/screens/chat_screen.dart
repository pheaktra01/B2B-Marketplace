import 'package:flutter/material.dart';
import 'package:mobile/features/chat/models/conversation_model.dart';
import 'package:mobile/features/chat/services/chat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LegacyStaticChatScreen extends StatelessWidget {
  const LegacyStaticChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/profile.png'),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Green Valley Organics',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Online',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Date Chip
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Incoming Message 1
                const ChatBubble(
                  isMe: false,
                  message:
                      'Good morning! We just finished our morning harvest. Today\'s heirloom tomatoes look fantastic — deep color and rich flavor.',
                  time: '08:42 AM',
                ),

                // Outgoing Message 1
                const ChatBubble(
                  isMe: true,
                  message:
                      'That sounds great. I\'m looking for about 20kg for this weekend\'s menu. Do you have enough for that?',
                  time: '08:45 AM',
                ),

                // Incoming Message 2
                const ChatBubble(
                  isMe: false,
                  message:
                      'Definitely. I\'ve put together a package for you. Here are the details:',
                  time:
                      '', // No timestamp on text part since product card follows
                ),

                // Product Card Attachment
                const ProductMessageCard(
                  imageUrl:
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvkvNcrsOhsZCTUZOu-w7gOezd1Sk2eHM-dYSO6niL28zY5SLuzl0xAU1f&s=10',
                  title: 'Heirloom Tomatoes (Mixed)',
                  price: '\$4.50',
                  unit: '/kg',
                  description:
                      'Farm-fresh, harvested this morning at peak ripeness.',
                  qty: 'Quantity: 20 kg',
                  time: '08:48 AM',
                ),

                // Outgoing Message 2
                const ChatBubble(
                  isMe: true,
                  message:
                      'Done! Added to my cart. Can we schedule delivery for 10:00 AM tomorrow?',
                  time: '08:50 AM',
                ),
              ],
            ),
          ),

          // Bottom Input Bar
          const ChatInputBar(),
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String participantName;
  final bool isOnline;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
    required this.isOnline,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  late Future<List<ChatMessage>> _messagesFuture;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _messagesFuture = _loadMessages();
  }

  Future<List<ChatMessage>> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('userId');
    final data = await _chatService.getMessages(widget.conversationId);
    final messages = data
        .map(
          (item) =>
              ChatMessage.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();

    if (messages.isNotEmpty && mounted) {
      final latest = messages.last;
      if (latest.senderId != _currentUserId) {
        await _chatService.markAsRead(widget.conversationId, latest.id);
      }
    }
    return messages;
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    try {
      await _chatService.sendMessage(widget.conversationId, content);
      if (mounted) setState(() => _messagesFuture = _loadMessages());
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to send message: $error')),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/profile.png'),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.participantName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: widget.isOnline
                        ? const Color(0xFF2E7D32)
                        : Colors.black45,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<ChatMessage>>(
              future: _messagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Unable to load messages: ${snapshot.error}'),
                  );
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Center(child: Text('Start the conversation'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ChatBubble(
                      isMe: message.senderId == _currentUserId,
                      message: message.content,
                      time: _formatMessageTime(message.createdAt),
                    );
                  },
                );
              },
            ),
          ),
          ChatInputBar(controller: _messageController, onSend: _sendMessage),
        ],
      ),
    );
  }
}

String _formatMessageTime(DateTime? value) {
  if (value == null) return '';
  final local = value.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${local.hour >= 12 ? 'PM' : 'AM'}';
}

// Custom Chat Bubble
class ChatBubble extends StatelessWidget {
  final bool isMe;
  final String message;
  final String time;

  const ChatBubble({
    super.key,
    required this.isMe,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    const greenColor = Color(0xFF0C6B2D);
    const greyColor = Color(0xFFF2F4F7);

    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4, bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          decoration: BoxDecoration(
            color: isMe ? greenColor : greyColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
          ),
          child: Text(
            message,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 14.5,
              height: 1.35,
            ),
          ),
        ),
        if (time.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              top: 2,
              bottom: 8,
              left: 4,
              right: 4,
            ),
            child: Text(
              time,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ),
      ],
    );
  }
}

// Product Attachment Card Component
class ProductMessageCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String unit;
  final String description;
  final String qty;
  final String time;

  const ProductMessageCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.unit,
    required this.description,
    required this.qty,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4, bottom: 4),
          width: MediaQuery.of(context).size.width * 0.82,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: price,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF0C6B2D),
                                ),
                              ),
                              TextSpan(
                                text: unit,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Description
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.black,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Quantity Badge & Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFEFEF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            qty,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0C6B2D),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Add to Order',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
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
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 8, left: 4),
          child: Text(
            time,
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ),
      ],
    );
  }
}

// Bottom Input Bar Component
class ChatInputBar extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onSend;

  const ChatInputBar({super.key, this.controller, this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            // Plus Action Button
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE8EFE6),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Color(0xFF0C6B2D)),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
            // Text Input Field
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend?.call(),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: const TextStyle(
                    color: Colors.black38,
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFF0C6B2D)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send Button
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0C6B2D),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
