import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/auth/screens/reset_password_screen.dart';
import 'package:mobile/features/farmer/screens/farmer_dashboard_screen.dart';
import 'package:mobile/features/restaurant/screens/home_screen.dart';

class VerifyPhoneScreen extends StatefulWidget {
  final VerificationType type;
  final String phoneNumber;
  final String? selectedRole; 

  const VerifyPhoneScreen({
    super.key,
    required this.type,
    required this.phoneNumber,
    this.selectedRole,
  });

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

enum VerificationType {
  login,
  signup,
  forgotPassword,
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final _formKey = GlobalKey<FormState>();

  // Create 6 controllers and 6 focus nodes for the 6-digit OTP fields
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String get buttonText {
    switch (widget.type) {
      case VerificationType.login:
        return "Login";
      case VerificationType.signup:
        return "Create Account";
      case VerificationType.forgotPassword:
        return "Reset Password";
    }
  }

  bool get showBackButton => widget.type == VerificationType.signup;

  bool get showChangePhone => widget.type != VerificationType.signup;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // Combines the 6 individual inputs into a single code string
  String get _currentOtpCode => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF0F6221);
    const inputFillColor = Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 360;
            final isShortScreen = constraints.maxHeight < 650;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16.0 : 24.0,
                  vertical: isShortScreen ? 16.0 : 24.0,
                ),
                child: ConstrainedBox(
                  // Max width constraint caps card stretch on tablets & desktops
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- Back Button ---
                      if (showBackButton)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Material(
                            color: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 20,
                                color: brandGreen,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),

                      if (showBackButton)
                        SizedBox(height: isShortScreen ? 12 : 16),

                      // --- Green Padlock Security Icon ---
                      Container(
                        width: isShortScreen ? 56 : 70,
                        height: isShortScreen ? 56 : 70,
                        decoration: BoxDecoration(
                          color: brandGreen,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.lock_open_outlined,
                          size: isShortScreen ? 30 : 38,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isShortScreen ? 12 : 16),

                      // --- Branding Title ---
                      Text(
                        'PsarKesekor',
                        style: TextStyle(
                          fontSize: isShortScreen ? 26 : 32,
                          fontWeight: FontWeight.bold,
                          color: brandGreen,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Secure Marketplace Verification',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),

                      SizedBox(height: isShortScreen ? 20 : 32),

                      // --- Main Container Card ---
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 14.0 : 20.0,
                          vertical: isShortScreen ? 20.0 : 32.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Text(
                                'Enter Verification Code',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 19 : 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'We\'ve sent a 6-digit verification code to\n${widget.phoneNumber}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                              ),

                              SizedBox(height: isShortScreen ? 20 : 28),

                              // --- Responsive 6-Digit OTP Field Row ---
                              LayoutBuilder(
                                builder: (context, cardConstraints) {
                                  // Compute dynamic width per box so they never overflow on tiny screens
                                  final totalAvailableWidth =
                                      cardConstraints.maxWidth;
                                  final calculatedBoxWidth =
                                      ((totalAvailableWidth - (5 * 8)) / 6)
                                          .clamp(36.0, 48.0);

                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(
                                      6,
                                      (index) => _buildOtpBox(
                                        index,
                                        inputFillColor,
                                        calculatedBoxWidth,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: isShortScreen ? 20 : 32),

                              // --- Verify & Proceed Button ---
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: brandGreen,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 1,
                                  ),
                                  onPressed: () {
                                    if (_currentOtpCode.length == 6) {
                                      switch (widget.type) {
                                        case VerificationType.login:
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const FarmerDashboardScreen(),
                                            ),
                                          );
                                          break;

                                      case VerificationType.signup:
                                        if (widget.selectedRole == 'farmer') {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const FarmerDashboardScreen(),
                                            ),
                                          );
                                        } else if (widget.selectedRole == 'restaurant') {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const HomeScreen(),
                                            ),
                                          );
                                        }
                                        break;

                                        case VerificationType.forgotPassword:
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const ResetPasswordScreen(),
                                            ),
                                          );
                                          break;
                                      }
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        buttonText,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: isShortScreen ? 20 : 28),

                              // --- Resend Verification Section ---
                              const Text(
                                'Didn\'t receive the code?',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              TextButton.icon(
                                onPressed: () {
                                  // Trigger API resend logic
                                },
                                icon: const Icon(
                                  Icons.refresh,
                                  size: 16,
                                  color: brandGreen,
                                ),
                                label: const Text(
                                  'Resend Code',
                                  style: TextStyle(
                                    color: brandGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                              if (showChangePhone) ...[
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Wrong phone number? Change number',
                                    style: TextStyle(
                                      color: brandGreen,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Generates custom independent dynamic input slots handling keyboard focus
  Widget _buildOtpBox(int index, Color fillColor, double width) {
    return SizedBox(
      width: width,
      height: 52,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          filled: true,
          fillColor: fillColor,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black26, width: 1.5),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Forward pass focus handling
            if (index < 5) {
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            } else {
              _focusNodes[index].unfocus(); // Done inputting final digit
            }
          } else {
            // Backward pass deletion focus handling
            if (index > 0) {
              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
            }
          }
        },
      ),
    );
  }
}