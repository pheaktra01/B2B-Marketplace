import 'package:flutter/material.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/farmer/widgets/edit_product_screen.dart';
import 'package:mobile/features/product/services/product_service.dart';

class FarmerProductDetailScreen
    extends StatefulWidget {
  final Map<String, dynamic> product;

  const FarmerProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<FarmerProductDetailScreen> createState() =>
      _FarmerProductDetailScreenState();
}

class _FarmerProductDetailScreenState
    extends State<FarmerProductDetailScreen> {
  static const Color primaryGreen =
      Color(0xFF1E5631);

  late Map<String, dynamic> product;

  @override
  void initState() {
    super.initState();

    product = Map<String, dynamic>.from(
      widget.product,
    );
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  String _value(
    String key, {
    String fallback = 'Not specified',
  }) {
    final value =
        product[key]?.toString().trim();

    if (value == null || value.isEmpty) {
      return fallback;
    }

    return value;
  }

  String _getImageUrl() {
    final images = product['imageUrls'];

    if (images is List &&
        images.isNotEmpty) {
      final image =
          images.first.toString().trim();

      if (image.isNotEmpty) {
        return ApiConstants.imageUrl(image);
      }
    }

    final imageUrl =
        product['imageUrl']?.toString().trim();

    if (imageUrl != null &&
        imageUrl.isNotEmpty) {
      return ApiConstants.imageUrl(imageUrl);
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final name = _value(
      'name',
      fallback: 'Unnamed Product',
    );

    final category = _value('category');

    final price =
        _toDouble(product['price']);

    final quantity =
        _toDouble(product['quantity']);

    final isAvailable =
        product['isAvailable'] == true;

    final imageUrl = _getImageUrl();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          'Product Details',
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,

        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
            ),
            onPressed: _editProduct,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.only(
          bottom: 30,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================================
            // IMAGE
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 260,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) {
                        return _placeholder();
                      },
                    )
                  : _placeholder(),
            ),

            Padding(
              padding:
                  const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // STATUS
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? Colors.green
                              .withValues(
                              alpha: 0.10,
                            )
                          : Colors.grey
                              .withValues(
                              alpha: 0.10,
                            ),
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      isAvailable
                          ? '● Available'
                          : '● Unavailable',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.bold,
                        color: isAvailable
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // NAME
                  Text(
                    name,
                    style:
                        const TextStyle(
                      fontSize: 25,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // PRICE
                  Text(
                    '\$${price.toStringAsFixed(2)} / kg',
                    style:
                        const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  _buildSectionTitle(
                    'Inventory',
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _buildInfoCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Available Quantity',
                    value:
                        '${quantity.toStringAsFixed(1)} kg',
                  ),

                  _buildInfoCard(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    value: _value(
                      'location',
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  _buildSectionTitle(
                    'Product Information',
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _buildInfoRow(
                    'Description',
                    _value(
                      'description',
                    ),
                  ),

                  _buildInfoRow(
                    'Condition',
                    _value(
                      'condition',
                    ),
                  ),

                  _buildInfoRow(
                    'Minimum Order',
                    '${_toDouble(product['minOrder']).toStringAsFixed(1)} kg',
                  ),

                  _buildInfoRow(
                    'Delivery Method',
                    _value(
                      'deliveryMethod',
                    ),
                  ),

                  _buildInfoRow(
                    'Delivery Fee',
                    '\$${_toDouble(product['deliveryFee']).toStringAsFixed(2)}',
                  ),

                  _buildInfoRow(
                    'Harvest Date',
                    _value(
                      'harvestDate',
                    ),
                  ),

                  _buildInfoRow(
                    'Available Until',
                    _value(
                      'availableUntil',
                    ),
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed:
                          _editProduct,
                      icon: const Icon(
                        Icons.edit_outlined,
                      ),
                      label: const Text(
                        'Edit Product',
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            primaryGreen,
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
  ) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: primaryGreen,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style:
                      const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 14,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color:
                  Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade100,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 60,
          color: Colors.grey,
        ),
      ),
    );
  }

  Future<void> _editProduct() async {
    final id =
        product['id']?.toString();

    if (id == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditProductScreen(
          product: product,
        ),
      ),
    );

    // Refresh the product after editing
    try {
      final products =
          await ProductService.getMyProducts();

      final updated =
          products.cast<
              Map<String, dynamic>>();

      final found =
          updated.where(
        (item) =>
            item['id']?.toString() == id,
      );

      if (found.isNotEmpty &&
          mounted) {
        setState(() {
          product = Map<String, dynamic>.from(
            found.first,
          );
        });
      }
    } catch (_) {}
  }
}