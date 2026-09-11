import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/core/routing/route_args.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyPhoneScreen extends StatefulWidget {
  final VerificationType type;
  final String phoneNumber;
  final String? selectedRole;
  final String? userId;
  final String? initialOtp;
  final String? password;

  const VerifyPhoneScreen({
    super.key,
    required this.type,
    required this.phoneNumber,
    this.selectedRole,
    this.userId,
    this.initialOtp,
    this.password,
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
  final _authService = AuthService();

  // Create 6 controllers and 6 focus nodes for the 6-digit OTP fields
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  String get buttonText {
    switch (widget.type) {
      case VerificationType.login:
        return "ចូលប្រើប្រាស់";
      case VerificationType.signup:
        return "បង្កើតគណនី";
      case VerificationType.forgotPassword:
        return "កំណត់ពាក្យសម្ងាត់ឡើងវិញ";
    }
  }

  bool get showBackButton => widget.type == VerificationType.signup;

  bool get showChangePhone => widget.type != VerificationType.signup;

  @override
  void initState() {
    super.initState();

    final initialOtp = (widget.initialOtp != null && widget.initialOtp!.length == 6)
        ? widget.initialOtp!
        : '123456';
    for (var index = 0; index < _controllers.length; index++) {
      _controllers[index].text = initialOtp[index];
    }
  }

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
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go(AppRoutes.login);
                                }
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
                        'ផ្សារកសិករ',
                        style: TextStyle(
                          fontSize: isShortScreen ? 26 : 32,
                          fontWeight: FontWeight.bold,
                          color: brandGreen,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'ការផ្ទៀងផ្ទាត់ទីផ្សារប្រកបដោយសុវត្ថិភាព',
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
                                'បញ្ចូលលេខកូដផ្ទៀងផ្ទាត់',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 19 : 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'យើងបានផ្ញើលេខកូដផ្ទៀងផ្ទាត់ ៦ខ្ទង់ ទៅកាន់\n${widget.phoneNumber}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: brandGreen.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lock_clock_outlined,
                                      size: 16,
                                      color: brandGreen,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'លេខកូដសាកល្បង / OTP: 123456',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: brandGreen,
                                      ),
                                    ),
                                  ],
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
                                  onPressed: _isLoading
                                      ? null
                                      : () async {
                                          if (_currentOtpCode.length != 6) {
                                            return;
                                          }

                                          final messenger = ScaffoldMessenger.of(context);

                                          setState(() {
                                            _isLoading = true;
                                          });

                                          try {
                                            switch (widget.type) {
                                              case VerificationType.login:
                                                if (widget.selectedRole == 'farmer') {
                                                  context.go(AppRoutes.farmerDashboard);
                                                } else {
                                                  context.go(AppRoutes.restaurantHome);
                                                }
                                                break;

                                              case VerificationType.signup:
                                                if (widget.userId == null || widget.userId!.isEmpty) {
                                                  throw StateError('Missing user id for verification');
                                                }
                                                final response = await _authService.verifyOtp(
                                                  userId: widget.userId!,
                                                  otp: _currentOtpCode,
                                                );
                                                final data = response['data'] as Map<String, dynamic>;

                                                final status = response['statusCode'] as int;
                                                if (status < 200 || status >= 300) {
                                                  throw StateError(data['message']?.toString() ?? 'OTP verification failed');
                                                }

                                                final prefs = await SharedPreferences.getInstance();
                                                await prefs.setString('userId', widget.userId!);

                                                // After successful verification, if we have the password (from signup), auto-login
                                                if (widget.password != null && widget.password!.isNotEmpty) {
                                                  final loginResp = await _authService.login(
                                                    phone: widget.phoneNumber,
                                                    password: widget.password!,
                                                  );

                                                  final loginData = loginResp['data'] as Map<String, dynamic>;

                                                  final loginStatus = loginResp['statusCode'] as int;
                                                  if (loginStatus >= 200 && loginStatus < 300) {
                                                    final user = loginData['user'] as Map<String, dynamic>?;
                                                    final role = user?['role']?.toString();
                                                    final loggedInUserId = user?['id']?.toString();

                                                    if (loggedInUserId != null && loggedInUserId.isNotEmpty) {
                                                      await prefs.setString('userId', loggedInUserId);
                                                    }

                                                    if (!mounted) return;
                                                    context.go(
                                                      AppRoutes.setupProfile,
                                                      extra: role ?? widget.selectedRole ?? 'restaurant',
                                                    );
                                                  } else {
                                                    // If login failed, still navigate to setupProfile
                                                    if (!mounted) return;
                                                    context.go(
                                                      AppRoutes.setupProfile,
                                                      extra: widget.selectedRole ?? 'restaurant',
                                                    );
                                                  }
                                                } else {
                                                  // No password provided: route to setupProfile
                                                  if (!mounted) return;
                                                  context.go(
                                                    AppRoutes.setupProfile,
                                                    extra: widget.selectedRole ?? 'restaurant',
                                                  );
                                                }
                                                break;

                                              case VerificationType.forgotPassword:
                                                if (!mounted) return;
                                                context.push(AppRoutes.resetPassword, extra: ResetPasswordArgs(
                                                  phoneNumber: widget.phoneNumber,
                                                  otp: _currentOtpCode,
                                                ));
                                                break;
                                            }
                                          } catch (error) {
                                            if (!mounted) {
                                              return;
                                            }

                                            messenger.showSnackBar(
                                              SnackBar(
                                                content: Text('Unable to verify OTP: $error'),
                                              ),
                                            );
                                          } finally {
                                            if (mounted) {
                                              setState(() {
                                                _isLoading = false;
                                              });
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
                                'មិនទាន់បានទទួលលេខកូដមែនទេ?',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              TextButton.icon(
                                onPressed: () {
                                  const staticOtp = '123456';
                                  for (var i = 0; i < _controllers.length; i++) {
                                    _controllers[i].text = staticOtp[i];
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('លេខកូដផ្ទៀងផ្ទាត់របស់អ្នកគឺ: 123456'),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.refresh,
                                  size: 16,
                                  color: brandGreen,
                                ),
                                label: const Text(
                                  'ផ្ញើលេខកូដឡើងវិញ',
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
                                    if (context.canPop()) {
                                      context.pop();
                                    } else {
                                      context.go(AppRoutes.login);
                                    }
                                  },
                                  child: const Text(
                                    'លេខទូរស័ព្ទមិនត្រឹមត្រូវ? ផ្លាស់ប្តូរលេខ',
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