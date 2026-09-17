import 'package:flutter/material.dart';
import 'package:mobile/features/notification/models/notification_model.dart';
import 'package:mobile/l10n/app_localizations.dart';

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

  _NotificationStyle _getStyle(String type, AppLocalizations? l10n) {
    final lower = type.toLowerCase();

    // 1. Order Notifications
    if (lower == 'order_placed') {
      return _NotificationStyle(
        icon: Icons.shopping_cart_outlined,
        color: const Color(0xFF0284C7),
        bgColor: const Color(0xFFF0F9FF),
        tag: l10n?.tagOrderPlaced ?? 'Order Placed',
      );
    }
    if (lower == 'order_created') {
      return _NotificationStyle(
        icon: Icons.add_shopping_cart_rounded,
        color: const Color(0xFFEA580C),
        bgColor: const Color(0xFFFFF7ED),
        tag: l10n?.tagNewOrder ?? 'New Order',
      );
    }
    if (lower == 'order_accepted') {
      return _NotificationStyle(
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xFF16A34A),
        bgColor: const Color(0xFFF0FDF4),
        tag: l10n?.tagAccepted ?? 'Accepted',
      );
    }
    if (lower == 'order_rejected') {
      return _NotificationStyle(
        icon: Icons.highlight_off_rounded,
        color: const Color(0xFFDC2626),
        bgColor: const Color(0xFFFEF2F2),
        tag: l10n?.tagRejected ?? 'Rejected',
      );
    }
    if (lower == 'order_ready') {
      return _NotificationStyle(
        icon: Icons.inventory_rounded,
        color: const Color(0xFF4F46E5),
        bgColor: const Color(0xFFEEF2FF),
        tag: l10n?.tagReady ?? 'Ready',
      );
    }
    if (lower == 'order_completed') {
      return _NotificationStyle(
        icon: Icons.task_alt_rounded,
        color: const Color(0xFF059669),
        bgColor: const Color(0xFFECFDF5),
        tag: l10n?.tagCompleted ?? 'Completed',
      );
    }
    if (lower == 'order_cancelled') {
      return _NotificationStyle(
        icon: Icons.cancel_outlined,
        color: const Color(0xFFDC2626),
        bgColor: const Color(0xFFFEF2F2),
        tag: l10n?.tagCancelled ?? 'Cancelled',
      );
    }
    if (lower.contains('order')) {
      return _NotificationStyle(
        icon: Icons.local_shipping_outlined,
        color: const Color(0xFFEA580C),
        bgColor: const Color(0xFFFFF7ED),
        tag: l10n?.tagOrder ?? 'Order',
      );
    }

    // 2. Chat Notifications
    if (lower == 'chat_image') {
      return _NotificationStyle(
        icon: Icons.image_outlined,
        color: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEFF6FF),
        tag: l10n?.tagPhoto ?? 'Photo',
      );
    }
    if (lower == 'chat_order') {
      return _NotificationStyle(
        icon: Icons.forum_outlined,
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF5F3FF),
        tag: l10n?.tagOrderChat ?? 'Order Chat',
      );
    }
    if (lower.contains('message') || lower.contains('chat')) {
      return _NotificationStyle(
        icon: Icons.chat_bubble_outline_rounded,
        color: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEFF6FF),
        tag: l10n?.tagChat ?? 'Chat',
      );
    }

    // 3. Payment Notifications
    if (lower == 'payment_failed') {
      return _NotificationStyle(
        icon: Icons.error_outline_rounded,
        color: const Color(0xFFDC2626),
        bgColor: const Color(0xFFFEF2F2),
        tag: l10n?.tagPaymentFailed ?? 'Payment Failed',
      );
    }
    if (lower == 'payment_success' || lower == 'payment_completed') {
      return _NotificationStyle(
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xFF059669),
        bgColor: const Color(0xFFECFDF5),
        tag: l10n?.tagPaymentDone ?? 'Payment Done',
      );
    }
    if (lower.contains('payment')) {
      return _NotificationStyle(
        icon: Icons.account_balance_wallet_outlined,
        color: const Color(0xFF059669),
        bgColor: const Color(0xFFECFDF5),
        tag: l10n?.tagPayment ?? 'Payment',
      );
    }

    // 4. Product & Stock Notifications
    if (lower == 'product_out_of_stock' || lower.contains('out_of_stock')) {
      return _NotificationStyle(
        icon: Icons.remove_shopping_cart_outlined,
        color: const Color(0xFFDC2626),
        bgColor: const Color(0xFFFEF2F2),
        tag: l10n?.tagOutOfStock ?? 'Out of Stock',
      );
    }
    if (lower == 'product_low_stock' || lower.contains('low_stock')) {
      return _NotificationStyle(
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFD97706),
        bgColor: const Color(0xFFFFFBEB),
        tag: l10n?.tagLowStock ?? 'Low Stock',
      );
    }
    if (lower == 'product_published') {
      return _NotificationStyle(
        icon: Icons.storefront_outlined,
        color: const Color(0xFF059669),
        bgColor: const Color(0xFFECFDF5),
        tag: l10n?.tagPublished ?? 'Published',
      );
    }
    if (lower == 'product_updated') {
      return _NotificationStyle(
        icon: Icons.edit_note_rounded,
        color: const Color(0xFF9333EA),
        bgColor: const Color(0xFFFAF5FF),
        tag: l10n?.tagUpdated ?? 'Updated',
      );
    }
    if (lower.contains('product') || lower.contains('inventory') || lower.contains('stock')) {
      return _NotificationStyle(
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFF9333EA),
        bgColor: const Color(0xFFFAF5FF),
        tag: l10n?.tagInventory ?? 'Inventory',
      );
    }

    // 5. Account & Security Notifications
    if (lower == 'account_security_alert') {
      return _NotificationStyle(
        icon: Icons.security_rounded,
        color: const Color(0xFFDC2626),
        bgColor: const Color(0xFFFEF2F2),
        tag: l10n?.tagSecurityAlert ?? 'Security Alert',
      );
    }
    if (lower == 'account_login') {
      return _NotificationStyle(
        icon: Icons.devices_rounded,
        color: const Color(0xFF0284C7),
        bgColor: const Color(0xFFF0F9FF),
        tag: l10n?.tagDeviceLogin ?? 'Device Login',
      );
    }
    if (lower == 'account_password_changed') {
      return _NotificationStyle(
        icon: Icons.vpn_key_outlined,
        color: const Color(0xFF0D9488),
        bgColor: const Color(0xFFF0FDFA),
        tag: l10n?.tagPassword ?? 'Password',
      );
    }
    if (lower == 'account_phone_changed') {
      return _NotificationStyle(
        icon: Icons.phone_android_rounded,
        color: const Color(0xFF4F46E5),
        bgColor: const Color(0xFFEEF2FF),
        tag: l10n?.tagPhone ?? 'Phone',
      );
    }
    if (lower.contains('account') || lower.contains('profile')) {
      return _NotificationStyle(
        icon: Icons.person_outline_rounded,
        color: const Color(0xFF0D9488),
        bgColor: const Color(0xFFF0FDFA),
        tag: l10n?.tagAccount ?? 'Account',
      );
    }

    // 6. System Notifications
    if (lower == 'system_announcement') {
      return _NotificationStyle(
        icon: Icons.campaign_outlined,
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF5F3FF),
        tag: l10n?.tagAnnouncement ?? 'Announcement',
      );
    }
    if (lower == 'system_maintenance') {
      return _NotificationStyle(
        icon: Icons.build_circle_outlined,
        color: const Color(0xFFEA580C),
        bgColor: const Color(0xFFFFF7ED),
        tag: l10n?.tagMaintenance ?? 'Maintenance',
      );
    }
    if (lower == 'system_new_feature') {
      return _NotificationStyle(
        icon: Icons.auto_awesome_rounded,
        color: const Color(0xFFD946EF),
        bgColor: const Color(0xFFFDF4FF),
        tag: l10n?.tagNewFeature ?? 'New Feature',
      );
    }
    if (lower == 'system_policy_update') {
      return _NotificationStyle(
        icon: Icons.gavel_rounded,
        color: const Color(0xFF475569),
        bgColor: const Color(0xFFF8FAFC),
        tag: l10n?.tagPolicyUpdate ?? 'Policy Update',
      );
    }
    if (lower == 'system_interruption') {
      return _NotificationStyle(
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFDC2626),
        bgColor: const Color(0xFFFEF2F2),
        tag: l10n?.tagInterruption ?? 'Interruption',
      );
    }

    return _NotificationStyle(
      icon: Icons.notifications_none_rounded,
      color: const Color(0xFF0D9488),
      bgColor: const Color(0xFFF0FDFA),
      tag: l10n?.tagNotice ?? 'Notice',
    );
  }

  String _formatTimeAgo(DateTime? date, AppLocalizations? l10n) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date.toLocal());

    if (difference.inSeconds < 60) {
      return l10n?.justNow ?? 'Just now';
    } else if (difference.inMinutes < 60) {
      return l10n?.minutesAgo(difference.inMinutes) ?? '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return l10n?.hoursAgo(difference.inHours) ?? '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return l10n?.yesterday ?? 'Yesterday';
    } else if (difference.inDays < 7) {
      return l10n?.daysAgo(difference.inDays) ?? '${difference.inDays}d ago';
    } else {
      final local = date.toLocal();
      return '${local.month}/${local.day}/${local.year}';
    }
  }

  String _getLocalizedTitle(String title, String type, AppLocalizations? l10n) {
    if (l10n == null) return title;
    final lower = title.trim().toLowerCase();
    if (lower == 'notification') return l10n.notifications;
    if (lower == 'new order' || lower.startsWith('new order #')) {
      final match = RegExp(r'#(\w+)').firstMatch(title);
      if (match != null) {
        return l10n.newOrder(match.group(1)!);
      }
      return l10n.tagNewOrder;
    }
    if (lower == 'order placed') return l10n.tagOrderPlaced;
    if (lower == 'order accepted') return l10n.tagAccepted;
    if (lower == 'order rejected') return l10n.tagRejected;
    if (lower == 'order ready' || lower == 'order ready for pickup') return l10n.tagReady;
    if (lower == 'order completed') return l10n.tagCompleted;
    if (lower == 'order cancelled') return l10n.tagCancelled;
    if (lower == 'order delivered') return l10n.orderDelivered;
    if (lower == 'new message' || lower == 'new messages') return l10n.tagChat;
    if (lower == 'payment successful' || lower == 'payment completed') return l10n.tagPaymentDone;
    if (lower == 'payment received') return l10n.paymentReceived;
    if (lower == 'payment failed') return l10n.tagPaymentFailed;
    if (lower == 'product low stock' || lower == 'low stock alert') return l10n.tagLowStock;
    if (lower == 'product out of stock' || lower == 'out of stock alert') return l10n.tagOutOfStock;
    if (lower == 'system update') return l10n.systemUpdate;
    if (lower == 'system maintenance') return l10n.tagMaintenance;
    if (lower == 'security alert' || lower.contains('new login')) return l10n.securityAlert;
    return title;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = _getStyle(notification.type, l10n);
    final isUnread = !notification.isRead;
    final timeStr = _formatTimeAgo(notification.createdAt, l10n);
    final displayTitle = _getLocalizedTitle(notification.title, notification.type, l10n);

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
                                    displayTitle,
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
                                  l10n?.view ?? 'View',
                                  style: const TextStyle(
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 4),
              Text(
                l10n?.delete ?? 'Delete',
                style: const TextStyle(
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
