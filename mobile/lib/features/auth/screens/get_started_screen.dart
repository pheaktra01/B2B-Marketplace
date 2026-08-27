import 'package:flutter/material.dart';
import 'package:mobile/features/auth/screens/login_screen.dart';
import 'package:mobile/features/auth/screens/role_selection_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    const primaryGreen = Color(0xFF1B7A32);
    const accentOrange = Color(0xFFFF9800);
    const textDark = Color(0xFF1F2937);
    const textMuted = Color(0xFF5B6472);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 900;

          final titleFontSize =
              isDesktop ? 34.0 : (isTablet ? 30.0 : 28.0);

          final bodyFontSize = isDesktop ? 17.0 : 15.0;

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/farm_background.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),

              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.04),
                        Colors.white.withValues(alpha: 0.16),
                        Colors.white.withValues(alpha: 0.62),
                        Colors.white.withValues(alpha: 0.96),
                      ],
                      stops: const [0.0, 0.48, 0.78, 1.0],
                    ),
                  ),
                ),
              ),

              // Logo
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 36 : 22,
                      isDesktop ? 20 : 14,
                      22,
                      0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/logo01.png',
                          width: isDesktop ? 92 : 50,
                          height: isDesktop ? 92 : 50,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'PsarKasekor',
                          style: TextStyle(
                            fontSize: isDesktop ? 38 : 30,
                            fontWeight: FontWeight.w700,
                            color: primaryGreen,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              Align(
                alignment: isTablet || isDesktop
                    ? Alignment.center
                    : Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 36 : 18,
                    0,
                    isDesktop ? 36 : 18,
                    isDesktop ? 36 : 0,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Container(
                      width: double.infinity,
                      height: isTablet || isDesktop
                          ? null
                          : constraints.maxHeight * 0.6,
                      padding: EdgeInsets.fromLTRB(
                        isDesktop || isTablet ? 36 : 24,
                        isDesktop || isTablet ? 30 : 24,
                        isDesktop || isTablet ? 36 : 24,
                        isDesktop || isTablet ? 34 : 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.98),
                        borderRadius: isTablet || isDesktop
                            ? BorderRadius.circular(30)
                            : const BorderRadius.only(
                                topLeft: Radius.circular(42),
                                topRight: Radius.circular(42),
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Page indicators
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildIndicator(active: true),
                                const SizedBox(width: 8),
                                _buildIndicator(active: false),
                                const SizedBox(width: 8),
                                _buildIndicator(active: false),
                              ],
                            ),

                            SizedBox(
                              height: isTablet || isDesktop ? 30 : 22,
                            ),

                            // Title
                            ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 360),
                              child: Text(
                                l10n.getStartedTitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w800,
                                  color: textDark,
                                  height: 1.22,
                                  letterSpacing: -0.6,
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Description
                            ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 380),
                              child: Text(
                                l10n.getStartedDescription,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: bodyFontSize,
                                  color: textMuted,
                                  height: 1.55,
                                ),
                              ),
                            ),

                            SizedBox(
                              height: isTablet || isDesktop ? 34 : 26,
                            ),

                            // Get Started button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RoleSelectionScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentOrange,
                                  foregroundColor: Colors.white,
                                  elevation: 6,
                                  shadowColor: accentOrange.withValues(
                                    alpha: 0.35,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(18),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    TextStyleCustom(
                                      text: l10n.getStarted,
                                      fontSize: isDesktop ? 18 : 17,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Login button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen(),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: primaryGreen,
                                    width: 2.2,
                                  ),
                                  foregroundColor: primaryGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(18),
                                  ),
                                ),
                                child: TextStyleCustom(
                                  text: l10n.login,
                                  fontSize: isDesktop ? 18 : 17,
                                  color: primaryGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                            SizedBox(
                              height: isTablet || isDesktop ? 30 : 24,
                            ),

                            // Trust section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildTrustDot(
                                  const Color(0xFFE8E7D6),
                                ),
                                const SizedBox(width: 8),
                                _buildTrustDot(
                                  const Color(0xFFC8F4B8),
                                ),
                                const SizedBox(width: 8),
                                _buildTrustDot(
                                  const Color(0xFFF7DDC8),
                                ),
                                const SizedBox(width: 14),
                                Flexible(
                                  child: Text(
                                    l10n.trustedChefs,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // Terms and privacy
                            Text(
                              l10n.termsPrivacy,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
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
      width: active ? 26 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF1B7A32)
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildTrustDot(Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
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