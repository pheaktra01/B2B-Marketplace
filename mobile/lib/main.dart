import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:mobile/core/app_locale.dart';
import 'package:mobile/core/routing/app_router.dart';
import 'package:mobile/features/notification/services/push_notification_service.dart';
import 'package:mobile/l10n/app_localizations.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  await AppLocale.load();

  // Initialize push notifications & background handler (mobile only)
  if (!kIsWeb) {
    await PushNotificationService.initialize();
  }

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