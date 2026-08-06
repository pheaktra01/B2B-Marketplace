import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/farmer/screens/notifications_screen.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
import 'package:mobile/features/farmer/widgets/farmer_bottom_nav_bar.dart';
import 'package:mobile/features/profile/screens/profile_screen.dart';
import 'package:mobile/features/profile/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Data Model for Products
class Product {
  final String id;
  final String name;
  final String category;
  final String tag;
  final Color tagColor;
  final String imageUrl;
  bool isLive;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.tag,
    required this.tagColor,
    required this.imageUrl,
    this.isLive = true,
  });
}

class FarmerProfileScreen extends StatefulWidget {
  final String? userId;

  const FarmerProfileScreen({super.key, this.userId});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  // Matching colors
  static const Color primaryGreen = Color(0xFF135A27);
  static const Color pageBgColor = Color(0xFFF4F6F4);
  static const Color cardBgColor = Color(0xFFF7F8F7);
  static const Color badgeBgColor = Color(0xFFEDF2EE);

  // Dynamic Data States
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'ទិន្នផលទាំងអស់',
    'បន្លែ',
    'គ្រឿងទេស',
    'បន្លែស្លឹក'
  ];

  String? _coverImageUrl;
  File? _localCoverFile;
  final String _coverFallback =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQGo2z3rQrSISUbvCJO0kZFrymxlPHjG6lkT0EkFKM8ntPy1Ug9ZWrQzA8&s=10';

  String? _avatarUrl;
  File? _localAvatarFile;
  final String _profileFallback =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT093unmUGMZ5zg74E7dxmsR9HipcSc5qKWltmRAAPVzAnMAX7Lz1KvkeE_&s=10';

  late List<Product> _products;
  final _userService = UserService();
  final ImagePicker _picker = ImagePicker();
  String? _displayName;
  String? _resolvedUserId;

  Widget _buildAvatar(String? url, double radius, {File? localFile}) {
    final placeholder = const AssetImage('assets/profile.png');

    ImageProvider imageProvider;
    if (localFile != null) {
      imageProvider = FileImage(localFile);
    } else if (url != null && url.isNotEmpty) {
      imageProvider = NetworkImage(url);
    } else {
      imageProvider = placeholder;
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: imageProvider,
      onBackgroundImageError: localFile == null && url != null && url.isNotEmpty
          ? (exception, stackTrace) {
              debugPrint('Error loading profile avatar: $exception');
            }
          : null,
    );
  }

  @override
  void initState() {
    super.initState();
    _products = [
      Product(
        id: '1',
        name: 'ប៉េងប៉ោះបុរាណ',
        category: 'បន្លែ',
        tag: 'មានក្នុងស្តុក',
        tagColor: primaryGreen,
        imageUrl:
            'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=400&q=80',
        isLive: true,
      ),
      Product(
        id: '2',
        name: 'ស្ពៃ Arugula',
        category: 'បន្លែស្លឹក',
        tag: 'មានក្នុងស្តុក',
        tagColor: primaryGreen,
        imageUrl:
            'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=400&q=80',
        isLive: true,
      ),
      Product(
        id: '3',
        name: 'ជីរនាងវង អ៊ីតាលី',
        category: 'គ្រឿងទេស',
        tag: 'ស្តុកតិច',
        tagColor: Colors.orange.shade800,
        imageUrl:
            'https://images.unsplash.com/photo-1618160702438-9b02ab6515c9?auto=format&fit=crop&w=400&q=80',
        isLive: false,
      ),
      Product(
        id: '4',
        name: 'ស្ពៃចោមស្វាយ',
        category: 'បន្លែ',
        tag: 'មានក្នុងស្តុក',
        tagColor: primaryGreen,
        imageUrl:
            'https://images.unsplash.com/photo-1524179091875-bf98a9a6ae52?auto=format&fit=crop&w=400&q=80',
        isLive: true,
      ),
    ];

    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    _resolvedUserId = widget.userId;

    if (_resolvedUserId == null || _resolvedUserId!.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('userId');
      if (storedUserId != null && storedUserId.isNotEmpty) {
        _resolvedUserId = storedUserId;
      }
    }

    if (!mounted) return;

    if (_resolvedUserId != null && _resolvedUserId!.isNotEmpty) {
      await _loadProfile(_resolvedUserId!);
    } else {
      setState(() {
        _displayName = 'Green Valley Organics';
      });
    }
  }

  Future<void> _loadProfile(String userId) async {
    try {
      final res = await _userService.getProfile(userId);
      if (res['statusCode'] == 200) {
        final data = res['data'] as Map<String, dynamic>;
        _displayName = data['name'] ?? 'Unnamed';
        final avatar = data['avatarUrl'] as String?;
        if (avatar != null && avatar.isNotEmpty) {
          _avatarUrl = avatar.startsWith('http')
              ? avatar
              : '${ApiConstants.baseUrl}$avatar';
        }
        final cover = data['coverUrl'] as String?;
        if (cover != null && cover.isNotEmpty) {
          _coverImageUrl = cover.startsWith('http')
              ? cover
              : '${ApiConstants.baseUrl}$cover';
        }
        setState(() {});
      }
    } catch (e) {
      // Keep defaults on failure
    }
  }

  String? get _activeUserId {
    if (_resolvedUserId != null && _resolvedUserId!.isNotEmpty) {
      return _resolvedUserId;
    }
    if (widget.userId != null && widget.userId!.isNotEmpty) {
      return widget.userId;
    }
    return null;
  }

  List<Product> get _filteredProducts {
    if (_selectedCategoryIndex == 0) return _products;
    final categoryName = _categories[_selectedCategoryIndex];
    return _products.where((p) => p.category == categoryName).toList();
  }

  // --- Image Handling Helpers ---

  void _showImageOptionsBottomSheet({
    required BuildContext context,
    required String title,
    required bool isAvatar,
  }) {
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
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.visibility, color: primaryGreen),
                title: const Text('មើលរូបភាព (View Photo)'),
                onTap: () {
                  Navigator.pop(ctx);
                  _viewPhotoFullScreen(isAvatar: isAvatar);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: primaryGreen),
                title: const Text('ផ្លាស់ប្តូររូបភាព (Change Photo)'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickCropAndSavePhoto(isAvatar: isAvatar);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _viewPhotoFullScreen({required bool isAvatar}) {
    final String? remoteUrl = isAvatar ? _avatarUrl : _coverImageUrl;
    final File? localFile = isAvatar ? _localAvatarFile : _localCoverFile;
    final String fallback = isAvatar ? _profileFallback : _coverFallback;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: localFile != null
                  ? Image.file(localFile, fit: BoxFit.contain)
                  : Image.network(
                      remoteUrl ?? fallback,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Image.network(fallback),
                    ),
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
      ),
    );
  }

  Future<void> _pickCropAndSavePhoto({required bool isAvatar}) async {
    try {
      // 1. Pick image from gallery
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      // 2. Crop image to 4x4 (1:1 aspect ratio)
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // 4x4 / 1:1 ratio
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: isAvatar ? 'កាត់រូបភាពគណនី' : 'កាត់រូបភាពគម្រប',
            toolbarColor: primaryGreen,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: isAvatar ? 'កាត់រូបភាពគណនី' : 'កាត់រូបភាពគម្រប',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile == null) return;

      final File croppedImageFile = File(croppedFile.path);

      if (!mounted) return;

      // 3. Show preview dialog with Save and Cancel options
      final bool? confirmSave = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isAvatar ? 'មើលរូបភាពគណនីថ្មី' : 'មើលរូបភាពគម្របថ្មី',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(isAvatar ? 100 : 12),
                child: Image.file(
                  croppedImageFile,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              const Text('តើអ្នកពិតជាចង់ផ្លាស់ប្តូររូបភាពនេះមែនទេ?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false), // Cancel
              child: const Text('បោះបង់ (Cancel)', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true), // Save
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('រក្សាទុក (Save)', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      // 4. Update image if user clicks Save; keep previous state if Cancelled
      if (confirmSave == true) {
        setState(() {
          if (isAvatar) {
            _localAvatarFile = croppedImageFile;
          } else {
            _localCoverFile = croppedImageFile;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAvatar
                  ? 'បានផ្លាស់ប្តូររូបភាពគណនីជោគជ័យ'
                  : 'បានផ្លាស់ប្តូររូបភាពគម្របជោគជ័យ',
            ),
            backgroundColor: primaryGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking or cropping image: $e');
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildAvatar(_avatarUrl, 18, localFile: _localAvatarFile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Banner & Profile Image
            _buildProfileHeader(),

            const SizedBox(height: 12),

            // 2. Title, Badges, and Action Buttons
            _buildProfileInfo(),

            const SizedBox(height: 20),

            // 3. Key Metrics Bar
            _buildMetricsBar(),

            const SizedBox(height: 24),

            // 4. Management Dashboard Grid
            _buildSectionTitle('ផ្ទាំងគ្រប់គ្រង'),
            const SizedBox(height: 12),
            _buildDashboardGrid(),

            const SizedBox(height: 28),

            // 5. Our Sustainable Story Section
            _buildSectionTitle('រឿងរ៉ាវនិរន្តរភាពរបស់យើង'),
            const SizedBox(height: 12),
            _buildStorySection(),

            const SizedBox(height: 28),

            // 6. Current Offerings (Products)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    'ផលិតផលបច្ចុប្បន្ន',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('មើលទាំងអស់ - View All Clicked')),
                      );
                    },
                    child: const Text(
                      'មើលទាំងអស់ >',
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'ស្រស់ៗពីកសិដ្ឋាន Hudson Valley របស់យើង',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            const SizedBox(height: 14),
            _buildCategoryChips(),
            const SizedBox(height: 16),
            _buildProductGrid(),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const FarmerBottomNavBar(
        currentIndex: 4,
      ),
    );
  }

  // Helper: Profile Banner and Avatar Stack
  Widget _buildProfileHeader() {
    ImageProvider coverImageProvider;
    if (_localCoverFile != null) {
      coverImageProvider = FileImage(_localCoverFile!);
    } else {
      coverImageProvider = NetworkImage(_coverImageUrl ?? _coverFallback);
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Cover Image Gesture Target
        GestureDetector(
          onTap: () => _showImageOptionsBottomSheet(
            context: context,
            title: 'ជម្រើសរូបភាពគម្រប (Cover Options)',
            isAvatar: false,
          ),
          child: Container(
            height: 190,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: coverImageProvider,
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
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
                ),
                Positioned(
                  top: 12,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ចែករំលែកប្រវត្តិរូប (Share profile)')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.share, size: 14, color: Colors.black87),
                          SizedBox(width: 6),
                          Text('ចែករំលែក', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => _showImageOptionsBottomSheet(
                      context: context,
                      title: 'ជម្រើសរូបភាពគម្រប (Cover Options)',
                      isAvatar: false,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, size: 14, color: Colors.black87),
                          SizedBox(width: 6),
                          Text('កែប្រែរូបគម្រប', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Avatar Gesture Target
        Positioned(
          bottom: -35,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: () => _showImageOptionsBottomSheet(
                  context: context,
                  title: 'ជម្រើសរូបភាពគណនី (Avatar Options)',
                  isAvatar: true,
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: _buildAvatar(_avatarUrl ?? _profileFallback, 46, localFile: _localAvatarFile),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: GestureDetector(
                  onTap: () => _showImageOptionsBottomSheet(
                    context: context,
                    title: 'ជម្រើសរូបភាពគណនី (Avatar Options)',
                    isAvatar: true,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper: Title, Badges, and Buttons
  Widget _buildProfileInfo() {
    return Column(
      children: [
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _displayName ?? 'Green Valley Organics',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.check_circle, color: primaryGreen, size: 20),
          ],
        ),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_outlined, size: 15, color: Colors.grey),
            SizedBox(width: 2),
            Text(
              'Hudson Valley, NY  •  ',
              style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Icon(Icons.verified, size: 15, color: primaryGreen),
            SizedBox(width: 3),
            Text(
              'អ្នកផលិតផ្លូវការ',
              style: TextStyle(color: primaryGreen, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ផ្សព្វផ្សាយ (Promote)')),
                );
              },
              icon: const Icon(Icons.campaign_outlined, size: 18, color: Colors.white),
              label: const Text(
                'ផ្សព្វផ្សាយ',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final userId = _activeUserId;
                if (userId == null) return;
                final changed = await Navigator.push<bool?>(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen(userId: userId)),
                );
                if (changed == true) await _loadProfile(userId);
              },
              icon: const Icon(Icons.edit_outlined, size: 18, color: primaryGreen),
              label: const Text(
                'កែប្រែប្រវត្តិរូប',
                style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: primaryGreen, width: 1.2),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper: Metrics Bar
  Widget _buildMetricsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn('120+', 'ការកុម្ម៉ង់'),
          _buildDivider(),
          _buildStatColumn('4.9 ★', 'ការវាយតម្លៃ'),
          _buildDivider(),
          _buildStatColumn('2018', 'ចាប់តាំងពី'),
          _buildDivider(),
          _buildStatColumn('\$4.2k', 'ចំណូល'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryGreen),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 24, width: 1, color: Colors.grey.shade200);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  // Helper: Dashboard Grid Items with onTap navigation handlers
  Widget _buildDashboardGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 2.3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          _buildDashboardCard(Icons.inventory_2_outlined, 'គ្រប់គ្រងស្តុក', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('គ្រប់គ្រងស្តុក (Inventory)')),
            );
          }),
          _buildDashboardCard(Icons.shopping_cart_outlined, 'មើលការកុម្ម៉ង់', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('មើលការកុម្ម៉ង់ (Orders)')),
            );
          }),
          _buildDashboardCard(Icons.insert_chart_outlined, 'ការវិភាគការលក់', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ការវិភាគការលក់ (Analytics)')),
            );
          }),
          _buildDashboardCard(Icons.credit_card_outlined, 'ការកំណត់ការទូទាត់', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ការកំណត់ការទូទាត់ (Payments)')),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: cardBgColor,
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
              child: Icon(icon, color: primaryGreen, size: 20),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Story Section
  Widget _buildStorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'នៅ Green Valley Organics យើងជឿជាក់ថាផ្ទះបាយអាជីពសក្តិសមទទួលបានបន្លែផ្លែឈើគុណភាពខ្ពស់បំផុត ដោយមិនប៉ះពាល់ដល់សុខភាពដីរបស់យើង។ យើងប្រើប្រាស់បច្ចេកទេសកសិកម្មកែប្រែឡើងវិញកម្រិតខ្ពស់ រួមទាំងការរក្សាទុកកាបូន និងជីកំប៉ុសជីវៈ ដើម្បីធានាថាគ្រប់ស្លឹក និងឫសពោរពេញដោយរសជាតិ។',
            style: TextStyle(color: Colors.grey.shade800, height: 1.4, fontSize: 13),
          ),
          const SizedBox(height: 14),
          _buildFeatureTile(Icons.eco_outlined, 'ទទួលស្គាល់ជាសរីរាង្គ'),
          _buildFeatureTile(Icons.water_drop_outlined, 'ប្រព័ន្ធស្រោចស្រពទឹកភ្លៀង'),
          _buildFeatureTile(Icons.local_shipping_outlined, 'ការផ្គត់ផ្គង់ភ្លាមៗក្នុងថ្ងៃ'),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'របាយការណ៍និរន្តរភាព',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 14),
                _buildProgressRow('គ្មានថ្នាំកសិកម្ម', 1.0, '100%'),
                const SizedBox(height: 12),
                _buildProgressRow('ថាមពលកកើតឡើងវិញ', 0.85, '85%'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('មើលរបាយការណ៍ផលប៉ះពាល់ពេញលេញ')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('របាយការណ៍ផលប៉ះពាល់ពេញលេញ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: badgeBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryGreen, size: 16),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, double value, String percentText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text(percentText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryGreen)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade200,
            color: primaryGreen,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  // Helper: Dynamic Category Chips
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 34,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategoryIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper: Dynamic Product Grid
  Widget _buildProductGrid() {
    final productsToShow = _filteredProducts;

    if (productsToShow.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Text('មិនមានផលិតផលទេ (No products available)'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: productsToShow.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final item = productsToShow[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          item.imageUrl,
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.tagColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.tag,
                            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.category,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}