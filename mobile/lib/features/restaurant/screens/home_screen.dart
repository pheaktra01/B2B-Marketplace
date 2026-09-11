import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/features/cart/services/cart_service.dart';
import 'package:mobile/features/notification/services/notification_service.dart';
import 'package:mobile/features/product/screens/product_card.dart';
import 'package:mobile/features/product/services/favorites_service.dart';
import 'package:mobile/features/product/services/product_service.dart';
import 'package:mobile/features/profile/services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Brand Colors
  static const Color primaryColor = Color(0xFF0F5A27);
  static const Color primaryLight = Color(0xFFE8F5E9);
  static const Color accentOrange = Color(0xFFF57C00);
  static const Color surfaceBg = Color(0xFFF8FAF8);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);

  // Controllers & Services
  final TextEditingController _searchController = TextEditingController();
  final CartService _cartService = CartService();
  final UserService _userService = UserService();
  final NotificationService _notificationService = NotificationService();

  // State Data
  bool _isLoading = true;
  String? _errorMessage;
  String? _addingProductId;

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _recommendedFarmers = [];
  Set<String> _favoriteIds = {};

  // Buyer Info
  String _buyerName = 'Restaurant';
  String _buyerAddress = 'Phnom Penh';
  String? _avatarUrl;
  int _cartItemCount = 0;
  int _unreadNotificationCount = 0;

  // Filters & Layout State
  int _selectedCategoryIndex = 0;
  String _activeQuickFilter = 'All';
  String _searchQuery = '';
  String _sortBy = 'newest';
  bool _isGridView = true;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'Vegetables', 'icon': Icons.eco_rounded},
    {'name': 'Fruits', 'icon': Icons.apple_rounded},
    {'name': 'Herbs & Spices', 'icon': Icons.grass_rounded},
    {'name': 'Seafood', 'icon': Icons.set_meal_rounded},
    {'name': 'Meat & Poultry', 'icon': Icons.egg_alt_rounded},
    {'name': 'Rice & Grains', 'icon': Icons.grain_rounded},
  ];

  final List<Map<String, dynamic>> _quickFilters = [
    {'name': 'All', 'icon': null},
    {'name': 'Organic / GAP', 'icon': Icons.verified_outlined},
    {'name': 'In Stock', 'icon': Icons.check_circle_outline_rounded},
    {'name': 'Low MOQ (≤10kg)', 'icon': Icons.inventory_2_outlined},
    {'name': 'Top Farmers', 'icon': Icons.star_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadAllHomeData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  // ==========================================================
  // DATA LOADING
  // ==========================================================

  Future<void> _loadAllHomeData() async {
    await Future.wait([
      _loadProducts(),
      _loadRecommendedFarmers(),
      _loadBuyerProfile(),
      _loadCartCount(),
      _loadUnreadNotifications(),
    ]);
  }

  Future<void> _loadBuyerProfile() async {
    try {
      final profile = await _userService.getProfile();
      final data = profile['data'];
      if (!mounted || data is! Map) return;

      setState(() {
        _buyerName = data['businessName']?.toString().isNotEmpty == true
            ? data['businessName'].toString()
            : data['name']?.toString() ?? 'Restaurant';

        final address = data['address']?.toString() ?? '';
        if (address.isNotEmpty) {
          _buyerAddress = address;
        }

        final avatar = data['avatarUrl']?.toString();
        if (avatar != null && avatar.isNotEmpty) {
          _avatarUrl = ApiConstants.imageUrl(avatar);
        }
      });
    } catch (e) {
      debugPrint('Error loading buyer profile: $e');
    }
  }

  Future<void> _loadCartCount() async {
    try {
      final cart = await _cartService.getCart();
      if (!mounted) return;
      setState(() {
        _cartItemCount = cart.items.length;
      });
    } catch (e) {
      debugPrint('Error loading cart count: $e');
    }
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final count = await _notificationService.getUnreadCount();
      if (!mounted) return;
      setState(() {
        _unreadNotificationCount = count;
      });
    } catch (e) {
      debugPrint('Error loading notifications count: $e');
    }
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

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final products = await ProductService.getAllProducts();
      final favIds = await FavoritesService.getFavoriteIds();

      if (!mounted) return;

      setState(() {
        _products = products
            .map((product) => Map<String, dynamic>.from(product))
            .toList();
        _favoriteIds = favIds.toSet();
        _isLoading = false;
      });
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
  // FILTERING & SORTING LOGIC
  // ==========================================================

  List<Map<String, dynamic>> get _filteredProducts {
    List<Map<String, dynamic>> list = List.from(_products);

    // 1. Category Filter
    final selectedCategory =
        _categories[_selectedCategoryIndex]['name'].toString();
    if (selectedCategory != 'All') {
      list = list.where((product) {
        final category = product['category']?.toString().toLowerCase() ?? '';
        return category == selectedCategory.toLowerCase();
      }).toList();
    }

    // 2. Search Query Filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((product) {
        final name = product['name']?.toString().toLowerCase() ?? '';
        final farm = _getFarmerName(product).toLowerCase();
        final loc = product['location']?.toString().toLowerCase() ?? '';
        final desc = product['description']?.toString().toLowerCase() ?? '';
        final cat = product['category']?.toString().toLowerCase() ?? '';

        return name.contains(query) ||
            farm.contains(query) ||
            loc.contains(query) ||
            desc.contains(query) ||
            cat.contains(query);
      }).toList();
    }

    // 3. Quick Filter Chip
    if (_activeQuickFilter == 'Organic / GAP') {
      list = list.where((product) {
        final cond = product['condition']?.toString().toLowerCase() ?? '';
        final name = product['name']?.toString().toLowerCase() ?? '';
        final desc = product['description']?.toString().toLowerCase() ?? '';
        return cond.contains('organic') ||
            cond.contains('gap') ||
            name.contains('organic') ||
            desc.contains('organic');
      }).toList();
    } else if (_activeQuickFilter == 'In Stock') {
      list = list.where((product) {
        final isAvail = product['isAvailable'] ?? true;
        final qty = _toDouble(product['quantity']);
        return isAvail && qty > 0;
      }).toList();
    } else if (_activeQuickFilter == 'Low MOQ (≤10kg)') {
      list = list.where((product) {
        final minOrder = _toDouble(product['minOrder']);
        return minOrder <= 10;
      }).toList();
    } else if (_activeQuickFilter == 'Top Farmers') {
      final recommendedFarmerIds = _recommendedFarmers
          .map((f) => f['id']?.toString())
          .whereType<String>()
          .toSet();

      list = list.where((product) {
        final farmerId = product['farmerId']?.toString() ??
            product['publisher']?['id']?.toString();
        return farmerId != null && recommendedFarmerIds.contains(farmerId);
      }).toList();
    }

    // 4. Sorting
    switch (_sortBy) {
      case 'price_asc':
        list.sort((a, b) =>
            _toDouble(a['price']).compareTo(_toDouble(b['price'])));
        break;
      case 'price_desc':
        list.sort((a, b) =>
            _toDouble(b['price']).compareTo(_toDouble(a['price'])));
        break;
      case 'moq_asc':
        list.sort((a, b) =>
            _toDouble(a['minOrder']).compareTo(_toDouble(b['minOrder'])));
        break;
      case 'newest':
      default:
        list.sort((a, b) {
          final dateA = DateTime.tryParse(a['createdAt']?.toString() ?? '') ??
              DateTime(2000);
          final dateB = DateTime.tryParse(b['createdAt']?.toString() ?? '') ??
              DateTime(2000);
          return dateB.compareTo(dateA);
        });
        break;
    }

    return list;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  String _formatPrice(dynamic value) {
    final price = _toDouble(value);
    return '\$${price.toStringAsFixed(2)}/kg';
  }

  String _formatQuantity(dynamic value) {
    final qty = _toDouble(value);
    if (qty <= 0) return '0 kg';
    if (qty % 1 == 0) return '${qty.toInt()} kg';
    return '${qty.toStringAsFixed(1)} kg';
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

  String _getFarmerName(Map<String, dynamic> product) {
    final publisher = product['publisher'];
    if (publisher is Map && publisher['name'] != null) {
      final name = publisher['name'].toString().trim();
      if (name.isNotEmpty) return name;
    }
    return product['farmerName']?.toString() ??
        product['farmName']?.toString() ??
        'Local Farmer';
  }

  // ==========================================================
  // CART & FAVORITE ACTIONS
  // ==========================================================

  Future<void> _toggleFavorite(String productId) async {
    if (productId.isEmpty) return;

    final wasFavorite = _favoriteIds.contains(productId);
    setState(() {
      if (wasFavorite) {
        _favoriteIds.remove(productId);
      } else {
        _favoriteIds.add(productId);
      }
    });

    try {
      final isFav = await FavoritesService.toggleFavorite(productId);
      if (!mounted) return;
      setState(() {
        if (isFav) {
          _favoriteIds.add(productId);
        } else {
          _favoriteIds.remove(productId);
        }
      });
    } catch (e) {
      // Revert if failed
      if (!mounted) return;
      setState(() {
        if (wasFavorite) {
          _favoriteIds.add(productId);
        } else {
          _favoriteIds.remove(productId);
        }
      });
    }
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    final pid = product['id']?.toString() ?? '';
    if (pid.isEmpty) return;

    final minOrder = _toDouble(product['minOrder']);
    final orderQty = minOrder > 0 ? minOrder : 1.0;

    setState(() => _addingProductId = pid);

    try {
      await _cartService.addToCart(
        productId: pid,
        quantity: orderQty,
      );

      await _loadCartCount();

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Added ${product['name']} to cart',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.amberAccent,
            onPressed: () {
              context.push(AppRoutes.restaurantCart).then((_) => _loadCartCount());
            },
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to cart: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _addingProductId = null);
    }
  }

  // ==========================================================
  // BUILD METHOD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceBg,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryColor,
          onRefresh: _loadAllHomeData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Top Custom App Bar / Buyer Header
              SliverToBoxAdapter(
                child: _buildBuyerHeader(),
              ),

              // 2. Search & Filter Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: _buildSearchBar(),
                ),
              ),

              // 3. Hero Promotional Sourcing Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: _buildHeroBanner(),
                ),
              ),

              // 4. Categories Selector
              SliverToBoxAdapter(
                child: _buildCategoriesSection(),
              ),

              // 5. Quick Quality Filter Chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 0, 16),
                  child: _buildQuickFilterBar(),
                ),
              ),

              // 6. Trusted Local Farmers Spotlight
              SliverToBoxAdapter(
                child: _buildRecommendedFarmersSection(),
              ),

              // 7. Products Section Header (Count, Sort, Grid/List toggle)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: _buildProductHeaderBar(),
                ),
              ),

              // 8. Products Feed (Grid or List)
              _buildProductFeedSliver(),

              // Bottom Padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SECTION WIDGETS
  // ==========================================================

  Widget _buildBuyerHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => context.push(AppRoutes.restaurantProfile),
            child: Stack(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 2),
                    image: _avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : const DecorationImage(
                            image: AssetImage('assets/mokoto.jpg'),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Greeting & Delivery Location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _buyerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, size: 16, color: primaryColor),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        _buyerAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Header Actions (Favorites, Notifications, Cart)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Favorites Button
              _buildHeaderIconButton(
                icon: Icons.favorite_border_rounded,
                onTap: () {
                  context.push(AppRoutes.restaurantFavorites).then((_) {
                    _loadProducts();
                  });
                },
              ),

              const SizedBox(width: 6),

              // Notification Bell with Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildHeaderIconButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: () {
                      context.push(AppRoutes.notifications).then((_) {
                        _loadUnreadNotifications();
                      });
                    },
                  ),
                  if (_unreadNotificationCount > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          _unreadNotificationCount > 9
                              ? '9+'
                              : '$_unreadNotificationCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 6),

              // Cart Button with Live Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildHeaderIconButton(
                    icon: Icons.shopping_bag_outlined,
                    isHighlighted: true,
                    onTap: () {
                      context.push(AppRoutes.restaurantCart).then((_) {
                        _loadCartCount();
                      });
                    },
                  ),
                  if (_cartItemCount > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: accentOrange,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          _cartItemCount > 9 ? '9+' : '$_cartItemCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return Material(
      color: isHighlighted
          ? primaryColor.withValues(alpha: 0.1)
          : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(
            icon,
            size: 21,
            color: isHighlighted ? primaryColor : textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 14, right: 10),
            child: Icon(Icons.search_rounded, color: primaryColor, size: 22),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 14, color: textDark),
              decoration: const InputDecoration(
                hintText: 'Search vegetables, fruits, farm name...',
                hintStyle: TextStyle(color: textMuted, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: textMuted),
              onPressed: () {
                _searchController.clear();
              },
            ),
          Container(
            height: 24,
            width: 1,
            color: Colors.grey.shade300,
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: primaryColor, size: 20),
            onPressed: () {
              context.push(AppRoutes.restaurantSearch);
            },
            tooltip: 'Advanced Search & Filter',
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D4B20), Color(0xFF1E7A38)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative leaf pattern
          Positioned(
            right: -20,
            bottom: -25,
            child: Icon(
              Icons.eco_rounded,
              size: 150,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded,
                          color: Colors.amberAccent, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'DIRECT FARM SOURCING',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Fresh Morning Harvest,\nZero Middleman Markup',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Order before 11:00 AM for same-day kitchen delivery.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () => context.push(AppRoutes.restaurantSearch),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Browse Wholesale Market',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'CATEGORIES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isSelected = _selectedCategoryIndex == index;
              final category = _categories[index];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        size: 17,
                        color: isSelected ? Colors.white : primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category['name'] as String,
                        style: TextStyle(
                          color: isSelected ? Colors.white : textDark,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilterBar() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _quickFilters[index];
          final name = filter['name'] as String;
          final icon = filter['icon'] as IconData?;
          final isSelected = _activeQuickFilter == name;

          return GestureDetector(
            onTap: () {
              setState(() {
                _activeQuickFilter = name;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? primaryLight : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade300,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 14,
                      color: isSelected ? primaryColor : textMuted,
                    ),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? primaryColor : textDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendedFarmersSection() {
    if (_recommendedFarmers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.verified_user_rounded,
                      color: primaryColor, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Trusted Farmers',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.push(AppRoutes.restaurantSearch),
                child: const Text(
                  'Explore All',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recommendedFarmers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final farmer = _recommendedFarmers[index];
              return _buildFarmerSpotlightCard(farmer);
            },
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildFarmerSpotlightCard(Map<String, dynamic> farmer) {
    final farmerId = farmer['id']?.toString() ?? '';
    final name = farmer['name']?.toString() ?? 'Farmer';
    final farmName = farmer['businessName']?.toString() ?? name;
    final location = farmer['address']?.toString() ?? 'Cambodia';
    final ordersCount = farmer['orderCount'] ?? 0;
    final avatar = farmer['avatarUrl']?.toString();
    final imageUrl = avatar != null && avatar.isNotEmpty
        ? ApiConstants.imageUrl(avatar)
        : '';

    return Container(
      width: 156,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (farmerId.isNotEmpty) {
              context.push(
                AppRoutes.restaurantFarmerProfile,
                extra: farmer,
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar with Verified Badge
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: primaryLight,
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : null,
                      child: imageUrl.isEmpty
                          ? const Icon(Icons.agriculture_rounded,
                              color: primaryColor, size: 26)
                          : null,
                    ),
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(
                        Icons.verified_rounded,
                        color: primaryColor,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Name
                Text(
                  farmName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),

                const SizedBox(height: 2),

                // Location
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 11, color: textMuted),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: textMuted),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Order badge / CTA
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      ordersCount > 0 ? '$ordersCount orders' : 'Verified Farm',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductHeaderBar() {
    final count = _filteredProducts.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'Farm Produce',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Sort Menu
            PopupMenuButton<String>(
              initialValue: _sortBy,
              tooltip: 'Sort by',
              onSelected: (val) {
                setState(() => _sortBy = val);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'newest',
                  child: Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 16),
                      SizedBox(width: 8),
                      Text('Newest Harvest'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'price_asc',
                  child: Row(
                    children: [
                      Icon(Icons.arrow_upward_rounded, size: 16),
                      SizedBox(width: 8),
                      Text('Price: Low to High'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'price_desc',
                  child: Row(
                    children: [
                      Icon(Icons.arrow_downward_rounded, size: 16),
                      SizedBox(width: 8),
                      Text('Price: High to Low'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'moq_asc',
                  child: Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 16),
                      SizedBox(width: 8),
                      Text('Lowest Minimum Order'),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sort_rounded, size: 15, color: textDark),
                    SizedBox(width: 4),
                    Text(
                      'Sort',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Grid / List Toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!_isGridView) setState(() => _isGridView = true);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _isGridView ? primaryLight : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.grid_view_rounded,
                        size: 16,
                        color: _isGridView ? primaryColor : textMuted,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_isGridView) setState(() => _isGridView = false);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: !_isGridView ? primaryLight : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.view_agenda_outlined,
                        size: 16,
                        color: !_isGridView ? primaryColor : textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductFeedSliver() {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: Center(
            child: CircularProgressIndicator(color: primaryColor),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return SliverToBoxAdapter(
        child: _buildErrorState(),
      );
    }

    final products = _filteredProducts;

    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyProductsState(),
      );
    }

    if (_isGridView) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.64,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final product = products[index];
              return _buildGridProductCard(product);
            },
            childCount: products.length,
          ),
        ),
      );
    }

    // List View
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];
            final pid = product['id']?.toString() ?? '';
            final isFav = _favoriteIds.contains(pid);

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: ProductCard(
                imageUrl: _getProductImage(product),
                productName: product['name']?.toString() ?? 'Fresh Produce',
                farmName: _getFarmerName(product),
                price: _formatPrice(product['price']),
                location: product['location']?.toString() ?? 'Cambodia',
                availableQuantity: _formatQuantity(product['quantity']),
                isAvailable: product['isAvailable'] ?? true,
                isFavorite: isFav,
                minOrder: product['minOrder'] != null
                    ? '${product['minOrder']} kg'
                    : null,
                condition: product['condition']?.toString(),
                onTap: () {
                  context.push(
                    AppRoutes.productDetail,
                    extra: product,
                  ).then((_) {
                    _loadProducts();
                    _loadCartCount();
                  });
                },
                onFavoritePressed: () => _toggleFavorite(pid),
                onAddToCart: () => _addToCart(product),
              ),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  // ==========================================================
  // GRID PRODUCT CARD (Sleek B2B card)
  // ==========================================================

  Widget _buildGridProductCard(Map<String, dynamic> product) {
    final pid = product['id']?.toString() ?? '';
    final name = product['name']?.toString() ?? 'Product';
    final farmerName = _getFarmerName(product);
    final location = product['location']?.toString() ?? 'Cambodia';
    final priceStr = _formatPrice(product['price']);
    final isAvail = product['isAvailable'] ?? true;
    final isFav = _favoriteIds.contains(pid);
    final imageUrl = _getProductImage(product);
    final minOrder = _toDouble(product['minOrder']);
    final condition = product['condition']?.toString() ?? '';
    final isAdding = _addingProductId == pid;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push(
              AppRoutes.productDetail,
              extra: product,
            ).then((_) {
              _loadProducts();
              _loadCartCount();
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image + Badges
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: SizedBox(
                      height: 130,
                      width: double.infinity,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      _buildProductPlaceholder(),
                            )
                          : _buildProductPlaceholder(),
                    ),
                  ),

                  // Condition / Freshness Badge
                  if (condition.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: condition.toLowerCase().contains('organic')
                              ? primaryColor
                              : Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          condition,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  // Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(pid),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isFav ? Colors.redAccent : textMuted,
                        ),
                      ),
                    ),
                  ),

                  // Minimum Order Badge
                  if (minOrder > 0)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'MOQ: ${minOrder.toInt()}kg',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Product Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                      ),

                      const SizedBox(height: 3),

                      // Farmer Name
                      Row(
                        children: [
                          const Icon(Icons.storefront_outlined,
                              size: 12, color: primaryColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              farmerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 2),

                      // Location
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 11, color: textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Price and Quick Add to Cart
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              priceStr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                              ),
                            ),
                          ),

                          // Quick Add to Cart button
                          GestureDetector(
                            onTap: (!isAvail || isAdding)
                                ? null
                                : () => _addToCart(product),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isAvail ? primaryColor : Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                              child: isAdding
                                  ? const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      isAvail
                                          ? Icons.add_shopping_cart_rounded
                                          : Icons.block_rounded,
                                      size: 16,
                                      color: isAvail
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                    ),
                            ),
                          ),
                        ],
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

  Widget _buildProductPlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons.eco_rounded,
          size: 40,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }

  // ==========================================================
  // EMPTY & ERROR STATES
  // ==========================================================

  Widget _buildEmptyProductsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 44,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Produce Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search keywords, category, or filter chips.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _selectedCategoryIndex = 0;
                _activeQuickFilter = 'All';
              });
            },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Reset All Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'Unable to load market produce',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            _errorMessage ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAllHomeData,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
