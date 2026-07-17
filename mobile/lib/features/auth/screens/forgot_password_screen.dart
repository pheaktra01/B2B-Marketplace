import 'package:flutter/material.dart';
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
      backgroundColor: const Color(0xFFF9FAFB), // Soft off-white canvas
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Logo ---
                // Replace with your asset image when ready: Image.asset('assets/logo.png')
                CircleAvatar(
                  radius: 45,
                  backgroundColor: brandGreen.withAlpha(30),
                  child: const Icon(Icons.restaurant_menu, size: 45, color: brandGreen),
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

                // --- Main Container Card ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Forgot Password',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Enter the email address associated with your Verdant account. We'll send you a link to reset your password and get you back to your professional dashboard.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
                        ),
                        
                        const SizedBox(height: 28),
                        
                        // --- Email/Phone Input Field ---
                        const Text(
                          'Email or phone number',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _identifierController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'name@central-kitchen.com',
                            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                            prefixIcon: const Icon(Icons.mail_outline, color: Colors.black45, size: 20),
                            filled: true,
                            fillColor: inputFillColor,
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
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email or phone number';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 20),

                        // --- Send Button ---
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 1,
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Trigger forgot password logic / API call
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VerifyPhoneScreen(
                                    type: VerificationType.forgotPassword,
                                    phoneNumber: phone,
                                  ),
                                ),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Send', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

                const SizedBox(height: 32),

                // --- Back to Login Link ---
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(), // Navigate back to LoginScreen
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_back, size: 18, color: Colors.black54),
                  label: const Text(
                    'Back to Login',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}