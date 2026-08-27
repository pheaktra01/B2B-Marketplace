import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/l10n/app_localizations.dart';

import 'package:mobile/features/farmer/screens/inventory_screen.dart';
import 'package:mobile/features/product/screens/product_card.dart';
import 'package:mobile/features/product/services/product_service.dart';

class AddProductFlowScreen extends StatefulWidget {
  const AddProductFlowScreen({super.key});

  @override
  State<AddProductFlowScreen> createState() =>
      _AddProductFlowScreenState();
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

  // Keep backend values in English.
  // Only the displayed labels are translated.
  String _selectedCategory = 'Vegetables';

  String _productCondition = 'Fresh';

  final List<XFile> _productImages = [];

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

  final TextEditingController _priceController =
      TextEditingController();

  final TextEditingController _quantityController =
      TextEditingController();

  final TextEditingController _minOrderController =
      TextEditingController();

  DateTime? _harvestDate;

  DateTime? _availableUntilDate;

  // ============================================================
  // STEP 3 - DELIVERY & REVIEW
  // ============================================================

  // Keep backend values in English.
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
    final l10n = AppLocalizations.of(context)!;

    if (_productImages.isEmpty) {
      _showError(l10n.uploadAtLeastOnePhoto);
      return false;
    }

    if (_productNameController.text.trim().isEmpty) {
      _showError(l10n.enterProductName);
      return false;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showError(l10n.enterProductDescription);
      return false;
    }

