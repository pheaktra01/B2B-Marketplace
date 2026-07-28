import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocale {
  AppLocale._();

  static const String _storageKey = 'selected_language_code';
  static final ValueNotifier<Locale> notifier = ValueNotifier<Locale>(const Locale('en'));

  static Locale get current => notifier.value;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_storageKey);

    if (languageCode == null || languageCode == 'en') {
      notifier.value = const Locale('en');
      return;
    }

    if (languageCode == 'km') {
      notifier.value = const Locale('km');
      return;
    }

    notifier.value = const Locale('en');
  }

  static Future<void> setLocale(Locale locale) async {
    notifier.value = locale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, locale.languageCode);
  }
}
