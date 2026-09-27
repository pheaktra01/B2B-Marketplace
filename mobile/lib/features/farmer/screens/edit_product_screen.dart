import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/product/services/product_service.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color bgGrey = Color(0xFFF7F9F7);
  static const int maxImages = 5;

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _minOrderController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _deliveryFeeController;

  late String _category;
  late String _condition;
  late String _deliveryMethod;
  late bool _isAvailable;
  DateTime? _harvestDate;
  DateTime? _availableUntil;

  // Existing image URLs hosted on server
  late List<String> _existingImages;
  // Newly picked image files to upload
  final List<XFile> _newImages = [];

  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = const [
    'Vegetables',
    'Microgreens',
    'Fruits',
    'Herbs & Spices',
    'Rice & Grains',
    'Eggs & Dairy',
    'Leafy Greens',
    'Other',
  ];

  final List<String> _deliveryMethods = const [
    'Farmer Delivery',
    'Buyer Pickup',
    'Both',
  ];

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _nameController = TextEditingController(
      text: product['name']?.toString() ?? '',
    );

    _priceController = TextEditingController(
      text: product['price']?.toString() ?? '',
    );

    _quantityController = TextEditingController(
      text: product['quantity']?.toString() ?? '',
    );

    _minOrderController = TextEditingController(
      text: product['minOrder']?.toString() ?? '',
    );

    _descriptionController = TextEditingController(
      text: product['description']?.toString() ?? '',
    );

    _locationController = TextEditingController(
      text: product['location']?.toString() ?? '',
    );

    _deliveryFeeController = TextEditingController(
      text: product['deliveryFee']?.toString() ?? '0.00',
    );

    _category = product['category']?.toString() ?? 'Vegetables';
    if (!_categories.contains(_category)) {
      _category = 'Other';
    }

    _condition = product['condition']?.toString() ?? 'Fresh';

    _deliveryMethod = product['deliveryMethod']?.toString() ?? 'Farmer Delivery';
    if (!_deliveryMethods.contains(_deliveryMethod)) {
      _deliveryMethod = 'Farmer Delivery';
    }

    _isAvailable = product['isAvailable'] != false;

    if (product['harvestDate'] != null) {
      _harvestDate = DateTime.tryParse(product['harvestDate'].toString());
    }

    if (product['availableUntil'] != null) {
      _availableUntil = DateTime.tryParse(product['availableUntil'].toString());
    }

    // Extract existing image URLs
    final rawImages = product['imageUrls'] ?? product['images'];
    if (rawImages is List) {
      _existingImages = rawImages
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (product['imageUrl'] != null &&
        product['imageUrl'].toString().trim().isNotEmpty) {
      _existingImages = [product['imageUrl'].toString().trim()];
    } else {
      _existingImages = [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _minOrderController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _deliveryFeeController.dispose();
    super.dispose();
  }

  // ============================================================
  // IMAGE PICKING
  // ============================================================

  int get _totalImagesCount => _existingImages.length + _newImages.length;

  Future<void> _showImagePickerModal() async {
    final remaining = maxImages - _totalImagesCount;
    if (remaining <= 0) {
      _showMessage('Maximum of $maxImages photos reached.');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Product Photos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_totalImagesCount / $maxImages',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'You can add up to $remaining more photo${remaining > 1 ? 's' : ''}.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: primaryGreen,
                  ),
                ),
                title: const Text(
                  'Take Photo with Camera',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromCamera();
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: primaryGreen,
                  ),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromGallery(remaining);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (photo != null) {
        setState(() {
          _newImages.add(photo);
        });
      }
    } catch (e) {
      _showMessage('Failed to capture photo: $e');
    }
  }

  Future<void> _pickFromGallery(int remaining) async {
    try {
      final List<XFile> photos = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (photos.isNotEmpty) {
        setState(() {
          _newImages.addAll(photos.take(remaining));
        });
      }
    } catch (e) {
      _showMessage('Failed to select photos: $e');
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  // ============================================================
  // DATE PICKERS
  // ============================================================

  Future<void> _selectDate({required bool isHarvest}) async {
    final now = DateTime.now();
    final initialDate = isHarvest
        ? (_harvestDate ?? now)
        : (_availableUntil ?? now.add(const Duration(days: 14)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isHarvest) {
          _harvestDate = picked;
        } else {
          _availableUntil = picked;
        }
      });
    }
  }

  // ============================================================
  // SAVE PRODUCT
  // ============================================================

  Future<void> _saveProduct() async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final quantity = double.tryParse(_quantityController.text.trim());
    final minOrder = double.tryParse(_minOrderController.text.trim()) ?? 0;
    final deliveryFee = double.tryParse(_deliveryFeeController.text.trim()) ?? 0;

    if (name.isEmpty) {
      _showMessage('Please enter a product name.');
      return;
    }

    if (price == null || price < 0) {
      _showMessage('Please enter a valid price.');
      return;
    }

    if (quantity == null || quantity < 0) {
      _showMessage('Please enter a valid available quantity.');
      return;
    }

    if (_totalImagesCount == 0) {
      _showMessage('Please add or keep at least one product photo.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final id = widget.product['id']?.toString();
      if (id == null) {
        throw Exception('Product ID not found.');
      }

      final Map<String, dynamic> data = {
        'name': name,
        'price': price,
        'quantity': quantity,
        'minOrder': minOrder,
        'description': _descriptionController.text.trim(),
        'category': _category,
        'condition': _condition,
        'location': _locationController.text.trim(),
        'deliveryMethod': _deliveryMethod,
        'deliveryFee': deliveryFee,
        'isAvailable': _isAvailable,
      };

      if (_harvestDate != null) {
        data['harvestDate'] = _harvestDate!.toIso8601String();
      }
      if (_availableUntil != null) {
        data['availableUntil'] = _availableUntil!.toIso8601String();
      }

      await ProductService.updateProduct(
        productId: id,
        data: data,
        existingImages: _existingImages,
        newImages: _newImages,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Product updated successfully!'),
            ],
          ),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      _showMessage('Failed to update product: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black87,
          ),
          onPressed: _isSaving ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Product',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProduct,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primaryGreen,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: primaryGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
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
                        _buildPhotosSection(),
                        const SizedBox(height: 16),
                        _buildBasicInfoSection(),
                        const SizedBox(height: 16),
                        _buildPricingInventorySection(),
                        const SizedBox(height: 16),
                        _buildDeliverySection(),
                        const SizedBox(height: 16),
                        _buildAvailabilitySection(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION: PHOTOS
  // ============================================================

  Widget _buildPhotosSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: primaryGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Product Photos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _totalImagesCount > 0 ? lightGreen : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_totalImagesCount / $maxImages photos',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _totalImagesCount > 0 ? darkGreen : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'The first photo is the main cover. You can add up to $maxImages photos.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 14),
          _buildPhotosGrid(),
        ],
      ),
    );
  }

  Widget _buildPhotosGrid() {
    final total = _totalImagesCount;
    final bool canAddMore = total < maxImages;
    final int itemCount = total + (canAddMore ? 1 : 0);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        // If it's the last item and we can add more, show "+ Add Photo" button
        if (canAddMore && index == total) {
          return _buildAddPhotoButton();
        }

        // Existing image
        if (index < _existingImages.length) {
          return _buildExistingImageItem(index);
        }

        // Newly picked image
        final newIndex = index - _existingImages.length;
        return _buildNewImageItem(newIndex, index == 0);
      },
    );
  }

  Widget _buildAddPhotoButton() {
    return InkWell(
      onTap: _showImagePickerModal,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: lightGreen.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryGreen.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: primaryGreen,
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add Photo',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingImageItem(int index) {
    final url = _existingImages[index];
    final isCover = index == 0;

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              ApiConstants.imageUrl(url),
              fit: BoxFit.cover,
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
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (isCover)
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Text(
                'Cover',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: () => _removeExistingImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewImageItem(int newIndex, bool isCover) {
    final XFile image = _newImages[newIndex];

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FutureBuilder<Uint8List>(
              future: image.readAsBytes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    color: lightGreen,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryGreen,
                      ),
                    ),
                  );
                }

                return Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
        if (isCover)
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Text(
                'Cover',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        else
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'New',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: () => _removeNewImage(newIndex),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION: BASIC INFORMATION
  // ============================================================

  Widget _buildBasicInfoSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.info_outline,
            title: 'Basic Information',
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Product Name *'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _nameController,
            hint: 'e.g., Fresh Organic Tomatoes',
            prefixIcon: Icons.eco_outlined,
          ),
          const SizedBox(height: 14),
          _buildFieldLabel('Category *'),
          const SizedBox(height: 6),
          _buildDropdownField(
            value: _category,
            items: _categories,
            prefixIcon: Icons.category_outlined,
            onChanged: (val) {
              if (val != null) {
                setState(() => _category = val);
              }
            },
          ),
          const SizedBox(height: 14),
          _buildFieldLabel('Condition *'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildChoiceTile(
                  title: 'Fresh',
                  subtitle: 'Standard Produce',
                  icon: Icons.water_drop_outlined,
                  isSelected: _condition == 'Fresh',
                  onTap: () => setState(() => _condition = 'Fresh'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildChoiceTile(
                  title: 'Organic',
                  subtitle: 'Chemical-Free',
                  icon: Icons.verified_outlined,
                  isSelected: _condition == 'Organic',
                  onTap: () => setState(() => _condition = 'Organic'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildFieldLabel('Description'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _descriptionController,
            hint: 'Describe product freshness, size, packaging, harvest method...',
            prefixIcon: Icons.notes_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION: PRICING & INVENTORY
  // ============================================================

  Widget _buildPricingInventorySection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.monetization_on_outlined,
            title: 'Pricing & Inventory',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Price per kg *'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _priceController,
                      hint: '0.00',
                      prefixText: '\$ ',
                      suffixText: '/kg',
                      prefixIcon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Available Stock *'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _quantityController,
                      hint: '0',
                      suffixText: 'kg',
                      prefixIcon: Icons.inventory_2_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildFieldLabel('Minimum Order Quantity (MOQ)'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _minOrderController,
            hint: 'e.g., 5',
            suffixText: 'kg',
            prefixIcon: Icons.shopping_basket_outlined,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Harvest Date'),
                    const SizedBox(height: 6),
                    _buildDateSelector(
                      date: _harvestDate,
                      placeholder: 'Select Date',
                      onTap: () => _selectDate(isHarvest: true),
                      onClear: _harvestDate != null
                          ? () => setState(() => _harvestDate = null)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Available Until'),
                    const SizedBox(height: 6),
                    _buildDateSelector(
                      date: _availableUntil,
                      placeholder: 'Select Date',
                      onTap: () => _selectDate(isHarvest: false),
                      onClear: _availableUntil != null
                          ? () => setState(() => _availableUntil = null)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION: DELIVERY & LOCATION
  // ============================================================

  Widget _buildDeliverySection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.local_shipping_outlined,
            title: 'Delivery & Location',
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Farm Location / Origin'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _locationController,
            hint: 'e.g., Phnom Penh, Kandal, Battambang',
            prefixIcon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 14),
          _buildFieldLabel('Delivery Method'),
          const SizedBox(height: 6),
          _buildDropdownField(
            value: _deliveryMethod,
            items: _deliveryMethods,
            prefixIcon: Icons.local_shipping_outlined,
            onChanged: (val) {
              if (val != null) {
                setState(() => _deliveryMethod = val);
              }
            },
          ),
          const SizedBox(height: 14),
          _buildFieldLabel('Delivery Fee'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _deliveryFeeController,
            hint: '0.00',
            prefixText: '\$ ',
            prefixIcon: Icons.payment_outlined,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION: AVAILABILITY
  // ============================================================

  Widget _buildAvailabilitySection() {
    return _buildCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isAvailable ? lightGreen : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isAvailable ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: _isAvailable ? primaryGreen : Colors.grey.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isAvailable ? 'Available for Sale' : 'Hidden from Buyers',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _isAvailable
                      ? 'Visible to restaurants on marketplace'
                      : 'Product is currently unlisted from marketplace',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isAvailable,
            activeThumbColor: primaryGreen,
            activeTrackColor: lightGreen,
            onChanged: (val) {
              setState(() => _isAvailable = val);
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM ACTION BAR
  // ============================================================

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HELPER WIDGETS
  // ============================================================

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
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

  Widget _buildSectionHeader({
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
          child: Icon(
            icon,
            color: primaryGreen,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E1E),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    String? prefixText,
    String? suffixText,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
        prefixText: prefixText,
        prefixStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        suffixText: suffixText,
        suffixStyle: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.grey.shade600,
          size: 20,
        ),
        filled: true,
        fillColor: bgGrey,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required IconData prefixIcon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: items.contains(value) ? value : items.first,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.grey.shade600,
          size: 20,
        ),
        filled: true,
        fillColor: bgGrey,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildChoiceTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? lightGreen : bgGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryGreen : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? darkGreen : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? darkGreen : const Color(0xFF1E1E1E),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? primaryGreen : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: primaryGreen,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required DateTime? date,
    required String placeholder,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    final formatted = date != null ? DateFormat('MMM dd, yyyy').format(date) : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bgGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: date != null ? primaryGreen : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                formatted ?? placeholder,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: date != null ? FontWeight.w600 : FontWeight.normal,
                  color: date != null ? Colors.black87 : Colors.grey.shade500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}