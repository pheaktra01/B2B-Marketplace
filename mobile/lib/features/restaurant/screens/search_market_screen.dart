import 'package:flutter/material.dart';
import 'package:mobile/features/restaurant/widgets/restaurant_bottom_nav_bar.dart';

class SearchMarketScreen extends StatefulWidget {
  const SearchMarketScreen({super.key});

  @override
  State<SearchMarketScreen> createState() => _SearchMarketScreenState();
}

class _SearchMarketScreenState extends State<SearchMarketScreen> {
  // Colors matching design
  static const Color primaryGreen = Color(0xFF135A27);
  static const Color lightBg = Color(0xFFF8FAF9);
  static const Color inputBg = Color(0xFFEFF2F1);
  static const Color tagBg = Color(0xFFE8ECE9);
  static const Color organicTagBg = Color(0xFFD8F3DC);
  static const Color topRatedTagBg = Color(0xFFFFEAD5);

  int _selectedTabIndex = 0; // 0: All, 1: Products, 2: Farmers

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Search Bar & Filter Button
              _buildSearchBar(),

              const SizedBox(height: 20),

              // 2. Recent Searches
              _buildRecentSearchesSection(),

              const SizedBox(height: 20),

              // 3. Popular Searches
              _buildPopularSearchesSection(),

              const SizedBox(height: 20),

              // 4. Browse Categories
              _buildBrowseCategoriesSection(),

              const SizedBox(height: 20),

              // 5. Filter Switch Tabs (All / Products / Farmers)
              _buildTabSwitcher(),

              const SizedBox(height: 16),

              // 6. Items Found Count & Sort Dropdown
              _buildResultHeader(),

              const SizedBox(height: 14),

              // 7. Product List Items
              _buildProductCard(
                image: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=400&q=80',
                title: 'Premium Heirloom Tomatoes',
                badgeText: 'ORGANIC',
                badgeBgColor: organicTagBg,
                badgeTextColor: const Color(0xFF2B7A3E),
                price: '\$4.50/kg',
                stockText: '• 450kg in stock',
                farmName: 'Green Valley Farms',
                rating: '4.8',
                isVerified: true,
              ),

              const SizedBox(height: 14),

              _buildProductCard(
                image: 'assets/tomato.jpg',
                title: 'Organic Baby Kale',
                badgeText: 'TOP RATED',
                badgeBgColor: topRatedTagBg,
                badgeTextColor: const Color(0xFFB55D00),
                price: '\$6.20/kg',
                stockText: '• 120kg in stock',
                farmName: 'Riverbend Estates',
                rating: '4.9',
                isVerified: true,
              ),

              const SizedBox(height: 14),

              _buildOutOfStockProductCard(
                image: 'https://images.unsplash.com/photo-1452195100486-9cc805987862?auto=format&fit=crop&w=400&q=80',
                title: 'Artisanal Smoked Cheddar',
                price: '\$12.50/unit',
                statusText: 'Restocking soon',
                farmName: 'Highland Creamery',
                rating: '4.7',
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      // 8. Bottom Navigation Bar attached directly to the Scaffold
      bottomNavigationBar: const RestaurantBottomNavBar(
        currentIndex: 1,
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products or farmers...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Icon(Icons.cancel, color: Colors.grey.shade500, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: primaryGreen,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildRecentSearchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Searches',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Clear All',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryGreen),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChipTag('Heirloom Tomatoes', hasCloseIcon: true),
            _buildChipTag('Organic Kale', hasCloseIcon: true),
          ],
        ),
      ],
    );
  }

  Widget _buildPopularSearchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Searches',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildOutlinedChip('Trending: Wagyu Beef'),
            _buildOutlinedChip('Hydroponic Herbs'),
            _buildOutlinedChip('Artisanal Cheese'),
          ],
        ),
      ],
    );
  }

  Widget _buildBrowseCategoriesSection() {
    final categories = [
      {
        'title': 'Vegetables',
        'icon': Icons.eco_rounded,
        'bgColor': const Color(0xFFEAF5EA),
        'accentColor': const Color(0xFF2D6A4F),
      },
      {
        'title': 'Fruits',
        'icon': Icons.apple_rounded,
        'bgColor': const Color(0xFFFFF3E0),
        'accentColor': const Color(0xFFE65100),
      },
      {
        'title': 'Meat',
        'icon': Icons.set_meal_rounded,
        'bgColor': const Color(0xFFFFEBEE),
        'accentColor': const Color(0xFFC62828),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Browse Categories',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: -0.2,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'See All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: categories.map((cat) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _buildCategoryTile(
                  title: cat['title'] as String,
                  icon: cat['icon'] as IconData,
                  bgColor: cat['bgColor'] as Color,
                  accentColor: cat['accentColor'] as Color,
                  onTap: () {
                    // Handle category selection
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryTile({
    required String title,
    required IconData icon,
    required Color bgColor,
    required Color accentColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Inner soft white badge container behind the icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withValues(alpha: 0.8),
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'All'),
          _buildTabItem(1, 'Products'),
          _buildTabItem(2, 'Farmers'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '124 items found',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
        Row(
          children: const [
            Text(
              'Sort By: Relevancy',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryGreen),
            ),
            SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down, color: primaryGreen, size: 18),
          ],
        ),
      ],
    );
  }

  Widget _buildProductCard({
    required String image,
    required String title,
    required String badgeText,
    required Color badgeBgColor,
    required Color badgeTextColor,
    required String price,
    required String stockText,
    required String farmName,
    required String rating,
    required bool isVerified,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      image,
                      width: 95,
                      height: 95,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border, size: 14, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: badgeTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          stockText,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 10,
                          backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80'),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            farmName,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified) ...[
                          const Icon(Icons.verified, size: 14, color: primaryGreen),
                          const SizedBox(width: 4),
                        ],
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          rating,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 16),
                    label: const Text(
                      'Add to Cart',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.remove_red_eye_outlined, color: Colors.black87, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutOfStockProductCard({
    required String image,
    required String title,
    required String price,
    required String statusText,
    required String farmName,
    required String rating,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      image,
                      width: 95,
                      height: 95,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    width: 95,
                    height: 95,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'OUT OF\nSTOCK',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          price,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                        ),
                        const Spacer(),
                        Text(
                          statusText,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFC85A5A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            farmName,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          rating,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8D9991),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Notify Me',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipTag(String label, {bool hasCloseIcon = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tagBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          if (hasCloseIcon) ...[
            const SizedBox(width: 6),
            Icon(Icons.close, size: 14, color: Colors.grey.shade700),
          ],
        ],
      ),
    );
  }

  Widget _buildOutlinedChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade800),
      ),
    );
  }
}