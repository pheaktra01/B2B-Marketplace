import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color lightGreenIconBg = Color(0xFFB9F6CA);
  static const Color pageBg = Color(0xFFF7F9F7);
  static const Color paymentIconBg = Color(0xFFFFE0B2);
  static const Color deliveryIconBg = Color(0xFFE8EAF6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        title: const Text(
          'ការជូនដំណឹង',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'អានទាំងអស់',
              style: TextStyle(
                color: primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // 1. TODAY SECTION
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ថ្ងៃនេះ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ថ្មី 3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Card 1: New Order (Unread)
          _buildNotificationCard(
            isUnread: true,
            iconWidget: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: lightGreenIconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.storefront, color: primaryGreen, size: 22),
            ),
            title: 'ការបញ្ជាទិញថ្មី #8821',
            timeAgo: '2 នាទីមុន',
            bodyText:
                'ហាង The Bistro Kitchen បានកុម្ម៉ង់ទិញប៉េងប៉ោះ Heirloom ចំនួន 40kg។',
            actionWidget: Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'មើលការបញ្ជាទិញ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'បដិសេធ',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Card 2: Message from Chef (Unread)
          _buildNotificationCard(
            isUnread: true,
            iconWidget: const CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            title: 'សារពីមេចុងភៅ Marcus',
            timeAgo: '1 ម៉ោងមុន',
            bodyText:
                '"តើយើងអាចបន្ថែមបរិមាណដឹកជញ្ជូនសម្រាប់ថ្ងៃអង្គារបានទេ? ខ្ញុំត្រូវការបន្ថែម 20 កេះទៀត..."',
            actionWidget: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chat_bubble_outline,
                      size: 18, color: Colors.black54),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'ឆ្លើយតបឥឡូវនេះ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Card 3: Payment Received (Read / No Green Border)
          _buildNotificationCard(
            isUnread: false,
            iconWidget: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: paymentIconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.account_balance_wallet_outlined,
                  color: Colors.brown, size: 22),
            ),
            title: 'ទទួលបានការទូទាត់ប្រាក់',
            timeAgo: '4 ម៉ោងមុន',
            bodyText:
                'ការទូទាត់ប្រាក់ចំនួន \$1,240.50 របស់អ្នកសម្រាប់កំឡុងថ្ងៃទី 1-15 តុលា ត្រូវបានដំណើរការរួចរាល់។',
            actionWidget: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                alignment: Alignment.centerLeft,
              ),
              child: const Text(
                'ពិនិត្យតុល្យភាព >',
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 2. YESTERDAY SECTION
          const Text(
            'ម្សិលមិញ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              letterSpacing: 1.0,
            ),
          ),

          const SizedBox(height: 12),

          // Card 4: Order Delivered
          _buildNotificationCard(
            isUnread: false,
            iconWidget: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: deliveryIconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_shipping_outlined,
                  color: Colors.black87, size: 22),
            ),
            title: 'បានដឹកជញ្ជូនរួចរាល់',
            timeAgo: '24 តុលា, 4:12 PM',
            bodyText:
                'ការបញ្ជាទិញ #7749 ត្រូវបានដឹកជញ្ជូនដោយជោគជ័យទៅកាន់ Green Leaf Brasserie។',
            actionWidget: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'មើលព័ត៌មានលម្អិត',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          // Card 5: System Update
          _buildNotificationCard(
            isUnread: false,
            iconWidget: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.info_outline,
                  color: Colors.black54, size: 22),
            ),
            title: 'ការធ្វើបច្ចុប្បន្នភាពប្រព័ន្ធ',
            timeAgo: '24 តុលា, 10:00 AM',
            bodyText:
                'ការថែទាំប្រព័ន្ធ Verdant ត្រូវបានបញ្ចប់។ មុខងារតាមដានការដឹកជញ្ជូនថ្មីអាចប្រើប្រាស់បានហើយ!',
          ),
        ],
      ),
    );
  }

  // Generic Notification Card Builder
  Widget _buildNotificationCard({
    required bool isUnread,
    required Widget iconWidget,
    required String title,
    required String timeAgo,
    required String bodyText,
    Widget? actionWidget,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Highlight indicator bar for unread notifications
              if (isUnread)
                Container(
                  width: 4,
                  color: primaryGreen,
                ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      iconWidget,
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Title & Timestamp
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      timeAgo,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    if (isUnread) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 6,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: primaryGreen,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // Body Text
                            Text(
                              bodyText,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                height: 1.35,
                              ),
                            ),

                            if (actionWidget != null) ...[
                              const SizedBox(height: 12),
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