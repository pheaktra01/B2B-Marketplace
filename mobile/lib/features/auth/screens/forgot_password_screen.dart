import 'package:flutter/material.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/features/auth/screens/login_screen.dart';
import 'package:mobile/features/auth/screens/verify_phone_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;

  String get phone => _identifierController.text;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

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
            final isLandscapeOrShort = constraints.maxHeight < 650;

            // Adaptive spacing values
            final topSpacing = isLandscapeOrShort ? 16.0 : 32.0;
            final cardPadding = isSmallScreen ? 16.0 : 24.0;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16.0 : 24.0,
                  vertical: 24.0,
                ),
                child: ConstrainedBox(
                  // Limits max width on tablets & desktop
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Logo & Branding Header ---
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: brandGreen.withValues(alpha: 0.1),
                            backgroundImage: const AssetImage('assets/logo01.png'),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'ផ្សារកសិករ',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: brandGreen,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'ផ្សារផលិតផលកសិកម្មស្រស់ៗសម្រាប់\nចុងភៅអាជីព។',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: topSpacing),

                      // --- Main Container Card ---
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: cardPadding,
                          vertical: isLandscapeOrShort ? 24.0 : 32.0,
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
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'ភ្លេចពាក្យសម្ងាត់',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "សូមបញ្ចូលអាសយដ្ឋានអ៊ីមែល ឬលេខទូរស័ព្ទដែលភ្ជាប់ជាមួយគណនីរបស់អ្នក។ យើងនឹងផ្ញើតំណ ឬកូដដើម្បីកំណត់ពាក្យសម្ងាត់ឡើងវិញ។",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // --- Input Field ---
                              const Text(
                                'លេខទូរស័ព្ទ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _identifierController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: '០១២៣៤៥៦៧៨៩ ឬ +855123456789',
                                  hintStyle: const TextStyle(
                                    color: Colors.black38,
                                    fontSize: 14,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.mail_outline,
                                    color: Colors.black45,
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: inputFillColor,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.black26,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'សូមបញ្ចូលលេខទូរស័ព្ទរបស់អ្នក';
                                  }

                                  if (!RegExp(r'^(0|\+855)\d{8,9}$').hasMatch(value.trim())) {
                                    return 'លេខទូរស័ព្ទមិនត្រឹមត្រូវ';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // --- Submit Button ---
                              SizedBox(
                                width: double.infinity,
                                height: 52,
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
                                          if (!_formKey.currentState!.validate()) {
                                            return;
                                          }

                                          final navigator = Navigator.of(context);
                                          final messenger = ScaffoldMessenger.of(context);

                                          setState(() {
                                            _isLoading = true;
                                          });

                                          try {
                                            final response = await _authService.forgotPassword(
                                              phone: phone.trim(),
                                            );
                                            final data = response['data'] as Map<String, dynamic>;

                                            final status = response['statusCode'] as int;
                                            if (status >= 200 && status < 300) {
                                              if (!mounted) {
                                                return;
                                              }

                                              navigator.pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (_) => VerifyPhoneScreen(
                                                    type: VerificationType.forgotPassword,
                                                    phoneNumber: phone.trim(),
                                                    initialOtp: data['otp']?.toString(),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              if (!mounted) {
                                                return;
                                              }

                                              messenger.showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    data['message']?.toString() ?? 'Unable to request OTP',
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (error) {
                                            if (!mounted) {
                                              return;
                                            }

                                            messenger.showSnackBar(
                                              SnackBar(
                                                content: Text('Unable to request OTP: $error'),
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
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'ផ្ញើ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_ios, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: topSpacing),

                      // --- Back to Login Button ---
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 18,
                            color: Colors.black54,
                          ),
                          label: const Text(
                            'ត្រឡប់ទៅទំព័រចូលប្រើប្រាស់',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
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
}