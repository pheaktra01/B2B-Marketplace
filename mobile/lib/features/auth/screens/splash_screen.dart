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
    // Navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. The Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // 2. The Fading Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.green.shade900.withValues(alpha: 0.9),
                  Colors.green.shade900.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // 3. The Logo and Title
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  '/logo.png',
                  width: 300,
                  height: 300,
                ),
                const SizedBox(height: 20),
                const Text(
                  'PsarKasekor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}