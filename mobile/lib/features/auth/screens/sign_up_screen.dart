import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/core/routing/route_args.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/features/auth/screens/verify_phone_screen.dart';

class SignUpScreen extends StatefulWidget {
  final String selectedRole;

  const SignUpScreen({
    super.key,
    required this.selectedRole,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // Controllers to retrieve input data
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _enterpriseController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State variables for toggling visibility & checkbox
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _enterpriseController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF0F6221);
    const bgLight = Color(0xFFF8FAFC);
    const borderColor = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktopOrTablet = constraints.maxWidth > 600;
            final isWide = constraints.maxWidth > 768; // For 2-column input fields
            final inputFill = isDesktopOrTablet ? bgLight : const Color(0xFFF3F4F6);

            return Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktopOrTablet ? 24.0 : 0.0,
                    vertical: isDesktopOrTablet ? 32.0 : 0.0,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Container(
                      decoration: isDesktopOrTablet
                          ? BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                              border: Border.all(color: borderColor, width: 0.5),
                            )
                          : const BoxDecoration(color: Colors.white),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(isDesktopOrTablet ? 24 : 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(isDesktopOrTablet ? 32.0 : 24.0),
                              child: Form(
                                key: _formKey,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // --- Navigation Back Button ---
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Material(
                                        color: isDesktopOrTablet ? bgLight : Colors.white,
                                        shape: const CircleBorder(),
                                        elevation: isDesktopOrTablet ? 0 : 2,
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
                                              context.go(AppRoutes.roleSelection);
                                            }
                                          },
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // --- Logo & Title ---
                                    CircleAvatar(
                                      radius: 60,
                                      backgroundColor: brandGreen.withValues(alpha: 0.1),
                                      backgroundImage: const AssetImage('assets/logo01.png'),
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      'ផ្សារកសិករ',
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: brandGreen,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'ទីផ្សារផលិតផលកសិកម្មស្រស់សម្រាប់\nអាជីវកម្មផ្ទះបាយអាជីព',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.3),
                                    ),

                                    const SizedBox(height: 20),

                                    // Role indicator badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: brandGreen.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            widget.selectedRole == 'farmer' ? Icons.agriculture : Icons.restaurant,
                                            size: 16,
                                            color: brandGreen,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            widget.selectedRole == 'farmer'
                                                ? 'ចុះឈ្មោះជា៖ កសិករ (Farmer)'
                                                : 'ចុះឈ្មោះជា៖ ភោជនីយដ្ឋាន (Restaurant)',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: brandGreen,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    const Text(
                                      'បង្កើតគណនីរបស់អ្នក',
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'ចូលរួមជាមួយបណ្តាញពាណិជ្ជកម្មកសិកម្មឈានមុខគេ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.3),
                                    ),

                                    const SizedBox(height: 24),

                                    // --- Form Layout ---
                                    if (isWide) ...[
                                      // 2-Column Row 1: Name & Phone
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInputField(
                                              label: 'ឈ្មោះពេញ',
                                              hint: 'បញ្ចូលឈ្មោះពេញ',
                                              prefixIcon: Icons.person_outline,
                                              controller: _nameController,
                                              validator: (value) {
                                                if (value == null || value.trim().isEmpty) {
                                                  return 'សូមបញ្ចូលឈ្មោះពេញ';
                                                }
                                                return null;
                                              },
                                              fillColor: inputFill,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildInputField(
                                              label: 'លេខទូរស័ព្ទ',
                                              hint: '012345678',
                                              prefixIcon: Icons.phone_outlined,
                                              controller: _phoneController,
                                              keyboardType: TextInputType.phone,
                                              validator: (value) {
                                                final cleaned = (value ?? '').replaceAll(RegExp(r'\s+'), '');
                                                if (cleaned.isEmpty) {
                                                  return 'សូមបញ្ចូលលេខទូរស័ព្ទ';
                                                }

                                                if (!RegExp(r'^(0|\+855)\d{7,9}$').hasMatch(cleaned)) {
                                                  return 'លេខទូរស័ព្ទមិនត្រឹមត្រូវ';
                                                }

                                                return null;
                                              },
                                              fillColor: inputFill,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // 2-Column Row 2: Passwords
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInputField(
                                              label: 'ពាក្យសម្ងាត់',
                                              hint: 'ពាក្យសម្ងាត់',
                                              prefixIcon: Icons.lock_outline,
                                              controller: _passwordController,
                                              obscureText: _obscurePassword,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'សូមបញ្ចូលពាក្យសម្ងាត់';
                                                }

                                                if (value.length < 8) {
                                                  return 'ពាក្យសម្ងាត់ត្រូវមានយ៉ាងហោចណាស់ ៨ តួអក្សរ';
                                                }
                                                return null;
                                              },
                                              fillColor: inputFill,
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscurePassword
                                                      ? Icons.visibility_off_outlined
                                                      : Icons.visibility_outlined,
                                                  color: Colors.black54,
                                                ),
                                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildInputField(
                                              label: 'បញ្ជាក់ពាក្យសម្ងាត់',
                                              hint: 'បញ្ជាក់ពាក្យសម្ងាត់',
                                              prefixIcon: Icons.lock_outline,
                                              controller: _confirmPasswordController,
                                              obscureText: _obscureConfirmPassword,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'សូមបញ្ជាក់ពាក្យសម្ងាត់';
                                                }

                                                if (value != _passwordController.text) {
                                                  return 'ពាក្យសម្ងាត់មិនត្រូវគ្នា';
                                                }
                                                return null;
                                              },
                                              fillColor: inputFill,
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscureConfirmPassword
                                                      ? Icons.visibility_off_outlined
                                                      : Icons.visibility_outlined,
                                                  color: Colors.black54,
                                                ),
                                                onPressed: () => setState(
                                                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ] else ...[
                                      // Single-column mobile view
                                      _buildInputField(
                                        label: 'ឈ្មោះពេញ',
                                        hint: 'បញ្ចូលឈ្មោះពេញរបស់អ្នក',
                                        prefixIcon: Icons.person_outline,
                                        controller: _nameController,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'សូមបញ្ចូលឈ្មោះពេញ';
                                          }
                                          return null;
                                        },
                                        fillColor: inputFill,
                                      ),
                                      _buildInputField(
                                        label: 'លេខទូរស័ព្ទ',
                                        hint: '012345678',
                                        prefixIcon: Icons.phone_outlined,
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        validator: (value) {
                                          final cleaned = (value ?? '').replaceAll(RegExp(r'\s+'), '');
                                          if (cleaned.isEmpty) {
                                            return 'សូមបញ្ចូលលេខទូរស័ព្ទ';
                                          }

                                          if (!RegExp(r'^(0|\+855)\d{7,9}$').hasMatch(cleaned)) {
                                            return 'លេខទូរស័ព្ទមិនត្រឹមត្រូវ';
                                          }

                                          return null;
                                        },
                                        fillColor: inputFill,
                                      ),
                                      _buildInputField(
                                        label: 'ពាក្យសម្ងាត់',
                                        hint: 'ពាក្យសម្ងាត់',
                                        prefixIcon: Icons.lock_outline,
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'សូមបញ្ចូលពាក្យសម្ងាត់';
                                          }

                                          if (value.length < 8) {
                                            return 'ពាក្យសម្ងាត់ត្រូវមានយ៉ាងហោចណាស់ ៨ តួអក្សរ';
                                          }

                                          return null;
                                        },
                                        fillColor: inputFill,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: Colors.black54,
                                          ),
                                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                        ),
                                      ),
                                      _buildInputField(
                                        label: 'បញ្ជាក់ពាក្យសម្ងាត់',
                                        hint: 'បញ្ជាក់ពាក្យសម្ងាត់',
                                        prefixIcon: Icons.lock_outline,
                                        controller: _confirmPasswordController,
                                        obscureText: _obscureConfirmPassword,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'សូមបញ្ជាក់ពាក្យសម្ងាត់';
                                          }

                                          if (value != _passwordController.text) {
                                            return 'ពាក្យសម្ងាត់មិនត្រូវគ្នា';
                                          }

                                          return null;
                                        },
                                        fillColor: inputFill,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirmPassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: Colors.black54,
                                          ),
                                          onPressed: () =>
                                              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                        ),
                                      ),
                                    ],

                                    // --- Terms and Conditions Checkbox ---
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Checkbox(
                                            value: _agreedToTerms,
                                            activeColor: brandGreen,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                            onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: RichText(
                                            text: const TextSpan(
                                              style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
                                              children: [
                                                TextSpan(text: 'ខ្ញុំយល់ព្រមតាម '),
                                                TextSpan(
                                                  text: 'លក្ខខណ្ឌប្រើប្រាស់',
                                                  style: TextStyle(
                                                    color: brandGreen,
                                                    fontWeight: FontWeight.w600,
                                                    decoration: TextDecoration.underline,
                                                  ),
                                                ),
                                                TextSpan(text: ' និង '),
                                                TextSpan(
                                                  text: 'គោលការណ៍ឯកជនភាព។',
                                                  style: TextStyle(
                                                    color: brandGreen,
                                                    fontWeight: FontWeight.w600,
                                                    decoration: TextDecoration.underline,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 24),

                                    // --- Sign Up Button ---
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: brandGreen,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 0,
                                        ),
                                        onPressed: _isLoading
                                            ? null
                                            : () async {
                                                if (!_formKey.currentState!.validate() || !_agreedToTerms) {
                                                  return;
                                                }

                                                final messenger = ScaffoldMessenger.of(context);

                                                setState(() {
                                                  _isLoading = true;
                                                });

                                                try {
                                                  final cleanPhone = _phoneController.text.replaceAll(RegExp(r'\s+'), '');
                                                  final response = await _authService.register(
                                                    name: _nameController.text.trim(),
                                                    phone: cleanPhone,
                                                    password: _passwordController.text,
                                                    role: widget.selectedRole,
                                                  );
                                                  final data = response['data'] as Map<String, dynamic>;

                                                  if (response['statusCode'] == 201 || response['statusCode'] == 200) {
                                                    if (!mounted) {
                                                      return;
                                                    }

                                                    context.push(
                                                      AppRoutes.verifyPhone,
                                                      extra: VerifyPhoneArgs(
                                                        type: VerificationType.signup,
                                                        phoneNumber: cleanPhone,
                                                        selectedRole: widget.selectedRole,
                                                        userId: data['userId']?.toString(),
                                                        initialOtp: data['otp']?.toString() ?? '123456',
                                                        password: _passwordController.text,
                                                      ),
                                                    );
                                                  } else {
                                                    if (!mounted) {
                                                      return;
                                                    }

                                                    messenger.showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          data['message']?.toString() ?? 'Sign up failed',
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
                                                      content: Text('Unable to sign up: $error'),
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
                                              'ចុះឈ្មោះ',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // --- Already have an account? Log In ---
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'មានគណនីរួចហើយមែនទេ? ',
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (context.canPop()) {
                                              context.pop();
                                            } else {
                                              context.go(AppRoutes.login);
                                            }
                                          },
                                          child: const Text(
                                            'ចូលគណនី',
                                            style: TextStyle(
                                              color: brandGreen,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper widget builder for form input fields
  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData prefixIcon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    Color fillColor = const Color(0xFFF3F4F6),
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
              prefixIcon: Icon(prefixIcon, color: const Color(0xFF0F6221), size: 20),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: fillColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF0F6221), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}