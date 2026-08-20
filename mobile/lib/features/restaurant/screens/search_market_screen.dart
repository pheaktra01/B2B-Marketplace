import 'package:flutter/material.dart';
import 'package:mobile/features/product/screens/product_card.dart';
import 'package:mobile/features/product/screens/product_detail_screen.dart';
import 'package:mobile/features/product/services/product_service.dart';
import 'package:mobile/features/restaurant/widgets/restaurant_bottom_nav_bar.dart';

class SearchMarketScreen extends StatefulWidget {
  const SearchMarketScreen({super.key});

  @override
  State<SearchMarketScreen> createState() =>
      _SearchMarketScreenState();
}

class _SearchMarketScreenState extends State<SearchMarketScreen> {
  static const Color primaryGreen = Color(0xFF135A27);
  static const Color lightBg = Color(0xFFF8FAF9);
  static const Color inputBg = Color(0xFFEFF2F1);
  static const Color tagBg = Color(0xFFE8ECE9);

  int _selectedTabIndex = 0;

  final TextEditingController _searchController =
      TextEditingController();

  List<Map<String, dynamic>> _products = [];

  bool _isLoading = true;
  String? _errorMessage;

  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Meat',
    'Seafood',
    'Herbs & Spices',
  ];

  @override
  void initState() {
    super.initState();

    _loadProducts();

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================================
  // LOAD PRODUCTS FROM BACKEND
  // ==========================================================

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ProductService.getAllProducts();

      if (!mounted) return;

      setState(() {
        _products = data
            .map(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();

        _isLoading = false;
      });

      debugPrint('========== MARKET PRODUCTS ==========');
      debugPrint('Products loaded: ${_products.length}');
      debugPrint('=====================================');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      debugPrint('Load products error: $e');
    }
  }

  // ==========================================================
  // SEARCH + FILTER
  // ==========================================================

  List<Map<String, dynamic>> get _filteredProducts {
    final searchText =
        _searchController.text.trim().toLowerCase();

    return _products.where((product) {
      // ------------------------------------------------------
      // Category filter
      // ------------------------------------------------------

      final category =
          product['category']?.toString() ?? '';

      final categoryMatches =
          _selectedCategory == 'All' ||
          category.toLowerCase() ==
              _selectedCategory.toLowerCase();

      if (!categoryMatches) {
        return false;
      }

      // ------------------------------------------------------
      // Search filter
      // ------------------------------------------------------

      if (searchText.isEmpty) {
        return true;
      }

      final name =
          product['name']?.toString().toLowerCase() ?? '';

      final farmerName =
          product['farmerName']?.toString().toLowerCase() ?? '';

      final farmName =
          product['farmName']?.toString().toLowerCase() ?? '';

      final productCategory =
          product['category']?.toString().toLowerCase() ?? '';

      final description =
          product['description']?.toString().toLowerCase() ?? '';

      return name.contains(searchText) ||
          farmerName.contains(searchText) ||
          farmName.contains(searchText) ||
          productCategory.contains(searchText) ||
          description.contains(searchText);
    }).toList();
  }

  // ==========================================================
  // PRICE
  // ==========================================================

  String _formatPrice(dynamic value) {
    double? price;

    if (value is num) {
      price = value.toDouble();
    } else {
      price = double.tryParse(
        value?.toString() ?? '',
      );
    }

    if (price == null) {
      return '\$0.00/kg';
    }

    return '\$${price.toStringAsFixed(2)}/kg';
  }

  // ==========================================================
  // STOCK
  // ==========================================================

  String _formatStock(dynamic value) {
    double? quantity;

    if (value is num) {
      quantity = value.toDouble();
    } else {
      quantity = double.tryParse(
        value?.toString() ?? '',
      );
    }

    if (quantity == null) {
      return '0 kg';
    }

    if (quantity % 1 == 0) {
      return '${quantity.toInt()} kg';
    }

    return '${quantity.toStringAsFixed(1)} kg';
  }

  // ==========================================================
  // FARMER NAME
  // ==========================================================

  String _getFarmerName(
    Map<String, dynamic> product,
  ) {
    return product['farmerName']?.toString() ??
        product['farmName']?.toString() ??
        product['farmer']?['name']?.toString() ??
        'Farmer';
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProducts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // SEARCH
                _buildSearchBar(),

                const SizedBox(height: 20),

                // RECENT SEARCHES
                _buildRecentSearchesSection(),

                const SizedBox(height: 20),

                // POPULAR SEARCHES
                _buildPopularSearchesSection(),

                const SizedBox(height: 20),

                // CATEGORIES
                _buildBrowseCategoriesSection(),

                const SizedBox(height: 20),

                // ALL / PRODUCTS / FARMERS
                _buildTabSwitcher(),

                const SizedBox(height: 16),

                // RESULTS
                _buildResultHeader(),

                const SizedBox(height: 14),

                // PRODUCTS
                _buildProductsSection(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar:
          const RestaurantBottomNavBar(
        currentIndex: 1,
      ),
    );
  }

  // ==========================================================
  // SEARCH BAR
  // ==========================================================

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            padding:
                const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius:
                  BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Colors.grey.shade600,
                  size: 20,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration:
                        InputDecoration(
                      hintText:
                          'Search products or farmers...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color:
                            Colors.grey.shade600,
                      ),
                      border:
                          InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.zero,
                    ),
                  ),
                ),

                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                    },
                    child: Icon(
                      Icons.cancel,
                      color:
                          Colors.grey.shade500,
                      size: 18,
                    ),
                  ),
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
            borderRadius:
                BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.tune_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // RECENT SEARCHES
  // ==========================================================

  Widget _buildRecentSearchesSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            GestureDetector(
              onTap: () {},
              child: const Text(
                'Clear All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChipTag(
              'Tomatoes',
              hasCloseIcon: true,
            ),
            _buildChipTag(
              'Organic Kale',
              hasCloseIcon: true,
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // POPULAR SEARCHES
  // ==========================================================

  Widget _buildPopularSearchesSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Searches',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildOutlinedChip(
              'Fresh Vegetables',
            ),
            _buildOutlinedChip(
              'Fruits',
            ),
            _buildOutlinedChip(
              'Local Farmers',
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // CATEGORIES
  // ==========================================================

  Widget _buildBrowseCategoriesSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Browse Categories',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = 'All';
                });
              },
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
          children: [
            _buildCategoryTile(
              title: 'Vegetables',
              icon: Icons.eco_rounded,
              bgColor:
                  const Color(0xFFEAF5EA),
              accentColor:
                  const Color(0xFF2D6A4F),
            ),

            _buildCategoryTile(
              title: 'Fruits',
              icon: Icons.apple_rounded,
              bgColor:
                  const Color(0xFFFFF3E0),
              accentColor:
                  const Color(0xFFE65100),
            ),

            _buildCategoryTile(
              title: 'Meat',
              icon: Icons.set_meal_rounded,
              bgColor:
                  const Color(0xFFFFEBEE),
              accentColor:
                  const Color(0xFFC62828),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryTile({
    required String title,
    required IconData icon,
    required Color bgColor,
    required Color accentColor,
  }) {
    final selected =
        _selectedCategory.toLowerCase() ==
            title.toLowerCase();

    return Expanded(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 4,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius:
                BorderRadius.circular(16),
            onTap: () {
              setState(() {
                _selectedCategory = title;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 8,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? accentColor.withValues(
                        alpha: 0.18,
                      )
                    : bgColor,
                borderRadius:
                    BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? accentColor
                      : accentColor.withValues(
                          alpha: 0.12,
                        ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(
                      color: Colors.white
                          .withValues(
                        alpha: 0.85,
                      ),
                      shape: BoxShape.circle,
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
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          Colors.black.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // TAB SWITCHER
  // ==========================================================

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius:
            BorderRadius.circular(12),
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

  Widget _buildTabItem(
    int index,
    String label,
  ) {
    final isSelected =
        _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryGreen
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected
                  ? FontWeight.bold
                  : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // RESULT HEADER
  // ==========================================================

  Widget _buildResultHeader() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_filteredProducts.length} items found',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),

        Row(
          children: const [
            Text(
              'Sort By: Relevancy',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down,
              color: primaryGreen,
              size: 18,
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // PRODUCT SECTION
  // ==========================================================

  Widget _buildProductsSection() {
    // Loading
    if (_isLoading) {
      return const Padding(
        padding:
            EdgeInsets.symmetric(
          vertical: 60,
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: primaryGreen,
          ),
        ),
      );
    }

    // Error
    if (_errorMessage != null) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 45,
            ),

            const SizedBox(height: 12),

            const Text(
              'Unable to load products',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    Colors.grey.shade600,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _loadProducts,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryGreen,
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Empty
    if (_filteredProducts.isEmpty) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(
          vertical: 50,
        ),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 50,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 12),

            const Text(
              'No products found',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Try another search or category.',
              style: TextStyle(
                color:
                    Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    // --------------------------------------------------------
    // Products
    // --------------------------------------------------------

    return Column(
      children: _filteredProducts.map(
        (product) {
          final farmerName =
              _getFarmerName(product);

          return Padding(
            padding:
                const EdgeInsets.only(
              bottom: 14,
            ),
            child: ProductCard(
              imageUrl:
                  product['imageBase64']
                          ?.toString() ??
                      '',

              productName:
                  product['name']
                          ?.toString() ??
                      'Unnamed Product',

              farmName: farmerName,

              price:
                  _formatPrice(
                product['price'],
              ),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductDetailScreen(
                      product: product,
                    ),
                  ),
                );
              },

              onFavoritePressed: () {
                debugPrint(
                  'Favorite: ${product['name']}',
                );
              },

              onAddToCart: () {
                debugPrint(
                  'Add to cart: ${product['name']}',
                );
              },
            ),
          );
        },
      ).toList(),
    );
  }

  // ==========================================================
  // CHIP
  // ==========================================================

  Widget _buildChipTag(
    String label, {
    bool hasCloseIcon = false,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: tagBg,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          if (hasCloseIcon) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.close,
              size: 14,
              color:
                  Colors.grey.shade700,
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================
  // OUTLINED CHIP
  // ==========================================================

  Widget _buildOutlinedChip(
    String label,
  ) {
    return GestureDetector(
      onTap: () {
        _searchController.text =
            label;
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color:
                Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w500,
            color:
                Colors.grey.shade800,
          ),
        ),
      ),
    );
  }
}