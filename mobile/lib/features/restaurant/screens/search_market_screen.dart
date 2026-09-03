import 'package:flutter/material.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/cart/services/cart_service.dart';
import 'package:mobile/features/product/screens/product_card.dart';
import 'package:mobile/features/product/screens/product_detail_screen.dart';
import 'package:mobile/features/product/services/product_service.dart';
import 'package:mobile/features/restaurant/services/search_service.dart';
import 'package:mobile/features/restaurant/widgets/restaurant_bottom_nav_bar.dart';

class SearchMarketScreen extends StatefulWidget {
  const SearchMarketScreen({super.key});

  @override
  State<SearchMarketScreen> createState() => _SearchMarketScreenState();
}

class _SearchMarketScreenState extends State<SearchMarketScreen> {
  static const Color primaryGreen = Color(0xFF135A27);
  static const Color lightBg = Color(0xFFF8FAF9);
  static const Color inputBg = Color(0xFFEFF2F1);
  static const Color tagBg = Color(0xFFE8ECE9);

  int _selectedTabIndex = 0;

  final CartService _cartService = CartService();
  final SearchService _searchService = SearchService();

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _products = [];

  bool _isLoading = true;
  String? _errorMessage;

  String _selectedCategory = 'All';
  final List<String> _recentSearches = [];
  bool _onlyAvailable = false;
  String _sortBy = 'relevance';

  @override
  void initState() {
    super.initState();

    _loadProducts();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() => setState(() {});

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
            .map((item) => Map<String, dynamic>.from(item))
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
    final filtered = _searchService.filterProducts(
      products: _products,
      query: _searchController.text,
      category: _selectedCategory,
      tabIndex: _selectedTabIndex,
    );

    final result = _onlyAvailable
        ? filtered.where((product) => product['isAvailable'] == true).toList()
        : filtered;
    if (_sortBy == 'price_low') {
      result.sort(
        (a, b) => _toNumber(a['price']).compareTo(_toNumber(b['price'])),
      );
    } else if (_sortBy == 'price_high') {
      result.sort(
        (a, b) => _toNumber(b['price']).compareTo(_toNumber(a['price'])),
      );
    }
    return result;
  }

  double _toNumber(dynamic value) => double.tryParse(value.toString()) ?? 0;

