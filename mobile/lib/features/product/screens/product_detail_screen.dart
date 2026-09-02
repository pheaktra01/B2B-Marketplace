import 'package:flutter/material.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/cart/services/cart_service.dart';
import 'package:mobile/features/chat/screens/chat_screen.dart';
import 'package:mobile/features/chat/services/chat_service.dart';
import 'package:mobile/features/profile/services/user_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const Color primaryGreen = Color(0xFF135A27);
  static const Color lightGreenBg = Color(0xFFE2F0E5);
  static const Color pageBgColor = Color(0xFFF7F9F8);
  static const Color buttonOrange = Color(0xFFFF8C00);

  int _selectedImageIndex = 0;

  // This is the quantity the restaurant wants to buy.
  double _orderQuantity = 1;

  bool _isFavorite = false;

  final CartService _cartService = CartService();
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();

  String? _publisherName;
  String? _publisherAvatarUrl;

  bool _isAddingToCart = false;
  bool _isAddedToCart = false;

  bool _isInCart = false;
  bool _isCheckingCart = true;
  bool _isContactingFarmer = false;

  // ==========================================================
  // PRODUCT DATA
  // ==========================================================

  String get _productName {
    return widget.product['name']?.toString() ?? 'Unnamed Product';
  }

  String get _description {
    final value = widget.product['description']?.toString();

    if (value == null || value.trim().isEmpty) {
      return 'No description available.';
    }

    return value;
  }

  String get _category {
    return widget.product['category']?.toString() ?? '';
  }

  String get _condition {
    return widget.product['condition']?.toString() ?? '';
  }

  String get _farmName {
    final publisher = widget.product['publisher'];
    if (publisher is Map && publisher['name'] != null) {
      return publisher['name'].toString();
    }

    return widget.product['farmerName']?.toString() ??
        widget.product['farmName']?.toString() ??
        widget.product['farmer']?['name']?.toString() ??
        'Farmer';
  }

  String get _location {
    return widget.product['location']?.toString() ?? '';
  }

  String get _deliveryMethod {
    return widget.product['deliveryMethod']?.toString() ?? '';
  }

  // ==========================================================
  // PRICE
  // ==========================================================

  double get _pricePerKg {
    final value = widget.product['price'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  // ==========================================================
  // AVAILABLE QUANTITY
  // ==========================================================

  double get _availableQuantity {
    final value = widget.product['quantity'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  // ==========================================================
  // MINIMUM ORDER
  // ==========================================================

  double get _minOrder {
    final value = widget.product['minOrder'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 1;
  }

  // ==========================================================
  // DELIVERY FEE
  // ==========================================================

  double get _deliveryFee {
    final value = widget.product['deliveryFee'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  // ==========================================================
  // AVAILABILITY
  // ==========================================================

  bool get _isAvailable {
    final value = widget.product['isAvailable'];

    if (value is bool) {
      return value;
    }

    return _availableQuantity > 0;
  }

  String? get _farmerId {
    final value = widget.product['farmerId'];
    if (value == null || value.toString().isEmpty) return null;
    return value.toString();
  }

  // ==========================================================
  // DATES
  // ==========================================================

  String _formatDate(dynamic value) {
    if (value == null) {
      return '';
    }

    final date = DateTime.tryParse(value.toString());

    if (date == null) {
      return value.toString();
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String get _harvestDate {
    return _formatDate(widget.product['harvestDate']);
  }

  String get _availableUntil {
    return _formatDate(widget.product['availableUntil']);
  }

  // ==========================================================
  // IMAGES
  // ==========================================================

  List<String> get _productImages {
    final images = widget.product['imageUrls'];

    if (images is List) {
      return images
          .map((image) => image.toString().trim())
          .where((image) => image.isNotEmpty)
          .map((image) => ApiConstants.imageUrl(image))
          .toList();
    }

    // Support imageUrl too, in case your backend returns
    // a single image instead of imageUrls.
    final singleImage = widget.product['imageUrl']?.toString().trim();

    if (singleImage != null && singleImage.isNotEmpty) {
      return [ApiConstants.imageUrl(singleImage)];
    }

    return [];
  }

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    // Start ordering at minimum order.
    _orderQuantity = _minOrder > 0 ? _minOrder : 1;

    _checkIfProductIsInCart();
    _loadPublisherProfile();
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
      debugPrint('Failed to load publisher profile: $error');
    }
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
          onPressed: () {
            Navigator.maybePop(context);
          },
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
            onPressed: () {},
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // IMAGE
            // ==================================================
            _buildMainImageView(),

            const SizedBox(height: 12),

            _buildThumbnailGallery(),

            const SizedBox(height: 20),

            // ==================================================
            // PRODUCT TITLE
            // ==================================================
            Text(
              _productName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // Category + condition
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_category.isNotEmpty)
                  _buildTagChip(_category, icon: Icons.category_outlined),

                if (_condition.isNotEmpty)
                  _buildTagChip(_condition, icon: Icons.verified_outlined),
              ],
            ),

            const SizedBox(height: 16),

            // ==================================================
            // PRICE
            // ==================================================
            _buildPriceSection(),

            const SizedBox(height: 20),

            // ==================================================
            // STOCK / MIN ORDER
            // ==================================================
            _buildOrderInformation(),

            const SizedBox(height: 20),

            // ==================================================
            // PRODUCT INFORMATION
            // ==================================================
            _buildProductInformation(),

            const SizedBox(height: 20),

            // ==================================================
            // DESCRIPTION
            // ==================================================
            _buildProductDescription(),

            const SizedBox(height: 20),

            // ==================================================
            // DELIVERY INFORMATION
            // ==================================================
            _buildDeliveryInformation(),

            const SizedBox(height: 20),

            // ==================================================
            // FARMER
            // ==================================================
            _buildFarmerCard(),

            const SizedBox(height: 30),
          ],
        ),
      ),

      // ========================================================
      // BOTTOM CART
      // ========================================================
      bottomNavigationBar: _buildBottomCartBar(),
    );
  }

  // ==========================================================
  // MAIN IMAGE
  // ==========================================================

  Widget _buildMainImageView() {
    if (_productImages.isEmpty) {
      return _buildImagePlaceholder(height: 320);
    }

    if (_selectedImageIndex >= _productImages.length) {
      _selectedImageIndex = 0;
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _buildImage(_productImages[_selectedImageIndex], height: 320),
        ),

        // Availability badge
        Positioned(top: 12, left: 12, child: _buildAvailabilityBadge()),

        // Favorite
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : primaryGreen,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // AVAILABILITY BADGE
  // ==========================================================

  Widget _buildAvailabilityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _isAvailable ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isAvailable ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: _isAvailable ? primaryGreen : Colors.red,
          ),

          const SizedBox(width: 5),

          Text(
            _isAvailable ? 'Available' : 'Unavailable',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _isAvailable ? primaryGreen : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // IMAGE
  // ==========================================================

  Widget _buildImage(String image, {required double height}) {
    return Image.network(
      image,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,

      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          height: height,
          width: double.infinity,
          color: Colors.grey.shade100,
          child: const Center(
            child: CircularProgressIndicator(
              color: primaryGreen,
              strokeWidth: 2,
            ),
          ),
        );
      },

      errorBuilder: (context, error, stackTrace) {
        debugPrint('Product image failed: $image');

        return _buildImagePlaceholder(height: height);
      },
    );
  }

  Widget _buildImagePlaceholder({required double height}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.eco_rounded, size: 60, color: primaryGreen),
    );
  }

  // ==========================================================
  // THUMBNAILS
  // ==========================================================

  Widget _buildThumbnailGallery() {
    if (_productImages.length <= 1) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _productImages.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final selected = index == _selectedImageIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedImageIndex = index;
              });
            },
            child: Container(
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? primaryGreen : Colors.transparent,
                  width: 2.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  _productImages[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.eco, color: primaryGreen),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // PRICE
  // ==========================================================

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightGreenBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),

                const SizedBox(height: 3),

                Text(
                  '\$${_pricePerKg.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),

                Text(
                  'per kg',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 17,
                  color: primaryGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_availableQuantity.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ORDER INFORMATION
  // ==========================================================

  Widget _buildOrderInformation() {
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
            'ORDER INFORMATION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildInfoBox(
                  icon: Icons.inventory_2_outlined,
                  title: 'Available',
                  value: '${_availableQuantity.toStringAsFixed(1)} kg',
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildInfoBox(
                  icon: Icons.shopping_basket_outlined,
                  title: 'Minimum Order',
                  value: '${_minOrder.toStringAsFixed(1)} kg',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: pageBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: primaryGreen),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PRODUCT INFORMATION
  // ==========================================================

  Widget _buildProductInformation() {
    final items = <Map<String, String>>[];

    if (_category.isNotEmpty) {
      items.add({'label': 'Category', 'value': _category});
    }

    if (_condition.isNotEmpty) {
      items.add({'label': 'Condition', 'value': _condition});
    }

    if (_location.isNotEmpty) {
      items.add({'label': 'Location', 'value': _location});
    }

    if (_harvestDate.isNotEmpty) {
      items.add({'label': 'Harvest Date', 'value': _harvestDate});
    }

    if (_availableUntil.isNotEmpty) {
      items.add({'label': 'Available Until', 'value': _availableUntil});
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSectionCard(
      title: 'PRODUCT INFORMATION',
      child: Column(
        children: items.map((item) {
          final index = items.indexOf(item);

          return Column(
            children: [
              _buildInformationRow(
                icon: _getInformationIcon(item['label']!),
                label: item['label']!,
                value: item['value']!,
              ),

              if (index != items.length - 1)
                Divider(height: 20, color: Colors.grey.shade200),
            ],
          );
        }).toList(),
      ),
    );
  }

  IconData _getInformationIcon(String label) {
    switch (label) {
      case 'Category':
        return Icons.category_outlined;

      case 'Condition':
        return Icons.verified_outlined;

      case 'Location':
        return Icons.location_on_outlined;

      case 'Harvest Date':
        return Icons.calendar_today_outlined;

      case 'Available Until':
        return Icons.event_available_outlined;

      default:
        return Icons.info_outline;
    }
  }

  Widget _buildInformationRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: lightGreenBg,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 18, color: primaryGreen),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // DESCRIPTION
  // ==========================================================

  Widget _buildProductDescription() {
    return _buildSectionCard(
      title: 'PRODUCT DESCRIPTION',
      child: Text(
        _description,
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  // ==========================================================
  // DELIVERY
  // ==========================================================

  Widget _buildDeliveryInformation() {
    final hasDelivery =
        _deliveryMethod.isNotEmpty || _location.isNotEmpty || _deliveryFee > 0;

    if (!hasDelivery) {
      return const SizedBox.shrink();
    }

    return _buildSectionCard(
      title: 'DELIVERY INFORMATION',
      child: Column(
        children: [
          if (_deliveryMethod.isNotEmpty)
            _buildInformationRow(
              icon: Icons.local_shipping_outlined,
              label: 'Delivery Method',
              value: _deliveryMethod,
            ),

          if (_location.isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildInformationRow(
              icon: Icons.location_on_outlined,
              label: 'Location',
              value: _location,
            ),
          ],

          const SizedBox(height: 14),

          _buildInformationRow(
            icon: Icons.payments_outlined,
            label: 'Delivery Fee',
            value: _deliveryFee > 0
                ? '\$${_deliveryFee.toStringAsFixed(2)}'
                : 'Free',
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FARMER
  // ==========================================================

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
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conversationId,
            participantName: participantName?.isNotEmpty == true
                ? participantName!
                : _farmName,
            isOnline: false,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to open chat: ${error.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isContactingFarmer = false);
    }
  }

  Widget _buildFarmerCard() {
    return _buildSectionCard(
      title: 'SELLER',
      child: Column(
        children: [
          Row(
            children: [
              _publisherAvatarUrl == null
                  ? const CircleAvatar(
                      radius: 25,
                      backgroundColor: lightGreenBg,
                      child: Icon(Icons.agriculture, color: primaryGreen),
                    )
                  : CircleAvatar(
                      radius: 25,
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
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.verified,
                          color: primaryGreen,
                          size: 14,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          'Verified Farmer',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              OutlinedButton(
                onPressed: _isContactingFarmer ? null : _contactFarmer,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isContactingFarmer
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Contact',
                        style: TextStyle(
                          color: primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_category.isNotEmpty) _buildTagChip(_category),

              if (_deliveryMethod.isNotEmpty) _buildTagChip(_deliveryMethod),

              _buildTagChip('Wholesale'),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SECTION CARD
  // ==========================================================

  Widget _buildSectionCard({required String title, required Widget child}) {
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
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
              letterSpacing: 0.7,
            ),
          ),

          const SizedBox(height: 14),

          child,
        ],
      ),
    );
  }

  // ==========================================================
  // TAG
  // ==========================================================

  Widget _buildTagChip(String label, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: primaryGreen),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BOTTOM CART
  // ==========================================================

  Widget _buildBottomCartBar() {
    final total = _pricePerKg * _orderQuantity;

    final canAdd =
        _isAvailable &&
        _orderQuantity >= _minOrder &&
        _orderQuantity <= _availableQuantity;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _orderQuantity > _minOrder
                        ? () {
                            setState(() {
                              _orderQuantity--;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.remove, size: 18),
                  ),

                  Text(
                    '${_orderQuantity.toStringAsFixed(0)} kg',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  IconButton(
                    onPressed: _orderQuantity < _availableQuantity
                        ? () {
                            setState(() {
                              _orderQuantity++;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.add, size: 18),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: ElevatedButton(
                onPressed:
                    canAdd && !_isAddingToCart && !_isInCart && !_isCheckingCart
                    ? _addToCart
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAddedToCart ? primaryGreen : buttonOrange,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCheckingCart
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : _isAddingToCart
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isInCart
                                ? 'Added to Cart'
                                : canAdd
                                ? 'Add to Cart'
                                : 'Unavailable',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),

                          if (canAdd && !_isInCart)
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart() async {
    if (_isAddingToCart || _isInCart) return;

    final productId = widget.product['id']?.toString();

    if (productId == null || productId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product ID is missing'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    try {
      await _cartService.addToCart(
        productId: productId,
        quantity: _orderQuantity,
      );

      if (!mounted) return;

      setState(() {
        _isInCart = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to cart successfully'),
          backgroundColor: primaryGreen,
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
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  Future<void> _checkIfProductIsInCart() async {
    final productId = widget.product['id']?.toString();

    if (productId == null || productId.isEmpty) {
      if (!mounted) return;

      setState(() {
        _isCheckingCart = false;
      });

      return;
    }

    try {
      final cart = await _cartService.getCart();

      final found = cart.items.any((item) => item.productId == productId);

      if (!mounted) return;

      setState(() {
        _isInCart = found;
        _isCheckingCart = false;
      });
    } catch (e) {
      debugPrint('Failed to check cart: $e');

      if (!mounted) return;

      setState(() {
        _isCheckingCart = false;
      });
    }
  }
}
