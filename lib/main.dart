import 'package:flutter/material.dart';
import 'package:convex_flutter/convex_flutter.dart';

import 'package:zdravi_pod_kontrolou/core/app_settings.dart';
import 'package:zdravi_pod_kontrolou/core/app_scope.dart';
import 'package:zdravi_pod_kontrolou/theme/sun_theme.dart';

import 'package:zdravi_pod_kontrolou/pages/dashboard_page.dart';
import 'package:zdravi_pod_kontrolou/pages/diary_page.dart';
import 'package:zdravi_pod_kontrolou/pages/core_page.dart';
import 'package:zdravi_pod_kontrolou/pages/community_page.dart';
import 'package:zdravi_pod_kontrolou/pages/more_page.dart';
import 'package:zdravi_pod_kontrolou/widgets/sun_bottom_menu.dart';

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

  // 🔥 Načtení uložených settings
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

            // 🔥 THEME
            theme: SunTheme.light(settings.genderMode),
            darkTheme: SunTheme.dark(settings.genderMode),
            themeMode: settings.themeMode,

            // 🔥 LOCALE
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            home: const SunShell(),
          );
        },
      ),
    );
  }
}

/// Bottom tabs order:
/// 0 Přehled  -> DashboardPage
/// 1 Deník    -> DiaryPage
/// 2 Core     -> CorePage
/// 3 Komunita -> CommunityPage
/// 4 More     -> MorePage
class SunShell extends StatefulWidget {
  const SunShell({super.key});

  @override
  State<SunShell> createState() => _SunShellState();
}

class _SunShellState extends State<SunShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          DashboardPage(),
          DiaryPage(),
          CorePage(),
          CommunityPage(),
          MorePage(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: SunBottomMenu(
            index: index,
            onChanged: (i) => setState(() => index = i),
            genderMode: settings.genderMode,
          ),
        ),
      ),
    );
  }
}
