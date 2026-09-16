import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/core/routing/route_args.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/features/notification/models/notification_model.dart';
import 'package:mobile/features/notification/services/notification_service.dart';
import 'package:mobile/features/notification/services/push_notification_service.dart';
import 'package:mobile/features/notification/widgets/notification_card.dart';
import 'package:mobile/l10n/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const primaryGreen = Color(0xFF1B5E20);
  static const pageBg = Color(0xFFF7F9F7);

  final NotificationService _service = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  final List<StreamSubscription> _subscriptions = [];

  String? _userRole;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadNotifications();
    _connectRealtime();
  }

  Future<void> _loadUserRole() async {
    final role = await AuthService.getUserRole();
    if (mounted) {
      setState(() {
        _userRole = role;
      });
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final data = await _service.getNotifications();
      final rawItems = data['notifications'];
      final items = (rawItems is List)
          ? rawItems
              .map((item) => NotificationModel.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList()
          : <NotificationModel>[];

      if (mounted) {
        setState(() {
          _notifications = items;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to load notifications';
        });
      }
    }
  }

  Future<void> _connectRealtime() async {
    // 1. Listen to real-time notification created stream
    _subscriptions.add(
      NotificationService.onNotificationCreated.listen((notification) {
        if (!mounted) return;
        setState(() {
          _notifications.removeWhere((item) => item.id == notification.id);
          _notifications.insert(0, notification);
        });
      }),
    );

    // 2. Listen to real-time notification marked as read stream
    _subscriptions.add(
      NotificationService.onNotificationRead.listen((notificationId) {
        if (!mounted) return;
        setState(() {
          final idx = _notifications.indexWhere((item) => item.id == notificationId);
          if (idx != -1) {
            _notifications[idx] = _notifications[idx].copyWith(isRead: true);
          }
        });
      }),
    );

    // 3. Listen to real-time mark all as read stream
    _subscriptions.add(
      NotificationService.onNotificationReadAll.listen((_) {
        if (!mounted) return;
        setState(() {
          _notifications = _notifications.map((item) => item.copyWith(isRead: true)).toList();
        });
      }),
    );

    // 4. Listen to real-time notification deleted stream
    _subscriptions.add(
      NotificationService.onNotificationDeleted.listen((notificationId) {
        if (!mounted) return;
        setState(() {
          _notifications.removeWhere((item) => item.id == notificationId);
        });
      }),
    );

    // 5. Listen to real-time delete all notifications stream
    _subscriptions.add(
      NotificationService.onNotificationDeletedAll.listen((_) {
        if (!mounted) return;
        setState(() {
          _notifications.clear();
        });
      }),
    );

    // Ensure socket is connected and joined to user notification room
    try {
      await _service.connectToNotifications();
    } catch (error) {
      debugPrint('Realtime notifications connection error: $error');
    }
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;
    setState(() {
      final idx = _notifications.indexWhere((item) => item.id == notification.id);
      if (idx != -1) {
        _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      }
    });

    try {
      await _service.markAsRead(notification.id);
    } catch (e) {
      debugPrint('Failed to mark notification as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      _notifications = _notifications.map((item) => item.copyWith(isRead: true)).toList();
    });

    try {
      await _service.markAllAsRead();
    } catch (e) {
      debugPrint('Failed to mark all notifications as read: $e');
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    final originalList = List<NotificationModel>.from(_notifications);
    setState(() {
      _notifications.removeWhere((item) => item.id == notification.id);
    });

    try {
      await _service.deleteNotification(notification.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification removed'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      debugPrint('Failed to delete notification: $error');
      if (mounted) {
        setState(() {
          _notifications = originalList;
        });
      }
    }
  }

  Future<void> _clearAllNotifications() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear all notifications?'),
        content: const Text('This will permanently remove all your notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final originalList = List<NotificationModel>.from(_notifications);
    setState(() {
      _notifications.clear();
    });

    try {
      await _service.deleteAllNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications cleared'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to clear notifications: $e');
      if (mounted) {
        setState(() {
          _notifications = originalList;
        });
      }
    }
  }

  bool _isGenericChatTitle(String title) {
    final lower = title.trim().toLowerCase();
    return lower.isEmpty ||
        lower == 'new message' ||
        lower == 'new messages' ||
        lower == 'new photo message' ||
        lower == 'new order chat' ||
        lower == 'chat' ||
        lower == 'notification';
  }

  Future<void> _openReference(NotificationModel notification) async {
    final role = (await AuthService.getUserRole())?.toLowerCase() ??
        _userRole?.toLowerCase() ??
        'restaurant';
    final isFarmer = role == 'farmer';

    // 1. Chat
    if (notification.referenceType == 'conversation' || notification.isChat) {
      if (notification.referenceId != null && notification.referenceId!.isNotEmpty) {
        String participantName = notification.title.trim();
        if (participantName.startsWith('New Messages from ')) {
          participantName = participantName.replaceFirst('New Messages from ', '').trim();
        } else if (_isGenericChatTitle(participantName)) {
          final sentMatch =
              RegExp(r'^(.+?)\s+sent you', caseSensitive: false).firstMatch(notification.message);
          if (sentMatch != null) {
            participantName = sentMatch.group(1)!.trim();
          } else {
            participantName = '';
          }
        }

        if (!mounted) return;
        context.push(
          AppRoutes.chatConversation,
          extra: ChatConversationArgs(
            conversationId: notification.referenceId!,
            participantName: participantName,
            isOnline: false,
          ),
        );
      }
      return;
    }

    // 2. Orders & Payments
    if (notification.referenceType == 'order' || notification.isOrder || notification.isPayment) {
      if (!mounted) return;
      if (isFarmer) {
        if (notification.referenceId != null && notification.referenceId!.isNotEmpty) {
          context.push(
            AppRoutes.farmerOrderDetail,
            extra: OrderTrackingArgs(orderId: notification.referenceId!),
          );
        } else {
          context.go(AppRoutes.farmerOrders);
        }
      } else {
        if (notification.referenceId != null && notification.referenceId!.isNotEmpty) {
          context.push(
            AppRoutes.restaurantOrderTracking,
            extra: OrderTrackingArgs(orderId: notification.referenceId!),
          );
        } else {
          context.push(AppRoutes.restaurantOrders);
        }
      }
      return;
    }

    // 3. Products & Stock
    if (notification.referenceType == 'product' || notification.isProduct) {
      if (!mounted) return;
      if (isFarmer) {
        context.go(AppRoutes.farmerInventory);
      } else {
        context.go(AppRoutes.restaurantHome);
      }
      return;
    }

    // 4. Account & Security
    if (notification.isAccount) {
      if (!mounted) return;
      final lowerType = notification.type.toLowerCase();
      final lowerTitle = notification.title.toLowerCase();
      final isLoginAlert = lowerType.contains('login') ||
          lowerTitle.contains('login') ||
          lowerTitle.contains('new device') ||
          lowerType.contains('security');

      if (isLoginAlert) {
        _showSecurityAlertModal(notification, isFarmer);
      } else {
        if (isFarmer) {
          context.go(AppRoutes.farmerProfile);
        } else {
          context.go(AppRoutes.restaurantProfile);
        }
      }
      return;
    }
  }

  void _showSecurityAlertModal(NotificationModel notification, bool isFarmer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final timeStr = _dateLabel(notification.createdAt, AppLocalizations.of(context)!);
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: const Icon(
                      Icons.devices_rounded,
                      color: Color(0xFF0284C7),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        if (timeStr.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.message.isNotEmpty
                          ? notification.message
                          : 'A new login was detected on your account.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF334155),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 16,
                          color: primaryGreen,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'If this was you, you can safely ignore this notice. If you did not log in recently, we recommend reviewing your profile or updating your security credentials.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey.shade700,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Dismiss',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (isFarmer) {
                          context.go(AppRoutes.farmerProfile);
                        } else {
                          context.go(AppRoutes.restaurantProfile);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'View Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _dateLabel(DateTime? date, AppLocalizations l10n) {
    if (date == null) return '';
    final now = DateTime.now();
    final local = date.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    if (day == today) return l10n.today;
    if (day == today.subtract(const Duration(days: 1))) return l10n.yesterday;
    return '${local.month}/${local.day}/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasUnread = _notifications.any((item) => !item.isRead);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: Text(
          l10n.notifications,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Send Test Notification',
            icon: const Icon(Icons.notifications_active_outlined, color: primaryGreen),
            onPressed: () async {
              await PushNotificationService.showTestNotification(
                title: 'PsarKasekor Notification',
                body:
                    'Testing lock screen notification! If you lock your phone now, this appears on your lock screen.',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Test notification sent! Check your lock screen & status bar.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          if (hasUnread)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                l10n.markAllAsRead,
                style: const TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) {
              if (value == 'mark_all') {
                _markAllAsRead();
              } else if (value == 'clear_all') {
                _clearAllNotifications();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_all',
                enabled: hasUnread,
                child: Row(
                  children: [
                    Icon(Icons.done_all_rounded, size: 18, color: hasUnread ? primaryGreen : Colors.grey),
                    const SizedBox(width: 8),
                    Text(l10n.markAllAsRead),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_all',
                enabled: _notifications.isNotEmpty,
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_outlined, size: 18, color: _notifications.isNotEmpty ? Colors.red : Colors.grey),
                    const SizedBox(width: 8),
                    const Text('Clear all notifications', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryGreen),
            )
          : _errorMessage != null && _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_errorMessage!),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() => _isLoading = true);
                          _loadNotifications();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: primaryGreen.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                size: 36,
                                color: primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No notifications yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'You will receive real-time updates here for orders, messages, stock, payments, and account activities.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _buildNotificationContent(l10n),
    );
  }

  Widget _buildNotificationContent(AppLocalizations l10n) {
    final unreadCount = _notifications.where((item) => !item.isRead).length;

    // Filter by category
    final filteredNotifications = _selectedCategory == 'all'
        ? _notifications
        : _notifications.where((item) => item.category == _selectedCategory).toList();

    final groups = <String, List<NotificationModel>>{};
    for (final notification in filteredNotifications) {
      groups
          .putIfAbsent(_dateLabel(notification.createdAt, l10n), () => [])
          .add(notification);
    }

    return Column(
      children: [
        // Category filter bar
        _buildCategoryFilters(_notifications),

        // Notification list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadNotifications,
            color: primaryGreen,
            child: filteredNotifications.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_list_off_rounded,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No ${_categoryLabel(_selectedCategory)} notifications',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_categoryLabel(_selectedCategory).toUpperCase()} NOTIFICATIONS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          if (unreadCount > 0 && _selectedCategory == 'all')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                l10n.newNotifications(unreadCount),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (final entry in groups.entries) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                            bottom: 8,
                            top: 4,
                          ),
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        for (final notification in entry.value)
                          NotificationCard(
                            key: ValueKey(notification.id),
                            notification: notification,
                            onTap: () {
                              _markAsRead(notification);
                              _openReference(notification);
                            },
                            onDelete: () => _deleteNotification(notification),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  String _categoryLabel(String key) {
    switch (key) {
      case 'orders':
        return 'Orders';
      case 'messages':
        return 'Messages';
      case 'payments':
        return 'Payments';
      case 'products':
        return 'Stock';
      case 'account':
        return 'Account';
      case 'system':
        return 'System';
      default:
        return 'All';
    }
  }

  Widget _buildCategoryFilters(List<NotificationModel> allNotifications) {
    final categories = [
      ('all', 'All', Icons.all_inbox_rounded),
      ('orders', 'Orders', Icons.shopping_bag_outlined),
      ('messages', 'Messages', Icons.chat_bubble_outline_rounded),
      ('payments', 'Payments', Icons.account_balance_wallet_outlined),
      ('products', 'Stock', Icons.inventory_2_outlined),
      ('account', 'Account', Icons.security_rounded),
      ('system', 'System', Icons.campaign_outlined),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: categories.map((cat) {
            final key = cat.$1;
            final label = cat.$2;
            final icon = cat.$3;
            final isSelected = _selectedCategory == key;

            final count = key == 'all'
                ? allNotifications.length
                : allNotifications.where((n) => n.category == key).length;

            final unread = key == 'all'
                ? allNotifications.where((n) => !n.isRead).length
                : allNotifications
                    .where((n) => n.category == key && !n.isRead)
                    .length;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedCategory = key),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryGreen
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? primaryGreen
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 15,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color:
                              isSelected ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.25)
                                : (unread > 0
                                    ? primaryGreen.withValues(alpha: 0.15)
                                    : Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : (unread > 0
                                      ? primaryGreen
                                      : Colors.grey.shade700),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
