import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/features/farmer/screens/farmer_settings_screen.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
import 'package:mobile/features/farmer/widgets/farmer_bottom_nav_bar.dart';

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
  // Theme Colors
  static const Color primaryGreen = Color(0xFF135A27);
  static const Color pageBgColor = Color(0xFFF4F6F4);
  static const Color cardBgColor = Color(0xFFF7F8F7);
  static const Color badgeBgColor = Color(0xFFEDF2EE);

  // Fallback / Initial Static Profile Data
  String _displayName = 'Green Valley Organics';
  String _location = 'Hudson Valley, NY';
  String _description =
      'At Green Valley Organics, we believe professional kitchens deserve the highest quality produce without compromising soil health. We use advanced regenerative farming techniques, including carbon sequestration and bio-composting, to ensure every leaf and root is packed with flavor.';

  // Image Fallbacks & State
  final String _defaultCoverUrl =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQGo2z3rQrSISUbvCJO0kZFrymxlPHjG6lkT0EkFKM8ntPy1Ug9ZWrQzA8&s=10';
  final String _defaultAvatarUrl =
      'assets/profile.png'; // Local asset for default avatar

  // Uint8List allows cross-platform rendering (Web + Mobile) via Image.memory
  Uint8List? _localCoverBytes;
  Uint8List? _localAvatarBytes;

  // Products & Categories
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'All Produce',
    'Vegetables',
    'Herbs & Spices',
    'Leafy Greens',
  ];

  late final List<Product> _products;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeProducts();
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

  List<Product> get _filteredProducts {
    if (_selectedCategoryIndex == 0) return _products;
    final categoryName = _categories[_selectedCategoryIndex];
    return _products.where((p) => p.category == categoryName).toList();
  }

  // ------------------------------------------------------------
  // EDIT INFORMATION DIALOG
  // ------------------------------------------------------------
  void _showEditProfileInfoDialog() {
    final nameController = TextEditingController(text: _displayName);
    final locationController = TextEditingController(text: _location);
    final descriptionController = TextEditingController(text: _description);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Profile Info', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Farm / Producer Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Sustainability Story / Bio'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _displayName = nameController.text.trim();
                  _location = locationController.text.trim();
                  _description = descriptionController.text.trim();
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile information updated!'),
                    backgroundColor: primaryGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // IMAGE HANDLING
  // ------------------------------------------------------------
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
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.visibility, color: primaryGreen),
                title: const Text('View Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _viewPhotoFullScreen(isAvatar: isAvatar);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: primaryGreen),
                title: const Text('Change Photo'),
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
                    : Image.network(
                        isAvatar ? _defaultAvatarUrl : _defaultCoverUrl,
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

  Future<void> _pickAndSavePhoto({required bool isAvatar}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (pickedFile == null) return;

      // Read bytes directly from the picked file
      final Uint8List imageBytes = await pickedFile.readAsBytes();

      setState(() {
        if (isAvatar) {
          _localAvatarBytes = imageBytes;
        } else {
          _localCoverBytes = imageBytes;
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAvatar ? 'Avatar updated!' : 'Cover photo updated!',
          ),
          backgroundColor: primaryGreen,
        ),
      );
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  // ------------------------------------------------------------
  // BUILD METHOD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
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
            _buildProfileHeader(),
            const SizedBox(height: 12),
            _buildProfileInfo(),
            const SizedBox(height: 20),
            _buildMetricsBar(),
            const SizedBox(height: 24),
            _buildSectionTitle('Dashboard'),
            const SizedBox(height: 12),
            _buildDashboardGrid(),
            const SizedBox(height: 28),
            _buildSectionTitle('Our Sustainability Story'),
            const SizedBox(height: 12),
            _buildStorySection(),
            const SizedBox(height: 28),
            _buildOfferingsHeader(),
            const SizedBox(height: 14),
            _buildCategoryChips(),
            const SizedBox(height: 16),
            _buildProductGrid(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const FarmerBottomNavBar(currentIndex: 4),
    );
  }

  // ------------------------------------------------------------
  // UI COMPONENTS
  // ------------------------------------------------------------

  Widget _buildProfileHeader() {
    ImageProvider coverImageProvider;
    if (_localCoverBytes != null) {
      coverImageProvider = MemoryImage(_localCoverBytes!);
    } else {
      coverImageProvider = NetworkImage(_defaultCoverUrl);
    }

    ImageProvider avatarImageProvider;
    if (_localAvatarBytes != null) {
      avatarImageProvider = MemoryImage(_localAvatarBytes!);
    } else {
      avatarImageProvider = NetworkImage(_defaultAvatarUrl);
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        GestureDetector(
          onTap: () => _showImageOptionsBottomSheet(
            context: context,
            title: 'Cover Photo Options',
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

        // Avatar Overlay
        Positioned(
          bottom: -35,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: () => _showImageOptionsBottomSheet(
                  context: context,
                  title: 'Avatar Options',
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
                    title: 'Avatar Options',
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

  Widget _buildProfileInfo() {
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
            const Icon(Icons.location_on_outlined, size: 15, color: Colors.grey),
            const SizedBox(width: 2),
            Text(
              '$_location  •  ',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.verified, size: 15, color: primaryGreen),
            const SizedBox(width: 3),
            const Text(
              'Verified Producer',
              style: TextStyle(
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
                  const SnackBar(content: Text('Promote Action Triggered')),
                );
              },
              icon: const Icon(Icons.campaign_outlined, size: 18, color: Colors.white),
              label: const Text('Promote', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _showEditProfileInfoDialog,
              icon: const Icon(Icons.edit_outlined, size: 18, color: primaryGreen),
              label: const Text('Edit Profile', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: primaryGreen, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

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
          const _StatTile(value: '120+', label: 'Orders'),
          _buildDivider(),
          const _StatTile(value: '4.9 ★', label: 'Rating'),
          _buildDivider(),
          const _StatTile(value: '2018', label: 'Since'),
          _buildDivider(),
          const _StatTile(value: '\$4.2k', label: 'Revenue'),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 24, width: 1, color: Colors.grey.shade200);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildDashboardGrid() {
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
            label: 'Manage Inventory',
            onTap: () {},
          ),
          _DashboardCard(
            icon: Icons.shopping_cart_outlined,
            label: 'View Orders',
            onTap: () {},
          ),
          _DashboardCard(
            icon: Icons.insert_chart_outlined,
            label: 'Sales Analytics',
            onTap: () {},
          ),
          _DashboardCard(
            icon: Icons.credit_card_outlined,
            label: 'Payment Settings',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _description,
            style: TextStyle(color: Colors.grey.shade800, height: 1.4, fontSize: 13),
          ),
          const SizedBox(height: 14),
          const _FeatureTile(icon: Icons.eco_outlined, text: 'Certified Organic'),
          const _FeatureTile(icon: Icons.water_drop_outlined, text: 'Rainwater Irrigation System'),
          const _FeatureTile(icon: Icons.local_shipping_outlined, text: 'Same-Day Local Delivery'),
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
                const Text(
                  'SUSTAINABILITY REPORT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 14),
                const _ProgressRow(label: 'Pesticide Free', progress: 1.0, percentageText: '100%'),
                const SizedBox(height: 12),
                const _ProgressRow(label: 'Renewable Energy', progress: 0.85, percentageText: '85%'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferingsHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Offerings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          SizedBox(height: 2),
          Text('Fresh from our local farm', style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                _categories[index],
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
                if (selected) setState(() => _selectedCategoryIndex = index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    final products = _filteredProducts;
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
        itemBuilder: (context, index) => _ProductCard(product: products[index]),
      ),
    );
  }
}

// ------------------------------------------------------------
// REUSABLE SUB-WIDGETS
// ------------------------------------------------------------

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
              child: Icon(icon, color: _FarmerProfileScreenState.primaryGreen, size: 20),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
          Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

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
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _FarmerProfileScreenState.badgeBgColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.tag,
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