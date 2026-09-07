import 'package:flutter/material.dart';
import 'package:mobile/core/app_locale.dart';
import 'package:mobile/core/routing/app_router.dart';
import 'package:mobile/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppLocale.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocale.notifier,
      builder: (context, locale, _) {
        return MaterialApp.router(
          title: 'PsarKasekor',
          debugShowCheckedModeBanner: false,

          locale: locale,

          supportedLocales:
              AppLocalizations.supportedLocales,

          localizationsDelegates:
              AppLocalizations.localizationsDelegates,

          routerConfig: AppRouter.router,
        );
      },
    );
  }
}