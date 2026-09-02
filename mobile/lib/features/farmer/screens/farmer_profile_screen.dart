import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/farmer/screens/farmer_settings_screen.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
import 'package:mobile/features/farmer/widgets/farmer_bottom_nav_bar.dart';
import 'package:mobile/features/profile/services/user_service.dart';
import 'package:mobile/core/constants/api_constants.dart';

// ------------------------------------------------------------
// DATA MODELS
// ------------------------------------------------------------

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
  // FALLBACK / INITIAL PROFILE DATA
  // ------------------------------------------------------------

  String _displayName = 'Pheaktra';
  String _phone = '';

  String _location = 'Dambae, Tboung Khmum, Cambodia';

  String _description =
      'At Green Valley Organics, we believe professional kitchens deserve the highest quality produce without compromising soil health. We use advanced regenerative farming techniques, including carbon sequestration and bio-composting, to ensure every leaf and root is packed with flavor.';

  // ------------------------------------------------------------
  // IMAGE FALLBACKS
  // ------------------------------------------------------------

  final String _defaultCoverUrl =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQGo2z3rQrSISUbvCJO0kZFrymxlPHjG6lkT0EkFKM8ntPy1Ug9ZWrQzA8&s=10';

  final String _defaultAvatarUrl = 'assets/profile.png';

  String? _avatarUrl;
  String? _coverUrl;
  final UserService _userService = UserService();

  Uint8List? _localCoverBytes;
  Uint8List? _localAvatarBytes;

  // ------------------------------------------------------------
  // PRODUCTS & CATEGORIES
  // ------------------------------------------------------------

  int _selectedCategoryIndex = 0;

  late final List<Product> _products;

  final ImagePicker _picker = ImagePicker();

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _initializeProducts();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final result = await _userService.getProfile();
      final data = result['data'];
      if (!mounted || data is! Map) return;

      setState(() {
        _displayName = data['name']?.toString() ?? _displayName;
        _phone = data['phone']?.toString() ?? '';
        _avatarUrl = _toImageUrl(data['avatarUrl']?.toString());
        _coverUrl = _toImageUrl(data['coverUrl']?.toString());
      });
    } catch (error) {
      debugPrint('Failed to load profile: $error');
    }
  }

  String? _toImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    return ApiConstants.imageUrl(url);
  }

  void _initializeProducts() {
    _products = [
      Product(
        id: '1',
        name: 'Heirloom Tomatoes',
        category: 'Vegetables',
        tag: 'In Stock',
        tagColor: primaryGreen,
        imageUrl:
            'https://images.unsplash.com/photo-1592841200221-a6898f307baa?auto=format&fit=crop&q=80&w=300',
      ),
      Product(
        id: '2',
        name: 'Fresh Basil',
        category: 'Herbs & Spices',
        tag: 'Organic',
        tagColor: primaryGreen,
        imageUrl:
            'https://images.unsplash.com/photo-1608686207856-001b95cf60ca?auto=format&fit=crop&q=80&w=300',
      ),
      Product(
        id: '3',
        name: 'Baby Spinach',
        category: 'Leafy Greens',
        tag: 'Fresh Harvest',
        tagColor: primaryGreen,
        imageUrl:
            'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&q=80&w=300',
      ),
    ];
  }

  // ------------------------------------------------------------
  // LOCALIZED CATEGORIES
  // ------------------------------------------------------------

  List<String> _getCategories(AppLocalizations l10n) {
    return [
      l10n.allProduce,
      l10n.vegetables,
      l10n.herbsSpices,
      l10n.leafyGreens,
    ];
  }

  // ------------------------------------------------------------
  // FILTER PRODUCTS
  // ------------------------------------------------------------

  List<Product> _filteredProducts(AppLocalizations l10n) {
    if (_selectedCategoryIndex == 0) {
      return _products;
    }

    final categoryName = _getCategories(l10n)[_selectedCategoryIndex];

    return _products.where((product) {
      return product.category == categoryName;
    }).toList();
  }

  // ------------------------------------------------------------
  // EDIT INFORMATION DIALOG
  // ------------------------------------------------------------

  void _showEditProfileInfoDialog() {
    final l10n = AppLocalizations.of(context)!;

    final nameController = TextEditingController(text: _displayName);

    final phoneController = TextEditingController(text: _phone);

    final locationController = TextEditingController(text: _location);

    final descriptionController = TextEditingController(text: _description);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          title: Text(
            l10n.editProfileInfo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: l10n.farmProducerName),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: locationController,
                  decoration: InputDecoration(labelText: l10n.location),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.sustainabilityStoryBio,
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),

              child: Text(
                l10n.cancel,
                style: const TextStyle(color: Colors.grey),
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                if (name.isEmpty) return;

                try {
                  await _userService.updateProfile({
                    'name': name,
                    'phone': phone,
                  });
                  if (!mounted) return;
                  setState(() {
                    _displayName = name;
                    _phone = phone;
                    _location = locationController.text.trim();
                    _description = descriptionController.text.trim();
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.profileInformationUpdated),
                      backgroundColor: primaryGreen,
                    ),
                  );
                } catch (error) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update profile: $error')),
                  );
                }
              },

              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),

              child: Text(
                l10n.save,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
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
                    : Image.network(
                        isAvatar
                            ? (_avatarUrl ?? _defaultAvatarUrl)
                            : (_coverUrl ?? _defaultCoverUrl),
                        fit: BoxFit.contain,
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

      if (pickedFile == null) {
        return;
      }

      final Uint8List imageBytes = await pickedFile.readAsBytes();

      final result = isAvatar
          ? await _userService.uploadAvatar(pickedFile.path)
          : await _userService.uploadCover(pickedFile.path);
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

      if (!mounted) {
        return;
      }

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
          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (context) => const FarmerSettingsScreen(),
            ),
          );
        },
      ),

      body: SingleChildScrollView(
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

      bottomNavigationBar: const FarmerBottomNavBar(currentIndex: 4),
    );
  }

  // ------------------------------------------------------------
  // PROFILE HEADER
  // ------------------------------------------------------------

  Widget _buildProfileHeader(AppLocalizations l10n) {
    ImageProvider coverImageProvider;

    if (_localCoverBytes != null) {
      coverImageProvider = MemoryImage(_localCoverBytes!);
    } else if (_coverUrl != null) {
      coverImageProvider = NetworkImage(_coverUrl!);
    } else {
      coverImageProvider = NetworkImage(_defaultCoverUrl);
    }

    ImageProvider avatarImageProvider;

    if (_localAvatarBytes != null) {
      avatarImageProvider = MemoryImage(_localAvatarBytes!);
    } else if (_avatarUrl != null) {
      avatarImageProvider = NetworkImage(_avatarUrl!);
    } else {
      avatarImageProvider = AssetImage(_defaultAvatarUrl);
    }

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

          child: Container(
            height: 190,
            width: double.infinity,

            decoration: BoxDecoration(
              image: DecorationImage(
                image: coverImageProvider,
                fit: BoxFit.cover,
              ),
            ),

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

                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: avatarImageProvider,
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
    return Column(
      children: [
        const SizedBox(height: 32),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text(
              _displayName,

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

        Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 15,
              color: Colors.grey,
            ),

            const SizedBox(width: 2),

            Flexible(
              child: Text(
                '$_location  •  ',

                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

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

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.promoteActionTriggered)),
                );
              },

              icon: const Icon(
                Icons.campaign_outlined,
                size: 18,
                color: Colors.white,
              ),

              label: Text(
                l10n.promote,

                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),

                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(width: 12),

            OutlinedButton.icon(
              onPressed: _showEditProfileInfoDialog,

              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: primaryGreen,
              ),

              label: Text(
                l10n.editProfile,

                style: const TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),

              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,

                side: const BorderSide(color: primaryGreen, width: 1.2),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),

                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // METRICS
  // ------------------------------------------------------------

  Widget _buildMetricsBar(AppLocalizations l10n) {
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
          _StatTile(value: '120+', label: l10n.orders),

          _buildDivider(),

          _StatTile(value: '4.9 ★', label: l10n.rating),

          _buildDivider(),

          _StatTile(value: '2018', label: l10n.since),

          _buildDivider(),

          _StatTile(value: '\$4.2k', label: l10n.revenue),
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
            onTap: () {},
          ),

          _DashboardCard(
            icon: Icons.shopping_cart_outlined,
            label: l10n.viewOrders,
            onTap: () {},
          ),

          _DashboardCard(
            icon: Icons.insert_chart_outlined,
            label: l10n.salesAnalytics,
            onTap: () {},
          ),

          _DashboardCard(
            icon: Icons.credit_card_outlined,
            label: l10n.paymentSettings,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SUSTAINABILITY STORY
  // ------------------------------------------------------------

  Widget _buildStorySection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            _description,

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
    final products = _filteredProducts(l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),

      child: GridView.builder(
        shrinkWrap: true,

        physics: const NeverScrollableScrollPhysics(),

        itemCount: products.length,

        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),

        itemBuilder: (context, index) {
          return _ProductCard(product: products[index]);
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
      children: [
        Text(
          value,

          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: _FarmerProfileScreenState.primaryGreen,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,

          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
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

          Text(
            text,

            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Localized product tags.
    // The product category/name itself stays as
    // product data and should not be translated here.

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

    return Container(
      decoration: BoxDecoration(
        color: _FarmerProfileScreenState.cardBgColor,

        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),

              child: Image.network(
                product.imageUrl,

                width: double.infinity,

                fit: BoxFit.cover,
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
    );
  }
}
