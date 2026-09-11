import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/features/profile/services/user_service.dart';

class SetupProfileScreen extends StatefulWidget {
  final String role;

  const SetupProfileScreen({
    super.key,
    required this.role,
  });

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  final _picker = ImagePicker();

  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;

  bool get isFarmer => widget.role == 'farmer';

  @override
  void dispose() {
    _businessNameController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('មិនអាចជ្រើសរើសរូបភាពបានទេ: $e')),
      );
    }
  }

  void _navigateToDashboard() {
    if (!mounted) return;
    if (isFarmer) {
      context.go(AppRoutes.farmerDashboard);
    } else {
      context.go(AppRoutes.restaurantHome);
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    final messenger = ScaffoldMessenger.of(context);

    try {
      // 1. Upload avatar if selected
      if (_imageFile != null) {
        await _userService.uploadAvatar(_imageFile!.path);
      }

      // 2. Update profile details if provided
      final Map<String, dynamic> updateData = {};
      final businessName = _businessNameController.text.trim();
      final address = _addressController.text.trim();
      final bio = _bioController.text.trim();

      if (businessName.isNotEmpty) {
        updateData['businessName'] = businessName;
      }
      if (address.isNotEmpty) {
        updateData['address'] = address;
      }
      if (bio.isNotEmpty) {
        updateData['bio'] = bio;
      }

      if (updateData.isNotEmpty) {
        await _userService.updateProfile(updateData);
      }

      _navigateToDashboard();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('មានបញ្ហាក្នុងការរក្សាទុកព័ត៌មាន: $e')),
      );
      // Still allow proceeding even if optional profile update encountered an issue
      _navigateToDashboard();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF0F6221);
    const bgLight = Color(0xFFF8FAFC);
    const textDark = Color(0xFF0F172A);
    const textMuted = Color(0xFF64748B);
    const borderColor = Color(0xFFE2E8F0);

    final titleRole = isFarmer ? 'កសិដ្ឋាន' : 'ភោជនីយដ្ឋាន';

    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktopOrTablet = constraints.maxWidth > 600;

            return Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktopOrTablet ? 24.0 : 16.0,
                  vertical: isDesktopOrTablet ? 32.0 : 20.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Container(
                    padding: EdgeInsets.all(isDesktopOrTablet ? 32.0 : 24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: borderColor, width: 0.5),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Step badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: brandGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 16,
                                  color: brandGreen,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'គណនីបានបង្កើតជោគជ័យ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: brandGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Heading
                          const Text(
                            'រៀបចំកម្រងព័ត៌មានរបស់អ្នក',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'បន្ថែមរូបតំណាង និងព័ត៌មាន$titleRoleរបស់អ្នក ដើម្បីបង្កើនទំនុកចិត្តលើទីផ្សារ',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: textMuted,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Avatar Picker Section
                          Center(
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: brandGreen.withValues(alpha: 0.3),
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: _imageFile != null
                                        ? Image.file(
                                            _imageFile!,
                                            fit: BoxFit.cover,
                                            width: 110,
                                            height: 110,
                                          )
                                        : Container(
                                            color: const Color(0xFFF1F5F9),
                                            child: Icon(
                                              isFarmer
                                                  ? Icons.agriculture
                                                  : Icons.storefront,
                                              size: 50,
                                              color: brandGreen.withValues(alpha: 0.7),
                                            ),
                                          ),
                                  ),
                                ),
                                Material(
                                  color: brandGreen,
                                  shape: const CircleBorder(),
                                  elevation: 3,
                                  child: InkWell(
                                    onTap: _pickImage,
                                    customBorder: const CircleBorder(),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          GestureDetector(
                            onTap: _pickImage,
                            child: Text(
                              _imageFile != null
                                  ? 'ផ្លាស់ប្តូររូបថត'
                                  : 'ជ្រើសរើសរូបតំណាង (Avatar)',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: brandGreen,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Business / Enterprise Name Input
                          _buildTextField(
                            label: 'ឈ្មោះ$titleRole',
                            hint: isFarmer
                                ? 'ឧ. កសិដ្ឋានធម្មជាតិបាត់ដំបង'
                                : 'ឧ. ភោជនីយដ្ឋានខ្មែរអង្គរ',
                            icon: isFarmer
                                ? Icons.agriculture_outlined
                                : Icons.storefront_outlined,
                            controller: _businessNameController,
                          ),

                          const SizedBox(height: 16),

                          // Address Input
                          _buildTextField(
                            label: 'អាសយដ្ឋាន / ទីតាំង',
                            hint: 'ឧ. រាជធានីភ្នំពេញ ឬខេត្ត...',
                            icon: Icons.location_on_outlined,
                            controller: _addressController,
                          ),

                          const SizedBox(height: 16),

                          // Bio / Description Input
                          _buildTextField(
                            label: 'ការពិពណ៌នាសង្ខេប',
                            hint: isFarmer
                                ? 'រៀបរាប់ខ្លីៗអំពីកសិផលដែលអ្នកដាំដុះ...'
                                : 'រៀបរាប់ខ្លីៗអំពីមុខម្ហូប ឬសេចក្តីត្រូវការរបស់អ្នក...',
                            icon: Icons.notes_outlined,
                            controller: _bioController,
                            maxLines: 3,
                          ),

                          const SizedBox(height: 32),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brandGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _isLoading ? null : _saveProfile,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'រក្សាទុក និងចាប់ផ្តើម',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Skip button
                          TextButton(
                            onPressed: _isLoading ? null : _navigateToDashboard,
                            child: const Text(
                              'រំលងពេលនេះ (បំពេញនៅពេលក្រោយ)',
                              style: TextStyle(
                                fontSize: 13,
                                color: textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF0F6221), size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 14 : 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0F6221), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
