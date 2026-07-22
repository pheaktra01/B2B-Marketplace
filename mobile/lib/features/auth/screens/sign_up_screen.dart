import 'package:flutter/material.dart';
import 'package:mobile/features/auth/screens/login_screen.dart';
import 'package:mobile/features/auth/screens/role_selection_screen.dart';
import 'package:mobile/features/auth/screens/verify_phone_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

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
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const RoleSelectionScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // --- Logo & Title ---
                                    CircleAvatar(
                                      radius: 42,
                                      backgroundColor: brandGreen.withValues(alpha: 0.1),
                                      child: const Icon(
                                        Icons.restaurant_menu,
                                        size: 42,
                                        color: brandGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      'PsarKesekor',
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: brandGreen,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Fresh produce marketplace for\nprofessional kitchens.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.3),
                                    ),

                                    const SizedBox(height: 28),
                                    const Text(
                                      'Create Your Account',
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Join the elite network of professional agricultural trade.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.3),
                                    ),

                                    const SizedBox(height: 28),

                                    // --- Dynamic Form Grid Layout ---
                                    if (isWide) ...[
                                      // 2-Column Row 1: Name & Email
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInputField(
                                              label: 'Full Name',
                                              hint: 'Enter full name',
                                              prefixIcon: Icons.person_outline,
                                              controller: _nameController,
                                              fillColor: inputFill,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildInputField(
                                              label: 'Email',
                                              hint: 'email@business.com',
                                              prefixIcon: Icons.mail_outline,
                                              controller: _emailController,
                                              keyboardType: TextInputType.emailAddress,
                                              fillColor: inputFill,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // 2-Column Row 2: Phone & Enterprise
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInputField(
                                              label: 'Phone number',
                                              hint: '+0123456789',
                                              prefixIcon: Icons.phone_outlined,
                                              controller: _phoneController,
                                              keyboardType: TextInputType.phone,
                                              fillColor: inputFill,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildInputField(
                                              label: 'Restaurant / Farm Name',
                                              hint: 'Enterprise name',
                                              prefixIcon: Icons.storefront_outlined,
                                              controller: _enterpriseController,
                                              fillColor: inputFill,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // 2-Column Row 3: Passwords
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInputField(
                                              label: 'Password',
                                              hint: 'Password',
                                              prefixIcon: Icons.lock_outline,
                                              controller: _passwordController,
                                              obscureText: _obscurePassword,
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
                                              label: 'Confirm Password',
                                              hint: 'Confirm Password',
                                              prefixIcon: Icons.lock_outline,
                                              controller: _confirmPasswordController,
                                              obscureText: _obscureConfirmPassword,
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
                                        label: 'Full Name',
                                        hint: 'Enter your full name',
                                        prefixIcon: Icons.person_outline,
                                        controller: _nameController,
                                        fillColor: inputFill,
                                      ),
                                      _buildInputField(
                                        label: 'Email',
                                        hint: 'email@business.com',
                                        prefixIcon: Icons.mail_outline,
                                        controller: _emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        fillColor: inputFill,
                                      ),
                                      _buildInputField(
                                        label: 'Phone number',
                                        hint: '+0123456789',
                                        prefixIcon: Icons.phone_outlined,
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        fillColor: inputFill,
                                      ),
                                      _buildInputField(
                                        label: 'Restaurant name/Farm name',
                                        hint: 'Name of your enterprise',
                                        prefixIcon: Icons.storefront_outlined,
                                        controller: _enterpriseController,
                                        fillColor: inputFill,
                                      ),
                                      _buildInputField(
                                        label: 'Password',
                                        hint: 'Password',
                                        prefixIcon: Icons.lock_outline,
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
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
                                        label: 'Confirm Password',
                                        hint: 'Confirm Password',
                                        prefixIcon: Icons.lock_outline,
                                        controller: _confirmPasswordController,
                                        obscureText: _obscureConfirmPassword,
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
                                      crossAxisAlignment: CrossAlignmentCheck(isDesktopOrTablet),
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
                                                TextSpan(text: 'I agree to the '),
                                                TextSpan(
                                                  text: 'Terms of Service',
                                                  style: TextStyle(
                                                    color: brandGreen,
                                                    fontWeight: FontWeight.w600,
                                                    decoration: TextDecoration.underline,
                                                  ),
                                                ),
                                                TextSpan(text: ' and '),
                                                TextSpan(
                                                  text: 'Privacy Policy.',
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
                                        onPressed: () {
                                          if (_formKey.currentState!.validate() && _agreedToTerms) {
                                            // Registration logic
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => VerifyPhoneScreen(
                                                type: VerificationType.signup,
                                                phoneNumber: _phoneController.text,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Sign Up',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

                            // --- Footer Navigation ---
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                border: Border(
                                  top: BorderSide(color: borderColor, width: 0.5),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Already have an account? ', style: TextStyle(color: Colors.black54)),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        color: brandGreen,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
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

  // Cross Alignment Helper
  // ignore: non_constant_identifier_names
  static CrossAxisAlignment CrossAlignmentCheck(bool isDesktop) {
    return isDesktop ? CrossAxisAlignment.center : CrossAxisAlignment.start;
  }

  // Input Field Helper Component
  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData prefixIcon,
    required TextEditingController controller,
    required Color fillColor,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
              prefixIcon: Icon(prefixIcon, color: Colors.black45, size: 20),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: fillColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
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