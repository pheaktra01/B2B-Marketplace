import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/features/farmer/screens/inventory_screen.dart';

import 'package:mobile/features/product/services/product_service.dart';

class AddProductFlowScreen extends StatefulWidget {
  const AddProductFlowScreen({super.key});

  @override
  State<AddProductFlowScreen> createState() => _AddProductFlowScreenState();
}

class _AddProductFlowScreenState extends State<AddProductFlowScreen> {
  // Step Tracking (1: Info, 2: Price & Inventory, 3: Delivery & Review, 4: Success)
  int _currentStep = 1;

  // STEP 1 - PRODUCT INFORMATION
  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Vegetables';
  String _productCondition = 'Fresh'; // 'Fresh' or 'Organic'

  bool _isPublishing = false;

  File? _productImage;

  Uint8List? _selectedImageBytes;

  String? _selectedImageBase64;

  final List<String> _categories = [
    'Vegetables',
    'Fruits',
    'Herbs & Spices',
    'Rice & Grains',
    'Eggs & Dairy',
  ];

  // STEP 2 - PRICE & INVENTORY
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minOrderController = TextEditingController();
  DateTime? _harvestDate;
  DateTime? _availableUntilDate;

  // STEP 3 - DELIVERY & REVIEW
  String _selectedLocation = 'Phnom Penh';
  String _deliveryOption = 'Farmer Delivery'; // 'Farmer Delivery' or 'Buyer Pickup'
  final _deliveryFeeController = TextEditingController(text: '2.00');

  final List<String> _locations = [
    'Phnom Penh',
    'Kandal',
    'Battambang',
    'Siem Reap',
    'Kampong Cham',
  ];

  @override
  void dispose() {
    _productNameController.removeListener(_refresh);
    _priceController.removeListener(_refresh);
    _quantityController.removeListener(_refresh);
    _descriptionController.removeListener(_refresh);

    _productNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _minOrderController.dispose();
    _deliveryFeeController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _productNameController.addListener(_refresh);
    _priceController.addListener(_refresh);
    _quantityController.addListener(_refresh);
    _descriptionController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (_selectedImageBase64 == null) {
        _showError('Please upload a product photo');
        return;
      }

      if (_productNameController.text.trim().isEmpty) {
        _showError('Please enter a product name');
        return;
      }

      if (_descriptionController.text.trim().isEmpty) {
        _showError('Please enter a product description');
        return;
      }

      setState(() {
        _currentStep = 2;
      });

      return;
    }

    if (_currentStep == 2) {
      final price = double.tryParse(_priceController.text.trim());
      final quantity = double.tryParse(_quantityController.text.trim());
      final minOrderText = _minOrderController.text.trim();

      final minOrder = minOrderText.isEmpty
          ? 1.0
          : double.tryParse(minOrderText);

      if (price == null || price <= 0) {
        _showError('Please enter a valid selling price');
        return;
      }

      if (quantity == null || quantity <= 0) {
        _showError('Please enter a valid available quantity');
        return;
      }

      if (minOrder == null || minOrder <= 0) {
        _showError('Please enter a valid minimum order');
        return;
      }

      if (minOrder > quantity) {
        _showError('Minimum order cannot be greater than available quantity');
        return;
      }

      if (_harvestDate != null &&
          _availableUntilDate != null &&
          _availableUntilDate!.isBefore(_harvestDate!)) {
        _showError('Available Until cannot be before Harvest Date');
        return;
      }

      setState(() {
        _currentStep = 3;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      Navigator.maybePop(context);
    }
  }

  Future<void> _pickProductImage() async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    final base64Image = base64Encode(bytes);

    setState(() {
      _productImage = File(image.path);
      _selectedImageBytes = bytes;
      _selectedImageBase64 = base64Image;
    });

    print('========== PRODUCT IMAGE ==========');
    print('Image selected: ${image.name}');
    print('Image bytes: ${bytes.length}');
    print('Base64 length: ${base64Image.length}');
    print('===================================');
  }

