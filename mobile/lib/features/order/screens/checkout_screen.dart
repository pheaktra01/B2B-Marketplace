import 'package:flutter/material.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/cart/models/cart_model.dart';
import 'package:mobile/features/cart/services/cart_service.dart';
import 'package:mobile/features/order/models/order_model.dart';
import 'package:mobile/features/order/screens/order_success_screen.dart';
import 'package:mobile/features/order/services/order_service.dart';

class CheckoutScreen extends StatefulWidget {
  final Cart cart;
  final String deliveryAddress;
  final String deliveryNotes;

  const CheckoutScreen({
    super.key,
    required this.cart,
    required this.deliveryAddress,
    this.deliveryNotes = '',
  });

  @override
  State<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // ==========================================================
  // COLORS
  // ==========================================================

  static const Color pageBgColor = Color(0xFFF5F7E8);
  static const Color primaryGreen = Color(0xFF135A27);
  static const Color buttonOrange = Color(0xFFFF8C00);

  // ==========================================================
  // SERVICES
  // ==========================================================

  final CartService _cartService = CartService();

  final OrderService _orderService =
      OrderService();

  // ==========================================================
  // STATE
  // ==========================================================

  bool _isCheckingOut = false;

  String _paymentMethod = 'KHQR';

  // ==========================================================
  // FORMAT PRICE
  // ==========================================================

