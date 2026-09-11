import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/features/auth/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Remove the native OS splash screen once Flutter starts rendering
    FlutterNativeSplash.remove();

    // Initialize smooth entrance animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();

    // Start auto-login and navigation check
    _checkAutoLogin();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAutoLogin() async {
    try {
      // Allow user to see the animated splash brand (2 seconds total)
      await Future.delayed(const Duration(milliseconds: 2000));
      if (!mounted) return;

      final isValid = await AuthService.isTokenValid();
      final role = await AuthService.getUserRole();

      debugPrint('SPLASH AUTO-LOGIN CHECK: isValid=$isValid, role=$role');

      if (!mounted) return;

      if (isValid && role != null && role.isNotEmpty) {
        if (role == 'farmer') {
          context.go(AppRoutes.farmerDashboard);
          return;
        } else if (role == 'restaurant') {
          context.go(AppRoutes.restaurantHome);
          return;
        }
      }

      // Not authenticated: navigate to onboarding / language selection
      context.go(AppRoutes.language);
    } catch (e) {
      debugPrint('Error during auto-login check: $e');
      if (!mounted) return;
      context.go(AppRoutes.language);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isTabletOrDesktop = screenWidth > 600;
          final double shortestSide = constraints.biggest.shortestSide;

          final double logoSize = (shortestSide * 0.35).clamp(110.0, 240.0);
          final double titleFontSize = (shortestSide * 0.08).clamp(28.0, 48.0);
          final double subtitleFontSize = (shortestSide * 0.038).clamp(13.0, 18.0);

          return Stack(
            children: [
              // 1. Background Image
              Positioned.fill(
                child: Image.asset(
                  'assets/background.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF0F5A27), Color(0xFF072A12)],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 2. Gradient Overlay for Visual Depth & Readability
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        const Color(0xFF072A12).withValues(alpha: 0.94),
                        const Color(0xFF0F5A27).withValues(alpha: 0.72),
                        const Color(0xFF0F5A27).withValues(alpha: 0.35),
                      ],
                      stops: isTabletOrDesktop
                          ? const [0.0, 0.45, 0.85]
                          : const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Animated Brand Logo, Title & Tagline
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo with soft ambient glow
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/logo.png',
                              width: logoSize,
                              height: logoSize,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.eco_rounded,
                                  size: logoSize * 0.8,
                                  color: Colors.white,
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          // App Title
                          Text(
                            'PsarKasekor',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w800,
                              letterSpacing: isTabletOrDesktop ? 1.5 : 0.8,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Tagline
                          Text(
                            'Fresh From Farm to Kitchen',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Subtle loading indicator
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Footer Version Label
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                      letterSpacing: 0.8,
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
}