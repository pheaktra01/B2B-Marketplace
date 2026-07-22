import 'package:flutter/material.dart';
import 'package:mobile/features/auth/screens/language_selection_screen.dart';
import 'package:mobile/features/auth/screens/login_screen.dart';
import 'package:mobile/features/auth/screens/role_selection_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;

          // Scaled fonts and paddings
          final double titleFontSize = isDesktop ? 32 : (isTablet ? 30 : 26);
          final double bodyFontSize = isDesktop ? 16 : 14;

          return Stack(
            children: [
              // 1. Fullscreen Background Image
              Positioned.fill(
                child: Image.asset(
                  'assets/farm_background.png',
                  fit: BoxFit.cover,
                ),
              ),

              // 2. Dim Overlay for Desktop/Tablet contrast
              if (isTablet || isDesktop)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ),

              // 3. Back Button
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                child: SafeArea(
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LanguageSelectionScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // 4. White Card Content Panel
              Align(
                alignment: isTablet || isDesktop
                    ? Alignment.center
                    : Alignment.bottomCenter,
                child: Container(
                  width: isDesktop
                      ? 480
                      : isTablet
                          ? 440
                          : double.infinity,
                  height: isTablet || isDesktop
                      ? null // Automatic height driven by content on tablet/desktop
                      : constraints.maxHeight * 0.58, // Bottom sheet height on mobile
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop || isTablet ? 36.0 : 24.0,
                    vertical: isDesktop || isTablet ? 32.0 : 24.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: isTablet || isDesktop
                        ? BorderRadius.circular(28)
                        : const BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                    boxShadow: isTablet || isDesktop
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            )
                          ]
                        : null,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Page Indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildIndicator(active: true),
                            const SizedBox(width: 8),
                            _buildIndicator(active: false),
                          ],
                        ),
                        SizedBox(height: isDesktop || isTablet ? 28 : 20),

                        // Title
                        Text(
                          "Direct from the Soil to your Kitchen",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          "Connect with local farmers and source the freshest ingredients for your restaurant.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: bodyFontSize,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: isDesktop || isTablet ? 32 : 24),

                        // Get Started Button
                        SizedBox(
                          width: double.infinity,
                          height: isDesktop ? 56 : 52,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RoleSelectionScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: TextStyleCustom(
                              text: "Get Started",
                              fontSize: isDesktop ? 18 : 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: isDesktop ? 56 : 52,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.green, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: TextStyleCustom(
                              text: "Login",
                              fontSize: isDesktop ? 18 : 16,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: isDesktop || isTablet ? 28 : 20),

                        // Social Proof / Trust
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified, size: 18, color: Colors.green.shade700),
                            const SizedBox(width: 6),
                            Text(
                              "Trusted by 500+ Top Chefs",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Footer Disclaimer
                        Text(
                          "By continuing, you agree to our Terms & Privacy Policy",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIndicator({required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? Colors.green : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// Helper widget for clean text styling inside buttons
class TextStyleCustom extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

  const TextStyleCustom({
    super.key,
    required this.text,
    required this.fontSize,
    required this.color,
    required this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
    );
  }
}