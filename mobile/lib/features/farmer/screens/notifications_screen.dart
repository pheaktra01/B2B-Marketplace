import 'package:flutter/material.dart';

import 'package:mobile/l10n/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen =
      Color(0xFF1B5E20);

  static const Color lightGreenIconBg =
      Color(0xFFB9F6CA);

  static const Color pageBg =
      Color(0xFFF7F9F7);

  static const Color paymentIconBg =
      Color(0xFFFFE0B2);

  static const Color deliveryIconBg =
      Color(0xFFE8EAF6);

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n =
        AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: pageBg,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black87,
          ),
          onPressed: () {
            Navigator.maybePop(context);
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
          TextButton(
            onPressed: () {
              // TODO:
              // Mark all notifications as read.
            },
            child: Text(
              l10n.markAllAsRead,
              style: const TextStyle(
                color: primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        children: [
          // ======================================================
          // TODAY
          // ======================================================

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.today,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  letterSpacing: 1.0,
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryGreen,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.newNotifications(3),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ======================================================
          // CARD 1
          // NEW ORDER
          // ======================================================

          _buildNotificationCard(
            isUnread: true,

            iconWidget: Container(
              padding:
                  const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: lightGreenIconBg,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.storefront,
                color: primaryGreen,
                size: 22,
              ),
            ),

            title: l10n.newOrder('8821'),

            timeAgo: l10n.minutesAgo(2),

            bodyText: l10n.orderMessage(
              'The Bistro Kitchen',
              '40',
              'Heirloom Tomatoes',
            ),

            actionWidget: Row(
              children: [
                // ------------------------------------------------
                // VIEW ORDER
                // ------------------------------------------------

                ElevatedButton(
                  onPressed: () {},

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        primaryGreen,
                    elevation: 0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8),
                    ),

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),

                  child: Text(
                    l10n.viewOrder,
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // ------------------------------------------------
                // DECLINE
                // ------------------------------------------------

                OutlinedButton(
                  onPressed: () {},

                  style:
                      OutlinedButton.styleFrom(
                    backgroundColor:
                        Colors.grey.shade200,
                    side: BorderSide.none,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8),
                    ),

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),

                  child: Text(
                    l10n.decline,
                    style:
                        const TextStyle(
                      color: Colors.black87,
                      fontWeight:
                          FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // CARD 2
          // MESSAGE FROM CHEF
          // ======================================================

          _buildNotificationCard(
            isUnread: true,

            iconWidget:
                const CircleAvatar(
              radius: 22,
              backgroundImage:
                  NetworkImage(
                'https://via.placeholder.com/150',
              ),
            ),

            title: l10n.messageFromChef(
              'Marcus',
            ),

            timeAgo: l10n.hoursAgo(1),

            bodyText:
                l10n.chefMessage,

            actionWidget: Row(
              children: [
                // ------------------------------------------------
                // CHAT ICON
                // ------------------------------------------------

                Container(
                  padding:
                      const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Colors.grey.shade200,
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    size: 18,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(width: 8),

                // ------------------------------------------------
                // REPLY
                // ------------------------------------------------

                ElevatedButton(
                  onPressed: () {},

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        primaryGreen,
                    elevation: 0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8),
                    ),

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),

                  child: Text(
                    l10n.replyNow,
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // CARD 3
          // PAYMENT RECEIVED
          // ======================================================

          _buildNotificationCard(
            isUnread: false,

            iconWidget: Container(
              padding:
                  const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: paymentIconBg,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons
                    .account_balance_wallet_outlined,
                color: Colors.brown,
                size: 22,
              ),
            ),

            title: l10n.paymentReceived,

            timeAgo: l10n.hoursAgo(4),

            bodyText:
                l10n.paymentProcessed(
              '\$1,240.50',
              'Oct 1-15',
            ),

            actionWidget: TextButton(
              onPressed: () {},

              style:
                  TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize:
                    const Size(50, 30),
                alignment:
                    Alignment.centerLeft,
              ),

              child: Text(
                l10n.checkBalance,
                style:
                    const TextStyle(
                  color: primaryGreen,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ======================================================
          // YESTERDAY
          // ======================================================

          Text(
            l10n.yesterday,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              letterSpacing: 1.0,
            ),
          ),

          const SizedBox(height: 12),

          // ======================================================
          // CARD 4
          // ORDER DELIVERED
          // ======================================================

          _buildNotificationCard(
            isUnread: false,

            iconWidget: Container(
              padding:
                  const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: deliveryIconBg,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                color: Colors.black87,
                size: 22,
              ),
            ),

            title: l10n.orderDelivered,

            timeAgo: 'Oct 24, 4:12 PM',

            bodyText:
                l10n.orderDeliveredMessage(
              '7749',
              'Green Leaf Brasserie',
            ),

            actionWidget:
                OutlinedButton(
              onPressed: () {},

              style:
                  OutlinedButton.styleFrom(
                backgroundColor:
                    Colors.grey.shade200,
                side: BorderSide.none,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8),
                ),

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),

              child: Text(
                l10n.viewDetails,
                style:
                    const TextStyle(
                  color: Colors.black87,
                  fontWeight:
                      FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          // ======================================================
          // CARD 5
          // SYSTEM UPDATE
          // ======================================================

          _buildNotificationCard(
            isUnread: false,

            iconWidget: Container(
              padding:
                  const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Colors.black54,
                size: 22,
              ),
            ),

            title: l10n.systemUpdate,

            timeAgo: 'Oct 24, 10:00 AM',

            bodyText:
                l10n.systemUpdateMessage,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTIFICATION CARD
  // ============================================================

  Widget _buildNotificationCard({
    required bool isUnread,
    required Widget iconWidget,
    required String title,
    required String timeAgo,
    required String bodyText,
    Widget? actionWidget,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.02,
            ),
            blurRadius: 4,
            offset:
                const Offset(0, 2),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(16),

        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [
              // ==================================================
              // UNREAD INDICATOR
              // ==================================================

              if (isUnread)
                Container(
                  width: 4,
                  color: primaryGreen,
                ),

              // ==================================================
              // CONTENT
              // ==================================================

              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    14,
                  ),

                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // ------------------------------------------
                      // ICON
                      // ------------------------------------------

                      iconWidget,

                      const SizedBox(
                        width: 12,
                      ),

                      // ------------------------------------------
                      // TEXT
                      // ------------------------------------------

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            // ====================================
                            // TITLE + TIME
                            // ====================================

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,

                              children: [
                                Flexible(
                                  child: Text(
                                    title,
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      fontSize: 15,
                                      color:
                                          Colors.black87,
                                    ),
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                  ),
                                ),

                                Row(
                                  children: [
                                    Text(
                                      timeAgo,
                                      style:
                                          TextStyle(
                                        fontSize: 11,
                                        color: Colors
                                            .grey
                                            .shade600,
                                      ),
                                    ),

                                    if (isUnread) ...[
                                      const SizedBox(
                                        width: 6,
                                      ),

                                      Container(
                                        width: 6,
                                        height: 12,
                                        decoration:
                                            BoxDecoration(
                                          color:
                                              primaryGreen,
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            // ====================================
                            // BODY
                            // ====================================

                            Text(
                              bodyText,
                              style:
                                  TextStyle(
                                fontSize: 13,
                                color: Colors
                                    .grey
                                    .shade700,
                                height: 1.35,
                              ),
                            ),

                            // ====================================
                            // ACTION
                            // ====================================

                            if (actionWidget !=
                                null) ...[
                              const SizedBox(
                                height: 12,
                              ),

                              actionWidget,
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}