import 'package:flutter/material.dart';
import 'package:mobile/features/farmer/screens/notifications_screen.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
import 'package:mobile/features/farmer/widgets/farmer_bottom_nav_bar.dart';
import 'package:mobile/l10n/app_localizations.dart';

class FarmerOrderManagementScreen extends StatefulWidget {
  const FarmerOrderManagementScreen({super.key});

  @override
  State<FarmerOrderManagementScreen> createState() =>
      _FarmerOrderManagementScreenState();
}

class _FarmerOrderManagementScreenState
    extends State<FarmerOrderManagementScreen> {
  int _selectedFilterIndex = 0;

  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color accentOrange = Color(0xFFFF8F00);
  static const Color pageBg = Color(0xFFF7F9F7);
  static const Color cardBg = Colors.white;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<String> filters = [
      l10n.allOrders,
      l10n.pending,
      l10n.accepted,
      l10n.preparing,
    ];

    return Scaffold(
      backgroundColor: pageBg,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: FarmerAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),

          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/profile.png'),
            ),
          ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // ======================================================
          // TITLE + ACTIVE BADGE
          // ======================================================

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.orderManagement,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '24 ${l10n.active}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ======================================================
          // FILTER CHIPS
          // ======================================================

          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedFilterIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilterIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryGreen
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      filters[index],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.black87,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // ======================================================
          // ORDERS LIST
          // ======================================================

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // ==================================================
                // ORDER 1 - PENDING
                // ==================================================

                _buildOrderCard(
                  l10n: l10n,
                  customerName: 'The Grand Bistro',
                  orderId: '#VRD-9821',
                  timeAgo: l10n.fiveMinutesAgo,
                  status: l10n.pending,
                  statusBgColor: const Color(0xFFA0520D),
                  itemsText:
                      '${l10n.heirloomTomatoes}, ${l10n.babyArugula} + 2 ${l10n.more}',
                  itemCountText: '24 ${l10n.cases}',
                  fulfillmentType: l10n.delivery,
                  fulfillmentTime: '10:00 AM',
                  price: '\$420.00',
                  actionButtons: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.grey.shade400,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            l10n.decline,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentOrange,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            l10n.accept,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // ORDER 2 - ACCEPTED
                // ==================================================

                _buildOrderCard(
                  l10n: l10n,
                  customerName: 'Green Plate Kitchen',
                  orderId: '#VRD-9742',
                  timeAgo: 'Oct 27, 2:15 PM',
                  status: l10n.accepted,
                  statusBgColor: const Color(0xFFC3D0A8),
                  statusTextColor: const Color(0xFF2E3D12),
                  itemsText:
                      '${l10n.microgreensMix}, ${l10n.rainbowCarrots}',
                  itemCountText: '12 ${l10n.cases}',
                  fulfillmentType: l10n.pickup,
                  fulfillmentTime: '11:30 AM',
                  price: '\$185.50',
                  actionButtons: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        l10n.startPreparing,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // ORDER 3 - PREPARING
                // ==================================================

                _buildOrderCard(
                  l10n: l10n,
                  customerName: 'Azure Fine Dining',
                  orderId: '#VRD-9610',
                  timeAgo: 'Oct 27, 1:40 PM',
                  status: l10n.preparing,
                  statusBgColor: const Color(0xFF2E6930),
                  itemsText:
                      '${l10n.naturalHoney}, ${l10n.sourdoughStarterKit} + 5 ${l10n.more}',
                  itemCountText: '40 ${l10n.items}',
                  fulfillmentType: l10n.delivery,
                  fulfillmentTime: '09:00 AM',
                  price: '\$1,120.00',
                  actionButtons: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: primaryGreen,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        l10n.markAsReady,
                        style: const TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // ORDER 4 - READY
                // ==================================================

                _buildOrderCard(
                  l10n: l10n,
                  customerName: 'The Rustic Table',
                  orderId: '#VRD-9588',
                  timeAgo: 'Oct 27, 11:20 AM',
                  status: l10n.ready,
                  statusBgColor: primaryGreen,
                  isHighlighted: true,
                  itemsText:
                      '${l10n.butterheadLettuce}, ${l10n.freshMint}',
                  itemCountText: '32 ${l10n.cases}',
                  fulfillmentType: l10n.readyForPickup,
                  fulfillmentTime: '',
                  price: '\$340.25',
                  hasCheckIcon: true,
                  actionButtons: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        l10n.completeOrder,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),

      // ==========================================================
      // BOTTOM NAVIGATION
      // ==========================================================

      bottomNavigationBar: const FarmerBottomNavBar(
        currentIndex: 1,
      ),
    );
  }

  // ==========================================================
  // ORDER CARD
  // ==========================================================

  Widget _buildOrderCard({
    required AppLocalizations l10n,
    required String customerName,
    required String orderId,
    required String timeAgo,
    required String status,
    required Color statusBgColor,
    Color statusTextColor = Colors.white,
    required String itemsText,
    required String itemCountText,
    required String fulfillmentType,
    required String fulfillmentTime,
    required String price,
    required Widget actionButtons,
    bool isHighlighted = false,
    bool hasCheckIcon = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted
              ? const Color(0xFF81C784)
              : Colors.grey.shade200,
          width: isHighlighted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // HEADER
          // ======================================================

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Row(
                      children: [
                        Text(
                          orderId,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                            fontSize: 13,
                          ),
                        ),

                        Flexible(
                          child: Text(
                            ' • $timeAgo',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ======================================================
          // ITEMS
          // ======================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                hasCheckIcon
                    ? Icons.check_circle_outline
                    : Icons.shopping_bag_outlined,
                size: 18,
                color: hasCheckIcon
                    ? primaryGreen
                    : Colors.grey.shade600,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  itemsText,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ======================================================
          // META INFORMATION
          // ======================================================

          Row(
            children: [
              const SizedBox(width: 26),

              Icon(
                Icons.inventory_2_outlined,
                size: 14,
                color: Colors.grey.shade600,
              ),

              const SizedBox(width: 4),

              Text(
                itemCountText,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),

              const SizedBox(width: 16),

              Icon(
                fulfillmentType.contains(l10n.pickup)
                    ? Icons.local_shipping_outlined
                    : Icons.access_time,
                size: 14,
                color: fulfillmentType.contains(l10n.ready)
                    ? primaryGreen
                    : Colors.grey.shade600,
              ),

              const SizedBox(width: 4),

              Expanded(
                child: Text(
                  fulfillmentTime.isNotEmpty
                      ? '$fulfillmentType: $fulfillmentTime'
                      : fulfillmentType,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fulfillmentType.contains(l10n.ready)
                        ? primaryGreen
                        : Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: fulfillmentType.contains(l10n.ready)
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),

          // ======================================================
          // DIVIDER
          // ======================================================

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),

          // ======================================================
          // PRICE + ACTION
          // ======================================================

          Row(
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: actionButtons,
              ),
            ],
          ),
        ],
      ),
    );
  }
}