import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/features/product/services/product_service.dart';

class FarmerProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const FarmerProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<FarmerProductDetailScreen> createState() =>
      _FarmerProductDetailScreenState();
}

class _FarmerProductDetailScreenState extends State<FarmerProductDetailScreen> {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color pageBgColor = Color(0xFFF7F9F7);

  late Map<String, dynamic> product;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isTogglingStatus = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    product = Map<String, dynamic>.from(widget.product);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ==========================================================
  // VALUE HELPERS
  // ==========================================================

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim()) ?? 0.0;
  }

  String _value(String key, {String fallback = 'Not specified'}) {
    final val = product[key]?.toString().trim();
    if (val == null || val.isEmpty) return fallback;
    return val;
  }

  List<String> get _productImages {
    final images = product['imageUrls'] ?? product['images'];
    if (images is List && images.isNotEmpty) {
      return images
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .map((e) => ApiConstants.imageUrl(e))
          .toList();
    }
    final single = product['imageUrl']?.toString().trim();
    if (single != null && single.isNotEmpty) {
      return [ApiConstants.imageUrl(single)];
    }
    return [];
  }

  String? _formatDate(dynamic dateValue) {
    if (dateValue == null) return null;
    final parsed = DateTime.tryParse(dateValue.toString());
    if (parsed == null) return null;
    return DateFormat('MMM dd, yyyy').format(parsed);
  }

  // ==========================================================
  // ACTIONS
  // ==========================================================

  Future<void> _editProduct() async {
    final id = product['id']?.toString();
    if (id == null) return;

    final updated = await context.push<bool>(
      AppRoutes.farmerEditProduct,
      extra: product,
    );

    // If updated, refresh product data
    if (updated == true || updated == null) {
      _refreshProductDetails();
    }
  }

  Future<void> _refreshProductDetails() async {
    final id = product['id']?.toString();
    if (id == null) return;

    try {
      final products = await ProductService.getMyProducts();
      final found = products.where((item) => item['id']?.toString() == id);
      if (found.isNotEmpty && mounted) {
        setState(() {
          product = Map<String, dynamic>.from(found.first);
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleAvailability(bool newValue) async {
    final id = product['id']?.toString();
    if (id == null) return;

    setState(() => _isTogglingStatus = true);

    try {
      await ProductService.updateProduct(
        productId: id,
        data: {'isAvailable': newValue},
      );

      if (mounted) {
        setState(() {
          product['isAvailable'] = newValue;
          _isTogglingStatus = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newValue
                  ? 'Product is now available on marketplace.'
                  : 'Product is now hidden from marketplace.',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTogglingStatus = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Delete Product'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${_value('name', fallback: 'this product')}"? This action cannot be undone.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _executeDelete();
    }
  }

  Future<void> _executeDelete() async {
    final id = product['id']?.toString();
    if (id == null) return;

    setState(() => _isDeleting = true);

    try {
      await ProductService.deleteProduct(productId: id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Product deleted successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete product: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openFullscreenImage(int initialIndex) {
    final images = _productImages;
    if (images.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              _value('name', fallback: 'Product Photo'),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: Image.network(
                images[initialIndex],
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
    final name = _value('name', fallback: 'Unnamed Product');
    final category = _value('category', fallback: 'Produce');
    final condition = _value('condition', fallback: 'Fresh');
    final price = _toDouble(product['price']);
    final quantity = _toDouble(product['quantity']);
    final isAvailable = product['isAvailable'] == true;
    final totalBatchValue = price * quantity;

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Product Details',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: primaryGreen,
            ),
            tooltip: 'Edit Product',
            onPressed: _editProduct,
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black87,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                _editProduct();
              } else if (value == 'toggle') {
                _toggleAvailability(!isAvailable);
              } else if (value == 'delete') {
                _confirmDelete();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20, color: primaryGreen),
                    SizedBox(width: 10),
                    Text('Edit Product'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(
                      isAvailable
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 10),
                    Text(isAvailable ? 'Hide Listing' : 'Make Available'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Delete Listing', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Hero Image Gallery
                        _buildHeroGallery(),

                        const SizedBox(height: 16),

                        // 2. Title & Status Header Card
                        _buildTitleCard(
                          name: name,
                          category: category,
                          condition: condition,
                          isAvailable: isAvailable,
                          quantity: quantity,
                        ),

                        const SizedBox(height: 14),

                        // 3. Business & Inventory Metrics
                        _buildMetricsRow(
                          price: price,
                          quantity: quantity,
                          batchValue: totalBatchValue,
                        ),

                        const SizedBox(height: 14),

                        // 4. Live Marketplace Toggle Card
                        _buildMarketplaceToggleCard(isAvailable: isAvailable),

                        const SizedBox(height: 14),

                        // 5. Inventory & Order Rules Card
                        _buildInventoryRulesCard(),

                        const SizedBox(height: 14),

                        // 6. Delivery & Location Card
                        _buildDeliveryCard(),

                        const SizedBox(height: 14),

                        // 7. Product Description Card
                        _buildDescriptionCard(),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Action Bar
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // WIDGET: HERO GALLERY
  // ==========================================================

  Widget _buildHeroGallery() {
    final images = _productImages;

    return Column(
      children: [
        Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey.shade200,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: images.isEmpty
                ? _buildEmptyImagePlaceholder()
                : Stack(
                    children: [
                      PageView.builder(
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
                              height: 280,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: primaryGreen,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, _, _) =>
                                  _buildEmptyImagePlaceholder(),
                            ),
                          );
                        },
                      ),

                      // Counter Badge
                      if (images.length > 1)
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '${_currentImageIndex + 1} / ${images.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      // Dots Indicator
                      if (images.length > 1)
                        Positioned(
                          bottom: 14,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (idx) {
                              final isSelected = _currentImageIndex == idx;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: isSelected ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
          ),
        ),

        // Thumbnails Strip (if multiple photos)
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 54,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, idx) {
                final isSelected = _currentImageIndex == idx;
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      idx,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 54,
                    height: 54,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? primaryGreen : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images[idx],
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

  Widget _buildEmptyImagePlaceholder() {
    return Container(
      color: lightGreen.withValues(alpha: 0.5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco_outlined,
                size: 40,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'No produce photos uploaded',
              style: TextStyle(
                color: darkGreen,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap Edit Product to upload photos',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // WIDGET: TITLE & STATUS CARD
  // ==========================================================

  Widget _buildTitleCard({
    required String name,
    required String category,
    required String condition,
    required bool isAvailable,
    required double quantity,
  }) {
    Color statusColor;
    Color statusBgColor;
    String statusLabel;
    IconData statusIcon;

    if (!isAvailable) {
      statusColor = Colors.grey.shade700;
      statusBgColor = Colors.grey.shade200;
      statusLabel = 'Hidden / Unlisted';
      statusIcon = Icons.visibility_off_outlined;
    } else if (quantity <= 0) {
      statusColor = Colors.red.shade700;
      statusBgColor = Colors.red.shade50;
      statusLabel = 'Out of Stock';
      statusIcon = Icons.error_outline;
    } else if (quantity <= 20) {
      statusColor = Colors.orange.shade800;
      statusBgColor = Colors.orange.shade50;
      statusLabel = 'Low Stock (${quantity.toStringAsFixed(1)} kg left)';
      statusIcon = Icons.warning_amber_rounded;
    } else {
      statusColor = darkGreen;
      statusBgColor = lightGreen;
      statusLabel = 'In Stock & Active';
      statusIcon = Icons.check_circle_outline;
    }

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Category Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.category_outlined,
                      size: 13,
                      color: primaryGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Condition Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: condition.toLowerCase() == 'organic'
                      ? const Color(0xFFE0F2FE)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      condition.toLowerCase() == 'organic'
                          ? Icons.verified_outlined
                          : Icons.water_drop_outlined,
                      size: 13,
                      color: condition.toLowerCase() == 'organic'
                          ? Colors.blue.shade700
                          : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      condition,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: condition.toLowerCase() == 'organic'
                          ? Colors.blue.shade800
                          : Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Product Name
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
              height: 1.25,
            ),
          ),

          const SizedBox(height: 12),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 6),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
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
  // WIDGET: METRICS ROW
  // ==========================================================

  Widget _buildMetricsRow({
    required double price,
    required double quantity,
    required double batchValue,
  }) {
    return Row(
      children: [
        // Unit Price
        Expanded(
          child: _buildMetricTile(
            label: 'Unit Price',
            value: '\$${price.toStringAsFixed(2)}',
            subtext: 'per kg',
            color: primaryGreen,
            icon: Icons.attach_money,
          ),
        ),

        const SizedBox(width: 10),

        // Total Stock
        Expanded(
          child: _buildMetricTile(
            label: 'Stock on Hand',
            value: quantity.toStringAsFixed(1),
            subtext: 'kg total',
            color: const Color(0xFF0284C7),
            icon: Icons.inventory_2_outlined,
          ),
        ),

        const SizedBox(width: 10),

        // Est. Inventory Value
        Expanded(
          child: _buildMetricTile(
            label: 'Est. Batch Value',
            value: '\$${batchValue.toStringAsFixed(0)}',
            subtext: 'total value',
            color: const Color(0xFFD97706),
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String subtext,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // WIDGET: MARKETPLACE TOGGLE CARD
  // ==========================================================

  Widget _buildMarketplaceToggleCard({required bool isAvailable}) {
    return _buildCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isAvailable ? lightGreen : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isAvailable
                  ? Icons.storefront_outlined
                  : Icons.visibility_off_outlined,
              color: isAvailable ? primaryGreen : Colors.grey.shade600,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAvailable ? 'Listed on Marketplace' : 'Listing is Hidden',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAvailable
                      ? 'Buyers and restaurants can discover this product'
                      : 'Product is paused and hidden from marketplace catalog',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          _isTogglingStatus
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryGreen,
                  ),
                )
              : Switch.adaptive(
                  value: isAvailable,
                  activeThumbColor: primaryGreen,
                  activeTrackColor: lightGreen,
                  onChanged: _toggleAvailability,
                ),
        ],
      ),
    );
  }

  // ==========================================================
  // WIDGET: INVENTORY & ORDER RULES CARD
  // ==========================================================

  Widget _buildInventoryRulesCard() {
    final minOrder = _toDouble(product['minOrder']);
    final harvestStr = _formatDate(product['harvestDate']) ?? 'Not specified';
    final availableUntilStr =
        _formatDate(product['availableUntil']) ?? 'Not specified';

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.rule_folder_outlined,
            title: 'Inventory & Order Rules',
          ),
          const SizedBox(height: 14),
          _buildDetailRow(
            icon: Icons.shopping_basket_outlined,
            label: 'Minimum Order Quantity (MOQ)',
            value: '${minOrder.toStringAsFixed(1)} kg',
          ),
          const Divider(height: 18),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Harvest Date',
            value: harvestStr,
          ),
          const Divider(height: 18),
          _buildDetailRow(
            icon: Icons.event_available_outlined,
            label: 'Available Until',
            value: availableUntilStr,
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // WIDGET: DELIVERY & LOCATION CARD
  // ==========================================================

  Widget _buildDeliveryCard() {
    final location = _value('location');
    final deliveryMethod = _value('deliveryMethod', fallback: 'Farmer Delivery');
    final deliveryFee = _toDouble(product['deliveryFee']);

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.local_shipping_outlined,
            title: 'Fulfillment & Logistics',
          ),
          const SizedBox(height: 14),
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            label: 'Farm Origin / Location',
            value: location,
          ),
          const Divider(height: 18),
          _buildDetailRow(
            icon: Icons.delivery_dining_outlined,
            label: 'Delivery Method',
            value: deliveryMethod,
          ),
          const Divider(height: 18),
          _buildDetailRow(
            icon: Icons.payments_outlined,
            label: 'Delivery Fee',
            value: deliveryFee > 0
                ? '\$${deliveryFee.toStringAsFixed(2)}'
                : 'Free Delivery',
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // WIDGET: DESCRIPTION CARD
  // ==========================================================

  Widget _buildDescriptionCard() {
    final description = _value('description', fallback: '');

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.description_outlined,
            title: 'Product Description',
          ),
          const SizedBox(height: 12),
          Text(
            description.isNotEmpty
                ? description
                : 'No additional description provided. Tap Edit to add details about your produce freshness, taste profile, and harvesting methods.',
            style: TextStyle(
              fontSize: 14,
              color: description.isNotEmpty
                  ? const Color(0xFF333333)
                  : Colors.grey.shade500,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // WIDGET: BOTTOM ACTION BAR
  // ==========================================================

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Delete Icon Button
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(14),
              ),
              child: IconButton(
                icon: _isDeleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.red,
                        ),
                      )
                    : const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Delete Product',
                onPressed: _isDeleting ? null : _confirmDelete,
              ),
            ),

            const SizedBox(width: 12),

            // Edit Product Button
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _editProduct,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text(
                    'Edit Product',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
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
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // COMMON HELPER BUILDERS
  // ==========================================================

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: lightGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryGreen, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E1E),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E1E),
          ),
        ),
      ],
    );
  }
}