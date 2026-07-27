import 'package:flutter/material.dart';
import 'package:mobile/features/farmer/widgets/farmer_bottom_nav_bar.dart';

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

  final List<String> filters = [
    'All Orders',
    'Pending',
    'Accepted',
    'Preparing'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: const [
            Icon(Icons.agriculture, color: primaryGreen, size: 24),
            SizedBox(width: 8),
            Text(
              'Verdant',
              style: TextStyle(
                color: primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0, left: 4.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // 1. Title Bar & Active Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Management',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '24 active',
                    style: TextStyle(
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

          // 2. Filter Chips Horizontal List
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
                        horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryGreen : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      filters[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 3. Orders List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Order 1: Pending
                _buildOrderCard(
                  customerName: 'The Grand Bistro',
                  orderId: '#VRD-9821',
                  timeAgo: '5 mins ago',
                  status: 'PENDING',
                  statusBgColor: const Color(0xFFA0520D),
                  itemsText: 'Heirloom Tomatoes, Baby Arugula + 2 more',
                  itemCountText: '24 units',
                  fulfillmentType: 'Delivery',
                  fulfillmentTime: '10:00 AM',
                  price: '\$420.00',
                  actionButtons: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Decline',
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold)),
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
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Accept',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Order 2: Accepted
                _buildOrderCard(
                  customerName: 'Green Plate Kitchen',
                  orderId: '#VRD-9742',
                  timeAgo: 'Oct 27, 2:15 PM',
                  status: 'ACCEPTED',
                  statusBgColor: const Color(0xFFC3D0A8),
                  statusTextColor: const Color(0xFF2E3D12),
                  itemsText: 'Microgreens Mix, Rainbow Carrots (Bulk)',
                  itemCountText: '12 cases',
                  fulfillmentType: 'Pickup',
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
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Start Preparing',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),

                // Order 3: Preparing
                _buildOrderCard(
                  customerName: 'Azure Fine Dining',
                  orderId: '#VRD-9610',
                  timeAgo: 'Oct 27, 1:40 PM',
                  status: 'PREPARING',
                  statusBgColor: const Color(0xFF2E6930),
                  itemsText: 'Organic Honey, Sourdough Starter Kit + 5 more',
                  itemCountText: '40 items',
                  fulfillmentType: 'Delivery',
                  fulfillmentTime: '09:00 AM',
                  price: '\$1,120.00',
                  actionButtons: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryGreen, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Mark as Ready',
                          style: TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),

                // Order 4: Ready (With Green Border Outline)
                _buildOrderCard(
                  customerName: 'The Rustic Table',
                  orderId: '#VRD-9588',
                  timeAgo: 'Oct 27, 11:20 AM',
                  status: 'READY',
                  statusBgColor: primaryGreen,
                  isHighlighted: true,
                  itemsText: 'Butterhead Lettuce (30 heads), Fresh Mint Bunch',
                  itemCountText: '32 units',
                  fulfillmentType: 'Pickup Ready',
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
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Complete Order',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const FarmerBottomNavBar(
        currentIndex: 1,
      ),
    );
  }

  // Card Reusable Widget
  Widget _buildOrderCard({
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
          color: isHighlighted ? const Color(0xFF81C784) : Colors.grey.shade200,
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
          // Row 1: Header (Name, ID, Time, Status)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
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
                      Text(
                        ' • $timeAgo',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

          // Row 2: Items text with Shopping Bag / Check Icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                hasCheckIcon ? Icons.check_circle_outline : Icons.shopping_bag_outlined,
                size: 18,
                color: hasCheckIcon ? primaryGreen : Colors.grey.shade600,
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

          // Row 3: Meta details (Units count, Delivery / Pickup method)
          Row(
            children: [
              const SizedBox(width: 26),
              Icon(Icons.inventory_2_outlined, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                itemCountText,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
              const SizedBox(width: 16),
              Icon(
                fulfillmentType.contains('Pickup')
                    ? Icons.local_shipping_outlined
                    : Icons.access_time,
                size: 14,
                color: fulfillmentType.contains('Ready')
                    ? primaryGreen
                    : Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                fulfillmentTime.isNotEmpty
                    ? '$fulfillmentType: $fulfillmentTime'
                    : fulfillmentType,
                style: TextStyle(
                  color: fulfillmentType.contains('Ready')
                      ? primaryGreen
                      : Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: fulfillmentType.contains('Ready')
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),

          // Row 4: Price & Action Buttons
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
              Expanded(child: actionButtons),
            ],
          ),
        ],
      ),
    );
  }
}