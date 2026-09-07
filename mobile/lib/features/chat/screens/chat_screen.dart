import 'package:flutter/material.dart';
import 'package:mobile/features/chat/models/conversation_model.dart';
import 'package:mobile/features/chat/services/chat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String participantName;
  final String? participantAvatarUrl;
  final bool isOnline;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
    this.participantAvatarUrl,
    required this.isOnline,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final ScrollController _messagesScrollController = ScrollController();

  String? _currentUserId;
  io.Socket? _socket;
  List<ChatMessage> _messages = [];

  bool _isLoadingInitial = true;
  bool _isLoadingOlder = false;
  bool _hasMore = true;
  bool _isSending = false;
  bool _hasText = false;
  bool _showNewMessagePill = false;
  int _unseenNewMessages = 0;

  @override
  void initState() {
    super.initState();

    _messageController.addListener(_onTextChanged);
    _messagesScrollController.addListener(_onScroll);

    _messageFocusNode.addListener(() {
      if (_messageFocusNode.hasFocus) {
        // Auto scroll to bottom when keyboard opens
        Future.delayed(const Duration(milliseconds: 150), () {
          _scrollToBottom(animate: true);
        });
      }
    });

    _loadInitialData();
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _onScroll() {
    if (!_messagesScrollController.hasClients) return;

    final offset = _messagesScrollController.offset;
    final max = _messagesScrollController.position.maxScrollExtent;

    // Check if user has scrolled back near the bottom
    if ((max - offset) <= 80 && _showNewMessagePill) {
      setState(() {
        _showNewMessagePill = false;
        _unseenNewMessages = 0;
      });
    }

    // Trigger load older messages when user scrolls near the top
    if (offset <= 40 && !_isLoadingOlder && _hasMore && _messages.isNotEmpty) {
      _loadOlderMessages();
    }
  }

  bool _isNearBottom([double threshold = 120]) {
    if (!_messagesScrollController.hasClients) return true;
    final max = _messagesScrollController.position.maxScrollExtent;
    final current = _messagesScrollController.offset;
    return (max - current) <= threshold;
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingInitial = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('userId');

      final data = await _chatService.getMessages(widget.conversationId, limit: 30);
      final fetched = data
          .map((item) => ChatMessage.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      final seen = <String>{};
      final deduplicated = fetched.where((m) => seen.add(m.id)).toList();

      if (mounted) {
        setState(() {
          _messages = deduplicated;
          _isLoadingInitial = false;
          _hasMore = fetched.length >= 30;
        });

        _scrollToBottom(animate: false);

        if (_messages.isNotEmpty) {
          final latest = _messages.last;
          if (latest.senderId != _currentUserId) {
            await _chatService.markAsRead(widget.conversationId, latest.id);
          }
        }
      }

      await _connectRealtime();
    } catch (error) {
      debugPrint('Error loading messages: $error');
      if (mounted) {
        setState(() => _isLoadingInitial = false);
      }
    }
  }

  Future<void> _loadOlderMessages() async {
    if (_isLoadingOlder || !_hasMore || _messages.isEmpty) return;

    final oldestReal = _messages.firstWhere(
      (m) => !m.id.startsWith('temp_'),
      orElse: () => _messages.first,
    );

    setState(() => _isLoadingOlder = true);

    try {
      final oldMaxExtent = _messagesScrollController.position.maxScrollExtent;
      final oldOffset = _messagesScrollController.offset;

      final data = await _chatService.getMessages(
        widget.conversationId,
        limit: 30,
        before: oldestReal.id,
      );

      final olderFetched = data
          .map((item) => ChatMessage.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      if (olderFetched.isEmpty || olderFetched.length < 30) {
        _hasMore = false;
      }

      if (olderFetched.isNotEmpty && mounted) {
        final currentIds = _messages.map((m) => m.id).toSet();
        final newOlder = olderFetched.where((m) => !currentIds.contains(m.id)).toList();

        setState(() {
          _messages = [...newOlder, ..._messages];
          _isLoadingOlder = false;
        });

        // Maintain previous scroll position seamlessly
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_messagesScrollController.hasClients) {
            final newMaxExtent = _messagesScrollController.position.maxScrollExtent;
            final delta = newMaxExtent - oldMaxExtent;
            _messagesScrollController.jumpTo(oldOffset + delta);
          }
        });
      } else if (mounted) {
        setState(() => _isLoadingOlder = false);
      }
    } catch (e) {
      debugPrint('Error loading older messages: $e');
      if (mounted) setState(() => _isLoadingOlder = false);
    }
  }

  Future<void> _connectRealtime() async {
    try {
      _socket = await _chatService.connectToConversation(
        widget.conversationId,
        (data) {
          final message = ChatMessage.fromJson(data);
          if (!mounted) return;

          final isFromMe = message.senderId == _currentUserId;
          final wasNearBottom = _isNearBottom();

          setState(() {
            // 1. If message already exists by ID, do not duplicate
            if (_messages.any((item) => item.id == message.id)) {
              return;
            }

            // 2. Reconcile temporary optimistic messages from current user
            final tempIndex = _messages.indexWhere(
              (item) =>
                  item.id.startsWith('temp_') &&
                  (item.senderId == message.senderId || item.senderId == _currentUserId) &&
                  item.content == message.content,
            );

            if (tempIndex != -1) {
              _messages[tempIndex] = message;
            } else {
              _messages.add(message);
            }

            // 3. Deduplicate
            final seen = <String>{};
            _messages = _messages.where((item) => seen.add(item.id)).toList();

            // 4. Handle scroll position or "New message" indicator
            if (isFromMe || wasNearBottom) {
              _showNewMessagePill = false;
              _unseenNewMessages = 0;
            } else {
              // User is reading older messages: show badge without shifting scroll
              _showNewMessagePill = true;
              _unseenNewMessages += 1;
            }
          });

          if (isFromMe || wasNearBottom) {
            _scrollToBottom();
            if (!isFromMe) {
              _chatService.markAsRead(widget.conversationId, message.id);
            }
          }
        },
      );
    } catch (error) {
      debugPrint('Realtime chat unavailable: $error');
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    _isSending = true;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempMsg = ChatMessage(
      id: tempId,
      senderId: _currentUserId ?? '',
      content: content,
      messageType: 'text',
      status: 'sending',
      createdAt: DateTime.now(),
    );

    // 1. Clear input & reset button state immediately
    _messageController.clear();
    setState(() {
      _hasText = false;
      _messages.add(tempMsg);
      _showNewMessagePill = false;
      _unseenNewMessages = 0;
    });

    // 2. Automatically scroll to the newest message
    _scrollToBottom();

    try {
      final response = await _chatService.sendMessage(widget.conversationId, content);
      final realMsg = ChatMessage.fromJson(Map<String, dynamic>.from(response as Map));

      if (!mounted) return;
      setState(() {
        final existingRealIndex = _messages.indexWhere((m) => m.id == realMsg.id);
        final tempIndex = _messages.indexWhere((m) => m.id == tempId);

        if (existingRealIndex != -1) {
          // Socket already arrived and added realMsg
          if (tempIndex != -1) {
            _messages.removeAt(tempIndex);
          }
        } else if (tempIndex != -1) {
          // Replace optimistic message with sent message
          _messages[tempIndex] = realMsg.copyWith(status: 'sent');
        } else {
          _messages.add(realMsg.copyWith(status: 'sent'));
        }

        final seen = <String>{};
        _messages = _messages.where((item) => seen.add(item.id)).toList();
      });

      _scrollToBottom();
    } catch (error) {
      if (mounted) {
        setState(() {
          _messages.removeWhere((m) => m.id == tempId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to send message: $error'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      _isSending = false;
    }
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_messagesScrollController.hasClients) return;

      final maxExtent = _messagesScrollController.position.maxScrollExtent;
      if (animate) {
        _messagesScrollController.animateTo(
          maxExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      } else {
        _messagesScrollController.jumpTo(maxExtent);
      }
    });
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _messageFocusNode.dispose();
    _messagesScrollController.removeListener(_onScroll);
    _messagesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Messages List & Floating Indicators
            Expanded(
              child: Stack(
                children: [
                  _buildMessagesBody(),

                  // "↓ New message" Floating Pill
                  if (_showNewMessagePill)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _buildNewMessagePill(),
                      ),
                    ),
                ],
              ),
            ),

            // Fixed Bottom Message Input Bar
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1D2939)),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              _buildParticipantAvatar(),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: widget.isOnline ? const Color(0xFF12B76A) : const Color(0xFF98A2B3),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.participantName,
                  style: const TextStyle(
                    color: Color(0xFF1D2939),
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  widget.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: widget.isOnline ? const Color(0xFF0C6B2D) : const Color(0xFF667085),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.phone_outlined, color: Color(0xFF344054), size: 21),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Voice call feature coming soon')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF344054), size: 21),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildParticipantAvatar({double radius = 18}) {
    final avatarUrl = widget.participantAvatarUrl;
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFE8EFE6),
        child: Text(
          widget.participantName.isNotEmpty ? widget.participantName[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Color(0xFF0C6B2D),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }

    if (avatarUrl.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFF2F4F7),
        backgroundImage: NetworkImage(avatarUrl),
        onBackgroundImageError: (_, _) {},
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFF2F4F7),
      backgroundImage: AssetImage(avatarUrl),
    );
  }

  Widget _buildMessagesBody() {
    if (_isLoadingInitial) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Color(0xFF0C6B2D),
        ),
      );
    }

    if (_messages.isEmpty) {
      return _buildEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _messagesScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Loading Older Messages Indicator
                if (_isLoadingOlder)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF0C6B2D),
                        ),
                      ),
                    ),
                  ),

                // Render Messages in Chronological Order (Oldest at top, Newest at bottom)
                ..._buildMessageListWithDateChips(),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildMessageListWithDateChips() {
    final widgets = <Widget>[];

    for (int i = 0; i < _messages.length; i++) {
      final msg = _messages[i];
      final isMe = msg.senderId == _currentUserId;

      // Check if we should insert a date header chip
      final showDateHeader = i == 0 ||
          _isDifferentDay(_messages[i - 1].createdAt, msg.createdAt);

      if (showDateHeader && msg.createdAt != null) {
        widgets.add(_buildDateChip(msg.createdAt!));
      }

      // Render Product Message or Normal Chat Bubble
      if (msg.messageType == 'product') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: ProductMessageCard(
                imageUrl:
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvkvNcrsOhsZCTUZOu-w7gOezd1Sk2eHM-dYSO6niL28zY5SLuzl0xAU1f&s=10',
                title: 'Fresh Farm Produce',
                price: '\$4.50',
                unit: '/kg',
                description: msg.content,
                qty: 'Available for order',
                time: _formatMessageTime(msg.createdAt),
              ),
            ),
          ),
        );
      } else {
        widgets.add(
          _MessageBubble(
            isMe: isMe,
            message: msg.content,
            time: _formatMessageTime(msg.createdAt),
            status: msg.status,
            avatarUrl: widget.participantAvatarUrl,
            participantName: widget.participantName,
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildDateChip(DateTime date) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4.5),
        decoration: BoxDecoration(
          color: const Color(0xFFE9ECEF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _formatDateHeader(date),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475467),
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: Color(0xFFE8EFE6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xFF0C6B2D),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Start a conversation',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2939),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Reach out to ${widget.participantName} about farm produce, negotiated prices, or delivery schedules.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF667085),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildPromptChip('👋 Hi! Are fresh vegetables available?'),
                _buildPromptChip('📦 What is the minimum delivery order?'),
                _buildPromptChip('🏷️ Can you share your wholesale price?'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChip(String prompt) {
    return ActionChip(
      label: Text(
        prompt,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF0C6B2D),
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: const Color(0xFFF2F7F0),
      side: const BorderSide(color: Color(0xFFD3E4CD)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: () {
        _messageController.text = prompt;
        _messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: _messageController.text.length),
        );
        _messageFocusNode.requestFocus();
      },
    );
  }

  Widget _buildNewMessagePill() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _showNewMessagePill = false;
            _unseenNewMessages = 0;
          });
          _scrollToBottom(animate: true);
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
          decoration: BoxDecoration(
            color: const Color(0xFF0C6B2D),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0C6B2D).withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_downward_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                _unseenNewMessages > 1
                    ? '$_unseenNewMessages new messages'
                    : '↓ New message',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEAECF0), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment / Plus Action Button
          Container(
            margin: const EdgeInsets.only(bottom: 2),
            decoration: const BoxDecoration(
              color: Color(0xFFE8EFE6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add_rounded, color: Color(0xFF0C6B2D), size: 22),
              onPressed: () {
                _showAttachmentOptions();
              },
              splashRadius: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            ),
          ),
          const SizedBox(width: 8),

          // Expanding Multiline Input Field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE4E7EC)),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                minLines: 1,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  fontSize: 14.5,
                  color: Color(0xFF1D2939),
                  height: 1.35,
                ),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: Color(0xFF98A2B3),
                    fontSize: 14,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9.5,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Dynamic Active / Inactive Send Button
          Container(
            margin: const EdgeInsets.only(bottom: 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: _hasText && !_isSending
                    ? const Color(0xFF0C6B2D)
                    : const Color(0xFFEAECF0),
                shape: BoxShape.circle,
                boxShadow: _hasText && !_isSending
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0C6B2D).withValues(alpha: 0.28),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: IconButton(
                icon: _isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: _hasText ? Colors.white : const Color(0xFF98A2B3),
                        size: 18,
                      ),
                onPressed: _hasText && !_isSending ? _sendMessage : null,
                splashRadius: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Share Attachment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2939),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAttachOption(
                      icon: Icons.image_rounded,
                      label: 'Photo',
                      color: const Color(0xFF0C6B2D),
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Photo sharing coming soon')),
                        );
                      },
                    ),
                    _buildAttachOption(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Product',
                      color: const Color(0xFF1570EF),
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Product catalog link coming soon')),
                        );
                      },
                    ),
                    _buildAttachOption(
                      icon: Icons.receipt_long_rounded,
                      label: 'Order Quote',
                      color: const Color(0xFFF79009),
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Order quote coming soon')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF344054),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Clean Message Bubble Component
class _MessageBubble extends StatelessWidget {
  final bool isMe;
  final String message;
  final String time;
  final String status;
  final String? avatarUrl;
  final String participantName;

  const _MessageBubble({
    required this.isMe,
    required this.message,
    required this.time,
    required this.status,
    required this.avatarUrl,
    required this.participantName,
  });

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF0C6B2D);
    const incomingBg = Color(0xFFF2F4F7);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Left Avatar for Other User
          if (!isMe) ...[
            _buildSmallAvatar(),
            const SizedBox(width: 8),
          ],

          // Bubble Container
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.76,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9.5),
              decoration: BoxDecoration(
                color: isMe ? brandGreen : incomingBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Message Text
                  Text(
                    message,
                    style: TextStyle(
                      color: isMe ? Colors.white : const Color(0xFF1D2939),
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Timestamp & Status Indicators
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe
                              ? Colors.white.withValues(alpha: 0.72)
                              : const Color(0xFF667085),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        _buildStatusIcon(status),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallAvatar() {
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return CircleAvatar(
        radius: 13,
        backgroundColor: const Color(0xFFE8EFE6),
        child: Text(
          participantName.isNotEmpty ? participantName[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Color(0xFF0C6B2D),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (avatarUrl!.startsWith('http')) {
      return CircleAvatar(
        radius: 13,
        backgroundColor: const Color(0xFFE4E7EC),
        backgroundImage: NetworkImage(avatarUrl!),
        onBackgroundImageError: (_, _) {},
      );
    }

    return CircleAvatar(
      radius: 13,
      backgroundColor: const Color(0xFFE4E7EC),
      backgroundImage: AssetImage(avatarUrl!),
    );
  }

  Widget _buildStatusIcon(String status) {
    if (status == 'sending') {
      return const Icon(
        Icons.access_time_rounded,
        size: 11,
        color: Colors.white70,
      );
    } else if (status == 'read') {
      return const Icon(
        Icons.done_all_rounded,
        size: 13,
        color: Color(0xFF86EFAC),
      );
    } else {
      // Sent status
      return const Icon(
        Icons.check_rounded,
        size: 12,
        color: Colors.white70,
      );
    }
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
    return Container(
      width: MediaQuery.of(context).size.width * 0.78,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              imageUrl,
              height: 125,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, error, stackTrace) => Container(
                height: 125,
                color: const Color(0xFFE8EFE6),
                child: const Icon(Icons.agriculture_rounded, size: 36, color: Color(0xFF0C6B2D)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: Color(0xFF1D2939),
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
                              fontSize: 14.5,
                              color: Color(0xFF0C6B2D),
                            ),
                          ),
                          TextSpan(
                            text: unit,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF667085),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475467),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        qty,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF344054),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C6B2D),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Add to Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
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
    );
  }
}

// Helpers for Date & Time Formatting
String _formatDateHeader(DateTime date) {
  final local = date.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final messageDay = DateTime(local.year, local.month, local.day);
  final difference = today.difference(messageDay).inDays;

  if (difference == 0) {
    return 'Today';
  } else if (difference == 1) {
    return 'Yesterday';
  } else {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final month = months[local.month - 1];
    if (local.year == now.year) {
      return '$month ${local.day}';
    }
    return '$month ${local.day}, ${local.year}';
  }
}

String _formatMessageTime(DateTime? value) {
  if (value == null) return '';
  final local = value.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${local.hour >= 12 ? 'PM' : 'AM'}';
}

bool _isDifferentDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return true;
  final localA = a.toLocal();
  final localB = b.toLocal();
  return localA.year != localB.year ||
      localA.month != localB.month ||
      localA.day != localB.day;
}
