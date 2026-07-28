import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/app_locale.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('setLocale updates notifier and persists selection', () async {
    SharedPreferences.setMockInitialValues({});
    await AppLocale.setLocale(const Locale('km'));

    expect(AppLocale.notifier.value.languageCode, 'km');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selected_language_code'), 'km');
  });
}
