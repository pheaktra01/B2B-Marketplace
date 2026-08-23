import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/features/farmer/screens/inventory_screen.dart';
import 'package:mobile/features/product/screens/product_card.dart';
import 'package:mobile/features/product/services/product_service.dart';

class AddProductFlowScreen extends StatefulWidget {
  const AddProductFlowScreen({super.key});

  @override
  State<AddProductFlowScreen> createState() => _AddProductFlowScreenState();
}

class _AddProductFlowScreenState extends State<AddProductFlowScreen> {
  // ============================================================
  // CONSTANTS
  // ============================================================

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const int maxImages = 5;

  // ============================================================
  // STEP TRACKING
  // ============================================================

  // 1 = Product Information
  // 2 = Price & Inventory
  // 3 = Delivery & Review
  // 4 = Success
  int _currentStep = 1;

  bool _isPublishing = false;

  // ============================================================
  // STEP 1 - PRODUCT INFORMATION
  // ============================================================

  final TextEditingController _productNameController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  String _selectedCategory = 'Vegetables';

  String _productCondition = 'Fresh';

  final List<XFile> _productImages = [];

  // Base64 strings sent to backend
  final List<String> _selectedImagesBase64 = [];

  final List<String> _categories = [
    'Vegetables',
    'Fruits',
    'Herbs & Spices',
    'Rice & Grains',
    'Eggs & Dairy',
  ];

  // ============================================================
  // STEP 2 - PRICE & INVENTORY
  // ============================================================

  final TextEditingController _priceController = TextEditingController();

  final TextEditingController _quantityController = TextEditingController();

  final TextEditingController _minOrderController = TextEditingController();

  DateTime? _harvestDate;

  DateTime? _availableUntilDate;

  // ============================================================
  // STEP 3 - DELIVERY & REVIEW
  // ============================================================

  String _selectedLocation = 'Phnom Penh';

  String _deliveryOption = 'Farmer Delivery';

  final TextEditingController _deliveryFeeController =
      TextEditingController(text: '2.00');

  final List<String> _locations = [
    'Phnom Penh',
    'Kandal',
    'Battambang',
    'Siem Reap',
    'Kampong Cham',
  ];

