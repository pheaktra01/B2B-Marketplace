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
import 'package:socket_io_client/socket_io_client.dart' as io;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const primaryGreen = Color(0xFF1B5E20);
  static const pageBg = Color(0xFFF7F9F7);

  final NotificationService _service = NotificationService();
  late Future<List<NotificationModel>> _notificationsFuture;
  io.Socket? _socket;
  String? _userRole;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _refresh();
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

  Future<void> _connectRealtime() async {
    try {
      _socket = await _service.connectToNotifications((data) {
        final notification = NotificationModel.fromJson(data);
        if (!mounted) return;
        setState(() {
          _notificationsFuture = _notificationsFuture.then((items) {
            if (items.any((item) => item.id == notification.id)) return items;
            return [notification, ...items];
          });
        });
      });
    } catch (error) {
      debugPrint('Realtime notifications unavailable: $error');
    }
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }

  void _refresh() {
    _notificationsFuture = _service.getNotifications().then((data) {
      final rawItems = data['notifications'];
      if (rawItems is! List) return <NotificationModel>[];
      return rawItems
          .map(
            (item) => NotificationModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    });
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;
    await _service.markAsRead(notification.id);
    if (!mounted) return;
    setState(() {
      _notificationsFuture = _notificationsFuture.then(
        (items) => items
            .map(
              (item) => item.id == notification.id
                  ? item.copyWith(isRead: true)
                  : item,
            )
            .toList(),
      );
    });
  }

  Future<void> _markAllAsRead() async {
    await _service.markAllAsRead();
    if (!mounted) return;
    setState(() {
      _notificationsFuture = _notificationsFuture.then(
        (items) => items.map((item) => item.copyWith(isRead: true)).toList(),
      );
    });
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    try {
      await _service.deleteNotification(notification.id);
      if (!mounted) return;
      setState(() {
        _notificationsFuture = _notificationsFuture.then(
          (items) =>
              items.where((item) => item.id != notification.id).toList(),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification removed'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      debugPrint('Failed to delete notification: $error');
    }
  }

  void _openReference(NotificationModel notification) {
    // 1. Chat
    if (notification.referenceType == 'conversation' ||
        notification.isChat) {
      if (notification.referenceId != null && notification.referenceId!.isNotEmpty) {
        context.push(
          AppRoutes.chatConversation,
          extra: ChatConversationArgs(
            conversationId: notification.referenceId!,
            participantName: notification.title,
            isOnline: false,
          ),
        );
      }
      return;
    }

    // 2. Orders & Payments
    if (notification.referenceType == 'order' ||
        notification.isOrder ||
        notification.isPayment) {
      if (_userRole == 'farmer') {
        context.push(AppRoutes.farmerOrders);
      } else {
        context.push(AppRoutes.restaurantOrders);
      }
      return;
    }

    // 3. Products & Stock
    if (notification.referenceType == 'product' || notification.isProduct) {
      if (_userRole == 'farmer') {
        context.push(AppRoutes.farmerInventory);
      } else {
        context.push(AppRoutes.restaurantHome);
      }
      return;
    }

    // 4. Account & Security
    if (notification.isAccount) {
      if (_userRole == 'farmer') {
        context.push(AppRoutes.farmerProfile);
      } else {
        context.push(AppRoutes.restaurantProfile);
      }
      return;
    }
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
                body: 'Testing lock screen notification! If you lock your phone now, this appears on your lock screen.',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test notification sent! Check your lock screen & status bar.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
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
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryGreen),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unable to load notifications'),
                  TextButton(
                    onPressed: () => setState(_refresh),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return Center(
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
                      'You will receive updates here for orders, messages, stock, payments, and account activities.',
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
            );
          }

          final unreadCount =
              notifications.where((item) => !item.isRead).length;

          // Filter by category
          final filteredNotifications = _selectedCategory == 'all'
              ? notifications
              : notifications
                  .where((item) => item.category == _selectedCategory)
                  .toList();

          final groups = <String, List<NotificationModel>>{};
          for (final notification in filteredNotifications) {
            groups
                .putIfAbsent(_dateLabel(notification.createdAt, l10n), () => [])
                .add(notification);
          }

          return Column(
            children: [
              // Category filter bar
              _buildCategoryFilters(notifications),

              // Notification list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => setState(_refresh),
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
                                  notification: notification,
                                  onTap: () async {
                                    await _markAsRead(notification);
                                    if (mounted) _openReference(notification);
                                  },
                                  onDelete: () =>
                                      _deleteNotification(notification),
                                ),
                              const SizedBox(height: 8),
                            ],
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _categoryLabel(String category) {
    switch (category) {
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