  Future<void> _publishProduct() async {
    final name = _productNameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final quantity = double.tryParse(_quantityController.text.trim());

    final minOrderText = _minOrderController.text.trim();
    final minOrder = minOrderText.isEmpty
        ? 1.0
        : double.tryParse(minOrderText);

    if (name.isEmpty) {
      _showError('Please enter a product name');
      return;
    }

    if (description.isEmpty) {
      _showError('Please enter a product description');
      return;
    }

    if (price == null || price <= 0) {
      _showError('Please enter a valid selling price');
      return;
    }

    if (quantity == null || quantity <= 0) {
      _showError('Please enter a valid available quantity');
      return;
    }

    if (minOrder == null || minOrder <= 0) {
      _showError('Please enter a valid minimum order');
      return;
    }

    if (minOrder > quantity) {
      _showError(
        'Minimum order cannot be greater than available quantity',
      );
      return;
    }

    if (_harvestDate != null &&
        _availableUntilDate != null &&
        _availableUntilDate!.isBefore(_harvestDate!)) {
      _showError(
        'Available Until cannot be before Harvest Date',
      );
      return;
    }

    double deliveryFee = 0;

    if (_deliveryOption == 'Farmer Delivery') {
      final parsedDeliveryFee = double.tryParse(
        _deliveryFeeController.text.trim(),
      );

      if (parsedDeliveryFee == null || parsedDeliveryFee < 0) {
        _showError('Please enter a valid delivery fee');
        return;
      }

      deliveryFee = parsedDeliveryFee;
    }

    try {
      setState(() {
        _isPublishing = true;
      });

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
        imageBase64: _selectedImageBase64,
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

      _showError(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);

    // Render Success Screen if published
    if (_currentStep == 4) {
      return _buildSuccessScreen(primaryGreen);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: _previousStep,
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
            // Top Progress Bar
            _buildProgressBar(primaryGreen),

            // Scrollable Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: _buildCurrentStepContent(primaryGreen),
                  ),
                ),
              ),
            ),

            // Fixed Bottom Action Button
            _buildBottomBar(primaryGreen),
          ],
        ),
      ),
    );
  }

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

  // Header Progress Indicator
  Widget _buildProgressBar(Color primaryGreen) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $_currentStep of 3',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryGreen,
                ),
              ),
              Text(
                '${((_currentStep / 3) * 100).toInt()}% Completed',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _currentStep / 3,
              backgroundColor: const Color(0xFFE8F5E9),
              valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // Controller for current step view
  Widget _buildCurrentStepContent(Color primaryGreen) {
    switch (_currentStep) {
      case 1:
        return _buildStep1Info(primaryGreen);
      case 2:
        return _buildStep2PriceInventory(primaryGreen);
      case 3:
        return _buildStep3DeliveryReview(primaryGreen);
      default:
        return const SizedBox.shrink();
    }
  }

  // ================= STEP 1: PRODUCT INFORMATION =================
  Widget _buildStep1Info(Color primaryGreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo Upload Box
        _buildFieldLabel('PRODUCT PHOTO'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFC8E6C9),
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: _pickProductImage,
            borderRadius: BorderRadius.circular(16),
            child: _productImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFFE8F5E9),
                        child: Icon(
                          Icons.add_a_photo_rounded,
                          color: primaryGreen,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Upload Product Photo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Clear photos help sell 2x faster',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          _productImage!,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _pickProductImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),

        // Product Name
        _buildFieldLabel('Product Name'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _productNameController,
          hintText: 'e.g. Fresh Organic Bok Choy',
        ),
        const SizedBox(height: 16),

        // Category Dropdown
        _buildFieldLabel('Category'),
        const SizedBox(height: 6),
        _buildDropdownField(
          value: _selectedCategory,
          items: _categories,
          onChanged: (val) => setState(() => _selectedCategory = val!),
        ),
        const SizedBox(height: 16),

        // Condition Choice Chips (Fresh / Organic)
        _buildFieldLabel('Product Condition'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildChoiceTile(
                title: 'Fresh',
                subtitle: 'Standard produce',
                isSelected: _productCondition == 'Fresh',
                onTap: () => setState(() => _productCondition = 'Fresh'),
                primaryGreen: primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildChoiceTile(
                title: 'Organic',
                subtitle: 'Chemical-free',
                isSelected: _productCondition == 'Organic',
                onTap: () => setState(() => _productCondition = 'Organic'),
                primaryGreen: primaryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Description Field
        _buildFieldLabel('Description'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _descriptionController,
          hintText: 'Describe quality, taste, or harvest details...',
          maxLines: 3,
        ),
      ],
    );
  }

  // ================= STEP 2: PRICE & INVENTORY =================
  Widget _buildStep2PriceInventory(Color primaryGreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PROMINENT MARKET RECOMMENDATION CARD
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8E9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFA5D6A7), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'Market Recommendation',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, color: Color(0xFFC8E6C9)),
              _buildRecommendationRow('Current restaurant demand', 'High 🔥'),
              const SizedBox(height: 6),
              _buildRecommendationRow('Typical market price', '\$1.10 – \$1.40 / kg'),
              const SizedBox(height: 6),
              _buildRecommendationRow('Recommended price', '\$1.25 / kg', isBold: true),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _priceController.text = '1.25';
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryGreen,
                    side: BorderSide(color: primaryGreen, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Use Recommended Price (\$1.25)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Selling Price
        _buildFieldLabel('Selling Price per kg'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _priceController,
          hintText: '0.00',
          keyboardType: TextInputType.number,
          suffixText: '\$ / kg',
        ),
        const SizedBox(height: 16),

        // Available Quantity & Minimum Order Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Available Quantity'),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _quantityController,
                    hintText: 'e.g. 100',
                    keyboardType: TextInputType.number,
                    suffixText: 'kg',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Minimum Order'),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _minOrderController,
                    hintText: 'e.g. 5',
                    keyboardType: TextInputType.number,
                    suffixText: 'kg',
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Date Pickers
        Row(
          children: [
            Expanded(
              child: _buildDatePickerTile(
                label: 'Harvest Date',
                selectedDate: _harvestDate,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _harvestDate = picked);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDatePickerTile(
                label: 'Available Until',
                selectedDate: _availableUntilDate,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _availableUntilDate = picked);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ================= STEP 3: DELIVERY & REVIEW =================
  Widget _buildStep3DeliveryReview(Color primaryGreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location Selector
        _buildFieldLabel('Location / Farm Origin'),
        const SizedBox(height: 6),
        _buildDropdownField(
          value: _selectedLocation,
          items: _locations,
          onChanged: (val) => setState(() => _selectedLocation = val!),
        ),
        const SizedBox(height: 16),

        // Delivery Options
        _buildFieldLabel('Delivery Method'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildChoiceTile(
                title: 'Farmer Delivery',
                subtitle: 'Deliver to buyer',
                isSelected: _deliveryOption == 'Farmer Delivery',
                onTap: () => setState(() => _deliveryOption = 'Farmer Delivery'),
                primaryGreen: primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildChoiceTile(
                title: 'Buyer Pickup',
                subtitle: 'Pickup at farm',
                isSelected: _deliveryOption == 'Buyer Pickup',
                onTap: () => setState(() => _deliveryOption = 'Buyer Pickup'),
                primaryGreen: primaryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_deliveryOption == 'Farmer Delivery') ...[
          _buildFieldLabel('Delivery Fee'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _deliveryFeeController,
            hintText: '0.00',
            keyboardType: TextInputType.number,
            suffixText: '\$',
          ),
          const SizedBox(height: 20),
        ],

        // Product Summary Preview Card
        _buildFieldLabel('PRODUCT PREVIEW'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Placeholder image box
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.eco_rounded, size: 40, color: primaryGreen),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _productNameController.text.isEmpty
                              ? 'Fresh Produce'
                              : _productNameController.text,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _productCondition,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${_priceController.text.isEmpty ? '0.00' : _priceController.text} / kg',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stock: ${_quantityController.text.isEmpty ? '0' : _quantityController.text} kg • $_selectedLocation',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Option: $_deliveryOption',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF616161)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= STEP 4: SUCCESS VIEW =================
  Widget _buildSuccessScreen(Color primaryGreen) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              CircleAvatar(
                radius: 46,
                backgroundColor: const Color(0xFFE8F5E9),
                child: Icon(Icons.check_circle_rounded, color: primaryGreen, size: 64),
              ),
              const SizedBox(height: 24),
              const Text(
                'Product Published!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your product is now available for restaurants in Cambodia to discover and order.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF757575), height: 1.4),
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
                        builder: (context) => const InventoryScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'View Product Listing',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.maybePop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD6D6D6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Dashboard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
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

  // Fixed Bottom Bar Button
  Widget _buildBottomBar(Color primaryGreen) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isPublishing
                  ? null
                  : (_currentStep == 3
                      ? _publishProduct
                      : _nextStep),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isPublishing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      _currentStep == 3
                          ? 'Publish Product'
                          : 'Next Step',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= UI HELPER COMPONENTS =================

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF424242),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: Color(0xFF212121)),
      decoration: InputDecoration(
        hintText: hintText,
        suffixText: suffixText,
        suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF616161)),
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6D6D6)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          style: const TextStyle(fontSize: 15, color: Color(0xFF212121)),
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChoiceTile({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryGreen,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryGreen : const Color(0xFFD6D6D6),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? primaryGreen : const Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD6D6D6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? 'Select date'
                      : '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: TextStyle(
                    fontSize: 13,
                    color: selectedDate == null ? const Color(0xFF9E9E9E) : const Color(0xFF212121),
                  ),
                ),
                const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.black54),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF424242)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? const Color(0xFF2E7D32) : const Color(0xFF212121),
          ),
        ),
      ],
    );
  }
}