import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
import 'package:mobile/features/order/models/order_model.dart';
import 'package:mobile/features/order/services/order_service.dart';
import 'package:mobile/features/product/services/favorites_service.dart';
import 'package:mobile/features/profile/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  static const Color primaryGreen = Color(0xFF135A27);
  static const Color pageBgColor = Color(0xFFF7F9F8);
  static const Color iconBgColor = Color(0xFFEAF2EB);

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final OrderService _orderService = OrderService();

  String _displayName = 'User';
  String _role = 'Restaurant';
  String _phone = '';
  String? _avatarUrl;
  String? _coverUrl;
  Uint8List? _localAvatarBytes;
  Uint8List? _localCoverBytes;
  bool _isUploadingImage = false;
  final ImagePicker _picker = ImagePicker();

  bool _isLoggingOut = false;

  // Real statistics
  int _ordersCount = 0;
  double _totalSpent = 0.0;
  int _favoritesCount = 0;
  List<OrderModel> _ordersList = [];
  bool _isLoadingStats = false;
  String _preferredPaymentMethod = 'khqr';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadStatsAndPreferences();
  }

  Future<void> _loadProfile() async {
    try {
      final result = await _userService.getProfile();
      final data = result['data'];
      if (!mounted || data is! Map) return;

      final avatar = data['avatarUrl']?.toString();
      setState(() {
        _displayName = data['name']?.toString() ?? _displayName;
        _role = data['role']?.toString() ?? _role;
        _phone = data['phone']?.toString() ?? '';
        _avatarUrl = avatar == null || avatar.isEmpty
            ? null
            : ApiConstants.imageUrl(avatar);
        final cover = data['coverUrl']?.toString();
        _coverUrl = cover == null || cover.isEmpty
            ? null
            : ApiConstants.imageUrl(cover);
      });
    } catch (error) {
      debugPrint('Failed to load restaurant profile: $error');
    }
  }

  Future<void> _loadStatsAndPreferences() async {
    setState(() => _isLoadingStats = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefPayment =
          prefs.getString('preferred_payment_method') ?? 'khqr';
      final favCount = await FavoritesService.getFavoriteCount();

      List<OrderModel> orders = [];
      try {
        orders = await _orderService.getRestaurantOrders();
      } catch (e) {
        debugPrint('Failed to load orders for stats: $e');
      }

      final totalSpent = orders.fold<double>(
        0.0,
        (sum, o) => sum + o.total,
      );

      if (!mounted) return;
      setState(() {
        _favoritesCount = favCount;
        _ordersList = orders;
        _ordersCount = orders.length;
        _totalSpent = totalSpent;
        _preferredPaymentMethod = prefPayment;
        _isLoadingStats = false;
      });
    } catch (e) {
      debugPrint('Failed to load stats: $e');
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _displayName);
    final phoneController = TextEditingController(text: _phone);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Business / Restaurant Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
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
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              try {
                final phone = phoneController.text.trim();
                await _userService.updateProfile({
                  'name': name,
                  'phone': phone,
                });
                if (!mounted) return;
                setState(() {
                  _displayName = name;
                  _phone = phone;
                });
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully'),
                    backgroundColor: primaryGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update profile: $error')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickProfileImage({required bool isAvatar}) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (pickedFile == null) return;

    setState(() => _isUploadingImage = true);
    try {
      final bytes = await pickedFile.readAsBytes();
      final result = isAvatar
          ? await _userService.uploadAvatar(pickedFile.path)
          : await _userService.uploadCover(pickedFile.path);
      final data = result['data'];
      final uploadedUrl = data is Map
          ? data[isAvatar ? 'avatarUrl' : 'coverUrl']?.toString()
          : null;

      if (!mounted) return;
      setState(() {
        if (isAvatar) {
          _localAvatarBytes = bytes;
          if (uploadedUrl != null) {
            _avatarUrl = ApiConstants.imageUrl(uploadedUrl);
          }
        } else {
          _localCoverBytes = bytes;
          if (uploadedUrl != null) {
            _coverUrl = ApiConstants.imageUrl(uploadedUrl);
          }
        }
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: FarmerAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              context.push(AppRoutes.notifications);
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/mokoto.jpg'),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primaryGreen,
        onRefresh: () async {
          await Future.wait([
            _loadProfile(),
            _loadStatsAndPreferences(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // 1. Profile Cover and Avatar
              _buildProfileAvatar(),

              const SizedBox(height: 62),

              // 2. Name and Title
              Text(
                _displayName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _role,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _editProfile,
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: const Text('Edit Profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryGreen,
                  side: const BorderSide(color: primaryGreen),
                ),
              ),

              const SizedBox(height: 24),

              // 3. Stats Row (Orders, Spent, Favorites)
              _buildStatsRow(),

              const SizedBox(height: 24),

              // 4. Menu Options List Card
              _buildMenuList(),

              const SizedBox(height: 28),

              // 5. Log Out Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isLoggingOut ? null : _handleLogout,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryGreen, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  child: _isLoggingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryGreen,
                          ),
                        )
                      : const Text(
                          'Log Out',
                          style: TextStyle(
                            color: primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildProfileAvatar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          GestureDetector(
            onTap: _isUploadingImage
                ? null
                : () => _pickProfileImage(isAvatar: false),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: _localCoverBytes != null
                      ? MemoryImage(_localCoverBytes!)
                      : _coverUrl != null
                          ? NetworkImage(_coverUrl!)
                          : const AssetImage('assets/farm_background.png')
                              as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -48,
            child: GestureDetector(
              onTap: _isUploadingImage
                  ? null
                  : () => _pickProfileImage(isAvatar: true),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF62A06E), width: 2),
                ),
                child: _localAvatarBytes != null
                    ? CircleAvatar(
                        radius: 50,
                        backgroundImage: MemoryImage(_localAvatarBytes!),
                      )
                    : _avatarUrl == null
                        ? const CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage('assets/mokoto.jpg'),
                          )
                        : CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(_avatarUrl!),
                            onBackgroundImageError: (_, _) {},
                          ),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: 76,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final spentDisplay = _isLoadingStats
        ? '...'
        : (_totalSpent >= 1000
            ? '\$${(_totalSpent / 1000).toStringAsFixed(1)}k'
            : '\$${_totalSpent.toStringAsFixed(0)}');

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            _isLoadingStats ? '...' : '$_ordersCount',
            'ORDERS',
            onTap: () => context
                .push(AppRoutes.restaurantOrders)
                .then((_) => _loadStatsAndPreferences()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            spentDisplay,
            'SPENT',
            onTap: _showAnalyticsBottomSheet,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            _isLoadingStats ? '...' : '$_favoritesCount',
            'FAVORITES',
            onTap: () => context
                .push(AppRoutes.restaurantFavorites)
                .then((_) => _loadStatsAndPreferences()),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    final menuItems = [
      {
        'icon': Icons.business_center_outlined,
        'title': 'Business Profile',
        'badge': null,
      },
      {
        'icon': Icons.receipt_long_outlined,
        'title': 'Order History',
        'badge': _ordersCount > 0 ? '$_ordersCount' : null,
      },
      {
        'icon': Icons.favorite_border_rounded,
        'title': 'Favorites Product',
        'badge': _favoritesCount > 0 ? '$_favoritesCount' : null,
      },
      {
        'icon': Icons.payment_outlined,
        'title': 'Payment Methods',
        'badge': _preferredPaymentMethod == 'khqr' ? 'KHQR' : 'COD',
      },
      {
        'icon': Icons.bar_chart_outlined,
        'title': 'Analytics',
        'badge': null,
      },
    ];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: List.generate(menuItems.length, (index) {
            final item = menuItems[index];
            final isLast = index == menuItems.length - 1;
            final badge = item['badge'] as String?;

            return Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: primaryGreen,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item['title'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: primaryGreen.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: primaryGreen,
                            ),
                          ),
                        ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                    ],
                  ),
                  onTap: () {
                    final title = item['title'] as String;
                    if (title == 'Business Profile') {
                      _showBusinessProfileBottomSheet();
                    } else if (title == 'Order History') {
                      context
                          .push(AppRoutes.restaurantOrders)
                          .then((_) => _loadStatsAndPreferences());
                    } else if (title == 'Favorites Product') {
                      context
                          .push(AppRoutes.restaurantFavorites)
                          .then((_) => _loadStatsAndPreferences());
                    } else if (title == 'Payment Methods') {
                      _showPaymentMethodsBottomSheet();
                    } else if (title == 'Analytics') {
                      _showAnalyticsBottomSheet();
                    }
                  },
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Colors.grey.shade100,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // --- BUSINESS PROFILE SHEET ---

  void _showBusinessProfileBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
          left: 20,
          right: 20,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Business Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(bottomSheetContext),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: pageBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: _avatarUrl != null
                        ? NetworkImage(_avatarUrl!)
                        : const AssetImage('assets/mokoto.jpg') as ImageProvider,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primaryGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: primaryGreen, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Verified Restaurant Buyer',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: primaryGreen,
                                ),
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
            const SizedBox(height: 16),
            _buildBusinessDetailItem(
              Icons.storefront_outlined,
              'Business Name',
              _displayName,
            ),
            _buildBusinessDetailItem(
              Icons.phone_outlined,
              'Contact Phone',
              _phone.isNotEmpty ? _phone : 'Not set',
            ),
            _buildBusinessDetailItem(
              Icons.location_on_outlined,
              'Operating Region',
              'Phnom Penh, Cambodia',
            ),
            _buildBusinessDetailItem(
              Icons.badge_outlined,
              'Account Role',
              'Commercial Restaurant & Kitchen Buyer',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(bottomSheetContext);
                  _editProfile();
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit Business Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryGreen, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
      ),
    );
  }

  // --- PAYMENT METHODS SHEET ---

  Future<void> _showPaymentMethodsBottomSheet() async {
    final prefs = await SharedPreferences.getInstance();
    String selectedMethod =
        prefs.getString('preferred_payment_method') ?? 'khqr';

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Payment Methods',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(bottomSheetContext),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Select your preferred default payment method for faster checkout.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 18),
              // Option 1: KHQR
              _buildPaymentOptionTile(
                title: 'KHQR (Bakong / QR Pay)',
                subtitle:
                    'Scan & pay instantly with any Cambodian banking app (ABA, ACLEDA, Canadia, Wing, etc.)',
                icon: Icons.qr_code_2_rounded,
                isSelected: selectedMethod == 'khqr',
                badgeText: 'Instant • Recommended',
                onTap: () async {
                  setModalState(() => selectedMethod = 'khqr');
                  await prefs.setString('preferred_payment_method', 'khqr');
                  if (mounted) {
                    setState(() => _preferredPaymentMethod = 'khqr');
                  }
                },
              ),
              const SizedBox(height: 12),
              // Option 2: Cash on Delivery
              _buildPaymentOptionTile(
                title: 'Cash on Delivery (COD)',
                subtitle:
                    'Pay cash upon receiving and inspecting produce directly at your kitchen.',
                icon: Icons.payments_outlined,
                isSelected: selectedMethod == 'cod',
                badgeText: 'Pay on Arrival',
                onTap: () async {
                  setModalState(() => selectedMethod = 'cod');
                  await prefs.setString('preferred_payment_method', 'cod');
                  if (mounted) {
                    setState(() => _preferredPaymentMethod = 'cod');
                  }
                },
              ),
              const SizedBox(height: 18),
              // Security note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryGreen.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: primaryGreen.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined,
                        color: primaryGreen, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Payments are processed securely through the National Bank of Cambodia Bakong network and direct verified vendor settlement.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(bottomSheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Default payment method set to ${selectedMethod == 'khqr' ? 'KHQR (Bakong)' : 'Cash on Delivery'}',
                        ),
                        backgroundColor: primaryGreen,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Confirm Preferred Method'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? primaryGreen.withValues(alpha: 0.04) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? primaryGreen : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? primaryGreen : iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : primaryGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? primaryGreen : Colors.grey.shade400,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ANALYTICS SHEET ---

  void _showAnalyticsBottomSheet() {
    final completedOrders = _ordersList
        .where((o) =>
            o.status.toLowerCase() == 'delivered' ||
            o.status.toLowerCase() == 'completed')
        .length;
    final activeOrders = _ordersList
        .where((o) => [
              'pending',
              'confirmed',
              'processing',
              'out_for_delivery',
              'in_transit'
            ].contains(o.status.toLowerCase()))
        .length;
    final cancelledOrders = _ordersList
        .where((o) => o.status.toLowerCase() == 'cancelled')
        .length;

    final avgOrderVal = _ordersCount > 0 ? _totalSpent / _ordersCount : 0.0;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(
          bottom: 24,
          left: 20,
          right: 20,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Purchasing Analytics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(bottomSheetContext),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Real-time spending & ordering metrics for your restaurant.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 18),
            // Metrics Row
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsMetricCard(
                    title: 'TOTAL SPENT',
                    value: '\$${_totalSpent.toStringAsFixed(2)}',
                    icon: Icons.account_balance_wallet_outlined,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildAnalyticsMetricCard(
                    title: 'ORDERS',
                    value: '$_ordersCount',
                    icon: Icons.receipt_long_outlined,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildAnalyticsMetricCard(
                    title: 'AVG ORDER',
                    value: '\$${avgOrderVal.toStringAsFixed(1)}',
                    icon: Icons.trending_up,
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Order Status Overview',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: pageBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildAnalyticsStatusRow(
                    label: 'Active / In Progress',
                    count: activeOrders,
                    total: _ordersCount,
                    color: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 10),
                  _buildAnalyticsStatusRow(
                    label: 'Delivered & Completed',
                    count: completedOrders,
                    total: _ordersCount,
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 10),
                  _buildAnalyticsStatusRow(
                    label: 'Cancelled',
                    count: cancelledOrders,
                    total: _ordersCount,
                    color: const Color(0xFFEF4444),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(bottomSheetContext);
                  context
                      .push(AppRoutes.restaurantOrders)
                      .then((_) => _loadStatsAndPreferences());
                },
                icon: const Icon(Icons.history, size: 18),
                label: const Text('View All Orders in History'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: pageBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsStatusRow({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final percentage = total > 0 ? (count / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Text(
              '$count (${total > 0 ? (percentage * 100).toStringAsFixed(0) : '0'}%)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total > 0 ? percentage : 0.0,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  // --- LOG OUT ---

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Log Out',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to log out of your account?',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isLoggingOut = true;
    });

    try {
      final result = await _authService.logout();
      debugPrint('Logout result: $result');

      if (!mounted) return;
      context.go(AppRoutes.getStarted);
    } catch (e) {
      debugPrint('Logout error: $e');
      if (!mounted) return;
      context.go(AppRoutes.getStarted);
    }
  }
}
