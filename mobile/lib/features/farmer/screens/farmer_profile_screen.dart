import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:go_router/go_router.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
import 'package:mobile/features/profile/services/user_service.dart';
import 'package:mobile/features/order/services/order_service.dart';
import 'package:mobile/features/product/services/product_service.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/profile/widgets/edit_profile_bottom_sheet.dart';

// ------------------------------------------------------------
// DATA MODELS
// ------------------------------------------------------------

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double quantity;
  final String tag;
  final Color tagColor;
  final String imageUrl;
  final bool isLive;
  final Map<String, dynamic> raw;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.tag,
    required this.tagColor,
    required this.imageUrl,
    this.isLive = true,
    required this.raw,
  });

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    final id = map['id']?.toString() ?? '';
    final name = map['name']?.toString() ?? 'Unnamed';
    final category = map['category']?.toString() ?? 'Produce';
    final price = _toDouble(map['price']);
    final quantity = _toDouble(map['quantity']);
    final isAvailable = map['isAvailable'] == true;

    String tag = 'In Stock';
    Color tagColor = const Color(0xFF135A27);

    if (!isAvailable) {
      tag = 'Unavailable';
      tagColor = Colors.grey;
    } else if (quantity <= 0) {
      tag = 'Out of Stock';
      tagColor = Colors.red.shade700;
    } else if (quantity <= 5) {
      tag = 'Low Stock';
      tagColor = Colors.orange.shade800;
    }

    String img = '';
    final images = map['imageUrls'] ?? map['images'];
    if (images is List && images.isNotEmpty) {
      img = images.first.toString();
    } else if (images is String && images.isNotEmpty && images != '{}') {
      img = images.replaceAll('{', '').replaceAll('}', '').split(',').first.trim();
    } else if (map['imageUrl'] != null) {
      img = map['imageUrl'].toString();
    }

    return Product(
      id: id,
      name: name,
      category: category,
      price: price,
      quantity: quantity,
      tag: tag,
      tagColor: tagColor,
      imageUrl: img.isNotEmpty ? ApiConstants.imageUrl(img) : '',
      isLive: isAvailable,
      raw: map,
    );
  }
}

// ------------------------------------------------------------
// MAIN PROFILE SCREEN
// ------------------------------------------------------------

class FarmerProfileScreen extends StatefulWidget {
  final String? userId;

  const FarmerProfileScreen({super.key, this.userId});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  // ------------------------------------------------------------
  // THEME COLORS
  // ------------------------------------------------------------

  static const Color primaryGreen = Color(0xFF135A27);
  static const Color pageBgColor = Color(0xFFF4F6F4);
  static const Color cardBgColor = Color(0xFFF7F8F7);
  static const Color badgeBgColor = Color(0xFFEDF2EE);

  // ------------------------------------------------------------
  // PROFILE DATA
  // ------------------------------------------------------------

  String _displayName = 'Farmer';
  String? _businessName;
  String _phone = '';
  String _location = '';
  String _description = '';
  bool _isVerified = true;
  String _sinceYear = '2024';

  // Metrics from real database
  int _orderCount = 0;
  double _totalRevenue = 0.0;
  final String _rating = '4.9 ★';

  // ------------------------------------------------------------
  // IMAGE FALLBACKS
  // ------------------------------------------------------------
  final String _defaultCoverUrl = 'assets/default_cover.jpg';
  final String _defaultAvatarUrl = 'assets/default_avatar.jpg';

  String? _avatarUrl;
  String? _coverUrl;
  final UserService _userService = UserService();
  final OrderService _orderService = OrderService();

  Uint8List? _localCoverBytes;
  Uint8List? _localAvatarBytes;

  // ------------------------------------------------------------
  // PRODUCTS & CATEGORIES
  // ------------------------------------------------------------

  int _selectedCategoryIndex = 0;
  List<Product> _products = [];
  bool _isLoading = true;

