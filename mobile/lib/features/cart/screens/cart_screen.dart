import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/core/routing/route_args.dart';
import 'package:mobile/features/cart/models/cart_model.dart';
import 'package:mobile/features/cart/services/cart_service.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
import 'package:mobile/features/notification/services/notification_service.dart';
import 'package:mobile/features/profile/services/user_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // ==========================================================
  // COLORS & THEME
  // ==========================================================

  static const Color pageBgColor = Color(0xFFF7F9F8);
  static const Color primaryGreen = Color(0xFF135A27);
  static const Color darkGreenBadge = Color(0xFF1F5E2B);
  static const Color buttonOrange = Color(0xFFFF8C00);

  // ==========================================================
  // SERVICES
  // ==========================================================

  final CartService _cartService = CartService();
  final UserService _userService = UserService();

  // ==========================================================
  // STATE
  // ==========================================================

  Cart? _cart;
  Cart? _previousCartSnapshot;
  bool _isLoading = true;
  bool _isSyncingBeforeCheckout = false;
  String? _errorMessage;
  String? _avatarUrl;

  // Optimistic & Debounce Tracking
  final Map<String, Timer> _debounceTimers = {};
  final Set<String> _syncingProductIds = {};

  // Delivery Address
  String _deliveryAddress = 'Building 42, St 271, Boeng Tumpun, Phnom Penh';

  // Delivery Notes presets
  final TextEditingController _notesController = TextEditingController();
  final List<String> _presetNotes = [
    'Early morning (6-8 AM)',
    'Call on arrival',
    'Kitchen loading dock',
    'Inspect on delivery',
  ];
  String? _selectedPreset;

  // ==========================================================
  // INIT & DISPOSE
  // ==========================================================

  @override
  void initState() {
    super.initState();
    _loadCart();
    _loadUserProfile();
  }

  @override
  void dispose() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _userService.getProfile();
      final data = profile['data'];
      final avatar = data is Map ? data['avatarUrl']?.toString() : null;
      if (mounted && avatar != null && avatar.isNotEmpty) {
        setState(() => _avatarUrl = ApiConstants.imageUrl(avatar));
      }
    } catch (e) {
      debugPrint('Error loading user profile in cart: $e');
    }
  }

  // ==========================================================
  // LOAD CART
  // ==========================================================

  Future<void> _loadCart() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cart = await _cartService.getCart();
      if (!mounted) return;

      setState(() {
        _cart = cart;
        _previousCartSnapshot = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  // ==========================================================
  // OPTIMISTIC QUANTITY STEPPER WITH DEBOUNCE (0ms UI LATENCY)
  // ==========================================================

  void _onQuantityChanged(CartItem item, double newQuantity) {
    HapticFeedback.selectionClick();

    if (newQuantity <= 0) {
      _confirmOrRemoveItem(item);
      return;
    }

    // Save snapshot before local change if not already saved
    _previousCartSnapshot ??= _cart;

    // 1. Instant local optimistic update (0ms perceived latency)
    setState(() {
      _cart = _cart?.updateItemQuantity(
        productId: item.productId,
        newQuantity: newQuantity,
      );
    });

    // 2. Debounce backend sync by 400ms to batch rapid taps
    _debounceTimers[item.productId]?.cancel();
    _debounceTimers[item.productId] = Timer(
      const Duration(milliseconds: 400),
      () => _syncQuantityToServer(item.productId, newQuantity),
    );
  }

  Future<void> _syncQuantityToServer(
    String productId,
    double quantity,
  ) async {
    if (!mounted) return;
    setState(() => _syncingProductIds.add(productId));

    try {
      final updatedCart = await _cartService.updateCartItem(
        productId: productId,
        quantity: quantity,
      );

      if (!mounted) return;

      // Update state with server response only if no other debounced tap is pending
      if (!_debounceTimers.containsKey(productId)) {
        setState(() {
          _cart = updatedCart;
          _previousCartSnapshot = null;
        });
      }
    } catch (e) {
      if (!mounted) return;

      // Rollback to prior snapshot
      if (_previousCartSnapshot != null) {
        setState(() {
          _cart = _previousCartSnapshot;
          _previousCartSnapshot = null;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update item: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _syncingProductIds.remove(productId));
      }
    }
  }

  // ==========================================================
  // REMOVE ITEM
  // ==========================================================

  Future<void> _confirmOrRemoveItem(CartItem item) async {
    await _removeItem(item);
  }

  Future<void> _removeItem(CartItem item) async {
    HapticFeedback.mediumImpact();

    // Cancel pending debounce for this item
    _debounceTimers[item.productId]?.cancel();
    _debounceTimers.remove(item.productId);

    final backupCart = _cart;

    // 1. Instant local optimistic deletion
    setState(() {
      _cart = _cart?.removeItem(productId: item.productId);
    });

    try {
      final updatedCart = await _cartService.removeFromCart(
        productId: item.productId,
      );

      if (!mounted) return;

      setState(() {
        _cart = updatedCart;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.productName} removed from cart'),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Rollback on failure
      setState(() {
        _cart = backupCart;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove ${item.productName}'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==========================================================
  // CLEAR CART
  // ==========================================================

  Future<void> _confirmClearCart() async {
    HapticFeedback.mediumImpact();

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to remove all products from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _cartService.clearCart();
      await _loadCart();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to clear cart: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  // ==========================================================
  // EDIT ADDRESS MODAL
  // ==========================================================

  void _showAddressPicker() {
    HapticFeedback.selectionClick();
    final controller = TextEditingController(text: _deliveryAddress);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Delivery Destination',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Enter your kitchen or restaurant address:',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. Building 42, St 271, Boeng Tumpun, Phnom Penh',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: primaryGreen),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      setState(() => _deliveryAddress = text);
                    }
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Save Address',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // PROCEED TO CHECKOUT
  // ==========================================================

  Future<void> _proceedToCheckout() async {
    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();

    if (_cart == null || _cart!.items.isEmpty) return;

    // Flush any pending debounced quantity updates before navigating
    if (_debounceTimers.isNotEmpty) {
      setState(() => _isSyncingBeforeCheckout = true);

      final timerEntries = List<MapEntry<String, Timer>>.from(_debounceTimers.entries);
      for (final entry in timerEntries) {
        entry.value.cancel();
        _debounceTimers.remove(entry.key);

        final item = _cart!.items.cast<CartItem?>().firstWhere(
              (i) => i != null && (i.productId == entry.key || i.id == entry.key),
              orElse: () => null,
            );

        if (item != null) {
          try {
            final updated = await _cartService.updateCartItem(
              productId: item.productId,
              quantity: item.quantity,
            );
            _cart = updated;
          } catch (_) {
            // Keep current cart state if individual sync fails
          }
        }
      }

      if (mounted) setState(() => _isSyncingBeforeCheckout = false);
    }

    if (!mounted || _cart == null) return;

    context.push(
      AppRoutes.restaurantCheckout,
      extra: CheckoutArgs(
        cart: _cart!,
        deliveryNotes: _notesController.text.trim(),
        deliveryAddress: _deliveryAddress,
      ),
    );
  }

  // ==========================================================
  // FORMAT HELPERS
  // ==========================================================

  String _formatPrice(double value) => '\$${value.toStringAsFixed(2)}';

  String _formatQuantity(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  String _getImageUrl(CartItem item) {
    final image = item.imageUrl.trim();
    if (image.isEmpty) return '';
    return ApiConstants.imageUrl(image);
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final hasItems = _cart != null && _cart!.items.isNotEmpty;

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: FarmerAppBar(
        isRestaurant: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: primaryGreen),
            tooltip: 'My Orders',
            onPressed: () => context.push(AppRoutes.restaurantOrders),
          ),
          if (hasItems)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
              tooltip: 'Clear Cart',
              onPressed: _confirmClearCart,
            ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () => context.push(AppRoutes.notifications),
              ),
              ValueListenableBuilder<int>(
                valueListenable: NotificationService.unreadCountNotifier,
                builder: (context, unreadCount, _) {
                  if (unreadCount <= 0) return const SizedBox.shrink();
                  return Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 16),
                      height: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => context.go(AppRoutes.restaurantProfile),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.8),
                    width: 2.0,
                  ),
                ),
                child: ClipOval(
                  child: _avatarUrl != null
                      ? Image.network(
                          _avatarUrl!,
                          width: 36,
                          height: 36,
                          cacheWidth: 100,
                          cacheHeight: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            'assets/default_avatar.jpg',
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/default_avatar.jpg',
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _loadCart(),
            _loadUserProfile(),
          ]);
        },
        color: primaryGreen,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryGreen),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_cart == null || _cart!.items.isEmpty) {
      return _buildEmptyCart();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 14),
          _buildAddressBanner(),
          const SizedBox(height: 14),
          _buildCartItemList(),
          const SizedBox(height: 14),
          _buildDeliveryNotesSection(),
          const SizedBox(height: 16),
          _buildOrderSummaryCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader() {
    final itemCount = _cart?.itemCount ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Fresh Cart',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Direct from certified local growers',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: darkGreenBadge,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$itemCount ${itemCount == 1 ? 'Item' : 'Items'}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // ADDRESS BANNER
  // ==========================================================

  Widget _buildAddressBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryGreen.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivering To Kitchen',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _deliveryAddress,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _showAddressPicker,
            style: TextButton.styleFrom(
              foregroundColor: primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(40, 30),
            ),
            child: const Text(
              'Edit',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CART ITEMS LIST
  // ==========================================================

  Widget _buildCartItemList() {
    final items = _cart?.items ?? [];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, unused) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSyncing = _syncingProductIds.contains(item.productId);

        return Dismissible(
          key: ValueKey('cart_${item.productId}_${item.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
          ),
          confirmDismiss: (_) async {
            await _removeItem(item);
            return false;
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildProductImage(item),
                ),
                const SizedBox(width: 12),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _removeItem(item),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatPrice(item.unitPrice)} / kg',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              'Subtotal: ${_formatPrice(item.subtotal)}',
                              key: ValueKey<String>(_formatPrice(item.subtotal)),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          _buildQuantityStepper(item, isSyncing),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage(CartItem item) {
    final imageUrl = _getImageUrl(item);

    if (imageUrl.isEmpty) {
      return Container(
        width: 72,
        height: 72,
        color: Colors.grey.shade100,
        child: const Icon(Icons.eco_outlined, color: primaryGreen, size: 28),
      );
    }

    return Image.network(
      imageUrl,
      width: 72,
      height: 72,
      cacheWidth: 150,
      cacheHeight: 150,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 72,
        height: 72,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 72,
          height: 72,
          color: Colors.grey.shade100,
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: primaryGreen,
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // QUANTITY STEPPER (ZERO-LAG OPTIMISTIC)
  // ==========================================================

  Widget _buildQuantityStepper(CartItem item, bool isSyncing) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // MINUS
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _onQuantityChanged(item, item.quantity - 1),
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: Icon(
                item.quantity <= 1 ? Icons.delete_outline : Icons.remove,
                size: 16,
                color: item.quantity <= 1 ? Colors.red : Colors.black87,
              ),
            ),
          ),
          // VALUE (ANIMATED SMOOTH TRANSITION)
          Container(
            constraints: const BoxConstraints(minWidth: 36),
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.85, end: 1.0).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Text(
                _formatQuantity(item.quantity),
                key: ValueKey<double>(item.quantity),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          // PLUS
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _onQuantityChanged(item, item.quantity + 1),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: darkGreenBadge,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.add,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DELIVERY NOTES SECTION
  // ==========================================================

  Widget _buildDeliveryNotesSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.note_alt_outlined, size: 18, color: primaryGreen),
              const SizedBox(width: 8),
              Text(
                'Kitchen Delivery Notes',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Preset chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _presetNotes.map((preset) {
              final isSelected = _selectedPreset == preset;
              return FilterChip(
                label: Text(
                  preset,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white : Colors.grey.shade800,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedColor: primaryGreen,
                backgroundColor: Colors.grey.shade100,
                side: BorderSide(
                  color: isSelected ? primaryGreen : Colors.grey.shade300,
                  width: 1,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                onSelected: (selected) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (selected) {
                      _selectedPreset = preset;
                      _notesController.text = preset;
                    } else {
                      _selectedPreset = null;
                      _notesController.clear();
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            maxLines: 2,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Add custom delivery instruction for the farmer...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: primaryGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ORDER SUMMARY CARD
  // ==========================================================

  Widget _buildOrderSummaryCard() {
    final subtotal = _cart?.total ?? 0;
    final deliveryFee = (_cart?.deliveryFee != null && _cart!.deliveryFee > 0)
        ? _cart!.deliveryFee
        : (subtotal > 0 ? 2.00 : 0.0);
    final estimatedTax = _cart?.tax ?? (subtotal * 0.03);
    final total = subtotal + deliveryFee + estimatedTax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          _buildSummaryRow('Subtotal', _formatPrice(subtotal)),
          const SizedBox(height: 8),
          _buildSummaryRow('Estimated Delivery', _formatPrice(deliveryFee)),
          const SizedBox(height: 8),
          _buildSummaryRow('Estimated Tax (3%)', _formatPrice(estimatedTax)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimated Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Text(
                  _formatPrice(total),
                  key: ValueKey<String>(_formatPrice(total)),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (_cart == null || _cart!.items.isEmpty || _isSyncingBeforeCheckout)
                  ? null
                  : _proceedToCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonOrange,
                disabledBackgroundColor: Colors.grey.shade300,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSyncingBeforeCheckout
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Proceed to Checkout (${_cart?.itemCount ?? 0})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyCart() {
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
                color: primaryGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add fresh vegetables, fruits, and seafood\ndirectly from verified local farmers.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.go(AppRoutes.restaurantHome);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.storefront_outlined, size: 18),
              label: const Text(
                'Explore Fresh Produce',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ERROR STATE
  // ==========================================================

  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 54, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Unable to load your cart',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _loadCart();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}