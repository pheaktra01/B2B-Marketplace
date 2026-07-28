import 'package:flutter/material.dart';
import 'package:mobile/features/farmer/screens/notifications_screen.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
import 'package:mobile/features/farmer/widgets/farmer_bottom_nav_bar.dart';

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  // Matching colors directly from the mock
  static const Color primaryGreen = Color(0xFF135A27);
  static const Color pageBgColor = Color(0xFFF4F6F4);
  static const Color cardBgColor = Color(0xFFF7F8F7);
  static const Color badgeBgColor = Color(0xFFEDF2EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBgColor,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Banner & Profile Image
            _buildProfileHeader(),

            const SizedBox(height: 12),

            // 2. Title, Badges, and Action Buttons
            _buildProfileInfo(),

            const SizedBox(height: 20),

            // 3. Key Metrics Bar
            _buildMetricsBar(),

            const SizedBox(height: 24),

            // 4. Management Dashboard Grid
            _buildSectionTitle('ផ្ទាំងគ្រប់គ្រង'),
            const SizedBox(height: 12),
            _buildDashboardGrid(),

            const SizedBox(height: 28),

            // 5. Our Sustainable Story Section
            _buildSectionTitle('រឿងរ៉ាវនិរន្តរភាពរបស់យើង'),
            const SizedBox(height: 12),
            _buildStorySection(),

            const SizedBox(height: 28),

            // 6. Current Offerings (Products)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    'ផលិតផលបច្ចុប្បន្ន',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'មើលទាំងអស់ >',
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'ស្រស់ៗពីកសិដ្ឋាន Hudson Valley របស់យើង',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            const SizedBox(height: 14),
            _buildCategoryChips(),
            const SizedBox(height: 16),
            _buildProductGrid(),

            const SizedBox(height: 24),

            // Duplicate Dashboard Section (as shown at the bottom of the image)
            _buildSectionTitle('ផ្ទាំងគ្រប់គ្រង'),
            const SizedBox(height: 12),
            _buildDashboardGrid(),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const FarmerBottomNavBar(
        currentIndex: 4,
      ),
    );
  }

  // Helper: Profile Banner and Avatar Stack with Gradient Fade
  Widget _buildProfileHeader() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Cover Image with Bottom Fade Gradient
        Container(
          height: 190,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('assets/farm.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              // Bottom gradient to blend into page color
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        pageBgColor.withValues(alpha: 0.8),
                        pageBgColor,
                      ],
                      stops: const [0.5, 0.85, 1.0],
                    ),
                  ),
                ),
              ),
              // Top Right Action Buttons
              Positioned(
                top: 12,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.share, size: 14, color: Colors.black87),
                      SizedBox(width: 6),
                      Text('ចែករំលែក', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 14, color: Colors.black87),
                      SizedBox(width: 6),
                      Text('កែប្រែរូបគម្រប', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Avatar with Camera Icon
        Positioned(
          bottom: -35,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 46,
                  backgroundImage: NetworkImage('assets/profile.png'),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper: Title, Badges, and Buttons
  Widget _buildProfileInfo() {
    return Column(
      children: [
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Green Valley Organics',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.check_circle, color: primaryGreen, size: 20),
          ],
        ),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_outlined, size: 15, color: Colors.grey),
            SizedBox(width: 2),
            Text(
              'Hudson Valley, NY  •  ',
              style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Icon(Icons.verified, size: 15, color: primaryGreen),
            SizedBox(width: 3),
            Text(
              'អ្នកផលិតផ្លូវការ',
              style: TextStyle(color: primaryGreen, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.campaign_outlined, size: 18, color: Colors.white),
              label: const Text(
                'ផ្សព្វផ្សាយ',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined, size: 18, color: primaryGreen),
              label: const Text(
                'កែប្រែប្រវត្តិរូប',
                style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: primaryGreen, width: 1.2),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper: 4 Metrics Box
  Widget _buildMetricsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn('120+', 'ការកុម្ម៉ង់'),
          _buildDivider(),
          _buildStatColumn('4.9 ★', 'ការវាយតម្លៃ'),
          _buildDivider(),
          _buildStatColumn('2018', 'ចាប់តាំងពី'),
          _buildDivider(),
          _buildStatColumn('\$4.2k', 'ចំណូល'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryGreen),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 24, width: 1, color: Colors.grey.shade200);
  }

  // Helper: Section Titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
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
        childAspectRatio: 2.3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          _buildDashboardCard(Icons.inventory_2_outlined, 'គ្រប់គ្រងស្តុក'),
          _buildDashboardCard(Icons.shopping_cart_outlined, 'មើលការកុម្ម៉ង់'),
          _buildDashboardCard(Icons.insert_chart_outlined, 'ការវិភាគការលក់'),
          _buildDashboardCard(Icons.credit_card_outlined, 'ការកំណត់ការទូទាត់'),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryGreen, size: 20),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
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
          Text(
            'នៅ Green Valley Organics យើងជឿជាក់ថាផ្ទះបាយអាជីពសក្តិសមទទួលបានបន្លែផ្លែឈើគុណភាពខ្ពស់បំផុត ដោយមិនប៉ះពាល់ដល់សុខភាពដីរបស់យើង។ យើងប្រើប្រាស់បច្ចេកទេសកសិកម្មកែប្រែឡើងវិញកម្រិតខ្ពស់ រួមទាំងការរក្សាទុកកាបូន និងជីកំប៉ុសជីវៈ ដើម្បីធានាថាគ្រប់ស្លឹក និងឫសពោរពេញដោយរសជាតិ។',
            style: TextStyle(color: Colors.grey.shade800, height: 1.4, fontSize: 13),
          ),
          const SizedBox(height: 14),
          _buildFeatureTile(Icons.eco_outlined, 'ទទួលស្គាល់ជាសរីរាង្គ'),
          _buildFeatureTile(Icons.water_drop_outlined, 'ប្រព័ន្ធស្រោចស្រពទឹកភ្លៀង'),
          _buildFeatureTile(Icons.local_shipping_outlined, 'ការផ្គត់ផ្គង់ភ្លាមៗក្នុងថ្ងៃ'),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'របាយការណ៍និរន្តរភាព',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 14),
                _buildProgressRow('គ្មានថ្នាំកសិកម្ម', 1.0, '100%'),
                const SizedBox(height: 12),
                _buildProgressRow('ថាមពលកកើតឡើងវិញ', 0.85, '85%'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('របាយការណ៍ផលប៉ះពាល់ពេញលេញ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                      ],
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: badgeBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryGreen, size: 16),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
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
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade200,
            color: primaryGreen,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  // Helper: Category Chips
  Widget _buildCategoryChips() {
    final categories = ['ទិន្នផលទាំងអស់', 'បន្លែ', 'គ្រឿងទេស', 'បន្លែស្លឹក'];
    return SizedBox(
      height: 34,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primaryGreen : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              categories[index],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
      {'name': 'ប៉េងប៉ោះបុរាណ', 'category': 'បន្លែ', 'tag': 'មានក្នុងស្តុក', 'tagColor': primaryGreen},
      {'name': 'ស្ពៃ Arugula', 'category': 'បន្លែស្លឹក', 'tag': 'មានក្នុងស្តុក', 'tagColor': primaryGreen},
      {'name': 'ជីរនាងវង អ៊ីតាលី', 'category': 'គ្រឿងទេស', 'tag': 'ស្តុកតិច', 'tagColor': Colors.orange.shade800},
      {'name': 'ស្ពៃចោមស្វាយ', 'category': 'បន្លែ', 'tag': 'មានក្នុងស្តុក', 'tagColor': primaryGreen},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final item = products[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        'assets/tomato.jpg',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item['tagColor'] as Color,
                          borderRadius: BorderRadius.circular(12),
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
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['category'] as String,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ផ្សាយផ្ទាល់', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                          SizedBox(
                            height: 24,
                            child: Transform.scale(
                              scale: 0.7,
                              child: Switch(
                                value: true,
                                onChanged: (v) {},
                                activeTrackColor: primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit_outlined, size: 12, color: Colors.black87),
                          label: const Text('កែប្រែបញ្ជី', style: TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: cardBgColor,
                            padding: EdgeInsets.zero,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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