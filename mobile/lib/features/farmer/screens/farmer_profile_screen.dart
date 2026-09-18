import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/app_locale.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
import 'package:mobile/features/order/services/order_service.dart';
import 'package:mobile/features/product/services/product_service.dart';
import 'package:mobile/features/profile/services/user_service.dart';
import 'package:mobile/features/profile/widgets/edit_profile_bottom_sheet.dart';
import 'package:mobile/l10n/app_localizations.dart';

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
  static const Color pageBgColor = Color(0xFFF7F9F8);

  // ------------------------------------------------------------
  // SERVICES
  // ------------------------------------------------------------
  final UserService _userService = UserService();
  final OrderService _orderService = OrderService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  // ------------------------------------------------------------
  // PROFILE DATA
  // ------------------------------------------------------------
  String _userId = '';
  String _displayName = 'Farmer';
  String? _businessName;
  String _phone = '';
  String _location = '';
  String _description = '';
  bool _isVerified = true;
  String _sinceYear = '2024';

  // Metrics
  int _orderCount = 0;
  double _totalRevenue = 0.0;
  int _productCount = 0;
  final String _rating = '4.9 ★';

  // Images
  final String _defaultCoverUrl = 'assets/default_cover.jpg';
  final String _defaultAvatarUrl = 'assets/default_avatar.jpg';

  String? _avatarUrl;
  String? _coverUrl;
  Uint8List? _localCoverBytes;
  Uint8List? _localAvatarBytes;

  bool _isLoading = true;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadProfile(),
        _loadOrdersMetrics(),
        _loadProductsCount(),
      ]);
    } catch (e) {
      debugPrint('Failed to load farmer profile data: $e');
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
        _userId = data['id']?.toString() ?? _userId;
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
      debugPrint('Failed to load farmer profile: $error');
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

  Future<void> _loadProductsCount() async {
    try {
      final items = await ProductService.getMyProducts();
      if (mounted) {
        setState(() {
          _productCount = items.length;
        });
      }
    } catch (error) {
      debugPrint('Failed to load farmer products count: $error');
    }
  }

  String? _toImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    return ApiConstants.imageUrl(url);
  }

  // ------------------------------------------------------------
  // EDIT PROFILE BOTTOM SHEET
  // ------------------------------------------------------------
  Future<void> _editProfile() async {
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
  // IMAGE OPTIONS & UPLOAD
  // ------------------------------------------------------------
  void _showImageOptionsBottomSheet({
    required BuildContext context,
    required String title,
    required bool isAvatar,
  }) {
    final l10n = AppLocalizations.of(context);

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
                  vertical: 14,
                  horizontal: 20,
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
                leading: const Icon(Icons.visibility_outlined, color: primaryGreen),
                title: Text(l10n?.viewPhoto ?? 'View Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _viewPhotoFullScreen(isAvatar: isAvatar);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined, color: primaryGreen),
                title: Text(l10n?.changePhoto ?? 'Change Photo'),
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

  void _viewPhotoFullScreen({required bool isAvatar}) {
    final Uint8List? localBytes = isAvatar ? _localAvatarBytes : _localCoverBytes;

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
                                    Image.asset(_defaultAvatarUrl, fit: BoxFit.contain),
                              )
                            : Image.asset(_defaultAvatarUrl, fit: BoxFit.contain))
                        : (_coverUrl != null && _coverUrl!.isNotEmpty
                            ? Image.network(
                                _coverUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(_defaultCoverUrl, fit: BoxFit.contain),
                              )
                            : Image.asset(_defaultCoverUrl, fit: BoxFit.contain))),
              ),
              Positioned(
                top: 44,
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

  Future<void> _pickAndSavePhoto({required bool isAvatar}) async {
    final l10n = AppLocalizations.of(context);

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
          content: Text(
            isAvatar
                ? (l10n?.avatarUpdated ?? 'Avatar updated successfully')
                : (l10n?.coverPhotoUpdated ?? 'Cover photo updated successfully'),
          ),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  // ------------------------------------------------------------
  // LOG OUT
  // ------------------------------------------------------------
  Future<void> _handleLogout() async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n?.logOut ?? 'Log Out',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to log out of your farmer account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n?.cancel ?? 'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n?.logOut ?? 'Log Out',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoggingOut = true);
    try {
      await _authService.logout();
      if (!mounted) return;
      context.go(AppRoutes.login);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoggingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log out: $e')),
        );
      }
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: FarmerAppBar(
        isProfileScreen: true,
        onSettingsTap: () {
          context.push(AppRoutes.farmerSettings);
        },
      ),
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator(
              color: primaryGreen,
              backgroundColor: Colors.transparent,
              minHeight: 2.5,
            ),
          Expanded(
            child: RefreshIndicator(
              color: primaryGreen,
              onRefresh: _loadAllData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Cover & Avatar Hero
                    _buildProfileHeader(l10n),

              // 2. Profile Details & Quick Actions
              _buildProfileInfo(l10n),

              const SizedBox(height: 20),

              // 3. Stats Row
              _buildMetricsBar(l10n),

              const SizedBox(height: 24),

              // 4. Menu & Management Section
              _buildManagementMenu(l10n),

              const SizedBox(height: 24),

              // 5. Logout Button
              _buildLogoutButton(l10n),

              const SizedBox(height: 16),

              // 6. Footer branding
              Center(
                child: Text(
                  'B2B Marketplace • Farmer Edition v1.0.0',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PROFILE HEADER (COVER & AVATAR)
  // ------------------------------------------------------------
  Widget _buildProfileHeader(AppLocalizations? l10n) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Cover Photo
        GestureDetector(
          onTap: () => _showImageOptionsBottomSheet(
            context: context,
            title: l10n?.coverPhotoOptions ?? 'Cover Photo Options',
            isAvatar: false,
          ),
          child: Container(
            height: 160,
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
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
                  // Dark overlay gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),
                  // Change cover indicator
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Edit Cover',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Avatar
        Positioned(
          bottom: -44,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: () => _showImageOptionsBottomSheet(
                  context: context,
                  title: l10n?.avatarOptions ?? 'Avatar Options',
                  isAvatar: true,
                ),
                child: Container(
                  padding: const EdgeInsets.all(3.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: _localAvatarBytes != null
                          ? Image.memory(_localAvatarBytes!, fit: BoxFit.cover)
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
                    title: l10n?.avatarOptions ?? 'Avatar Options',
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
                      size: 13,
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
  // PROFILE INFO & QUICK ACTIONS
  // ------------------------------------------------------------
  Widget _buildProfileInfo(AppLocalizations? l10n) {
    final title = _businessName != null && _businessName!.isNotEmpty
        ? _businessName!
        : (_displayName.isNotEmpty ? _displayName : 'Local Farm & Producer');

    final locationDisplay =
        _location.isNotEmpty ? _location : 'Cambodia';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 52),

          // Business / Farm Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              if (_isVerified) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified, color: primaryGreen, size: 20),
              ],
            ],
          ),

          const SizedBox(height: 4),

          // Subtitle: Farmer name + Producer tag
          Text(
            _businessName != null && _businessName!.isNotEmpty
                ? '$_displayName • Farm Owner & Producer'
                : 'Agricultural Producer & Grower',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Badges: Location & Member Since
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      locationDisplay,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (_phone.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_outlined,
                        size: 13, color: primaryGreen),
                    const SizedBox(width: 4),
                    Text(
                      l10n?.verifiedProducer ?? 'Verified Farm',
                      style: const TextStyle(
                        fontSize: 12,
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Since $_sinceYear',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Farm Bio Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.format_quote_rounded,
                            size: 18, color: primaryGreen),
                        SizedBox(width: 6),
                        Text(
                          'About Farm & Practices',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: _editProfile,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        child: Text(
                          _description.isNotEmpty ? 'Edit' : 'Add Bio',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _description.isNotEmpty
                      ? _description
                      : 'Share your farming methods, organic certifications, and story with restaurant buyers.',
                  style: TextStyle(
                    fontSize: 13,
                    color: _description.isNotEmpty
                        ? Colors.grey.shade800
                        : Colors.grey.shade500,
                    fontStyle: _description.isNotEmpty
                        ? FontStyle.normal
                        : FontStyle.italic,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Quick Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _editProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(
                    l10n?.editProfile ?? 'Edit Farm Profile',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (_userId.isNotEmpty) {
                      context.push(
                        AppRoutes.restaurantFarmerProfile,
                        extra: _userId,
                      );
                    } else {
                      _editProfile();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryGreen,
                    side: const BorderSide(color: primaryGreen, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.storefront_outlined, size: 18),
                  label: const Text(
                    'Preview Store',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // FARM METRICS BAR
  // ------------------------------------------------------------
  Widget _buildMetricsBar(AppLocalizations? l10n) {
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
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricTile(
              value: '$_orderCount',
              label: (l10n?.orders ?? 'Orders').toUpperCase(),
              onTap: () => context.go(AppRoutes.farmerOrders),
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildMetricTile(
              value: formattedRevenue,
              label: (l10n?.revenue ?? 'Revenue').toUpperCase(),
              onTap: _showAnalyticsBottomSheet,
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildMetricTile(
              value: '$_productCount',
              label: 'PRODUCE',
              onTap: () => context.go(AppRoutes.farmerInventory),
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildMetricTile(
              value: _rating,
              label: (l10n?.rating ?? 'Rating').toUpperCase(),
              onTap: null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String value,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: primaryGreen,
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
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 24, width: 1, color: Colors.grey.shade200);
  }

  // ------------------------------------------------------------
  // MANAGEMENT MENU LIST
  // ------------------------------------------------------------
  Widget _buildManagementMenu(AppLocalizations? l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          _buildMenuTile(
            icon: Icons.storefront_outlined,
            title: 'Farm Business Details',
            subtitle: 'Address, business contact, and bio',
            onTap: _editProfile,
          ),
          const Divider(height: 1, indent: 56),
          _buildMenuTile(
            icon: Icons.insights_outlined,
            title: 'Sales & Revenue Analytics',
            subtitle: 'Earnings breakdown and order volume',
            onTap: _showAnalyticsBottomSheet,
          ),
          const Divider(height: 1, indent: 56),
          _buildMenuTile(
            icon: Icons.account_balance_outlined,
            title: 'Payout & Payment Methods',
            subtitle: 'Direct KHQR and settlement settings',
            onTap: _showPayoutBottomSheet,
          ),
          const Divider(height: 1, indent: 56),
          _buildMenuTile(
            icon: Icons.settings_outlined,
            title: l10n?.settings ?? 'Account Settings & Security',
            subtitle: 'Change password and account preferences',
            onTap: () {
              context.push(AppRoutes.farmerSettings);
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildMenuTile(
            icon: Icons.language_outlined,
            title: l10n?.selectLanguage ?? 'Language / ភាសា',
            subtitle: 'English / ភាសាខ្មែរ',
            onTap: _showLanguageDialog,
          ),
          const Divider(height: 1, indent: 56),
          _buildMenuTile(
            icon: Icons.help_outline_rounded,
            title: 'Help Center & Support',
            subtitle: 'Farmer guides, FAQs, and hotline',
            onTap: _showHelpSupportDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primaryGreen, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  // ------------------------------------------------------------
  // LOG OUT BUTTON
  // ------------------------------------------------------------
  Widget _buildLogoutButton(AppLocalizations? l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: _isLoggingOut ? null : _handleLogout,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade600,
            side: BorderSide(color: Colors.red.shade200, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: _isLoggingOut
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.red,
                  ),
                )
              : const Icon(Icons.logout_rounded, size: 18),
          label: Text(
            _isLoggingOut
                ? 'Logging out...'
                : (l10n?.logOut ?? 'Log Out from Farm Account'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BOTTOM SHEETS & DIALOGS
  // ------------------------------------------------------------

  void _showAnalyticsBottomSheet() {
    final avgOrderValue = _orderCount > 0 ? (_totalRevenue / _orderCount) : 0.0;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sales & Revenue Analytics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: primaryGreen.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TOTAL REVENUE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${_totalRevenue.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AVG ORDER VALUE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${avgOrderValue.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Transactions are settled directly upon order delivery through KHQR or cash.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade900,
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
      },
    );
  }

  void _showPayoutBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payout & Payment Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.qr_code_2, color: Colors.red, size: 24),
                  ),
                  title: const Text(
                    'Bakong KHQR Payments',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Active • Instant settlements directly to your bank account',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.check_circle, color: primaryGreen),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.payments_outlined, color: primaryGreen, size: 24),
                  ),
                  title: const Text(
                    'Cash On Delivery (COD)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Enabled • Collect payment in person when delivering produce',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.check_circle, color: primaryGreen),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n?.selectLanguage ?? 'Select Language'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: ValueListenableBuilder<Locale>(
            valueListenable: AppLocale.notifier,
            builder: (context, locale, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Text('🇰🇭', style: TextStyle(fontSize: 22)),
                    title: Text(l10n?.khmer ?? 'ភាសាខ្មែរ (Khmer)'),
                    trailing: locale.languageCode == 'km'
                        ? const Icon(Icons.check, color: primaryGreen)
                        : null,
                    onTap: () async {
                      await AppLocale.setLocale(const Locale('km'));
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                    },
                  ),
                  ListTile(
                    leading: const Text('🇬🇧', style: TextStyle(fontSize: 22)),
                    title: Text(l10n?.english ?? 'English'),
                    trailing: locale.languageCode == 'en'
                        ? const Icon(Icons.check, color: primaryGreen)
                        : null,
                    onTap: () async {
                      await AppLocale.setLocale(const Locale('en'));
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showHelpSupportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.headset_mic_outlined, color: primaryGreen),
            SizedBox(width: 8),
            Text('Farmer Support', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need assistance with your listings, orders, or delivery settlements?',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 16, color: primaryGreen),
                SizedBox(width: 8),
                Text('Support Hotline: +855 12 345 678', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 16, color: primaryGreen),
                SizedBox(width: 8),
                Text('support@b2bmarketplace.com', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
