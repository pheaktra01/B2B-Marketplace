import 'package:flutter/material.dart';

import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/chat/models/conversation_model.dart';
import 'package:mobile/features/chat/widgets/conversation_card.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
import 'package:mobile/features/farmer/widgets/farmer_bottom_nav_bar.dart';
import 'package:mobile/features/restaurant/widgets/restaurant_bottom_nav_bar.dart';
import 'package:mobile/features/chat/services/chat_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatListScreen extends StatefulWidget {
  final bool isRestaurant;

  const ChatListScreen({super.key, this.isRestaurant = false});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // ============================================================
  // STATE
  // ============================================================

  int _selectedCategoryIndex = 0;
  final ChatService _chatService = ChatService();
  late Future<List<Conversation>> _conversationsFuture;
  String _searchQuery = '';
  io.Socket? _socket;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color pageBg = Color(0xFFF5F5E9);

  // ============================================================
  // CONVERSATIONS
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _connectRealtime();
  }

  Future<void> _connectRealtime() async {
    try {
      _socket = await _chatService.connectToConversationList(() {
        if (mounted) {
          setState(_loadConversations);
        }
      });
    } catch (error) {
      debugPrint('Realtime conversation list unavailable: $error');
    }
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }

  void _loadConversations() {
    _conversationsFuture = _chatService.getConversations().then(
      (items) => items
          .map(
            (item) =>
                Conversation.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Localized categories
    final categories = [
      l10n.allMessages,
      l10n.restaurants,
      l10n.deliveries,
      l10n.support,
    ];

    return Scaffold(
      backgroundColor: pageBg,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: const FarmerAppBar(),

      // ========================================================
      // BODY
      // ========================================================
      body: Column(
        children: [
          const SizedBox(height: 12),

          // ======================================================
          // SEARCH BAR
          // ======================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (value) => setState(() {
                _searchQuery = value.trim().toLowerCase();
              }),
              decoration: InputDecoration(
                hintText: l10n.searchConversations,

                hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),

                prefixIcon: const Icon(Icons.search, color: Colors.grey),

                filled: true,

                fillColor: Colors.white,

                contentPadding: const EdgeInsets.symmetric(vertical: 0),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryGreen),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ======================================================
          // CATEGORY FILTERS
          // ======================================================
          SizedBox(
            height: 36,

            child: ListView.builder(
              scrollDirection: Axis.horizontal,

              padding: const EdgeInsets.symmetric(horizontal: 16),

              itemCount: categories.length,

              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },

                  child: Container(
                    margin: const EdgeInsets.only(right: 8),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      color: isSelected ? primaryGreen : Colors.white,

                      borderRadius: BorderRadius.circular(20),

                      border: Border.all(
                        color: isSelected ? primaryGreen : Colors.grey.shade300,
                      ),
                    ),

                    child: Text(
                      categories[index],

                      style: TextStyle(
                        color: isSelected ? Colors.white : primaryGreen,

                        fontSize: 13,

                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ======================================================
          // CONVERSATION LIST
          // ======================================================
          Expanded(
            child: FutureBuilder<List<Conversation>>(
              future: _conversationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Unable to load conversations'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(_loadConversations),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final conversations = (snapshot.data ?? []).where((item) {
                  if (_searchQuery.isEmpty) return true;
                  return item.name.toLowerCase().contains(_searchQuery) ||
                      item.message.toLowerCase().contains(_searchQuery);
                }).toList();

                if (conversations.isEmpty) {
                  return const Center(child: Text('No conversations yet'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final item = conversations[index];
                    return ConversationCard(
                      conversationId: item.id,
                      name: item.name,
                      message: item.message,
                      time: item.time,
                      avatarUrl: item.avatarUrl,
                      unreadCount: item.unreadCount,
                      isOnline: item.isOnline,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================
      bottomNavigationBar: widget.isRestaurant
          ? const RestaurantBottomNavBar(currentIndex: 3)
          : const FarmerBottomNavBar(currentIndex: 3),
    );
  }
}
