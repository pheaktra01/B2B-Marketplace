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

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const Color primaryGreen = Color(0xFF135A27);
  static const Color lightGreenBg = Color(0xFFEAF2EB);
  static const Color pageBgColor = Color(0xFFF7F9F8);

  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  // Wholesale order quantity in kg
  double _orderQuantity = 1;

  bool _isFavorite = false;

  final CartService _cartService = CartService();
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();

  String? _publisherName;
  String? _publisherAvatarUrl;

  bool _isAddingToCart = false;
  bool _isBuyingNow = false;
  bool _isInCart = false;
  bool _isContactingFarmer = false;

  List<Map<String, dynamic>> _relatedProducts = [];

  // ==========================================================
  // GETTERS & DATA PARSING
  // ==========================================================

  String get _productId {
    return widget.product['id']?.toString() ?? '';
  }

  String get _productName {
    return widget.product['name']?.toString() ?? 'Unnamed Product';
  }

  String get _description {
    final value = widget.product['description']?.toString();
    if (value == null || value.trim().isEmpty) {
      return 'Fresh high-quality agricultural produce grown and harvested directly by local farmers with sustainable practices.';
    }
    return value;
  }

  String get _category {
    return widget.product['category']?.toString() ?? '';
  }

  String get _condition {
    return widget.product['condition']?.toString() ?? 'Fresh';
  }

  String get _farmName {
    final publisher = widget.product['publisher'];
    if (publisher is Map && publisher['name'] != null) {
      return publisher['name'].toString();
    }
    return widget.product['farmerName']?.toString() ??
        widget.product['farmName']?.toString() ??
        widget.product['farmer']?['name']?.toString() ??
        'Local Farm';
  }

  String get _location {
    return widget.product['location']?.toString() ?? 'Cambodia';
  }

  String get _deliveryMethod {
    return widget.product['deliveryMethod']?.toString() ?? 'Farmer Delivery';
  }

  double get _pricePerKg {
    final value = widget.product['price'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  double get _availableQuantity {
    final value = widget.product['quantity'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  double get _minOrder {
    final value = widget.product['minOrder'];
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value?.toString() ?? '');
    return (parsed != null && parsed > 0) ? parsed : 1.0;
  }

  double get _deliveryFee {
    final value = widget.product['deliveryFee'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  bool get _isAvailable {
    final value = widget.product['isAvailable'];
    if (value is bool) return value;
    return _availableQuantity > 0;
  }

  String? get _farmerId {
    final value = widget.product['farmerId'];
    if (value != null && value.toString().isNotEmpty) return value.toString();
    final publisher = widget.product['publisher'];
    if (publisher is Map && publisher['id'] != null) {
      return publisher['id'].toString();
    }
    final farmer = widget.product['farmer'];
    if (farmer is Map && farmer['id'] != null) {
      return farmer['id'].toString();
    }
    final pubId = widget.product['publisherId'];
    if (pubId != null && pubId.toString().isNotEmpty) {
      return pubId.toString();
    }
    return null;
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';
    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String get _harvestDate {
    return _formatDate(widget.product['harvestDate']);
  }

  String get _availableUntil {
    return _formatDate(widget.product['availableUntil']);
  }

  List<String> get _productImages {
    final images = widget.product['imageUrls'];
    if (images is List && images.isNotEmpty) {
      return images
          .map((img) => img.toString().trim())
          .where((img) => img.isNotEmpty)
          .map((img) => ApiConstants.imageUrl(img))
          .toList();
    }
    final single = widget.product['imageUrl']?.toString().trim();
    if (single != null && single.isNotEmpty) {
      return [ApiConstants.imageUrl(single)];
    }
    return [];
  }

  // ==========================================================
  // LIFECYCLE
  // ==========================================================

  @override
  void initState() {
    super.initState();
    _orderQuantity = _minOrder > 0 ? _minOrder : 1.0;
    _checkFavoriteStatus();
    _checkIfProductIsInCart();
    _loadPublisherProfile();
    _loadRelatedProducts();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    if (_productId.isNotEmpty) {
      final isFav = await FavoritesService.isFavorite(_productId);
      if (mounted) setState(() => _isFavorite = isFav);
    }
  }

  Future<void> _checkIfProductIsInCart() async {
    if (_productId.isEmpty) return;
    try {
      final cart = await _cartService.getCart();
      final found = cart.items.any((item) => item.productId == _productId);
      if (!mounted) return;
      setState(() {
        _isInCart = found;
      });
    } catch (_) {}
  }

  Future<void> _loadPublisherProfile() async {
    final publisher = widget.product['publisher'];
    if (publisher is Map) {
      final avatar = publisher['avatarUrl']?.toString();
      if (mounted) {
        setState(() {
          _publisherName = publisher['name']?.toString();
          _publisherAvatarUrl = avatar == null || avatar.isEmpty
              ? null
              : ApiConstants.imageUrl(avatar);
        });
      }
      return;
    }

    final farmerId = _farmerId;
    if (farmerId == null) return;
    try {
      final result = await _userService.getUserById(farmerId);
      final data = result['data'];
      if (!mounted || data is! Map) return;
      final avatar = data['avatarUrl']?.toString();
      setState(() {
        _publisherName = data['name']?.toString();
        _publisherAvatarUrl = avatar == null || avatar.isEmpty
            ? null
            : ApiConstants.imageUrl(avatar);
      });
    } catch (error) {
      debugPrint('Failed to load publisher: $error');
    }
  }

  Future<void> _loadRelatedProducts() async {
    try {
      final list = await ProductService.getRelatedProducts(
        category: _category,
        farmerId: _farmerId,
        excludeProductId: _productId,
      );
      if (!mounted) return;
      setState(() {
        _relatedProducts = list;
      });
    } catch (_) {}
  }

  // ==========================================================
  // ACTIONS
  // ==========================================================

  Future<void> _toggleFavorite() async {
    if (_productId.isEmpty) return;
    final isFav = await FavoritesService.toggleFavorite(_productId);
    if (!mounted) return;
    setState(() => _isFavorite = isFav);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFav ? 'Added to Favorites' : 'Removed from Favorites'),
        duration: const Duration(seconds: 1),
        backgroundColor: isFav ? primaryGreen : Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareProduct() {
    Clipboard.setData(ClipboardData(
      text: 'Check out $_productName on B2B Marketplace at \$${_pricePerKg.toStringAsFixed(2)}/kg!',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product link copied to clipboard!'),
        duration: Duration(seconds: 2),
        backgroundColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showQuantityInputDialog() {
    final controller =
        TextEditingController(text: _orderQuantity.toStringAsFixed(0));

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Enter Order Quantity',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Minimum order: ${_minOrder.toStringAsFixed(0)} kg\nAvailable stock: ${_availableQuantity.toStringAsFixed(0)} kg',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              autofocus: true,
              decoration: InputDecoration(
                suffixText: 'kg',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: primaryGreen, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                if (val < _minOrder) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Minimum order quantity is ${_minOrder.toStringAsFixed(0)} kg'),
                      backgroundColor: Colors.orange.shade800,
                    ),
                  );
                  return;
                }
                if (val > _availableQuantity && _availableQuantity > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cannot exceed available stock of ${_availableQuantity.toStringAsFixed(0)} kg'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                setState(() => _orderQuantity = val);
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _addPresetQuantity(double amount) {
    final next = _orderQuantity + amount;
    if (_availableQuantity > 0 && next > _availableQuantity) {
      setState(() => _orderQuantity = _availableQuantity);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Adjusted to maximum available stock: ${_availableQuantity.toStringAsFixed(0)} kg'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() => _orderQuantity = next);
    }
  }

  Future<void> _addToCart() async {
    if (_isAddingToCart) return;

    if (_productId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product ID is missing')),
      );
      return;
    }

    setState(() => _isAddingToCart = true);
    try {
      await _cartService.addToCart(
        productId: _productId,
        quantity: _orderQuantity,
      );
      if (!mounted) return;
      setState(() => _isInCart = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${_orderQuantity.toStringAsFixed(0)} kg $_productName to cart'),
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
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  Future<void> _buyNow() async {
    if (_isBuyingNow) return;

    setState(() => _isBuyingNow = true);
    try {
      // 1. Add to cart
      await _cartService.addToCart(
        productId: _productId,
        quantity: _orderQuantity,
      );
      // 2. Fetch updated cart
      final cart = await _cartService.getCart();
      if (!mounted) return;
      setState(() => _isInCart = true);

      // 3. Navigate directly to checkout
      await context.push(
        AppRoutes.restaurantCheckout,
        extra: CheckoutArgs(
          cart: cart,
          deliveryAddress: 'Commercial Kitchen, Phnom Penh',
          deliveryNotes: 'Direct procurement order for $_productName',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkout initialization failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBuyingNow = false);
    }
  }

  Future<void> _contactFarmer() async {
    final farmerId = _farmerId;
    if (farmerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farmer information is unavailable')),
      );
      return;
    }

    setState(() => _isContactingFarmer = true);
    try {
      final conversation = await _chatService.createConversation(farmerId);
      final conversationId = conversation['id']?.toString();
      if (conversationId == null || conversationId.isEmpty) {
        throw Exception('Conversation ID was not returned');
      }

      if (!mounted) return;
      final participant = conversation['participant'];
      final participantName = participant is Map
          ? participant['name']?.toString()
          : null;
      await context.push(
        AppRoutes.chatConversation,
        extra: ChatConversationArgs(
          conversationId: conversationId,
          participantName: participantName?.isNotEmpty == true
              ? participantName!
              : _farmName,
          participantAvatarUrl: _publisherAvatarUrl,
          isOnline: false,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open chat: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isContactingFarmer = false);
    }
  }

  void _openFullscreenImage(int initialIndex) {
    if (_productImages.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              _productName,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: Image.network(
                _productImages[initialIndex],
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: pageBgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          _productName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black87),
            onPressed: _shareProduct,
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black87),
            onPressed: () => context.push(AppRoutes.restaurantCart),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Swipeable Hero Image Gallery
            _buildHeroImageGallery(),

            const SizedBox(height: 16),

            // 2. Title & Trust Badges
            _buildTitleAndBadges(),

            const SizedBox(height: 16),

            // 3. Wholesale Pricing Card
            _buildPricingCard(),

            const SizedBox(height: 16),

            // 4. Interactive Wholesale Quantity Selector & Presets
            _buildWholesaleQuantitySelector(),

            const SizedBox(height: 16),

            // 5. Dynamic Price & Order Summary Card
            _buildOrderSummaryCard(),

            const SizedBox(height: 16),

            // 6. Farmer / Seller Profile Card
            _buildFarmerProfileCard(),

            const SizedBox(height: 16),

            // 7. Product Details & Harvest Info
            _buildProductInfoCard(),

            const SizedBox(height: 16),

            // 8. Description
            _buildDescriptionCard(),

            const SizedBox(height: 20),

            // 9. More Produce From This Farm
            if (_relatedProducts.isNotEmpty) _buildRelatedProduceSection(),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildDualBottomBar(),
    );
  }

  // ==========================================================
  // WIDGET BUILDERS
  // ==========================================================

  Widget _buildHeroImageGallery() {
    final images = _productImages;

    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 320,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.grey.shade200,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: images.isEmpty
                    ? const Center(
                        child: Icon(Icons.eco_outlined,
                            size: 64, color: primaryGreen),
                      )
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        onPageChanged: (idx) {
                          setState(() => _currentImageIndex = idx);
                        },
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _openFullscreenImage(index),
                            child: Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 320,
                              errorBuilder: (_, _, _) => const Center(
                                child: Icon(Icons.broken_image_outlined,
                                    size: 48, color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),

            // Availability Badge (Top Left)
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _isAvailable ? Colors.white : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isAvailable
                            ? (_availableQuantity < 20
                                ? Colors.orange
                                : Colors.green)
                            : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isAvailable
                          ? (_availableQuantity < 20
                              ? 'Low Stock (${_availableQuantity.toStringAsFixed(0)} kg)'
                              : 'In Stock (${_availableQuantity.toStringAsFixed(0)} kg)')
                          : 'Out of Stock',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _isAvailable
                            ? (_availableQuantity < 20
                                ? Colors.orange.shade800
                                : primaryGreen)
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Favorite Button (Top Right)
            Positioned(
              top: 14,
              right: 14,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 3,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _toggleFavorite,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.grey.shade700,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),

            // Image Counter Pill (Bottom Right)
            if (images.length > 1)
              Positioned(
                bottom: 14,
                right: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentImageIndex + 1} / ${images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Thumbnail strip
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == _currentImageIndex;
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? primaryGreen : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTitleAndBadges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _productName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (_category.isNotEmpty)
              _buildPillBadge(
                label: _category,
                icon: Icons.category_outlined,
                bgColor: lightGreenBg,
                textColor: primaryGreen,
              ),
            _buildPillBadge(
              label: _condition,
              icon: Icons.eco_outlined,
              bgColor: Colors.green.shade50,
              textColor: const Color(0xFF2E7D32),
            ),
            _buildPillBadge(
              label: _location,
              icon: Icons.location_on_outlined,
              bgColor: Colors.grey.shade100,
              textColor: Colors.grey.shade800,
            ),
            _buildPillBadge(
              label: 'Min: ${_minOrder.toStringAsFixed(0)} kg',
              icon: Icons.shopping_basket_outlined,
              bgColor: Colors.orange.shade50,
              textColor: Colors.orange.shade900,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPillBadge({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightGreenBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryGreen.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WHOLESALE UNIT PRICE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '\$${_pricePerKg.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '/ kg',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Minimum: ${_minOrder.toStringAsFixed(0)} kg',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Delivery: ${_deliveryFee > 0 ? '\$${_deliveryFee.toStringAsFixed(2)}' : 'Free'}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWholesaleQuantitySelector() {
    final canDecrease = _orderQuantity > _minOrder;
    final canIncrease =
        _availableQuantity <= 0 || _orderQuantity < _availableQuantity;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ORDER QUANTITY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Min. wholesale order: ${_minOrder.toStringAsFixed(0)} kg',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Stepper + Direct Input tap
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: pageBgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: canDecrease
                            ? () {
                                setState(() {
                                  _orderQuantity =
                                      (_orderQuantity - 1).clamp(_minOrder, 99999);
                                });
                              }
                            : null,
                        icon: const Icon(Icons.remove, size: 20),
                        color: canDecrease ? primaryGreen : Colors.grey,
                      ),
                      GestureDetector(
                        onTap: _showQuantityInputDialog,
                        child: Row(
                          children: [
                            Text(
                              '${_orderQuantity.toStringAsFixed(0)} kg',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.edit_outlined,
                                size: 14, color: Colors.grey.shade500),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: canIncrease
                            ? () {
                                setState(() => _orderQuantity++);
                              }
                            : null,
                        icon: const Icon(Icons.add, size: 20),
                        color: canIncrease ? primaryGreen : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Quick Presets Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickPresetChip('+5 kg', () => _addPresetQuantity(5)),
                const SizedBox(width: 8),
                _buildQuickPresetChip('+10 kg', () => _addPresetQuantity(10)),
                const SizedBox(width: 8),
                _buildQuickPresetChip('+25 kg', () => _addPresetQuantity(25)),
                const SizedBox(width: 8),
                _buildQuickPresetChip('+50 kg', () => _addPresetQuantity(50)),
                const SizedBox(width: 8),
                _buildQuickPresetChip('+100 kg', () => _addPresetQuantity(100)),
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('Reset to Min'),
                  labelStyle: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold, color: primaryGreen),
                  backgroundColor: lightGreenBg,
                  onPressed: () {
                    setState(() => _orderQuantity = _minOrder);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPresetChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    final subtotal = _pricePerKg * _orderQuantity;
    final total = subtotal + _deliveryFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PRICE ESTIMATE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Produce Subtotal (${_orderQuantity.toStringAsFixed(0)} kg × \$${_pricePerKg.toStringAsFixed(2)})',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Delivery Fee',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              Text(
                _deliveryFee > 0
                    ? '\$${_deliveryFee.toStringAsFixed(2)}'
                    : 'Free',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _deliveryFee > 0 ? Colors.black87 : primaryGreen,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimated Total',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FARMER & PRODUCER',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _publisherAvatarUrl == null
                  ? const CircleAvatar(
                      radius: 26,
                      backgroundColor: lightGreenBg,
                      child: Icon(Icons.agriculture, color: primaryGreen, size: 26),
                    )
                  : CircleAvatar(
                      radius: 26,
                      backgroundImage: NetworkImage(_publisherAvatarUrl!),
                      onBackgroundImageError: (_, _) {},
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _publisherName?.isNotEmpty == true
                          ? _publisherName!
                          : _farmName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.verified, color: primaryGreen, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Verified Local Producer',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isContactingFarmer ? null : _contactFarmer,
                icon: const Icon(Icons.chat_outlined, size: 16),
                label: const Text('Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightGreenBg,
                  foregroundColor: primaryGreen,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HARVEST & LOGISTICS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          if (_harvestDate.isNotEmpty)
            _buildInfoRow(Icons.calendar_today_outlined, 'Harvest Date', _harvestDate),
          if (_availableUntil.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildInfoRow(Icons.event_available_outlined, 'Available Until', _availableUntil),
          ],
          const SizedBox(height: 10),
          _buildInfoRow(Icons.local_shipping_outlined, 'Delivery Method', _deliveryMethod),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.location_on_outlined, 'Farm Origin', _location),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: lightGreenBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryGreen, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PRODUCT DESCRIPTION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatRelatedPrice(dynamic value) {
    double? price;
    if (value is num) {
      price = value.toDouble();
    } else {
      price = double.tryParse(value?.toString() ?? '');
    }
    if (price == null) return '\$0.00/kg';
    return '\$${price.toStringAsFixed(2)}/kg';
  }

  String _getProductImageUrl(Map<String, dynamic> product) {
    final images = product['imageUrls'];
    if (images is List && images.isNotEmpty) {
      final first = images.first.toString().trim();
      if (first.isNotEmpty) return ApiConstants.imageUrl(first);
    }
    final single = product['imageUrl']?.toString().trim();
    if (single != null && single.isNotEmpty) {
      return ApiConstants.imageUrl(single);
    }
    return '';
  }

  Widget _buildRelatedProduceSection() {
    if (_relatedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'More From This Farm',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              '${_relatedProducts.length} items',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 232,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _relatedProducts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = _relatedProducts[index];
              return _buildRelatedProductCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedProductCard(Map<String, dynamic> item) {
    final name = item['name']?.toString() ?? 'Produce';
    final imgUrl = _getProductImageUrl(item);
    final priceStr = _formatRelatedPrice(item['price']);
    final condition = item['condition']?.toString();
    final minOrder = item['minOrder']?.toString();
    final quantity = item['quantity']?.toString() ?? '0';
    final isAvailable = item['isAvailable'] == true ||
        ((item['quantity'] is num
                ? (item['quantity'] as num)
                : (num.tryParse(quantity) ?? 0)) >
            0);

    return Container(
      width: 175,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            context.push(AppRoutes.productDetail, extra: item);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Stack with Badges
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: Container(
                  height: 110,
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imgUrl.isNotEmpty)
                        Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Center(
                            child: Icon(Icons.eco_outlined,
                                size: 36, color: primaryGreen),
                          ),
                        )
                      else
                        const Center(
                          child: Icon(Icons.eco_outlined,
                              size: 36, color: primaryGreen),
                        ),

                      // Availability & condition badges
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isAvailable)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.94),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'In Stock',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (condition != null && condition.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: primaryGreen.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  condition,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Min order badge
                      if (minOrder != null && minOrder.isNotEmpty)
                        Positioned(
                          bottom: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Min: $minOrder kg',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Product Info & Quick Action
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      priceStr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            '$quantity kg left',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: !isAvailable
                              ? null
                              : () async {
                                  final pId = item['id']?.toString() ?? '';
                                  if (pId.isEmpty) return;
                                  final orderQty =
                                      double.tryParse(minOrder ?? '') ?? 1.0;
                                  try {
                                    await _cartService.addToCart(
                                      productId: pId,
                                      quantity: orderQty > 0 ? orderQty : 1.0,
                                    );
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Added $name to cart'),
                                          duration: const Duration(seconds: 2),
                                          action: SnackBarAction(
                                            label: 'VIEW CART',
                                            textColor: Colors.white,
                                            onPressed: () => context
                                                .push(AppRoutes.restaurantCart),
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Failed to add to cart: $e'),
                                          backgroundColor: Colors.red.shade700,
                                        ),
                                      );
                                    }
                                  }
                                },
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? primaryGreen.withValues(alpha: 0.12)
                                  : Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_shopping_cart,
                              size: 15,
                              color: isAvailable
                                  ? primaryGreen
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDualBottomBar() {
    final subtotal = _pricePerKg * _orderQuantity;
    final canOrder = _isAvailable &&
        _orderQuantity >= _minOrder &&
        (_availableQuantity <= 0 || _orderQuantity <= _availableQuantity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Total price
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL (${_orderQuantity.toStringAsFixed(0)} kg)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Button 1: Add to Cart / View Cart
            Expanded(
              flex: 3,
              child: OutlinedButton.icon(
                onPressed: _isInCart
                    ? () => context.push(AppRoutes.restaurantCart)
                    : (canOrder && !_isAddingToCart ? _addToCart : null),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryGreen,
                  side: const BorderSide(color: primaryGreen, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isAddingToCart
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryGreen,
                        ),
                      )
                    : Icon(_isInCart ? Icons.shopping_cart : Icons.add_shopping_cart, size: 18),
                label: Text(
                  _isInCart ? 'In Cart' : 'Add to Cart',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Button 2: Buy Now (Instant Checkout)
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                onPressed: canOrder && !_isBuyingNow ? _buyNow : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isBuyingNow
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.bolt, size: 18),
                label: const Text(
                  'Buy Now',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
