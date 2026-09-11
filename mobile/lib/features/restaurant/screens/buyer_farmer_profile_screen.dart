import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/core/routing/route_args.dart';
import 'package:mobile/features/cart/services/cart_service.dart';
import 'package:mobile/features/chat/services/chat_service.dart';
import 'package:mobile/features/product/services/favorites_service.dart';
import 'package:mobile/features/product/services/product_service.dart';
import 'package:mobile/features/profile/services/user_service.dart';

class BuyerFarmerProfileScreen extends StatefulWidget {
  final String farmerId;
  final Map<String, dynamic>? initialFarmerData;

  const BuyerFarmerProfileScreen({
    super.key,
    required this.farmerId,
    this.initialFarmerData,
  });

  @override
  State<BuyerFarmerProfileScreen> createState() =>
      _BuyerFarmerProfileScreenState();
}

class _BuyerFarmerProfileScreenState extends State<BuyerFarmerProfileScreen>
    with SingleTickerProviderStateMixin {
  // Theme Palette
  static const Color primaryGreen = Color(0xFF135A27);
  static const Color darkGreen = Color(0xFF0C3818);
  static const Color lightGreenBg = Color(0xFFEAF5EC);
  static const Color pageBg = Color(0xFFF8FAFC);
  static const Color cardBorderColor = Color(0xFFE2E8F0);

  final UserService _userService = UserService();
  final ChatService _chatService = ChatService();
  final CartService _cartService = CartService();

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoadingProducts = true;
  bool _isContacting = false;
  String? _addingToCartId;

  // Profile data
  String _farmerName = '';
  String? _businessName;
  String? _avatarUrl;
  String? _coverUrl;
  String? _address;
  String? _bio;
  String? _phone;
  bool _isVerified = true;

  // Products data
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  Set<String> _favoriteIds = {};
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    _initializeFromInitialData();
    _loadFarmerProfile();
    _loadFarmerProducts();
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeFromInitialData() {
    final data = widget.initialFarmerData;
    if (data != null) {
      _farmerName = data['name']?.toString() ??
          data['farmerName']?.toString() ??
          'Local Farmer';
      _businessName = data['businessName']?.toString() ??
          data['farmName']?.toString();
      _phone = data['phone']?.toString();
      _address = data['address']?.toString() ?? data['location']?.toString();
      _bio = data['bio']?.toString();
      final avatar = data['avatarUrl']?.toString();
      if (avatar != null && avatar.isNotEmpty) {
        _avatarUrl = ApiConstants.imageUrl(avatar);
      }
      final cover = data['coverUrl']?.toString();
      if (cover != null && cover.isNotEmpty) {
        _coverUrl = ApiConstants.imageUrl(cover);
      }
    }
  }

  Future<void> _loadFarmerProfile() async {
    if (widget.farmerId.isEmpty) {
      return;
    }

    try {
      final result = await _userService.getUserById(widget.farmerId);
      final data = result['data'];
      if (!mounted || data is! Map) return;

      final avatar = data['avatarUrl']?.toString();
      final cover = data['coverUrl']?.toString();

      setState(() {
        _farmerName = data['name']?.toString() ?? _farmerName;
        _businessName = data['businessName']?.toString() ?? _businessName;
        _phone = data['phone']?.toString() ?? _phone;
        _address = data['address']?.toString() ?? _address;
        _bio = data['bio']?.toString() ?? _bio;
        _isVerified = data['isVerified'] == true || _isVerified;

        if (avatar != null && avatar.isNotEmpty) {
          _avatarUrl = ApiConstants.imageUrl(avatar);
        }
        if (cover != null && cover.isNotEmpty) {
          _coverUrl = ApiConstants.imageUrl(cover);
        }
      });
    } catch (e) {
      debugPrint('Error loading farmer profile: $e');
    }
  }

  Future<void> _loadFarmerProducts() async {
    if (widget.farmerId.isEmpty) {
      setState(() => _isLoadingProducts = false);
      return;
    }

    try {
      final products = await ProductService.getProductsByFarmer(widget.farmerId);
      if (!mounted) return;

      final categorySet = <String>{'All'};
      for (final p in products) {
        final cat = p['category']?.toString();
        if (cat != null && cat.isNotEmpty) {
          categorySet.add(cat);
        }
      }

      setState(() {
        _allProducts = products;
        _categories = categorySet.toList();
        _applyFilters();
        _isLoadingProducts = false;
      });
    } catch (e) {
      debugPrint('Error loading farmer products: $e');
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final ids = await FavoritesService.getFavoriteIds();
      if (!mounted) return;
      setState(() {
        _favoriteIds = ids.toSet();
      });
    } catch (_) {}
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((p) {
        final name = (p['name']?.toString() ?? '').toLowerCase();
        final cat = (p['category']?.toString() ?? '').toLowerCase();

        final matchesCategory = _selectedCategory == 'All' ||
            cat == _selectedCategory.toLowerCase();
        final matchesQuery = query.isEmpty ||
            name.contains(query) ||
            cat.contains(query);

        return matchesCategory && matchesQuery;
      }).toList();
    });
  }

  Future<void> _toggleFavorite(String productId) async {
    if (productId.isEmpty) return;
    final isFav = await FavoritesService.toggleFavorite(productId);
    if (!mounted) return;
    setState(() {
      if (isFav) {
        _favoriteIds.add(productId);
      } else {
        _favoriteIds.remove(productId);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFav ? 'Added to favorites' : 'Removed from favorites'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isFav ? primaryGreen : Colors.grey.shade800,
      ),
    );
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    final productId = product['id']?.toString() ?? '';
    if (productId.isEmpty) return;

    setState(() => _addingToCartId = productId);
    try {
      final minOrder = double.tryParse(product['minOrder']?.toString() ?? '') ?? 1.0;
      await _cartService.addToCart(
        productId: productId,
        quantity: minOrder > 0 ? minOrder : 1.0,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${product['name']} to cart'),
          backgroundColor: primaryGreen,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () => context.push(AppRoutes.restaurantCart),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _addingToCartId = null);
    }
  }

  Future<void> _chatWithFarmer() async {
    if (_isContacting) return;
    final farmerId = widget.farmerId;
    if (farmerId.isEmpty) return;

    setState(() => _isContacting = true);
    try {
      final conversation = await _chatService.createConversation(farmerId);
      final conversationId = conversation['id']?.toString();
      if (conversationId == null || conversationId.isEmpty) {
        throw Exception('Conversation could not be initialized');
      }

      if (!mounted) return;
      final participant = conversation['participant'];
      final name = participant is Map && participant['name'] != null
          ? participant['name'].toString()
          : (_businessName?.isNotEmpty == true ? _businessName! : _farmerName);

      await context.push(
        AppRoutes.chatConversation,
        extra: ChatConversationArgs(
          conversationId: conversationId,
          participantName: name,
          participantAvatarUrl: _avatarUrl,
          isOnline: false,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open chat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isContacting = false);
    }
  }

  void _showContactFarmerDialog() {
    final phone = _phone?.trim() ?? '';
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 32,
                backgroundColor: lightGreenBg,
                child: const Icon(Icons.call_outlined, color: primaryGreen, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                _businessName ?? _farmerName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                phone.isNotEmpty ? phone : 'No phone number provided yet',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              if (phone.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: phone));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Phone number $phone copied to clipboard!'),
                          backgroundColor: primaryGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text(
                      'Copy Phone Number',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareFarmerProfile() {
    final title = _businessName ?? _farmerName;
    Clipboard.setData(
      ClipboardData(
        text: 'Check out $title on B2B Marketplace! Location: ${_address ?? "Cambodia"}',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Farmer profile link copied to clipboard!'),
        backgroundColor: primaryGreen,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _businessName?.isNotEmpty == true
        ? _businessName!
        : (_farmerName.isNotEmpty ? _farmerName : 'Local Farm');
    final subtitleOwner = _businessName?.isNotEmpty == true &&
            _farmerName.isNotEmpty &&
            _farmerName != _businessName
        ? 'Operated by $_farmerName'
        : null;

    return Scaffold(
      backgroundColor: pageBg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Profile Header & Actions
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover Photo with Navigation Actions and Overlapping Avatar
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Cover Photo
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: const BoxDecoration(color: darkGreen),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _coverUrl != null
                                ? Image.network(
                                    _coverUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _buildCoverFallback(),
                                  )
                                : _buildCoverFallback(),
                            // Gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.45),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.75),
                                  ],
                                  stops: const [0.0, 0.45, 1.0],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Navigation Actions (Back and Share buttons)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      Colors.black.withValues(alpha: 0.35),
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back,
                                        color: Colors.white, size: 20),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ),
                                CircleAvatar(
                                  backgroundColor:
                                      Colors.black.withValues(alpha: 0.35),
                                  child: IconButton(
                                    icon: const Icon(Icons.share_outlined,
                                        color: Colors.white, size: 20),
                                    onPressed: _shareFarmerProfile,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Avatar Overlapping Cover Bottom Edge
                      Positioned(
                        bottom: -38,
                        left: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 38,
                            backgroundColor: lightGreenBg,
                            backgroundImage: _avatarUrl != null
                                ? NetworkImage(_avatarUrl!)
                                : null,
                            child: _avatarUrl == null
                                ? const Icon(
                                    Icons.agriculture,
                                    color: primaryGreen,
                                    size: 38,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Profile Info Card & Actions
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Space for the overlapping avatar + Verified Producer Badge aligned right
                        SizedBox(
                          height: 44,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (_isVerified)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: lightGreenBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color:
                                            primaryGreen.withValues(alpha: 0.2)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified,
                                          color: primaryGreen, size: 16),
                                      SizedBox(width: 5),
                                      Text(
                                        'Verified Producer',
                                        style: TextStyle(
                                          color: primaryGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Farm Name & Owner
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (subtitleOwner != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitleOwner,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 15, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _address?.isNotEmpty == true
                                    ? _address!
                                    : 'Cambodia',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Buyer Action Buttons
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 46,
                                child: ElevatedButton.icon(
                                  onPressed: _isContacting
                                      ? null
                                      : _chatWithFarmer,
                                  icon: _isContacting
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.chat_bubble_outline,
                                          size: 18),
                                  label: Text(
                                    _isContacting
                                        ? 'Opening Chat...'
                                        : 'Chat with Farmer',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryGreen,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 46,
                                child: OutlinedButton.icon(
                                  onPressed: _showContactFarmerDialog,
                                  icon: const Icon(Icons.phone_outlined,
                                      size: 18),
                                  label: const Text(
                                    'Contact',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: primaryGreen,
                                    side: const BorderSide(
                                        color: primaryGreen, width: 1.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Quick Trust Metrics Bar
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: pageBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: cardBorderColor),
                          ),
                          child: Row(
                            children: [
                              _buildMetricItem(
                                icon: Icons.inventory_2_outlined,
                                title: '${_allProducts.length}',
                                label: 'Produce',
                              ),
                              _buildMetricDivider(),
                              _buildMetricItem(
                                icon: Icons.star_rounded,
                                iconColor: Colors.amber,
                                title: '4.9 ★',
                                label: 'Rating',
                              ),
                              _buildMetricDivider(),
                              _buildMetricItem(
                                icon: Icons.local_shipping_outlined,
                                title: 'Direct',
                                label: 'Delivery',
                              ),
                              _buildMetricDivider(),
                              _buildMetricItem(
                                icon: Icons.check_circle_outline,
                                title: '100%',
                                label: 'Fresh Harvest',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sticky Tab Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: primaryGreen,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorColor: primaryGreen,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  tabs: [
                    Tab(text: 'Produce Catalog (${_allProducts.length})'),
                    const Tab(text: 'About Farm'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProductsTab(),
            _buildAboutTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    Color iconColor = primaryGreen,
    required String title,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildCoverFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F471D), Color(0xFF1D7838)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.agriculture,
        color: Colors.white12,
        size: 110,
      ),
    );
  }

  // ==========================================================
  // TAB 1: PRODUCE CATALOG
  // ==========================================================

  Widget _buildProductsTab() {
    if (_isLoadingProducts) {
      return const Center(
        child: CircularProgressIndicator(color: primaryGreen),
      );
    }

    return CustomScrollView(
      slivers: [
        // Search & Category Filters
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // In-catalog search
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cardBorderColor),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => _applyFilters(),
                    decoration: InputDecoration(
                      hintText: 'Search within this farm...',
                      hintStyle:
                          TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      prefixIcon: Icon(Icons.search,
                          color: Colors.grey.shade500, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _applyFilters();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Chips
                if (_categories.length > 1)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = cat;
                                  _applyFilters();
                                });
                              }
                            },
                            selectedColor: primaryGreen,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade800,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? primaryGreen
                                    : Colors.grey.shade300,
                              ),
                            ),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Product Grid or Empty State
        if (_filteredProducts.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: lightGreenBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.eco_outlined,
                          size: 48, color: primaryGreen),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchController.text.isNotEmpty
                          ? 'No matching produce found'
                          : 'No active produce listed yet',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _searchController.text.isNotEmpty
                          ? 'Try searching for something else'
                          : 'This farmer has not published any available crops right now.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = _filteredProducts[index];
                  return _buildProductCard(product);
                },
                childCount: _filteredProducts.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final productId = product['id']?.toString() ?? '';
    final isFav = _favoriteIds.contains(productId);
    final isAddingThis = _addingToCartId == productId;

    final name = product['name']?.toString() ?? 'Fresh Produce';
    final price = double.tryParse(product['price']?.toString() ?? '') ?? 0.0;
    final minOrder = double.tryParse(product['minOrder']?.toString() ?? '') ?? 1.0;
    final condition = product['condition']?.toString() ?? 'Fresh';

    String? imageUrl;
    final images = product['imageUrls'];
    if (images is List && images.isNotEmpty) {
      imageUrl = ApiConstants.imageUrl(images.first.toString());
    } else if (product['imageUrl'] != null) {
      imageUrl = ApiConstants.imageUrl(product['imageUrl'].toString());
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: () {
          context.push(
            AppRoutes.productDetail,
            extra: product,
          ).then((_) => _loadFavorites());
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image & Badge & Fav
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
                    child: AspectRatio(
                      aspectRatio: 1.3,
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade100,
                                child: const Icon(Icons.image_not_supported,
                                    color: Colors.grey),
                              ),
                            )
                          : Container(
                              color: lightGreenBg,
                              child: const Icon(Icons.eco,
                                  color: primaryGreen, size: 36),
                            ),
                    ),
                  ),
                  // Condition badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        condition,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () => _toggleFavorite(productId),
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.grey.shade700,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Info & Price & Add to Cart
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Min: ${minOrder.toStringAsFixed(0)} kg',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '\$${price.toStringAsFixed(2)}/kg',
                            style: const TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                            width: 34,
                            height: 34,
                            child: ElevatedButton(
                              onPressed: isAddingThis
                                  ? null
                                  : () => _addToCart(product),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: isAddingThis
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.add_shopping_cart,
                                      size: 16),
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

  // ==========================================================
  // TAB 2: ABOUT FARM
  // ==========================================================

  Widget _buildAboutTab() {
    final bioText = _bio?.isNotEmpty == true
        ? _bio!
        : 'Dedicated local farmer committed to providing fresh, sustainable, and high-quality agricultural produce for professional restaurant kitchens and wholesale buyers.';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio / Story
          const Text(
            'About the Farm',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorderColor),
            ),
            child: Text(
              bioText,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade800,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Farm Practices Badges
          const Text(
            'Farming Standards & Practices',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildPracticeTile(
            icon: Icons.eco,
            title: 'Sustainable Agriculture',
            desc: 'Utilizes organic composting and biological pest management.',
          ),
          const SizedBox(height: 10),
          _buildPracticeTile(
            icon: Icons.grass,
            title: 'Freshly Harvested',
            desc: 'Crops are harvested upon order confirmation to ensure maximum freshness.',
          ),
          const SizedBox(height: 10),
          _buildPracticeTile(
            icon: Icons.handshake_outlined,
            title: 'Direct Farm-to-Kitchen',
            desc: 'Fair pricing directly between grower and culinary establishments.',
          ),

          const SizedBox(height: 24),

          // Location & Contact Details
          const Text(
            'Location & Logistics',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorderColor),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.location_on_outlined,
                  'Farm Origin',
                  _address?.isNotEmpty == true ? _address! : 'Cambodia',
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.phone_outlined,
                  'Direct Phone',
                  _phone?.isNotEmpty == true ? _phone! : 'Available upon chat inquiry',
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.local_shipping_outlined,
                  'Fulfillment',
                  'Direct Farm Delivery & Commercial Hub Pickup',
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPracticeTile({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: lightGreenBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryGreen, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: primaryGreen),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}
