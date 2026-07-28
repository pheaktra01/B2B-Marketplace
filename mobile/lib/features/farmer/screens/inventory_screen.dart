import 'package:flutter/material.dart';
import 'package:mobile/features/farmer/screens/notifications_screen.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
import 'package:mobile/features/farmer/widgets/farmer_bottom_nav_bar.dart';
import 'package:mobile/features/product/screens/add_product_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = ['ទំនិញទាំងអស់', 'បន្លែ', 'បន្លែពន្លក'];

  // Sample data to match the UI precisely with Khmer text & Western numbers
  final List<Map<String, dynamic>> _inventoryItems = [
    {
      'name': 'ប៉េងប៉ោះបុរាណ',
      'price': '\$4.50',
      'unit': '/គីឡូក្រាម',
      'stockText': 'នៅសល់ 120 គីឡូក្រាម',
      'progress': 0.85,
      'status': 'សកម្ម',
      'statusColor': const Color(0xFF1E5631),
      'progressColor': const Color(0xFF1E5631),
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600',
    },
    {
      'name': 'សាឡាត់ Baby Arugula',
      'price': '\$12.00',
      'unit': '/កេស',
      'stockText': 'នៅសល់ 8 កេស',
      'progress': 0.2,
      'status': 'ស្តុកទាប',
      'statusColor': const Color(0xFFD9534F),
      'progressColor': const Color(0xFFD9534F),
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600',
    },
    {
      'name': 'ការ៉ុតចម្រុះពណ៌',
      'price': '\$3.20',
      'unit': '/គីឡូក្រាម',
      'stockText': 'នៅសល់ 0 គីឡូក្រាម',
      'progress': 0.0,
      'status': 'អសកម្ម',
      'statusColor': Colors.grey,
      'progressColor': Colors.grey,
      'isAvailable': false,
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvkvNcrsOhsZCTUZOu-w7gOezd1Sk2eHM-dYSO6niL28zY5SLuzl0xAU1f&s=10', // Placeholder local asset
    },
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E5631);
    const backgroundColor = Color(0xFFF7F6E8); // Off-white/light yellow tint background

    return Scaffold(
      backgroundColor: backgroundColor,
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
              backgroundImage: NetworkImage('assets/profile.png'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Header Title & Subtitle
            const Text(
              'ការគ្រប់គ្រងស្តុក',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'តាមដានទិន្នផល និងគ្រប់គ្រងកម្រិតការផ្គត់ផ្គង់ផ្ទះបាយរបស់អ្នក។',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),

            // Top Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'ទំនិញសកម្ម',
                    value: '24',
                    valueColor: primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'ស្តុកទាប',
                    value: '3',
                    valueColor: const Color(0xFFB71C1C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'ស្វែងរកស្តុករបស់អ្នក...',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Filter Chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilterIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilterIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[800],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Inventory List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _inventoryItems.length,
              itemBuilder: (context, index) {
                final item = _inventoryItems[index];
                return _buildInventoryCard(item, primaryColor);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // Add Item Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductScreen(), // Placeholder for Add Item Screen
            ),
          );
        },
        backgroundColor: const Color(0xFFB86A04), // Warm accent brown/orange color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: const FarmerBottomNavBar(
        currentIndex: 2,
      ),
    );
  }

  // Widget for Top Metrics (Active Items, Low Stock)
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // Widget for Individual Item Cards
  Widget _buildInventoryCard(Map<String, dynamic> item, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header with Status Tag
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  item['imageUrl'],
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item['status'] == 'ស្តុកទាប') ...[
                        const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFD9534F)),
                        const SizedBox(width: 4),
                      ] else if (item['status'] == 'សកម្ម') ...[
                        const Icon(Icons.circle, size: 8, color: Color(0xFF1E5631)),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        item['status'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: item['statusColor'],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Card Details
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name & Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: item['price'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E5631),
                            ),
                          ),
                          TextSpan(
                            text: item['unit'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Stock Level Label & Progress Bar
                Text(
                  'កម្រិតស្តុក',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: item['progress'],
                    minHeight: 6,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(item['progressColor']),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['stockText'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: item['status'] == 'ស្តុកទាប' ? const Color(0xFFD9534F) : Colors.grey[700],
                  ),
                ),
                const Divider(height: 24, thickness: 1),

                // Toggle Switch & Action Buttons
                Row(
                  children: [
                    Text(
                      'មានលក់',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 8),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: item['isAvailable'],
                        activeThumbColor: primaryColor,
                        onChanged: (val) {
                          setState(() {
                            item['isAvailable'] = val;
                          });
                        },
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.black87),
                      onPressed: () {},
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.black87),
                      onPressed: () {},
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}