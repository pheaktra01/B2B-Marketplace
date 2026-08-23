import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String farmName;
  final String price;

  final XFile? localImage;

  final String location;
  final String availableQuantity;

  final bool isAvailable;
  final bool isFavorite;

  final VoidCallback? onTap;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.farmName,
    required this.price,

    this.location = 'Kandal',
    this.availableQuantity = '150 kg',

    this.isAvailable = true,
    this.isFavorite = false,

    this.localImage,

    this.onTap,
    this.onFavoritePressed,
    this.onAddToCart,
  });

  static const Color primaryGreen = Color(0xFF135A27);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // PRODUCT IMAGE
              // ==================================================

              _buildImageSection(),

              // ==================================================
              // PRODUCT INFORMATION
              // ==================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  12,
                  14,
                  14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ------------------------------------------
                    // PRODUCT NAME + PRICE
                    // ------------------------------------------

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: primaryGreen,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ------------------------------------------
                    // FARMER
                    // ------------------------------------------

                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: primaryGreen.withValues(
                              alpha: 0.10,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.eco_outlined,
                            size: 15,
                            color: primaryGreen,
                          ),
                        ),

                        const SizedBox(width: 7),

                        Expanded(
                          child: Text(
                            farmName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ------------------------------------------
                    // LOCATION + AVAILABLE
                    // ------------------------------------------

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),

                        const SizedBox(width: 4),

                        Flexible(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          child: Text(
                            '|',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),

                        Text(
                          'Available: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        Text(
                          availableQuantity,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ------------------------------------------
                    // ADD TO CART
                    // ------------------------------------------

                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton.icon(
                          onPressed:
                              isAvailable ? onAddToCart : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                Colors.grey.shade300,
                            disabledForegroundColor:
                                Colors.grey.shade600,
                            elevation: 0,
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(
                            Icons.add_shopping_cart_outlined,
                            size: 17,
                          ),
                          label: Text(
                            isAvailable
                                ? 'Add to Cart'
                                : 'Unavailable',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
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
      ),
    );
  }

  // ==========================================================
  // IMAGE SECTION
  // ==========================================================

  Widget _buildImageSection() {
    return Stack(
      children: [
        // ======================================================
        // PRODUCT IMAGE
        // ======================================================

        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 190,
            child: localImage != null
                ? FutureBuilder(
                    future: localImage!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                          color: Colors.grey.shade100,
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
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return _buildImagePlaceholder();
                        },
                      );
                    },
                  )
                : imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return _buildImagePlaceholder();
                        },
                        loadingBuilder: (
                          context,
                          child,
                          loadingProgress,
                        ) {
                          if (loadingProgress == null) {
                            return child;
                          }

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
                      )
                    : _buildImagePlaceholder(),
          ),
        ),

        // ======================================================
        // AVAILABLE BADGE - TOP LEFT
        // ======================================================

        if (isAvailable)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.94,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 5),

                  const Text(
                    'Available',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ======================================================
        // FAVORITE BUTTON - TOP RIGHT
        // ======================================================

        Positioned(
          top: 10,
          right: 10,
          child: Material(
            color: Colors.white.withValues(
              alpha: 0.92,
            ),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onFavoritePressed,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  size: 20,
                  color: isFavorite
                      ? Colors.red
                      : Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // IMAGE PLACEHOLDER
  // ==========================================================

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 50,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}