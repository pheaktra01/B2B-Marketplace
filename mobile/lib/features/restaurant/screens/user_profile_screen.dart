import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/auth/screens/get_started_screen.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
import 'package:mobile/features/profile/services/user_service.dart';
import 'package:mobile/features/restaurant/widgets/restaurant_bottom_nav_bar.dart';

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

  @override
  void initState() {
    super.initState();
    _loadProfile();
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

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _displayName);
    final phoneController = TextEditingController(text: _phone);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
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
              } catch (error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update profile: $error')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
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
      body: SingleChildScrollView(
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
              style: TextStyle(
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

            // 3. Stats Row (Orders, Spent, Farmers)
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

            const SizedBox(height: 16),
          ],
        ),
      ),

      // 6. Bottom Navigation Bar
      bottomNavigationBar: const RestaurantBottomNavBar(currentIndex: 4),
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
                      : const AssetImage('assets/farm_background.png'),
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
    return Row(
      children: [
        Expanded(child: _buildStatCard('42', 'ORDERS')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('\$12.4k', 'SPENT')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('15', 'FARMERS')),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
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
    );
  }

  Widget _buildMenuList() {
    final menuItems = [
      {'icon': Icons.business_center_outlined, 'title': 'Business Profile'},
      {'icon': Icons.receipt_long_outlined, 'title': 'Order History'},
      {'icon': Icons.eco_outlined, 'title': 'Saved Farmers'},
      {'icon': Icons.payment_outlined, 'title': 'Payment Methods'},
      {'icon': Icons.bar_chart_outlined, 'title': 'Analytics'},
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
                trailing: Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                onTap: () {},
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

    // User pressed Cancel or closed the dialog
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

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const GetStartedScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Logout error: $e');

      if (!mounted) return;

      // AuthService already clears local authentication
      // even when the backend request fails.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const GetStartedScreen()),
        (route) => false,
      );
    }
  }
}
