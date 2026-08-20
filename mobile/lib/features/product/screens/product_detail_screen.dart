import 'dart:convert';

import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // Theme Colors matching the image
  static const Color primaryGreen = Color(0xFF135A27);
  static const Color lightGreenBg = Color(0xFFE2F0E5);
  static const Color pageBgColor = Color(0xFFF7F9F8);
  static const Color buttonOrange = Color(0xFFFF8C00);

  int _selectedImageIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;

  // Sample Images for the Gallery
  List<String> get _productImages {
    final image = widget.product['imageBase64']?.toString();

    if (image == null || image.isEmpty) {
      return [];
    }

    return [image];
  }

  double get _pricePerKg {
    final value = widget.product['price'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String get _productName {
    return widget.product['name']?.toString() ??
        'Unnamed Product';
  }

  String get _category {
    return widget.product['category']?.toString() ??
        '';
  }

  String get _description {
    return widget.product['description']?.toString() ??
        'No description available.';
  }

  double get _stock {
    final value = widget.product['quantity'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String get _farmName {
    return widget.product['farmerName']?.toString() ??
        widget.product['farmName']?.toString() ??
        'Farmer';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: pageBgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          _productName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Main Image Preview with Favorite Button
            _buildMainImageView(),

            const SizedBox(height: 12),

            // 2. Thumbnail List Below Main Image
            _buildThumbnailGallery(),

            const SizedBox(height: 20),

            // 3. Title & Quantity Selector Row
            _buildTitleAndQuantityRow(),

            const SizedBox(height: 8),

            // 4. Price & Stock Badge
            _buildPriceAndStockRow(),

            const SizedBox(height: 20),

            // 5. Product Description
            _buildProductDescription(),

            const SizedBox(height: 20),

            // 6. Farmer / Vendor Card
            _buildFarmerCard(),

            const SizedBox(height: 24),
          ],
        ),
      ),

      // 7. Bottom Action Bar (Price total & Add to Cart button)
      bottomNavigationBar: _buildBottomCartBar(),
    );
  }

  // --- WIDGET BUILDERS ---
  Widget _buildMainImageView() {
    if (_productImages.isEmpty) {
      return _buildImagePlaceholder(
        height: 320,
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _buildImage(
            _productImages[_selectedImageIndex],
            height: 320,
          ),
        ),

        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: _isFavorite
                    ? Colors.red
                    : primaryGreen,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(
    String image,
    {
    required double height,
  }) {
    if (image.isEmpty) {
      return _buildImagePlaceholder(
        height: height,
      );
    }

    // Base64
    if (_looksLikeBase64(image)) {
      try {
        String base64String = image;

        if (base64String.contains(',')) {
          base64String =
              base64String.split(',').last;
        }

        final bytes = base64Decode(base64String);

        return Image.memory(
          bytes,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _buildImagePlaceholder(
              height: height,
            );
          },
        );
      } catch (e) {
        debugPrint(
          'Detail image decode error: $e',
        );

        return _buildImagePlaceholder(
          height: height,
        );
      }
    }

    // URL
    return Image.network(
      image,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return _buildImagePlaceholder(
          height: height,
        );
      },
    );
  }

  bool _looksLikeBase64(String value) {
    return value.startsWith('data:image') ||
        (!value.startsWith('http://') &&
            !value.startsWith('https://'));
  }

  Widget _buildImagePlaceholder({
    required double height,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.eco_rounded,
        size: 60,
        color: primaryGreen,
      ),
    );
  }

  Widget _buildThumbnailGallery() {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _productImages.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedImageIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedImageIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? primaryGreen : Colors.transparent,
                  width: 2.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildThumbnailImage(
                  _productImages[index],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThumbnailImage(String image) {
    if (image.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(
          Icons.eco,
          color: primaryGreen,
        ),
      );
    }

    // URL
    if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.eco,
              color: primaryGreen,
            ),
          );
        },
      );
    }

    // Base64
    try {
      String base64String = image;

      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }

      final bytes = base64Decode(base64String);

      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.eco,
              color: primaryGreen,
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(
          Icons.eco,
          color: primaryGreen,
        ),
      );
    }
  }

  Widget _buildTitleAndQuantityRow() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                _productName,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                  color: Colors.black87,
                ),
              ),

              if (_category.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  _category,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 12),

        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_quantity > 1) {
                    setState(() {
                      _quantity--;
                    });
                  }
                },
                icon: const Icon(
                  Icons.remove,
                  size: 18,
                  color: primaryGreen,
                ),
                constraints:
                    const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
                padding: EdgeInsets.zero,
              ),

              Text(
                '$_quantity',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              IconButton(
                onPressed: () {
                  if (_quantity < _stock) {
                    setState(() {
                      _quantity++;
                    });
                  }
                },
                icon: const Icon(
                  Icons.add,
                  size: 18,
                  color: primaryGreen,
                ),
                constraints:
                    const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndStockRow() {
    return Row(
      children: [
        Text(
          '\$${_pricePerKg.toStringAsFixed(2)}/kg',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryGreen,
          ),
        ),

        const SizedBox(width: 10),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: lightGreenBg,
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.circle,
                color: primaryGreen,
                size: 8,
              ),

              const SizedBox(width: 6),

              Text(
                '${_stock.toStringAsFixed(1)} KG IN STOCK',
                style: const TextStyle(
                  color: primaryGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductDescription() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'PRODUCT DESCRIPTION',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          _description,
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildFarmerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                child: Icon(
                  Icons.agriculture,
                  color: primaryGreen,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _farmName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.orange,
                          size: 14,
                        ),

                        const SizedBox(width: 4),

                        const Text(
                          '4.9',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(width: 4),

                        Text(
                          '(Reviews)',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: primaryGreen,
                    width: 1.5,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Contact',
                  style: TextStyle(
                    color: primaryGreen,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (_category.isNotEmpty)
                _buildTagChip(_category),

              _buildTagChip('Local Delivery'),
              _buildTagChip('Wholesale Pricing'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBottomCartBar() {
    final double totalAmount =
        _pricePerKg * _quantity;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Total',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  '\$${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 24),

            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Add to cart
                },
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      buttonOrange,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}