  final ImagePicker _picker = ImagePicker();

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (mounted && _products.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      await Future.wait([
        _loadProfile(),
        _loadOrdersMetrics(),
        _loadProducts(),
      ]);
    } catch (e) {
      debugPrint('Failed to load profile data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadProfile() async {
    try {
      final result = widget.userId != null
          ? await _userService.getUserById(widget.userId!)
          : await _userService.getProfile();

      final data = result['data'];
      if (!mounted || data is! Map) return;

      final createdAtStr = data['createdAt']?.toString();
      final createdDate = DateTime.tryParse(createdAtStr ?? '');

      setState(() {
        _displayName = data['name']?.toString() ?? _displayName;
        _businessName = data['businessName']?.toString();
        _phone = data['phone']?.toString() ?? '';
        _location = data['address']?.toString() ?? '';
        _description = data['bio']?.toString() ?? '';
        _isVerified = data['isVerified'] == true;
        if (createdDate != null) {
          _sinceYear = createdDate.year.toString();
        }
        _avatarUrl = _toImageUrl(data['avatarUrl']?.toString());
        _coverUrl = _toImageUrl(data['coverUrl']?.toString());
      });
    } catch (error) {
      debugPrint('Failed to load profile: $error');
    }
  }

  Future<void> _loadOrdersMetrics() async {
    try {
      final orders = await _orderService.getFarmerOrders();
      double revenue = 0.0;
      for (final order in orders) {
        if (order.status.toLowerCase() != 'cancelled') {
          revenue += order.total;
        }
      }
      if (mounted) {
        setState(() {
          _orderCount = orders.length;
          _totalRevenue = revenue;
        });
      }
    } catch (error) {
      debugPrint('Failed to load farmer orders for metrics: $error');
    }
  }

  Future<void> _loadProducts() async {
    try {
      final items = await ProductService.getMyProducts();
      final loaded = items.map((map) => Product.fromMap(map)).toList();

      if (mounted) {
        setState(() {
          _products = loaded;
        });
      }
    } catch (error) {
      debugPrint('Failed to load farmer products: $error');
    }
  }

  String? _toImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    return ApiConstants.imageUrl(url);
  }

  // ------------------------------------------------------------
  // CATEGORIES
  // ------------------------------------------------------------

