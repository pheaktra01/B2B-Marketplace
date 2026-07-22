import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/features/auth/screens/language_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine screen dimensions
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final isTabletOrDesktop = screenWidth > 600;

          // Dynamically scale logo and text based on smaller dimension
          final double shortestSide = constraints.biggest.shortestSide;
          
          // Clamp logo size: min 120px, max 320px
          final double logoSize = (shortestSide * 0.35).clamp(120.0, 320.0);
          
          // Clamp font size: min 28px, max 64px
          final double fontSize = (shortestSide * 0.08).clamp(28.0, 64.0);

          return Stack(
            children: [
              // 1. Background Image
              Positioned.fill(
                child: Image.asset(
                  'assets/background.png',
                  fit: BoxFit.cover,
                ),
              ),

              // 2. Responsive Gradient Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.green.shade900.withValues(alpha: 0.9),
                        Colors.green.shade900.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                      // Adjust gradient stops slightly for desktop vs mobile
                      stops: isTabletOrDesktop 
                          ? const [0.0, 0.4, 0.8] 
                          : const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Scaled Logo & Title
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        width: logoSize,
                        height: logoSize,
                      ),
                      SizedBox(height: screenHeight * 0.025), // Responsive spacing
                      Text(
                        'PsarKasekor',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          letterSpacing: isTabletOrDesktop ? 1.5 : 0.5,
                        ),
                      ),
                    ],
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