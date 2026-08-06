import 'package:flutter/material.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/features/auth/screens/forgot_password_screen.dart';
import 'package:mobile/features/auth/screens/get_started_screen.dart';
import 'package:mobile/features/auth/screens/role_selection_screen.dart';
import 'package:mobile/features/farmer/screens/farmer_dashboard_screen.dart';
import 'package:mobile/features/restaurant/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Shared Brand Design Tokens
    const primaryGreen = Color(0xFF156D27);
    const textDark = Color(0xFF0F172A);
    const textMuted = Color(0xFF475569);
    const bgLight = Color(0xFFF8FAFC);
    const borderColor = Color(0xFFCBD5E1);

    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Screen Breakpoint Checks
            final isDesktopOrTablet = constraints.maxWidth > 600;

            return Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktopOrTablet ? 24.0 : 0.0,
                    vertical: isDesktopOrTablet ? 32.0 : 0.0,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Container(
                      decoration: isDesktopOrTablet
                          ? BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                              border: Border.all(color: borderColor, width: 0.5),
                            )
                          : null,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(isDesktopOrTablet ? 24 : 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header + Form Content
                            Padding(
                              padding: EdgeInsets.all(isDesktopOrTablet ? 32.0 : 24.0),
                              child: Form(
                                key: _formKey,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // --- Navigation Back Button ---
                                    Row(
                                      children: [
                                        Material(
                                          color: isDesktopOrTablet ? bgLight : Colors.white,
                                          shape: const CircleBorder(),
                                          elevation: isDesktopOrTablet ? 0 : 2,
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
                                            radius: 60,
                                            backgroundColor: primaryGreen.withValues(alpha: 0.1),
                                            backgroundImage: const AssetImage('assets/logo01.png'),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'ផ្សារកសិករ',
                                            style: TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                              color: primaryGreen,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                                            child: Text(
                                              'ផ្សារផលិតផលកសិកម្មស្រស់ៗសម្រាប់ចុងភៅអាជីព។',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: textMuted,
                                                height: 1.3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 28),

                                    // --- Section Heading ---
                                    const Center(
                                      child: Text(
                                        'សូមស្វាគមន៍មកវិញ',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: textDark,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // --- Phone Number Input Field ---
                                    const Text(
                                      'លេខទូរស័ព្ទ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'សូមបញ្ចូលលេខទូរស័ព្ទ';
                                        }

                                        if (!RegExp(r'^(0|\+855)\d{8,9}$').hasMatch(value.trim())) {
                                          return 'លេខទូរស័ព្ទមិនត្រឹមត្រូវ';
                                        }

                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: '០១២៣៤៥៦៧៨៩ ឬ +855123456789',
                                        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        filled: true,
                                        fillColor: isDesktopOrTablet ? bgLight : Colors.white,
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
                                          'ពាក្យសម្ងាត់',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: textDark,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const ForgotPasswordScreen(),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'ភ្លេចពាក្យសម្ងាត់?',
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
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'សូមបញ្ចូលពាក្យសម្ងាត់';
                                        }

                                        if (value.length < 6) {
                                          return 'ពាក្យសម្ងាត់ត្រូវមានយ៉ាងហោចណាស់ ៦ តួអក្សរ';
                                        }

                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: '••••••••',
                                        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        filled: true,
                                        fillColor: isDesktopOrTablet ? bgLight : Colors.white,
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
                                      height: 52,
                                      child: ElevatedButton(
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
                                                  final response = await _authService.login(
                                                    phone: _phoneController.text.trim(),
                                                    password: _passwordController.text,
                                                  );
                                                  final data = response['data'] as Map<String, dynamic>;

                                                  final status = response['statusCode'] as int;
                                                  if (status >= 200 && status < 300) {
                                                    final user = data['user'] as Map<String, dynamic>;
                                                    final role = user['role']?.toString();
                                                    final userId = user['id']?.toString();

                                                    if (userId != null && userId.isNotEmpty) {
                                                      final prefs = await SharedPreferences.getInstance();
                                                      await prefs.setString('userId', userId);
                                                    }

                                                    if (!mounted) {
                                                      return;
                                                    }

                                                    navigator.pushReplacement(
                                                      MaterialPageRoute(
                                                        builder: (_) => role == 'farmer'
                                                            ? const FarmerDashboardScreen()
                                                            : const HomeScreen(),
                                                      ),
                                                    );
                                                  } else {
                                                    if (!mounted) {
                                                      return;
                                                    }

                                                    messenger.showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          data['message']?.toString() ?? 'Login failed',
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
                                                      content: Text('Unable to login: $error'),
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
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryGreen,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'ចូលប្រើប្រាស់',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(width: 6),
                                            Icon(Icons.chevron_right, size: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 28),

                                    // --- Custom "Or continue with" Divider ---
                                    const Row(
                                      children: [
                                        Expanded(child: Divider(color: borderColor, thickness: 1)),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                                          child: Text(
                                            'ឬបន្តជាមួយ',
                                            style: TextStyle(color: textMuted, fontSize: 13),
                                          ),
                                        ),
                                        Expanded(child: Divider(color: borderColor, thickness: 1)),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    // --- Social Sign-In Row ---
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(minHeight: 50),
                                            child: _buildSocialButton(
                                              label: 'Google',
                                              iconColor: Colors.red,
                                              iconData: Icons.g_mobiledata,
                                              isDesktop: isDesktopOrTablet,
                                              onTap: () {},
                                            ),    
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(minHeight: 50),
                                            child: _buildSocialButton(
                                              label: 'Facebook',
                                              iconColor: const Color(0xFF1877F2),
                                              iconData: Icons.facebook,
                                              isDesktop: isDesktopOrTablet,
                                              onTap: () {},
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // --- Footer Area ---
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
                                  const Text(
                                    "មិនទាន់មានគណនី? ",
                                    style: TextStyle(color: textMuted, fontSize: 14),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const RoleSelectionScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'បង្កើតគណនី',
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

  // Social Login Button Helper
  Widget _buildSocialButton({
    required String label,
    required IconData iconData,
    required Color iconColor,
    required bool isDesktop,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: isDesktop ? const Color(0xFFF8FAFC) : Colors.white,
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
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}