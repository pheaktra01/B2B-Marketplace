import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/core/routing/route_args.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/features/auth/screens/verify_phone_screen.dart';
import 'package:mobile/features/auth/widgets/auth_language_switch.dart';
import 'package:mobile/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
                      // --- Top Bar (Back Button & Language Switch) ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go(AppRoutes.login);
                                }
                              },
                            ),
                          ),
                          const AuthLanguageSwitch(),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // --- Logo & Branding Header ---
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: brandGreen.withValues(alpha: 0.1),
                            backgroundImage: const AssetImage('assets/logo01.png'),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.farmersMarket,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: brandGreen,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.farmersMarketDescription,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
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
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  l10n.forgotPasswordTitle,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.forgotPasswordInstruction,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // --- Input Field ---
                              Text(
                                l10n.phoneNumber,
                                style: const TextStyle(
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
                                  hintText: l10n.phoneHint,
                                  hintStyle: const TextStyle(
                                    color: Colors.black38,
                                    fontSize: 14,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.phone_outlined,
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
                                    return l10n.pleaseEnterPhoneNumber;
                                  }

                                  if (!RegExp(r'^(0|\+855)\d{8,9}$').hasMatch(value.trim())) {
                                    return l10n.invalidPhoneNumber;
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

                                          Navigator.of(context);
                                          final messenger = ScaffoldMessenger.of(context);

                                          setState(() {
                                            _isLoading = true;
                                          });

                                          try {
                                            final response = await _authService.forgotPassword(
                                              phone: _identifierController.text.trim(),
                                            );
                                            final data = response['data'] as Map<String, dynamic>;

                                            final status = response['statusCode'] as int;
                                            if (status >= 200 && status < 300) {
                                              if (!context.mounted) {
                                                return;
                                              }

                                              context.push(
                                                AppRoutes.verifyPhone,
                                                extra: VerifyPhoneArgs(
                                                  type: VerificationType.forgotPassword,
                                                  phoneNumber: _identifierController.text.trim(),
                                                  initialOtp: data['otp']?.toString(),
                                                ),
                                              );
                                            } else {
                                              if (!mounted) {
                                                return;
                                              }

                                              messenger.showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    data['message']?.toString() ?? l10n.unableToRequestOtp,
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
                                                content: Text('${l10n.unableToRequestOtp}: $error'),
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
                                        l10n.send,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_ios, size: 16),
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
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutes.login);
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 18,
                            color: Colors.black54,
                          ),
                          label: Text(
                            l10n.backToLogin,
                            style: const TextStyle(
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