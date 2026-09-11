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
    final lower = type.toLowerCase();

    // 1. Order Notifications
    if (lower == 'order_placed') {
      return const _NotificationStyle(
        icon: Icons.shopping_cart_outlined,
        color: Color(0xFF0284C7),
        bgColor: Color(0xFFF0F9FF),
        tag: 'Order Placed',
      );
    }
    if (lower == 'order_created') {
      return const _NotificationStyle(
        icon: Icons.add_shopping_cart_rounded,
        color: Color(0xFFEA580C),
        bgColor: Color(0xFFFFF7ED),
        tag: 'New Order',
      );
    }
    if (lower == 'order_accepted') {
      return const _NotificationStyle(
        icon: Icons.check_circle_outline_rounded,
        color: Color(0xFF16A34A),
        bgColor: Color(0xFFF0FDF4),
        tag: 'Accepted',
      );
    }
    if (lower == 'order_rejected') {
      return const _NotificationStyle(
        icon: Icons.highlight_off_rounded,
        color: Color(0xFFDC2626),
        bgColor: Color(0xFFFEF2F2),
        tag: 'Rejected',
      );
    }
    if (lower == 'order_ready') {
      return const _NotificationStyle(
        icon: Icons.inventory_rounded,
        color: Color(0xFF4F46E5),
        bgColor: Color(0xFFEEF2FF),
        tag: 'Ready',
      );
    }
    if (lower == 'order_completed') {
      return const _NotificationStyle(
        icon: Icons.task_alt_rounded,
        color: Color(0xFF059669),
        bgColor: Color(0xFFECFDF5),
        tag: 'Completed',
      );
    }
    if (lower == 'order_cancelled') {
      return const _NotificationStyle(
        icon: Icons.cancel_outlined,
        color: Color(0xFFDC2626),
        bgColor: Color(0xFFFEF2F2),
        tag: 'Cancelled',
      );
    }
    if (lower.contains('order')) {
      return const _NotificationStyle(
        icon: Icons.local_shipping_outlined,
        color: Color(0xFFEA580C),
        bgColor: Color(0xFFFFF7ED),
        tag: 'Order',
      );
    }

    // 2. Chat Notifications
    if (lower == 'chat_image') {
      return const _NotificationStyle(
        icon: Icons.image_outlined,
        color: Color(0xFF2563EB),
        bgColor: Color(0xFFEFF6FF),
        tag: 'Photo',
      );
    }
    if (lower == 'chat_order') {
      return const _NotificationStyle(
        icon: Icons.forum_outlined,
        color: Color(0xFF7C3AED),
        bgColor: Color(0xFFF5F3FF),
        tag: 'Order Chat',
      );
    }
    if (lower.contains('message') || lower.contains('chat')) {
      return const _NotificationStyle(
        icon: Icons.chat_bubble_outline_rounded,
        color: Color(0xFF2563EB),
        bgColor: Color(0xFFEFF6FF),
        tag: 'Chat',
      );
    }

    // 3. Payment Notifications
    if (lower == 'payment_failed') {
      return const _NotificationStyle(
        icon: Icons.error_outline_rounded,
        color: Color(0xFFDC2626),
        bgColor: Color(0xFFFEF2F2),
        tag: 'Payment Failed',
      );
    }
    if (lower == 'payment_success' || lower == 'payment_completed') {
      return const _NotificationStyle(
        icon: Icons.check_circle_outline_rounded,
        color: Color(0xFF059669),
        bgColor: Color(0xFFECFDF5),
        tag: 'Payment Done',
      );
    }
    if (lower.contains('payment')) {
      return const _NotificationStyle(
        icon: Icons.account_balance_wallet_outlined,
        color: Color(0xFF059669),
        bgColor: Color(0xFFECFDF5),
        tag: 'Payment',
      );
    }

    // 4. Product & Stock Notifications
    if (lower == 'product_out_of_stock' || lower.contains('out_of_stock')) {
      return const _NotificationStyle(
        icon: Icons.remove_shopping_cart_outlined,
        color: Color(0xFFDC2626),
        bgColor: Color(0xFFFEF2F2),
        tag: 'Out of Stock',
      );
    }
    if (lower == 'product_low_stock' || lower.contains('low_stock')) {
      return const _NotificationStyle(
        icon: Icons.warning_amber_rounded,
        color: Color(0xFFD97706),
        bgColor: Color(0xFFFFFBEB),
        tag: 'Low Stock',
      );
    }
    if (lower == 'product_published') {
      return const _NotificationStyle(
        icon: Icons.storefront_outlined,
        color: Color(0xFF059669),
        bgColor: Color(0xFFECFDF5),
        tag: 'Published',
      );
    }
    if (lower == 'product_updated') {
      return const _NotificationStyle(
        icon: Icons.edit_note_rounded,
        color: Color(0xFF9333EA),
        bgColor: Color(0xFFFAF5FF),
        tag: 'Updated',
      );
    }
    if (lower.contains('product') || lower.contains('inventory') || lower.contains('stock')) {
      return const _NotificationStyle(
        icon: Icons.inventory_2_outlined,
        color: Color(0xFF9333EA),
        bgColor: Color(0xFFFAF5FF),
        tag: 'Inventory',
      );
    }

    // 5. Account & Security Notifications
    if (lower == 'account_security_alert') {
      return const _NotificationStyle(
        icon: Icons.security_rounded,
        color: Color(0xFFDC2626),
        bgColor: Color(0xFFFEF2F2),
        tag: 'Security Alert',
      );
    }
    if (lower == 'account_login') {
      return const _NotificationStyle(
        icon: Icons.devices_rounded,
        color: Color(0xFF0284C7),
        bgColor: Color(0xFFF0F9FF),
        tag: 'Device Login',
      );
    }
    if (lower == 'account_password_changed') {
      return const _NotificationStyle(
        icon: Icons.vpn_key_outlined,
        color: Color(0xFF0D9488),
        bgColor: Color(0xFFF0FDFA),
        tag: 'Password',
      );
    }
    if (lower == 'account_phone_changed') {
      return const _NotificationStyle(
        icon: Icons.phone_android_rounded,
        color: Color(0xFF4F46E5),
        bgColor: Color(0xFFEEF2FF),
        tag: 'Phone',
      );
    }
    if (lower.contains('account') || lower.contains('profile')) {
      return const _NotificationStyle(
        icon: Icons.person_outline_rounded,
        color: Color(0xFF0D9488),
        bgColor: Color(0xFFF0FDFA),
        tag: 'Account',
      );
    }

    // 6. System Notifications
    if (lower == 'system_announcement') {
      return const _NotificationStyle(
        icon: Icons.campaign_outlined,
        color: Color(0xFF7C3AED),
        bgColor: Color(0xFFF5F3FF),
        tag: 'Announcement',
      );
    }
    if (lower == 'system_maintenance') {
      return const _NotificationStyle(
        icon: Icons.build_circle_outlined,
        color: Color(0xFFEA580C),
        bgColor: Color(0xFFFFF7ED),
        tag: 'Maintenance',
      );
    }
    if (lower == 'system_new_feature') {
      return const _NotificationStyle(
        icon: Icons.auto_awesome_rounded,
        color: Color(0xFFD946EF),
        bgColor: Color(0xFFFDF4FF),
        tag: 'New Feature',
      );
    }
    if (lower == 'system_policy_update') {
      return const _NotificationStyle(
        icon: Icons.gavel_rounded,
        color: Color(0xFF475569),
        bgColor: Color(0xFFF8FAFC),
        tag: 'Policy Update',
      );
    }
    if (lower == 'system_interruption') {
      return const _NotificationStyle(
        icon: Icons.warning_amber_rounded,
        color: Color(0xFFDC2626),
        bgColor: Color(0xFFFEF2F2),
        tag: 'Interruption',
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
