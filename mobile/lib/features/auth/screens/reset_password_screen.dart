import 'package:flutter/material.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/features/auth/screens/login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phoneNumber;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.phoneNumber,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Validation states for password dynamic checklist
  bool _isLongEnough = false;
  bool _hasNumberOrSymbol = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePasswordRules);
  }

  void _validatePasswordRules() {
    final text = _passwordController.text;
    setState(() {
      _isLongEnough = text.length >= 8;
      _hasNumberOrSymbol = text.contains(RegExp(r'[0-9!@#\$&*~+-=_\^%()]'));
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePasswordRules);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF0F6221);
    const inputFillColor = Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // --- Custom Top App Bar ---
            Container(
              color: Colors.white,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: brandGreen.withValues(alpha: 0.1),
                              backgroundImage: const AssetImage('assets/logo01.png'),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'ផ្សារកសិករ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: brandGreen,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            // Support action
                          },
                          child: const Text(
                            'ជំនួយ',
                            style: TextStyle(
                              color: brandGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --- Screen Content Container ---
            Expanded(
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
                        // Restricts card width on tablets/desktop
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 16.0 : 20.0,
                            vertical: isShortScreen ? 24.0 : 32.0,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'កំណត់ពាក្យសម្ងាត់ឡើងវិញ',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'សូមបង្កើតពាក្យសម្ងាត់ផ្ទាល់ខ្លួនដែលអ្នកមិនបានប្រើប្រាស់នៅកន្លែងផ្សេង។',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                    height: 1.4,
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // --- New Password Field ---
                                const Text(
                                  'ពាក្យសម្ងាត់ថ្មី',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: _buildInputDecoration(
                                    hint: 'បញ្ចូលពាក្យសម្ងាត់ថ្មី',
                                    prefixIcon: Icons.lock_outline,
                                    fillColor: inputFillColor,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.black54,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword = !_obscurePassword,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // --- Confirm Password Field ---
                                const Text(
                                  'បញ្ជាក់ពាក្យសម្ងាត់ថ្មី',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  decoration: _buildInputDecoration(
                                    hint: 'បញ្ជាក់ពាក្យសម្ងាត់ថ្មី',
                                    prefixIcon: Icons.verified_user_outlined,
                                    fillColor: inputFillColor,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.black54,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscureConfirmPassword = !_obscureConfirmPassword,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value != _passwordController.text) {
                                      return 'ពាក្យសម្ងាត់មិនត្រូវគ្នាតែមួយទេ';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // --- Dynamic Requirement Checklists ---
                                _buildRequirementRow(
                                  'យ៉ាងហោចណាស់ ៨ តួអក្សរ',
                                  _isLongEnough,
                                  brandGreen,
                                ),
                                const SizedBox(height: 8),
                                _buildRequirementRow(
                                  'មានយ៉ាងហោចណាស់លេខមួយ ឬនិមិត្តសញ្ញាមួយ',
                                  _hasNumberOrSymbol,
                                  brandGreen,
                                ),

                                const SizedBox(height: 28),

                                // --- Reset Password Button ---
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
                                            if (!_formKey.currentState!.validate() ||
                                                !_isLongEnough ||
                                                !_hasNumberOrSymbol) {
                                              return;
                                            }

                                            final navigator = Navigator.of(context);
                                            final messenger = ScaffoldMessenger.of(context);

                                            setState(() {
                                              _isLoading = true;
                                            });

                                            try {
                                              final response = await _authService.resetPassword(
                                                phone: widget.phoneNumber,
                                                otp: widget.otp,
                                                password: _passwordController.text,
                                              );
                                              final data = response['data'] as Map<String, dynamic>;

                                              final status = response['statusCode'] as int;
                                              if (status >= 200 && status < 300) {
                                                if (!mounted) {
                                                  return;
                                                }

                                                navigator.pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                    builder: (_) => const LoginScreen(),
                                                  ),
                                                  (route) => false,
                                                );
                                              } else {
                                                if (!mounted) {
                                                  return;
                                                }

                                                messenger.showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      data['message']?.toString() ?? 'Reset password failed',
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
                                                  content: Text('Unable to reset password: $error'),
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
                                          'កំណត់ពាក្យសម្ងាត់ឡើងវិញ',
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

                                const SizedBox(height: 24),

                                // --- Bottom Return Option ---
                                Align(
                                  alignment: Alignment.center,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'បោះបង់ ហើយត្រឡប់ទៅទំព័រចូល',
                                      style: TextStyle(
                                        color: brandGreen,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Common UI styling rules for TextFields
  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData prefixIcon,
    required Color fillColor,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.black38,
        fontSize: 13,
        letterSpacing: 0.5,
      ),
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
    );
  }

  // Row helper widget to draw requirement parameters
  Widget _buildRequirementRow(String text, bool isMet, Color successColor) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isMet ? successColor : Colors.black38,
              width: 1.5,
            ),
            color: isMet ? successColor.withAlpha(40) : Colors.transparent,
          ),
          child: isMet
              ? Icon(Icons.check, size: 10, color: successColor)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isMet ? Colors.black87 : Colors.black54,
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}