  List<String> _getCategories(AppLocalizations l10n) {
    final dynamicCategories = _products
        .map((p) => p.category.trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();

    return [l10n.allProduce, ...dynamicCategories];
  }

  // ------------------------------------------------------------
  // FILTER PRODUCTS
  // ------------------------------------------------------------

  List<Product> _filteredProducts(AppLocalizations l10n) {
    final categories = _getCategories(l10n);
    if (_selectedCategoryIndex <= 0 ||
        _selectedCategoryIndex >= categories.length) {
      return _products;
    }

    final categoryName = categories[_selectedCategoryIndex];
    return _products
        .where(
          (product) =>
              product.category.toLowerCase() == categoryName.toLowerCase(),
        )
        .toList();
  }

  // ------------------------------------------------------------
  // EDIT INFORMATION DIALOG (MODERN BOTTOM SHEET)
  // ------------------------------------------------------------

  // ignore: unused_element
  Future<void> _showEditProfileInfoDialog() async {
    final result = await EditProfileBottomSheet.show(
      context: context,
      isFarmer: true,
      currentName: _displayName,
      currentBusinessName: _businessName,
      currentPhone: _phone,
      currentAddress: _location,
      currentBio: _description,
      currentAvatarUrl: _avatarUrl,
      currentCoverUrl: _coverUrl,
    );

    if (result != null && mounted) {
      setState(() {
        _displayName = result['name'] ?? _displayName;
        _businessName = result['businessName'];
        _phone = result['phone'] ?? _phone;
        _location = result['address'] ?? _location;
        _description = result['bio'] ?? _description;
        if (result['avatarUrl'] != null) {
          _avatarUrl = result['avatarUrl'];
          _localAvatarBytes = null;
        }
        if (result['coverUrl'] != null) {
          _coverUrl = result['coverUrl'];
          _localCoverBytes = null;
        }
      });

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.farmProfileUpdated ?? 'Farm profile updated successfully! 🌾',
          ),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // IMAGE OPTIONS
  // ------------------------------------------------------------

  void _showImageOptionsBottomSheet({
    required BuildContext context,
    required String title,
    required bool isAvatar,
  }) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.visibility, color: primaryGreen),
                title: Text(l10n.viewPhoto),
                onTap: () {
                  Navigator.pop(ctx);
                  _viewPhotoFullScreen(isAvatar: isAvatar);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: primaryGreen),
                title: Text(l10n.changePhoto),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndSavePhoto(isAvatar: isAvatar);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // VIEW PHOTO
  // ------------------------------------------------------------

  void _viewPhotoFullScreen({required bool isAvatar}) {
    final Uint8List? localBytes = isAvatar
        ? _localAvatarBytes
        : _localCoverBytes;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                child: localBytes != null
                    ? Image.memory(localBytes, fit: BoxFit.contain)
                    : (isAvatar
                        ? (_avatarUrl != null && _avatarUrl!.isNotEmpty
                            ? Image.network(
                                _avatarUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                  _defaultAvatarUrl,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : Image.asset(
                                _defaultAvatarUrl,
                                fit: BoxFit.contain,
                              ))
                        : (_coverUrl != null && _coverUrl!.isNotEmpty
                            ? Image.network(
                                _coverUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                  _defaultCoverUrl,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : Image.asset(
                                _defaultCoverUrl,
                                fit: BoxFit.contain,
                              ))),
              ),
              Positioned(
                top: 40,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // PICK PHOTO
  // ------------------------------------------------------------

  Future<void> _pickAndSavePhoto({required bool isAvatar}) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (pickedFile == null) return;

      final Uint8List imageBytes = await pickedFile.readAsBytes();

      final result = isAvatar
          ? await _userService.uploadAvatar(
              pickedFile.path,
              imageBytes: imageBytes,
              filename: pickedFile.name,
            )
          : await _userService.uploadCover(
              pickedFile.path,
              imageBytes: imageBytes,
              filename: pickedFile.name,
            );
      final data = result['data'];
      final uploadedUrl = _toImageUrl(
        data is Map
            ? data[isAvatar ? 'avatarUrl' : 'coverUrl']?.toString()
            : null,
      );

      setState(() {
        if (isAvatar) {
          _localAvatarBytes = imageBytes;
          _avatarUrl = uploadedUrl;
        } else {
          _localCoverBytes = imageBytes;
          _coverUrl = uploadedUrl;
        }
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAvatar ? l10n.avatarUpdated : l10n.coverPhotoUpdated),
          backgroundColor: primaryGreen,
        ),
      );
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: FarmerAppBar(
        isProfileScreen: true,
        onSettingsTap: () {
          context.push(AppRoutes.farmerSettings);
        },
      ),
      body: RefreshIndicator(
        color: primaryGreen,
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(l10n),
              const SizedBox(height: 12),
              _buildProfileInfo(l10n),
              const SizedBox(height: 20),
              _buildMetricsBar(l10n),
              const SizedBox(height: 24),
              _buildSectionTitle(l10n.dashboard),
              const SizedBox(height: 12),
              _buildDashboardGrid(l10n),
              const SizedBox(height: 28),
              _buildSectionTitle(l10n.ourSustainabilityStory),
              const SizedBox(height: 12),
              _buildStorySection(l10n),
              const SizedBox(height: 28),
              _buildOfferingsHeader(l10n),
              const SizedBox(height: 14),
              _buildCategoryChips(l10n),
              const SizedBox(height: 16),
              _buildProductGrid(l10n),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PROFILE HEADER
  // ------------------------------------------------------------

  Widget _buildProfileHeader(AppLocalizations l10n) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        GestureDetector(
          onTap: () => _showImageOptionsBottomSheet(
            context: context,
            title: l10n.coverPhotoOptions,
            isAvatar: false,
          ),
          child: SizedBox(
            height: 190,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_localCoverBytes != null)
                  Image.memory(_localCoverBytes!, fit: BoxFit.cover)
                else if (_coverUrl != null && _coverUrl!.isNotEmpty)
                  Image.network(
                    _coverUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset(_defaultCoverUrl, fit: BoxFit.cover),
                  )
                else
                  Image.asset(_defaultCoverUrl, fit: BoxFit.cover),
                Container(
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
              ],
            ),
          ),
        ),

        // --------------------------------------------------------
        // AVATAR
        // --------------------------------------------------------
        Positioned(
          bottom: -35,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: () => _showImageOptionsBottomSheet(
                  context: context,
                  title: l10n.avatarOptions,
                  isAvatar: true,
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Container(
                      width: 92,
                      height: 92,
                      color: Colors.grey.shade200,
                      child: _localAvatarBytes != null
                          ? Image.memory(
                              _localAvatarBytes!,
                              fit: BoxFit.cover,
                            )
                          : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                              ? Image.network(
                                  _avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                        _defaultAvatarUrl,
                                        fit: BoxFit.cover,
                                      ),
                                )
                              : Image.asset(
                                  _defaultAvatarUrl,
                                  fit: BoxFit.cover,
                                ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: GestureDetector(
                  onTap: () => _showImageOptionsBottomSheet(
                    context: context,
                    title: l10n.avatarOptions,
                    isAvatar: true,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // PROFILE INFO
  // ------------------------------------------------------------

  Widget _buildProfileInfo(AppLocalizations l10n) {
    final title = _businessName != null && _businessName!.isNotEmpty
        ? _businessName!
        : (_displayName.isNotEmpty ? _displayName : 'Local Producer');

    final locationDisplay = _location.isNotEmpty ? _location : 'Cambodia';

    return Column(
      children: [
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              if (_isVerified) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check_circle, color: primaryGreen, size: 20),
              ],
            ],
          ),
        ),
        if (_businessName != null &&
            _businessName!.isNotEmpty &&
            _displayName.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            _displayName,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 15,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    locationDisplay,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Text('•', style: TextStyle(color: Colors.grey)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, size: 15, color: primaryGreen),
                  const SizedBox(width: 3),
                  Text(
                    l10n.verifiedProducer,
                    style: const TextStyle(
                      color: primaryGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // METRICS
  // ------------------------------------------------------------

  Widget _buildMetricsBar(AppLocalizations l10n) {
    String formattedRevenue;
    if (_totalRevenue >= 1000) {
      formattedRevenue = '\$${(_totalRevenue / 1000).toStringAsFixed(1)}k';
    } else {
      formattedRevenue = '\$${_totalRevenue.toStringAsFixed(0)}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatTile(value: '$_orderCount', label: l10n.orders),
          ),
          _buildDivider(),
          Expanded(
            child: _StatTile(value: _rating, label: l10n.rating),
          ),
          _buildDivider(),
          Expanded(
            child: _StatTile(value: _sinceYear, label: l10n.since),
          ),
          _buildDivider(),
          Expanded(
            child: _StatTile(value: formattedRevenue, label: l10n.revenue),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 24, width: 1, color: Colors.grey.shade200);
  }

  // ------------------------------------------------------------
  // SECTION TITLE
  // ------------------------------------------------------------

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // DASHBOARD
  // ------------------------------------------------------------

  Widget _buildDashboardGrid(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 2.3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          _DashboardCard(
            icon: Icons.inventory_2_outlined,
            label: l10n.manageInventory,
            onTap: () {
              context.go(AppRoutes.farmerInventory);
            },
          ),
          _DashboardCard(
            icon: Icons.shopping_cart_outlined,
            label: l10n.viewOrders,
            onTap: () {
              context.go(AppRoutes.farmerOrders);
            },
          ),
          _DashboardCard(
            icon: Icons.insert_chart_outlined,
            label: l10n.salesAnalytics,
            onTap: () {
              context.go(AppRoutes.farmerOrders);
            },
          ),
          _DashboardCard(
            icon: Icons.credit_card_outlined,
            label: l10n.paymentSettings,
            onTap: () {
              context.push(AppRoutes.farmerSettings);
            },
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SUSTAINABILITY STORY
  // ------------------------------------------------------------

  Widget _buildStorySection(AppLocalizations l10n) {
    final storyText = _description.isNotEmpty
        ? _description
        : 'Welcome to our farm! We believe professional kitchens deserve the highest quality produce without compromising soil health. Update your bio to share your organic practices and sustainability story with buyers.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            storyText,
            style: TextStyle(
              color: Colors.grey.shade800,
              height: 1.4,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          _FeatureTile(icon: Icons.eco_outlined, text: l10n.certifiedOrganic),
          _FeatureTile(
            icon: Icons.water_drop_outlined,
            text: l10n.rainwaterIrrigationSystem,
          ),
          _FeatureTile(
            icon: Icons.local_shipping_outlined,
            text: l10n.sameDayLocalDelivery,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.sustainabilityReport.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 14),
                _ProgressRow(
                  label: l10n.pesticideFree,
                  progress: 1.0,
                  percentageText: '100%',
                ),
                const SizedBox(height: 12),
                _ProgressRow(
                  label: l10n.renewableEnergy,
                  progress: 0.85,
                  percentageText: '85%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // OFFERINGS HEADER
  // ------------------------------------------------------------

  Widget _buildOfferingsHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.currentOfferings,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.freshFromOurLocalFarm,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Add Produce',
            icon: const Icon(Icons.add_circle, color: primaryGreen, size: 28),
            onPressed: () async {
              await context.push(AppRoutes.farmerAddProduct);
              _loadProducts();
            },
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CATEGORY CHIPS
  // ------------------------------------------------------------

  Widget _buildCategoryChips(AppLocalizations l10n) {
    final categories = _getCategories(l10n);

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: primaryGreen,
              backgroundColor: cardBgColor,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // PRODUCT GRID
  // ------------------------------------------------------------

  Widget _buildProductGrid(AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(color: primaryGreen),
        ),
      );
    }

    final products = _filteredProducts(l10n);

    if (products.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.noProductsListedYet,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () async {
                  await context.push(AppRoutes.farmerAddProduct);
                  _loadProducts();
                },
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text(
                  'Add New Produce',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.74,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          return _ProductCard(
            product: products[index],
            onTap: () async {
              await context.push(
                AppRoutes.farmerProductDetail,
                extra: products[index].raw,
              );
              _loadProducts();
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// STAT TILE
// ============================================================

class _StatTile extends StatelessWidget {
  final String value;
  final String label;

  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: _FarmerProfileScreenState.primaryGreen,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ============================================================
// DASHBOARD CARD
// ============================================================

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: _FarmerProfileScreenState.cardBgColor,
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
              child: Icon(
                icon,
                color: _FarmerProfileScreenState.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FEATURE TILE
// ============================================================

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _FarmerProfileScreenState.primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROGRESS ROW
// ============================================================

class _ProgressRow extends StatelessWidget {
  final String label;
  final double progress;
  final String percentageText;

  const _ProgressRow({
    required this.label,
    required this.progress,
    required this.percentageText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              percentageText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _FarmerProfileScreenState.primaryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade300,
          color: _FarmerProfileScreenState.primaryGreen,
          minHeight: 6,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

// ============================================================
// PRODUCT CARD
// ============================================================

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const _ProductCard({required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String localizedTag;
    switch (product.tag) {
      case 'In Stock':
        localizedTag = l10n.inStock;
        break;
      case 'Organic':
        localizedTag = l10n.organic;
        break;
      case 'Fresh Harvest':
        localizedTag = l10n.freshHarvest;
        break;
      default:
        localizedTag = product.tag;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: _FarmerProfileScreenState.cardBgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: Icon(
                              Icons.eco,
                              color: _FarmerProfileScreenState.primaryGreen,
                              size: 36,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Icon(
                            Icons.eco,
                            color: _FarmerProfileScreenState.primaryGreen,
                            size: 36,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${product.price.toStringAsFixed(2)} / kg',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: _FarmerProfileScreenState.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _FarmerProfileScreenState.badgeBgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      localizedTag,
                      style: TextStyle(
                        color: product.tagColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
