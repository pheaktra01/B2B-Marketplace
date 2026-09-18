import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/features/chat/models/conversation_model.dart';
import 'package:mobile/features/chat/services/chat_service.dart';
import 'package:mobile/features/order/models/order_model.dart';
import 'package:mobile/features/order/services/order_service.dart';
import 'package:mobile/features/product/services/product_service.dart';
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

  late String _participantName;
  String? _participantAvatarUrl;
  late bool _isOnline;

  bool _isOtherTyping = false;
  Timer? _typingTimer;
  Timer? _otherTypingDebounceTimer;

  bool _isLoadingInitial = true;
  bool _isLoadingOlder = false;
  bool _hasMore = true;
  bool _isSending = false;
  bool _hasText = false;
  bool _showNewMessagePill = false;
  int _unseenNewMessages = 0;

  static bool _isGenericName(String name) {
    final lower = name.trim().toLowerCase();
    return lower.isEmpty ||
        lower == 'new message' ||
        lower == 'new messages' ||
        lower == 'new photo message' ||
        lower == 'new order chat' ||
        lower == 'chat' ||
        lower == 'notification';
  }

  String _cleanInitialName(String name) {
    var cleaned = name.trim();
    if (cleaned.startsWith('New Messages from ')) {
      cleaned = cleaned.replaceFirst('New Messages from ', '').trim();
    }
    if (_isGenericName(cleaned)) {
      return '';
    }
    return cleaned;
  }

  String get _displayParticipantName {
    if (_participantName.trim().isNotEmpty) {
      return _participantName;
    }
    return 'Chat';
  }

  @override
  void initState() {
    super.initState();

    _participantName = _cleanInitialName(widget.participantName);
    _participantAvatarUrl = widget.participantAvatarUrl;
    _isOnline = widget.isOnline;

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
    final text = _messageController.text;
    final hasText = text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }

    if (hasText) {
      _chatService.emitTyping(_socket, widget.conversationId);
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(milliseconds: 1800), () {
        _chatService.emitStopTyping(_socket, widget.conversationId);
      });
    } else {
      _typingTimer?.cancel();
      _chatService.emitStopTyping(_socket, widget.conversationId);
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

    // Fetch conversation details (real participant name and avatar) asynchronously
    _loadConversationDetails();

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
          String? messageIdToMark;
          for (final m in _messages.reversed) {
            if (m.senderId != _currentUserId && !m.id.startsWith('temp_')) {
              messageIdToMark = m.id;
              break;
            }
          }
          await _chatService.markAsRead(widget.conversationId, messageIdToMark);
        } else {
          await _chatService.markAsRead(widget.conversationId);
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

  Future<void> _loadConversationDetails() async {
    try {
      final data = await _chatService.getConversation(widget.conversationId);
      final participant = data['participant'] as Map<String, dynamic>?;
      if (participant != null && mounted) {
        final name = participant['name']?.toString().trim();
        final avatar = participant['avatarUrl']?.toString().trim();
        final isOnline = participant['isOnline'] == true;

        setState(() {
          if (name != null && name.isNotEmpty && !_isGenericName(name)) {
            _participantName = name;
          }
          if (avatar != null && avatar.isNotEmpty) {
            _participantAvatarUrl = avatar;
          }
          if (isOnline) {
            _isOnline = true;
          }
        });
      }
    } catch (error) {
      debugPrint('Error loading conversation details: $error');
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
        onMessage: (data) {
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
        onMessagesRead: (data) {
          if (!mounted) return;
          final readerId = data['readerId']?.toString();
          if (readerId == _currentUserId) return;
          final lastReadAtStr = data['lastReadAt']?.toString();
          final lastReadAt = DateTime.tryParse(lastReadAtStr ?? '');

          setState(() {
            _messages = _messages.map((m) {
              if (m.senderId == _currentUserId && m.status != 'read') {
                if (lastReadAt == null ||
                    (m.createdAt != null && !m.createdAt!.isAfter(lastReadAt))) {
                  return m.copyWith(status: 'read');
                }
              }
              return m;
            }).toList();
          });
        },
        onTyping: (userId) {
          if (userId == _currentUserId) return;
          if (!mounted) return;
          _otherTypingDebounceTimer?.cancel();
          setState(() => _isOtherTyping = true);
          if (_isNearBottom()) {
            _scrollToBottom();
          }
          _otherTypingDebounceTimer = Timer(const Duration(seconds: 3), () {
            if (mounted && _isOtherTyping) {
              setState(() => _isOtherTyping = false);
            }
          });
        },
        onStopTyping: (userId) {
          if (userId == _currentUserId) return;
          if (!mounted) return;
          _otherTypingDebounceTimer?.cancel();
          setState(() => _isOtherTyping = false);
        },
        onUserStatusChanged: (userId, isOnline) {
          if (userId == _currentUserId) return;
          if (!mounted) return;
          setState(() => _isOnline = isOnline);
        },
      );
    } catch (error) {
      debugPrint('Realtime chat unavailable: $error');
    }
  }

  Future<void> _sendTypedMessage(String content, {String messageType = 'text'}) async {
    if (content.isEmpty || _isSending) return;

    _isSending = true;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempMsg = ChatMessage(
      id: tempId,
      senderId: _currentUserId ?? '',
      content: content,
      messageType: messageType,
      status: 'sending',
      createdAt: DateTime.now(),
    );

    // 1. Clear input & reset button state if it was text
    if (messageType == 'text') {
      _typingTimer?.cancel();
      _chatService.emitStopTyping(_socket, widget.conversationId);
      _messageController.clear();
      setState(() {
        _hasText = false;
      });
    }

    setState(() {
      _messages.add(tempMsg);
      _showNewMessagePill = false;
      _unseenNewMessages = 0;
    });

    // 2. Automatically scroll to the newest message
    _scrollToBottom();

    try {
      final response = await _chatService.sendMessage(
        widget.conversationId,
        content,
        messageType: messageType,
      );
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

  Future<void> _sendMessage() => _sendTypedMessage(_messageController.text.trim());

  Future<void> _pickAndSendImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 80);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 12),
                Text('Uploading photo...'),
              ],
            ),
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      final imageUrl = await _chatService.uploadChatImage(bytes, picked.name);
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        await _sendTypedMessage(imageUrl, messageType: 'image');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send photo: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF0C6B2D)),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndSendImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0C6B2D)),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndSendImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showProductPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return _ProductPickerSheet(
              scrollController: scrollController,
              onSelect: (product) {
                Navigator.pop(ctx);
                final images = product['imageUrls'];
                String firstImg = '';
                if (images is List && images.isNotEmpty) {
                  firstImg = images[0].toString();
                } else if (product['imageUrl'] != null && product['imageUrl'].toString().isNotEmpty) {
                  firstImg = product['imageUrl'].toString();
                }

                final payload = jsonEncode({
                  ...product,
                  'id': product['id']?.toString() ?? '',
                  'name': product['name']?.toString() ?? 'Product',
                  'title': product['name']?.toString() ?? 'Product',
                  'price': product['price']?.toString() ?? '0',
                  'unit': product['unit']?.toString() ?? 'kg',
                  'imageUrl': firstImg,
                  'imageUrls': images is List && images.isNotEmpty
                      ? images
                      : (firstImg.isNotEmpty ? [firstImg] : []),
                  'description': product['description']?.toString() ?? '',
                  'quantity': product['quantity'] ?? 0,
                  'qty': product['quantity'] != null ? '${product['quantity']} available' : 'In stock',
                });
                _sendTypedMessage(payload, messageType: 'product');
              },
            );
          },
        );
      },
    );
  }

  void _showOrderPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.35,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return _OrderPickerSheet(
              scrollController: scrollController,
              onSelect: (order) {
                Navigator.pop(ctx);
                final payload = jsonEncode({
                  'id': order.id,
                  'displayId': order.displayId,
                  'status': order.status,
                  'total': '\$${order.total.toStringAsFixed(2)}',
                  'itemCount': '${order.items.length} items',
                });
                _sendTypedMessage(payload, messageType: 'order');
              },
            );
          },
        );
      },
    );
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
    _typingTimer?.cancel();
    _otherTypingDebounceTimer?.cancel();
    _chatService.emitStopTyping(_socket, widget.conversationId);
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
                    color: _isOtherTyping || _isOnline
                        ? const Color(0xFF12B76A)
                        : const Color(0xFF98A2B3),
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
                  _displayParticipantName,
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
                  _isOtherTyping
                      ? 'typing...'
                      : (_isOnline ? 'Online' : 'Offline'),
                  style: TextStyle(
                    color: _isOtherTyping || _isOnline
                        ? const Color(0xFF0C6B2D)
                        : const Color(0xFF667085),
                    fontSize: 11.5,
                    fontWeight:
                        _isOtherTyping ? FontWeight.w700 : FontWeight.w500,
                    fontStyle:
                        _isOtherTyping ? FontStyle.italic : FontStyle.normal,
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
    final rawAvatarUrl = _participantAvatarUrl;
    if (rawAvatarUrl == null || rawAvatarUrl.isEmpty) {
      final initial = _participantName.trim().isNotEmpty
          ? _participantName.trim()[0].toUpperCase()
          : '';
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFE8EFE6),
        child: initial.isNotEmpty
            ? Text(
                initial,
                style: TextStyle(
                  color: const Color(0xFF0C6B2D),
                  fontWeight: FontWeight.bold,
                  fontSize: radius * 0.78,
                ),
              )
            : Icon(
                Icons.person_rounded,
                color: const Color(0xFF0C6B2D),
                size: radius * 1.1,
              ),
      );
    }

    if (rawAvatarUrl == 'assets/default_avatar.jpg' || rawAvatarUrl.startsWith('assets/')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFF2F4F7),
        backgroundImage: AssetImage(rawAvatarUrl),
      );
    }

    final avatarUrl = ApiConstants.imageUrl(rawAvatarUrl);
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
      backgroundImage: const AssetImage('assets/default_avatar.jpg'),
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

      // Render Product Message, Image Message, Order Message, or Normal Chat Bubble
      if (msg.messageType == 'product') {
        Map<String, dynamic> pData = {};
        try {
          final decoded = jsonDecode(msg.content);
          if (decoded is Map) {
            pData = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}

        final title = pData['title']?.toString() ?? pData['name']?.toString() ?? 'Product';
        final rawPrice = pData['price']?.toString() ?? '';
        final price = rawPrice.isNotEmpty
            ? (rawPrice.startsWith('\$') ? rawPrice : '\$$rawPrice')
            : '\$0.00';
        final rawUnit = pData['unit']?.toString() ?? 'kg';
        final unit = rawUnit.startsWith('/') ? rawUnit : '/$rawUnit';

        String imageUrl = pData['imageUrl']?.toString() ?? '';
        if (imageUrl.isEmpty && pData['imageUrls'] is List && (pData['imageUrls'] as List).isNotEmpty) {
          imageUrl = (pData['imageUrls'] as List).first.toString();
        }

        final description = pData['description']?.toString() ?? '';
        final qty = pData['qty']?.toString() ??
            (pData['quantity'] != null ? '${pData['quantity']} available' : 'Available');
        final productId = pData['id']?.toString() ?? '';

        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: ProductMessageCard(
                imageUrl: imageUrl.isNotEmpty
                    ? ApiConstants.imageUrl(imageUrl)
                    : 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=500',
                title: title,
                price: price,
                unit: unit,
                description: description,
                qty: qty,
                time: _formatMessageTime(msg.createdAt),
                onTap: productId.isNotEmpty
                    ? () {
                        context.push(
                          AppRoutes.productDetail,
                          extra: pData,
                        );
                      }
                    : null,
              ),
            ),
          ),
        );
      } else if (msg.messageType == 'image') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: _ImageMessageBubble(
                isMe: isMe,
                imageUrl: msg.content,
                time: _formatMessageTime(msg.createdAt),
                status: msg.status,
              ),
            ),
          ),
        );
      } else if (msg.messageType == 'order') {
        Map<String, dynamic> oData = {};
        try {
          final decoded = jsonDecode(msg.content);
          if (decoded is Map) {
            oData = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}

        final orderId = oData['id']?.toString() ?? '';
        final displayId = oData['displayId']?.toString() ??
            (orderId.isNotEmpty ? orderId.substring(0, 8) : 'Order');
        final status = oData['status']?.toString() ?? 'Pending';
        final total = oData['total']?.toString() ?? '';
        final itemCount = oData['itemCount']?.toString() ?? '';

        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: _OrderMessageCard(
                isMe: isMe,
                orderId: orderId,
                displayId: displayId,
                status: status,
                total: total,
                itemCount: itemCount,
                time: _formatMessageTime(msg.createdAt),
                onTap: orderId.isNotEmpty
                    ? () {
                        context.push(
                          AppRoutes.restaurantOrderTracking,
                          extra: orderId,
                        );
                      }
                    : null,
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
            avatarUrl: _participantAvatarUrl,
            participantName: _displayParticipantName,
          ),
        );
      }
    }

    if (_isOtherTyping) {
      widgets.add(
        _TypingIndicatorBubble(
          avatarUrl: _participantAvatarUrl,
          participantName: _displayParticipantName,
        ),
      );
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
              'Reach out to $_displayParticipantName about farm produce, negotiated prices, or delivery schedules.',
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
          String? messageIdToMark;
          for (final m in _messages.reversed) {
            if (m.senderId != _currentUserId && !m.id.startsWith('temp_')) {
              messageIdToMark = m.id;
              break;
            }
          }
          _chatService.markAsRead(widget.conversationId, messageIdToMark);
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
                        _showImageSourceDialog();
                      },
                    ),
                    _buildAttachOption(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Product',
                      color: const Color(0xFF1570EF),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showProductPicker();
                      },
                    ),
                    _buildAttachOption(
                      icon: Icons.receipt_long_rounded,
                      label: 'Order Quote',
                      color: const Color(0xFFF79009),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showOrderPicker();
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

    if (avatarUrl == 'assets/default_avatar.jpg' || avatarUrl!.startsWith('assets/')) {
      return CircleAvatar(
        radius: 13,
        backgroundColor: const Color(0xFFE4E7EC),
        backgroundImage: AssetImage(avatarUrl!),
      );
    }

    final fullUrl = ApiConstants.imageUrl(avatarUrl!);
    if (fullUrl.startsWith('http')) {
      return CircleAvatar(
        radius: 13,
        backgroundColor: const Color(0xFFE4E7EC),
        backgroundImage: NetworkImage(fullUrl),
        onBackgroundImageError: (_, _) {},
      );
    }

    return const CircleAvatar(
      radius: 13,
      backgroundColor: Color(0xFFE4E7EC),
      backgroundImage: AssetImage('assets/default_avatar.jpg'),
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

// Realtime Typing Indicator Bubble Component
class _TypingIndicatorBubble extends StatefulWidget {
  final String? avatarUrl;
  final String participantName;

  const _TypingIndicatorBubble({
    required this.avatarUrl,
    required this.participantName,
  });

  @override
  State<_TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<_TypingIndicatorBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildSmallAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF2F4F7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    final progress =
                        ((_animController.value - (index * 0.2)) % 1.0 + 1.0) % 1.0;
                    final bounce =
                        (progress < 0.5 ? progress : (1.0 - progress)) * 2;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      width: 6,
                      height: 6 + (bounce * 4),
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          const Color(0xFF98A2B3),
                          const Color(0xFF0C6B2D),
                          bounce,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallAvatar() {
    final avatar = widget.avatarUrl;
    if (avatar == null || avatar.isEmpty) {
      return CircleAvatar(
        radius: 13,
        backgroundColor: const Color(0xFFE8EFE6),
        child: Text(
          widget.participantName.isNotEmpty
              ? widget.participantName[0].toUpperCase()
              : 'U',
          style: const TextStyle(
            color: Color(0xFF0C6B2D),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (avatar == 'assets/default_avatar.jpg' || avatar.startsWith('assets/')) {
      return CircleAvatar(
        radius: 13,
        backgroundColor: const Color(0xFFE4E7EC),
        backgroundImage: AssetImage(avatar),
      );
    }

    final fullUrl = ApiConstants.imageUrl(avatar);
    if (fullUrl.startsWith('http')) {
      return CircleAvatar(
        radius: 13,
        backgroundColor: const Color(0xFFE4E7EC),
        backgroundImage: NetworkImage(fullUrl),
        onBackgroundImageError: (_, _) {},
      );
    }

    return const CircleAvatar(
      radius: 13,
      backgroundColor: Color(0xFFE4E7EC),
      backgroundImage: AssetImage('assets/default_avatar.jpg'),
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
  final VoidCallback? onTap;

  const ProductMessageCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.unit,
    required this.description,
    required this.qty,
    required this.time,
    this.onTap,
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
                    if (price.isNotEmpty)
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
                if (description.isNotEmpty) ...[
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
                ],
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
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C6B2D),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'View Product',
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

// Image Message Bubble Component
class _ImageMessageBubble extends StatelessWidget {
  final bool isMe;
  final String imageUrl;
  final String time;
  final String status;

  const _ImageMessageBubble({
    required this.isMe,
    required this.imageUrl,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final fullUrl = ApiConstants.imageUrl(imageUrl);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 16),
        ),
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => Dialog(
                backgroundColor: Colors.black87,
                insetPadding: EdgeInsets.zero,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    InteractiveViewer(
                      child: Center(
                        child: Image.network(
                          fullUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Center(
                            child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 20,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Image.network(
                fullUrl,
                width: 240,
                height: 200,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: 240,
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0C6B2D)),
                    ),
                  );
                },
                errorBuilder: (_, _, _) => Container(
                  width: 240,
                  height: 160,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: 36),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        status == 'read'
                            ? Icons.done_all_rounded
                            : Icons.done_rounded,
                        size: 11,
                        color: status == 'read' ? const Color(0xFF52C41A) : Colors.white70,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Order Quote Message Card Component
class _OrderMessageCard extends StatelessWidget {
  final bool isMe;
  final String orderId;
  final String displayId;
  final String status;
  final String total;
  final String itemCount;
  final String time;
  final VoidCallback? onTap;

  const _OrderMessageCard({
    required this.isMe,
    required this.orderId,
    required this.displayId,
    required this.status,
    required this.total,
    required this.itemCount,
    required this.time,
    this.onTap,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.blue.shade700;
      case 'processing':
        return Colors.indigo.shade600;
      case 'shipped':
        return Colors.teal.shade700;
      case 'delivered':
        return const Color(0xFF0C6B2D);
      case 'cancelled':
        return Colors.red.shade700;
      case 'pending':
      default:
        return const Color(0xFFE65100);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Container(
      width: MediaQuery.of(context).size.width * 0.78,
      margin: const EdgeInsets.symmetric(vertical: 4),
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF79009).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Color(0xFFF79009),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Order #$displayId',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1D2939),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (total.isNotEmpty || itemCount.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (itemCount.isNotEmpty)
                    Text(
                      itemCount,
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                    ),
                  if (total.isNotEmpty)
                    Text(
                      total,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0C6B2D),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
                if (onTap != null)
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C6B2D),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'View Order',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Product Selector Bottom Sheet
class _ProductPickerSheet extends StatefulWidget {
  final ScrollController scrollController;
  final ValueChanged<Map<String, dynamic>> onSelect;

  const _ProductPickerSheet({
    required this.scrollController,
    required this.onSelect,
  });

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final items = await ProductService.getAllProducts();
      if (mounted) {
        setState(() {
          _products = items.whereType<Map<String, dynamic>>().toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _products.where((p) {
      if (_search.isEmpty) return true;
      final name = p['name']?.toString().toLowerCase() ?? '';
      return name.contains(_search.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.shopping_bag_outlined, color: Color(0xFF1570EF)),
              SizedBox(width: 8),
              Text(
                'Select Product to Share',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2939),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            onChanged: (val) => setState(() => _search = val.trim()),
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              filled: true,
              fillColor: const Color(0xFFF2F4F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0C6B2D)))
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No products found',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.separated(
                        controller: widget.scrollController,
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final p = filtered[index];
                          final name = p['name']?.toString() ?? 'Product';
                          final price = p['price'] != null ? '\$${p['price']}' : '';
                          final unit = p['unit'] != null ? '/${p['unit']}' : '/kg';
                          final images = p['imageUrls'];
                          final img = (images is List && images.isNotEmpty)
                              ? ApiConstants.imageUrl(images[0].toString())
                              : '';

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: img.isNotEmpty
                                  ? Image.network(
                                      img,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        width: 48,
                                        height: 48,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.agriculture, color: Colors.grey),
                                      ),
                                    )
                                  : Container(
                                      width: 48,
                                      height: 48,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.agriculture, color: Colors.grey),
                                    ),
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              '$price $unit',
                              style: const TextStyle(color: Color(0xFF0C6B2D), fontWeight: FontWeight.w600),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => widget.onSelect(p),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1570EF),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Share', style: TextStyle(color: Colors.white, fontSize: 12)),
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

// Order Selector Bottom Sheet
class _OrderPickerSheet extends StatefulWidget {
  final ScrollController scrollController;
  final ValueChanged<OrderModel> onSelect;

  const _OrderPickerSheet({
    required this.scrollController,
    required this.onSelect,
  });

  @override
  State<_OrderPickerSheet> createState() => _OrderPickerSheetState();
}

class _OrderPickerSheetState extends State<_OrderPickerSheet> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final items = await OrderService().getRestaurantOrders();
      if (mounted) {
        setState(() {
          _orders = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: Color(0xFFF79009)),
              SizedBox(width: 8),
              Text(
                'Select Order Quote to Share',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2939),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0C6B2D)))
                : _orders.isEmpty
                    ? Center(
                        child: Text(
                          'No orders found',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.separated(
                        controller: widget.scrollController,
                        itemCount: _orders.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final o = _orders[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF79009).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.receipt_long_rounded, color: Color(0xFFF79009), size: 20),
                            ),
                            title: Text(
                              'Order #${o.displayId}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              'Status: ${o.status} • \$${o.total.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => widget.onSelect(o),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF79009),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Share', style: TextStyle(color: Colors.white, fontSize: 12)),
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
