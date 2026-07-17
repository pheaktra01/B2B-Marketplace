import 'package:flutter/material.dart';
import 'package:mobile/features/auth/screens/forgot_password_screen.dart';
import 'package:mobile/features/auth/screens/get_started_screen.dart';
import 'package:mobile/features/auth/screens/role_selection_screen.dart';
import 'package:mobile/features/auth/screens/verify_phone_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Shared Brand Design Tokens
    const primaryGreen = Color(0xFF156D27); // Darker rich green used on this button/text
    const textDark = Color(0xFF0F172A);
    const textMuted = Color(0xFF475569);
    const bgLight = Color(0xFFF8FAFC);
    const borderColor = Color(0xFFCBD5E1);

    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Main scrollable content body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Material(
                            color: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 20,
                                color: textDark,
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const GetStartedScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // --- Logo & Brand Identity ---
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: primaryGreen.withValues(alpha: 0.1),
                              child: const Icon(Icons.eco, size: 50, color: primaryGreen),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'PsarKasekor',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text(
                                'Fresh produce marketplace for professional kitchens.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: textMuted,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- Section Heading ---
                      const Center(
                        child: Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // --- Phone Number Input Field ---
                      const Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: '0123456789',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: borderColor, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: primaryGreen, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- Password Label with Forgot Action ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForgotPasswordScreen(), // Navigate to ForgotPasswordScreen
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // --- Password Input Field ---
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.lock_outline, color: textMuted, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: textMuted,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: borderColor, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: primaryGreen, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Login Button ---
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Execute authentication workflow 
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VerifyPhoneScreen(
                                  type: VerificationType.login,
                                  phoneNumber: _phoneController.text,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Login',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.chevron_right, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- Custom "Or continue with" Divider ---
                      Row(
                        children: const [
                          Expanded(child: Divider(color: borderColor, thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(color: textMuted, fontSize: 14),
                            ),
                          ),
                          Expanded(child: Divider(color: borderColor, thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // --- Social Sign-In Row ---
                      Row(
                        children: [
                          Expanded(
                            child: _buildSocialButton(
                              label: 'Google',
                              iconColor: Colors.red,
                              iconData: Icons.g_mobiledata, // Fallback icon frame
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSocialButton(
                              label: 'Facebook',
                              iconColor: const Color(0xFF1877F2),
                              iconData: Icons.facebook,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- Sticky Footer Area ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9), // Slight tint break for footer card background
                border: Border(
                  top: BorderSide(color: borderColor, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: textMuted, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoleSelectionScreen(), // Navigate to RoleSelectionScreen
                        ),
                      );
                    },
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Social Login Button Builder Helper
  Widget _buildSocialButton({
    required String label,
    required IconData iconData,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, color: iconColor, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}