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
    // Custom deep green branding color from your logo/button
    const brandGreen = Color(0xFF0F6221); 
    const inputFillColor = Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  ],
                ),

                const SizedBox(height: 16),

                // Placeholder for Logo Image
                CircleAvatar(
                  radius: 45,
                  backgroundColor: brandGreen.withAlpha(30),
                  child: const Icon(
                    Icons.restaurant_menu,
                    size: 45,
                    color: brandGreen,
                  ),
                ),
                
                const SizedBox(height: 16),
                const Text(
                  'PsarKesekor',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: brandGreen,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fresh produce marketplace for\nprofessional kitchens.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.3),
                ),
                
                const SizedBox(height: 32),
                const Text(
                  'Create Your Account',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Join the elite network of professional\nagricultural trade.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.3),
                ),
                
                const SizedBox(height: 32),

                // --- Form Fields ---
                _buildInputField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outline,
                  controller: _nameController,
                  fillColor: inputFillColor,
                ),
                _buildInputField(
                  label: 'Email',
                  hint: 'email@business.com',
                  prefixIcon: Icons.mail_outline,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  fillColor: inputFillColor,
                ),
                _buildInputField(
                  label: 'Phone number',
                  hint: '+0123456789',
                  prefixIcon: Icons.phone_outlined,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  fillColor: inputFillColor,
                ),
                _buildInputField(
                  label: 'Restaurant name/Farm name',
                  hint: 'Name of your enterprise',
                  prefixIcon: Icons.storefront_outlined,
                  controller: _enterpriseController,
                  fillColor: inputFillColor,
                ),
                _buildInputField(
                  label: 'Password',
                  hint: 'Password',
                  prefixIcon: Icons.lock_outline,
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  fillColor: inputFillColor,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
                  fillColor: inputFillColor,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.black54,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),

                // --- Terms and Conditions Checkbox ---
                Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      activeColor: brandGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of\nService',
                              style: const TextStyle(color: brandGreen, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy.',
                              style: const TextStyle(color: brandGreen, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
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
                      elevation: 2,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _agreedToTerms) {
                        // Implement form submission / registration API call here
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
                        Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(color: Colors.black12, thickness: 1),
                const SizedBox(height: 16),

                // --- Bottom Navigation Navigation ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account ', style: TextStyle(color: Colors.black54)),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(), // Navigate to LoginScreen
                          ),
                        );
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                      child: const Text(
                        'Login',
                        style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper builder widget to reduce code duplication for inputs
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
      padding: const EdgeInsets.only(bottom: 20.0),
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
                borderSide: const BorderSide(color: Colors.black12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black26, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}