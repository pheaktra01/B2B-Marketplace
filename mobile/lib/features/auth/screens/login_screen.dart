import 'package:flutter/material.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/features/auth/screens/forgot_password_screen.dart';
import 'package:mobile/features/auth/screens/get_started_screen.dart';
import 'package:mobile/features/farmer/screens/farmer_dashboard_screen.dart';
import 'package:mobile/features/restaurant/screens/home_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

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
                              border: Border.all(
                                color: borderColor,
                                width: 0.5,
                              ),
                            )
                          : null,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          isDesktopOrTablet ? 24 : 0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(
                                isDesktopOrTablet ? 32.0 : 24.0,
                              ),
                              child: Form(
                                key: _formKey,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Back button
                                    Row(
                                      children: [
                                        Material(
                                          color: isDesktopOrTablet
                                              ? bgLight
                                              : Colors.white,
                                          shape: const CircleBorder(),
                                          elevation:
                                              isDesktopOrTablet ? 0 : 2,
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
                                                  builder: (context) =>
                                                      const GetStartedScreen(),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Logo & Brand
                                    Center(
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 60,
                                            backgroundColor:
                                                primaryGreen.withValues(
                                              alpha: 0.1,
                                            ),
                                            backgroundImage:
                                                const AssetImage(
                                              'assets/logo01.png',
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            l10n.farmersMarket,
                                            style: const TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                              color: primaryGreen,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                            ),
                                            child: Text(
                                              l10n.farmersMarketDescription,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
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

                                    // Welcome Back
                                    Center(
                                      child: Text(
                                        l10n.welcomeBack,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: textDark,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Phone Number
                                    Text(
                                      l10n.phoneNumber,
                                      style: const TextStyle(
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
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return l10n
                                              .pleaseEnterPhoneNumber;
                                        }

                                        if (!RegExp(
                                          r'^(0|\+855)\d{8,9}$',
                                        ).hasMatch(value.trim())) {
                                          return l10n.invalidPhoneNumber;
                                        }

                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: '+855123456789',
                                        hintStyle: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        filled: true,
                                        fillColor: isDesktopOrTablet
                                            ? bgLight
                                            : Colors.white,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: borderColor,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: primaryGreen,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // Password + Forgot Password
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          l10n.password,
                                          style: const TextStyle(
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
                                                builder: (context) =>
                                                    const ForgotPasswordScreen(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            l10n.forgotPassword,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: primaryGreen,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // Password
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty) {
                                          return l10n.pleaseEnterPassword;
                                        }

                                        if (value.length < 6) {
                                          return l10n.passwordMinLength;
                                        }

                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: '••••••••',
                                        hintStyle: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        filled: true,
                                        fillColor: isDesktopOrTablet
                                            ? bgLight
                                            : Colors.white,
                                        prefixIcon: const Icon(
                                          Icons.lock_outline,
                                          color: textMuted,
                                          size: 20,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons
                                                    .visibility_off_outlined,
                                            color: textMuted,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: borderColor,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: primaryGreen,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Login Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: _isLoading
                                            ? null
                                            : _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryGreen,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              l10n.login,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Icon(
                                              Icons.chevron_right,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 28),

                                    // Divider
                                    Row(
                                      children: [
                                        const Expanded(
                                          child: Divider(
                                            color: borderColor,
                                            thickness: 1,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                          ),
                                          child: Text(
                                            l10n.orContinueWith,
                                            style: const TextStyle(
                                              color: textMuted,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        const Expanded(
                                          child: Divider(
                                            color: borderColor,
                                            thickness: 1,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    // Social Sign-In placeholder
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ConstrainedBox(
                                            constraints:
                                                const BoxConstraints(
                                              minHeight: 50,
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

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
    });

    print('========== LOGIN BUTTON PRESSED ==========');
    print('Phone: ${_phoneController.text.trim()}');

    try {
      final response = await _authService.login(
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      final data = response['data'] as Map<String, dynamic>;
      final status = response['statusCode'] as int;

      print('========== LOGIN RESULT ==========');
      print('Status: $status');
      print('Message: ${data['message']}');

      if (status >= 200 && status < 300) {
        final user = data['user'] as Map<String, dynamic>;

        final role = user['role']?.toString();
        final userId = user['id']?.toString();

        print('Login successful');
        print('User ID: $userId');
        print('Role: $role');

        if (userId != null && userId.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);
        }

        if (!mounted) return;

        if (role == 'farmer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const FarmerDashboardScreen(),
            ),
          );
        } else if (role == 'restaurant') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.unknownUserRole),
            ),
          );
        }
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message']?.toString() ?? l10n.loginFailed,
            ),
          ),
        );
      }
    } catch (error) {
      print('LOGIN ERROR: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.unableToLogin}: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}