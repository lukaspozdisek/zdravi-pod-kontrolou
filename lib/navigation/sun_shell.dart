import 'package:flutter/material.dart';

import '../sun_home.dart';
import '../theme/sun_theme.dart';
import '../widgets/sun_bottom_menu.dart';
import '../pages/food_page.dart';
import '../pages/mission_page.dart';
import '../pages/community_page.dart';
import '../pages/profile_page.dart';

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
          const FoodPage(),
          const MissionPage(),
          const CommunityPage(),
          const ProfilePage(),
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