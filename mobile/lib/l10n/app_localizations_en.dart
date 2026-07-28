// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Marketplace';

  @override
  String get login => 'Login';

  @override
  String get signup => 'Sign Up';

  @override
  String get language => 'Language';

  @override
  String get chooseLanguage => 'Choose Your Language';

  @override
  String get selectLanguageDescription =>
      'Select your language to use\nPsarKasekor';

  @override
  String get continueButton => 'Continue';
}
