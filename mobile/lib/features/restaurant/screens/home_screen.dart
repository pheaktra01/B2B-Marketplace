import 'package:flutter/material.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/cart/services/cart_service.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
import 'package:mobile/features/product/screens/product_card.dart';
import 'package:mobile/features/product/screens/product_detail_screen.dart';
import 'package:mobile/features/product/services/product_service.dart';
import 'package:mobile/features/profile/services/user_service.dart';
import 'package:mobile/features/restaurant/widgets/restaurant_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primaryColor = Color(0xFF0F5A27);

  int _selectedCategoryIndex = 0;

  bool _isLoading = true;
  String? _errorMessage;

  final CartService _cartService = CartService();
  final UserService _userService = UserService();

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _recommendedFarmers = [];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'Vegetables', 'icon': Icons.eco_outlined},
    {'name': 'Fruits', 'icon': Icons.apple_outlined},
    {'name': 'Seafood', 'icon': Icons.set_meal_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadRecommendedFarmers();
  }

  Future<void> _loadRecommendedFarmers() async {
    try {
      final farmers = await _userService.getRecommendedFarmers();
      if (!mounted) return;
      setState(() => _recommendedFarmers = farmers);
    } catch (error) {
      debugPrint('Failed to load recommended farmers: $error');
    }
  }

  // ==========================================================
  // LOAD REAL PRODUCTS FROM BACKEND
  // ==========================================================

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final products = await ProductService.getAllProducts();

      if (!mounted) return;

      setState(() {
        _products = products
            .map((product) => Map<String, dynamic>.from(product))
            .toList();

        _isLoading = false;
      });

      debugPrint('========== HOME PRODUCTS ==========');
      debugPrint('Products loaded: ${_products.length}');

      for (final product in _products) {
        debugPrint(
          '${product['id']} - ${product['name']} - ${product['price']}',
        );
      }

      debugPrint('===================================');
    } catch (e) {
      debugPrint('Failed to load products: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ==========================================================
  // FILTER PRODUCTS
  // ==========================================================

  List<Map<String, dynamic>> get _filteredProducts {
    final selectedCategory = _categories[_selectedCategoryIndex]['name']
        .toString();

    if (selectedCategory == 'All') {
      return _products;
    }

    return _products.where((product) {
      final category = product['category']?.toString().toLowerCase() ?? '';

      return category == selectedCategory.toLowerCase();
    }).toList();
  }

  // ==========================================================
  // FORMAT PRICE
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
  // GET PRODUCT IMAGE
  // ==========================================================

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

  // ==========================================================
  // GET FARMER NAME
  // ==========================================================

  String _getFarmerName(Map<String, dynamic> product) {
    return product['farmerName']?.toString() ??
        product['farmName']?.toString() ??
        'Farmer';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ======================================================
      // APP BAR
      // ======================================================
      appBar: FarmerAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),

          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/mokoto.jpg'),
            ),
          ),
        ],
      ),

      // ======================================================
      // BODY
      // ======================================================
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ==================================================
              // GREETING
              // ==================================================
              const Text(
                'Hello, Green Kitchen',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Your fresh ingredients are waiting.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // SEARCH
              // ==================================================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[600]),

                    const SizedBox(width: 8),

                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search for fresh produce...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // CATEGORIES
              // ==================================================
              const Text(
                'CATEGORIES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.1,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedCategoryIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _categories[index]['icon'],
                              size: 18,
                              color: isSelected ? Colors.white : primaryColor,
                            ),

                            const SizedBox(width: 6),

                            Text(
                              _categories[index]['name'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // FEATURED PRODUCTS
              // ==================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View all',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ==================================================
              // LOADING
              // ==================================================
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                )
              // ==================================================
              // ERROR
              // ==================================================
              else if (_errorMessage != null)
                _buildErrorState()
              // ==================================================
              // EMPTY
              // ==================================================
              else if (_filteredProducts.isEmpty)
                _buildEmptyProductsState()
              // ==================================================
              // REAL PRODUCTS
              // ==================================================
              else
                ..._filteredProducts.map((product) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),

                    child: ProductCard(
                      imageUrl: _getProductImage(product),

                      productName:
                          product['name']?.toString() ?? 'Unnamed Product',

                      farmName: _getFarmerName(product),

                      price: _formatPrice(product['price']),

                      location: product['location']?.toString() ?? 'Unknown',

                      availableQuantity: _formatQuantity(product['quantity']),

                      isAvailable: product['isAvailable'] ?? true,

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: product),
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
                }),

              const SizedBox(height: 8),

              // ==================================================
              // RECOMMENDED FARMERS
              // ==================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recommended Farmers',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See list',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (_recommendedFarmers.isEmpty)
                Text(
                  'No recommended farmers yet',
                  style: TextStyle(color: Colors.grey.shade600),
                )
              else
                ..._recommendedFarmers.map(
                  (farmer) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildFarmerCard(
                      imageUrl: farmer['avatarUrl'] == null
                          ? ''
                          : ApiConstants.imageUrl(
                              farmer['avatarUrl'].toString(),
                            ),
                      name: farmer['name']?.toString() ?? 'Farmer',
                      rating: '',
                      ordersCount: '${farmer['orderCount'] ?? 0}',
                    ),
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================
      bottomNavigationBar: const RestaurantBottomNavBar(currentIndex: 0),
    );
  }

  // ==========================================================
  // ERROR STATE
  // ==========================================================

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.cloud_off_outlined, size: 50, color: Colors.grey.shade400),

          const SizedBox(height: 12),

          const Text(
            'Unable to load products',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(
            _errorMessage ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _loadProducts,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // EMPTY PRODUCTS
  // ==========================================================

  Widget _buildEmptyProductsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 50,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 12),

          Text(
            'No products available',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FARMER CARD
  // ==========================================================

  Widget _buildFarmerCard({
    required String imageUrl,
    required String name,
    required String rating,
    required String ordersCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.agriculture, color: primaryColor),
                );
              },
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

                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),

                    const SizedBox(width: 4),

                    Text(
                      rating.isEmpty
                          ? '$ordersCount orders'
                          : '$rating ($ordersCount orders)',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: primaryColor,
              size: 18,
            ),
          ),
        ],
      ),
    );
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
          backgroundColor: primaryColor,
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
