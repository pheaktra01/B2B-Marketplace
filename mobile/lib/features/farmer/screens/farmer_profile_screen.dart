import 'package:flutter/material.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
import 'package:mobile/features/farmer/widgets/farmer_bottom_nav_bar.dart';

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {

  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color lightGreenBg = Color(0xFFF1F8E9);
  static const Color cardBg = Color(0xFFF7F9F7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FarmerAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Banner & Profile Image Stack
            _buildProfileHeader(),

            const SizedBox(height: 16),

            // 2. Title, Badges, and Action Buttons
            _buildProfileInfo(),

            const SizedBox(height: 20),

            // 3. Key Metrics Bar
            _buildMetricsBar(),

            const SizedBox(height: 24),

            // 4. Management Dashboard Grid
            _buildSectionTitle('Management Dashboard'),
            const SizedBox(height: 12),
            _buildDashboardGrid(),

            const SizedBox(height: 28),

            // 5. Our Sustainable Story Section
            _buildSectionTitle('Our Sustainable Story'),
            const SizedBox(height: 8),
            _buildStorySection(),

            const SizedBox(height: 28),

            // 6. Current Offerings (Products)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Current Offerings'),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View All >',
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Fresh from our Hudson Valley Fields',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoryChips(),
            const SizedBox(height: 16),
            _buildProductGrid(),

            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.orange,
        child: const Icon(Icons.edit_note, color: Colors.white),
      ),
      bottomNavigationBar: const FarmerBottomNavBar(
        currentIndex: 4,
      ),
    );
  }

  // Helper: Profile Banner and Avatar
  Widget _buildProfileHeader() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://via.placeholder.com/600x200'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 12,
                right: 12,
                child: Chip(
                  avatar: const Icon(Icons.share, size: 16, color: Colors.black87),
                  label: const Text('Share'),
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Chip(
                  avatar: const Icon(Icons.edit, size: 16, color: Colors.black87),
                  label: const Text('Edit Cover'),
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -40,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const CircleAvatar(
                  radius: 45,
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper: Profile Details & Actions
  Widget _buildProfileInfo() {
    return Column(
      children: [
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Green Valley Organics',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 6),
            Icon(Icons.verified, color: primaryGreen, size: 20),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.location_on, size: 14, color: Colors.grey),
            Text(' Hudson Valley, NY  •  ', style: TextStyle(color: Colors.grey, fontSize: 13)),
            Icon(Icons.eco, size: 14, color: primaryGreen),
            Text(' Verified Producer', style: TextStyle(color: primaryGreen, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.campaign, size: 18),
              label: const Text('Promote'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_note, size: 18, color: primaryGreen),
              label: const Text('Edit Bio', style: TextStyle(color: primaryGreen)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primaryGreen),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper: 4 Metrics Summary
  Widget _buildMetricsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn('120+', 'ORDERS'),
          _buildDivider(),
          _buildStatColumn('4.9 ★', 'REVIEWS'),
          _buildDivider(),
          _buildStatColumn('2018', 'SINCE'),
          _buildDivider(),
          _buildStatColumn('\$4.2k', 'REVENUE'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 24, width: 1, color: Colors.grey.shade300);
  }

  // Helper: Section Titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper: Dashboard Grid Items
  Widget _buildDashboardGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          _buildDashboardCard(Icons.inventory, 'Manage Inventory'),
          _buildDashboardCard(Icons.shopping_cart, 'View Orders'),
          _buildDashboardCard(Icons.bar_chart, 'Sales Analytics'),
          _buildDashboardCard(Icons.payments, 'Payment Settings'),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: primaryGreen, size: 22),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Story Section
  Widget _buildStorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'At Green Valley Organics, we believe that professional kitchens deserve the highest-grade produce without compromising the health of our soil. We utilize advanced regenerative agriculture techniques...',
            style: TextStyle(color: Colors.black87, height: 1.4, fontSize: 13),
          ),
          const SizedBox(height: 12),
          _buildFeatureTile(Icons.verified_user, 'Certified Organic'),
          _buildFeatureTile(Icons.water_drop, 'Rainwater Irrigation'),
          _buildFeatureTile(Icons.local_shipping, 'Same-Day Sourcing'),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: lightGreenBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SUSTAINABILITY REPORT',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryGreen, letterSpacing: 1),
                ),
                const SizedBox(height: 12),
                _buildProgressRow('Pesticide Free', 1.0, '100%'),
                const SizedBox(height: 10),
                _buildProgressRow('Renewable Energy', 0.85, '85%'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Full Impact Report  >'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryGreen, size: 18),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, double value, String percentText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text(percentText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryGreen)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey.shade300,
          color: primaryGreen,
          minHeight: 6,
        ),
      ],
    );
  }

  // Helper: Category Chips
  Widget _buildCategoryChips() {
    final categories = ['All Harvest', 'Vegetables', 'Herbs', 'Greens'];
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primaryGreen : cardBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              categories[index],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper: Product Grid Cards
  Widget _buildProductGrid() {
    final products = [
      {'name': 'Heirloom Tomatoes', 'category': 'VEGETABLES', 'tag': 'IN STOCK', 'tagColor': primaryGreen},
      {'name': 'Baby Arugula', 'category': 'GREENS', 'tag': 'IN STOCK', 'tagColor': primaryGreen},
      {'name': 'Italian Basil', 'category': 'HERBS', 'tag': 'LOW STOCK', 'tagColor': Colors.orange},
      {'name': 'Rainbow Chard', 'category': 'VEGETABLES', 'tag': 'IN STOCK', 'tagColor': primaryGreen},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final item = products[index];
          return Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        'https://via.placeholder.com/150',
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: item['tagColor'] as Color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item['tag'] as String,
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['category'] as String,
                        style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Live', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Transform.scale(
                            scale: 0.6,
                            child: Switch(
                              value: true,
                              onChanged: (v) {},
                              activeThumbColor: primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        height: 28,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit, size: 12, color: Colors.black87),
                          label: const Text('Edit Listing', style: TextStyle(fontSize: 10, color: Colors.black87)),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}