  void _addRecentSearch(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 5) _recentSearches.removeLast();
    });
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Available products only'),
                  value: _onlyAvailable,
                  onChanged: (value) {
                    setSheetState(() => _onlyAvailable = value);
                    setState(() {});
                  },
                ),
                DropdownButtonFormField<String>(
                  initialValue: _sortBy,
                  decoration: const InputDecoration(labelText: 'Sort by'),
                  items: const [
                    DropdownMenuItem(
                      value: 'relevance',
                      child: Text('Relevance'),
                    ),
                    DropdownMenuItem(
                      value: 'price_low',
                      child: Text('Price: low to high'),
                    ),
                    DropdownMenuItem(
                      value: 'price_high',
                      child: Text('Price: high to low'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setSheetState(() => _sortBy = value);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // PRICE
  // ==========================================================

  String _formatPrice(dynamic value) {
    double? price;

    if (value is num) {
      price = value.toDouble();
    } else {
      price = double.tryParse(value?.toString() ?? '');
    }

    if (price == null) {
      return '\$0.00/kg';
    }

    return '\$${price.toStringAsFixed(2)}/kg';
  }

  // ==========================================================
  // FARMER NAME
  // ==========================================================

  String _getFarmerName(Map<String, dynamic> product) {
    final publisher = product['publisher'];
    if (publisher is Map && publisher['name'] != null) {
      return publisher['name'].toString();
    }
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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

      bottomNavigationBar: const RestaurantBottomNavBar(currentIndex: 1),
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
                    controller: _searchController,
                    onSubmitted: _addRecentSearch,
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

                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                    },
                    child: Icon(
                      Icons.cancel,
                      color: Colors.grey.shade500,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        GestureDetector(
          onTap: _showFilters,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 20,
            ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              onTap: () => setState(_recentSearches.clear),
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

        if (_recentSearches.isEmpty)
          Text(
            'No recent searches',
            style: TextStyle(color: Colors.grey.shade600),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((search) {
              return GestureDetector(
                onTap: () => setState(() => _searchController.text = search),
                child: _buildChipTag(search, hasCloseIcon: true),
              );
            }).toList(),
          ),
      ],
    );
  }

  // ==========================================================
  // POPULAR SEARCHES
  // ==========================================================

  Widget _buildPopularSearchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            _buildOutlinedChip('Fresh Vegetables'),
            _buildOutlinedChip('Fruits'),
            _buildOutlinedChip('Local Farmers'),
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
              bgColor: const Color(0xFFEAF5EA),
              accentColor: const Color(0xFF2D6A4F),
            ),

            _buildCategoryTile(
              title: 'Fruits',
              icon: Icons.apple_rounded,
              bgColor: const Color(0xFFFFF3E0),
              accentColor: const Color(0xFFE65100),
            ),

            _buildCategoryTile(
              title: 'Meat',
              icon: Icons.set_meal_rounded,
              bgColor: const Color(0xFFFFEBEE),
              accentColor: const Color(0xFFC62828),
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
    final selected = _selectedCategory.toLowerCase() == title.toLowerCase();

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                _selectedCategory = title;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: selected ? accentColor.withValues(alpha: 0.18) : bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? accentColor
                      : accentColor.withValues(alpha: 0.12),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: accentColor, size: 24),
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
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
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

  // ==========================================================
  // RESULT HEADER
  // ==========================================================

  Widget _buildResultHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            Icon(Icons.keyboard_arrow_down, color: primaryGreen, size: 18),
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
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator(color: primaryGreen)),
      );
    }

    // Error
    if (_errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 45),

            const SizedBox(height: 12),

            const Text(
              'Unable to load products',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 6),

            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _loadProducts,
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
              child: const Text(
                'Try Again',
                style: TextStyle(color: Colors.white),
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
        padding: const EdgeInsets.symmetric(vertical: 50),
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              'Try another search or category.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_selectedTabIndex == 2) {
      final farmers = <String, Map<String, dynamic>>{};
      for (final product in _filteredProducts) {
        final publisher = product['publisher'];
        final id = product['farmerId']?.toString() ?? '';
        if (id.isEmpty) continue;
        farmers.putIfAbsent(
          id,
          () => {
            'name': _getFarmerName(product),
            'avatarUrl': publisher is Map ? publisher['avatarUrl'] : null,
          },
        );
      }
      return Column(
        children: farmers.values.map((farmer) {
          final avatar = farmer['avatarUrl']?.toString();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildFarmerCard(
              imageUrl: avatar == null || avatar.isEmpty
                  ? ''
                  : ApiConstants.imageUrl(avatar),
              name: farmer['name']?.toString() ?? 'Farmer',
              rating: '',
              ordersCount: 'Publisher',
            ),
          );
        }).toList(),
      );
    }

    // --------------------------------------------------------
    // Products
    // --------------------------------------------------------

    return Column(
      children: _filteredProducts.map((product) {
        _getFarmerName(product);

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: ProductCard(
            imageUrl: _getProductImage(product),

            productName: product['name']?.toString() ?? 'Unnamed Product',

            farmName: _getFarmerName(product),

            price: _formatPrice(product['price']),

            location: product['location']?.toString() ?? 'Unknown',

            availableQuantity: _formatQuantity(product['quantity']),

            isAvailable: product['isAvailable'] ?? true,

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product: product),
                ),
              );
            },

            onFavoritePressed: () {
              debugPrint('Favorite: ${product['name']}');
            },

            onAddToCart: () {
              _addToCart(product);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFarmerCard({
    required String imageUrl,
    required String name,
    required String rating,
    required String ordersCount,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isEmpty
                  ? Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.agriculture, color: primaryGreen),
                    )
                  : Image.network(
                      imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.agriculture,
                          color: primaryGreen,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rating.isEmpty
                        ? '$ordersCount orders'
                        : '$rating ($ordersCount orders)',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: primaryGreen),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // CHIP
  // ==========================================================

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
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          if (hasCloseIcon) ...[
            const SizedBox(width: 6),
            Icon(Icons.close, size: 14, color: Colors.grey.shade700),
          ],
        ],
      ),
    );
  }

  // ==========================================================
  // OUTLINED CHIP
  // ==========================================================

  Widget _buildOutlinedChip(String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
      ),
    );
  }

  String _getProductImage(Map<String, dynamic> product) {
    final images = product['imageUrls'];

    if (images is List && images.isNotEmpty) {
      final image = images.first.toString().trim();

      if (image.isNotEmpty) {
        return ApiConstants.imageUrl(image);
      }
    }

    return '';
  }

  String _formatQuantity(dynamic value) {
    if (value == null) {
      return '0 kg';
    }

    final quantity = double.tryParse(value.toString());

    if (quantity == null) {
      return '0 kg';
    }

    if (quantity % 1 == 0) {
      return '${quantity.toInt()} kg';
    }

    return '${quantity.toStringAsFixed(1)} kg';
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    try {
      await _cartService.addToCart(
        productId: product['id'].toString(),
        quantity: 1,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product['name']} added to cart'),
          backgroundColor: primaryGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add ${product['name']} to cart'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
