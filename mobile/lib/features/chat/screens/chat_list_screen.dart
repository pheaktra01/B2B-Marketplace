import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/core/routing/route_args.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/chat/models/conversation_model.dart';
import 'package:mobile/features/chat/widgets/conversation_card.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
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
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentUserId;
  String _searchQuery = '';
  io.Socket? _socket;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color pageBg = Color(0xFFF5F5E9);

  // ============================================================
  // CONVERSATIONS & SOCKET
  // ============================================================

  @override
  void initState() {
    super.initState();
    _initUserAndLoad();
    _connectRealtime();
  }

  Future<void> _initUserAndLoad() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('userId');
    } catch (_) {}
    await _loadConversations();
  }

  Future<void> _connectRealtime() async {
    try {
      _socket = await _chatService.connectToConversationList(
        onConversationUpdated: _handleRealtimeUpdate,
        onUserStatusChanged: (userId, isOnline) {
          if (!mounted) return;
          setState(() {
            _conversations = _conversations.map((c) {
              if (c.participantId == userId) {
                return c.copyWith(isOnline: isOnline);
              }
              return c;
            }).toList();
          });
        },
      );
    } catch (error) {
      debugPrint('Realtime conversation list unavailable: $error');
    }
  }

  void _handleRealtimeUpdate(Map<String, dynamic>? data) {
    if (!mounted) return;

    if (data == null) {
      _loadConversations(silent: true);
      return;
    }

    try {
      final conversationId = data['conversationId']?.toString() ??
          data['conversation']?['id']?.toString() ??
          data['id']?.toString();

      if (conversationId == null || conversationId.isEmpty) {
        _loadConversations(silent: true);
        return;
      }

      // Check if payload has message info
      Map<String, dynamic>? msgData;
      if (data['lastMessage'] is Map) {
        msgData = Map<String, dynamic>.from(data['lastMessage'] as Map);
      } else if (data['content'] != null || data['messageType'] != null) {
        msgData = data;
      }

      final index = _conversations.indexWhere((c) => c.id == conversationId);

      if (index != -1) {
        final current = _conversations[index];
        String preview = current.message;
        DateTime? newTime = current.updatedAt;
        int unread = current.unreadCount;

        if (msgData != null) {
          final msgType = msgData['messageType']?.toString() ?? 'text';
          if (msgType == 'image') {
            preview = '📷 Photo';
          } else {
            preview = msgData['content']?.toString() ?? preview;
          }

          final createdAtStr = msgData['createdAt']?.toString();
          if (createdAtStr != null) {
            newTime = DateTime.tryParse(createdAtStr) ?? DateTime.now();
          } else {
            newTime = DateTime.now();
          }

          final senderId = msgData['senderId']?.toString();
          if (senderId != null && senderId != _currentUserId) {
            unread = current.unreadCount + 1;
          }
        }

        final updated = current.copyWith(
          message: preview,
          time: Conversation.formatTime(newTime),
          updatedAt: newTime,
          unreadCount: unread,
        );

        setState(() {
          _conversations.removeAt(index);
          _conversations.insert(0, updated);
        });
      }

      // Fetch server state silently in background to keep data pristine
      _loadConversations(silent: true);
    } catch (e) {
      debugPrint('Error handling realtime update: $e');
      _loadConversations(silent: true);
    }
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }

  Future<void> _loadConversations({bool silent = false}) async {
    if (!silent && _conversations.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final items = await _chatService.getConversations();
      final loaded = items
          .map(
            (item) =>
                Conversation.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();

      if (mounted) {
        setState(() {
          _conversations = loaded;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      debugPrint('Failed to load conversations: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_conversations.isEmpty) {
            _errorMessage = e.toString();
          }
        });
      }
    }
  }

  bool _matchesCategory(Conversation item) {
    if (_selectedCategoryIndex == 0) return true;
    final role = item.role.toLowerCase();
    if (_selectedCategoryIndex == 1) {
      return role.contains('restaurant') || role.contains('buyer');
    }
    if (_selectedCategoryIndex == 2) {
      return role.contains('driver') || role.contains('delivery');
    }
    if (_selectedCategoryIndex == 3) {
      return role.contains('admin') || role.contains('support');
    }
    return true;
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

    final filteredConversations = _conversations.where((item) {
      if (!_matchesCategory(item)) return false;
      if (_searchQuery.isEmpty) return true;
      return item.name.toLowerCase().contains(_searchQuery) ||
          item.message.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: pageBg,

      // ========================================================
      appBar: FarmerAppBar(
        isRestaurant: widget.isRestaurant,
      ),

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
            child: Builder(
              builder: (context) {
                if (_isLoading && _conversations.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryGreen),
                  );
                }

                if (_errorMessage != null && _conversations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Unable to load conversations'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _loadConversations(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (filteredConversations.isEmpty) {
                  return RefreshIndicator(
                    color: primaryGreen,
                    onRefresh: () => _loadConversations(silent: true),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No conversations found'
                                    : 'No conversations yet',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: primaryGreen,
                  onRefresh: () => _loadConversations(silent: true),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    itemCount: filteredConversations.length,
                    itemBuilder: (context, index) {
                      final item = filteredConversations[index];
                      return ConversationCard(
                        conversationId: item.id,
                        name: item.name,
                        message: item.message,
                        time: item.time,
                        avatarUrl: item.avatarUrl,
                        unreadCount: item.unreadCount,
                        isOnline: item.isOnline,
                        onTap: () async {
                          await context.push(
                            AppRoutes.chatConversation,
                            extra: ChatConversationArgs(
                              conversationId: item.id,
                              participantName: item.name,
                              participantAvatarUrl: item.avatarUrl,
                              isOnline: item.isOnline,
                            ),
                          );
                          if (mounted) {
                            _loadConversations(silent: true);
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

