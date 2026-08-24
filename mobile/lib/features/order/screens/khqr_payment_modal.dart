import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/features/order/models/order_model.dart';
import 'package:mobile/features/order/screens/order_success_screen.dart';

class KhqrPaymentModal extends StatefulWidget {
  final List<OrderModel> orders;
  final double totalAmount;

  const KhqrPaymentModal({
    super.key,
    required this.orders,
    required this.totalAmount,
  });

  @override
  State<KhqrPaymentModal> createState() =>
      _KhqrPaymentModalState();
}

class _KhqrPaymentModalState
    extends State<KhqrPaymentModal> {
  // =========================================================
  // COLORS
  // =========================================================

  static const Color primaryGreen =
      Color(0xFF135A27);

  static const Color khqrRed =
      Color(0xFFD30000);

  static const Color timerBg =
      Color(0xFFF9EFE6);

  static const Color timerText =
      Color(0xFF8B4513);

  static const Color footerBg =
      Color(0xFFF2F5F4);

  // =========================================================
  // TIMER
  // =========================================================

  Timer? _timer;

  int _startSeconds = 299;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    _startTimer();
  }

  // =========================================================
  // COUNTDOWN
  // =========================================================

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_startSeconds <= 0) {
          timer.cancel();

          setState(() {
            _startSeconds = 0;
          });

          return;
        }

        setState(() {
          _startSeconds--;
        });
      },
    );
  }

  // =========================================================
  // FORMAT TIME
  // =========================================================

  String _formatTime(int totalSeconds) {
    final minutes =
        totalSeconds ~/ 60;

    final seconds =
        totalSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // =========================================================
  // PAYMENT CONFIRMATION
  // =========================================================

  Future<void> _confirmPayment() async {
    if (_isProcessing) {
      return;
    }

    if (_startSeconds <= 0) {
      _showError(
        'This KHQR payment has expired.',
      );

      return;
    }

    setState(() {
      _isProcessing = true;
    });

    /*
     * IMPORTANT:
     *
     * For your current demo, we are only simulating
     * successful KHQR payment.
     *
     * Later you should connect this button to your
     * real KHQR/payment verification API.
     */

    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderSuccessScreen(
          orders: widget.orders,
        ),
      ),
    );
  }

  // =========================================================
  // ERROR
  // =========================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,

      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 24,
            ),

            child: Dialog(
              insetPadding:
                  EdgeInsets.zero,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20),
              ),

              clipBehavior:
                  Clip.antiAlias,

              backgroundColor:
                  Colors.white,

              child: Column(
                mainAxisSize:
                    MainAxisSize.min,

                children: [
                  // =====================================================
                  // HEADER
                  // =====================================================

                  _buildHeader(context),

                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFEEEEEE),
                  ),

                  // =====================================================
                  // BODY
                  // =====================================================

                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      20,
                    ),

                    child: Column(
                      children: [
                        // =================================================
                        // ACCOUNT
                        // =================================================

                        const Text(
                          'VERDANT MARKETPLACE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Colors.black54,
                            letterSpacing: 1.0,
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // =================================================
                        // QR CODE
                        // =================================================

                        _buildQrContainer(),

                        const SizedBox(
                          height: 16,
                        ),

                        // =================================================
                        // TOTAL AMOUNT
                        // =================================================

                        Text(
                          '\$${widget.totalAmount.toStringAsFixed(2)}',
                          style:
                              const TextStyle(
                            fontSize: 24,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                primaryGreen,
                          ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        const Text(
                          'Total payment amount',
                          style:
                              TextStyle(
                            fontSize: 12,
                            color:
                                Colors.black54,
                          ),
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        // =================================================
                        // ORDER COUNT
                        // =================================================

                        if (widget.orders.length > 1)
                          _buildOrderCount(),

                        if (widget.orders.length > 1)
                          const SizedBox(
                            height: 12,
                          ),

                        // =================================================
                        // COUNTDOWN
                        // =================================================

                        _buildCountdownPill(),

                        const SizedBox(
                          height: 20,
                        ),

                        // =================================================
                        // INSTRUCTIONS
                        // =================================================

                        Text(
                          'Open your banking app and scan '
                          'the QR code to complete the payment.',
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                Colors.grey.shade600,
                            height: 1.35,
                          ),
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        // =================================================
                        // DOWNLOAD QR
                        // =================================================

                        SizedBox(
                          width:
                              double.infinity,

                          height: 48,

                          child:
                              OutlinedButton.icon(
                            onPressed:
                                () {
                              _showError(
                                'QR download will be connected later.',
                              );
                            },

                            icon:
                                const Icon(
                              Icons
                                  .download_outlined,
                              color:
                                  primaryGreen,
                              size: 20,
                            ),

                            label:
                                const Text(
                              'Download QR',
                              style:
                                  TextStyle(
                                color:
                                    primaryGreen,
                                fontWeight:
                                    FontWeight
                                        .bold,
                                fontSize:
                                    14,
                              ),
                            ),

                            style:
                                OutlinedButton
                                    .styleFrom(
                              side:
                                  BorderSide(
                                color:
                                    primaryGreen
                                        .withValues(
                                  alpha: 0.4,
                                ),
                                width: 1.2,
                              ),

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        // =================================================
                        // PAYMENT BUTTON
                        // =================================================

                        SizedBox(
                          width:
                              double.infinity,

                          height: 50,

                          child:
                              ElevatedButton(
                            onPressed:
                                _isProcessing
                                    ? null
                                    : _confirmPayment,

                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  primaryGreen,

                              disabledBackgroundColor:
                                  primaryGreen
                                      .withValues(
                                alpha: 0.5,
                              ),

                              elevation: 0,

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
                              ),
                            ),

                            child:
                                _isProcessing
                                    ? const SizedBox(
                                        width:
                                            22,
                                        height:
                                            22,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth:
                                              2,
                                          color:
                                              Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'I Have Paid',
                                        style:
                                            TextStyle(
                                          color:
                                              Colors.white,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize:
                                              15,
                                        ),
                                      ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // =====================================================
                  // FOOTER
                  // =====================================================

                  _buildFooterBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),

      child: Row(
        children: [
          // KHQR LOGO
          Container(
            width: 32,
            height: 32,

            decoration:
                const BoxDecoration(
              color: khqrRed,
              shape: BoxShape.circle,
            ),

            alignment:
                Alignment.center,

            child: const Text(
              'KHQR',
              style: TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.bold,
                fontSize: 8,
                letterSpacing: -0.5,
              ),
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          const Text(
            'Scan to Pay',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
              color:
                  Colors.black87,
            ),
          ),

          const Spacer(),

          IconButton(
            icon: const Icon(
              Icons.close,
              color:
                  Colors.black54,
              size: 20,
            ),

            onPressed: () =>
                Navigator.maybePop(
              context,
            ),

            padding:
                EdgeInsets.zero,

            constraints:
                const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // QR CONTAINER
  // =========================================================

  Widget _buildQrContainer() {
    /*
     * IMPORTANT:
     *
     * This is still a DEMO QR.
     *
     * Later replace `data=` with the real KHQR payload
     * generated by your backend/payment provider.
     */

    final qrData =
        'VerdantMarketplace'
        '|amount=${widget.totalAmount.toStringAsFixed(2)}';

    final encodedData =
        Uri.encodeComponent(qrData);

    final qrUrl =
        'https://api.qrserver.com/v1/create-qr-code/'
        '?size=200x200&data=$encodedData';

    return Container(
      width: 240,
      height: 240,

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        border: Border.all(
          color:
              primaryGreen.withValues(
            alpha: 0.15,
          ),
          width: 1.5,
        ),

        boxShadow: [
          BoxShadow(
            color:
                primaryGreen.withValues(
              alpha: 0.08,
            ),
            blurRadius: 16,
            spreadRadius: 2,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Center(
        child: Stack(
          alignment:
              Alignment.center,

          children: [
            // QR
            Image.network(
              qrUrl,

              width: 200,
              height: 200,

              fit:
                  BoxFit.contain,

              errorBuilder:
                  (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.qr_code_2,
                  size: 180,
                  color:
                      Colors.black87,
                );
              },
            ),

            // KHQR CENTER LOGO
            Container(
              padding:
                  const EdgeInsets.all(
                5,
              ),

              decoration:
                  BoxDecoration(
                color:
                    khqrRed,

                shape:
                    BoxShape.circle,

                border:
                    Border.all(
                  color:
                      Colors.white,
                  width: 2,
                ),

                boxShadow:
                    const [
                  BoxShadow(
                    color:
                        Colors.black26,
                    blurRadius: 4,
                  ),
                ],
              ),

              child:
                  const Icon(
                Icons
                    .account_balance,
                color:
                    Colors.white,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // ORDER COUNT
  // =========================================================

  Widget _buildOrderCount() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),

      decoration:
          BoxDecoration(
        color:
            primaryGreen.withValues(
          alpha: 0.06,
        ),

        borderRadius:
            BorderRadius.circular(
          10,
        ),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          const Icon(
            Icons.receipt_long,
            size: 16,
            color:
                primaryGreen,
          ),

          const SizedBox(
            width: 6,
          ),

          Text(
            '${widget.orders.length} orders created',
            style:
                const TextStyle(
              color:
                  primaryGreen,
              fontWeight:
                  FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // COUNTDOWN
  // =========================================================

  Widget _buildCountdownPill() {
    final expired =
        _startSeconds <= 0;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),

      decoration:
          BoxDecoration(
        color: expired
            ? Colors.red.shade50
            : timerBg,

        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Icon(
            expired
                ? Icons.error_outline
                : Icons.access_time,

            size: 14,

            color: expired
                ? Colors.red
                : timerText,
          ),

          const SizedBox(
            width: 6,
          ),

          Text(
            expired
                ? 'Payment expired'
                : 'Expiring in '
                    '${_formatTime(_startSeconds)}',

            style: TextStyle(
              color: expired
                  ? Colors.red
                  : timerText,

              fontWeight:
                  FontWeight.bold,

              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FOOTER
  // =========================================================

  Widget _buildFooterBar() {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.symmetric(
        vertical: 12,
      ),

      color:
          footerBg,

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          _buildSecurityText(
            Icons.lock_outline,
            'SECURE ENCRYPTION',
          ),

          const SizedBox(
            width: 16,
          ),

          _buildSecurityText(
            Icons.verified_user_outlined,
            'BANK VERIFIED',
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SECURITY TEXT
  // =========================================================

  Widget _buildSecurityText(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12,
          color:
              Colors.grey.shade600,
        ),

        const SizedBox(
          width: 4,
        ),

        Text(
          text,
          style: TextStyle(
            fontSize: 9,
            fontWeight:
                FontWeight.bold,
            color:
                Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }
}