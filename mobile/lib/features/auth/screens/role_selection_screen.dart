import 'package:flutter/material.dart';
import 'package:mobile/features/auth/screens/get_started_screen.dart';
import 'package:mobile/features/auth/screens/login_screen.dart';
import 'package:mobile/features/auth/screens/sign_up_screen.dart';

// Import LoginScreen if it exists in your project
// import 'login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  // Track selected role: 'restaurant', 'farmer', or null
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    // Brand Colors matching the UI design
    const primaryGreen = Color(0xFF2E9546);
    const textDark = Color(0xFF0F172A);
    const textMuted = Color(0xFF475569);
    const bgLight = Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
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

              // --- Logo & Brand Name ---
              Center(
                child: Column(
                  children: [
                    // Replace with your real asset or network image
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: primaryGreen.withValues(alpha: 0.1),
                      child: const Icon(Icons.eco, size: 50, color: primaryGreen),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'PsarKasekor',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- Heading Texts ---
              const Text(
                'How will you use PsarKasekor?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Join our premium agricultural network. Choose your role to personalize your experience.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // --- Restaurant Role Card ---
              _buildRoleCard(
                id: 'restaurant',
                icon: Icons.restaurant,
                title: 'I am a Restaurant',
                description: 'Sourcing the freshest ingredients directly from local producers with reliable logistics.',
                tags: ['Buyer', 'Kitchen'],
                isSelected: _selectedRole == 'restaurant',
                primaryColor: primaryGreen,
              ),
              const SizedBox(height: 20),

              // --- Farmer Role Card ---
              _buildRoleCard(
                id: 'farmer',
                icon: Icons.agriculture, // Using tractor/agriculture icon
                title: 'I am a Farmer',
                description: 'Showcasing my bountiful harvest to top professional kitchens and managing wholesale orders.',
                tags: ['Seller', 'Producer'],
                isSelected: _selectedRole == 'farmer',
                primaryColor: primaryGreen,
              ),
              const SizedBox(height: 40),

              // --- Continue Button ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedRole == null
                      ? null // Disabled if no selection
                      : () {
                          // Handle navigation or setup logic here
                          // ignore: avoid_print
                          print('Selected Role: $_selectedRole');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedRole != null ? primaryGreen : const Color(0xFFE2E8F0),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                    disabledForegroundColor: textMuted.withValues(alpha: 0.6),
                    elevation: _selectedRole != null ? 2 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Continue',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Footer ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: textMuted, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Helper builder for custom interactive Role Cards
  Widget _buildRoleCard({
    required String id,
    required IconData icon,
    required String title,
    required String description,
    required List<String> tags,
    required bool isSelected,
    required Color primaryColor,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = id;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAE6DA), // Light vintage tint from image
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF4A5D4E), size: 28),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            // Description Text
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            // Dynamic Pills/Tags row
            Wrap(
              spacing: 8,
              children: tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2F7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4A5568),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}