import 'package:flutter/material.dart';
import 'package:mobile/core/app_locale.dart';
import 'package:mobile/features/auth/screens/get_started_screen.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/l10n/app_localizations.dart';

class FarmerSettingsScreen extends StatefulWidget {
  const FarmerSettingsScreen({super.key});

  @override
  State<FarmerSettingsScreen> createState() =>
      _FarmerSettingsScreenState();
}

class _FarmerSettingsScreenState extends State<FarmerSettingsScreen> {
  bool _pushNotifications = true;
  bool _smsAlerts = false;
  bool _darkMode = false;

  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;

  static const Color _primaryColor = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocale.notifier,
      builder: (context, locale, child) {
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          backgroundColor: const Color(0xFFFBFBFC),

          // ============================================================
          // APP BAR
          // ============================================================

          appBar: AppBar(
            backgroundColor: const Color(0xFFFBFBFC),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: _primaryColor,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              l10n.settings,
              style: const TextStyle(
                color: _primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
          ),

          // ============================================================
          // BODY
          // ============================================================

          body: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            children: [
              // ========================================================
              // ACCOUNT
              // ========================================================

              _buildSectionHeader(l10n.account),

              _buildSettingsTile(
                icon: Icons.person_outline,
                title: l10n.editProfile,
                subtitle: l10n.namePhoneNumberLocation,
                onTap: () {
                  // Navigate to Edit Profile
                },
              ),

              _buildSettingsTile(
                icon: Icons.lock_outline,
                title: l10n.security,
                subtitle: l10n.changePassword,
                onTap: () {
                  // Navigate to Security
                },
              ),

              const SizedBox(height: 16),

              // ========================================================
              // PREFERENCES
              // ========================================================

              _buildSectionHeader(l10n.preferences),

              // LANGUAGE
              _buildSettingsTile(
                icon: Icons.language,
                title: l10n.language,
                subtitle: locale.languageCode == 'km'
                    ? l10n.khmer
                    : l10n.english,
                onTap: _showLanguageDialog,
              ),

              // NOTIFICATIONS
              _buildSwitchTile(
                icon: Icons.notifications_none,
                title: l10n.notifications,
                subtitle: l10n.receiveMarketAlerts,
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                },
              ),

              // SMS ALERTS
              _buildSwitchTile(
                icon: Icons.sms_outlined,
                title: l10n.smsAlerts,
                subtitle: l10n.receiveUpdatesViaSms,
                value: _smsAlerts,
                onChanged: (value) {
                  setState(() {
                    _smsAlerts = value;
                  });
                },
              ),

              // DARK MODE
              _buildSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: l10n.darkMode,
                subtitle: l10n.switchAppTheme,
                value: _darkMode,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              // ========================================================
              // SUPPORT & INFO
              // ========================================================

              _buildSectionHeader(l10n.supportAndInfo),

              _buildSettingsTile(
                icon: Icons.help_outline,
                title: l10n.helpCenter,
                onTap: () {},
              ),

              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: l10n.privacyPolicy,
                onTap: () {},
              ),

              _buildSettingsTile(
                icon: Icons.info_outline,
                title: l10n.aboutApp,
                subtitle: l10n.version210,
                onTap: () {},
              ),

              const SizedBox(height: 24),

              // ========================================================
              // LOG OUT
              // ========================================================

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade700,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.red.shade200,
                    ),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: Text(
                  l10n.logOut,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: _showLogoutConfirmation,
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        bottom: 8,
      ),
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

  // ============================================================
  // SETTINGS TILE
  // ============================================================

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
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _primaryColor.withValues(alpha: 0.1),
          child: Icon(
            icon,
            color: _primaryColor,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              )
            : null,
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  // ============================================================
  // SWITCH TILE
  // ============================================================

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
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: SwitchListTile(
        secondary: CircleAvatar(
          backgroundColor: _primaryColor.withValues(alpha: 0.1),
          child: Icon(
            icon,
            color: _primaryColor,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        activeColor: _primaryColor,
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  // ============================================================
  // LANGUAGE DIALOG
  // ============================================================

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.selectLanguage),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: ValueListenableBuilder<Locale>(
            valueListenable: AppLocale.notifier,
            builder: (context, locale, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ====================================================
                  // KHMER
                  // ====================================================

                  ListTile(
                    leading: const Text(
                      '🇰🇭',
                      style: TextStyle(fontSize: 22),
                    ),
                    title: Text(l10n.khmer),
                    trailing: locale.languageCode == 'km'
                        ? const Icon(
                            Icons.check,
                            color: _primaryColor,
                          )
                        : null,
                    onTap: () async {
                      await AppLocale.setLocale(
                        const Locale('km'),
                      );

                      if (!dialogContext.mounted) return;

                      Navigator.pop(dialogContext);
                    },
                  ),

                  // ====================================================
                  // ENGLISH
                  // ====================================================

                  ListTile(
                    leading: const Text(
                      '🇬🇧',
                      style: TextStyle(fontSize: 22),
                    ),
                    title: Text(l10n.english),
                    trailing: locale.languageCode == 'en'
                        ? const Icon(
                            Icons.check,
                            color: _primaryColor,
                          )
                        : null,
                    onTap: () async {
                      await AppLocale.setLocale(
                        const Locale('en'),
                      );

                      if (!dialogContext.mounted) return;

                      Navigator.pop(dialogContext);
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // LOGOUT CONFIRMATION
  // ============================================================

  void _showLogoutConfirmation() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.logOut),
          content: Text(l10n.logoutConfirmation),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                l10n.cancel,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: _isLoggingOut
                  ? null
                  : () async {
                      Navigator.pop(dialogContext);
                      await _logout();
                    },
              child: Text(
                l10n.logOut,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      final result = await _authService.logout();

      if (!mounted) return;

      debugPrint(
        'LOGOUT STATUS: ${result['statusCode']}',
      );

      debugPrint(
        'LOGOUT RESPONSE: ${result['data']}',
      );

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
                  l10n.logoutFailed,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.logoutError}: $e',
          ),
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