  // ============================================================
  // INIT / DISPOSE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _productNameController.addListener(_refresh);
    _descriptionController.addListener(_refresh);
    _priceController.addListener(_refresh);
    _quantityController.addListener(_refresh);
  }

  @override
  void dispose() {
    _productNameController.removeListener(_refresh);
    _descriptionController.removeListener(_refresh);
    _priceController.removeListener(_refresh);
    _quantityController.removeListener(_refresh);

    _productNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _minOrderController.dispose();
    _deliveryFeeController.dispose();

    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // STEP NAVIGATION
  // ============================================================

  void _nextStep() {
    if (_currentStep == 1) {
      if (!_validateStep1()) {
        return;
      }

      setState(() {
        _currentStep = 2;
      });

      return;
    }

    if (_currentStep == 2) {
      if (!_validateStep2()) {
        return;
      }

      setState(() {
        _currentStep = 3;
      });

      return;
    }
  }

  void _previousStep() {
    if (_isPublishing) return;

    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.maybePop(context);
    }
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool _validateStep1() {
    if (_productImages.isEmpty) {
      _showError('Please upload at least one product photo');
      return false;
    }

    if (_productNameController.text.trim().isEmpty) {
      _showError('Please enter a product name');
      return false;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showError('Please enter a product description');
      return false;
    }

    return true;
  }

  bool _validateStep2() {
    final price = double.tryParse(
      _priceController.text.trim(),
    );

    final quantity = double.tryParse(
      _quantityController.text.trim(),
    );

    final minOrderText = _minOrderController.text.trim();

    final minOrder = minOrderText.isEmpty
        ? 1.0
        : double.tryParse(minOrderText);

    if (price == null || price <= 0) {
      _showError('Please enter a valid selling price');
      return false;
    }

    if (quantity == null || quantity <= 0) {
      _showError('Please enter a valid available quantity');
      return false;
    }

    if (minOrder == null || minOrder <= 0) {
      _showError('Please enter a valid minimum order');
      return false;
    }

    if (minOrder > quantity) {
      _showError(
        'Minimum order cannot be greater than available quantity',
      );
      return false;
    }

    if (_harvestDate != null &&
        _availableUntilDate != null &&
        _availableUntilDate!.isBefore(_harvestDate!)) {
      _showError(
        'Available Until cannot be before Harvest Date',
      );
      return false;
    }

    return true;
  }

  // ============================================================
  // IMAGE PICKING
  // ============================================================

  Future<void> _pickProductImages() async {
    try {
      final remainingSlots =
          maxImages - _productImages.length;

      if (remainingSlots <= 0) {
        _showError(
          'You can upload a maximum of $maxImages images',
        );
        return;
      }

      final ImagePicker picker =
          ImagePicker();

      final List<XFile> images =
          await picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (images.isEmpty) {
        return;
      }

      final List<XFile> selectedImages =
          images
              .take(remainingSlots)
              .toList();

      if (images.length > remainingSlots) {
        _showError(
          'Only $remainingSlots more image'
          '${remainingSlots == 1 ? '' : 's'} can be added. '
          'Maximum is $maxImages.',
        );
      }

      setState(() {
        _productImages.addAll(
          selectedImages,
        );
      });

      debugPrint(
        '========== PRODUCT IMAGES =========',
      );

      for (final image in selectedImages) {
        debugPrint(
          'Image: ${image.name}',
        );

        debugPrint(
          'Path: ${image.path}',
        );
      }

      debugPrint(
        'Total images: ${_productImages.length}',
      );

      debugPrint(
        '====================================',
      );
    } catch (e) {
      debugPrint(
        'Image picker error: $e',
      );

      _showError(
        'Failed to select images',
      );
    }
  }

  void _removeProductImage(int index) {
    if (index < 0 ||
        index >= _productImages.length) {
      return;
    }

    setState(() {
      _productImages.removeAt(index);
    });
  }

  // ============================================================
  // PUBLISH PRODUCT
  // ============================================================

  Future<void> _publishProduct() async {
    if (_isPublishing) return;

    if (!_validateStep1()) {
      setState(() {
        _currentStep = 1;
      });
      return;
    }

    if (!_validateStep2()) {
      setState(() {
        _currentStep = 2;
      });
      return;
    }

    // Validate delivery fee
    double deliveryFee = 0;

    if (_deliveryOption == 'Farmer Delivery') {
      final parsedDeliveryFee = double.tryParse(
        _deliveryFeeController.text.trim(),
      );

      if (parsedDeliveryFee == null ||
          parsedDeliveryFee < 0) {
        _showError(
          'Please enter a valid delivery fee',
        );
        return;
      }

      deliveryFee = parsedDeliveryFee;
    }

    final String name =
        _productNameController.text.trim();

    final String description =
        _descriptionController.text.trim();

    final double price =
        double.parse(_priceController.text.trim());

    final double quantity =
        double.parse(_quantityController.text.trim());

    final String minOrderText =
        _minOrderController.text.trim();

    final double minOrder = minOrderText.isEmpty
        ? 1.0
        : double.parse(minOrderText);

    try {
      setState(() {
        _isPublishing = true;
      });

      debugPrint('========== PUBLISH PRODUCT ==========');
      debugPrint('Name: $name');
      debugPrint('Category: $_selectedCategory');
      debugPrint('Condition: $_productCondition');
      debugPrint('Price: $price');
      debugPrint('Quantity: $quantity');
      debugPrint('Min Order: $minOrder');
      debugPrint('Location: $_selectedLocation');
      debugPrint(
        'Delivery: $_deliveryOption',
      );
      debugPrint(
        'Delivery Fee: $deliveryFee',
      );
      debugPrint(
        'Images: ${_productImages.length}',
      );
      debugPrint('=====================================');

      await ProductService.createProduct(
        name: name,
        description: description,
        category: _selectedCategory,
        condition: _productCondition,
        price: price,
        quantity: quantity,
        minOrder: minOrder,
        harvestDate: _harvestDate,
        availableUntil: _availableUntilDate,
        location: _selectedLocation,
        deliveryMethod: _deliveryOption,
        deliveryFee: deliveryFee,
        images: _productImages,
      );

      if (!mounted) return;

      setState(() {
        _isPublishing = false;
        _currentStep = 4;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isPublishing = false;
      });

      final String errorMessage =
          e.toString().replaceFirst(
                'Exception: ',
                '',
              );

      _showError(errorMessage);
    }
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 4) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed:
              _isPublishing ? null : _previousStep,
        ),
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 450,
                    ),
                    child:
                        _buildCurrentStepContent(),
                  ),
                ),
              ),
            ),

            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR TITLE
  // ============================================================

  String _getAppBarTitle() {
    switch (_currentStep) {
      case 1:
        return 'Add Product';
      case 2:
        return 'Price & Inventory';
      case 3:
        return 'Delivery & Review';
      default:
        return 'Add Product';
    }
  }

  // ============================================================
  // PROGRESS BAR
  // ============================================================

  Widget _buildProgressBar() {
    final double progress =
        _currentStep / 3;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $_currentStep of 3',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryGreen,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% Completed',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  const Color(0xFFE8F5E9),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                primaryGreen,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CURRENT STEP
  // ============================================================

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Info();

      case 2:
        return _buildStep2PriceInventory();

      case 3:
        return _buildStep3DeliveryReview();

      default:
        return const SizedBox.shrink();
    }
  }

  // ============================================================
  // STEP 1
  // ============================================================

  Widget _buildStep1Info() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(
          'PRODUCT PHOTOS',
        ),

        const SizedBox(height: 6),

        Text(
          '${_productImages.length}/$maxImages photos',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 10),

        if (_productImages.isEmpty)
          _buildEmptyImageUploadBox()
        else
          _buildProductImagesGrid(),

        const SizedBox(height: 20),

        _buildFieldLabel(
          'Product Name',
        ),

        const SizedBox(height: 6),

        _buildTextField(
          controller:
              _productNameController,
          hintText:
              'e.g. Fresh Organic Bok Choy',
        ),

        const SizedBox(height: 16),

        _buildFieldLabel(
          'Category',
        ),

        const SizedBox(height: 6),

        _buildDropdownField(
          value: _selectedCategory,
          items: _categories,
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedCategory = value;
            });
          },
        ),

        const SizedBox(height: 16),

        _buildFieldLabel(
          'Product Condition',
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _buildChoiceTile(
                title: 'Fresh',
                subtitle:
                    'Standard produce',
                isSelected:
                    _productCondition ==
                        'Fresh',
                onTap: () {
                  setState(() {
                    _productCondition =
                        'Fresh';
                  });
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildChoiceTile(
                title: 'Organic',
                subtitle:
                    'Chemical-free',
                isSelected:
                    _productCondition ==
                        'Organic',
                onTap: () {
                  setState(() {
                    _productCondition =
                        'Organic';
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        _buildFieldLabel(
          'Description',
        ),

        const SizedBox(height: 6),

        _buildTextField(
          controller:
              _descriptionController,
          hintText:
              'Describe quality, taste, or harvest details...',
          maxLines: 3,
        ),
      ],
    );
  }

  // ============================================================
  // STEP 2
  // ============================================================

  Widget _buildStep2PriceInventory() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildRecommendationCard(),

        const SizedBox(height: 20),

        _buildFieldLabel(
          'Selling Price per kg',
        ),

        const SizedBox(height: 6),

        _buildTextField(
          controller:
              _priceController,
          hintText: '0.00',
          keyboardType:
              const TextInputType.numberWithOptions(
            decimal: true,
          ),
          suffixText: '\$ / kg',
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel(
                    'Available Quantity',
                  ),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller:
                        _quantityController,
                    hintText:
                        'e.g. 100',
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    suffixText: 'kg',
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel(
                    'Minimum Order',
                  ),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller:
                        _minOrderController,
                    hintText:
                        'e.g. 5',
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    suffixText: 'kg',
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildDatePickerTile(
                label: 'Harvest Date',
                selectedDate:
                    _harvestDate,
                onTap:
                    _selectHarvestDate,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildDatePickerTile(
                label: 'Available Until',
                selectedDate:
                    _availableUntilDate,
                onTap:
                    _selectAvailableUntilDate,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // MARKET RECOMMENDATION
  // ============================================================

  Widget _buildRecommendationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFA5D6A7),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '💡',
                style:
                    TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Market Recommendation',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
              ),
            ],
          ),

          const Divider(
            height: 20,
            color: Color(0xFFC8E6C9),
          ),

          _buildRecommendationRow(
            'Current restaurant demand',
            'High 🔥',
          ),

          const SizedBox(height: 6),

          _buildRecommendationRow(
            'Typical market price',
            '\$1.10 – \$1.40 / kg',
          ),

          const SizedBox(height: 6),

          _buildRecommendationRow(
            'Recommended price',
            '\$1.25 / kg',
            isBold: true,
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _priceController.text =
                    '1.25';
              },
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    primaryGreen,
                side: const BorderSide(
                  color: primaryGreen,
                  width: 1.5,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                backgroundColor:
                    Colors.white,
              ),
              child: const Text(
                'Use Recommended Price (\$1.25)',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEP 3
  // ============================================================

  Widget _buildStep3DeliveryReview() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(
          'Location / Farm Origin',
        ),

        const SizedBox(height: 6),

        _buildDropdownField(
          value: _selectedLocation,
          items: _locations,
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedLocation = value;
            });
          },
        ),

        const SizedBox(height: 16),

        _buildFieldLabel(
          'Delivery Method',
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _buildChoiceTile(
                title:
                    'Farmer Delivery',
                subtitle:
                    'Deliver to buyer',
                isSelected:
                    _deliveryOption ==
                        'Farmer Delivery',
                onTap: () {
                  setState(() {
                    _deliveryOption =
                        'Farmer Delivery';
                  });
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildChoiceTile(
                title:
                    'Buyer Pickup',
                subtitle:
                    'Pickup at farm',
                isSelected:
                    _deliveryOption ==
                        'Buyer Pickup',
                onTap: () {
                  setState(() {
                    _deliveryOption =
                        'Buyer Pickup';
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        if (_deliveryOption ==
            'Farmer Delivery') ...[
          _buildFieldLabel(
            'Delivery Fee',
          ),

          const SizedBox(height: 6),

          _buildTextField(
            controller:
                _deliveryFeeController,
            hintText: '0.00',
            keyboardType:
                const TextInputType
                    .numberWithOptions(
              decimal: true,
            ),
            suffixText: '\$',
          ),

          const SizedBox(height: 20),
        ],

        _buildFieldLabel(
          'PRODUCT PREVIEW',
        ),

        const SizedBox(height: 8),

        _buildProductPreview(),
      ],
    );
  }

  // ============================================================
  // PRODUCT PREVIEW
  // ============================================================

  Widget _buildProductPreview() {
    final String productName =
        _productNameController.text.trim().isEmpty
            ? 'Fresh Produce'
            : _productNameController.text.trim();

    final String price =
        _priceController.text.trim().isEmpty
            ? '\$0.00 / kg'
            : '\$${_priceController.text.trim()} / kg';

    final String quantity =
        _quantityController.text.trim().isEmpty
            ? '0 kg'
            : '${_quantityController.text.trim()} kg';

    return ProductCard(
      imageUrl: '',
      localImage:
          _productImages.isNotEmpty
              ? _productImages.first
              : null,

      productName: productName,
      farmName: 'Your Farm',
      price: price,

      location: _selectedLocation,
      availableQuantity: quantity,

      isAvailable: true,
      isFavorite: false,

      onTap: null,
      onFavoritePressed: null,
      onAddToCart: null,
    );
  }

  // ============================================================
  // STEP 4 SUCCESS
  // ============================================================

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Column(
            children: [
              const Spacer(),

              const CircleAvatar(
                radius: 46,
                backgroundColor:
                    Color(0xFFE8F5E9),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: primaryGreen,
                  size: 64,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Product Published!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFF1E1E1E),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Your product is now available for restaurants in Cambodia to discover and order.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      Color(0xFF757575),
                  height: 1.4,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                const InventoryScreen(),
                      ),
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        primaryGreen,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child:
                      const Text(
                    'View Product Listing',
                    style:
                        TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child:
                    OutlinedButton(
                  onPressed: () =>
                      Navigator.maybePop(
                    context,
                  ),
                  style:
                      OutlinedButton.styleFrom(
                    side:
                        const BorderSide(
                      color:
                          Color(0xFFD6D6D6),
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  child:
                      const Text(
                    'Back to Dashboard',
                    style:
                        TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF424242),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM BAR
  // ============================================================

  Widget _buildBottomBar() {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset:
                const Offset(0, -4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 450,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
                  _isPublishing
                      ? null
                      : (_currentStep == 3
                          ? _publishProduct
                          : _nextStep),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryGreen,
                disabledBackgroundColor:
                    Colors.grey.shade400,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                elevation: 0,
              ),
              child: _isPublishing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<
                                Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      _currentStep == 3
                          ? 'Publish Product'
                          : 'Next Step',
                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DATE PICKERS
  // ============================================================

  Future<void> _selectHarvestDate() async {
    final DateTime now =
        DateTime.now();

    final DateTime? picked =
        await showDatePicker(
      context: context,
      initialDate:
          _harvestDate ?? now,
      firstDate:
          DateTime(2025),
      lastDate:
          DateTime(2030),
    );

    if (picked == null) return;

    setState(() {
      _harvestDate = picked;
    });
  }

  Future<void> _selectAvailableUntilDate() async {
    final DateTime initialDate =
        _availableUntilDate ??
            DateTime.now().add(
              const Duration(days: 7),
            );

    final DateTime? picked =
        await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate:
          DateTime(2025),
      lastDate:
          DateTime(2030),
    );

    if (picked == null) return;

    setState(() {
      _availableUntilDate = picked;
    });
  }

  // ============================================================
  // UI HELPERS
  // ============================================================

  Widget _buildFieldLabel(
    String label,
  ) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight:
            FontWeight.bold,
        color:
            Color(0xFF424242),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController
        controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType =
        TextInputType.text,
    String? suffixText,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType:
          keyboardType,
      style: const TextStyle(
        fontSize: 15,
        color:
            Color(0xFF212121),
      ),
      decoration:
          InputDecoration(
        hintText:
            hintText,
        suffixText:
            suffixText,
        suffixStyle:
            const TextStyle(
          fontWeight:
              FontWeight.bold,
          color:
              Color(0xFF616161),
        ),
        hintStyle:
            const TextStyle(
          color:
              Color(0xFF9E9E9E),
          fontSize: 14,
        ),
        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        filled: true,
        fillColor:
            Colors.white,
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          borderSide:
              const BorderSide(
            color:
                Color(0xFFD6D6D6),
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          borderSide:
              const BorderSide(
            color:
                primaryGreen,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?>
        onChanged,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        border:
            Border.all(
          color:
              const Color(0xFFD6D6D6),
        ),
      ),
      child:
          DropdownButtonHideUnderline(
        child:
            DropdownButton<String>(
          value: value,
          isExpanded:
              true,
          icon:
              const Icon(
            Icons
                .keyboard_arrow_down,
            color:
                Colors.black54,
          ),
          style:
              const TextStyle(
            fontSize: 15,
            color:
                Color(0xFF212121),
          ),
          onChanged:
              onChanged,
          items:
              items.map(
            (item) {
              return DropdownMenuItem<
                  String>(
                value: item,
                child:
                    Text(item),
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  Widget _buildChoiceTile({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(
        12,
      ),
      child: Container(
        padding:
            const EdgeInsets.all(
          12,
        ),
        decoration:
            BoxDecoration(
          color: isSelected
              ? const Color(
                  0xFFE8F5E9,
                )
              : Colors.white,
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          border:
              Border.all(
            color: isSelected
                ? primaryGreen
                : const Color(
                    0xFFD6D6D6,
                  ),
            width: isSelected
                ? 1.5
                : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.bold,
                color: isSelected
                    ? primaryGreen
                    : const Color(
                        0xFF212121,
                      ),
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              subtitle,
              style:
                  const TextStyle(
                fontSize: 11,
                color:
                    Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerTile({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment
              .start,
      children: [
        _buildFieldLabel(
          label,
        ),

        const SizedBox(
          height: 6,
        ),

        InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          child: Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            decoration:
                BoxDecoration(
              color:
                  Colors.white,
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
              border:
                  Border.all(
                color:
                    const Color(
                  0xFFD6D6D6,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedDate ==
                            null
                        ? 'Select date'
                        : '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style:
                        TextStyle(
                      fontSize:
                          13,
                      color: selectedDate ==
                              null
                          ? const Color(
                              0xFF9E9E9E,
                            )
                          : const Color(
                              0xFF212121,
                            ),
                    ),
                  ),
                ),
                const Icon(
                  Icons
                      .calendar_today_rounded,
                  size: 16,
                  color:
                      Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style:
                const TextStyle(
              fontSize: 13,
              color:
                  Color(0xFF424242),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold
                ? FontWeight.bold
                : FontWeight.w600,
            color: isBold
                ? primaryGreen
                : const Color(
                    0xFF212121,
                  ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY IMAGE BOX
  // ============================================================

  Widget _buildEmptyImageUploadBox() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFC8E6C9,
          ),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap:
            _pickProductImages,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundColor:
                  Color(
                0xFFE8F5E9,
              ),
              child: Icon(
                Icons
                    .add_a_photo_rounded,
                color:
                    primaryGreen,
                size: 26,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            const Text(
              'Upload Product Photos',
              style:
                  TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.bold,
                color:
                    primaryGreen,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            const Text(
              'Add up to 5 photos',
              style:
                  TextStyle(
                fontSize: 12,
                color:
                    Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE GRID
  // ============================================================

  Widget _buildProductImagesGrid() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount:
              _productImages.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemBuilder:
              (context, index) {
            return _buildImageItem(
              index,
            );
          },
        ),

        const SizedBox(
          height: 10,
        ),

        if (_productImages.length <
            maxImages)
          SizedBox(
            width:
                double.infinity,
            height: 45,
            child:
                OutlinedButton.icon(
              onPressed:
                  _pickProductImages,
              icon:
                  const Icon(
                Icons
                    .add_photo_alternate_outlined,
                color:
                    primaryGreen,
              ),
              label:
                  Text(
                'Add More Photos (${_productImages.length}/$maxImages)',
                style:
                    const TextStyle(
                  color:
                      primaryGreen,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              style:
                  OutlinedButton
                      .styleFrom(
                side:
                    const BorderSide(
                  color:
                      primaryGreen,
                  width:
                      1.2,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    12,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageItem(
    int index,
  ) {
    final XFile image =
        _productImages[index];

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(12),
            child: FutureBuilder<Uint8List>(
              future: image.readAsBytes(),
              builder: (
                context,
                snapshot,
              ) {
                if (!snapshot.hasData) {
                  return Container(
                    color:
                        const Color(0xFFE8F5E9),
                    child:
                        const Center(
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                            primaryGreen,
                      ),
                    ),
                  );
                }

                return Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Container(
                      color:
                          const Color(0xFFE8F5E9),
                      child:
                          const Icon(
                        Icons
                            .image_not_supported,
                        color:
                            primaryGreen,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),

        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: () =>
                _removeProductImage(index),
            child: Container(
              width: 26,
              height: 26,
              decoration:
                  const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 17,
              ),
            ),
          ),
        ),

        if (index == 0)
          Positioned(
            left: 5,
            bottom: 5,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 4,
              ),
              decoration:
                  BoxDecoration(
                color: primaryGreen,
                borderRadius:
                    BorderRadius.circular(6),
              ),
              child: const Text(
                'Main',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}