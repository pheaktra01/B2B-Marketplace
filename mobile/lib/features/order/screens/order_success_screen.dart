import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile/features/restaurant/screens/home_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  // Theme Colors
  static const Color primaryGreen = Color(0xFF135A27);
  static const Color pageBgColor = Color(0xFFF7F9F8);
  static const Color buttonOrange = Color(0xFFFF8C00);
  static const Color chipBgColor = Color(0xFFF2F5F4);
  static const Color iconBadgeBg = Color(0xFFE5EDE7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // 1. Confetti & Checkmark Illustration Header
              _buildCelebrationHeader(),

              const SizedBox(height: 24),

              // 2. Order Success Title & Order Number
              const Text(
                'Order Placed\nSuccessfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Order ',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  children: const [
                    TextSpan(
                      text: '#8842',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: ' has been sent to the farmers.\nYou can track your delivery in the Orders tab.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 3. Delivery Schedule Card
              _buildDeliveryScheduleCard(),

              const SizedBox(height: 14),

              // 4. Status Chips Row (Confirmed Quality & Invoice Ready)
              _buildStatusChipsRow(),

              const SizedBox(height: 14),

              // 5. Local Growers Hero Card
              _buildLocalGrowersCard(),

              const SizedBox(height: 32),

              // 6. Action Buttons (Track Order & Back to Home)
              _buildActionButtons(context),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildCelebrationHeader() {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Confetti Particles
          CustomPaint(
            size: const Size(double.infinity, 180),
            painter: ConfettiPainter(),
          ),

          // Glowing Outer Circle Halo
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryGreen.withValues(alpha: 0.1),
            ),
          ),

          // Dark Green Main Circle
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: primaryGreen,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Center(
              // White Checkmark Icon Circle
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: primaryGreen,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryScheduleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBadgeBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: primaryGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DELIVERY SCHEDULE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Expected Tomorrow',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '6:00 AM - 8:00 AM',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChipsRow() {
    return Row(
      children: [
        // Chip 1: Confirmed Quality
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: chipBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.verified_outlined,
                  color: primaryGreen,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Confirmed\nQuality',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Chip 2: Invoice Ready
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: chipBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  color: primaryGreen,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Invoice Ready',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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

  Widget _buildLocalGrowersCard() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=800&q=80',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Dark Overlay Gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
          // Caption Over Image
          Positioned(
            bottom: 14,
            left: 14,
            child: Row(
              children: const [
                Icon(Icons.agriculture_outlined, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'Connecting you with local growers',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Track Order Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.alt_route_rounded, color: Colors.white, size: 20),
            label: const Text(
              'Track Order',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonOrange,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Back to Home Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(), // Replace with your actual home screen widget
              ),
            ),
            icon: const Icon(Icons.home_outlined, color: primaryGreen, size: 20),
            label: const Text(
              'Back to Home',
              style: TextStyle(
                color: primaryGreen,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: primaryGreen, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Painter for generating festive confetti particles around the checkmark
class ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed for reproducible layout
    final colors = [
      const Color(0xFF135A27),
      const Color(0xFF62A06E),
      const Color(0xFFFF8C00),
      const Color(0xFF8AC926),
    ];

    for (int i = 0; i < 32; i++) {
      final paint = Paint()
        ..color = colors[random.nextInt(colors.length)]
        ..style = PaintingStyle.fill;

      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;

      // Don't draw particles right on top of the central checkmark
      if ((x - size.width / 2).abs() < 50 && (y - size.height / 2).abs() < 50) {
        continue;
      }

      double particleSize = random.nextDouble() * 6 + 4;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(random.nextDouble() * math.pi);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, particleSize, particleSize),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}