import 'package:flutter/material.dart';
import 'package:mobile/features/product/services/product_service.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() =>
      _EditProductScreenState();
}

class _EditProductScreenState
    extends State<EditProductScreen> {
  static const Color primaryGreen =
      Color(0xFF135A27);

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _minOrderController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _deliveryFeeController;

  late String _category;
  late String _deliveryMethod;
  late bool _isAvailable;

  bool _isSaving = false;

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
      text: product['deliveryFee']?.toString() ?? '',
    );

    _category =
        product['category']?.toString() ?? 'Vegetables';

    _deliveryMethod =
        product['deliveryMethod']?.toString() ??
            'Farmer Delivery';

    _isAvailable =
        product['isAvailable'] == true;
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

  Future<void> _saveProduct() async {
    final name = _nameController.text.trim();

    final price = double.tryParse(
      _priceController.text.trim(),
    );

    final quantity = double.tryParse(
      _quantityController.text.trim(),
    );

    final minOrder = double.tryParse(
      _minOrderController.text.trim(),
    );

    final deliveryFee = double.tryParse(
      _deliveryFeeController.text.trim(),
    );

    if (name.isEmpty ||
        price == null ||
        quantity == null) {
      _showMessage(
        'Please enter valid product information.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final id =
          widget.product['id']?.toString();

      if (id == null) {
        throw Exception(
          'Product ID not found.',
        );
      }

      await ProductService.updateProduct(
        productId: id,
        data: {
          'name': name,
          'price': price,
          'quantity': quantity,
          'minOrder': minOrder ?? 0,
          'description':
              _descriptionController.text.trim(),
          'category': _category,
          'location':
              _locationController.text.trim(),
          'deliveryMethod': _deliveryMethod,
          'deliveryFee': deliveryFee ?? 0,
          'isAvailable': _isAvailable,
        },
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'Failed to update product: $e',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F6E8),

      appBar: AppBar(
        title: const Text(
          'Edit Product',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Basic Information',
            ),

            const SizedBox(height: 12),

            _buildTextField(
              controller: _nameController,
              label: 'Product Name',
              icon: Icons.eco_outlined,
            ),

            const SizedBox(height: 12),

            _buildDropdown(
              label: 'Category',
              value: _category,
              items: const [
                'Vegetables',
                'Microgreens',
                'Fruits',
                'Herbs & Spices',
                'Leafy Greens',
                'Other',
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _category = value;
                });
              },
            ),

            const SizedBox(height: 24),

            _buildSectionTitle(
              'Pricing & Stock',
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller:
                        _priceController,
                    label: 'Price',
                    prefix: '\$ ',
                    icon:
                        Icons.attach_money,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildTextField(
                    controller:
                        _quantityController,
                    label: 'Quantity',
                    suffix: ' kg',
                    icon:
                        Icons.inventory_2_outlined,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildTextField(
              controller:
                  _minOrderController,
              label: 'Minimum Order',
              suffix: ' kg',
              icon:
                  Icons.shopping_basket_outlined,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),
            ),

            const SizedBox(height: 24),

            _buildSectionTitle(
              'Product Details',
            ),

            const SizedBox(height: 12),

            _buildTextField(
              controller:
                  _descriptionController,
              label: 'Description',
              icon:
                  Icons.description_outlined,
              maxLines: 4,
            ),

            const SizedBox(height: 24),

            _buildSectionTitle(
              'Delivery',
            ),

            const SizedBox(height: 12),

            _buildTextField(
              controller:
                  _locationController,
              label: 'Location',
              icon:
                  Icons.location_on_outlined,
            ),

            const SizedBox(height: 12),

            _buildDropdown(
              label: 'Delivery Method',
              value: _deliveryMethod,
              items: const [
                'Farmer Delivery',
                'Buyer Pickup',
                'Both',
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _deliveryMethod = value;
                });
              },
            ),

            const SizedBox(height: 12),

            _buildTextField(
              controller:
                  _deliveryFeeController,
              label: 'Delivery Fee',
              prefix: '\$ ',
              icon:
                  Icons.local_shipping_outlined,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),
            ),

            const SizedBox(height: 24),

            // AVAILABILITY
            Container(
              padding:
                  const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.visibility_outlined,
                    color: primaryGreen,
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available for Sale',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Restaurants can see and order this product.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Switch(
                    value: _isAvailable,
                    activeThumbColor:
                        primaryGreen,
                    onChanged: (value) {
                      setState(() {
                        _isAvailable = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    _isSaving
                        ? null
                        : _saveProduct,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      primaryGreen,
                  foregroundColor:
                      Colors.white,
                  disabledBackgroundColor:
                      Colors.grey.shade300,
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? prefix,
    String? suffix,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        suffixText: suffix,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?>
        onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue:
          items.contains(value)
              ? value
              : items.first,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(
          Icons.category_outlined,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
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
}