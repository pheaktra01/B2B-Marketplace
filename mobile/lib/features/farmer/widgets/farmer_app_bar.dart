import 'package:flutter/material.dart';
import 'package:mobile/features/farmer/screens/farmer_profile_screen.dart';
import 'package:mobile/features/notification/screens/notifications_screen.dart';

class FarmerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showLogo;
  final bool isProfileScreen;
  final VoidCallback? onSettingsTap;

  const FarmerAppBar({
    super.key,
    this.title = '',
    this.actions,
    this.showLogo = true,
    this.isProfileScreen = false,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFFFBFBFC),
      elevation: 0,
      titleSpacing: 16,
      title: showLogo
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/logo01.png',
                    height: 36,
                    width: 36,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'PsarKasekor',
                  style: TextStyle(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.9),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            )
          : Text(title),
      actions: actions ??
          [
            IconButton(
              icon: Icon(
                Icons.notifications_none,
                size: 28,
                color: const Color(0xFF2E7D32).withValues(alpha: 0.9),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: isProfileScreen
                  ? IconButton(
                      icon: Icon(
                        Icons.settings,
                        size: 28,
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.9),
                      ),
                      onPressed: onSettingsTap ??
                          () {
                            // Navigate to Settings screen here
                          },
                    )
                  : InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FarmerProfileScreen(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF2E7D32).withValues(alpha: 0.8),
                            width: 2.0,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage('assets/profile.png'),
                        ),
                      ),
                    ),
            ),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}