import 'package:flutter/material.dart';
import 'package:mobile/core/app_locale.dart';

class AuthLanguageSwitch extends StatelessWidget {
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;

  const AuthLanguageSwitch({
    super.key,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocale.notifier,
      builder: (context, currentLocale, _) {
        final isKhmer = currentLocale.languageCode == 'km';

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              final newLocale =
                  isKhmer ? const Locale('en') : const Locale('km');
              await AppLocale.setLocale(newLocale);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: borderColor ?? Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isKhmer ? '🇰🇭' : '🇺🇸',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isKhmer ? 'ខ្មែរ' : 'EN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor ?? const Color(0xFF0F6221),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: 14,
                    color: textColor?.withValues(alpha: 0.7) ??
                        const Color(0xFF0F6221).withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
