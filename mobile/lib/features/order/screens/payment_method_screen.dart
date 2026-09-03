import 'package:flutter/material.dart';
import 'package:mobile/features/cart/models/cart_model.dart';
import 'package:mobile/features/cart/services/cart_service.dart';
import 'package:mobile/features/order/screens/order_success_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final Cart cart;
  final String deliveryNotes;

  const PaymentMethodScreen({
    super.key,
    required this.cart,
    this.deliveryNotes = '',
  });

  @override
  State<PaymentMethodScreen> createState() =>
      _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  // ==========================================================
  // COLORS
  // ==========================================================

  static const Color primaryGreen = Color(0xFF135A27);
  static const Color defaultBadgeBg = Color(0xFFC3EBCB);
  static const Color defaultBadgeText = Color(0xFF0F5222);
  static const Color pageBgColor = Color(0xFFF7F9F8);
  static const Color buttonOrange = Color(0xFFFF8C00);

  // ==========================================================
  // PAYMENT METHODS
  // ==========================================================

  // 0 = Visa
  // 1 = KHQR
  int _selectedPaymentMethod = 0;

  // ==========================================================
  // SERVICES
  // ==========================================================

  final CartService _cartService = CartService();

  // ==========================================================
  // STATE
  // ==========================================================

  bool _isProcessing = false;

  // ==========================================================
  // PRICE CALCULATIONS
  // ==========================================================

  double get _subtotal => widget.cart.total;

  /// Tax is 3% of subtotal
  double get _tax => _subtotal * 0.03;

  /// Currently free.
  /// You can replace this later with backend delivery fee.
  double get _deliveryFee => 0.0;

  double get _orderTotal =>
      _subtotal + _tax + _deliveryFee;
      
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

      appBar: AppBar(
        backgroundColor: pageBgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: primaryGreen,
          ),
          onPressed: _isProcessing
              ? null
              : () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Payment Method',
          style: TextStyle(
            color: primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),

      // ======================================================
      // BODY
      // ======================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ORDER TOTAL
            _buildOrderTotalHeader(),

            const SizedBox(height: 20),

            // VISA
            _buildVisaTile(),

            const SizedBox(height: 12),

            // KHQR
            _buildKhqrTile(),

            const SizedBox(height: 12),

            // ADD CARD
            _buildAddNewCardTile(),

            const SizedBox(height: 20),

            // SECURITY
            _buildSecurityBadge(),

            const SizedBox(height: 16),

            // PROMO
            _buildPromoBanner(),

            const SizedBox(height: 24),
          ],
        ),
      ),

      // ======================================================
      // BOTTOM ACTION
      // ======================================================

      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  // ==========================================================
  // ORDER TOTAL HEADER
  // ==========================================================

  Widget _buildOrderTotalHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ORDER TOTAL',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          '\$${_orderTotal.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: primaryGreen,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          'Payment due today',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 12),

        // PRICE BREAKDOWN
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildPriceRow(
                'Subtotal',
                _subtotal,
              ),

              const SizedBox(height: 8),

              _buildPriceRow(
                'Tax (3%)',
                _tax,
              ),

              const SizedBox(height: 8),

              _buildPriceRow(
                'Delivery Fee',
                _deliveryFee,
                zeroText: 'Free',
              ),

              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: Divider(height: 1),
              ),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                  Text(
                    '\$${_orderTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // PRICE ROW
  // ==========================================================

  Widget _buildPriceRow(
    String title,
    double amount, {
    String? zeroText,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          amount == 0 && zeroText != null
              ? zeroText
              : '\$${amount.toStringAsFixed(2)}',
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
  // VISA TILE
  // ==========================================================

  Widget _buildVisaTile() {
    final bool isSelected =
        _selectedPaymentMethod == 0;

    return GestureDetector(
      onTap: _isProcessing
          ? null
          : () {
              setState(() {
                _selectedPaymentMethod = 0;
              });
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? primaryGreen
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.02,
              ),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // CARD ICON
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.credit_card,
                color: primaryGreen,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            // CARD DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Visa **** 4242',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 15,
                          color:
                              Colors.black87,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              defaultBadgeBg,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            6,
                          ),
                        ),
                        child: const Text(
                          'DEFAULT',
                          style: TextStyle(
                            color:
                                defaultBadgeText,
                            fontSize: 9,
                            fontWeight:
                                FontWeight.bold,
                            letterSpacing:
                                0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Expires 12/26',
                    style: TextStyle(
                      color:
                          Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // RADIO
            _buildRadio(isSelected),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // KHQR TILE
  // ==========================================================

  Widget _buildKhqrTile() {
    final bool isSelected =
        _selectedPaymentMethod == 1;

    return GestureDetector(
      onTap: _isProcessing
          ? null
          : () {
              setState(() {
                _selectedPaymentMethod = 1;
              });
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? primaryGreen
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.02,
              ),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // KHQR LOGO
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFD30000),
                borderRadius:
                    BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Text(
                'KHQR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            const SizedBox(width: 14),

            // TEXT
            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'KHQR',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 15,
                      color:
                          Colors.black87,
                    ),
                  ),

                  SizedBox(height: 2),

                  Text(
                    'Scan to pay with any banking app',
                    style: TextStyle(
                      color: primaryGreen,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // RADIO
            _buildRadio(isSelected),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // RADIO
  // ==========================================================

  Widget _buildRadio(bool isSelected) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? primaryGreen
            : Colors.transparent,
        border: Border.all(
          color: isSelected
              ? primaryGreen
              : Colors.grey.shade400,
          width: isSelected ? 0 : 2,
        ),
      ),
      child: isSelected
          ? const Center(
              child: CircleAvatar(
                radius: 3.5,
                backgroundColor:
                    Colors.white,
              ),
            )
          : null,
    );
  }

  // ==========================================================
  // ADD NEW CARD
  // ==========================================================

  Widget _buildAddNewCardTile() {
    return GestureDetector(
      onTap: _isProcessing
          ? null
          : () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    'Add new card will be available soon.',
                  ),
                ),
              );
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F3),
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade400,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.grey,
                size: 20,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Card',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 14,
                      color:
                          Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    'Securely save for future orders',
                    style: TextStyle(
                      color:
                          Colors.grey.shade600,
                      fontSize: 12,
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

  // ==========================================================
  // SECURITY
  // ==========================================================

  Widget _buildSecurityBadge() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 16,
          color: Colors.grey.shade600,
        ),

        const SizedBox(width: 6),

        Text(
          'Secure 256-bit SSL Encrypted Payment',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // PROMO BANNER
  // ==========================================================

  Widget _buildPromoBanner() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=800&q=80',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(
                    alpha: 0.65,
                  ),
                  Colors.black.withValues(
                    alpha: 0.2,
                  ),
                ],
                begin:
                    Alignment.centerLeft,
                end:
                    Alignment.centerRight,
              ),
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  'AGRIFINANCE B2B',
                  style: TextStyle(
                    color:
                        Colors.white.withValues(
                      alpha: 0.8,
                    ),
                    fontSize: 10,
                    fontWeight:
                        FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Flexible credit for\ngrowing kitchens.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BOTTOM ACTION BAR
  // ==========================================================

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
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
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : _confirmPayment,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      buttonOrange,
                  disabledBackgroundColor:
                      Colors.grey.shade400,
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          Text(
                            'Confirm Payment Method',
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 16,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward,
                            color:
                                Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 12),

            RichText(
              textAlign:
                  TextAlign.center,
              text: TextSpan(
                text:
                    'By clicking confirm, you agree to Verdant\'s ',
                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                  fontSize: 11,
                ),
                children: const [
                  TextSpan(
                    text:
                        'Terms of Service.',
                    style: TextStyle(
                      color:
                          Colors.black87,
                      fontWeight:
                          FontWeight.w600,
                      decoration:
                          TextDecoration
                              .underline,
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

  // ==========================================================
  // CONFIRM PAYMENT
  // ==========================================================

  Future<void> _confirmPayment() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // ======================================================
      // IMPORTANT
      //
      // Create the order BEFORE clearing the cart.
      //
      // Replace this section with your actual OrderService.
      // ======================================================

      /*
      final orders = await _orderService.createOrder(
        cartId: widget.cart.id,
        paymentMethod: _paymentMethod,
        deliveryNotes: widget.deliveryNotes,
      );
      */

      // ------------------------------------------------------
      // TEMPORARY DEMO
      //
      // Remove this when your OrderService is connected.
      // ------------------------------------------------------

      await Future.delayed(
        const Duration(seconds: 1),
      );

      // ======================================================
      // CLEAR CART
      //
      // This MUST happen only after the order is successfully
      // created/confirmed.
      // ======================================================

      await _cartService.clearCart();

      if (!mounted) return;

      // ======================================================
      // ORDER SUCCESS
      // ======================================================

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const OrderSuccessScreen(
            orders: [],
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint(
        'Confirm payment error: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to place order: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });
    }
  }
}