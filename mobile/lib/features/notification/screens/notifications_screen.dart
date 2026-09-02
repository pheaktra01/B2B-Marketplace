import 'package:flutter/material.dart';
import 'package:mobile/features/chat/screens/chat_screen.dart';
import 'package:mobile/features/notification/models/notification_model.dart';
import 'package:mobile/features/notification/services/notification_service.dart';
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
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
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

  void _openReference(NotificationModel notification) {
    if (notification.referenceType != 'conversation' ||
        notification.referenceId == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversationId: notification.referenceId!,
          participantName: notification.title,
          isOnline: false,
        ),
      ),
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
    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
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
            return const Center(child: CircularProgressIndicator());
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
            return const Center(child: Text('No notifications yet'));
          }

          final unreadCount = notifications
              .where((item) => !item.isRead)
              .length;
          final groups = <String, List<NotificationModel>>{};
          for (final notification in notifications) {
            groups
                .putIfAbsent(_dateLabel(notification.createdAt, l10n), () => [])
                .add(notification);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.notifications,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      letterSpacing: 1,
                    ),
                  ),
                  if (unreadCount > 0)
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
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              for (final entry in groups.entries) ...[
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                for (final notification in entry.value)
                  _NotificationCard(
                    notification: notification,
                    onTap: () async {
                      await _markAsRead(notification);
                      if (mounted) _openReference(notification);
                    },
                  ),
                const SizedBox(height: 8),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  IconData _iconForType(String type) {
    if (type == 'message') return Icons.chat_bubble_outline;
    if (type.startsWith('order')) return Icons.storefront;
    if (type == 'payment_received') {
      return Icons.account_balance_wallet_outlined;
    }
    if (type == 'product') return Icons.inventory_2_outlined;
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notification.isRead
                      ? Colors.grey.shade200
                      : const Color(0xFFB9F6CA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForType(notification.type),
                  color: notification.isRead
                      ? Colors.black54
                      : const Color(0xFF1B5E20),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 7,
                            height: 12,
                            color: const Color(0xFF1B5E20),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.35,
                      ),
                    ),
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
