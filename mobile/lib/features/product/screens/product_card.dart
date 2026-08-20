import 'dart:convert';

import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String farmName;
  final String price;
  final bool isFavorite;

  final VoidCallback? onFavoritePressed;
  final VoidCallback? onAddToCart;
  final VoidCallback? onTap;

  static const Color primaryColor = Color(0xFF0F5A27);

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.farmName,
    required this.price,
    this.isFavorite = false,
    this.onFavoritePressed,
    this.onAddToCart,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // IMAGE
              // ==================================================

              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: _buildProductImage(),
                  ),

                  // ==================================================
                  // FAVORITE BUTTON
                  // ==================================================

                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: primaryColor,
                        ),
                        onPressed: onFavoritePressed,
                      ),
                    ),
                  ),
                ],
              ),

              // ==================================================
              // DETAILS
              // ==================================================

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          Icons.agriculture,
                          size: 16,
                          color: Colors.grey[600],
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            farmName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),

                        ElevatedButton(
                          onPressed: onAddToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Add to Cart',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT IMAGE
  // ============================================================

  Widget _buildProductImage() {
    // No image
    if (imageUrl.trim().isEmpty) {
      return _buildImagePlaceholder();
    }

    final image = imageUrl.trim();

    // ==========================================================
    // BASE64 IMAGE
    // ==========================================================

    if (_looksLikeBase64(image)) {
      try {
        String base64String = image;

        // Handles:
        // data:image/png;base64,xxxxx
        // data:image/jpeg;base64,xxxxx
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }

        final bytes = base64Decode(base64String);

        return Image.memory(
          bytes,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _buildImagePlaceholder();
          },
        );
      } catch (e) {
        debugPrint(
          'ProductCard Base64 image decode error: $e',
        );

        return _buildImagePlaceholder();
      }
    }

    // ==========================================================
    // NETWORK IMAGE
    // ==========================================================

    return Image.network(
      image,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,

      // Loading indicator
      loadingBuilder: (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          height: 180,
          width: double.infinity,
          color: Colors.grey.shade100,
          child: const Center(
            child: CircularProgressIndicator(
              color: primaryColor,
              strokeWidth: 2,
            ),
          ),
        );
      },

      // Error
      errorBuilder: (_, __, ___) {
        debugPrint(
          'ProductCard image failed to load: $image',
        );

        return _buildImagePlaceholder();
      },
    );
  }

  // ============================================================
  // DETECT BASE64
  // ============================================================

  bool _looksLikeBase64(String value) {
    return value.startsWith('data:image') ||
        (!value.startsWith('http://') &&
            !value.startsWith('https://'));
  }

  // ============================================================
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget _buildImagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 40,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 6),
          Text(
            'No image',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}