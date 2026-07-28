import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/features/order/screens/order_success_screen.dart';

class KhqrPaymentModal extends StatefulWidget {
  const KhqrPaymentModal({super.key});

  @override
  State<KhqrPaymentModal> createState() => _KhqrPaymentModalState();
}

class _KhqrPaymentModalState extends State<KhqrPaymentModal> {
  // Theme Colors
  static const Color primaryGreen = Color(0xFF135A27);
  static const Color khqrRed = Color(0xFFD30000);
  static const Color timerBg = Color(0xFFF9EFE6);
  static const Color timerText = Color(0xFF8B4513);
  static const Color footerBg = Color(0xFFF2F5F4);

  // Countdown timer for "Expiring in 04:59"
  Timer? _timer;
  int _startSeconds = 299; // 4 mins 59 secs

  // Navigation timer to simulate auto-redirect after payment
  Timer? _autoNavigateTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _startAutoNavigationTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startSeconds == 0) {
        if (mounted) {
          setState(() {
            timer.cancel();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _startSeconds--;
          });
        }
      }
    });
  }

  // Auto-redirect to OrderSuccessScreen after 3 seconds
  void _startAutoNavigationTimer() {
    _autoNavigateTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Navigates directly replacing the current route with the success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const OrderSuccessScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _autoNavigateTimer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54, // Dimmed modal overlay background
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Dialog(
              insetPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              backgroundColor: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Header (KHQR Icon, Title, and Close Button)
                  _buildHeader(context),

                  const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      children: [
                        // 2. Account Name
                        const Text(
                          'YUKI MOKOTO',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            letterSpacing: 1.0,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 3. Custom KHQR Code Box
                        _buildQrContainer(),

                        const SizedBox(height: 16),

                        // 4. Amount Text
                        const Text(
                          '\$4,280.50',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 5. Expiring Countdown Pill
                        _buildCountdownPill(),

                        const SizedBox(height: 20),

                        // 6. Instruction Subtitle
                        Text(
                          'Open your banking app and scan the QR code to complete the payment.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.35,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 7. Download QR Outlined Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.download_outlined,
                              color: primaryGreen,
                              size: 20,
                            ),
                            label: const Text(
                              'Download QR',
                              style: TextStyle(
                                color: primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: primaryGreen.withValues(alpha: 0.4),
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 8. Security Footer Bar
                  _buildFooterBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // KHQR Red Circle Logo
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: khqrRed,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              'KHQR',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 8,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Scan to Pay',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black54, size: 20),
            onPressed: () => Navigator.maybePop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildQrContainer() {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primaryGreen.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Embedded QR Code Mock Illustration
            Image.network(
              'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=YukiMokotoVerdantPay4280.50',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.qr_code_2, size: 180, color: Colors.black87);
              },
            ),

            // Red KHQR Emblem Overlay in center
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: khqrRed,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                  )
                ],
              ),
              child: const Icon(
                Icons.settings_suggest_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: timerBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time,
            size: 14,
            color: timerText,
          ),
          const SizedBox(width: 6),
          Text(
            'Expiring in ${_formatTime(_startSeconds)}',
            style: const TextStyle(
              color: timerText,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: footerBg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSecurityText(Icons.lock_outline, 'SECURE ENCRYPTION'),
          const SizedBox(width: 16),
          _buildSecurityText(Icons.verified_user_outlined, 'BANK VERIFIED'),
        ],
      ),
    );
  }

  Widget _buildSecurityText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}