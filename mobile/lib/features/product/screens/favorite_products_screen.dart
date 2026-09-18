import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/features/cart/services/cart_service.dart';
import 'package:mobile/features/product/screens/product_card.dart';
import 'package:mobile/features/product/services/favorites_service.dart';
import 'package:mobile/features/restaurant/widgets/restaurant_bottom_nav_bar.dart';
import 'package:mobile/l10n/app_localizations.dart';

class FavoriteProductsScreen extends StatefulWidget {
  const FavoriteProductsScreen({super.key});

  @override
  State<FavoriteProductsScreen> createState() => _FavoriteProductsScreenState();
}

class _FavoriteProductsScreenState extends State<FavoriteProductsScreen> {
  static const Color primaryGreen = Color(0xFF135A27);
  static const Color pageBgColor = Color(0xFFF7F9F8);

  final CartService _cartService = CartService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _favoriteProducts = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await FavoritesService.getFavoriteProducts();

      if (!mounted) return;
      setState(() {
        _favoriteProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _toggleFavorite(String productId) async {
    // Optimistic removal from screen
    setState(() {
      _favoriteProducts.removeWhere((p) => p['id']?.toString() == productId);
    });

    await FavoritesService.toggleFavorite(productId);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.removedFromFavorites ?? 'Removed from favorites'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    try {
      final productId = product['id']?.toString() ?? '';
      if (productId.isEmpty) return;

      await _cartService.addToCart(
        productId: productId,
        quantity: 1,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        final name = product['name']?.toString() ?? 'produce';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.addedProduceToCart(name) ?? 'Added $name to cart'),
            backgroundColor: primaryGreen,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.failedAddToCart(e.toString()) ?? 'Failed to add to cart: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getProductImage(Map<String, dynamic> product) {
    final images = product['imageUrls'];
    if (images is List && images.isNotEmpty) {
      final img = images.first.toString().trim();
      if (img.isNotEmpty) return ApiConstants.imageUrl(img);
    }
    return '';
  }

  String _getFarmerName(Map<String, dynamic> product) {
    final farmer = product['farmer'];
    if (farmer is Map &&
        farmer['name'] != null &&
        farmer['name'].toString().isNotEmpty) {
      return farmer['name'].toString();
    }
    return product['farmerName']?.toString() ??
        product['farmName']?.toString() ??
        'Local Farm';
  }

  String _formatPrice(dynamic value) {
    double? price;
    if (value is num) {
      price = value.toDouble();
    } else {
      price = double.tryParse(value?.toString() ?? '');
    }
    if (price == null) return '\$0.00/kg';
    return '\$${price.toStringAsFixed(2)}/kg';
  }

  String _formatQuantity(dynamic value) {
    if (value == null) return '0 kg';
    return '$value kg';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: pageBgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n?.favoriteProducts ?? 'Favorite Products',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        color: primaryGreen,
        child: _buildBody(l10n),
      ),
      bottomNavigationBar: const RestaurantBottomNavBar(
        currentIndex: 1,
      ),
    );
  }

  Widget _buildBody(AppLocalizations? l10n) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryGreen),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
              const SizedBox(height: 12),
              Text(
                l10n?.couldNotLoadFavorites ?? 'Could not load favorites',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadFavorites,
                style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                child:
                    Text(l10n?.retry ?? 'Retry', style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_favoriteProducts.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_outline,
                  size: 54,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n?.noFavoritesYet ?? 'No favorite products yet',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.favoritesEmptySubtitle ??
                    'Tap the heart icon on any produce in the marketplace\nto save it here for fast kitchen re-ordering.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.restaurantHome),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.storefront_outlined, size: 18),
                label: Text(
                  l10n?.browseProduce ?? 'Browse Produce',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _favoriteProducts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final product = _favoriteProducts[index];
        final productId = product['id']?.toString() ?? '';

        return ProductCard(
          imageUrl: _getProductImage(product),
          productName: product['name']?.toString() ?? 'Product',
          farmName: _getFarmerName(product),
          price: _formatPrice(product['price']),
          location: product['location']?.toString() ?? 'Cambodia',
          availableQuantity: _formatQuantity(product['quantity']),
          isAvailable: product['isAvailable'] == true,
          isFavorite: true,
          onFavoritePressed: () => _toggleFavorite(productId),
          onAddToCart: () => _addToCart(product),
          onTap: () {
            context
                .push(AppRoutes.productDetail, extra: product)
                .then((_) => _loadFavorites());
          },
        );
      },
    );
  }
}
