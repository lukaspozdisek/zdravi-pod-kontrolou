import 'package:flutter/material.dart';

import 'theme/sun_theme.dart';
import 'sun_home.dart';

import 'widgets/sun_bottom_menu.dart';
import 'pages/diary_page.dart';
import 'pages/core_page.dart';
import 'pages/community_page.dart';
import 'pages/more_page.dart';

void main() {
  runApp(const SunApp());
}

class SunApp extends StatefulWidget {
  const SunApp({super.key});

  @override
  State<SunApp> createState() => _SunAppState();
}

class _SunAppState extends State<SunApp> {
  ThemeMode themeMode = ThemeMode.dark;
  SunGenderMode genderMode = SunGenderMode.woman;

  void toggleTheme() {
    setState(() {
      themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void setGender(SunGenderMode g) {
    setState(() => genderMode = g);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: SunTheme.light(genderMode),
      darkTheme: SunTheme.dark(genderMode),
      themeMode: themeMode,
      home: SunShell(
        themeMode: themeMode,
        genderMode: genderMode,
        onToggleTheme: toggleTheme,
        onToggleGender: setGender,
      ),
    );
  }
}

/// Bottom tabs order:
/// 0 Přehled  -> SunHome
/// 1 Deník    -> DiaryPage
/// 2 Core     -> CorePage
/// 3 Komunita -> CommunityPage
/// 4 More     -> MorePage
class SunShell extends StatefulWidget {
  final ThemeMode themeMode;
  final SunGenderMode genderMode;
  final VoidCallback onToggleTheme;
  final ValueChanged<SunGenderMode> onToggleGender;

  const SunShell({
    super.key,
    required this.themeMode,
    required this.genderMode,
    required this.onToggleTheme,
    required this.onToggleGender,
  });

  @override
  State<SunShell> createState() => _SunShellState();
}

class _SunShellState extends State<SunShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [
          SunHome(
            themeMode: widget.themeMode,
            genderMode: widget.genderMode,
            onToggleTheme: widget.onToggleTheme,
            onToggleGender: widget.onToggleGender,
          ),
          const DiaryPage(),
          const CorePage(),
          const CommunityPage(),
          const MorePage(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: SunBottomMenu(
            index: index,
            onChanged: (i) => setState(() => index = i),
            genderMode: widget.genderMode,
          ),
        ),
      ),
    );
  }
}