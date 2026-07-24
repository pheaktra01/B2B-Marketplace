import 'package:flutter/material.dart';
import 'package:mobile/features/auth/screens/get_started_screen.dart';
import 'package:mobile/features/auth/screens/login_screen.dart';
import 'package:mobile/features/auth/screens/sign_up_screen.dart';

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;

            // Constrain content width so it doesn't stretch infinitely on wide monitors
            final double maxContentWidth = isDesktop ? 800 : (isTablet ? 650 : double.infinity);

            // Responsive typography
            final double titleFontSize = isDesktop ? 32 : (isTablet ? 28 : 24);
            final double bodyFontSize = isDesktop ? 16 : 15;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop || isTablet ? 32.0 : 24.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // --- Back Button ---
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Material(
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
                      ),

                      const SizedBox(height: 16),

                      // --- Logo & Brand Name ---
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: isDesktop ? 50 : 45,
                              backgroundColor: primaryGreen.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.eco,
                                size: isDesktop ? 56 : 50,
                                color: primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'PsarKasekor',
                              style: TextStyle(
                                fontSize: titleFontSize + 4,
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isDesktop ? 36 : 28),

                      // --- Heading Texts ---
                      Text(
                        'How will you use PsarKasekor?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Join our premium agricultural network. Choose your role to personalize your experience.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: bodyFontSize,
                          color: textMuted,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 40 : 32),

                      // --- Role Cards (Side-by-Side on Tablet/Desktop, Stacked on Mobile) ---
                      if (isTablet || isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildRoleCard(
                                id: 'restaurant',
                                icon: Icons.restaurant,
                                title: 'I am a Restaurant',
                                description:
                                    'Sourcing the freshest ingredients directly from local producers with reliable logistics.',
                                tags: ['Buyer', 'Kitchen'],
                                isSelected: _selectedRole == 'restaurant',
                                primaryColor: primaryGreen,
                                isDesktop: isDesktop,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildRoleCard(
                                id: 'farmer',
                                icon: Icons.agriculture,
                                title: 'I am a Farmer',
                                description:
                                    'Showcasing my bountiful harvest to top professional kitchens and managing wholesale orders.',
                                tags: ['Seller', 'Producer'],
                                isSelected: _selectedRole == 'farmer',
                                primaryColor: primaryGreen,
                                isDesktop: isDesktop,
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildRoleCard(
                              id: 'restaurant',
                              icon: Icons.restaurant,
                              title: 'I am a Restaurant',
                              description:
                                  'Sourcing the freshest ingredients directly from local producers with reliable logistics.',
                              tags: ['Buyer', 'Kitchen'],
                              isSelected: _selectedRole == 'restaurant',
                              primaryColor: primaryGreen,
                              isDesktop: false,
                            ),
                            const SizedBox(height: 20),
                            _buildRoleCard(
                              id: 'farmer',
                              icon: Icons.agriculture,
                              title: 'I am a Farmer',
                              description:
                                  'Showcasing my bountiful harvest to top professional kitchens and managing wholesale orders.',
                              tags: ['Seller', 'Producer'],
                              isSelected: _selectedRole == 'farmer',
                              primaryColor: primaryGreen,
                              isDesktop: false,
                            ),
                          ],
                        ),

                      SizedBox(height: isDesktop ? 48 : 36),

                      // --- Continue Button ---
                      SizedBox(
                        width: double.infinity,
                        height: isDesktop ? 58 : 54,
                        child: ElevatedButton(
                          onPressed: _selectedRole == null
                              ? null
                              : () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUpScreen(
                                        selectedRole: _selectedRole!,
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _selectedRole != null ? primaryGreen : const Color(0xFFE2E8F0),
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
                            children: [
                              Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: isDesktop ? 18 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18),
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
          },
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
    required bool isDesktop,
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
        padding: EdgeInsets.all(isDesktop ? 28.0 : 22.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primaryColor.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 16 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAE6DA),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFF4A5D4E), size: 28),
                ),
                // Radio indicator icon
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? primaryColor : const Color(0xFFCBD5E1),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: isDesktop ? 22 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            // Description Text
            Text(
              description,
              style: TextStyle(
                fontSize: isDesktop ? 15 : 14,
                color: const Color(0xFF475569),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            // Dynamic Pills/Tags row
            Wrap(
              spacing: 8,
              runSpacing: 8,
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