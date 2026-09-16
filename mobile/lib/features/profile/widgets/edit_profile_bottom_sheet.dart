import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/profile/services/user_service.dart';

/// Modal bottom sheet for updating Farmer and Restaurant profile details,
/// including avatars, cover photos, business names, contact info, location, and bio.
Future<Map<String, dynamic>?> showEditProfileBottomSheet({
  required BuildContext context,
  required bool isFarmer,
  required String currentName,
  String? currentBusinessName,
  required String currentPhone,
  required String currentAddress,
  required String currentBio,
  String? currentAvatarUrl,
  String? currentCoverUrl,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (ctx) => EditProfileBottomSheet(
      isFarmer: isFarmer,
      currentName: currentName,
      currentBusinessName: currentBusinessName,
      currentPhone: currentPhone,
      currentAddress: currentAddress,
      currentBio: currentBio,
      currentAvatarUrl: currentAvatarUrl,
      currentCoverUrl: currentCoverUrl,
    ),
  );
}

class EditProfileBottomSheet extends StatefulWidget {
  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    required bool isFarmer,
    required String currentName,
    String? currentBusinessName,
    required String currentPhone,
    required String currentAddress,
    required String currentBio,
    String? currentAvatarUrl,
    String? currentCoverUrl,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) => EditProfileBottomSheet(
        isFarmer: isFarmer,
        currentName: currentName,
        currentBusinessName: currentBusinessName,
        currentPhone: currentPhone,
        currentAddress: currentAddress,
        currentBio: currentBio,
        currentAvatarUrl: currentAvatarUrl,
        currentCoverUrl: currentCoverUrl,
      ),
    );
  }

  final bool isFarmer;
  final String currentName;
  final String? currentBusinessName;
  final String currentPhone;
  final String currentAddress;
  final String currentBio;
  final String? currentAvatarUrl;
  final String? currentCoverUrl;

  const EditProfileBottomSheet({
    super.key,
    required this.isFarmer,
    required this.currentName,
    this.currentBusinessName,
    required this.currentPhone,
    required this.currentAddress,
    required this.currentBio,
    this.currentAvatarUrl,
    this.currentCoverUrl,
  });

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _businessNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _bioController;

  File? _newAvatarFile;
  File? _newCoverFile;

  bool _isSubmitting = false;

  Color get primaryColor => widget.isFarmer
      ? const Color(0xFF135A27) // Agriculture dark green
      : const Color(0xFF1A6B35); // Restaurant emerald green

  Color get accentColor => widget.isFarmer
      ? const Color(0xFFFF9800) // Warm harvest amber
      : const Color(0xFFE65100); // Culinary deep orange

  Color get lightBgColor => widget.isFarmer
      ? const Color(0xFFE8F5E9)
      : const Color(0xFFEAF2EB);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _businessNameController =
        TextEditingController(text: widget.currentBusinessName ?? '');
    _phoneController = TextEditingController(text: widget.currentPhone);
    _addressController = TextEditingController(text: widget.currentAddress);
    _bioController = TextEditingController(text: widget.currentBio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required bool isAvatar}) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAvatar ? 'Update Profile Picture' : 'Update Cover Banner',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt_rounded, color: primaryColor),
                ),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Use your device camera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.photo_library_rounded, color: primaryColor),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Select an existing photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (picked != null) {
        setState(() {
          if (isAvatar) {
            _newAvatarFile = File(picked.path);
          } else {
            _newCoverFile = File(picked.path);
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? updatedAvatarUrl;
      String? updatedCoverUrl;

      // 1. Upload Avatar if modified
      if (_newAvatarFile != null) {
        final res = await _userService.uploadAvatar(_newAvatarFile!.path);
        final data = res['data'];
        if (data is Map && data['avatarUrl'] != null) {
          updatedAvatarUrl = ApiConstants.imageUrl(data['avatarUrl'].toString());
        }
      }

      // 2. Upload Cover if modified
      if (_newCoverFile != null) {
        final res = await _userService.uploadCover(_newCoverFile!.path);
        final data = res['data'];
        if (data is Map && data['coverUrl'] != null) {
          updatedCoverUrl = ApiConstants.imageUrl(data['coverUrl'].toString());
        }
      }

      // 3. Update profile fields
      final name = _nameController.text.trim();
      final businessName = _businessNameController.text.trim();
      final phone = _phoneController.text.trim();
      final address = _addressController.text.trim();
      final bio = _bioController.text.trim();

      final payload = <String, dynamic>{
        'name': name,
        'businessName': businessName,
        'phone': phone,
        'address': address,
        'bio': bio,
      };

      await _userService.updateProfile(payload);

      if (!mounted) return;

      final result = <String, dynamic>{
        'name': name,
        'businessName': businessName,
        'phone': phone,
        'address': address,
        'bio': bio,
      };
      if (updatedAvatarUrl != null) {
        result['avatarUrl'] = updatedAvatarUrl;
      }
      if (updatedCoverUrl != null) {
        result['coverUrl'] = updatedCoverUrl;
      }

      Navigator.pop(context, result);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: $error'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.92;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 42,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: lightBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isFarmer
                        ? Icons.agriculture_rounded
                        : Icons.restaurant_rounded,
                    color: primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isFarmer
                            ? 'Edit Farm Profile'
                            : 'Edit Restaurant Profile',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                      Text(
                        widget.isFarmer
                            ? 'Manage your farm identity & contact information'
                            : 'Manage your restaurant details & delivery address',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: Colors.grey.shade600,
                  splashRadius: 20,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Form Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Media Section (Cover + Overlapping Avatar)
                    _buildMediaPreviewSection(),
                    const SizedBox(height: 24),

                    // Section 1: Business Identity
                    _buildSectionTitle(
                      title: widget.isFarmer
                          ? 'Farm & Business Details'
                          : 'Restaurant Brand & Identity',
                      icon: widget.isFarmer
                          ? Icons.storefront_rounded
                          : Icons.dining_rounded,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _businessNameController,
                      label: widget.isFarmer
                          ? 'Farm / Producer Name'
                          : 'Restaurant / Business Name',
                      hint: widget.isFarmer
                          ? 'e.g., Battambang Green Valley Farm'
                          : 'e.g., Siem Reap Kitchen & Grill',
                      prefixIcon: widget.isFarmer
                          ? Icons.agriculture_outlined
                          : Icons.storefront_outlined,
                      helperText: widget.isFarmer
                          ? 'Displayed prominently on marketplace listings'
                          : 'Your public restaurant or kitchen business name',
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _nameController,
                      label: widget.isFarmer
                          ? 'Owner / Contact Person Name'
                          : 'Manager / Contact Person Name',
                      hint: 'e.g., Sokha Chen',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a contact name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Section 2: Contact & Location
                    _buildSectionTitle(
                      title: 'Contact & Location',
                      icon: Icons.contact_phone_outlined,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: 'e.g., 012 345 678',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a contact phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _addressController,
                      label: widget.isFarmer
                          ? 'Farm Location / Origin'
                          : 'Restaurant / Delivery Address',
                      hint: widget.isFarmer
                          ? 'e.g., Dambae, Tboung Khmum, Cambodia'
                          : 'e.g., Street 240, Daun Penh, Phnom Penh',
                      prefixIcon: Icons.location_on_outlined,
                      helperText: widget.isFarmer
                          ? 'Helps restaurants locate local farm produce'
                          : 'Used as primary delivery address for produce orders',
                    ),
                    const SizedBox(height: 24),

                    // Section 3: Story / Bio
                    _buildSectionTitle(
                      title: widget.isFarmer
                          ? 'Sustainability & Farm Story'
                          : 'Restaurant Bio & Sourcing Needs',
                      icon: Icons.auto_stories_outlined,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _bioController,
                      label: widget.isFarmer
                          ? 'Farm Story & Produce Quality'
                          : 'Restaurant Description & Concept',
                      hint: widget.isFarmer
                          ? 'Describe your farming practices, organic cultivation, harvest frequency...'
                          : 'Describe your cuisine style, farm-to-table preferences, and fresh ingredient needs...',
                      prefixIcon: Icons.notes_rounded,
                      maxLines: 4,
                      maxLength: 400,
                    ),
                    const SizedBox(height: 28),

                    // Submit & Cancel Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: OutlinedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 19,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPreviewSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Photos & Branding',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF424242),
                ),
              ),
              Text(
                'Tap to change',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Cover Stack with Overlapping Avatar
          SizedBox(
            height: 160,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover Image
                GestureDetector(
                  onTap: () => _pickImage(isAvatar: false),
                  child: Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_newCoverFile != null)
                            Image.file(
                              _newCoverFile!,
                              fit: BoxFit.cover,
                            )
                          else if (widget.currentCoverUrl != null &&
                              widget.currentCoverUrl!.isNotEmpty)
                            Image.network(
                              widget.currentCoverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildCoverPlaceholder(),
                            )
                          else
                            _buildCoverPlaceholder(),

                          // Dark gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.4),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),

                          // Edit Cover Pill
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Cover',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
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

                // Overlapping Avatar
                Positioned(
                  left: 16,
                  bottom: 2,
                  child: GestureDetector(
                    onTap: () => _pickImage(isAvatar: true),
                    child: Stack(
                      children: [
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _newAvatarFile != null
                                ? Image.file(
                                    _newAvatarFile!,
                                    fit: BoxFit.cover,
                                  )
                                : (widget.currentAvatarUrl != null &&
                                        widget.currentAvatarUrl!.isNotEmpty)
                                    ? Image.network(
                                        widget.currentAvatarUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                _buildAvatarPlaceholder(),
                                      )
                                    : _buildAvatarPlaceholder(),
                          ),
                        ),

                        // Edit Badge
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Helper text next to avatar
                Positioned(
                  left: 112,
                  bottom: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Profile Avatar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        'Click to replace photo',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
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
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.75),
            primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          widget.isFarmer
              ? Icons.nature_people_rounded
              : Icons.restaurant_menu_rounded,
          color: Colors.white.withValues(alpha: 0.35),
          size: 48,
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: lightBgColor,
      child: Icon(
        Icons.person_rounded,
        size: 40,
        color: primaryColor.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1E1E1E)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
            ),
            helperText: helperText,
            helperMaxLines: 2,
            helperStyle: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            prefixIcon: Icon(
              prefixIcon,
              size: 20,
              color: primaryColor.withValues(alpha: 0.8),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FBFA),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: maxLines > 1 ? 12 : 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
          ),
        ),
      ],
    );
  }
}
