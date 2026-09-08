import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/features/cart/models/cart_model.dart';
import 'package:mobile/features/cart/services/cart_service.dart';
import 'package:mobile/features/order/models/order_model.dart';
import 'package:mobile/features/order/screens/khqr_payment_modal.dart';
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
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // ==========================================================
  // COLORS
  // ==========================================================

  static const Color pageBgColor = Color(0xFFF7F9F8);
  static const Color primaryGreen = Color(0xFF135A27);
  static const Color buttonOrange = Color(0xFFFF8C00);

  // ==========================================================
  // SERVICES
  // ==========================================================

  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();

  // ==========================================================
  // STATE
  // ==========================================================

  bool _isCheckingOut = false;
  String _paymentMethod = 'KHQR'; // 'KHQR' or 'CASH'
  String _deliveryMethod = 'delivery'; // 'delivery' or 'pickup'
  late String _deliveryAddress;
  String _contactPhone = '+855 12 345 678';
  late String _deliveryNotes;

  @override
  void initState() {
    super.initState();
    _deliveryAddress = widget.deliveryAddress.trim().isEmpty ||
            widget.deliveryAddress == '<ADDRESS>'
        ? 'Building 42, St 271, Boeng Tumpun, Phnom Penh'
        : widget.deliveryAddress;
    _deliveryNotes = widget.deliveryNotes;
  }

  // ==========================================================
  // CALCULATIONS
  // ==========================================================

  double get subtotal => widget.cart.total;

  double get deliveryFee => _deliveryMethod == 'pickup' ? 0.0 : 2.00;

  double get tax => subtotal * 0.03;

  double get total => subtotal + deliveryFee + tax;

  String _formatPrice(double value) => '\$${value.toStringAsFixed(2)}';

  String _formatQuantity(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  // ==========================================================
  // EDIT ADDRESS MODAL
  // ==========================================================

  void _showEditAddressModal() {
    final addressCtrl = TextEditingController(text: _deliveryAddress);
    final phoneCtrl = TextEditingController(text: _contactPhone);

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
                      fontSize: 18,
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
              const SizedBox(height: 14),
              const Text(
                'Street Address / Kitchen Location',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: addressCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. #42, Street 271, Phnom Penh',
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: primaryGreen),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Contact Phone Number',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'e.g. +855 12 345 678',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: primaryGreen),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final newAddr = addressCtrl.text.trim();
                    final newPhone = phoneCtrl.text.trim();
                    if (newAddr.isNotEmpty) {
                      setState(() {
                        _deliveryAddress = newAddr;
                        if (newPhone.isNotEmpty) _contactPhone = newPhone;
                      });
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _isCheckingOut ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(),
            const SizedBox(height: 14),
            _buildDeliveryMethodSelector(),
            const SizedBox(height: 14),
            _buildAddressCard(),
            const SizedBox(height: 14),
            _buildProductsCard(),
            const SizedBox(height: 14),
            _buildPaymentCard(),
            const SizedBox(height: 14),
            _buildOrderSummary(),
            const SizedBox(height: 20),
            _buildPlaceOrderButton(),
            const SizedBox(height: 24),
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
        gradient: const LinearGradient(
          colors: [primaryGreen, Color(0xFF1B7A38)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_basket_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Review Your Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${widget.cart.itemCount} items • Fresh harvest direct from growers',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
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
  // DELIVERY METHOD SELECTOR
  // ==========================================================

  Widget _buildDeliveryMethodSelector() {
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
            'Fulfillment Option',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFulfillmentTile(
                  title: 'Kitchen Delivery',
                  subtitle: 'Direct dispatch (\$2.00)',
                  icon: Icons.local_shipping_outlined,
                  isSelected: _deliveryMethod == 'delivery',
                  onTap: () {
                    setState(() => _deliveryMethod = 'delivery');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildFulfillmentTile(
                  title: 'Farm Pickup',
                  subtitle: 'Pick up free (\$0.00)',
                  icon: Icons.storefront_outlined,
                  isSelected: _deliveryMethod == 'pickup',
                  onTap: () {
                    setState(() => _deliveryMethod = 'pickup');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFulfillmentTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryGreen.withValues(alpha: 0.06)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryGreen : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? primaryGreen : Colors.grey.shade600,
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(Icons.check_circle, size: 16, color: primaryGreen),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? primaryGreen : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.5,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ADDRESS CARD
  // ==========================================================

  Widget _buildAddressCard() {
    return Container(
      width: double.infinity,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _deliveryMethod == 'pickup'
                        ? Icons.storefront_outlined
                        : Icons.location_on_outlined,
                    color: primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _deliveryMethod == 'pickup'
                        ? 'Pickup Location'
                        : 'Delivery Address',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              if (_deliveryMethod == 'delivery')
                TextButton(
                  onPressed: _showEditAddressModal,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: primaryGreen,
                  ),
                  child: const Text(
                    'Change',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _deliveryMethod == 'pickup'
                ? 'Grower Hub - Farmer Direct Pickup point\nReady for collection tomorrow after 7:00 AM'
                : _deliveryAddress,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.35,
            ),
          ),
          if (_deliveryMethod == 'delivery') ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  _contactPhone,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
          if (_deliveryNotes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.note_alt_outlined, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Note: $_deliveryNotes',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================
  // PRODUCTS CARD
  // ==========================================================

  Widget _buildProductsCard() {
    return Container(
      width: double.infinity,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Items Summary',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${widget.cart.items.length} products',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.cart.items.map((item) => _buildProductItem(item)),
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl.isEmpty
                ? Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.eco, color: primaryGreen),
                  )
                : Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_formatQuantity(item.quantity)} kg × ${_formatPrice(item.unitPrice)}/kg',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
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
  // PAYMENT CARD
  // ==========================================================

  Widget _buildPaymentCard() {
    return Container(
      width: double.infinity,
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
            'Payment Method',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            value: 'KHQR',
            title: 'Bakong / KHQR',
            subtitle: 'Scan and pay instantly with any mobile banking app',
            icon: Icons.qr_code_2,
            badge: 'RECOMMENDED',
          ),
          const SizedBox(height: 10),
          _buildPaymentOption(
            value: 'CASH',
            title: 'Cash on Delivery',
            subtitle: 'Pay in cash upon arrival & inspection',
            icon: Icons.payments_outlined,
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
    String? badge,
  }) {
    final selected = _paymentMethod == value;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() => _paymentMethod = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? primaryGreen.withValues(alpha: 0.05)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? primaryGreen : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected
                    ? primaryGreen.withValues(alpha: 0.12)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: selected ? primaryGreen : Colors.grey.shade700,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: selected ? primaryGreen : Colors.black87,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primaryGreen,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _paymentMethod,
              activeColor: primaryGreen,
              onChanged: (val) {
                if (val != null) setState(() => _paymentMethod = val);
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
          _buildSummaryRow(
            'Delivery Fee',
            deliveryFee == 0 ? 'Free' : _formatPrice(deliveryFee),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow('Estimated Tax (3%)', _formatPrice(tax)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Due',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              Text(
                _formatPrice(total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ],
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
  // PLACE ORDER BUTTON
  // ==========================================================

  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isCheckingOut ? null : _placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonOrange,
          disabledBackgroundColor: Colors.grey.shade400,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isCheckingOut
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, color: Colors.white, size: 19),
                  const SizedBox(width: 8),
                  Text(
                    _paymentMethod == 'KHQR'
                        ? 'Pay with KHQR • ${_formatPrice(total)}'
                        : 'Place Order • ${_formatPrice(total)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ==========================================================
  // PLACE ORDER LOGIC
  // ==========================================================

  Future<void> _placeOrder() async {
    if (_isCheckingOut) return;

    if (_deliveryMethod == 'delivery' && _deliveryAddress.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a valid delivery address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCheckingOut = true;
    });

    try {
      final List<OrderModel> orders = await _orderService.checkout(
        deliveryAddress: _deliveryMethod == 'pickup'
            ? 'Farm Direct Pickup'
            : _deliveryAddress.trim(),
        deliveryMethod: _deliveryMethod,
        paymentMethod: _paymentMethod,
      );

      if (orders.isEmpty) {
        throw Exception('No orders were created');
      }

      // Clear cart locally
      await _cartService.clearCart();

      if (!mounted) return;

      if (_paymentMethod == 'KHQR') {
        // Show KHQR modal with real created orders
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) => KhqrPaymentModal(
            orders: orders,
            totalAmount: total,
          ),
        );
      } else {
        // Cash on delivery: Go straight to success screen
        context.go(
          AppRoutes.restaurantOrderSuccess,
          extra: orders,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingOut = false;
        });
      }
    }
  }
}