  String _formatPrice(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  String _formatQuantity(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  // ==========================================================
  // TOTALS
  // ==========================================================

  double get subtotal {
    return widget.cart.total;
  }

  double get deliveryFee {
    return 2.00;
  }

  double get tax {
    return subtotal * 0.03;
  }

  double get total {
    return subtotal + deliveryFee + tax;
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBgColor,

      appBar: AppBar(
        backgroundColor: pageBgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black87,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(),

            const SizedBox(height: 16),

            _buildProductsCard(),

            const SizedBox(height: 16),

            _buildDeliveryCard(),

            const SizedBox(height: 16),

            _buildPaymentCard(),

            const SizedBox(height: 16),

            _buildOrderSummary(),

            const SizedBox(height: 24),

            _buildPlaceOrderButton(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ORDER HEADER
  // ==========================================================

  Widget _buildOrderHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 25,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Review Your Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${widget.cart.itemCount} items in your order',
                  style: TextStyle(
                    color:
                        Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
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
  // PRODUCTS
  // ==========================================================

  Widget _buildProductsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Items',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 14),

          ...widget.cart.items.map(
            (item) => _buildProductItem(item),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(CartItem item) {
    final image = item.imageUrl.trim();

    String imageUrl = '';

    if (image.isNotEmpty) {
      imageUrl = ApiConstants.imageUrl(image);
    }

    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(10),
            child: imageUrl.isEmpty
                ? Container(
                    width: 65,
                    height: 65,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_outlined,
                      color: Colors.grey,
                    ),
                  )
                : Image.network(
                    imageUrl,
                    width: 65,
                    height: 65,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) {
                      return Container(
                        width: 65,
                        height: 65,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons
                              .image_not_supported_outlined,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${_formatQuantity(item.quantity)} kg × '
                  '${_formatPrice(item.unitPrice)}',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Delivery: ${_formatPrice(item.deliveryFee)}',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            _formatPrice(item.subtotal),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DELIVERY
  // ==========================================================

  Widget _buildDeliveryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 14),

          _buildInfoRow(
            Icons.local_shipping_outlined,
            'Delivery Method',
            'Farmer / Local Delivery',
          ),

          const SizedBox(height: 12),

          _buildInfoRow(
            Icons.payments_outlined,
            'Delivery Fee',
            _formatPrice(deliveryFee),
          ),

          const SizedBox(height: 12),

          _buildInfoRow(
            Icons.access_time_outlined,
            'Expected Delivery',
            'Tomorrow, 6:00 AM - 8:00 AM',
          ),

          if (widget.deliveryNotes.isNotEmpty) ...[
            const SizedBox(height: 12),

            _buildInfoRow(
              Icons.note_alt_outlined,
              'Delivery Notes',
              widget.deliveryNotes,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          padding:
              const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryGreen.withValues(
              alpha: 0.08,
            ),
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: primaryGreen,
            size: 20,
          ),
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
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // PAYMENT
  // ==========================================================

  Widget _buildPaymentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          _buildPaymentOption(
            value: 'KHQR',
            title: 'Bakong / KHQR',
            subtitle:
                'Pay securely with KHQR',
            icon: Icons.qr_code_2,
          ),

          const SizedBox(height: 8),

          _buildPaymentOption(
            value: 'CASH',
            title: 'Cash on Delivery',
            subtitle:
                'Pay when your order arrives',
            icon:
                Icons.payments_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected =
        _paymentMethod == value;

    return InkWell(
      borderRadius:
          BorderRadius.circular(12),
      onTap: () {
        setState(() {
          _paymentMethod = value;
        });
      },
      child: Container(
        padding:
            const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? primaryGreen.withValues(
                  alpha: 0.06,
                )
              : Colors.grey.shade50,
          borderRadius:
              BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? primaryGreen
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: primaryGreen,
              size: 25,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            Radio<String>(
              value: value,
              groupValue:
                  _paymentMethod,
              activeColor:
                  primaryGreen,
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _paymentMethod = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ORDER SUMMARY
  // ==========================================================

  Widget _buildOrderSummary() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
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
                ? 'Free'
                : _formatPrice(deliveryFee),
          ),

          const SizedBox(height: 10),

          _buildSummaryRow(
            'Tax (3%)',
            _formatPrice(tax),
          ),

          const Padding(
            padding:
                EdgeInsets.symmetric(
              vertical: 14,
            ),
            child: Divider(),
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
                  color: primaryGreen,
                ),
              ),

              Text(
                _formatPrice(total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Align(
            alignment:
                Alignment.centerRight,
            child: Text(
              'Subtotal + Delivery + 3% Tax',
              style: TextStyle(
                fontSize: 11,
                color:
                    Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

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

        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // PLACE ORDER BUTTON
  // ==========================================================

  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isCheckingOut
            ? null
            : _placeOrder,
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              buttonOrange,
          disabledBackgroundColor:
              Colors.grey.shade300,
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
        ),
        child: _isCheckingOut
            ? const SizedBox(
                width: 22,
                height: 22,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                    size: 19,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    'Place Order • '
                    '${_formatPrice(total)}',
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ==========================================================
  // PLACE ORDER
  // ==========================================================

  Future<void> _placeOrder() async {
    if (_isCheckingOut) return;

    setState(() {
      _isCheckingOut = true;
    });

    try {
      // ======================================================
      // DEBUG
      // ======================================================

      debugPrint(
        '========== PLACE ORDER ==========',
      );

      debugPrint(
        'Cart ID: ${widget.cart.id}',
      );

      debugPrint(
        'Delivery Address: ${widget.deliveryAddress}',
      );

      debugPrint(
        'Delivery Method: delivery',
      );

      debugPrint(
        'Payment Method: khqr',
      );

      debugPrint(
        '=================================',
      );

      // ======================================================
      // CALL BACKEND
      // ======================================================

      final List<OrderModel> orders =
          await _orderService.checkout(
        deliveryAddress:
            widget.deliveryAddress.trim(),
        deliveryMethod: 'delivery',
        paymentMethod: _paymentMethod,
      );

      // ======================================================
      // CHECK RESPONSE
      // ======================================================

      if (orders.isEmpty) {
        throw Exception(
          'No orders were created',
        );
      }

      debugPrint(
        '========== ORDERS CREATED =========',
      );

      debugPrint(
        'Number of orders: ${orders.length}',
      );

      for (final order in orders) {
        debugPrint(
          'Order ID: ${order.id}',
        );

        debugPrint(
          'Subtotal: ${order.subtotal}',
        );

        debugPrint(
          'Transaction Fee: ${order.transactionFee}',
        );

        debugPrint(
          'Delivery Fee: ${order.deliveryFee}',
        );

        debugPrint(
          'Total: ${order.total}',
        );
      }

      debugPrint(
        '===================================',
      );

      // ======================================================
      // CLEAR CART
      //
      // IMPORTANT:
      // Only clear after backend successfully created
      // the order.
      // ======================================================

      await _cartService.clearCart();

      if (!mounted) return;

      // ======================================================
      // GO TO SUCCESS SCREEN
      //
      // Pass the REAL backend orders.
      // ======================================================

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(
            orders: orders,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      debugPrint(
        'Checkout error: $e',
      );

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
        _isCheckingOut = false;
      });
    }
  }
}