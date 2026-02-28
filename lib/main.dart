import 'package:flutter/material.dart';
import 'package:convex_flutter/convex_flutter.dart';

import 'package:zdravi_pod_kontrolou/core/app_settings.dart';
import 'package:zdravi_pod_kontrolou/core/app_scope.dart';
import 'package:zdravi_pod_kontrolou/theme/sun_theme.dart';
import 'package:zdravi_pod_kontrolou/navigation/sun_shell.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zdravi_pod_kontrolou/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ConvexClient.initialize(
    ConvexConfig(
      deploymentUrl: 'https://polite-kookabura-676.eu-west-1.convex.cloud',
      clientId: 'zdravi-pod-kontrolou',
    ),
  );

  final settings = AppSettings();
  await settings.load();

  runApp(SunApp(settings: settings));
}

class SunApp extends StatelessWidget {
  final AppSettings settings;

  const SunApp({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      settings: settings,
      child: AnimatedBuilder(
        animation: settings,
        builder: (_, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            // THEME
            theme: SunTheme.light(settings.genderMode),
            darkTheme: SunTheme.dark(settings.genderMode),
            themeMode: settings.themeMode,

            // LOCALE
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // ✅ SunShell reads everything from AppScope (no params here)
            home: const SunShell(),
          );
        },
      ),
    );
  }
}
