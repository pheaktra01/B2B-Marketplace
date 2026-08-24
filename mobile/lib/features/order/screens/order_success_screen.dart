import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile/features/order/models/order_model.dart';
import 'package:mobile/features/restaurant/screens/home_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final List<OrderModel> orders;

  const OrderSuccessScreen({
    super.key,
    required this.orders,
  });

  // =========================================================
  // COLORS
  // =========================================================

  static const Color primaryGreen =
      Color(0xFF135A27);

  static const Color pageBgColor =
      Color(0xFFF7F9F8);

  static const Color buttonOrange =
      Color(0xFFFF8C00);

  static const Color chipBgColor =
      Color(0xFFF2F5F4);

  static const Color iconBadgeBg =
      Color(0xFFE5EDE7);

  // =========================================================
  // CALCULATED VALUES
  // =========================================================

  double get totalAmount {
    return orders.fold<double>(
      0,
      (sum, order) => sum + order.total,
    );
  }

  double get subtotal {
    return orders.fold<double>(
      0,
      (sum, order) => sum + order.subtotal,
    );
  }

  double get transactionFee {
    return orders.fold<double>(
      0,
      (sum, order) => sum + order.transactionFee,
    );
  }

  double get deliveryFee {
    return orders.fold<double>(
      0,
      (sum, order) => sum + order.deliveryFee,
    );
  }

  String get orderNumbers {
    if (orders.isEmpty) {
      return '#N/A';
    }

    if (orders.length == 1) {
      return '#${orders.first.id.substring(0, 8)}';
    }

    return '${orders.length} orders';
  }

  String get deliveryMethod {
    if (orders.isEmpty) {
      return 'Delivery';
    }

    return orders.first.deliveryMethod;
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBgColor,

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),

          child: Column(
            children: [
              const SizedBox(height: 10),

              // =====================================================
              // 1. CELEBRATION
              // =====================================================

              _buildCelebrationHeader(),

              const SizedBox(height: 24),

              // =====================================================
              // 2. SUCCESS TITLE
              // =====================================================

              const Text(
                'Order Placed\nSuccessfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.bold,
                  color: primaryGreen,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              _buildOrderMessage(),

              const SizedBox(height: 28),

              // =====================================================
              // 3. DELIVERY SCHEDULE
              // =====================================================

              _buildDeliveryScheduleCard(),

              const SizedBox(height: 14),

              // =====================================================
              // 4. ORDER PAYMENT SUMMARY
              // =====================================================

              _buildPaymentSummaryCard(),

              const SizedBox(height: 14),

              // =====================================================
              // 5. STATUS CHIPS
              // =====================================================

              _buildStatusChipsRow(),

              const SizedBox(height: 14),

              // =====================================================
              // 6. LOCAL GROWERS
              // =====================================================

              _buildLocalGrowersCard(),

              const SizedBox(height: 32),

              // =====================================================
              // 7. ACTION BUTTONS
              // =====================================================

              _buildActionButtons(context),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // ORDER MESSAGE
  // =========================================================

  Widget _buildOrderMessage() {
    return RichText(
      textAlign: TextAlign.center,

      text: TextSpan(
        text: 'Order ',

        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
          height: 1.4,
        ),

        children: [
          TextSpan(
            text: orderNumbers,

            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
              color:
                  Colors.black87,
            ),
          ),

          const TextSpan(
            text:
                ' has been sent to the farmers.\n'
                'You can track your delivery in the Orders tab.',
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CELEBRATION HEADER
  // =========================================================

  Widget _buildCelebrationHeader() {
    return SizedBox(
      height: 180,
      width: double.infinity,

      child: Stack(
        alignment:
            Alignment.center,

        children: [
          CustomPaint(
            size:
                const Size(
              double.infinity,
              180,
            ),

            painter:
                ConfettiPainter(),
          ),

          // Halo
          Container(
            width: 128,
            height: 128,

            decoration:
                BoxDecoration(
              shape:
                  BoxShape.circle,

              color:
                  primaryGreen
                      .withValues(
                alpha: 0.1,
              ),
            ),
          ),

          // Main circle
          Container(
            width: 100,
            height: 100,

            decoration:
                const BoxDecoration(
              shape:
                  BoxShape.circle,

              color:
                  primaryGreen,

              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black12,
                  blurRadius: 10,
                  offset:
                      Offset(0, 4),
                ),
              ],
            ),

            child: Center(
              child: Container(
                width: 44,
                height: 44,

                decoration:
                    const BoxDecoration(
                  shape:
                      BoxShape.circle,

                  color:
                      Colors.white,
                ),

                child:
                    const Icon(
                  Icons.check_rounded,
                  color:
                      primaryGreen,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DELIVERY SCHEDULE
  // =========================================================

  Widget _buildDeliveryScheduleCard() {
    final isPickup =
        deliveryMethod == 'pickup';

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(18),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          16,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.02,
            ),

            blurRadius: 10,

            offset:
                const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Container(
            padding:
                const EdgeInsets.all(
              10,
            ),

            decoration:
                BoxDecoration(
              color:
                  iconBadgeBg,

              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),

            child: Icon(
              isPickup
                  ? Icons.store_outlined
                  : Icons
                      .local_shipping_outlined,

              color:
                  primaryGreen,

              size: 22,
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  isPickup
                      ? 'PICKUP'
                      : 'DELIVERY SCHEDULE',

                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Colors.grey.shade600,
                    letterSpacing:
                        0.8,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  isPickup
                      ? 'Ready for pickup'
                      : 'Expected Tomorrow',

                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Colors.black87,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  isPickup
                      ? 'Please check your Orders tab'
                      : '6:00 AM - 8:00 AM',

                  style: TextStyle(
                    fontSize: 13,
                    color:
                        Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PAYMENT SUMMARY
  // =========================================================

  Widget _buildPaymentSummaryCard() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(18),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          16,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.02,
            ),

            blurRadius: 10,

            offset:
                const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _buildSectionHeader(
            Icons.receipt_long_outlined,
            'PAYMENT SUMMARY',
          ),

          const SizedBox(
            height: 16,
          ),

          _buildPriceLine(
            'Subtotal',
            '\$${subtotal.toStringAsFixed(2)}',
          ),

          const SizedBox(
            height: 8,
          ),

          _buildPriceLine(
            'Transaction Fee (5%)',
            '\$${transactionFee.toStringAsFixed(2)}',
          ),

          const SizedBox(
            height: 8,
          ),

          _buildPriceLine(
            'Delivery Fee',
            '\$${deliveryFee.toStringAsFixed(2)}',
          ),

          const SizedBox(
            height: 12,
          ),

          Divider(
            color:
                Colors.grey.shade200,
          ),

          const SizedBox(
            height: 10,
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                'TOTAL PAID',
                style:
                    TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Colors.black87,
                ),
              ),

              Text(
                '\$${totalAmount.toStringAsFixed(2)}',

                style:
                    const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      primaryGreen,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),

            decoration:
                BoxDecoration(
              color:
                  chipBgColor,

              borderRadius:
                  BorderRadius.circular(
                8,
              ),
            ),

            child: const Row(
              children: [
                Icon(
                  Icons.qr_code_2,
                  size: 16,
                  color:
                      primaryGreen,
                ),

                SizedBox(
                  width: 6,
                ),

                Text(
                  'Paid via KHQR',
                  style:
                      TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STATUS CHIPS
  // =========================================================

  Widget _buildStatusChipsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),

            decoration:
                BoxDecoration(
              color:
                  chipBgColor,

              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),

            child: const Row(
              children: [
                Icon(
                  Icons
                      .verified_outlined,
                  color:
                      primaryGreen,
                  size: 20,
                ),

                SizedBox(
                  width: 8,
                ),

                Expanded(
                  child: Text(
                    'Order\nConfirmed',
                    style:
                        TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Colors.black87,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),

            decoration:
                BoxDecoration(
              color:
                  chipBgColor,

              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),

            child: const Row(
              children: [
                Icon(
                  Icons
                      .receipt_long_outlined,
                  color:
                      primaryGreen,
                  size: 20,
                ),

                SizedBox(
                  width: 8,
                ),

                Expanded(
                  child: Text(
                    'Payment\nConfirmed',
                    style:
                        TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Colors.black87,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // LOCAL GROWERS CARD
  // =========================================================

  Widget _buildLocalGrowersCard() {
    return Container(
      height: 140,
      width: double.infinity,

      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          16,
        ),

        image:
            const DecorationImage(
          image:
              NetworkImage(
            'https://images.unsplash.com/'
            'photo-1500937386664-56d1dfef3854'
            '?auto=format&fit=crop&w=800&q=80',
          ),

          fit:
              BoxFit.cover,
        ),
      ),

      child: Stack(
        children: [
          Container(
            decoration:
                BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                16,
              ),

              gradient:
                  LinearGradient(
                colors: [
                  Colors.black.withValues(
                    alpha: 0.6,
                  ),

                  Colors.transparent,
                ],

                begin:
                    Alignment.bottomLeft,

                end:
                    Alignment.topRight,
              ),
            ),
          ),

          Positioned(
            bottom: 14,
            left: 14,

            child: Row(
              children: const [
                Icon(
                  Icons
                      .agriculture_outlined,
                  color:
                      Colors.white,
                  size: 16,
                ),

                SizedBox(
                  width: 6,
                ),

                Text(
                  'Connecting you with local growers',
                  style:
                      TextStyle(
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight.w600,
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

  // =========================================================
  // ACTION BUTTONS
  // =========================================================

  Widget _buildActionButtons(
    BuildContext context,
  ) {
    return Column(
      children: [
        // TRACK ORDER
        SizedBox(
          width: double.infinity,
          height: 50,

          child:
              ElevatedButton.icon(
            onPressed: () {
              /*
               * Later:
               * Navigator.push(...)
               * to OrderTrackingScreen
               */
            },

            icon:
                const Icon(
              Icons.alt_route_rounded,
              color:
                  Colors.white,
              size: 20,
            ),

            label:
                const Text(
              'Track Order',
              style:
                  TextStyle(
                color:
                    Colors.white,
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  buttonOrange,

              elevation: 0,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        // BACK HOME
        SizedBox(
          width: double.infinity,
          height: 50,

          child:
              OutlinedButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,

                MaterialPageRoute(
                  builder: (_) =>
                      const HomeScreen(),
                ),

                (route) => false,
              );
            },

            icon:
                const Icon(
              Icons.home_outlined,
              color:
                  primaryGreen,
              size: 20,
            ),

            label:
                const Text(
              'Back to Home',
              style:
                  TextStyle(
                color:
                    primaryGreen,
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            style:
                OutlinedButton.styleFrom(
              side:
                  const BorderSide(
                color:
                    primaryGreen,
                width: 1.5,
              ),

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),

              backgroundColor:
                  Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // SECTION HEADER
  // =========================================================

  Widget _buildSectionHeader(
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color:
              primaryGreen,
        ),

        const SizedBox(
          width: 8,
        ),

        Text(
          title,

          style:
              TextStyle(
            fontSize: 11,
            fontWeight:
                FontWeight.bold,
            color:
                Colors.grey.shade700,
            letterSpacing:
                0.8,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // PRICE LINE
  // =========================================================

  Widget _buildPriceLine(
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [
        Text(
          label,

          style:
              TextStyle(
            fontSize: 13,
            color:
                Colors.grey.shade600,
          ),
        ),

        Text(
          value,

          style:
              const TextStyle(
            fontSize: 13,
            fontWeight:
                FontWeight.w600,
            color:
                Colors.black87,
          ),
        ),
      ],
    );
  }
}

// =============================================================
// CONFETTI PAINTER
// =============================================================

class ConfettiPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final random =
        math.Random(42);

    final colors = [
      const Color(0xFF135A27),
      const Color(0xFF62A06E),
      const Color(0xFFFF8C00),
      const Color(0xFF8AC926),
    ];

    for (
      int i = 0;
      i < 32;
      i++
    ) {
      final paint = Paint()
        ..color =
            colors[
                random.nextInt(
              colors.length,
            )]
        ..style =
            PaintingStyle.fill;

      final x =
          random.nextDouble() *
              size.width;

      final y =
          random.nextDouble() *
              size.height;

      // Don't draw particles
      // directly around checkmark.
      if ((x -
                      size.width / 2)
                  .abs() <
              50 &&
          (y -
                      size.height / 2)
                  .abs() <
              50) {
        continue;
      }

      final particleSize =
          random.nextDouble() *
                  6 +
              4;

      canvas.save();

      canvas.translate(
        x,
        y,
      );

      canvas.rotate(
        random.nextDouble() *
            math.pi,
      );

      canvas.drawRect(
        Rect.fromLTWH(
          0,
          0,
          particleSize,
          particleSize,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}