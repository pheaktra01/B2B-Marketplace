import 'package:flutter/material.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/farmer/screens/farmer_profile_screen.dart';
import 'package:mobile/features/notification/screens/notifications_screen.dart';
import 'package:mobile/features/notification/services/notification_service.dart';
import 'package:mobile/features/profile/services/user_service.dart';

class FarmerAppBar extends StatefulWidget implements PreferredSizeWidget {
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
  State<FarmerAppBar> createState() => _FarmerAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _FarmerAppBarState extends State<FarmerAppBar> {
  String? _avatarUrl;
  int _unreadNotificationCount = 0;

  final UserService _userService = UserService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadAppBarData();
  }

  Future<void> _loadAppBarData() async {
    try {
      final profile = await _userService.getProfile();
      final data = profile['data'];
      final avatar = data is Map ? data['avatarUrl']?.toString() : null;
      if (mounted && avatar != null && avatar.isNotEmpty) {
        setState(() => _avatarUrl = ApiConstants.imageUrl(avatar));
      }
    } catch (error) {
      debugPrint('Failed to load app bar profile: $error');
    }

    try {
      final count = await _notificationService.getUnreadCount();
      if (mounted) setState(() => _unreadNotificationCount = count);
    } catch (error) {
      debugPrint('Failed to load unread notification count: $error');
    }
  }

  Future<void> _openNotifications(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
    _loadAppBarData();
  }

  Future<void> _openProfile(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FarmerProfileScreen()),
    );
    _loadAppBarData();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFFFBFBFC),
      elevation: 0,
      titleSpacing: 16,
      title: widget.showLogo
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
          : Text(widget.title),
      actions:
          widget.actions ??
          [
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_none,
                    size: 28,
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.9),
                  ),
                  onPressed: () => _openNotifications(context),
                ),
                if (_unreadNotificationCount > 0)
                  Positioned(
                    right: 4,
                    top: 3,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 16),
                      height: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFFBFBFC),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        _unreadNotificationCount > 99
                            ? '99+'
                            : '$_unreadNotificationCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: widget.isProfileScreen
                  ? IconButton(
                      icon: Icon(
                        Icons.settings,
                        size: 28,
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.9),
                      ),
                      onPressed:
                          widget.onSettingsTap ??
                          () {
                            // Navigate to Settings screen here
                          },
                    )
                  : InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _openProfile(context),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(
                              0xFF2E7D32,
                            ).withValues(alpha: 0.8),
                            width: 2.0,
                          ),
                        ),
                        child: ClipOval(
                          child: _avatarUrl == null
                              ? Image.asset(
                                  'assets/mokoto.jpg',
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  _avatarUrl!,
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                        'assets/mokoto.jpg',
                                        width: 36,
                                        height: 36,
                                        fit: BoxFit.cover,
                                      ),
                                ),
                        ),
                      ),
                    ),
            ),
          ],
    );
  }
}
