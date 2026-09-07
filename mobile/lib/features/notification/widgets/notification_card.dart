import 'package:flutter/material.dart';
import 'package:mobile/features/notification/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    this.onDelete,
  });

  static const Color primaryGreen = Color(0xFF1B5E20);

  _NotificationStyle _getStyle(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('order')) {
      return const _NotificationStyle(
        icon: Icons.local_shipping_outlined,
        color: Color(0xFFEA580C),
        bgColor: Color(0xFFFFF7ED),
        tag: 'Order',
      );
    }
    if (lowerType.contains('payment')) {
      return const _NotificationStyle(
        icon: Icons.account_balance_wallet_outlined,
        color: Color(0xFF059669),
        bgColor: Color(0xFFECFDF5),
        tag: 'Payment',
      );
    }
    if (lowerType.contains('message') || lowerType.contains('chat')) {
      return const _NotificationStyle(
        icon: Icons.chat_bubble_outline_rounded,
        color: Color(0xFF2563EB),
        bgColor: Color(0xFFEFF6FF),
        tag: 'Chat',
      );
    }
    if (lowerType.contains('product') || lowerType.contains('inventory')) {
      return const _NotificationStyle(
        icon: Icons.inventory_2_outlined,
        color: Color(0xFF9333EA),
        bgColor: Color(0xFFFAF5FF),
        tag: 'Inventory',
      );
    }
    return const _NotificationStyle(
      icon: Icons.notifications_none_rounded,
      color: Color(0xFF0D9488),
      bgColor: Color(0xFFF0FDFA),
      tag: 'Notice',
    );
  }

  String _formatTimeAgo(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date.toLocal());

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      final local = date.toLocal();
      return '${local.month}/${local.day}/${local.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStyle(notification.type);
    final isUnread = !notification.isRead;
    final timeStr = _formatTimeAgo(notification.createdAt);

    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFF4FBF5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? primaryGreen.withValues(alpha: 0.25)
              : Colors.grey.shade200,
          width: isUnread ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnread
                ? primaryGreen.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isUnread ? style.bgColor : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      style.icon,
                      color: isUnread ? style.color : Colors.grey.shade600,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Title, Unread Dot & Time
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    notification.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: isUnread
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      fontSize: 14.5,
                                      color: isUnread
                                          ? const Color(0xFF111827)
                                          : const Color(0xFF374151),
                                    ),
                                  ),
                                ),
                                if (isUnread) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: primaryGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (timeStr.isNotEmpty)
                            Text(
                              timeStr,
                              style: TextStyle(
                                fontSize: 11,
                                color: isUnread
                                    ? primaryGreen
                                    : Colors.grey.shade500,
                                fontWeight: isUnread
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Message Body
                      Text(
                        notification.message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: isUnread
                              ? const Color(0xFF374151)
                              : Colors.grey.shade600,
                          height: 1.38,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Footer: Category Tag & Tap indicator
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isUnread
                                  ? style.color.withValues(alpha: 0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              style.tag,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: isUnread
                                    ? style.color
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (notification.referenceId != null ||
                              notification.referenceType != null)
                            Row(
                              children: [
                                Text(
                                  'View',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 15,
                                  color: primaryGreen,
                                ),
                              ],
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

    if (onDelete != null) {
      return Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete!(),
        background: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFDC2626),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
              SizedBox(width: 4),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: cardContent,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: cardContent,
    );
  }
}

class _NotificationStyle {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String tag;

  const _NotificationStyle({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.tag,
  });
}
