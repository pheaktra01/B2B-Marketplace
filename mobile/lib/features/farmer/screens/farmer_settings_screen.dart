import 'package:flutter/material.dart';
import 'package:mobile/features/auth/screens/get_started_screen.dart';
import 'package:mobile/features/auth/services/auth_service.dart';

class FarmerSettingsScreen extends StatefulWidget {
  const FarmerSettingsScreen({super.key});

  @override
  State<FarmerSettingsScreen> createState() => _FarmerSettingsScreenState();
}

class _FarmerSettingsScreenState extends State<FarmerSettingsScreen> {
  // State variables for toggles
  bool _pushNotifications = true;
  bool _smsAlerts = false;
  bool _darkMode = false;
  String _selectedLanguage = 'English';

  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;

  final Color _primaryColor = const Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFBFC),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: _primaryColor.withValues(alpha: 0.9),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Section: Account
          _buildSectionHeader('Account'),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Name, Phone Number, Location',
            onTap: () {
              // Navigate to Edit Profile screen
            },
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Security',
            subtitle: 'Change Password',
            onTap: () {
              // Navigate to Password/Security screen
            },
          ),

          const SizedBox(height: 16),

          // Section: Preferences
          _buildSectionHeader('Preferences'),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: _selectedLanguage,
            onTap: _showLanguageDialog,
          ),
          _buildSwitchTile(
            icon: Icons.notifications_none,
            title: 'Notifications',
            subtitle: 'Receive market alerts',
            value: _pushNotifications,
            onChanged: (val) => setState(() => _pushNotifications = val),
          ),
          _buildSwitchTile(
            icon: Icons.sms_outlined,
            title: 'SMS Alerts',
            subtitle: 'Receive updates via SMS',
            value: _smsAlerts,
            onChanged: (val) => setState(() => _smsAlerts = val),
          ),
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Switch app theme',
            value: _darkMode,
            onChanged: (val) => setState(() => _darkMode = val),
          ),

          const SizedBox(height: 16),

          // Section: Support & Info
          _buildSectionHeader('Support & Info'),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Help Center',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About App',
            subtitle: 'Version 2.1.0',
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // Logout Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red.shade200),
              ),
            ),
            icon: const Icon(Icons.logout),
            label: const Text(
              'Log Out',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onPressed: _showLogoutConfirmation,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _primaryColor.withValues(alpha: 0.1),
          child: Icon(icon, color: _primaryColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: subtitle != null
            ? Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))
            : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        secondary: CircleAvatar(
          backgroundColor: _primaryColor.withValues(alpha: 0.1),
          child: Icon(icon, color: _primaryColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        activeColor: _primaryColor,
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Khmer'),
                trailing: _selectedLanguage == 'Khmer'
                    ? Icon(Icons.check, color: _primaryColor)
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = 'Khmer');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('English'),
                trailing: _selectedLanguage == 'English'
                    ? Icon(Icons.check, color: _primaryColor)
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = 'English');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text(
            'Are you sure you want to log out of the app?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: _isLoggingOut
                  ? null
                  : () async {
                      Navigator.pop(dialogContext);
                      await _logout();
                    },
              child: const Text(
                'Log Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      final result = await _authService.logout();

      if (!mounted) return;

      print('LOGOUT STATUS: ${result['statusCode']}');
      print('LOGOUT RESPONSE: ${result['data']}');

      if (result['statusCode'] >= 200 &&
          result['statusCode'] < 300) {
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const GetStartedScreen(),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['data']['message']?.toString() ??
                  'Logout failed',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout error: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }
}