    return true;
  }

  bool _validateStep2() {
    final l10n = AppLocalizations.of(context)!;

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
      _showError(l10n.enterValidSellingPrice);
      return false;
    }

    if (quantity == null || quantity <= 0) {
      _showError(l10n.enterValidQuantity);
      return false;
    }

    if (minOrder == null || minOrder <= 0) {
      _showError(l10n.enterValidMinimumOrder);
      return false;
    }

    if (minOrder > quantity) {
      _showError(
        l10n.minimumOrderGreaterThanQuantity,
      );
      return false;
    }

    if (_harvestDate != null &&
        _availableUntilDate != null &&
        _availableUntilDate!.isBefore(_harvestDate!)) {
      _showError(
        l10n.availableUntilBeforeHarvest,
      );
      return false;
    }

    return true;
  }

  // ============================================================
  // IMAGE PICKING
  // ============================================================

  Future<void> _pickProductImages() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final remainingSlots =
          maxImages - _productImages.length;

      if (remainingSlots <= 0) {
        _showError(
          l10n.maximumImages(maxImages),
        );
        return;
      }

      final ImagePicker picker = ImagePicker();

      final List<XFile> images =
          await picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (images.isEmpty) {
        return;
      }

      final List<XFile> selectedImages =
          images.take(remainingSlots).toList();

      if (images.length > remainingSlots) {
        _showError(
          l10n.onlyMoreImages(
            remainingSlots,
            maxImages,
          ),
        );
      }

      setState(() {
        _productImages.addAll(selectedImages);
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
        l10n.failedToSelectImages,
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
    final l10n = AppLocalizations.of(context)!;

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
      final parsedDeliveryFee =
          double.tryParse(
        _deliveryFeeController.text.trim(),
      );

      if (parsedDeliveryFee == null ||
          parsedDeliveryFee < 0) {
        _showError(
          l10n.enterValidDeliveryFee,
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
        double.parse(
      _priceController.text.trim(),
    );

    final double quantity =
        double.parse(
      _quantityController.text.trim(),
    );

    final String minOrderText =
        _minOrderController.text.trim();

    final double minOrder =
        minOrderText.isEmpty
            ? 1.0
            : double.parse(minOrderText);

    try {
      setState(() {
        _isPublishing = true;
      });

      debugPrint(
        '========== PUBLISH PRODUCT ==========',
      );
      debugPrint('Name: $name');
      debugPrint(
        'Category: $_selectedCategory',
      );
      debugPrint(
        'Condition: $_productCondition',
      );
      debugPrint('Price: $price');
      debugPrint('Quantity: $quantity');
      debugPrint('Min Order: $minOrder');
      debugPrint(
        'Location: $_selectedLocation',
      );
      debugPrint(
        'Delivery: $_deliveryOption',
      );
      debugPrint(
        'Delivery Fee: $deliveryFee',
      );
      debugPrint(
        'Images: ${_productImages.length}',
      );
      debugPrint(
        '=====================================',
      );

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

      _showError(
        errorMessage.isEmpty
            ? l10n.failedToPublishProduct
            : errorMessage,
      );
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
    final l10n = AppLocalizations.of(context)!;

    if (_currentStep == 4) {
      return _buildSuccessScreen(l10n);
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF9FBF9),
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
              _isPublishing
                  ? null
                  : _previousStep,
        ),
        title: Text(
          _getAppBarTitle(l10n),
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
            _buildProgressBar(l10n),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(
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
                        _buildCurrentStepContent(
                      l10n,
                    ),
                  ),
                ),
              ),
            ),

            _buildBottomBar(l10n),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR TITLE
  // ============================================================

  String _getAppBarTitle(
    AppLocalizations l10n,
  ) {
    switch (_currentStep) {
      case 1:
        return l10n.addProduct;
      case 2:
        return l10n.priceAndInventory;
      case 3:
        return l10n.deliveryAndReview;
      default:
        return l10n.addProduct;
    }
  }

  // ============================================================
  // PROGRESS BAR
  // ============================================================

  Widget _buildProgressBar(
    AppLocalizations l10n,
  ) {
    final double progress =
        _currentStep / 3;

    return Container(
      color: Colors.white,
      padding:
          const EdgeInsets.symmetric(
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
                l10n.stepOf(
                  _currentStep,
                  3,
                ),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w600,
                  color: primaryGreen,
                ),
              ),
              Text(
                l10n.percentCompleted(
                  (progress * 100).toInt(),
                ),
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
            child:
                LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  const Color(0xFFE8F5E9),
              valueColor:
                  const AlwaysStoppedAnimation<
                      Color>(
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

  Widget _buildCurrentStepContent(
    AppLocalizations l10n,
  ) {
    switch (_currentStep) {
      case 1:
        return _buildStep1Info(l10n);

      case 2:
        return _buildStep2PriceInventory(
          l10n,
        );

      case 3:
        return _buildStep3DeliveryReview(
          l10n,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // ============================================================
  // STEP 1
  // ============================================================

  Widget _buildStep1Info(
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(
          l10n.productPhotos,
        ),

        const SizedBox(height: 6),

        Text(
          l10n.photosCount(
            _productImages.length,
            maxImages,
          ),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 10),

        if (_productImages.isEmpty)
          _buildEmptyImageUploadBox(l10n)
        else
          _buildProductImagesGrid(l10n),

        const SizedBox(height: 20),

        _buildFieldLabel(
          l10n.productName,
        ),

        const SizedBox(height: 6),

        _buildTextField(
          controller:
              _productNameController,
          hintText:
              l10n.productNameHint,
        ),

        const SizedBox(height: 16),

        _buildFieldLabel(
          l10n.category,
        ),

        const SizedBox(height: 6),

        _buildDropdownField(
          value: _selectedCategory,
          items: _categories,
          itemLabel: (item) =>
              _getCategoryLabel(
            item,
            l10n,
          ),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedCategory = value;
            });
          },
        ),

        const SizedBox(height: 16),

        _buildFieldLabel(
          l10n.productCondition,
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _buildChoiceTile(
                title: l10n.fresh,
                subtitle:
                    l10n.standardProduce,
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
                title: l10n.organic,
                subtitle:
                    l10n.chemicalFree,
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
          l10n.description,
        ),

        const SizedBox(height: 6),

        _buildTextField(
          controller:
              _descriptionController,
          hintText:
              l10n.descriptionHint,
          maxLines: 3,
        ),
      ],
    );
  }

  // ============================================================
  // STEP 2
  // ============================================================

  Widget _buildStep2PriceInventory(
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildRecommendationCard(l10n),

        const SizedBox(height: 20),

        _buildFieldLabel(
          l10n.sellingPricePerKg,
        ),

        const SizedBox(height: 6),

        _buildTextField(
          controller:
              _priceController,
          hintText: '0.00',
          keyboardType:
              const TextInputType
                  .numberWithOptions(
            decimal: true,
          ),
          suffixText: l10n.perKg,
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
                    l10n.availableQuantity,
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  _buildTextField(
                    controller:
                        _quantityController,
                    hintText: 'e.g. 100',
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
                    l10n.minimumOrder,
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  _buildTextField(
                    controller:
                        _minOrderController,
                    hintText: 'e.g. 5',
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
                label: l10n.harvestDate,
                selectedDate:
                    _harvestDate,
                onTap:
                    _selectHarvestDate,
                selectDateText:
                    l10n.selectDate,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildDatePickerTile(
                label:
                    l10n.availableUntil,
                selectedDate:
                    _availableUntilDate,
                onTap:
                    _selectAvailableUntilDate,
                selectDateText:
                    l10n.selectDate,
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

  Widget _buildRecommendationCard(
    AppLocalizations l10n,
  ) {
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

              Expanded(
                child: Text(
                  l10n.marketRecommendation,
                  style: const TextStyle(
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
            l10n.currentRestaurantDemand,
            l10n.highDemand,
          ),

          const SizedBox(height: 6),

          _buildRecommendationRow(
            l10n.typicalMarketPrice,
            '\$1.10 – \$1.40 / kg',
          ),

          const SizedBox(height: 6),

          _buildRecommendationRow(
            l10n.recommendedPrice,
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
              child: Text(
                l10n.useRecommendedPrice(
                  '\$1.25',
                ),
                style: const TextStyle(
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

  Widget _buildStep3DeliveryReview(
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(
          l10n.locationFarmOrigin,
        ),

        const SizedBox(height: 6),

        _buildDropdownField(
          value: _selectedLocation,
          items: _locations,
          itemLabel: (item) =>
              _getLocationLabel(
            item,
            l10n,
          ),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedLocation = value;
            });
          },
        ),

        const SizedBox(height: 16),

        _buildFieldLabel(
          l10n.deliveryMethod,
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _buildChoiceTile(
                title:
                    l10n.farmerDelivery,
                subtitle:
                    l10n.deliverToBuyer,
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
                    l10n.buyerPickup,
                subtitle:
                    l10n.pickupAtFarm,
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
            l10n.deliveryFee,
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
          l10n.productPreview,
        ),

        const SizedBox(height: 8),

        _buildProductPreview(l10n),
      ],
    );
  }

  // ============================================================
  // PRODUCT PREVIEW
  // ============================================================

  Widget _buildProductPreview(
    AppLocalizations l10n,
  ) {
    final String productName =
        _productNameController.text
                .trim()
                .isEmpty
            ? l10n.freshProduce
            : _productNameController.text
                .trim();

    final String price =
        _priceController.text
                .trim()
                .isEmpty
            ? '\$0.00 / kg'
            : '\$${_priceController.text.trim()} / kg';

    final String quantity =
        _quantityController.text
                .trim()
                .isEmpty
            ? '0 kg'
            : '${_quantityController.text.trim()} kg';

    return ProductCard(
      imageUrl: '',
      localImage:
          _productImages.isNotEmpty
              ? _productImages.first
              : null,

      productName: productName,
      farmName: l10n.yourFarm,
      price: price,

      location: _getLocationLabel(
        _selectedLocation,
        l10n,
      ),
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

  Widget _buildSuccessScreen(
    AppLocalizations l10n,
  ) {
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

              Text(
                l10n.productPublished,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFF1E1E1E),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                l10n.productPublishedDescription,
                textAlign:
                    TextAlign.center,
                style: const TextStyle(
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
                  child: Text(
                    l10n.viewProductListing,
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
                  child: Text(
                    l10n.backToDashboard,
                    style:
                        const TextStyle(
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

  Widget _buildBottomBar(
    AppLocalizations l10n,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.05,
            ),
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
                          ? l10n.publishProduct
                          : l10n.nextStep,
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

  Future<void>
      _selectAvailableUntilDate() async {
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
    required String Function(String)
        itemLabel,
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
                child: Text(
                  itemLabel(item),
                ),
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
    required String selectDateText,
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
                        ? selectDateText
                        : '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style:
                        TextStyle(
                      fontSize:
                          13,
                      color:
                          selectedDate ==
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

  Widget _buildEmptyImageUploadBox(
    AppLocalizations l10n,
  ) {
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

            Text(
              l10n.uploadProductPhotos,
              style:
                  const TextStyle(
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

            Text(
              l10n.addUpToFivePhotos,
              style:
                  const TextStyle(
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

  Widget _buildProductImagesGrid(
    AppLocalizations l10n,
  ) {
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
              l10n,
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
                l10n.addMorePhotos(
                  _productImages.length,
                  maxImages,
                ),
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
    AppLocalizations l10n,
  ) {
    final XFile image =
        _productImages[index];

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(12),
            child:
                FutureBuilder<Uint8List>(
              future:
                  image.readAsBytes(),
              builder: (
                context,
                snapshot,
              ) {
                if (!snapshot.hasData) {
                  return Container(
                    color:
                        const Color(
                      0xFFE8F5E9,
                    ),
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
                          const Color(
                        0xFFE8F5E9,
                      ),
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
                _removeProductImage(
              index,
            ),
            child: Container(
              width: 26,
              height: 26,
              decoration:
                  const BoxDecoration(
                color:
                    Colors.black54,
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons.close,
                color:
                    Colors.white,
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
                  const EdgeInsets
                      .symmetric(
                horizontal: 7,
                vertical: 4,
              ),
              decoration:
                  BoxDecoration(
                color:
                    primaryGreen,
                borderRadius:
                    BorderRadius.circular(
                  6,
                ),
              ),
              child: Text(
                l10n.mainPhoto,
                style:
                    const TextStyle(
                  color:
                      Colors.white,
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

  // ============================================================
  // LOCALIZATION HELPERS
  // ============================================================

  String _getCategoryLabel(
    String category,
    AppLocalizations l10n,
  ) {
    switch (category) {
      case 'Vegetables':
        return l10n.vegetables;

      case 'Fruits':
        return l10n.fruits;

      case 'Herbs & Spices':
        return l10n.herbsAndSpices;

      case 'Rice & Grains':
        return l10n.riceAndGrains;

      case 'Eggs & Dairy':
        return l10n.eggsAndDairy;

      default:
        return category;
    }
  }

  String _getLocationLabel(
    String location,
    AppLocalizations l10n,
  ) {
    switch (location) {
      case 'Phnom Penh':
        return l10n.phnomPenh;

      case 'Kandal':
        return l10n.kandal;

      case 'Battambang':
        return l10n.battambang;

      case 'Siem Reap':
        return l10n.siemReap;

      case 'Kampong Cham':
        return l10n.kampongCham;

      default:
        return location;
    }
  }
}