import 'package:flutter/material.dart';
import 'package:mobile/core/constants/api_constants.dart';

class FarmerProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onAvailabilityChanged;

  const FarmerProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onAvailabilityChanged,
  });

  static const Color primaryGreen = Color(0xFF1E5631);

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

  String _getImageUrl() {
    final images = product['imageUrls'];

    if (images is List && images.isNotEmpty) {
      final image = images.first.toString().trim();

      if (image.isNotEmpty) {
        return ApiConstants.imageUrl(image);
      }
    }

    // Optional fallback if backend sometimes returns imageUrl
    final imageUrl =
        product['imageUrl']?.toString().trim();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ApiConstants.imageUrl(imageUrl);
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final name =
        product['name']?.toString() ??
            'Unnamed Product';

    final category =
        product['category']?.toString() ??
            '';

    final location =
        product['location']?.toString() ??
            'Unknown';

    final price =
        _toDouble(product['price']);

    final quantity =
        _toDouble(product['quantity']);

    final isAvailable =
        product['isAvailable'] == true;

    final imageUrl = _getImageUrl();

    final isLowStock =
        quantity > 0 && quantity <= 20;

    final isOutOfStock =
        quantity <= 0;

    String status;
    Color statusColor;
    IconData statusIcon;

    if (!isAvailable) {
      status = 'Inactive';
      statusColor = Colors.grey;
      statusIcon = Icons.pause_circle_outline;
    } else if (isOutOfStock) {
      status = 'Out of Stock';
      statusColor = Colors.red;
      statusIcon = Icons.remove_circle_outline;
    } else if (isLowStock) {
      status = 'Low Stock';
      statusColor = Colors.orange.shade800;
      statusIcon = Icons.warning_amber_rounded;
    } else {
      status = 'Active';
      statusColor = Colors.green.shade700;
      statusIcon = Icons.check_circle_outline;
    }

    final progress =
        (quantity / 100).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ====================================================
          // IMAGE
          // ====================================================

          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 180,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (
                                context,
                                error,
                                stackTrace,
                              ) {
                            return _buildPlaceholder();
                          },
                          loadingBuilder:
                              (
                                context,
                                child,
                                loadingProgress,
                              ) {
                            if (loadingProgress ==
                                null) {
                              return child;
                            }

                            return Container(
                              color:
                                  Colors.grey.shade100,
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
                          },
                        )
                      : _buildPlaceholder(),
                ),
              ),

              // STATUS
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.94,
                    ),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // MORE
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: Colors.white.withValues(
                    alpha: 0.94,
                  ),
                  shape:
                      const CircleBorder(),
                  child: PopupMenuButton<String>(
                    padding:
                        EdgeInsets.zero,
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.black87,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit?.call();
                      }

                      if (value == 'delete') {
                        onDelete?.call();
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 19,
                            ),
                            SizedBox(width: 10),
                            Text('Edit Product'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 19,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Text('Delete Product'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ====================================================
          // DETAILS
          // ====================================================

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // NAME + PRICE
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Text(
                      '\$${price.toStringAsFixed(2)}/kg',
                      style:
                          const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                        color: primaryGreen,
                      ),
                    ),
                  ],
                ),

                if (category.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // QUANTITY
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 17,
                      color:
                          Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${quantity.toStringAsFixed(1)} kg available',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // LOCATION
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 17,
                      color:
                          Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // STOCK LEVEL
                Text(
                  'Stock Level',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        Colors.grey.shade600,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 6),

                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  borderRadius:
                      BorderRadius.circular(4),
                  backgroundColor:
                      Colors.grey.shade200,
                  valueColor:
                      AlwaysStoppedAnimation<
                          Color>(
                    statusColor,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${(progress * 100).toInt()}% stock level',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        Colors.grey.shade600,
                  ),
                ),

                const Divider(
                  height: 26,
                ),

                // AVAILABLE SWITCH
                Row(
                  children: [
                    const Text(
                      'Available for Sale',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

                    Switch(
                      value: isAvailable,
                      activeThumbColor:
                          primaryGreen,
                      onChanged:
                          onAvailabilityChanged,
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // VIEW + EDIT
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(
                          Icons.visibility_outlined,
                          size: 18,
                        ),
                        label: const Text(
                          'View Details',
                        ),
                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              primaryGreen,
                          side: const BorderSide(
                            color: primaryGreen,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                        ),
                        label: const Text(
                          'Edit',
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
                              10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }
}