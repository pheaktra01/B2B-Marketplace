import 'package:flutter/material.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/cart/models/cart_model.dart';
import 'package:mobile/features/cart/services/cart_service.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
import 'package:mobile/features/order/screens/checkout_screen.dart';
import 'package:mobile/features/restaurant/widgets/restaurant_bottom_nav_bar.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // ==========================================================
  // COLORS
  // ==========================================================

  static const Color pageBgColor = Color(0xFFF5F7E8);
  static const Color primaryGreen = Color(0xFF135A27);
  static const Color darkGreenBadge = Color(0xFF1F5E2B);
  static const Color buttonOrange = Color(0xFFFF8C00);

  // ==========================================================
  // SERVICES
  // ==========================================================

  final CartService _cartService = CartService();

  // ==========================================================
  // STATE
  // ==========================================================

  Cart? _cart;

  bool _isLoading = true;
  String? _errorMessage;

  // Track which item is currently being updated
  String? _updatingItemId;

  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final TextEditingController _notesController =
      TextEditingController();

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
        _isLoading = false;
      });

      debugPrint('========== CART ==========');
      debugPrint('Cart ID: ${cart.id}');
      debugPrint('Restaurant ID: ${cart.restaurantId}');
      debugPrint('Items: ${cart.items.length}');
      debugPrint('Item count: ${cart.itemCount}');
      debugPrint('Total: ${cart.total}');

      for (final item in cart.items) {
        debugPrint(
          '${item.productName} - '
          '${item.quantity} x ${item.unitPrice} = ${item.subtotal}',
        );
      }

      debugPrint('==========================');
    } catch (e) {
      debugPrint('Load cart error: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ==========================================================
  // UPDATE QUANTITY
  // ==========================================================

  Future<void> _updateQuantity(
    CartItem item,
    double newQuantity,
  ) async {
    if (newQuantity <= 0) {
      await _removeItem(item);
      return;
    }

    if (_updatingItemId != null) {
      return;
    }

    setState(() {
      _updatingItemId = item.id;
    });

    try {
      final updatedCart = await _cartService.updateCartItem(
        productId: item.productId,
        quantity: newQuantity,
      );

      if (!mounted) return;

      setState(() {
        _cart = updatedCart;
      });
    } catch (e) {
      debugPrint('Update cart item error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update ${item.productName}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _updatingItemId = null;
      });
    }
  }

  // ==========================================================
  // REMOVE ITEM
  // ==========================================================

  Future<void> _removeItem(CartItem item) async {
    if (_updatingItemId != null) {
      return;
    }

    setState(() {
      _updatingItemId = item.id;
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
          content: Text(
            '${item.productName} removed from cart',
          ),
          backgroundColor: primaryGreen,
        ),
      );
    } catch (e) {
      debugPrint('Remove cart item error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to remove ${item.productName}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _updatingItemId = null;
      });
    }
  }

  // ==========================================================
  // IMAGE
  // ==========================================================

  String _getImageUrl(CartItem item) {
    final image = item.imageUrl.trim();

    if (image.isEmpty) {
      return '';
    }

    return ApiConstants.imageUrl(image);
  }

  // ==========================================================
  // FORMAT PRICE
  // ==========================================================

  String _formatPrice(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  // ==========================================================
  // FORMAT QUANTITY
  // ==========================================================

  String _formatQuantity(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBgColor,

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: FarmerAppBar(
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
            ),
            onPressed: () {},
          ),

          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage:
                  AssetImage('assets/profile.png'),
            ),
          ),
        ],
      ),

      // ======================================================
      // BODY
      // ======================================================

      body: RefreshIndicator(
        onRefresh: _loadCart,
        child: _buildBody(),
      ),

      // ======================================================
      // BOTTOM NAV
      // ======================================================

      bottomNavigationBar:
          const RestaurantBottomNavBar(
        currentIndex: 2,
      ),
    );
  }

  // ==========================================================
  // BODY
  // ==========================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryGreen,
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_cart == null || _cart!.items.isEmpty) {
      return _buildEmptyCart();
    }

    return SingleChildScrollView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // HEADER
          _buildHeader(),

          const SizedBox(height: 16),

          // ITEMS
          _buildCartItemList(),

          const SizedBox(height: 16),

          // DELIVERY NOTES
          _buildDeliveryNotes(),

          const SizedBox(height: 20),

          // SUMMARY
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
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Your Cart',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: darkGreenBadge,
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Text(
            '$itemCount Items',
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
  // CART ITEMS
  // ==========================================================

  Widget _buildCartItemList() {
    final items = _cart?.items ?? [];

    return ListView.separated(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];

        final isUpdating =
            _updatingItemId == item.id;

        return Container(
          padding:
              const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==============================================
              // IMAGE
              // ==============================================

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(12),
                child: _buildProductImage(item),
              ),

              const SizedBox(width: 12),

              // ==============================================
              // PRODUCT INFO
              // ==============================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // NAME + REMOVE
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.productName,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 15,
                              color:
                                  Colors.black87,
                            ),
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                          ),
                        ),

                        GestureDetector(
                          onTap: isUpdating
                              ? null
                              : () =>
                                  _removeItem(
                                    item,
                                  ),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: isUpdating
                                ? Colors.grey
                                : Colors
                                    .grey
                                    .shade600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // PRICE
                    RichText(
                      text: TextSpan(
                        text:
                            _formatPrice(
                          item.unitPrice,
                        ),
                        style:
                            const TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              primaryGreen,
                        ),
                        children: const [
                          TextSpan(
                            text: ' / kg',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight
                                      .normal,
                              color:
                                  Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // SUBTOTAL + STEPPER
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Text(
                          'Subtotal: ${_formatPrice(item.subtotal)}',
                          style:
                              TextStyle(
                            fontSize: 12,
                            color: Colors
                                .grey
                                .shade600,
                          ),
                        ),

                        _buildQuantityStepper(
                          item,
                          isUpdating,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // PRODUCT IMAGE
  // ==========================================================

  Widget _buildProductImage(
    CartItem item,
  ) {
    final imageUrl = _getImageUrl(item);

    if (imageUrl.isEmpty) {
      return Container(
        width: 75,
        height: 75,
        color: Colors.grey.shade200,
        child: const Icon(
          Icons.image_outlined,
          color: Colors.grey,
          size: 30,
        ),
      );
    }

    return Image.network(
      imageUrl,
      width: 75,
      height: 75,
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) {
        return Container(
          width: 75,
          height: 75,
          color: Colors.grey.shade200,
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey,
          ),
        );
      },
      loadingBuilder:
          (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          width: 75,
          height: 75,
          color: Colors.grey.shade100,
          child: const Center(
            child:
                CircularProgressIndicator(
              strokeWidth: 2,
              color: primaryGreen,
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // QUANTITY STEPPER
  // ==========================================================

  Widget _buildQuantityStepper(
    CartItem item,
    bool isUpdating,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // MINUS
          GestureDetector(
            onTap: isUpdating
                ? null
                : () {
                    final newQuantity =
                        item.quantity - 1;

                    _updateQuantity(
                      item,
                      newQuantity,
                    );
                  },
            child: Container(
              padding:
                  const EdgeInsets.all(4),
              decoration:
                  const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.remove,
                size: 14,
                color: isUpdating
                    ? Colors.grey
                    : Colors.black87,
              ),
            ),
          ),

          // QUANTITY
          SizedBox(
            width: 38,
            child: Center(
              child: isUpdating
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                            primaryGreen,
                      ),
                    )
                  : Text(
                      _formatQuantity(
                        item.quantity,
                      ),
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
            ),
          ),

          // PLUS
          GestureDetector(
            onTap: isUpdating
                ? null
                : () {
                    final newQuantity =
                        item.quantity + 1;

                    _updateQuantity(
                      item,
                      newQuantity,
                    );
                  },
            child: Container(
              padding:
                  const EdgeInsets.all(4),
              decoration:
                  const BoxDecoration(
                color: darkGreenBadge,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DELIVERY NOTES
  // ==========================================================

  Widget _buildDeliveryNotes() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Notes',
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 6),

        TextField(
          controller:
              _notesController,
          maxLines: 2,
          decoration:
              InputDecoration(
            hintText:
                'e.g. Leave by the kitchen entrance after 6 AM...',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
            ),
            fillColor: Colors.white,
            filled: true,
            contentPadding:
                const EdgeInsets.all(12),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide:
                  BorderSide(
                color:
                    Colors.grey.shade300,
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide:
                  const BorderSide(
                color: primaryGreen,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // ORDER SUMMARY
  // ==========================================================

  Widget _buildOrderSummaryCard() {
    final subtotal = _cart?.total ?? 0;

    // These will be calculated by checkout/backend later.
    const deliveryFee = 0.0;
    const estimatedTax = 0.0;

    final total = subtotal + deliveryFee + estimatedTax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          _buildSummaryRow(
            'Subtotal',
            _formatPrice(subtotal),
          ),

          const SizedBox(height: 10),

          _buildSummaryRow(
            'Delivery Fee',
            deliveryFee == 0
                ? 'Calculated at checkout'
                : _formatPrice(deliveryFee),
          ),

          const SizedBox(height: 10),

          _buildSummaryRow(
            'Tax',
            estimatedTax == 0
                ? 'Calculated at checkout'
                : _formatPrice(estimatedTax),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              Text(
                _formatPrice(total),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed:
                  _cart == null || _cart!.items.isEmpty
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckoutScreen(
                                cart: _cart!,
                                deliveryNotes:
                                    _notesController.text.trim(), deliveryAddress: '<ADDRESS>',
                              ),
                            ),
                          );
                        },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonOrange,
                disabledBackgroundColor: Colors.grey.shade300,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Proceed to Checkout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SUMMARY ROW
  // ==========================================================

  Widget _buildSummaryRow(
    String title,
    String value,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color:
                Colors.grey.shade700,
          ),
        ),

        Flexible(
          child: Text(
            value,
            textAlign:
                TextAlign.right,
            style:
                const TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w600,
              color:
                  Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // EMPTY CART
  // ==========================================================

  Widget _buildEmptyCart() {
    return Center(
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              padding:
                  const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryGreen
                    .withValues(
                  alpha: 0.08,
                ),
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
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Add fresh products from farmers\nto your cart.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color:
                    Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryGreen,
                foregroundColor:
                    Colors.white,
              ),
              child: const Text(
                'Continue Shopping',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 60,
              color:
                  Colors.grey.shade400,
            ),

            const SizedBox(height: 16),

            const Text(
              'Unable to load your cart',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _errorMessage ?? '',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color:
                    Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _loadCart,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryGreen,
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}